class Project
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic


  embeds_many :revisions

  field :git
  field :name
  field :dir

  validates :git, presence: true
  validates :name, presence: true
  validates :dir, presence: true

  before_validation :set_name, :set_dir
  before_save :clone_repo
  before_destroy :del_dir

  protected

  require 'rugged'
  require 'fileutils'
  require 'rubocop'

  def set_name
    # self.name = self.git.match(/(?:.(?!\/))+$/)[0].match(/.*[^\.git]/)[0].match(/[^\/].*/)[0] # Project is named after git repository

    unless git.nil?
      match =git.match(/\w+\.\w+$/)
      if match.nil?
        self.name ||= self.git
      else
        self.name ||= match[0]
      end
    end

  end

  def set_dir
    self.dir = "public/project_revisions/#{self.id}"
  end

  def del_dir
    FileUtils.rm_rf(self.dir)
  end

  def clone_repo
    tmp_dir = "public/projects"
    FileUtils.mkdir_p(tmp_dir)
    dir = "public/projects/#{self.id}"
    repo = Rugged::Repository.clone_at(self.git, dir)
    walker = Rugged::Walker.new(repo)
    walker.sorting(Rugged::SORT_DATE | Rugged::SORT_REVERSE) # Sort by date; oldest -> newest
    walker.push(repo.head.target) # Reference head to point to correct branch

    threads = []
    walker.each do |c|
      t_dir = "public/project_revisions/#{self.id}/#{c.oid}"
      FileUtils.mkdir_p(t_dir)
      FileUtils.cp_r(Dir.glob(dir+"/**"), t_dir) # Use Dir.glob so we don't copy the .git folder
      puts "Rubocop scanning commit: #{c.oid}"
      threads << Thread.new {
        # rev = self.revisions.new({time: c.time, epoch_time: c.epoch_time, commit_id: c.oid, dir: t_dir, smells: Hash[JSON.parse(%x{rubocop --format json #{t_dir}})["files"].collect { |file| [file["path"], file["offenses"].length] }]})

        file_loc = "#{t_dir}/smells.json"
        # smells = with_captured_stdout { RuboCop::CLI.new.run(["--format", "json", "--output", file_loc, t_dir]) }
        RuboCop::CLI.new.run(["--format", "json", "--out", file_loc, t_dir])
        json = JSON.parse(IO.read(file_loc))
        rev = self.revisions.new({time: c.time, epoch_time: c.epoch_time, commit_id: c.oid, dir: t_dir, smells: Hash[json["files"].collect { |file| [file["path"], file["offenses"].length] }]})

        root = Dir.pwd
        Dir.glob(t_dir+"/**/*") do |file|
          if File.file?(file)
            count = %x{sed -n '=' #{file} | wc -l}.to_i # System call for line count -> much faster than ruby
            rev.items.new({name: file, trackable_name: file.match(/#{c.oid.to_s}\/.*/)[0].gsub(c.oid.to_s, ''), line_count: count, smell_count: rev.smells[file] || 0})
          end
        end
      }
      repo.reset(c.oid, :hard)
    end
    walker.reset
    threads.each { |thr| thr.join }
    FileUtils.rm_rf(tmp_dir)
  end

  private
  def with_captured_stdout
    begin
      old_stdout = $stdout
      $stdout = StringIO.new('', 'w')
      yield
      $stdout.string
    ensure
      $stdout = old_stdout
    end
  end
end
