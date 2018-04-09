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
    statusCode [integer!]
    errorDescription
] [
    err: find errors statusCode
    insert http-port rejoin ["HTTP/1.0 "
        statusCode " " err/2 "^/Content-type: text/html^/^/"
        <html> 
        <head>
            <title> err/2 </title>
        </head>
        <body>
            <h1> "Server error" </h1> <br />
            <p> "REBOL Webserver Error:" </p> <br /> 
            <p> err/3 "  " <pre>errorDescription</pre> </p> 
        </body> 
        </html>
    ]
]

sendRedirection: funct [
    statusCode [integer!]
    mime [string!]
    data [binary!]
] [
    sendSuccess statusCode mime data
]

sendSuccess: funct [
    statusCode [integer!]
    mime [string!]
    data [binary!]
] [
    insert data rejoin ["HTTP/1.0 " statusCode " OK^/Content-type: " mime "^/^/"]
    write-io http-port data length? data
]

sendResponse: funct [
    response [object!]
] [
    case [
        find errorCodes response/status [sendError response/status response/data]
        find redirectionCodes response/status [sendSuccess response/status response/mime response/data]
        find successCodes response/status [sendSuccess response/status response/mime response/data]
        true [sendError response/status response/data]
    ]
]

