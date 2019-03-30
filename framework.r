Rebol [
    Title: "Tiny Framework"
    Documentation: http://www.rebol.net/cookbook/recipes/0057.html
]

do %base/moduleLoader.r

;brings in the base FP functions
do %base/functional.r

do %base/helpers.r

config: import %config.r

routing: context load %base/routing.r

templater: context load %base/templater.r

do %base/request.r

do %base/response.r

;stops the framework if a test fails
do %tests.r

serverPort: open/lines append tcp://: config/port  ; port used for web connections

print rejoin ["^/listening on port " config/port]

; set up the routes
routeFilesLocations: copy f_map lambda [append copy config/routingDir ?] config/routeFiles
routing/setRoutes routeFilesLocations

routing/printRoutes

; holds the request information which is printed out as connections are made
buffer: make string! 1024  ; will auto-expand if needed

; processes each HTTP request from a web browser. The first step is to wait for a connection on the serverPort. When a connection is made, the connectionPort variable is set to the TCP port connection and is then used to get the HTTP request from the browser and send the result back to the browser.
forever [
    print rejoin [newline "#####"]
    print "waiting for request"

    connectionPort: first wait serverPort
    clear buffer
    print "waiting over"

    if error? error: try [
        buffer: makeBufferFromConnectionPort buffer connectionPort
        
        request: makeRequest config buffer
        print rejoin ["request: [" newline request "]" newline]
                     
        response: handleRequest config routing request
        sendResponse response connectionPort

        ; block must return something so we can 'try it
        none
    ] [
        error: disarm error

        str_error: errorToString error

        print rejoin [newline "#####" newline "error: " str_error]
        response: make response_obj compose [
            status: 500 
            data: (str_error)
        ]
        sendResponse response connectionPort
    ]

    ; makes sure that the connection from the browser is closed, now that the requested web data has been returned.
    print "port closed"
    close connectionPort
]