Rebol [
    Title: "Tiny Framework - tests"
    Documentation: http://www.rebol.net/cookbook/recipes/0057.html
]

; test files are those that have end with "test.r"
testFiles: findFiles/matching %tests/ lambda [endsWith ? "Test.r"]

probe testFiles

;runs all functions that start with test in testFiles

foreach testFile testFiles [
    testFileContents: context load testFile
    testFileObject: testFileContents/tests
    functions: copy words-of testFileObject
    testFunctions: f_filter lambda [startsWith to-string ? "test"] functions
    testResults: f_map lambda [
        functionToCall: to-word ?
        if in testFileObject 'setUp [testFileObject/setUp]
        testFileObject/:functionToCall
        if in testFileObject 'tearDown [testFileObject/tearDown]
    ] testFunctions

    probe testFunctions
]

print "all tests pass"