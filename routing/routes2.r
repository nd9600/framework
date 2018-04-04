Rebol [
    Title: "Tiny Framework: parameter routes"
    Description: "routing.r will read anything in 'routes into the app's routes"
]

routes: [
    [
        url "/route_test/{parameter}"
        method "GET"
        controller "FirstController@param_function1"
    ]
    [
        url "/route_test/{parameter}/h/{parameter}"
        controller "FirstController@param_function2"
    ]
]