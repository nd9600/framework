Rebol [
    Title: "Tiny Framework - templater comment tests"
]

tests: context [

    templater: none

    setUp: func [] [
        templater: context load %base/templater.r
    ]

    tearDown: func [] [
        templater: none
    ]

    testCompilingWithOnlyComments: funct [] [
        template: {<title>First test{# not shown! #}!</title>}
        variables: make map! reduce []
    
        compiled: templater/compile template variables
        wanted: {<title>First test!</title>}
        assert [
            (compiled) == (wanted)
        ]
    ]
    
    testCompilingWithOneParameterBeforeComment: funct [] [
        template: {<title>First test with {{parameter}}{# not shown! #}!</title>}
        variables: make map! reduce [
            'parameter 123
        ]
    
        compiled: templater/compile template variables
        wanted: {<title>First test with 123!</title>}
        assert [
            (compiled) == (wanted)
        ]
    ]
    
    testCompilingWithOneParameterAfterComment: funct [] [
        template: {<title>First test with {# not shown! #}{{parameter}}!</title>}
        variables: make map! reduce [
            'parameter 123
        ]
    
        compiled: templater/compile template variables
        wanted: {<title>First test with 123!</title>}
        assert [
            (compiled) == (wanted)
        ]
    ]
]
