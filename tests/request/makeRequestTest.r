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
        assert [true]
    ]
]