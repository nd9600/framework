Rebol [
    Title: "Tiny Framework: parameter routes"
    Description: "routing.r will read anything in 'routes into the app's routes"
]

routes: [
    [
        url "/routeTest/{parameter}"
        method "GET"
        controller "FirstController@paramFunction1"
    ]
    [
        url "/routeTest/{parameter}/h/{parameter}"
        controller "FirstController@paramFunction2"
    ]
]