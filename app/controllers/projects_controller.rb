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
                  items: rev.items.map { |item| {name: item.name, content: File.open(item.name).read}}
              }
            end
        }
        # render json: JSON.pretty_generate(JSON.parse(@project.to_json(include: [revisions: {include: :items}])))
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
    tmp_dir = "public/projects"
    FileUtils.mkdir_p(tmp_dir)
    dir = "public/projects/#{project_params[:name]}"
    repo = Rugged::Repository.clone_at(project_params[:git], dir)

    walker = Rugged::Walker.new(repo)
    puts "****************************************************************"

    walker.sorting(Rugged::SORT_DATE | Rugged::SORT_REVERSE)    # Sort by date; oldest -> newest
    walker.push(repo.head.target)    # Reference head to point to correct branch

    revisions = []

    walker.each do |c|
      t_dir = "public/project_revisions/#{project_params[:name]}/#{c.oid}"
      FileUtils.mkdir_p(t_dir)
      FileUtils.cp_r(Dir.glob(dir+"/**"), t_dir) # Use Dir.glob so we don't copy the .git folder
      rev = Revision.new({time: c.time, epoch_time: c.epoch_time, commit_id: c.oid})
      rev.save
      revisions << rev
      Dir.glob(t_dir+"/**/*") do |file|
        if File.file?(file)
          count = %x{sed -n '=' #{file} | wc -l}.to_i
          # Item.new({name: file, content: File.open(file).read, revision: rev, line_count: count, smell_count: rand(0..1000)}).save
          Item.new({name: file, revision: rev, line_count: count, smell_count: rand(0..1000)}).save

        end
      end
      repo.reset(c.oid, :hard)
    end
    walker.reset
    puts "****************************************************************"
    FileUtils.rm_rf(tmp_dir);

    # Dir.glob(dir+"/**/*.rb") do | file |
    #   puts file
    # end
    @project = Project.new(project_params)
    @project.dir = "public/project_revisions/#{project_params[:name]}"

    respond_to do |format|
      if @project.save
        revisions.each { |r| r.update({project_id: @project.id}) }
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
