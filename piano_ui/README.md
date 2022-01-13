# PianoUi

Typical running:
```
iex --name ui@192.168.1.4 --cookie fw_cookie -S mix
```

For single computer use:

```
iex --sname ui --cookie somecookie -S mix
```

With env vars:

    PIANO_UI_LIBCLUSTER_STRATEGY="local_epmd"
    PIANO_UI_CTL_NODE="ctl"

Old:
- iex --sname ui@localhost -S mix
- Then run: `Node.connect(:"fw@192.168.1.6")`

TODO:
- [ ] When you press play after everything has been paused overnight then the title and artist should display
- [ ] Add station switching
- [ ] Track play/pause 
