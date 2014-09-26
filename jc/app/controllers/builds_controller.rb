require 'fileutils'
require 'terminal-table'

class BuildsController < ApplicationController

    def index 

        summary = [ "hello world! this is the jc server. version <#{Jessy.version}>" ]
        summary << "latest builds list:"

        Build.all.order( :id => :desc ).limit(10).each do |b|
            summary << "ID:#{b.id} upd at #{b[:updated_at].strftime('%B %d, %Y at %H:%M')} "
        end
        summary << ""

        render :text => summary.join("\n")

		
    end

    def new
        @report = Build.new
    end

    
    def create

        @build = Build.new _params

        @build.save!

        FileUtils.mkdir_p "#{@build.dir}/cpanlib/"
        FileUtils.mkdir_p _artefacts_dir

        @build.log "create build ID: #{@build.id}. key:#{_params[:key_id]} ok"

        response.headers['build_id'] = "#{@build.id}"

        render :text => "create build ID: #{@build.id}. key:#{_params[:key_id]} ok\n"

    end

    def show
        @build = Build.find params[:id]
        redirect_to log_build_path @build
    end

    def copy

        @old_build = Build.find params[:jc_id]
        @build = Build.find params[:id]

        @build.log "copy builds: from: #{@old_build.id} to #{@build.id}"

        cmd = [ ]
        cmd << "rm -rf #{@build.dir}/cpanlib"
        cmd << "cp -r #{@old_build.dir}/cpanlib/  #{@build.dir}/"

        if @build.execute_cmd(cmd) == true
            @build.log "copy ok"
            render :text => "copy build ok\n"
        else
            render :text => "copy build failed\ncheck #{url_for(@build) } for details", :status => 500
        end

    end

    def install

        @build = Build.find params[:id]
        list = []
        env = Hash.new
        env[:cpan_mirror] = params[:cpan_mirror]

        params[:t].each do |name|
            @build.log  "schedulled install for target <#{name}>"
            target = @build.targets.create( :name => name, :state => 'pending' )
            target.save!
            list << target
        end
        Delayed::Job.enqueue( InstallAsync.new( @build,  list, env    ) )       
        @build.log "schedulled asynchronous  install for #{list.size} targets"
        render :text => "schedulled asynchronous  install for #{list.size} targets\n"

    end

    def artefact

        @build = Build.find params[:id]
        url = params[:url]
        orig_dir = params[:orig_dir]
        local_name = (params[:url].split '/').last

        timestamp = Time.now.strftime '%Y-%m-%d_%H-%M-%S'
        dir_name_with_ts = local_name.sub('.tar.gz',"-#{timestamp}") 

        @build.log "create artefact from #{url}. orig dir: #{orig_dir}"
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
        cmd << "mv #{dir_name_with_ts}.tar.gz #{_artefacts_dir}"
        cmd << "ls -lth #{_artefacts_dir}/#{dir_name_with_ts}.tar.gz"

        cmd_str = @build.cmd_str cmd


        if @build.execute_cmd(cmd) == true
            @build.log  "create artefact ok"
	        response.headers['dist_name'] = "#{dir_name_with_ts}.tar.gz"
            # distribution_name
            @build.update :distribution_name => "#{dir_name_with_ts}.tar.gz"
            @build.save!
            render :text => "create artefact ok\n"
        else
            render :text => "create artefact failed\ncheck #{url_for(@build) } for details", :status => 500
        end

    end

    def destroy
        @build = Build.find params[:id]
        if @build.has_artefact?
            @build.log "build has artefact: <#{@build.distribution_name}>, destroy it first ... "
            @build.execute_cmd [ "rm #{_artefacts_dir}/#{@build.distribution_name}", "rm -rf #{@build.dir}" ]
        else
            @build.execute_cmd [ "rm -rf #{@build.dir}" ]
        end

        @build.destroy!
        render :text => "destroy build ID: #{params[:id]}"
    end
   
    def summary

        @build = Build.find params[:id]

        summary = [ "", "Build ID: #{@build.id}. Targets summary." ]

        rows = []

        @build.targets.each do |t|
            rows << [ t.id, t.name, t.state, t.created_at.strftime('%B %d, %Y at %H:%M')  ]
        end

        table = Terminal::Table.new :headings => ['ID', 'Name', 'State' , 'Time' ], :rows =>  rows

        summary << [ "#{table}", "" ]

        render :text => summary.join("\n")
    end

    def target_state
        @build = Build.find params[:id]
        tg_name = params[:name]
        tg = @build.targets.find_by_name!(tg_name)
        response.headers['target_state'] = tg.state
        render :text => "#{tg.state}\n"
    end

    def log
        @build = Build.find params[:id]
        send_file @build.log_path
    end

    def head
        @build = Build.find params[:id]
        render :text => `head -n 10 #{@build.log_path}`
    end

    def tail
        @build = Build.find params[:id]
        render :text => `tail -n 10 #{@build.log_path}`
    end

    def truncate_log
        @build = Build.find params[:id]
        @build.truncate_log
        render :text => "log truncate ok\n"
    end

    def cpanm_log
        @build = Build.find params[:id]
        send_file @build.cpanm_log_path(params["cpanm_id"])
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
