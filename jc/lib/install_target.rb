class InstallTarget < Struct.new( :build, :list , :env, :async   )

    def run
        list.each do |t|

            if File.exist?"#{Dir.home}/.jc/hooks/pre.hook"
                build.log "running pre hook"
                unless build.execute_cmd(["#{Dir.home}/.jc/hooks/pre.hook"], false) == true
                    t.update :state => 'failed'
                    t.save!
                    raise "pre hook execution failed"
                end
            end

            build.log "run install for <#{t.name}>"
            cmd = []
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
