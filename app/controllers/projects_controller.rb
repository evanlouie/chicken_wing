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
    @project.name = @project.git.match(/(?:.(?!\/))+$/)[0].match(/.*[^\.git]/)[0].match(/[^\/].*/)[0]
    @project.dir = "public/project_revisions/#{project_params[:name]}"

    tmp_dir = "public/projects"
    FileUtils.mkdir_p(tmp_dir)
    dir = "public/projects/#{@project.id}"
    repo = Rugged::Repository.clone_at(project_params[:git], dir)

    walker = Rugged::Walker.new(repo)
    walker.sorting(Rugged::SORT_DATE | Rugged::SORT_REVERSE)    # Sort by date; oldest -> newest
    walker.push(repo.head.target)    # Reference head to point to correct branch

    walker.each do |c|
      t_dir = "public/project_revisions/#{@project.id}/#{c.oid}"
      FileUtils.mkdir_p(t_dir)
      FileUtils.cp_r(Dir.glob(dir+"/**"), t_dir) # Use Dir.glob so we don't copy the .git folder
      puts "Rubocop scanning commit: #{c.oid}"
      rev = @project.revisions.new({time: c.time, epoch_time: c.epoch_time, commit_id: c.oid, dir: t_dir, smells: Hash[JSON.parse(%x{rubocop --format json #{t_dir}})["files"].collect { |file| [ file["path"], file["offenses"].length ]}]})
      Dir.glob(t_dir+"/**/*") do |file|
        if File.file?(file)
          count = %x{sed -n '=' #{file} | wc -l}.to_i # System call for line count -> much faster than ruby
          rev.items.new({name: file, line_count: count, smell_count: rev.smells[file] || 0 })
        end
      end

      repo.reset(c.oid, :hard)
    end
    walker.reset
    FileUtils.rm_rf(tmp_dir)

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
