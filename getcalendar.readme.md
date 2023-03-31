# Setup instructions for getcalendar script

There's one particular piece of the MacOS Calendar integration that is tricky enough it deserves explanation: authorization.

Before the `getcalendar.swift` script can actually read calendar data, _the process that invokes it needs to be granted permission to read the Calendar_

However, you can't just add this permission via System Preferences. There's no "add" button for Calendar. Why not? No one seems to know.

Instead, you need to have the invoking process run a small AppleScript that triggers the authorization panel for user interaction. This script is included here as `calendar_auth.scpt` 

What do I mean by "invoking process"?

Well, if you're using Espanso as a keyboard macro / substitution tool, Espanso has to be granted permission. Same with tools like Keyboard Maestro. For these tools, the solution is to have them invoke the provided Apple Script _just once_ after which they're good to go.

For Espanso, do something like this in your base.yml configuration:
```
  # run getcalendar tana paste integration
  - trigger: ";;cal"
    replace: "{{output}}"
    vars:
      - name: output
        type: shell
        params:
          cmd: "~/dev/tana/tana-paste-examples/getcalendar.swift -me 'Brett Adam'"

  - trigger: ";;setup"
    replace: "{{output}}"
    vars:
      - name: output
        type: shell
        params:
          cmd: "osascript ~/dev/tana/tana-paste-examples/calendar_auth.scpt"
```
And then invoke the `;;setup` macro one time. 

