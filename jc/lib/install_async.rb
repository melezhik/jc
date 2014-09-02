class InstallAsync < Struct.new( :build, :list , :env   )

    def perform
        #runner = RunInstall.new build, dist, env, self
        #runner.run 
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
