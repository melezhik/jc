class InstallAsync < Struct.new( :build, :dist, :env   )


    def perform

        dist.update( :status => 'DJ_PERFORM'  )
        runner = RunInstall.new build, dist, env, self
        runner.run 

    end

    def before(job) 
        log "scheduled async install build ID: #{build.id}. dist name: #{dist.name} env: #{env}"
        dist.update( :status => 'DJ_BEFORE'  )
        dist.save!
    end

    def after(job)
        log "finished async install dist name: #{dist.name}"
    end

    def success(job)
        log "succeeded async install dist name: #{dist.name}"
        stat.update( :status => 'DJ_OK'  )
        stat.save!
    end


    def error(job, ex)
        log  "failed async install dist name: #{dist.name}"
        log  "#{ex.class} : #{ex.message}"
        log   ex.backtrace
        dist.update( :status => 'DJ_ERROR'  )
        dist.save!
    end

    def failure(job)
    end

    def max_attempts
        return 1
    end

end
