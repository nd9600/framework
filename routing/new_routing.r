Rebol [
    Title: "Tiny Framework - routing"
]

routing: make object! [

    ; used to check if the HTTP request uses an acceptable method
    accepted_route_methods: copy ["ANY" "GET" "POST" "HEAD" "PUT" "DELETE" "CONNECT" "OPTIONS" "TRACE" "PATCH"]
    
    ; needed to parse the HTTP request
    route_methods_rule: copy ["GET" | "POST" | "HEAD" | "PUT" | "DELETE" | "CONNECT" | "OPTIONS" | "TRACE" | "PATCH"]
    
    routes: copy []

    print_routes: funct [
    ] [
        print "^/##########^/routes:"
        foreach method accepted_route_methods [
            if (length? routes_for_method: select routes method) > 0 [
                print method
                forskip routes_for_method 2 [
                    print rejoin [tab mold first routes_for_method ": " first next routes_for_method]
                ]
            ]
        ]
        prin "##########"
    ]

    get_routes: func [
        "gets the app's routes"
        routes_to_load [block!] "the routes to load, containing files or strings"
        /local current-dir temp_routes
    ] [
        ;changes to the directory where routes are defined first, then changes back after finding the route
        current-dir: system/options/path
        change-dir config/routing_dir

        ; 'routes is a series like ["ANY" [] "GET" [] "POST" []]
        temp_routes: copy/deep accepted_route_methods
        loop length? temp_routes [temp_routes: insert/only next temp_routes copy []]
        routes: head temp_routes

        ; loads the data for each routing file
        routes_to_load: f_map :load routes_to_load

        ; loops through every routing file
        forall routes_to_load [
            ; if the current variable is called routes, add its content to the routes hashmap
            if (equal? first routes_to_load 'routes) [
                routes_from_this_file: first next routes_to_load
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
                ]
            ]
        ]

        ;speeds up finding routes, but the initial creation is slower
        ;routes: to-map routes

        change-dir current-dir
    ]

    find_route: funct [
        "gets the route controller for a route URL, checked against the routes for all HTTP methods"
        request [object!] "the request object"
    ] [
        route_method: request/method
        request_url: request/url

        if (not find accepted_route_methods route_method) [
            print rejoin [route_method " is not an accepted route method. Only " accepted_route_methods " are accepted"]
            return none
        ]
        if (empty? routes) [
            print "'routes is empty"
            return none
        ]
        
        ; first checks against "ANY" routes, then the specific route method
        routes_for_method: select routes "ANY"
        route_controller_results: get_route_controller routes_for_method request_url
        
        ; if no match in the ANY routes, try and match in the actual method;s routes
        if (not route_controller_results) [
            routes_for_method: select routes route_method
            route_controller_results: get_route_controller routes_for_method request_url
        ]
        return route_controller_results
    ]

    get_route_controller: funct [
        "gets the route controller for a route URL, checked against the routes for a specific HTTP method"
        routes_for_method [series!] "the routes to check against"
        url_to_check [string!] "the URL to check"
    ] [
        forskip routes_for_method 2 [
            route: first routes_for_method
            set [matches parameters] check_if_url_matches_rule url_to_check route
            if matches [
                route_controller: first next routes_for_method
                return reduce [route_controller parameters]
            ]
        ]
        return none
    ]

    check_if_url_matches_rule: funct [
        url [string!]
        converted_rule [block!]
    ] [
        parameters: collect compose/only [
            matches: parse url (converted_rule)
        ]
        reduce [matches parameters]
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
                        append converted_rule compose [
                            copy parameter_data to end (to-paren [keep parameter_data])
                        ]
                        )
                |
                    ; if the parameter wasn't at the end of the rule
                    copy match_until_after_parameter skip (
                        append converted_rule compose [
                            copy parameter_data to (match_until_after_parameter) skip (to-paren [keep parameter_data])
                        ]
                        ) 
                ]
            ]

            ; used if/when there aren't any parameters
            copy match_until_end to end (append converted_rule match_until_end)
        ]
        parse rule_as_string conversion_rules
        converted_rule
    ]
]