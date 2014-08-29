require 'fileutils'
class BuildsController < ApplicationController

    def index 
        render :text => "hello world\n"
    end

    def new
        @report = Build.new
    end

    def create

        @build = Build.new _params

        logger.info "create build ID: #{@build.id}. key:#{_params[:key_id]}"
    
        @build.save!


        FileUtils.mkdir_p "#{Dir.home}/.jc/builds/#{@build.id}"
        render :text => "build ID: #{@build.id}. key:#{_params[:key_id]} created ok\n"

    end

    def set_install_base

        @build = Build.find params[:id]
        dir_name = params[:path].sub('.tar.gz','')

        cmd = "cd #{Dir.home}/.jc/builds/#{@build.id} && rm -rf *"
        cmd << " && cp  -v #{Dir.home}/.jc/artefacts/#{params[:path]} ."
        cmd << " && tar -xzf #{params[:path]} && cd #{dir_name} && cp -r cpanlib/ ../ "
        cmd << " && cd ../ && rm -rf #{dir_name} && rm #{params[:path]} && ls -l cpanlib/"
        out = `#{cmd}`

        render :text => "ustall base from: #{params[:path]} set ok\n output: #{out}"

    end

private

    def _params
        params.require(:build).permit( 
            :key_id
        )
    end

end
