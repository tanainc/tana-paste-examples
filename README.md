# Tana Paste example scripts

## Example scripts that generate Tana Paste output

Tana Paste is a special text format that is parsed by Tana, and generates rich Tana structures when pasted normally. All text is preceded by `%%tana%%` to trigger this special functionality. More details about the format [in the help center](https://be.tana.inc?nodeid=83JNrPSOgO).

All these scripts are provided solely as examples/inspiration. Feel free to modify, or use as templates to explore other sources of data. If you have interesting improvements or new scripts, we welcome pull requests.

You can run these scripts normally to inspect the output, but we recommend piping to pbcopy on Mac or similar tools to put the text directly on the clipboard for use with Tana. These scripts an also be launched automatically by tools like Keyboard Maestro.

## Scripts and usage

- rss.mjs [URL to RSS feed]
  - Fetches top 3 items from an RSS feed
  - Notice that the URL must be to the actual RSS feed, the script does not "discover" the RSS feed URL from the website URL like many feed readers
- github.mjs [organization][repo]
  - fetches five pull requests from the given org/repo
  - requires githubToken in config.js
  - many other kinds of data can be fetched with the Github API
- twitter.mjs [tweet id]
  - fetches the tweet specified and some related tweets
  - requires Twitter token in config.js
- hypothesis.mjs [webpage url]
  - fetches all your annotations/highlights for a given website from Hypothes.is (great "web clipper")
  - requires Hypothes.is token in config.js
- retro.mjs
  - generates links to the daily node 7, 30, 90, 180, 360 days ago
  - note that you can currently not click on inline date references in Tana to go to the corresponding date node, but that functionality is planned
- zotero-translator-tana.js
  - can be moved to the Zotero/Translations folder, and used to copy bibliography elements out of Zotero into Tana
