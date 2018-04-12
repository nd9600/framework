Rebol [
    Title: "Tiny Framework - request handlers"
    Documentation: http://www.rebol.net/cookbook/recipes/0057.html
]

request_obj: context [
    method: copy ""
    url: copy ""
    query_parameters: copy []
]

makeRequest: funct [
    config [object!]
    buffer [string!]
] [
    query_string: copy ""
    relative_path: append copy config/public_prefix "index.html"

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
            ;print error_message
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

            ; gets the result from calling the controller function
            either (empty? route_parameters) [
                controller_output: controller/(controller_function) request
            ] [
                controller_output: controller/(controller_function) request route_parameters
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