# SYNOPSIS

JC - is a jessy compiler

# Dependencies

    ruby ( better to install with rvm )
    nodejs
    libmysqlclient-dev
    libssl-dev
    sqlite3-dev

# INSTALLATION AND CONFIGURATION

## get source code

    su - jc
    git clone git@git.x:melezhik/jc.git
    cd jc/jc

## setup database connetction

    su - jc
    cd jc/jc/

    nano config/database.yml 

	    production:
   	    adapter: mysql2
   	    encoding: utf8
   	    reconnect: true
   	    database: jc
   	    pool: 5
   	    username: *******
   	    password: jc
   	    host: mysql.production.x

## install dependencies

    bundle

## deploy database 

    export RAILS_ENV=production
    rake db:migrate

## run application

    export dj_workers=5
    mkdir -p tmp/pids

    eye load config/eye/app.rb
    eye i

## setup directory for artefacts

    su - jc
    mkdir -p ~/.jc/artefacts
    cd jc/jc/public/
    ln -s ~/.jc/artefacts artefacts

# API

## create build

    curl -X POST  -d 'build[key_id]=33' http://127.0.0.1:4000/builds/ -D -

creates js build object, on success returns object's ID in `build_id` http header


## copy

    curl -X POST  http://127.0.0.1:4000/builds/27/copy?key_id=1001 -d ''

- copies jc build with key_id into given js build, techically speaking copies install base from one build to another 


## create artefact

    curl -X POST  -d 'url=file:///tmp/boomerang2-bundle-v0.2.5.66567-1033.tar.gz' -d 'orig_dir=boomerang2-bundle-v0.2.5' http://127.0.0.1:4000/builds/25/artefact    

## destroy build

    curl -X DELETE  http://127.0.0.1:4000/builds/27

- destroy build object, delete build local directory and ( if build has artefact ) dlete artefact file


## show build log

    curl  http://127.0.0.1:4000/builds/25/log

## make request for asynchronous install of targets

    curl -X POST  -d 't[]=Foo::Bar' -d 't[]=P/PINTO/Foo-Bar-Baz-0.1.0.tar.gz'  -d 't[]=Adriver::DBI'  -d 'cpan_mirror=http://cpan.webdev.x/CPAN' http://127.0.0.1:4000/builds/25/install

## get current state of  target installed

    curl  http://127.0.0.1:4000/builds/25/target_state?name=Adriver::DBI

returns target state as `target_state' http header, one of these:

    - pending # wait for scheduller to run target install
    - install # target is being installed currently 
    - ok # target successfully installed
    - fail # failed to install target


## summary

    http://127.0.0.1:4000/builds/25/summary 

returns build summary info in human readable form

##
    curl 127.0.0.1:3001/artefacts/Simple-Foo-v0.1.0.66644-1128-2014-09-10_14-30-22.tar.gz

download artefact


