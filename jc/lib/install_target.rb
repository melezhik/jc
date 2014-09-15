class InstallTarget < Struct.new( :build, :list , :env, :async   )

    def run
        list.each do |t|
            build.log "run install for <#{t.name}>"
            cmd = []
            cmd << "cpanm -L #{build.dir}/cpanlib --mirror #{env[:cpan_mirror]} --mirror-only #{t.name} -v"
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
