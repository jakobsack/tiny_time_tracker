class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.tree(current_user.projects)
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @records = @project.records.order('begun_at DESC').paginate(page: params[:page])
  end

  # GET /projects/new
  def new
    @project = current_user.projects.build
    @projects = Project.tree(current_user.projects.reject {|p| p == @project})
  end

  # GET /projects/1/edit
  def edit
    @projects = Project.tree(current_user.projects.reject {|p| p == @project})
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = current_user.projects.build(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to projects_path, notice: _('Project was successfully created.') }
        format.json { render :show, status: :created, location: @project }
      else
        @projects = Project.tree(current_user.projects.reject {|p| p == @project})
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: _('Project was successfully updated.') }
        format.json { render :show, status: :ok, location: @project }
      else
        @projects = Project.tree(current_user.projects.reject {|p| p == @project})
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: _('Project was successfully destroyed.') }
      format.json { head :no_content }
    end
  end

  def kick_start
    @project = current_user.projects.build(project_params)
    @project.color = RGB::Color.from_rgb((rand * 256).to_i, (rand * 256).to_i, (rand * 256).to_i).to_rgb_hex
    @project.active = true

    unless @project.save
      format.html { redirect_to dashboard_projects_path, alert: _('Could not create project.') }
      format.json { render json: @project.errors, status: :unprocessable_entity }
      return
    end

    Record.close_last_record_for(current_user.id)
    @record = @project.records.build
    @record.user = current_user
    @record.begun_at = Time.now
    @record.save!

    respond_to do |format|
      if @record.save
        format.html { redirect_to dashboard_projects_path }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { redirect_to dashboard_projects_path, alert: _('Could not create new record.') }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def dashboard
    @open_record = current_user.open_record
    @projects = Project.tree(current_user.projects)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = current_user.projects.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:name, :color, :parent_id, :active)
    end
end
