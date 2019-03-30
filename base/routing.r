Rebol [
    Title: "Tiny Framework - routing"
]

; used to check if the HTTP request uses an acceptable method
acceptedRouteMethods: copy ["ANY" "GET" "POST" "HEAD" "PUT" "DELETE" "CONNECT" "OPTIONS" "TRACE" "PATCH"]

; needed to parse the HTTP request
routeMethodsRule: copy ["GET" | "POST" | "HEAD" | "PUT" | "DELETE" | "CONNECT" | "OPTIONS" | "TRACE" | "PATCH"]

routes: copy []
unconvertedRoutes: copy []

printRoutes: funct [
] [
    print "^/##########^/routes:"
    foreach method acceptedRouteMethods [
        if (length? routesForMethod: select unconvertedRoutes method) > 0 [
            print method
            forskip routesForMethod 2 [
                print rejoin [tab mold first routesForMethod ": " first next routesForMethod]
            ]
        ]
    ]
    print "##########"
]

getRoutes: func [
    "gets the app's routes"
    routeFilesToLoad [block!] "the routes to load, containing files or strings"
    /local tempRoutes
] [
    ; 'routes is a series like ["ANY" [] "GET" [] "POST" []] after this
    tempRoutes: copy/deep acceptedRouteMethods
    loop length? tempRoutes [tempRoutes: insert/only next tempRoutes copy []]
    routes: copy []
    routes: head tempRoutes
    unconvertedRoutes: copy/deep routes

    ; loads the data for each routing file
    loadedRouteFiles: f_map lambda [context load ?] routeFilesToLoad

    ; loops through every routing file
    foreach routeFile loadedRouteFiles [
        ; if add the content of 'routes to the routes hashmap
        routesFromThisFile: routeFile/routes

        foreach actualRoute routesFromThisFile [

            ; if the routeMethod is ANY, GET or POST, add it to the appropriate series
            ; otherwise, add it to the GET series
            routeMethod: select actualRoute 'method
            if (not find acceptedRouteMethods routeMethod) [
                routeMethod: "GET"
            ]
            routeUrl: select actualRoute 'url
            routeRule: convertRuleToParseRule routeUrl
            routeController: select actualRoute 'controller
            
            ; adds the route to the appropriate block in 'routes
            routesForMethod: select routes routeMethod
            append routesForMethod reduce [routeRule routeController]

            unconvertedRoutesForMethod: select unconvertedRoutes routeMethod
            append unconvertedRoutesForMethod reduce [routeUrl routeController]
        ]
    ]

    ;speeds up finding routes, but the initial creation is slower
    ;routes: to-map routes
]

findRoute: funct [
    "gets the route controller for a route URL, checked against the routes for all HTTP methods"
    request [object!] "the request object"
] [
    routeMethod: request/method
    requestUrl: request/url
    
    ; first checks against "ANY" routes, then the specific route method
    ANYMethodsRoutes: select routes "ANY"
    routeControllerResults: getRouteController ANYMethodsRoutes requestUrl
    
    ; if no match in the ANY routes, try and match in the actual method;s routes
    if (not routeControllerResults) [
        routesForActualMethod: select routes routeMethod
        routeControllerResults: getRouteController routesForActualMethod requestUrl
    ]
    return routeControllerResults
]

getRouteController: funct [
    "gets the route controller for a route URL, checked against the routes for a specific HTTP method"
    routes [series!] "the routes to check against"
    url [string!] "the URL to check"
] [
    forskip routes 2 [
        route: first routes
        ; collect returns a block of parameters, parse returns whether a match was found
        parameters: collect compose/only [ ; composes so that keep is defined here
            matches: parse url (route)
        ]
        if matches [
            routeController: first next routes
            return reduce [routeController parameters]
        ]
    ]
    return none
]

convertRuleToParseRule: funct [
    "converts a rule of the form abcdef/{}/123{} to Redbol's PARSE rule"
    ruleAsString [string!]
] [
    convertedRule: copy []
    conversionRules: [

        ; handles parameters
        any [
            copy matchUntilParameter to "{"
            thru "}" 
            [
                ; if the parameter was at the end of the rule
                end ( 
                    append convertedRule compose [ 
                        (matchUntilParameter) 
                        copy parameter to end (to-paren [keep parameter]) 
                    ]
                  )

                ; if the parameter wasn't at the end of the rule
                | copy charAfterParameter skip (
                    append convertedRule compose [
                        (matchUntilParameter)
                        copy parameter to (charAfterParameter) skip (to-paren [keep parameter])
                    ]
                  ) 
            ]
        ]

        ; used if/when there aren't any parameters
        [
            end 
            | copy matchUntilEnd to end (append convertedRule matchUntilEnd)
        ]
    ]
    parse ruleAsString conversionRules
    convertedRule
]