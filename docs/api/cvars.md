# CVars / Configuration / Game Metadata (`args.cvars`)

Hash contains metadata pulled from the files under the `./metadata` directory. To get the keys that are available type `$args.cvars.keys` in the Console. Here is an example of how to retrieve the game version number:

```ruby
def tick args
  args.outputs.labels << {
    x: 640,
    y: 360,
    text: args.cvars["game_metadata.version"].value.to_s
  }
end
```

Each CVar has the following properties `value`, `name`, `description`, `type`, `locked`.

## Available Configuration

?> See `metadata/game_metadata.txt` and `metadata/cvars.txt` for detailed information of all the configuration values that are supported. The following table
is a high level summary of each value.

| File                           | Name                       | Values                                                                       | Description                                                                                                                                                  |
|--------------------------------|----------------------------|------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **metadata/cvars.txt**         | `webserver.enabled`        | `true` or `false` (default is `false`)                                       | Controls whether or not the in-game web server at `localhost:9001` is enabled in dev mode. The in-game web server is primarily needed for remote-hotloading. |
|                                | `webserver.port`           | Number representing a port (default is `9001`)                               | Port that the in-game web server runs on. For remote-hotloading, this value must be `9001`.                                                                  |
|                                | `webserver.remote_clients` | `true` or `false` (default is `false`)                                       | Controls whether or not remote connections to the in-game web server are allowed. Must be set to `true` for remote-hotloading.                               |
|                                | `renderer.background_sleep`| Number representing (default is `50`, set to `0` to disable)                 | Controls how long to wait before attempting to rendering the game when the game does not have focus (wasted CPU cycles rendering when the window isn't top). |
| **metadata/game_metadata.txt** | `devid`                    | String value                                                                 | Your Developer Id on Itch.io. |
|                                | `devname`                  | String value                                                                 | Developer name/studio name. |
|                                | `gameid`                   | String value                                                                 | Your Game Id on Itch.io |
|                                | `gametitle`                | String value                                                                 | The title of your game. |
|                                | `version`                  | String value                                                                 | `MAJOR`.`MINOR` Version number for your game. |
|                                | `icon`                     | String value                                                                 | Path to your game icon. |
|                                | `orientation`              | `landscape` or `portrait` (default is `landscape`)                           | Orientation for your game. |
|                                | `orientation_ios`          | `landscape` or `portrait`                                                    | Overrides the default orientation on iOS. This is a Pro feature. |
|                                | `orientation_android`      | `landscape` or `portrait`                                                    | Overrides the default orientation on Android. This is a Pro feature. |
|                                | `scale_quality`            | `0`, `1`, or `2` (default is `0`)                                            | Specifies the render scale quality for your game (0=nearest neighbor, 1=linear, 2=anisotropic/best). Full details of what each number means in `metadata/game_metadata.txt`. |
|                                | `ignore_directories`       | Comma delimited list of directories                                          | Directories to exclude when packaging your game. |
|                                | `packageid`                | String in reverse domain convention                                          | Android Package Id for your game. This is a Pro feature. |
|                                | `compile_ruby`             | `true` or `false` (default is `false`)                                       | Signifies if your game code will be compiled to bytecode during packaging. This is a Pro feature. |
|                                | `hd`                       | `true` or `false` (default is `false`)                                       | Whether your game will be rendered in HD. This is a Pro feature. |
|                                | `highdpi`                  | `true` or `false` (default is `false`)                                       | Whether your game will be rendered with High DPI. This is a Pro feature. |
|                                | `sprites_directory`        | String value                                                                 | The path that DR should search for HD texture atlases. This is a Pro feature. |
|                                | `hd_letterbox`             | `true` or `false` (default is `true`)                                        | Disables the letter box around your game. This is a Pro feature. |
|                                | `hd_max_scale`             | `0`, `100`, `125`, `150`, `175`, `200`, `250`, `300`, `400` (default is `0`) | Signifies the max scale of your game. `0` means size to fit (full details of what each number means in `metadata/game_metadata.txt`). |
| **metadata/ios_metadata.txt**  | `teamid`                   | String value                                                                 | Apple Team Id. This is a Pro feature. |
|                                | `appid`                    | String value                                                                 | Apple App Id. This is a Pro feature. |
|                                | `appname`                  | String value                                                                 | The name to show under the App icon. |
|                                | `devcert`                  | String value                                                                 | Apple Development Certificate name used to sign your game for local device deployment. This is a Pro feature. |
|                                | `prodcert`                 | String value                                                                 | Apple Distribution Certificate name used to sign your game release to the App Store. This is a Pro feature. |
