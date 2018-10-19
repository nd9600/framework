Rebol [
    Title: "Tiny Framework - templater tests with just variables"
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
        template: {<title>First test!</title>}
        variables: make map! reduce []
    
        compiled: templater/compile template variables
        assert [
            compiled == template
        ]
    ]
    
    testCompilingWithOneParameter: funct [] [
        template: {<title>First test with {{parameter}}!</title>}
        variables: make map! reduce [
            'parameter 123
        ]
    
        compiled: templater/compile template variables
        wanted: {<title>First test with 123!</title>}
        assert [
            (compiled) == (wanted)
        ]
    ]
    
    testCompilingWithTwoParameters: funct [] [
        template: {<title>First test with {{ parameter }} - {{ parameter2 }}!</title>}
        variables: make map! reduce [
            'parameter 456
            'parameter2 123
        ]
    
        compiled: templater/compile template variables
        wanted: {<title>First test with 456 - 123!</title>}
        assert [
            (compiled) == (wanted)
        ]
    ]
]
