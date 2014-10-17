class ProjectsController < ApplicationController

  require 'rugged'
  require 'fileutils'
  include ProjectsHelper

  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
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
    FileUtils.mkdir_p("public/projects")
    dir = "public/projects/#{project_params[:name]}"
    repo = Rugged::Repository.clone_at(project_params[:git], dir)

    walker = Rugged::Walker.new(repo)
    puts "****************************************************************"
    
    # Sort by date; oldest -> newest
    walker.sorting(Rugged::SORT_DATE | Rugged::SORT_REVERSE)
    # walker.sorting(Rugged::SORT_DATE)

    # Reference head to point to correct branch
    walker.push(repo.head.target)

    walker.each do |c|
      t_dir = "public/project_revisions/#{project_params[:name]}/#{c.time}"
      FileUtils.mkdir_p(t_dir)
      FileUtils.cp_r(dir+"/.", t_dir)
      t_repo = Rugged::Repository.new(t_dir)
      t_repo.reset(t_repo.rev_parse_oid(c.oid), :hard)
    end
    walker.reset
    puts "****************************************************************"


    # Dir.glob(dir+"/**/*.rb") do | file |
    #   puts file
    # end
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
