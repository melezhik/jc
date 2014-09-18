class InstallTarget < Struct.new( :build, :list , :env, :async   )

    def run

        if File.exist?"#{Dir.home}/.jc/hooks/pre.hook"
            build.log "running pre hook:"
            File.open("#{Dir.home}/.jc/hooks/pre.hook").each do |l|
                build.log l
            end
            unless build.execute_cmd([ "cd #{build.dir}", "#{Dir.home}/.jc/hooks/pre.hook"], false) == true
                t.update :state => 'failed'
                t.save!
                raise "pre hook execution failed"
            end
        end

        list.each do |t|

            build.log "run install for <#{t.name}>"
            cmd = Array.new
            cmd << "cpanm -l #{build.dir}/cpanlib --mirror #{env[:cpan_mirror]} --mirror-only #{t.name}"
            if build.execute_cmd(cmd, false) == true
                build.log  "target <#{t.name} installed ok>"
                t.update :state => 'ok'
                t.save!
            else
                build.log  "target <#{t.name} failed>"
                t.update :state => 'failed'
                t.save!
            end
    
        end
    end

end
