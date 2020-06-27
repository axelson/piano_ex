

pianobar -> input.pipe <- PianoCtl.PianoInputReader
                      reads         |
                                    v
                               PianoCtl.Server -> PianoUi

To test:

    ./test-example.sh

## TODO

- [x] Change PianoParser to be able to accurately detect events
- [x] Display the current song in the scenic scene
- [x] Nodes should be configured from config
- [x] Fetch and display cover art
- [x] write the OS pid to `~/.config/pianobar/piano_ctl_pid`
- [x] command.sh should check the pid, and only write to the pipe if the process is still running
- [ ] Add play/pause and next buttons
- [ ] Extract text into a separate scene
- [x] PianoCtl.CommandRunner is broken
- [ ] Find a good name for the Splash scene
- [ ] Use PianoCtl.PipeReader to avoid blocking input/output
  - Will require re-writing some of the input parsing

## EventCmd format

```
event_name   # The event name
             # An empty line
attr1=val1   # A list of attrs
attr2=val2
attr2=val2
attr2=val2
             # Another empty line
```

Examples:

songstart

<song starting details>

// time passes
songfinish
<song finished details>

stationfetchplaylist
<fetched song>

songstart
<song starting details>

# Attributions

* pause play by Darrin Loeliger from the Noun Project
* Next by SBTS from the Noun Project
* stop button by Rizky Mapat Waluya from the Noun Project
* play by RAAJA from the Noun Project
