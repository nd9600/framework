Rebol [
    Title: "Tiny Framework - helper functions"
]

parse_query_string: funct [
    "Parses a string string, returning a map"
    query_string [string!]
] [
    pairs: parse query_string "&"

    ; puts the values in a block, so they don't conflict with the keys
    parameters: f_map lambda [
        b: parse ? "="
        compose/deep/only [(to-word b/1) [(b/2)]]
    ] pairs
    ;to-hash parameters ; makes many accesses of a large block faster
]

block_to_string: funct [
    b [block!]
] [
    rejoin [f_map lambda [append to-string ? "^/"] b]
]

object_to_string: funct [
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