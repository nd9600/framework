Rebol [
    Title: "Tiny Framework - request handlers"
    Documentation: http://www.rebol.net/cookbook/recipes/0057.html
]

request_obj: context [
    method: copy ""
    url: copy ""
    queryParameters: copy []
]

makeBufferFromConnectionPort: funct [
    buffer [string!]
    connectionPort [port!]
] [
    ; gathers the browser's request, a line at a time. The host name of the client (the browser computer) is added to the buffer string. It is just for your own information. If you want, you could use the remote-ip address instead of the host name.

    line: first connectionPort
    repend buffer [line newline]

    httpMethod: first parse line " "
    httpMethodIsGET: httpMethod == "GET"

    either httpMethodIsGET [
        while [not empty? line: first connectionPort][
            repend buffer [line newline]
        ]
    ] [
        until [
            line: first connectionPort
            repend buffer [line newline]
            
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

            if leftInBufferIsAtPostBody [
                repend buffer [newline first linesLeftInBuffer newline]
            ]

            leftInBufferIsAtPostBody
        ]
    ]

    repend buffer ["Address: " connectionPort/host newline]
    buffer
]

makeRequest: funct [
    config [object!]
    buffer [string!]
] [
    queryString: copy ""
    relativePath: append copy config/publicPrefix "index.html"

    ?? buffer

    ; parses the HTTP header and copies the requested relativePath to a variable
    ; http, / and /public/ are rewritten to /public/index.html
    parse buffer [
        copy method routing/routeMethodsRule
        [
            "http"
            |   "/ "
            |   config/publicPrefix "HTTP"
            |   [
                    copy relativePath to "?"
                    skip copy queryString to " "
                ]
            |   copy relativePath to " "
        ]
    ]

    parsedQueryParameters: parseQueryString queryString

    make request_obj compose/only [
        method: (method)
        url: (relativePath)
        queryParameters: (parsedQueryParameters)
    ]
]

handleRequest: funct [
    config [object!]
    routing [object!]
    request [object!]
] [
    either startsWith request/url config/publicPrefix [
        handlePublicRequest config request
    ] [
        handleControllerRequest config routing request
    ]
]

handlePublicRequest: funct [
    config [object!]
    request [object!]
] [
    ; the url has the publicPrefix at the start
    relativePath: find/tail request/url config/publicPrefix

    ; check that the requested file exists, read the file and send it to the browser
    any [
        if not exists? config/publicDir/:relativePath [
            return make response_obj compose [
                status: 404
                data: (request/url)
            ]
        ]
        if error? try [
            mime: getMimeType relativePath
            data: read/binary config/publicDir/:relativePath

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
    routeResults: routing/findRoute request
    either (none? routeResults) [
        return make response_obj compose [
            status: 404
            data: (reform ["There were no routes found for:" request/url])
        ]
    ] [
        ;print append copy "routeResults are: " mold routeResults  
        route: parse routeResults/1 "@"

        ; return an error if the controller is invalid
        either (equal? length? route 1) [
            errorMessage: copy reform [route "is an invalid controller-method pair"]
            return make response_obj compose [
                status: 500 
                data: (errorMessage)
            ]
        ] [        
            routeParameters: routeResults/2
            controller_name: rejoin [route/1 ".r"]
            controllerFunction_name: copy route/2
            controllerFunction: to-word controllerFunction_name

            ;print rejoin ["route: " mold route  ]
            ;print rejoin ["routeParameters: " mold routeParameters]

            ; execute the wanted function from the controller file
            controllerPath: config/controllersDir/:controller_name
            controller: context load controllerPath

            wordsInController: words-of controller
            controllerFunctionNameAsLitWord: to-lit-word controllerFunction_name
            controllerDoesntHaveFunction: none? find wordsInController controllerFunctionNameAsLitWord

            if controllerDoesntHaveFunction [
                errorMessage: copy reform [controllerPath "doesn't have a function called" controllerFunction_name]
                return make response_obj compose [
                    status: 500
                    mime: "text/html"
                    data: (errorMessage)
                ]
            ]

            ; gets the result from calling the controller function
            controller_output: either (empty? routeParameters) [
                controller/(controllerFunction) request
            ] [
                controller/(controllerFunction) request routeParameters
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
    relativePath [string!]
] [
    mime: "text/plain"
    parse relativePath [
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