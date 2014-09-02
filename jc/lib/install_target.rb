class InstallTarget < Struct.new( :build, :list , :env, :async   )

    def run
        list.each do |t|
            build.log "run install for <#{t.name}>"
            cmd = []
            cmd << "cpanm -l #{build.dir}/cpanlib --mirror #{env[:cpan_mirror]} --mirror-only #{t.name} -q"
            cmd_str = build.cmd_str cmd 
            build.log "run command: #{cmd_str}"
            if system(cmd_str) == true
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
