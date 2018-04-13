Rebol [
    Title: "Tiny Framework"
    Documentation: http://www.rebol.net/cookbook/recipes/0057.html
]

;brings in the base FP functions
do %base/functional.r

do %base/helpers.r

config: context load %config.r

routing: context load %base/routing.r

templater: context load %base/templater.r

do %base/request.r

do %base/response.r

;stops the framework if a test fails
do %tests.r

listenPort: open/lines append tcp://: config/port  ; port used for web connections

print rejoin ["^/listening on port " config/port]

; set up the routes
routeFilesLocations: copy f_map lambda [append copy config/routing_dir ?] config/route_files
routing/get_routes routeFilesLocations

routing/print_routes

; holds the request information which is printed out as connections are made
buffer: make string! 1024  ; will auto-expand if needed

; processes each HTTP request from a web browser. The first step is to wait for a connection on the listenPort. When a connection is made, the httpPort variable is set to the TCP port connection and is then used to get the HTTP request from the browser and send the result back to the browser.
forever [
    print rejoin [newline "#####"]
    print "waiting for request"

    httpPort: first wait listenPort
    clear buffer
    print "waiting over"

    if error? error: try [
        ; gathers the browser's request, a line at a time. The host name of the client (the browser computer) is added to the buffer string. It is just for your own information. If you want, you could use the remote-ip address instead of the host name.
        while [not empty? http_request: first httpPort][
            repend buffer [http_request newline]
        ]
        repend buffer ["Address: " httpPort/host newline]
        
        request: makeRequest config buffer
        print rejoin ["request: [" newline request "]" newline]
                     
        response: handleRequest config routing request
        sendResponse response httpPort

        ; block must return something so we can 'try it
        none
    ] [
        error: disarm error

        str_error: errorToString error

        print rejoin [newline "#####" newline "error: " str_error]
        sendResponse make response_obj compose [
            status: 500 
            data: (str_error)
        ]
    ]

    ; makes sure that the connection from the browser is closed, now that the requested web data has been returned.
    print "port closed"
    close httpPort
]
