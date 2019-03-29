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
        url "/route_test" 
        method "GET"
        controller "FirstController@index"
    ]

    [
        url "/route_test/{parameter}" 
        controller "FirstController@param_test"
    ]
]