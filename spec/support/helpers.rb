module CreationTestHelpers
  APP_NAME = "dummy_app"

  def create_tmp_directory
    FileUtils.mkdir_p(tmp_path)
  end

  def remove_project_directory
    FileUtils.rm_rf(project_path)
  end

  def project_path *path
    @project_path ||= tmp_path.join(APP_NAME)

    return @project_path if path.blank?
    @project_path.join(*path.flatten.join("/").split("/"))
  end

  def inside_project_bundle &block
    Dir.chdir(project_path) do
      Bundler.with_clean_env do
        yield
      end
    end
  end

  def run_creation(arguments = nil)
    Dir.chdir(tmp_path) do
      Bundler.with_clean_env do
        command = "new #{APP_NAME} #{arguments}".strip
        puts "\e[35m  => running: creation #{command}\e[0m (can be a bit slow)"
        %x(#{creation_binary} #{command})
      end
    end
  end

  private

  def tmp_path
    @tmp_path ||= root_path.join("tmp")
  end

  def creation_binary
    root_path.join("exe", "creation")
  end

  def root_path
    Pathname.new(__FILE__).parent.parent.parent
  end
end
