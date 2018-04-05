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

    probe rule
    probe parse route rule

    reduce ['collect parse route rule]
]

probe context parse "/user/nikic/42" probe emit "/user/{name}/{id}"