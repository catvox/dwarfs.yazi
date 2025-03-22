# dwarfs.yazi
dwarfs plugin for yazi

## Installation

Plugin for Yazi to compression files with dwarfs. To install, run the below mentioned command:

```lua
ya pack -a catvox/dwarfs
```

## Usage

### Compression

For compession, add this to your keymap.toml:

```lua
[[manager.prepend_keymap]]
on = ["C","c"]
run = "plugin dwarfs --args='mkdwarfs dfs'"
desc = "Compress with dwarfs"

[[manager.prepend_keymap]]
on = ["C","m"]
run = "plugin dwarfs --args=dwarfs dfs"
desc = "Mount with dwarfs"

```

--args=dwarfs part tells the plugin that default extension filename is dwarfs. You can change that to whatever extension filename you want.
