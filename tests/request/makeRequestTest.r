Rebol [
    Title: "Tiny Framework - request creation tests"
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

    testMakingRequestForGETRequestAndControllerPath: funct [] [
        buffer: copy "GET /routeTest/123 HTTP/1.1"
        request: makeRequest config buffer
        assert [
            request/method == "GET"
            request/url == "/routeTest/123"
        ]
    ]

    testMakingRequestForPOSTRequestAndControllerPath: funct [] [
        buffer: copy "POST /routeTest/123 HTTP/1.1"
        request: makeRequest config buffer
        assert [
            request/method == "POST"
            request/url == "/routeTest/123"
        ]
    ]

    testMakingRequestForGETRequestAndControllerPathAndQueryParameters: funct [] [
        buffer: copy "GET /routeTest/123?a=2&b=asd&c=d1f HTTP/1.1"
        request: makeRequest config buffer
        assert [
            request/method == "GET"
            request/url == "/routeTest/123"
            request/queryParameters == [a "2" b "asd" c "d1f"]
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