Rebol [
    Title: "Tiny Framework - test driver"
]

testFilenameSuffix: copy "Test.r"
testFunctionNamePrefix: copy "test"

; test files are those that end with "Test.r"
testFiles: findFiles/matching %tests/ lambda [endsWith ? testFilenameSuffix]

; runs all functions that start with test in testFiles
; runs setUp and tearDown functions before each test function, if they exist
foreach testFile testFiles [

    testFileContents: context load testFile        
    testFileObject: testFileContents/tests
    wordsInTestFile: copy words-of testFileObject
    testFunctions: f_filter lambda [startsWith to-string ? testFunctionNamePrefix] wordsInTestFile

    ; actually call each test function; we don't care about the results
    foreach testFunction testFunctions [
        if in testFileObject 'setUp [testFileObject/setUp]
        testFileObject/:testFunction
        if in testFileObject 'tearDown [testFileObject/tearDown]
    ]
]

print "all tests pass"