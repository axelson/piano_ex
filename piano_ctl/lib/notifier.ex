defmodule PianoCtl.Notifier do
  def create_script do
    content = EEx.eval_file(template_path())
    path = "#{System.fetch_env!("HOME")}/.config/pianobar/command.sh"
    File.write!(path, content)
    File.chmod!(path, 0o775)
  end

  def template_path, do: Path.join([__DIR__, "templates", "command.sh.eex"])
end
