Rebol [
	Title:  "Test HTTPd Scheme"
	File:   %server-test.r3
	Date:    02-Jul-2020
	Author: "Oldes"
	Version: 0.6.0
	Note: {
		To test POST method from Rebol console, try this:
		```
		write http://localhost:8081 {msg=hello}
		write http://localhost:8081 [post [user-agent: "bla"] "hello"]

		```
	}
]

import %httpd.reb

system/options/log/httpd: 4 ; for verbose output
system/options/quiet: false

make-dir/deep %_logs/ ;; make sure that there is the directory for logs

humans.txt: {
       __
      (  )
       ||
       ||
   ___|""|__.._
  /____________\
  \____________/~~~> http://github.com/oldes/
}


serve-http [
	port: 9000
	;- Main server configuration                                                                 
	root: %public/
	;server-name: "nginx" ;= it's possible to hide real server name
	keep-alive: [30 100] ;= [timeout max-requests] or FALSE to turn it off
	log-access: %_logs/tech.rebol-access.log
	log-errors: %_logs/tech.rebol-errors.log
	list-dir?:  true
	;- Server's actor functions                                                                  
	actor: [
		On-Accept: func [info [object!]][
			; allow only connections from localhost
			; TRUE = accepted, FALSE = refuse
			;find [ 127.0.0.1 ] info/remote-ip 
			true
		]
		On-Header: func [ctx [object!] /local path key][
			path: ctx/inp/target/file
			;- detect some of common hacking attempts...
			unless parse path anti-hacking-rules [
				ctx/out/status: 418 ;= I'm a teapot
				ctx/out/header/Content-Type: "text/plain; charset=UTF-8"
				ctx/out/content: "Your silly hacking attempt was detected!"
				exit
			]
			;- serve valid content...
			switch path [
				%/form/     [
					; path rewrite...
					; http://localhost:8081/form/ is now same like http://localhost:8081/form.html
					ctx/inp/target/file: %/form.html
					; request processing will continue
				]
				%/form.htm
				%/form.html [
					ctx/out/status: 301 ;= Moved Permanently
					ctx/out/header/Location: %/
					; request processing will stop with redirection response
				]
				%/plain/ [
					ctx/out/status: 200
					ctx/out/header/Content-Type: "text/plain; charset=UTF-8"
					ctx/out/content: "hello"
					; request processing will stop with response 200 serving the plain text content
				]
				%/ip [
					; service to resolve the remote ip like: http://ifconfig.me/ip
					ctx/out/status: 200
					ctx/out/header/Content-Type: "text/plain"
					ctx/out/content: form ctx/remote-ip
				]
				%/header [
					ctx/out/status: 200
					ctx/out/header/Content-Type: "text/plain"
					ctx/out/content: ajoin [
						"Request input:" mold ctx/inp
					]
				]
				%/echo [
					;@@ Consider checking the ctx/out/header/Origin value
					;@@ before accepting websocket connection upgrade!   
					system/schemes/httpd/actor/WS-handshake ctx
				]
				%/env [
					ctx/out/status: 200
					ctx/out/header/Content-Type: "text/plain"
					ctx/out/content: clear ""
					try [call/shell/output/wait "env" :ctx/out/content]
				]
			]
		]
		On-Post: func [ctx [object!] /local data][
			if ctx/inp/target/file = %/api/v2/do [
				;- A primitive API example                                                    
				try/with [
					;?? ctx/inp
					data: ctx/inp/content
					unless map? data [data: to map! ctx/inp/content/1] ;;= url-encoded input
					;; using plain secret in this example,
					;; but it should be replaced with something better in the real life
					if data/token <> "SOME_SECRET" [
						ctx/out/status: 401 ;= Unauthorized
						exit
					]
					;; reusing the input for an output
					;; without the token...
					remove/key data 'token
					;; but with result of the input expression...
					;@@ NOTE that there is no security setting, so the code may be dangerous!
					data/result: mold/all try load data/code
					ctx/out/header/Content-Type: "application/json"
					ctx/out/content: to-json data
				][
					ctx/out/status: 400 ;= Bad request
				]
				exit
			]
			;; else just return what we received...
			ctx/out/content: ajoin [
				"<br/>Request header:<pre>" mold ctx/inp/header </pre>
				"Received <code>" ctx/inp/header/Content-Type/1 
				"</code> data:<pre>" mold ctx/inp/content </pre>
			]
		]
		On-Not-Found: func[ctx][
			;; Here may be provided custom content, when requested file is not found
			unless parse ctx/inp/target/file [
				;; we must work with an absolute path!
				ctx/config/root [
					;-- serving the content directly from the memory
					%humans.txt (ctx/out/content: humans.txt) ;@@ https://codeburst.io/all-about-humans-humans-txt-actually-f571d37f92d2
				|	%robots.txt (ctx/out/content: robots.txt) ;@@ https://developers.google.com/search/docs/crawling-indexing/robots/create-robots-txt
				|	%bot-trap/  (ctx/out/content: ajoin ["Welcome bot: " ctx/inp/header/User-Agent])
				]
			][
				ctx/out/status: 404
				;; including an optional message...
				ctx/out/content: "Content not found on this server!"
				append ctx/out/content rejoin [{<pre>} mold ctx/inp {</pre>}]
			]
		]

		On-Post-Received: func [ctx [object!] /local data][
			if ctx/inp/target/file = %/api/v2/do [
				;- A primitive API example                                                    
				try/except [
					;?? ctx/inp
					data: ctx/inp/content
					unless map? data [data: to map! ctx/inp/content/1] ;;= url-encoded input
					;; using plain secret in this example,
					;; but it should be replaced with something better in the real life
					if data/token <> "SOME_SECRET" [
						ctx/out/status: 401 ;= Unauthorized
						exit
					]
					;; reusing the input for an output
					;; without the token...
					remove/key data 'token
					;; but with result of the input expression...
					;@@ NOTE that there is no security setting, so the code may be dangerous!
					data/result: mold/all try load data/code
					ctx/out/header/Content-Type: "application/json"
					ctx/out/content: to-json data
				][
					ctx/out/status: 400 ;= Bad request
				]
				exit
			]
			;; else just return what we received...
			ctx/out/content: ajoin [
				"<br/>Request header:<pre>" mold ctx/inp/header </pre>
				"Received <code>" ctx/inp/header/Content-Type/1 
				"</code> data:<pre>" mold ctx/inp/content </pre>
				<pre> ctx/inp </pre>
			]
		]
	]
]

