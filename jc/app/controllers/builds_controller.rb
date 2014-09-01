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

        FileUtils.mkdir_p @build.local_dir
        FileUtils.mkdir_p _artefacts_dir

        @build.log "\n\ncreate build ID: #{@build.id}. key:#{_params[:key_id]} ok\n"

        response.headers['id'] = "#{@build.id}"

        render :text => "create build ID: #{@build.id}. key:#{_params[:key_id]} ok\n"

    end

    def set_install_base

        @build = Build.find params[:id]
        dir_name = params[:path].sub('.tar.gz','')

        @build.log "\n\nset install base from: #{params[:path]}\n\n"

        cmd = [ ]
        cmd << "cd #{@build.build_dir}"
        cmd << "rm -rf #{dir_name}"
        cmd << "rm -rf cpanlib"
        cmd << "cp  -v #{Dir.home}/.jc/artefacts/#{params[:path]} ."
        cmd << "tar -xzf #{params[:path]}"
        cmd << "cd #{dir_name}"
        cmd << "cp -r cpanlib/ ../"
        cmd << "cd ../"
        cmd << "rm -rf #{dir_name} #{params[:path]}"

        cmd_str = @build.cmd_str cmd

        @build.log  "running command: #{cmd_str}\n\n"

        if system(cmd_str) == true
            @build.log "set install base ok\n"
            render :text => "set install base from: #{params[:path]} ok\n"
        else
            render :text => "command #{cmd_str} failed\n", :status => 500
        end

    end

    def install
        @build = Build.find params[:id]
        url = params[:url]
        
    end

    def make_artefact

        @build = Build.find params[:id]
        url = params[:url]
        orig_dir = params[:orig_dir]
        local_name = (params[:url].split '/').last

        timestamp = Time.now.strftime '%Y-%m-%d_%H-%M-%S'
        dir_name_with_ts = local_name.sub('.tar.gz',"-#{timestamp}") 

        @build.log "\n\nmake artefact from #{url}. orig dir: #{orig_dir}\n"
        @build.log "local name: #{local_name}\n"
        @build.log "dir name with ts: #{dir_name_with_ts}\n"

        cmd = []
        cmd << "cd #{@build.build_dir}"
        cmd << "rm -rf temp"
        cmd << "mkdir temp"
        cmd << "cd temp"
        cmd << "curl  #{url} -o #{local_name} -s -f"
        cmd << "tar -xzf #{local_name}"
        cmd << "mv #{orig_dir} #{dir_name_with_ts}"
        cmd << "cp -r ../cpanlib #{dir_name_with_ts}"
        cmd << "tar -czf #{dir_name_with_ts}.tar.gz #{dir_name_with_ts}"
        cmd << "mv #{dir_name_with_ts}.tar.gz #{Dir.home}/.jc/artefacts"
        cmd << "ls -lth #{_artefacts_dir}/#{dir_name_with_ts}.tar.gz"

        cmd_str = @build.cmd_str cmd

        @build.log  "running command: #{cmd_str}\n\n"

        if system(cmd_str) == true
            @build.log  "make artefact ok\n"
            render :text => "make artefact ok\n"
        else
            render :text => "command #{cmd_str} failed\n", :status => 500
        end

    end

    def log
        @build = Build.find params[:id]
        send_file @build.log_path
    end

private

    def _params
        params.require(:build).permit( 
            :key_id
        )
    end

    def _artefacts_dir
        "#{Dir.home}/.jc/artefacts"
    end

end
