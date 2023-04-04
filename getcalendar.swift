#!/usr/bin/swift

/*

*/

import Foundation
import EventKit

var args = CommandLine.arguments
let script_name = args[0]

func help() {
    fputs(
"""
    Simple script to grab calendar events via the Apple Calendar
    app, filter them and then format them as a tana-paste format
    blob of text. Use a keyboard macro accelerator or other
    mechanism to get this into Tana 

    If you run this from terminal you can do:
        ./getcalendar | pbcopy

    And then simply paste the result into Tana.

    Accepts arguments, many of which should be quoted on the cmd line:

        -calendar "name of calendar"  <default: Calendar >

        -me "name of yourself in meeting attendees"  <default: Me >
        Script removes yourself from meeting attendees. If you leave it as default, 
        you will be included since Calendar doesn't use "me" as a name anywhere

        -ignore "event title to ignore"  (can be repeated)

        <starts out as defaults "Block", "Lunch", "DNS/Focus time",  "DNS/Lunch", "Focus time" >

        -solo (if present, include meetings with a single attendee)

        -one2one "#[[tag name for one2one meetings]]" <default #[[1:1]] >

        -meeting "#[[tag name for regular meetings]]" <default: #[[meeting]] >

        -person "#[[tag name for attendees]]" <default: #person >

        -offset <default 0>
        Which day to query for. +1 means tomorrow, -1 mean yesterday

        -range <default 1>
        How many days to query for from offset.

        -json
        Emit a JSON blob per event in addition to the other output as a Tana field

    Example:

        ./getcalendar.swift -me "Brett Adam" -person "#people"

    Calendar access authorization:

    This script will produce empty results until your script runner is authorized to access
    your calendar via Calendar.app

    See the associated getcalendar.readme.md file for instructions.
    """, stdout)
}

func usage() {
    print("Usage: \(script_name)\n")
    help()
    exit(1)
}


// TODO: make these parameters somehow!
var calendar_name = "Calendar"
var self_name = "Me"
var titles_to_ignore = ["Block", "Lunch", "DNS/Focus time",  "DNS/Lunch", "Focus time" ]
var ignore_solo_meetings = true
var emit_json = false

var meeting_tag = "#meeting"
var one2one_tag = "#[[1:1]]"
var person_tag = "#person"
var day_offset:Int = 0
var day_range = 1

var next:String? = nil

args.removeFirst() // strip command itself
for argument in args {
    if next == nil {
        next = argument
        // process zero-param toggles
        if next != nil {
            switch next {
                case "-help":
                    help()
                    exit(0)
                case "-solo":
                    ignore_solo_meetings = false
                    next = nil
                    continue // get next arg
                case "-json":
                    emit_json = true
                    next = nil
                    continue // get next arg
                default: 
                    continue // move on to process arg
            } 
        }
    }

    // process the arg after the switch
    if next != nil {
        switch next {
            case "-calendar":
                calendar_name = argument
            case "-me":
                self_name = argument
            case "-ignore":
                titles_to_ignore.append(argument)
            case "-one2one":
                one2one_tag = argument
            case "-meeting":
                meeting_tag = argument
            case "-person":
                person_tag = argument
            case "-offset":
                day_offset = Int(argument) ?? 0
            case "-range":
                day_range = Int(argument) ?? 1
            default:
                fputs("Unknown argument " + next! + "\n\n", stderr)
                usage()
        }
        next = nil
    }
}

if next != nil {
    fputs("Missing argument for " + next! + "\n\n", stderr)
    usage()
}

// tana-paste format to follow...
print("%%tana%%")

// some structs we need for working with the data
struct Event: Codable {
    let title: String
    let startDate: String
    let endDate: String
    let location: String?
    let attendees: [Attendee]?
    let notes: String?
    let recurrence: [String]?

    init(title: String, startDate:String, endDate:String,
        attendees:[Attendee]?=nil, notes:String?=nil, location:String?=nil, recurrence:[String]?=nil) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.attendees = attendees
        self.notes = notes
        self.recurrence = recurrence
    }
}

struct Attendee: Codable {
    let name: String
    let url: URL?

    init(name:String, url:URL?=nil) {
        self.name = name
        self.url = url
    }
}


let eventStore = EKEventStore()

