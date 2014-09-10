# SYNOPSIS

JC - is a jessy compiler


# INSTALLATION


    su - jc
    git clone git@git.x:melezhik/jc.git
    cd jc/jc
    eye load config/eye/app.rb

# Configuration

    su - jc
    mkdir -p ~/.jc/artefacts
    cd jc/jc/public/
    ln -s ~/.jc/artefacts artefacts

# API

## create build

    curl -X POST  -d 'build[key_id]=33' http://127.0.0.1:3000/builds/ -D -

creates js build object, on success returns object's ID in `build_id` http header


## copy

    curl -X POST  http://127.0.0.1:3000/builds/27/copy?key_id=1001 -d ''

- copies jc build with key_id into given js build, techically speaking copies install base from one build to another 


## create artefact

    curl -X POST  -d 'url=file:///tmp/boomerang2-bundle-v0.2.5.66567-1033.tar.gz' -d 'orig_dir=boomerang2-bundle-v0.2.5' http://127.0.0.1:3000/builds/25/artefact    

- creates artefact for given distribution, returns artefact name as `dist_name` http header


## show build log

    curl  http://127.0.0.1:3000/builds/25/log

## make request for asynchronous install of targets

    curl -X POST  -d 't[]=Foo::Bar' -d 't[]=P/PINTO/Foo-Bar-Baz-0.1.0.tar.gz'  -d 't[]=Adriver::DBI'  -d 'cpan_mirror=http://cpan.webdev.x/CPAN' http://127.0.0.1:3000/builds/25/install

## get current state of  target installed

    curl  http://127.0.0.1:3000/builds/25/target_state?name=Adriver::DBI

returns target state as `target_state' http header, one of these:

    - pending # wait for scheduller to run target install
    - install # target is being installed currently 
    - ok # target successfully installed
    - fail # failed to install target


## summary

    http://127.0.0.1:3000/builds/25/summary 

returns build summary info in human readable form

##
    curl 127.0.0.1:3001/artefacts/Simple-Foo-v0.1.0.66644-1128-2014-09-10_14-30-22.tar.gz

download artefact


