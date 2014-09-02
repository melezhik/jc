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

        FileUtils.mkdir_p @build.dir
        FileUtils.mkdir_p _artefacts_dir

        @build.log "create build ID: #{@build.id}. key:#{_params[:key_id]} ok"

        response.headers['id'] = "#{@build.id}"

        render :text => "create build ID: #{@build.id}. key:#{_params[:key_id]} ok\n"

    end

    def copy

        @old_build = Build.find params[:key_id]
        @build = Build.find params[:id]

        @build.log "copy builds: from: #{@old_build.id} to #{@build.id}"

        cmd = [ ]
        cmd << "rm -rf #{@build.dir}/cpanlib"
        cmd << "cp -r #{@old_build.dir}/cpanlib/  #{@build.dir}/"

        cmd_str = @build.cmd_str cmd

        @build.log  "running command: #{cmd_str}"

        if system(cmd_str) == true
            @build.log "copy ok"
            render :text => "copy ok\n"
        else
            render :text => "command #{cmd_str} failed\n", :status => 500
        end

    end

    def install
        @build = Build.find params[:id]
        list = []
        params[:names].each do |name|
            @build.log  "schedulled install for target <#{name}>"
            @dist = @build.dists.create( :name => name )
            @dist.save!
            list << @dist
        end
        Delayed::Job.enqueue( InstallAsync.new( @build,  list   ) )       
        @build.log "schedulled asynchronous  install for #{list.size} targets"
        render :text => "schedulled asynchronous  install for #{list.size} targets\n"

    end

    def make_artefact

        @build = Build.find params[:id]
        url = params[:url]
        orig_dir = params[:orig_dir]
        local_name = (params[:url].split '/').last

        timestamp = Time.now.strftime '%Y-%m-%d_%H-%M-%S'
        dir_name_with_ts = local_name.sub('.tar.gz',"-#{timestamp}") 

        @build.log "make artefact from #{url}. orig dir: #{orig_dir}"
        @build.log "local name: #{local_name}"
        @build.log "dir name with ts: #{dir_name_with_ts}"

        cmd = []
        cmd << "cd #{@build.dir}"
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

        @build.log  "running command: #{cmd_str}"

        if system(cmd_str) == true
            @build.log  "make artefact ok"
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