// Ask for Calendar access, reset in case we messed up earlier
// See stackoverflow. 
// IMPORTANT: you must grant Calendar access to whatever script runner
// you are using. This can be tricky to pull off since you cannot do 
// this manually in System Preferences (Grr) 
// For example, Keyboard Maestro needs a "helper" the first time
// See https://forum.keyboardmaestro.com/t/icalbuddy-doesnt-work-within-keyboard-maestro-mojave-calendar-permissions/15446/40?u=brett_adam

eventStore.requestAccess(to: .event) { (granted, error) in
    if granted {
      eventStore.reset()
       // go on managing reminders
    }
}

let today = Calendar.current.startOfDay(for: Date())

let startDate = Calendar.current.date(byAdding: .day, value: 0 + day_offset, to: today)!
let endDate = Calendar.current.date(byAdding: .day, value: day_range + day_offset, to: today)!

let calendars = eventStore.calendars(for: .event )

let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)

let events = eventStore.events(matching: predicate)

// process all of the evewnts

// filter all the events we don't care about
// and narrow to our single relevant calendar
let filteredEvents = events.filter { event in
    event.calendar.title == calendar_name
    && !titles_to_ignore.contains(event.title)
}

// Now map the event array to our own internal structure
// stripping off various aspects as we go along
let eventArray = filteredEvents.map { event in
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd H:mm"
    let startDateString = formatter.string(from: event.startDate)
    let endDateString = formatter.string(from: event.endDate)
    
    // Filter the notes field
    var notes = event.notes
    if let range = event.notes?.range(of: "~==========================~") {
        notes = String(event.notes![..<range.lowerBound])
    }

    if let range = event.notes?.range(of: "is inviting you to") {
        notes = String(event.notes![..<range.lowerBound])
    }

    if let range = event.notes?.range(of: "Microsoft Teams meeting") {
        notes = String(event.notes![..<range.lowerBound])
    }   

    if let range = event.notes?.range(of: "[Autodesk]\r\nBrett Adam") {
        notes = String(event.notes![..<range.lowerBound])
    } 


    notes = notes?.trimmingCharacters(in: .whitespacesAndNewlines)

    // crunch the attendees list
    let attendees = event.attendees?.compactMap { (attendee: EKParticipant) -> Attendee? in
        guard let name = attendee.name else {
            return nil
        }
        
        return Attendee(name: name
            //, url: attendee.url
            )
    }
    
    let recurrence: [String]? = event.hasRecurrenceRules ? event.recurrenceRules!.map { rule in
         return rule.description
    } : nil
    
    return Event(title: event.title
        , startDate: startDateString, endDate: endDateString
        , attendees: attendees, notes: notes
        , location: event.location
        , recurrence: recurrence
        )
}

// generate ouutput in tana-paste format
for event in eventArray {
    var node_tag = meeting_tag
    var name = "- " + event.title + " with "
    var attendee_field = "  - Attendees:: \n"
    var count = 0
    let num_attendees = event.attendees?.count ?? 0

    if num_attendees >= 5 {
        name = name + " (many people)"
    }

    for attendee in event.attendees ?? [] {
        count += 1
        if attendee.name != self_name {
            // don't put more than 5 people in the name of the meeting node
            if num_attendees < 5 {
                name = name + " [[" + attendee.name + "]]"
            }

            attendee_field = attendee_field + "    - [[" + attendee.name + person_tag + "]]\n"
        }
        else {
            attendee_field = attendee_field + ""
        }
    }

    if count == 0 && ignore_solo_meetings {
        continue;
    }

    if count == 2 {
        node_tag = one2one_tag
    }

    print(name + " " + node_tag)
    fputs(attendee_field, stdout)
    print("  - Start time:: [[date:" + String(event.startDate) + "/" + String(event.endDate) + "]]")
    
    // spit out JSON for further examination or to feed RAW to some other API
    if emit_json {
        emitJSON(event:event)
    }
}

// OLD JSON code if you want to see raw data
// or feed to this to other consuming tools via API
func emitJSON(event:Event) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    do {
        let jsonData = try encoder.encode(event)
        if let jsonString = String(data: jsonData, encoding: .utf8) {            
        print("- " + event.title + " with  #meeting")
        print("  - JSON:: \(jsonString)")            
        }
    } catch {
        print("Error encoding JSON: \(error)")
    }
}