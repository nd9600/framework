Rebol [
    Title: "Tiny Framework: Test controller"
]

getTest: func [
    request [object!]
] [
    mold request
]

postTest: func [
    request [object!]
] [
    "hello POST world"
    mold request
]