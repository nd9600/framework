Rebol [
    Title: "Tiny Framework - request creation tests"
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

    testMakingRequestForGETRequestAndControllerPath: funct [] [
        buffer: copy "GET /route_test/123 HTTP/1.1"
        request: makeRequest config buffer
        assert [
            request/method == "GET"
            request/url == "/route_test/123"
        ]
    ]

    testMakingRequestForPOSTRequestAndControllerPath: funct [] [
        buffer: copy "POST /route_test/123 HTTP/1.1"
        request: makeRequest config buffer
        assert [
            request/method == "POST"
            request/url == "/route_test/123"
        ]
    ]

    testMakingRequestForGETRequestAndControllerPathAndQueryParameters: funct [] [
        buffer: copy "GET /route_test/123?a=2&b=asd&c=d1f HTTP/1.1"
        request: makeRequest config buffer
        assert [
            request/method == "GET"
            request/url == "/route_test/123"
            request/query_parameters == [a "2" b "asd" c "d1f"]
        ]
    ]

    testMakingRequestForGETRequestAndPublicPath: funct [] [
        buffer: copy "GET /public/t.txt HTTP/1.1"
        request: makeRequest config buffer
        assert [
            request/method == "GET"
            request/url == "/public/t.txt"
        ]
    ]

    testRequestsWithOnlyPublicPrefixAreWrittenToIndexFile: funct [] [
        buffer: copy "GET /public/ HTTP/1.1"
        request: makeRequest config buffer
        assert [
            request/method == "GET"
            request/url == "/public/index.html"
        ]
    ]

    testGettingMimeType: funct [] [
        assert [
            (getMimeType "/public/t.txt") == "text/plain"
            (getMimeType "/public/t.html") == "text/html"
            (getMimeType "/public/t.css") == "text/css"
            (getMimeType "/public/t.js") == "text/javascript"
        ]
    ]
]