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

        _log @build, "\n\ncreate build ID: #{@build.id}. key:#{_params[:key_id]} ok\n"

        response.headers['id'] = "#{@build.id}"

        render :text => "create build ID: #{@build.id}. key:#{_params[:key_id]} ok\n"

    end

    def set_install_base

        @build = Build.find params[:id]
        dir_name = params[:path].sub('.tar.gz','')

        _log @build, "\n\nset install base from: #{params[:path]}\n\n"

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

        cmd_str = _cmd_str @build, cmd

        _log @build, "running command: #{cmd_str}\n\n"

        if system(cmd_str) == true
            _log @build, "set install base ok\n"
            render :text => "set install base from: #{params[:path]} ok\n"
        else
            render :text => "command #{cmd_str} failed\n", :status => 500
        end

    end


    def make_artefact

        @build = Build.find params[:id]
        url = params[:url]
        orig_dir = params[:orig_dir]
        local_name = (params[:url].split '/').last

        timestamp = Time.now.strftime '%Y-%m-%d_%H-%M-%S'
        dir_name_with_ts = local_name.sub('.tar.gz',"-#{timestamp}") 

        _log @build, "\n\nmake artefact from #{url}. orig dir: #{orig_dir}\n"
        _log @build, "local name: #{local_name}\n"
        _log @build, "dir name with ts: #{dir_name_with_ts}\n"

        cmd = []
        cmd << "cd #{Dir.home}/.jc/builds/#{@build.id}"
        cmd << "rm -rf #{local_name}"
        cmd << "curl #{url} -o #{local_name}"
        cmd << "tar -xzf #{local_name}"
        cmd << "mv #{orig_dir} #{dir_name_with_ts}"
        cmd << "cp -r ./cpanlib #{dir_name_with_ts}"
        cmd << "tar -czf #{dir_name_with_ts}.tar.gz #{dir_name_with_ts}"
        cmd << "ls -lth #{Dir.home}/.jc/builds/#{@build.id}"

        cmd_str = _cmd_str @build, cmd

        _log @build, "running command: #{cmd_str}\n\n"

        if system(cmd_str) == true
            _log @build, "make artefact ok\n"
            render :text => "make artefact ok\n"
        else
            render :text => "command #{cmd_str} failed\n", :status => 500
        end

    end

    def log
        @build = Build.find params[:id]
        send_file log_path(@build)
    end

private


    def log_path build
        "#{Dir.home}/.jc/builds/#{build.id}/log.txt"
    end

    def _log build, line
        File.open(log_path(build), 'a') do |l|
            l << line
        end
    end

    def _params
        params.require(:build).permit( 
            :key_id
        )
    end

    def _cmd_str build, cmd = []
        cmd.map { |c| "#{c} 1>>#{log_path(build)} 2>&1" }.join " && \\\n"
    end
end
