Rebol [
    Title: "Tiny Framework - response functions"
]

errorCodes: copy [400 401 403 404 405 500 503]
redirectionCodes: copy [300 301 307 308]
successCodes: copy [200 201 202]

errors: [
    400 "Bad request" "Request: "
    403 "Forbidden" "No permission to access: "
    404 "Not found" "File not found: "
    500 "Internal server error" "Error: "
]

sendError: funct [
    response [object!]
] [
    err: find errors response/status
    insert http-port rejoin ["HTTP/1.0 "
        response/status " " err/2 "^/Content-type: text/html^/^/"
        <html> 
        <head>
            <title> err/2 </title>
        </head>
        <body>
            <h1> "Server error" </h1> <br />
            <p> "REBOL Webserver Error:" </p> <br /> 
            <p> err/3 "  " <pre> response/data </pre> </p> 
        </body> 
        </html>
    ]
]

sendRedirection: funct [
    response [object!]
] [
    sendSuccess response
]

sendSuccess: funct [
    response [object!]
] [
    insert response/data rejoin ["HTTP/1.0 " response/status " OK^/Content-type: " response/mime "^/^/"]
    write-io http-port response/data length? response/data
]

sendResponse: funct [
    response [object!]
] [
    case [
        find errorCodes response/status [sendError response]
        find redirectionCodes response/status [sendSuccess response]
        find successCodes response/status [sendSuccess response]
        true [sendError response]
    ]
]

