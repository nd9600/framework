Rebol [
    Title: "Tiny Framework - request creation tests"
]

tests: context [

    config: none

    setUp: func [] [
        config: context load {
            public_dir: %tests/storage/public/ 
            public_prefix: "/public/"
        }
    ]

    tearDown: func [] [
        config: none
    ]

    testGettingController: funct [] [
        req1: make request_obj [method: "GET" url: "/route_test"]
        req1_results: routing/find_route req1
        assert [
            req1_results/1 == copy "FirstController@index"
            req1_results/2 == copy []
        ]
    ]
]