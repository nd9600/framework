# My <50kb web framework
## Cross-platform, written in Rebol - it'll be rewritten in Red once Red gets full IO support

To use it:
1. Download Rebol from http://www.rebol.com/downloads.html - only the Core version is needed
2. Run `rebol framework.r`.

That's it. You can change the configuration in `config.r`, but by default, it:
* runs on port 8000
* uses routes from the `routing/` directory, and
* loads routes from a `routes.r` file - you can add more, or even use strings if you want
* uses controllers from the `controllers/` folder 
* uses templates from the `templates/` folder
* can store and access files from the `storage/` folder
* serves files straight from the `storage/public/` directory, if a request URL starts with `/public/`
