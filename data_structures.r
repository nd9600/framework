Rebol [
    Title: "Tiny Framework - data structures"
]

request_obj: context [
    method: copy ""
    url: copy ""
    query_parameters: copy []
]

response_obj: context [
    status: 200,
    mime: copy ""
    data: copy ""
]