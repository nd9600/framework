Rebol [
    Title: "Tiny Framework - configuration"
]

config: make object! [
    port: 8000
    public_dir: %public/
    routing_dir: %routing/
    route_files: [%routes.r]
    controllers_dir: %controllers/
]