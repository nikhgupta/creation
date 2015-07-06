class Thor::Shell::Color
  def notify message, options = {}
    old_mute = @mute
    @mute = false
    type  = options.fetch(:type, :info)
    color = options.fetch(:color, nil)
    title = options.fetch(:title, :creation)
    title = :creation if title.to_s.underscore == "base"
    color = :cyan if title == :creation

    color ||= case type.to_s.underscore.to_sym
              when :warn, :warning then :yellow
              when :success, :pass, :passed then :green
              when :alert, :fail, :failed, :failure then :red
              when :info, :task, :bundle, :commit then :magenta
              else :white
              end
    say_status title, "[#{type}]: #{message}", color
  ensure
    @mute = old_mute
  end
end
