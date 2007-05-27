#
#  This file is part of the Jikes RVM project (http://jikesrvm.org).
#
#  This file is licensed to You under the Common Public License (CPL);
#  You may not use this file except in compliance with the License. You
#  may obtain a copy of the License at
#
#      http://www.opensource.org/licenses/cpl1.0.php
#
#  See the COPYRIGHT.txt file distributed with this work for information
#  regarding copyright ownership.
#
class TestRunController < ApplicationController
  verify :method => :get, :only => [:show, :show_summary, :list], :redirect_to => {:action => :index}
  verify :method => :post, :only => [:destroy], :redirect_to => {:action => :index}
  caches_page :show, :show_summary
  cache_sweeper :test_run_sweeper, :only => [:destroy]
  session :off, :except => [:new, :destroy]

  def new
    raise AuthenticatedSystem::SecurityError unless (is_authenticated? and current_user.uploader?)
    @record = TestRunUpload.new(params[:record])
    if request.post?
      if @record.valid?
        tmp_dir = "#{SystemSetting['tmp.dir']}/uploads"
        FileUtils.mkdir_p(tmp_dir) unless (File.exist?(tmp_dir) and File.directory?(tmp_dir))
        base_file = @record.data.original_filename.gsub(/^.*(\\|\/)/, '').gsub(/[^\w._-]/,'')
        filename = "#{tmp_dir}/#{Time.now.usec}_#{session.id}_#{base_file}"
        file = File.open(filename, File::CREAT|File::TRUNC|File::RDWR)
        file.write(@record.data.read)
        file.close
        begin
          @test_run = TestRunBuilder.create_from(@record.host, filename, current_user, Time.now)
          TestRunTransformer.build_olap_model_from(@test_run) if @test_run
        ensure
          File.delete(filename)
        end
        if @test_run
          flash[:notice] = "#{@test_run.label} was successfully created."
          redirect_to(:action => 'show', :id => @test_run.id)
        end
      end
    end
  end

  def show
    @record = TestRun.find(params[:id])
  end

  def show_summary
    @record = TestRun.find(params[:id])
  end

  def destroy
    raise AuthenticatedSystem::SecurityError unless is_authenticated?
    @record = TestRun.find(params[:id])
    raise AuthenticatedSystem::SecurityError unless (current_user.admin? or (current_user.uploader? and current_user.id == @record.uploader_id))
    flash[:notice] = "#{@record.label} was successfully deleted."
    @record.destroy
    redirect_to(:controller => '/host', :action => 'show', :id => @record.host_id)
  end
end
