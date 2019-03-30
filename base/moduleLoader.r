Rebol [
    Title: "Rebol Module loader"
    License: "MIT"
]

import: funct [
    "Imports variables from a block!, file! or string!, without polluting the global scope. Variables can be defined as functions of other, non-exported variables"
    input [block! file! string!] "the thing to import, like [b: 1 c: b + 10 d: [4 5 6] export [d c e] e: c * 12]"
    /only "only import some word!s"
        wordsToImport [block!] "the word!s to import, like [a b]"
] [
    inputAsBlock: case [
        block? input [input]
        any [file? input string? input] [load input]
    ]

    ; find variables to export, and remove [export block!] from the argument
    exportingVariables: copy []
    parse inputAsBlock [
        copy toExport to 'export skip
        copy exportingBlock block! (
            append exportingVariables first exportingBlock
        )
        copy fromExportToEnd to end
    ]
    blockWithoutExport: compose [(toExport) (fromExportToEnd)]
    blockAsObject: context blockWithoutExport

    ; extract the variables from the current scope
    bitThatReturnsVariables: copy []
    
    finalVariablesToExport: either only [
        importAndExportIntersection: intersect exportingVariables wordsToImport
        
        if ((length? importAndExportIntersection) <> (length? wordsToImport)) [
            print rejoin ["import and export lists are different: " difference exportingVariables wordsToImport]
        ]
        importAndExportIntersection
    ] [
        exportingVariables
    ]
           
    foreach variableToExport finalVariablesToExport [
        variableToExportAsLitWord: to-lit-word :variableToExport

        either (not none? find blockAsObject variableToExportAsLitWord) [
            key: to-set-word :variableToExport
            value: get in blockAsObject (variableToExportAsLitWord)
            probe :value
            append bitThatReturnsVariables compose/only [(key) (:value)]
        ] [
            print rejoin [variableToExportAsLitWord " isn't exported in the input " type? input "!"]
        ]
    ]
    context bitThatReturnsVariables
]
