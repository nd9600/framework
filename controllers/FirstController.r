Rebol [
    Title: "Tiny Framework: First controller"
]

index: func [
    request [object!]
] ["hello world"]

param_test: func [
    request [object!]
    parameters [block!]
] [
    template: templater/t_load "first.twig.html"
    variables: make map! reduce [
        'parameter parameters/1
        ;'parameter request/query_parameters/a
    ]
    
    return templater/compile template variables
]