Rebol [
    Title: "Tiny Framework - tests"
    Documentation: http://www.rebol.net/cookbook/recipes/0057.html
]

; test files are those that have end with "test.r"
testFiles: findFiles/matching %tests/ lambda [endsWith ? "Test.r"]


; runs all functions that start with test in testFiles
; runs setUp and tearDown functions before each test function, if they exist

foreach testFile testFiles [

    ; directories and wrong files are included too
    if all [not dir? testFile (%.r = suffix? testFile)] [
        testFileContents: context load testFile        
        if in testFileContents 'tests [
            testFileObject: testFileContents/tests
            words: copy words-of testFileObject
            testFunctions: f_filter lambda [startsWith to-string ? "test"] words
            testResults: f_map lambda [
                functionToCall: to-word ?
                if in testFileObject 'setUp [testFileObject/setUp]
                testFileObject/:functionToCall
                if in testFileObject 'tearDown [testFileObject/tearDown]
            ] testFunctions
        ]
    ]
]

print "all tests pass"