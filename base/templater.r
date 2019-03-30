Rebol [
    Title: "Tiny Framework - templater"
]

tLoad: funct [
    templateName ["string!"] "the template.path"
] [
    read config/templatesDir/:templateName
]

compile: funct [
    inputString    [string!]   "the input to compile"
    variables       [map!]    "the variables to use to compile the input string"
] [        
    whitespace:     [#" " | tab | newline]
    digit:          charset "0123456789"
    letter:         charset [#"A" - #"Z" #"a" - #"z" ]
    otherChar:     charset ["_" "-" "/"]
    alphanum:       union letter digit
    anyCharacter:  complement make bitset! []
    
    ; a variable name must start with a letter and can be followed by a series of letters, digits or underscores or dashes
    variable: [letter any [alphanum | otherChar]]
    
    ; copy any character into the output
    anything: [copy data anyCharacter (append output data)]
    
    ; copy escaped left braces nto the output
    escapedLeftBraces: [copy data "\{{" (append output data)]
    
    ; copy the value of a variable into the output, or "none" if the variable doesn't exist
    templateVariable: [
        "{{" any whitespace copy data variable any whitespace "}}"
        (
            variablePath: append copy "variables/" data
            
            ; we have to bind actualVariablePath to this context or 'variables isn't defined for some reason
            actualVariablePath: load/all variablePath
            actualVariable: do bind actualVariablePath 'variables
             
            either (block? actualVariable) [
                append output mold actualVariable
            ] [
                append output actualVariable
            ]
        )
    ]
    
    escapedLeftBraceAndPercent: [copy data "\{%" (append output data)]
    
    ; compile "{% for i in block %} {{ i }} {% endfor %}" make map! reduce ['block [1 2 3 4]]
    forLoop: [
        "{%" any whitespace "for" 
            some whitespace copy iteratorIndex variable
            some whitespace "in" 
            some whitespace copy thingToIterateOver variable
        any whitespace "%}"
            copy stringToCompileRepeatedly to 
        "{%" "{%" any whitespace "endfor" any whitespace "%}"
        (
            iteratorIndexAsVariable: to-word iteratorIndex
            
            thingToIterateOver: to-word thingToIterateOver
            actualThingToIterateOver: select variables thingToIterateOver
            
            foreach i actualThingToIterateOver [
                thisIterationsVariables: copy variables
                append thisIterationsVariables reduce [:iteratorIndexAsVariable :i]
                append output (compile stringToCompileRepeatedly thisIterationsVariables)
            ]
        )
    ]
    
    ;'comment is already defined in rebol
    commentRule: [ "{#" thru "#}" ]
    
    rules: [
        any [
                escapedLeftBraces
            |
                templateVariable
            |
                escapedLeftBraceAndPercent
            |
                forLoop
            |
                commentRule
            |
                anything
        ]  
    ]
    
    output: copy ""
    parse/all inputString rules
    output
]
