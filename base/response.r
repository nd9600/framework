Rebol [
    Title: "Tiny Framework - response functions"
]

response_obj: context [
    status: 200,
    mime: copy ""
    data: copy ""
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
    port [port!]
] [
    err: find errors response/status
    errorResponse: rejoin ["HTTP/1.0 "
        response/status " " err/2 "^/Content-type: text/html^/^/"
        <html> 
        <head>
            <title> err/2 </title>
            <link rel="stylesheet" href="https://unpkg.com/sakura.css/css/sakura.css" type="text/css">
        </head>
        <body>
            <h1> "Server error" </h1> <br />
            <p> "REBOL Webserver Error:" </p> <br /> 
            <p> err/3 "  " <pre> response/data </pre> </p> 
        </body> 
        </html>
    ]
    if found? port [insert port errorResponse]
    errorResponse
]

sendRedirection: funct [
    response [object!]
    port [port!]
] [
    sendSuccess response port
]

sendSuccess: funct [
    response [object!]
    port [port!]
] [
    insert response/data rejoin ["HTTP/1.0 " response/status " OK^/Content-type: " response/mime "^/^/"]
    if found? port [write-io port response/data length? response/data]
    response/data
]

sendResponse: funct [
    response [object!]
    port [port!]
] [
    case [
        find errorCodes response/status [sendError response port]
        find redirectionCodes response/status [sendSuccess response port]
        find successCodes response/status [sendSuccess response port]
        true [sendError response port]
    ]
]

