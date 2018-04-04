Rebol [
    Title: "Tiny Framework - functional programming functions"
]

;apply: function [f x][f x] ;monadic argument only
;apply: function [f args][do head insert args 'f]
;apply: function [f args][do append copy [f] args]
;apply: function [f args][do compose [f (args)] ]

lambda: func [
    "makes lambda functions - https://gist.github.com/draegtun/11b0258377a3b49bfd9dc91c3a1c8c3d"
    block [block!] "the function to make"
] [
    spec: make block! 0

    parse block [
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

    func spec block
]

f_map: func [
    "The functional map"
    f  [any-function!] "the function to use" 
    block [block!] "the block to reduce"
] [
    result: copy block
    while [not tail? result] [
        replacement: f first result
        result: change/part result replacement 1
    ]   
    head result
]

f_fold: func [
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

f_filter: func [
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
