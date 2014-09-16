cwd = File.expand_path(File.join(File.dirname(__FILE__), %w[ ../ ../ ]))
port = 3001
app = :jc
puts cwd

Eye.config do
    logger "#{cwd}/log/eye.log"
end

Eye.application app do

  working_dir cwd
  stdall "#{cwd}/log/trash.log" # stdout,err logs for processes by default

    process :api do
        pid_file "tmp/pids/server.pid"
        start_command "puma -C config/puma.rb -d --pidfile #{cwd}/tmp/pids/server.pid"
        daemonize false
        stdall "#{cwd}/log/api.eye.log"
        start_timeout 30.seconds
        stop_timeout 30.seconds
    end

    group 'dj' do

        workers = (ENV['dj_workers']||'2').to_i
        (1..workers).each do |i|
            process "dj#{i}" do
                env 'PERL5LIB' => "#{ENV['HOME']}/perl5/lib/perl5:/usr/local/rle/lib/perl5"
                pid_file "tmp/pids/delayed_job.#{i}.pid" # pid_path will be expanded with the working_dir
                start_command "./bin/delayed_job start -i #{i}"
                stop_command "./bin/delayed_job stop -i #{i}"
                daemonize false
                stdall "#{cwd}/log/dj.eye.log"
                start_timeout 30.seconds
                stop_timeout 30.seconds
            end
        end

    end

end
