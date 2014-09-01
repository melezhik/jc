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

        @build.save!

        FileUtils.mkdir_p "#{Dir.home}/.jc/builds/#{@build.id}"

        log @build, "create build ID: #{@build.id}. key:#{_params[:key_id]} ok\n"

        response.headers['id'] = "#{@build.id}"

        render :text => "create build ID: #{@build.id}. key:#{_params[:key_id]} ok\n"

    end

    def set_install_base

        @build = Build.find params[:id]
        dir_name = params[:path].sub('.tar.gz','')

        log @build, "set install base from: #{params[:path]}\n\n"

        cmd = [ ]
        cmd << "cd #{Dir.home}/.jc/builds/#{@build.id}"
        cmd << "rm -rf #{dir_name}"
        cmd << "rm -rf cpanlib"
        cmd << "cp  -v #{Dir.home}/.jc/artefacts/#{params[:path]} ."
        cmd << "tar -xzf #{params[:path]}"
        cmd << "cd #{dir_name}"
        cmd << "cp -r cpanlib/ ../"
        cmd << "cd ../"
        cmd << "rm -rf #{dir_name} #{params[:path]}"

        cmd_str = cmd.map { |c| "#{c} 1>>#{Dir.home}/.jc/builds/#{@build.id}/log.txt 2>&1" }.join ' && '

        log @build, "running command: #{cmd_str}\n\n"

        if system(cmd_str) == true
            log @build, "set install base ok\n"
            render :text => "set install base from: #{params[:path]} ok\n"
        else
            render :text => "command #{cmd_str} failed\n", :status => 500
        end

    end

private


    def log build, line
        File.open("#{Dir.home}/.jc/builds/#{build.id}/log.txt", 'a') do |l|
            l << line
        end
    end

    def _params
        params.require(:build).permit( 
            :key_id
        )
    end

end
