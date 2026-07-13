defmodule PianoCtl.Notifier do
  @template_path Path.join([__DIR__, "templates", "command.sh.eex"])
  @external_resource @template_path
  @template File.read!(@template_path)

  def create_script do
    content = EEx.eval_string(@template)
    path = PianoCtl.Config.event_command_path()
    File.write!(path, content)
    File.chmod!(path, 0o775)
  end
end
