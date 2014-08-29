cwd = File.expand_path(File.join(File.dirname(__FILE__), %w[ ../ ../ ]))
port = 3000
app = :jc

Eye.config do
    logger "#{cwd}/log/eye.log"
end

Eye.application app do

  working_dir cwd
  stdall "#{cwd}/log/trash.log" # stdout,err logs for processes by default

    process :api do
        pid_file "tmp/pids/server.pid"
        start_command "rails server -d -P #{cwd}/tmp/pids/server.pid -p #{port}"
        daemonize false
        stdall "#{cwd}/log/api.eye.log"
        start_timeout 30.seconds
        stop_timeout 30.seconds
    end

end
