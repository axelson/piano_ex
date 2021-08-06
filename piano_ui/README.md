# PianoUi

Typical running:
```
dotenv iex --name ui@192.168.1.4 --cookie fw_cookie -S mix
```

For single computer only use `iex --name "ui@jdesktop.localdomain" --cookie fw_cookie -S mix`

Then run: `Node.connect(:"fw@192.168.1.6")`

Old: iex --sname ui@localhost -S mix

TODO:
- [ ] When you press play after everything has been paused overnight then the title and artist should display
- [ ] Add station switching
- [ ] Track play/pause 
