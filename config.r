Rebol [
    Title: "Tiny Framework - configuration"
]

; to access the public_dir, start the url with /public/
config: make object! [
    port: 8000

    public_dir: %public/
    public_prefix: "/public2/"

    routing_dir: %routing/
    route_files: [%routes.r]

    controllers_dir: %controllers/
    templates_dir: %templates/    
]
