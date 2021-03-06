Rebol [
    Title: "Tiny Framework - helper functions"
]

contains?: funct [
    "returns if 's contains 'e"
    s [series!] "the series to search in"
    e [any-type!] "the element to search for"
] [
    not none? find s e
]

startsWith: funct [
    "returns whether 'series starts with 'value"
    series [series!]
    value [any-type!]
] [
    match: find series value
    either all [found? match head? match] [true] [false]
]

endsWith: funct [
    "returns whether 'series ends with 'value"
    series [series!]
    value [any-type!]
] [
    match: find/tail series value
    either all [found? match tail? match] [true] [false]
]

flatten: funct[
    b [block!]
] [
    "flattens a block"
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

parseQueryString: funct [
    "Parses a string string, returning a map"
    queryString [string!]
] [
    pairs: parse queryString "&"

    ; puts the values in a block, so they don't conflict with the keys
    parameters: f_map lambda [
        paramPair: parse ? "="
        compose [(to-word paramPair/1) (paramPair/2)]
    ] pairs
    flatten parameters
    ;to-hash parameters ; makes many accesses of a large block faster
]

blockToString: funct [
    b [block!]
] [
    rejoin [f_map lambda [append to-string ? "^/"] b]
]

sepJoin: funct [
    "Returns a reduced block of values as a string, separated by a separator"
    block [block!]
    sep [string! char!]
] [
    rejoin compose/only flatten 
        f_map lambda [reduce [? copy (sep)]] block
]

objectToString: funct [
    obj [object!]
] [
    words: words-of obj
    values: values-of obj
    str: copy ""
    repeat i length? words [
        append str rejoin [words/(i) ": " values/(i) "^/"]
    ]
    str
]

errorToString: funct [
    "adds the actual error string to the error so you can read it easily"
    error [object!]
] [
    errorIDBlock: get error/id
    arg1: to-string error/arg1
    arg2: to-string error/arg2
    arg3: to-string error/arg3
    usefulError: bind to-block errorIDBlock 'arg1

    ; adds a space in between each thing
    usefulErrorString: reform reduce usefulError

    fieldsWeWant: context [
        near: error/near
        where: error/where
    ]

    rejoin [usefulErrorString newline form errorIDBlock newline newline objectToString fieldsWeWant]
]

findFiles: funct [
    "find files in a directory (including sub-directories), optionally matching against a condition"
    dir [file!]
    /matching "only find files that match a condition"
    condition [any-function!] "the condition files must match"
] [
    fileList: copy []
    files: sort load dir

    ; get files in this directory
    foreach file files [

        ; so we don't add directories by accident
        if not find file "/" [
            either matching [
                if condition file [append fileList dir/:file]
            ] [
                append fileList dir/:file
            ]
        ]
    ]

    ; get files in sub-directories
    foreach file files [
        if find file "/" [

            ; we have to pass the refinement into the recursive calls too
            either matching [
                append fileList findFiles/matching dir/:file :condition
            ] [
                append fileList findFiles dir/:file
            ]
        ]
    ]
    fileList
]