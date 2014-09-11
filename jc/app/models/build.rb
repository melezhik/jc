require 'fileutils'
require 'open3'

class Build < ActiveRecord::Base

    has_many :targets
    validates :key_id, presence: true    

    def log_path
        "#{dir}/log.txt"
    end

    def logger
        if @logger 
            @logger
        else
            f = File.open(log_path, 'a')
            f.sync = true
            @logger =  Logger.new f
        end
    end

    def log line
        logger.info line.chomp
    end

    def cmd_str cmd = []
        cmd.join " && \\\n"
    end


    def dir
        "#{Dir.home}/.jc/builds/#{id}"
    end

    def truncate_log
        File.truncate log_path, 0
    end

    def execute_cmd( cmd = [], raise_ex = true )
    
            cmd_str = cmd_str cmd

            log "running command: #{cmd_str}"
    
            exit_status = nil

            Open3.popen3(cmd_str) do |stdin, stdout, stderr, wait_thr|
    
                while line = stdout.gets("\n")
                    log line
                end
    
                while line = stderr.gets("\n")
                    log line
                end
    
                exit_status = wait_thr.value
    
                if exit_status.success?
                    log "command successfully executed, exit status: #{exit_status}"
                else
                    log "command unsuccessfully executed, exit status: #{exit_status}"
                    raise "command unsuccessfully executed, exit status: #{exit_status}" if raise_ex == true
                end
            end

            exit_status.success?

    end

end
