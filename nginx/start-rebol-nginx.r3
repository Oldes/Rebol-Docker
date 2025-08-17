REBOL [
    Title:   "Start NGINX with Rebol as a backend server Docker Container"
    Purpose: "Create/mount public and cgi-bin directories and start container"
    Notes:   "Requires Docker Desktop."
]

;--------------------------------
;- Configuration (edit as needed)
image-name:     "rebol-nginx"
container-name: "rebol-nginx-app"
port:           8090

; Host directories (relative to script directory by default)
base-dir:   what-dir
public-dir: base-dir/public
app-dir:    base-dir/app
conf-dir:   base-dir/conf

; Mount modes: use ":ro" for read-only, or "" for read-write
public-mode: ":ro"
cgi-mode: ""  ; allow write for debugging; set to ":ro" for read-only

;----------------------------
;- Helpers                   
ensure-dir: func [dir [file!]] [
    unless exists? dir [
        make-dir/deep dir
        print ["Created" mold dir]
    ]
]

do-cmd: function [cmd][
	if block? cmd [cmd: rejoin cmd]
	out: copy ""
	err: copy ""
	?? cmd
	call/shell/output/error :cmd :out :err
	unless empty? err [return make error! err]
	?? out
	out
]

docker-available?: function[][
    res: do-cmd "docker --version"
    parse res ["Docker version" to end]
]

;----------------------------
;- Main                      
unless docker-available? [
    print "^/[ERROR] Docker CLI not found. Please install Docker Desktop and ensure 'docker' is in PATH."
    quit/return 1
]

res: do-cmd [{docker ps -aq -f name="^^} container-name {$"}]

either any [error? res empty? res][
	docker-run-cmd: rejoin [
	    "docker run -d"
	    " -p " :port ":80"
	    " -v ^"" to-local-file conf-dir   "/nginx.conf:/etc/nginx/nginx.conf:ro^""
	    " -v ^"" to-local-file conf-dir   "/conf.d:/etc/nginx/conf.d/:ro^""
	    " -v ^"" to-local-file conf-dir   "/supervisord.conf:/etc/supervisord.conf:ro^""
	    " -v ^"" to-local-file public-dir ":/usr/share/nginx/html" public-mode {"}
	    " -v ^"" to-local-file app-dir    ":/opt/app" cgi-mode {"}
	    " --restart unless-stopped"
	    " --name " container-name SP image-name    
	]
][
	docker-run-cmd: rejoin [
		"docker restart " container-name
	]
]

?? docker-run-cmd

print "^/Starting container..."
call/console/wait docker-run-cmd

print rejoin ["Open: http://localhost:" port "/"]
print rejoin ["CGI:  http://localhost:" port "/cgi-bin/hello.r3"]

print "^/Useful commands:"
print rejoin ["  docker logs -f " container-name]
print rejoin ["  docker restart " container-name]
print rejoin ["  docker stop " container-name]
print rejoin ["  docker rm -f " container-name]
print "^/Done."