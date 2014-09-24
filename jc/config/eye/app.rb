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

	if ENV['RAILS_ENV'] == 'production'
		env 'SECRET_KEY_BASE' => 'jc'
	end	


        start_command "puma -C config/puma.rb -d --pidfile #{cwd}/tmp/pids/server.pid"
        daemonize false

        stdall "#{cwd}/log/api.eye.log"
        start_timeout 10.seconds
        stop_timeout 10.seconds

    end

    group 'dj' do

        workers = (ENV['dj_workers']||'2').to_i
        (1..workers).each do |i|
            process "dj#{i}" do

                stdall "#{cwd}/log/dj.eye.log"

                pid_file "tmp/pids/delayed_job.#{i}.pid" # pid_path will be expanded with the working_dir
                start_command 'rake jobs:work'
                daemonize true

                env 'PERL5LIB' => "#{ENV['HOME']}/perl5/lib/perl5:/usr/local/rle/lib/perl5"
                env 'http_proxy' => 'http://squid.adriver.x:3128'
                env 'https_proxy' => 'http://squid.adriver.x:3128'
                env 'HTTP_PROXY' => 'http://squid.adriver.x:3128'
                env 'HTTPS_PROXY' => 'http://squid.adriver.x:3128'
                env 'no_proxy' => 'localhost,127.0.0.1,10.0.0.0,.x,0'

            end
        end

    end

end
