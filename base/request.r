Rebol [
    Title: "Tiny Framework - request handlers"
    Documentation: http://www.rebol.net/cookbook/recipes/0057.html
]

request_obj: context [
    method: copy ""
    url: copy ""
    query_parameters: copy []
]

makeBufferFromConnectionPort: funct [
    buffer [string!]
    connectionPort [port!]
] [
    ; gathers the browser's request, a line at a time. The host name of the client (the browser computer) is added to the buffer string. It is just for your own information. If you want, you could use the remote-ip address instead of the host name.
    until [
        line: first connectionPort

        ; rebol's open/lines refinement seems to break with POST bodies, and it thinks the blank line between the HTTP header and body is the end of the request, so we have to manually add in the POST body ourselves, which is on one line, after a blank line after the header
        leftInBuffer: to-string connectionPort/state/inBuffer
        linesLeftInBuffer: to-block parse connectionPort/state/inBuffer "^M"

        ; this might not be needed
        notAtBlankLineBeforeBody: all [
            find leftInBuffer "^/^M"
            (index? find leftInBuffer "^/^M") == 1
        ]
        leftInBufferIsAtPostBody: all [
            notAtBlankLineBeforeBody 
            (length? linesLeftInBuffer) == 1
        ]
        repend buffer [line newline]

        if leftInBufferIsAtPostBody [
            repend buffer [newline first linesLeftInBuffer newline]
            repend buffer ["Address: " connectionPort/host newline]
        ]

        leftInBufferIsAtPostBody
    ]

    buffer
]

makeRequest: funct [
    config [object!]
    buffer [string!]
] [
    query_string: copy ""
    relative_path: append copy config/public_prefix "index.html"

    probe buffer

    ; parses the HTTP header and copies the requested relative_path to a variable
    ; http, / and /public/ are rewritten to /public/index.html
    parse buffer [
        [
            copy method routing/route_methods_rule
        ]
        [
            "http"
            | "/ "
            | config/public_prefix "HTTP"
            | copy relative_path to "?"
              skip copy query_string to " "
            | copy relative_path to " "
        ]
    ]

    parsed_query_parameters: parse_query_string query_string

    make request_obj compose/only [
        method: (method)
        url: (relative_path)
        query_parameters: (parsed_query_parameters)
    ]
]

handleRequest: funct [
    config [object!]
    routing [object!]
    request [object!]
] [
    either startsWith request/url config/public_prefix [
        handlePublicRequest config request
    ] [
        handleControllerRequest config routing request
    ]
]

handlePublicRequest: funct [
    config [object!]
    request [object!]
] [
    ; the url has the public_prefix at the start
    relative_path: find/tail request/url config/public_prefix

    ; check that the requested file exists, read the file and send it to the browser
    any [
        if not exists? config/public_dir/:relative_path [
            return make response_obj compose [
                status: 404
                data: (request/url)
            ]
        ]
        if error? try [
            mime: getMimeType relative_path
            data: read/binary config/public_dir/:relative_path

            return make response_obj compose [
                status: 200 
                mime: (mime)
                data: (data)
            ]
        ] [
            return make response_obj compose [
                status: 400 
                data: (request/url)
            ]
        ]
    ]
]

handleControllerRequest: funct [
    config [object!]
    routing [object!]
    request [object!]
] [
    route_results: routing/find_route request
    either (none? route_results) [
        return make response_obj compose [
            status: 404
            data: (reform ["There were no routes found for:" request/url])
        ]
    ] [
        ;print append copy "route_results are: " mold route_results  
        route: parse route_results/1 "@"

        ; return an error if the controller is invalid
        either (equal? length? route 1) [
            error_message: copy reform [route "is an invalid controller-method pair"]
            return make response_obj compose [
                status: 500 
                data: (error_message)
            ]
        ] [        
            route_parameters: route_results/2
            controller_name: rejoin [route/1 ".r"]
            controller_function_name: copy route/2
            controller_function: to-word controller_function_name

            ;print rejoin ["route: " mold route  ]
            ;print rejoin ["route_parameters: " mold route_parameters]

            ; execute the wanted function from the controller file
            controller_path: config/controllers_dir/:controller_name
            controller: context load controller_path

            wordsInController: words-of controller
            controllerFunctionNameAsLitWord: to-lit-word controller_function_name
            controllerDoesntHaveFunction: none? find wordsInController controllerFunctionNameAsLitWord

            if controllerDoesntHaveFunction [
                error_message: copy reform [controller_path "doesn't have a function called" controller_function_name]
                return make response_obj compose [
                    status: 500
                    mime: "text/html"
                    data: (error_message)
                ]
            ]

            ; gets the result from calling the controller function
            controller_output: either (empty? route_parameters) [
                controller/(controller_function) request
            ] [
                controller/(controller_function) request route_parameters
            ]

            mime: "text/html"

            ; send the controller output in a 200 response
            data: copy controller_output

            return make response_obj compose [
                status: 200 
                mime: (mime)
                data: (data)
            ]
        ]
    ]
]

getMimeType: funct [
    relative_path [string!]
] [
    mime: "text/plain"
    parse relative_path [
        thru "."
        [
            "html" (mime: "text/html")
            | "css" (mime: "text/css")
            | "js" (mime: "text/javascript")
            | "gif"  (mime: "image/gif")
            | "jpg"  (mime: "image/jpeg")
        ]
    ]
    mime
]