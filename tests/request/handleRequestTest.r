Rebol [
    Title: "Tiny Framework - request handling tests"
]

tests: context [

    config: none

    setUp: func [] [
        config: context load {
            publicDir: %tests/needed_data/storage/public/ 
            publicPrefix: "/public/"
            routingDir: %routing/
            controllersDir: %tests/needed_data/controllers
        }
    ]

    tearDown: func [] [
        config: none
    ]

    testHandlingSuccessfulPublicRequest: funct [] [
        routing: context load %base/routing.r
        routing/setRoutes copy []

        request: make request_obj [
            method: "GET"
            url: "/public/t.txt"
        ]
        response: handleRequest config routing request

        ; t.txt contains 123, which is 313233 in hex
        ; the test failed if I just asserted that the response as a whole was right
        assert [
            response/status == 200
            response/mime == "text/plain"
            response/data == #{313233}
        ]
    ]

    testHandling404PublicRequest: funct [] [
        routing: context load %base/routing.r
        routing/setRoutes copy []

        request: make request_obj [
            method: "GET"
            url: "/public/t2.txt"
        ]
        response: handleRequest config routing request
        assert [
            response/status == 404
            response/data == "/public/t2.txt"
        ]
    ]

    testHandlingSuccessfulControllerRequest: funct [] [
        routing: context load %base/routing.r
        routesStr1: {
        routes: [
            [
                url "/routeTest" 
                method "GET"
                controller "FirstController@index"
            ]
        ]
        }
        routing/setRoutes copy reduce [routesStr1]

        request: make request_obj [
            method: "GET"
            url: "/routeTest"
        ]
        response: handleRequest config routing request

        ; FirstController just returns "hello world"
        assert [
            response/status == 200
            response/mime == "text/html"
            response/data == "hello world"
        ]
    ]

    testHandlingControllerRequestForNonexistentController: funct [] [
        routing: context load %base/routing.r
        routing/setRoutes copy []

        request: make request_obj [
            method: "GET"
            url: "/routeTest2"
        ]
        response: handleRequest config routing request
        assert [
            response/status == 404
            response/data == "There were no routes found for: /routeTest2"
        ]
    ]

    testHandlingControllerRequestForIncorrectController: funct [] [
        routing: context load %base/routing.r
        routesStr1: {
        routes: [
            [
                url "/routeTest" 
                method "GET"
                controller "FirstController"
            ]
        ]
        }
        routing/setRoutes copy reduce [routesStr1]

        request: make request_obj [
            method: "GET"
            url: "/routeTest"
        ]
        response: handleRequest config routing request
        assert [
            response/status == 500
            response/data == "FirstController is an invalid controller-method pair"
        ]
    ]
]