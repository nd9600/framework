Rebol [
    Title: "Tiny Framework: default routes"
    Documentation: http://www.rebol.net/cookbook/recipes/0057.html
]

routes: [
    [
        url "/test" 
        method "GET"
        controller "TestController@getTest"
    ]

    [
        url "/test" 
        method "POST"
        controller "TestController@postTest"
    ]

    [
        url "/routeTest" 
        method "GET"
        controller "FirstController@index"
    ]

    [
        url "/routeTest/{parameter}" 
        controller "FirstController@paramTest"
    ]
]