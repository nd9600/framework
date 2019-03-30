Rebol [
    Title: "Tiny Framework - functional programming functions"
]

;applyF: funct [f x][f x] ;monadic argument only
;applyF: funct [f args][do head insert args 'f]
;applyF: funct [f args][do append copy [f] args]
applyF: funct [f args][do compose [f (args)] ]

lambda: funct [
    "makes lambda functions - https://gist.github.com/draegtun/11b0258377a3b49bfd9dc91c3a1c8c3d"
    block [block!] "the function to make"
    /applyArgs "immediately apply the lambda function to arguments"
        args [any-type!] "the arguments to apply the function to, can be a block!"
] [
    flatten: funct[b][
        flattened: copy []
        while [not tail? b] [
            element: first b
            either block? element [
                append flattened flatten element
            ] [
                append flattened element
            ]
            b: next b
        ]
        flattened
    ]

    spec: make block! 0
    flattenedBlock: flatten block

    parse flattenedBlock [
        any [
            set word word! (
                if (strict-equal? first to-string word #"?") [
                    append spec word
                    ]
                )
            | skip
        ]
    ]

    spec: unique sort spec
    
    if all [
        (length? spec) > 1
        found? find spec '?
    ] [ 
        do make error! {cannot match ? with ?name placeholders}
    ]

    f: funct spec block
    
    either applyArgs [
        argsAsBlock: either block? args [args] [reduce [args]]
        applyF :f argsAsBlock
    ] [
        :f
    ]
]

f_map: funct [
    "The functional map"
    f  [any-function!] "the function to use" 
    block [block!] "the block to reduce"
] [
    result: copy []
    while [not tail? block] [
        replacement: f first block
        append/only result replacement
        block: next block
    ]   
    result
]

f_fold: funct [
    "The functional left fold"
    f  [any-function!] "the function to use" 
    init [any-type!] "the initial value"
    block [block!] "the block to fold"
] [
    result: init
    while [not tail? block] [
        result: f result first block
        block: next block
    ]
    result
]

f_filter: funct [
    "The functional filter"
    condition [function!] "the condition to check, as a lambda function" 
    block [block!] "the block to fold"
] [
    result: copy []
    while [not tail? block] [
        if (condition first block) [
            append result first block
        ]
        block: next block
    ]
    result
]
