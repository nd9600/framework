Rebol [
    Title: "Tiny Framework - request handling tests"
]

tests: context [

    config: none

    setUp: func [] [
        config: context load {
            public_dir: %tests/needed_data/storage/public/ 
            public_prefix: "/public/"
            routing_dir: %routing/
            controllers_dir: %tests/needed_data/controllers
        }
    ]

    tearDown: func [] [
        config: none
    ]

    testHandlingSuccessfulPublicRequest: funct [] [
        routing: context load %base/routing.r
        routing/get_routes copy []

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
        routing/get_routes copy []

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
        routes_str1: {
        routes: [
            [
                url "/route_test" 
                method "GET"
                controller "FirstController@index"
            ]
        ]
        }
        routing/get_routes copy reduce [routes_str1]

        request: make request_obj [
            method: "GET"
            url: "/route_test"
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
        routing/get_routes copy []

        request: make request_obj [
            method: "GET"
            url: "/route_test2"
        ]
        response: handleRequest config routing request
        assert [
            response/status == 404
            response/data == "There were no routes found for: /route_test2"
        ]
    ]

    testHandlingControllerRequestForIncorrectController: funct [] [
        routing: context load %base/routing.r
        routes_str1: {
        routes: [
            [
                url "/route_test" 
                method "GET"
                controller "FirstController"
            ]
        ]
        }
        routing/get_routes copy reduce [routes_str1]

        request: make request_obj [
            method: "GET"
            url: "/route_test"
        ]
        response: handleRequest config routing request
        assert [
            response/status == 500
            response/data == "FirstController is an invalid controller-method pair"
        ]
    ]
]