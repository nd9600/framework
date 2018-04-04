Rebol [
    Title: "Tiny Framework"
    Documentation: http://www.rebol.net/cookbook/recipes/0057.html
]

;brings in the base FP functions
do %functional.r

do %data_structures.r

do %helpers.r

;brings in the config into an object called 'config
do %config.r

;brings in the routing functions into an object called 'routing
do %routing/routing.r

;brings in the templating functions into an object called 'templater
do %views/templater.r

;stops the framework if a test fails
do %tests.r

root_dir: what-dir

listen_port: open/lines append tcp://: config/port  ; port used for web connections

print rejoin ["^/listening on port " config/port]

; set up the routes
routing/get_routes config/route_files

routing/print_routes

errors: [
    400 "Forbidden" "No permission to access: "
    404 "Not Found" "Controller not found for: "
    500 "Internal server error" "Error: "
]

send-error: function [err-num file] [err] [
    err: find errors err-num
    insert http-port join "HTTP/1.0 " [
        err-num " " err/2 "^/Content-type: text/html^/^/"
        <html> <title> err/2 </title>
        <body><h1> "server-error" </h1><br /><p> "REBOL Webserver Error:" </p>
        <br /> <p> err/3 "  " <b>file</b> newline </p> </body> </html>
    ]
]

send-page: func [data mime] [
    insert data rejoin ["HTTP/1.0 200 OK^/Content-type: " mime "^/^/"]
    write-io http-port data length? data
]

; holds the request information which is printed out as connections are made
buffer: make string! 1024  ; will auto-expand if needed

; processes each HTTP request from a web browser. The first step is to wait for a connection on the listen_port. When a connection is made, the http-port variable is set to the TCP port connection and is then used to get the HTTP request from the browser and send the result back to the browser.
forever [
    print rejoin [newline]
    print "waiting for request"
    http-port: first wait listen_port
    clear buffer
    print "waiting over"

    ; gathers the browser's request, a line at a time. The host name of the client (the browser computer) is added to the buffer string. It is just for your own information. If you want, you could use the remote-ip address instead of the host name.
    while [not empty? http_request: first http-port][
        repend buffer [http_request newline]
    ]
    repend buffer ["Address: " http-port/host newline]
    query_string: copy ""
    relative_path: "index.html"
    mime: "text/plain"
    
    ;  parses the HTTP header and copies the requested relative_path to a variable. This is a very simple method, but it will work fine for simple web server requests.
    parse buffer [
        [
            copy method routing/route_methods_rule
        ]
        [
            "http"
            | "/ "
            | copy relative_path to "?"
              skip copy query_string to " "
            | copy relative_path to " "
        ]
    ]

    parsed_query_parameters: parse_query_string query_string

    request: make request_obj compose/only [
        method: (method)
        url: (relative_path)
        query_parameters: (parsed_query_parameters)
    ]

    print "request is"
    probe request
                 
    route_results: routing/find_route request
    either (none? route_results) [
        send-error 404 relative_path
    ] [
        print append copy "route_results are: " mold route_results  
        route: parse route_results/1 "@"
        
        ; return an error if the controller is invalid
        either (equal? length? route 1) [
            print rejoin ["^"" route "^"" " is an incorrect controller"]
            send-error 500 rejoin ["^"" route "^"" " is an incorrect controller"]
        ] [
        
            route_parameters: route_results/2
            controller_name: append copy route/1 ".r"
            controller_function_name: copy route/2

            print append copy "route is: " mold route  
            print append copy "route_parameters are: " mold route_parameters

            ; execute the wanted function from the controller file
            controller_path: config/controllers_dir/:controller_name
            controller: context load controller_path   

            ; gets the result from calling the controller function
            either (empty? route_parameters) [
                controller_output: controller/(to-word controller_function_name) request
            ] [
                controller_output: controller/(to-word controller_function_name) request route_parameters
            ]

            ; takes the relative_path's suffix and uses it to lookup the MIME type. This is returned to the web browser to tell it what to do with the data. For example, if the file is foo.html, then a text/html MIME type is returned. You can add other MIME types to this list.
            ;parse relative_path [thru "."
            ;                [
            ;                    "html" (mime: "text/html")
            ;                    | "gif"  (mime: "image/gif")
            ;                    | "jpg"  (mime: "image/jpeg")
            ;                ]
            ;           ]
            mime: "text/html"

            ; check that the requested file exists, read the file and send it to the browser using the SEND-PAGE function described earlier. If an error occurs, the SEND-ERROR function is called to send the error back to the browser.
            any [
                ;if not exists? config/public_dir/:relative_path [
                ;    send-error 404 relative_path
                ;]
                if error? try [
                    ;data: read/binary config/public_dir/:relative_path
                    data: copy controller_output
                ] [
                    send-error 400 relative_path
                ]
                send-page data mime
            ]

            ; makes sure that the connection from the browser is closed, now that the requested web data has been returned.
            print "port closed"
        ]
    ]
    close http-port
]
