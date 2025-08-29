Rebol [
    title:  "Docker utilities"
    name:    docker
    type:    module
    version: 0.0.1
    Date:    29-Aug-2025
    Author:  @Oldes
    File:    %docker.reb
    exports: [
        version
        list-containers
        run
    ]
]

system/options/log/docker: 2                        ;; enable logging for the 'docker'

do-cmd: function [cmd /console /test][
    if block? cmd [cmd: rejoin cmd]                 ;; accept commands as blocks; join into a single string
    log-info 'DOCKER cmd                            ;; log the command before execution
    parse cmd [any [to LF remove LF]]               ;; strip literal LF characters (flatten single-line when needed)
    if test [exit]                                  ;; dry-run mode: do nothing further
    either console [                                ;; interactive mode: attach stdio to the current console
        call/shell/console/wait :cmd                ;; run command via shell, block until it finishes
    ][
        out: copy ""                                ;; buffer for stdout
        err: copy ""                                ;; buffer for stderr
        call/shell/output/error :cmd :out :err      ;; execute capturing both stdout and stderr
        unless empty? err [return make error! err]  ;; if anything on stderr, return it as an error!
        log-debug 'DOCKER as-green out              ;; debug-log the successful output
        out                                         ;; return stdout text
    ]
]

version: function[][                                 
    res: do-cmd "docker --version"                  ;; query docker for version info
    parse res ["Docker version " copy ver: to "," to end] ;; extract version substring up to first comma
    attempt [transcode/one ver]                     ;; try to convert to a typed value (e.g., decimal/tuple)
]

containers: make map! []                            ;; cache map for container listings: name -> [id image]

list-containers: function [
    "Return map of container names with IDs and image names"
][
    res: next split-lines do-cmd "docker ps"        ;; split output into lines; skip the header row
    clear containers                                ;; reset the cache for a fresh listing
    foreach line res [                              ;; iterate through each container line
        print line                                  ;; echo raw line (optional visibility)
        if parse line [                             ;; parse columns separated by runs of spaces
            copy id:    to "  " any SP              ;; container ID
            copy image: to "  " any SP              ;; image name
            to "  " any SP                          ;; command (skip)
            to "  " any SP                          ;; created (skip)
            to "  " any SP                          ;; status (skip)
            to "  " any SP                          ;; ports (skip)
            copy name: to end                       ;; container name (last column)
        ][
            try [name: to word! name]               ;; use word! key if valid, else keep string
            containers/:name:  reduce [id image]    ;; store mapping: name -> [id image]
        ]
    ]
    containers                                      ;; return the filled map
]

inspect: function[container][
    decode 'json do-cmd ajoin ["docker container inspect " container] ;; run inspect and decode JSON to values
]

run: function [
    spec [object! block! map!]          ;; run specification containing image, flags, ports, volumes, etc.
    /test "Don't evaluate the command"  ;; if set, build and show the command but do not execute
    /console                            ;; run attached to console (interactive TTY)
][
    ;; Ensure required 'image' is present
    unless image: select spec 'image [
        cause-error 'user 'message "Spec must include 'image'"
    ]

    ;; Initialize command and extract common fields
    cmd: copy "docker run"
    sep: "^/ "                             ;; separator for readability in composed command
    name:    select spec 'name             ;; optional container name
    command: select spec 'command          ;; optional command/entrypoint override
    volumes: any [select spec 'volumes []] ;; optional volumes block
    flags:   any [select spec 'flags []]   ;; optional flags block
    ports:   select spec 'ports            ;; optional ports block

    if all [console not find flags '-it][
        append flags '-it
    ] 

    ;; Add --name if provided
    if any-string? :name [
        repend cmd [sep "--name " :name]
    ]

    ;; If command is a string, handle inline vs. multiline payloads
    if string? :command [
        trim/head/tail command: copy command       ;; normalize edges
        if find command LF [                       ;; multiline payload: write a script and mount it
            unless find/match command "#!" [       ;; ensure a shebang for shell execution
                insert command "#!/bin/sh^/"
            ] 
            script: rejoin [%./ any [name "cmd"] %-entry.sh]  ;; derive script filename from name or fallback
            write script command                    ;; write script file
            command: to string! next script         ;; convert %file to string path (strip leading %)
            volumes: copy volumes                   ;; work on a copy so spec is not mutated
            repend volumes [script next script 'read-only]  ;; mount host script to same path in container, ro
        ]
    ]

    ;; Append flags and their arguments
    if block? :flags [
        forall flags [
            flag: form flags/1                          ;; stringify current token
            append cmd either #"-" = flag/1 [sep][#" "] ;; new flag vs. argument continuation
            append cmd flag
        ]
    ]

    ;; Append port mappings: -p host:container
    if block? :ports [
        foreach [h c] ports [
            repend cmd [sep "-p " h ":" c]
        ]
    ]

    ;; Append volume mounts: -v host:container[:ro]
    if block? :volumes [
        parse volumes [any [
            set host: file!                 ;; host path (file!)
            set cont: file! (               ;; container path (file!)
                repend cmd [
                    sep "-v "
                    to-local-file/full host ;; render OS-native path including drive/space handling
                    #":" cont               ;; separator and container destination
                ]
            )
            opt ['read-only (append cmd ":ro")]  ;; optional read-only suffix
        ]]
    ]

    ;; Image goes after flags/mounts
    repend cmd [sep image]

    ;; Optional command appended after image
    if string? :command [
        append append cmd sep command 
    ]

    ;; Execute or show command depending on refinements
    either test [
        ?? cmd                                  ;; debug-print the composed command in test mode
    ][
        do-cmd/:console cmd                     ;; run the command; attach console if /console was given
    ]
]
