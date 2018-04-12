Rebol [
    Title: "Tiny Framework - controller parameter tests"
    Documentation: http://www.rebol.net/cookbook/recipes/0057.html
]

testGettingRouteWithNoParameters: funct [] [
    routes_str1: {
    routes: [
        [
            url "/route_test" 
            method "GET"
            controller "FirstController@index"
        ]
        [
            url "/route_test/{parameter}"
            method "GET"
            controller "FirstController@param_test"
        ]
        [
            url "/route_test/{p1}/{p2}" 
            method "POST"
            controller "FirstController@param_test2"
        ]
    ]
    }

    routing/get_routes config reduce [routes_str1]

    ; checks route with no parameters
    req1: make request_obj [method: "GET" url: "/route_test"]
    req1_results: routing/find_route req1
    assert [
        req1_results/1 == copy "FirstController@index"
        req1_results/2 == copy []
    ]
]

testGettingRouteWithOneParameter: funct [] [
    req2: make request_obj [method: "GET" url: "/route_test/123"]
    req2_results: routing/find_route req2
    assert [
        req2_results/1 == "FirstController@param_test"
        req2_results/2 == ["123"]
    ]
]

testGettingRouteWithTwoParameters: funct [] [
    req3: make request_obj [method: "POST" url: "/route_test/123/456"]
    req3_results: routing/find_route req3
    assert [
        req3_results/1 == "FirstController@param_test2"
        req3_results/2 == ["123" "456"]
    ]
]