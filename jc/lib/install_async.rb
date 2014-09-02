class InstallAsync < Struct.new( :build, :list , :env   )

    def perform
        runner = InstallTarget.new build, list, env, self
        list.each do |t|
                t.update :state => 'install'
                t.save!
        end
        runner.run 
    end

    def before(job) 
        build.log "env: #{env}"
        build.log "perl5lib: #{ENV['PERL5LIB']}"
        build.log "scheduled async install"
    end

    def after(job)
        build.log "finished async install"
    end

    def success(job)
        build.log "succeeded async install"
    end


    def error(job, ex)
        build.log  "failed async install"
        build.log  "#{ex.class} : #{ex.message}"
        build.log   ex.backtrace
    end

    def failure(job)
    end

    def max_attempts
        return 1
    end

end
