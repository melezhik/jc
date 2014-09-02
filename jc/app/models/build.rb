require 'fileutils'

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
        cmd.map { |c| "#{c} 1>>#{log_path} 2>&1" }.join " && \\\n"
    end


    def dir
        "#{Dir.home}/.jc/builds/#{id}"
    end

    def truncate_log
        File.truncate log_path, 0
    end

end
