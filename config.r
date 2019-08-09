Rebol [
    Title: "Tiny Framework - configuration"
]

; to access the publicDir, start the url with /public/
; 'publicPrefix must have a / at the end
; file!s don't need to have one

port: 8000

routingDir: %routing/
routeFiles: [%routes.r]

controllersDir: %controllers/
templatesDir: %templates/    

storageDir: %storage/

publicDir: %storage/public/
publicPrefix: "/public/"