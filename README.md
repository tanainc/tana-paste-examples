# Tana Paste example scripts

## Example scripts that generate Tana Paste output

Tana Paste is a special text format that is parsed by Tana, and generates rich Tana structures when pasted normally. All text is preceded by `%%tana%%` to trigger this special functionality. More details about the format [in the help center](https://help.tana.inc/build-tutorials/tana-paste.html).

https://www.loom.com/share/6fd81ff1ab364acf9f448ffdedfeb57f

All these scripts are provided solely as examples/inspiration. Feel free to modify, or use as templates to explore other sources of data. If you have interesting improvements or new scripts, we welcome pull requests.

You can run these scripts normally to inspect the output, but we recommend piping to pbcopy on Mac or similar tools to put the text directly on the clipboard for use with Tana. These scripts an also be launched automatically by tools like Keyboard Maestro.

## Scripts and usage

- rss.mjs [URL to RSS feed]
  - Fetches top 3 items from an RSS feed
  - Notice that the URL must be to the actual RSS feed, the script does not "discover" the RSS feed URL from the website URL like many feed readers
  - ![image](https://user-images.githubusercontent.com/61575/188881503-12e70e93-6f73-4f1d-bf5d-30d2094818d1.png)
- github.mjs [organization][repo]
  - fetches five pull requests from the given org/repo
  - requires githubToken in config.js
  - many other kinds of data can be fetched with the Github API
  - ![image](https://user-images.githubusercontent.com/61575/188881329-1d97325e-e503-4d2e-a659-77631a3bfa0a.png)
- twitter.mjs [tweet id]
  - fetches the tweet specified and some related tweets
  - requires Twitter token in config.js
  - ![image](https://user-images.githubusercontent.com/61575/188881173-01cc0dfc-eeec-4e20-9cad-e9b102489de2.png)
- hypothesis.mjs [webpage url]
  - fetches all your annotations/highlights for a given website from Hypothes.is (great "web clipper")
  - requires Hypothes.is token in config.js
  - ![image](https://user-images.githubusercontent.com/61575/188881856-00987def-eb21-442a-a265-6b10c52169b3.png)
- retro.mjs
  - generates links to the daily node 7, 30, 90, 180, 360 days ago
  - also an automatic GMail search for emails you've written in the past - easy to remove if you don't want it
  - note that you can currently not click on inline date references in Tana to go to the corresponding date node, but that functionality is planned
  - ![image](https://user-images.githubusercontent.com/61575/188881604-43a65115-46cc-4cbb-a780-5b4e57e9b7b5.png)
- zotero-translator-tana.js
  - can be moved to the Zotero/Translations folder, and used to copy bibliography elements out of Zotero into Tana
  - ![image](https://user-images.githubusercontent.com/61575/188881053-dfdab35a-b24b-4d48-9556-5ad00c34c208.png)
- readwise.mjs [days (x)]
  - fetches highlights taken in the last x days from Readwise
  - ![image](https://user-images.githubusercontent.com/8036315/193777925-f9de1f80-c755-4ffd-a2d1-0e9125795f7b.png)

### External Scripts

- [macOS Calendar->Tana](https://github.com/willplatnick/calendar-tana)
  - macOS only. Fetches calendar events happening today from macOS Calendar app.
- [Things 3->Tana](https://github.com/willplatnick/things-tana)
  - macOS only. Fetches tasks due today from Things 3.
  
