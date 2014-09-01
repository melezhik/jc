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


    curl -X POST  -d 'build[key_id]=33' http://127.0.0.1/builds/ -D -

creates js build object, on success returns ID in build_id header


## set install base

    curl -X POST  -d 'path=boomerang2-bundle-v0.2.5.66567-1033-2014-08-29_16-04-13.tar.gz' http://127.0.0.1:3000/builds/25/set_install_base

- gets install base from given artefact and copies it into js build directory


## make artefact

    curl -X POST  -d 'url=file:///tmp/boomerang2-bundle-v0.2.5.66567-1033.tar.gz' -d 'orig_dir=boomerang2-bundle-v0.2.5' http://127.0.0.1:3000/builds/25/make_artefact    

- creates artefact for given distribution 


## show build log

    curl  http://127.0.0.1:3000/builds/25/log


