Rebol [
    Title: "Tiny Framework - bundler"
]

do %base/helpers.r


files: copy [%framework.r %bundler.r]
append files findFiles %controllers/
append files findFiles %routing/
append files findFiles %storage/
append files findFiles %templates/
append files findFiles %tests/

; bundles any files that the framework depends on
framework: load %framework.r
parse framework [
    any [
        to file! copy file file! (append files file)
        
    ] to end
]

print rejoin ["bundling [" files "]"]

compressed: copy []
uncompressed: copy []

foreach file files [
    readFile: read file
    compressedFile: compress readFile
    append/only compressed reduce [file compressedFile]
    append/only uncompressed reduce [file readFile]
]

probe length? mold compressed
probe length? mold uncompressed

save/header %bundled.r compose/only [
    bundledFiles: (compressed)

    change-dir %b/
    foreach block bundledFiles [
        filename: first block
        compressed: second block
        decompressed: decompress compressed
        dir: first split-path filename
        make-dir/deep dir
        save filename decompressed
    ]
] [Title: "Tiny Framework - bundled"]
