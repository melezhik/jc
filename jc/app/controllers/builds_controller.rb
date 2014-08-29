require 'fileutils'
class BuildsController < ApplicationController

    def index 
        render :text => "hello world\n"
    end

    def new
        @report = Build.new
    end

    def create

        @build = Build.new _params

        logger.info "create build ID: #{@build.id}. key:#{_params[:key_id]} created ok"
    
        @build.save!


        FileUtils.mkdir_p "#{Dir.home}/.jc/builds/#{_params[:key_id]}"
        render :text => "build ID: #{@build.id}. key:#{_params[:key_id]} created ok\n"

    end

private

    def _params
        params.require(:build).permit( 
            :key_id
        )
    end

end
