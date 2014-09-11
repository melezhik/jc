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
        logger.info line
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

private

    def execute_cmd( cmd = [], raise_ex = true )
    
            cmd_str = cmd_str cmd

            log :info, "running command: #{cmd_str}"
    
            exit_status = nil

            Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
    
                while line = stdout.gets("\n")
                    log :debug,  line
                end
    
                while line = stderr.gets("\n")
                    log :error,  line
                end
    
                exit_status = wait_thr.value
    
                if exit_status.success?
                    log :debug, "command successfully executed, exit status: #{exit_status}"
                else
                    log :error, "command unsuccessfully executed, exit status: #{exit_status}"
                    raise "command unsuccessfully executed, exit status: #{exit_status}" if raise_ex == true
                end
            end

            exit_status.success?

    end

end
