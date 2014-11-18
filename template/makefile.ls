#!/usr/bin/env lsc 

{ parse, add-plugin } = require('newmake')

name            = "_site"
destination-dir = "#name"
source-dir      = "assets"

s = -> "#source-dir#it"
d = -> "#destination-dir#it"

{baseUrl} = require('./site.json')


parse ->


    @add-plugin 'jadeBeml',(g, deps) ->
        @compile-files( (-> "jade -O ./site.json -P -p #{it.orig-complete} < #{it.orig-complete} | beml-cli > #{it.build-target}"), ".html", g, deps )

    @notifyStrip destination-dir 

    @serveRoot '.'

    @collect "all", -> [
        @notify ~>
            @toDir d("/css"), ->
                        @less s("/less/client.less"), s("/less/*.less")


        @notify ~>
            @toDir d(""), { strip: s("") }, -> [
                @jadeBeml s("/index.jade")
                ]

        @notify ~>
            @toDir d("/js/client.js"), ->
                       @browserify s("/js/client.ls"), s("/js/*.{ls,js}")
        ]

    @collect "deploy", -> 
        @command-seq -> [
            @make "all"
            @cmd "blog-ftp-cli -l #name -r #baseUrl"
            ]

    @collect "clean", -> [
        @remove-all-targets()
        @cmd "rm -rf #name"
    ]



        

