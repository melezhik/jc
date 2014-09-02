# SYNOPSIS
JC - is a jam compiler service


# INSTALLATION


    mkdir -p ~/.js/builds

    git clone git@git.x:melezhik/jc.git
    cd jc/js
    eye load config/eye/app.rb
    eye l


# API

## create build


    curl -X POST  -d 'build[key_id]=33' http://127.0.0.1:3000/builds/ -D -

creates js build object, on success returns ID in build_id header


## copy

    curl -X POST  http://127.0.0.1:3000/builds/27/copy?key_id=25 -d ''

- copies jc build with key_id into given js build, techically speaking copies install base from one build to another 


## make artefact

    curl -X POST  -d 'url=file:///tmp/boomerang2-bundle-v0.2.5.66567-1033.tar.gz' -d 'orig_dir=boomerang2-bundle-v0.2.5' http://127.0.0.1:3000/builds/25/make_artefact    

- creates artefact for given distribution 


## show build log

    curl  http://127.0.0.1:3000/builds/25/log

## make request for asynchronous install of targets

    curl -X POST  -d 'names[]=Foo::Bar' -d 'names[]=P/PINTO/Foo-Bar-Baz-0.1.0.tar.gz'  -d 'names[]=Adriver::DBI'  -d 'cpan_mirror=http://cpan.webdev.x/CPAN' http://127.0.0.1:3000/builds/25/install

## get current state of  target installed

    curl  http://127.0.0.1:3000/builds/25/target_state?name=Adriver::DBI

returns target state as `target_state' http header, one of these:

    - OK
    - FAIL
    - IN_PROCESS



