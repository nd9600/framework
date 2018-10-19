Rebol [
    Title: "Tiny Framework - templater"
]

t_load: funct [
    template_name ["string!"] "the template.path"
] [
    read config/templates_dir/:template_name
]

compile: funct [
    input_string    [string!]   "the input to compile"
    variables       [hash!]    "the variables to use to compile the input string"
] [        
    whitespace:     [#" " | tab | newline]
    digit:          charset "0123456789"
    letter:         charset [#"A" - #"Z" #"a" - #"z" ]
    other_char:     charset ["_" "-" "'" ":"]
    alphanum:       union letter digit
    any_character:  complement make bitset! []
    
    ; a variable name must start with a letter and can be followed by a series of letters, digits or underscores or dashes
    variable: [letter any [alphanum | other_char]]
    
    ; copy any character into the output
    anything: [copy data any_character (append output data)]
    
    ; copy escaped left braces nto the output
    escaped_left_braces: [copy data "\{{" (append output data)]
    
    ; copy the value of a variable into the output, or "none" if the variable doesn't exist
    template_variable: [
        "{{" any whitespace copy data variable any whitespace "}}"
        (
            variable_name: to-word data
            actual_variable: select variables variable_name
            append output actual_variable
        )
    ]
    
    escaped_left_brace_and_percent: [copy data "\{%" (append output data)]
    
    for_loop: [
        "{%" any whitespace "for" 
            some whitespace copy iteratorIndex variable
            some whitespace "in" 
            some whitespace copy thingToIterateOver variable
        any whitespace "%}"
            copy stringToCompileRepeatedly to 
        "{%" "{%" any whitespace "endfor" any whitespace "%}" ]
        (
            iteratorIndexAsVariable: to-word iteratorIndex
            
            thingToIterateOver: to-word thingToIterateOver
            actualThingToIterateOver: select variables thingToIterateOver
            
            foreach i actualThingToIterateOver [
                thisIterationsVariables: copy variables
                insert thisIterationsVariables [:iteratorIndexAsVariable :i]
                append output (compile stringToCompileRepeatedly thisIterationsVariables)
            ]
            
            append output 
        )
    ]
    
    ;'comment is already defined in rebol
    comment_rule: [ "{#" thru "#}" ]
    
    rules: [
        any [
                escaped_left_braces
            |
                template_variable
            |
                escaped_left_brace_and_percent
            |
                for_loop
            |
                comment_rule
            |
                anything
        ]  
    ]
    
    output: copy ""
    parse/all input_string rules
    output
]
