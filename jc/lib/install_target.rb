class InstallTarget < Struct.new( :build, :list , :env, :async   )

    def run
        list.each do |t|
            build.log "run install for <#{t.name}>"
        end
    end

end
