

pianobar -> input.pipe <- PianoCtl.PianoInputReader
                      reads         |
                                    v
                               PianoCtl.Server -> PianoUi

To test:

    ./test-example.sh

## TODO

- [x] Change PianoParser to be able to accurately detect events

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
