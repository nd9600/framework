Rebol [
    Title: "Tiny Framework - routing"
]

; used to check if the HTTP request uses an acceptable method
accepted_route_methods: copy ["ANY" "GET" "POST" "HEAD" "PUT" "DELETE" "CONNECT" "OPTIONS" "TRACE" "PATCH"]

; needed to parse the HTTP request
route_methods_rule: copy ["GET" | "POST" | "HEAD" | "PUT" | "DELETE" | "CONNECT" | "OPTIONS" | "TRACE" | "PATCH"]

routes: copy []
unconverted_routes: copy []

print_routes: funct [
] [
    print "^/##########^/routes:"
    foreach method accepted_route_methods [
        if (length? routes_for_method: select unconverted_routes method) > 0 [
            print method
            forskip routes_for_method 2 [
                print rejoin [tab mold first routes_for_method ": " first next routes_for_method]
            ]
        ]
    ]
    print "##########"
]

get_routes: func [
    "gets the app's routes"
    route_files_to_load [block!] "the routes to load, containing files or strings"
    /local tempRoutes
] [
    ; 'routes is a series like ["ANY" [] "GET" [] "POST" []] after this
    tempRoutes: copy/deep accepted_route_methods
    loop length? tempRoutes [tempRoutes: insert/only next tempRoutes copy []]
    routes: copy []
    routes: head tempRoutes
    unconverted_routes: copy/deep routes

    ; loads the data for each routing file
    loaded_route_files: f_map lambda [context load ?] route_files_to_load

    ; loops through every routing file
    foreach route_file loaded_route_files [
        ; if add the content of 'routes to the routes hashmap
        routes_from_this_file: route_file/routes

        foreach actual_route routes_from_this_file [

            ; if the route_method is ANY, GET or POST, add it to the appropriate series
            ; otherwise, add it to the GET series
            route_method: select actual_route 'method
            if (not find accepted_route_methods route_method) [
                route_method: "GET"
            ]
            route_url: select actual_route 'url
            route_rule: convert_rule_to_parse_rule route_url
            route_controller: select actual_route 'controller
            
            ; adds the route to the appropriate block in 'routes
            routes_for_method: select routes route_method
            append routes_for_method reduce [route_rule route_controller]

            unconverted_routes_for_method: select unconverted_routes route_method
            append unconverted_routes_for_method reduce [route_url route_controller]
        ]
    ]

    ;speeds up finding routes, but the initial creation is slower
    ;routes: to-map routes
]

find_route: funct [
    "gets the route controller for a route URL, checked against the routes for all HTTP methods"
    request [object!] "the request object"
] [
    route_method: request/method
    request_url: request/url
    
    ; first checks against "ANY" routes, then the specific route method
    ANY_methods_routes: select routes "ANY"
    route_controller_results: get_route_controller ANY_methods_routes request_url
    
    ; if no match in the ANY routes, try and match in the actual method;s routes
    if (not route_controller_results) [
        routes_for_actual_method: select routes route_method
        route_controller_results: get_route_controller routes_for_actual_method request_url
    ]
    return route_controller_results
]

get_route_controller: funct [
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
            route_controller: first next routes
            return reduce [route_controller parameters]
        ]
    ]
    return none
]

convert_rule_to_parse_rule: funct [
    "converts a rule of the form abcdef/{}/123{} to Redbol's PARSE rule"
    rule_as_string [string!]
] [
    converted_rule: copy []
    conversion_rules: [

        ; handles parameters
        any [
            copy match_until_parameter to "{" (append converted_rule match_until_parameter)
            thru "}" 
            [
                ; if the parameter was at the end of the rule
                end ( 
                    append converted_rule compose [ copy parameter to end (to-paren [keep parameter]) ]
                  )

                ; if the parameter wasn't at the end of the rule
                | copy char_after_parameter skip (
                    append converted_rule compose [
                        copy parameter to (char_after_parameter) skip (to-paren [keep parameter])
                    ]
                  ) 
            ]
        ]

        ; used if/when there aren't any parameters
        [
            end 
            | copy match_until_end to end (append converted_rule match_until_end)
        ]
    ]
    parse rule_as_string conversion_rules
    converted_rule
]