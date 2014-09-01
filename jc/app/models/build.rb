class Build < ActiveRecord::Base

    has_many :dists
    validates :key_id, presence: true    

    def log_path
        "#{build_dir}/log.txt"
    end

    def log line
        File.open(log_path, 'a') do |l|
            l << line
        end
    end

    def cmd_str cmd = []
        cmd.map { |c| "#{c} 1>>#{log_path} 2>&1" }.join " && \\\n"
    end


    def build_dir
        "#{Dir.home}/.jc/builds/#{id}"
    end

end
