emit: func [route][
    rule: [
        collect [
            some [
                keep to "{" skip
                copy label to "}" skip ahead [set mark skip | end (mark: 'end)] 
                keep (
                    compose/only [
                        keep (
                            to paren! reduce ['quote to set-word! label]
                        ) 
                        keep to (mark)
                    ]
                )
            |   thru end keep ([thru end])
            ]
        ]
    ]

    reduce ['collect parse route rule]
]

probe context parse "/user/nikic/42" probe emit "/user/{name}/{id}",

convert_rule_to_parse_rule: funct [
    "converts a rule of the form abcdef/{}/123{} to Redbol's PARSE rule"
    rule_as_string [string!]
] [
    converted_rule: copy []
    conversion_rules: [

        ; handles parameters
        any [
            copy match_until_parameter to "{" (append converted_rule match_until_parameter)
            thru "}" 
            [
                ; if the parameter was at the end of the rule
                end ( 
                    append converted_rule compose [
                        copy parameter_data to end (to-paren [keep parameter_data])
                    ]
                    )
            |
                ; if the parameter wasn't at the end of the rule
                copy match_until_after_parameter skip (
                    append converted_rule compose [
                        copy parameter_data to (match_until_after_parameter) skip (to-paren [keep parameter_data])
                    ]
                    ) 
            ]
        ]

        ; used if/when there aren't any parameters
        copy match_until_end to end (append converted_rule match_until_end)
    ]
    parse rule_as_string conversion_rules
    converted_rule
]

s: "abcdef/{}/123{}1"
url: "abcdef/abc/123abracadabra1"
rule: convert_rule_to_parse_rule s
parameters: collect compose/only [
    matches: parse url (rule)
]
probe matches
probe parameters