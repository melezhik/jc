class BuildsController < ApplicationController

    def index 
        render :text => "hello world\n"
    end

    def new
        @report = Build.new
    end

    def create
        @build = Build.new _params
        @build.save!
        render :text => "build ID: #{@build.id}. key:#{params[:key]} created ok\n"
    end

private

    def _params
        params.require(:build).permit( 
            :key_id
        )
    end

end
