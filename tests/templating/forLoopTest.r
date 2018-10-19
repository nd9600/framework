Rebol [
    Title: "Tiny Framework - templater for loop tests"
]

tests: context [

    templater: none

    setUp: func [] [
        templater: context load %base/templater.r
    ]

    tearDown: func [] [
        templater: none
    ]

    testCompilingWithNoParameters: funct [] [
        template: {{% for i in block %} abc {% endfor %}}
        variables: make map! reduce ['block [1 2 3 4]]
    
        compiled: templater/compile template variables
        wanted: " abc  abc  abc  abc "
        assert [
            compiled == wanted
        ]
    ]
    
    testCompilingWithParameterInsertion: funct [] [
        template: {{% for i in block %} {{ i }} {% endfor %}}
        variables: make map! reduce ['block [1 2 3 4]]
    
        compiled: templater/compile template variables
        wanted: " 1  2  3  4 "
        assert [
            (compiled) == (wanted)
        ]
    ]
]
