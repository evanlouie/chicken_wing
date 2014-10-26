class ProjectsController < ApplicationController

  before_action :set_project, only: [:visualize, :show, :edit, :update, :destroy]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all
  end

  def visualize
    respond_to do |format|
      format.html do
        @project = {
            git: @project.git,
            name: @project.name,
            revisions: @project.revisions.map do |rev|
              {
                  commit_id: rev.commit_id,
                  epoch_time: rev.epoch_time,
                  human_time: rev.time,
                  items: rev.items.map { |item| {name: item.name, line_count: item.line_count, smell_count: item.smell_count}}
              }
            end
        }.to_json

        render :visualize, layout: "visualize"
      end
    end
  end
  # GET /projects/1
  # GET /projects/1.json
  def show
    respond_to do |format|
      format.html { render :show }
      format.json do
        project = {
            git: @project.git,
            name: @project.name,
            revisions: @project.revisions.map do |rev|
              {
                  commit_id: rev.commit_id,
                  epoch_time: rev.epoch_time,
                  human_time: rev.time,
                  # smells: rev.smells,
                  # items: rev.items.map { |item| {name: item.name, content: File.open(item.name).read, line_count: item.line_count, smell_count: item.smell_count}}
                  items: rev.items.map { |item| {name: item.name, line_count: item.line_count, smell_count: item.smell_count}}

              }
            end
        }
        render json: JSON.pretty_generate(project)
      end
    end
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
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
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
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
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.require(:project).permit(:git, :name)
  end
end
