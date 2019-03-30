Rebol [
    Title: "Tiny Framework - controller parameter tests"
]

tests: context [

    routing: none

    setUp: func [] [
        routing: context load %base/routing.r
        routesStr1: {
        routes: [
            [
                url "/routeTest" 
                method "GET"
                controller "FirstController@index"
            ]
            [
                url "/routeTest/{parameter}"
                method "GET"
                controller "FirstController@paramTest"
            ]
            [
                url "/routeTest/{p1}/{p2}" 
                method "POST"
                controller "FirstController@paramTest2"
            ]
        ]
        }

        routing/setRoutes reduce [routesStr1]
    ]

    tearDown: func [] [
        routing: none
    ]

    testGettingRouteWithNoParameters: funct [] [
        ; checks route with no parameters
        req1: make request_obj [method: "GET" url: "/routeTest"]
        req1Results: routing/findRoute req1
        assert [
            req1Results/1 == copy "FirstController@index"
            req1Results/2 == copy []
        ]
    ]

    testGettingRouteWithOneParameter: funct [] [
        req2: make request_obj [method: "GET" url: "/routeTest/123"]
        req2Results: routing/findRoute req2
        assert [
            req2Results/1 == "FirstController@paramTest"
            req2Results/2 == ["123"]
        ]
    ]

    testGettingRouteWithTwoParameters: funct [] [
        req3: make request_obj [method: "POST" url: "/routeTest/123/456"]
        req3Results: routing/findRoute req3
        assert [
            req3Results/1 == "FirstController@paramTest2"
            req3Results/2 == ["123" "456"]
        ]
    ]

]