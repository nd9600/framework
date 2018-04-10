# My cross-platform web framework, in less than 50kb, written in Rebol - it'll be rewritten in Red once Red gets full IO support

To use it:
1. Download Rebol from http://www.rebol.com/downloads.html - only the Core version is needed
2. Run `rebol framework.r`.

That's it. You can change the configuration in `config.r`, but by default, it:
* runs on port 8000
* serves files straight from the `storage/public/` directory
* uses controllers from the `controllers/` folder 
* uses routes from the `routing/` directory, and
* loads routes from a `routes.r` file - you can add more, or even use strings if you want
