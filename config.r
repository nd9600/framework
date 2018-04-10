Rebol [
    Title: "Tiny Framework - configuration"
]

; to access the public_dir, start the url with /public/
; 'public_prefix must have a / at the end
; file!s don't need to have one
config: make object! [
    port: 8000

    public_dir: %../../site/
    public_prefix: "/public/"

    routing_dir: %routing/
    route_files: [%routes.r]

    controllers_dir: %controllers/
    templates_dir: %templates/    
]
