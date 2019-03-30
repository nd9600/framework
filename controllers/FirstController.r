Rebol [
    Title: "Tiny Framework: First controller"
]

index: func [
    request [object!]
] ["hello world"]

paramTest: func [
    request [object!]
    parameters [block!]
] [
    template: templater/t_load "first.twig.html"
    variables: make map! reduce [
        'parameter parameters/1
        ;'parameter request/queryParameters/a
    ]
    
    return templater/compile template variables
]