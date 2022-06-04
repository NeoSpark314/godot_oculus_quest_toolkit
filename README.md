# Godot Oculus Quest Toolkit <!-- omit in toc --> 
This is an in-development toolkit for basic VR interactions using the Godot game engine.

The main target of this toolkit is native Oculus Quest development but it also supports WebXR export and DesktopVR (via the OpenVR and Oculus Godot modules) and most of the features are not platform specific.

You can try a Web-Exported version of the tookit at https://neospark314.itch.io/godot-oculus-quest-toolkit

The toolkit in this repository requires (at the time of writing) a recent version of Godot 3.4.

If you have questions or run into problems please open an issue here or contact me on discord.

There is a discord server specific for users of the toolkit. Feel free to join: https://discord.gg/JtTpFk9852

For general discussions about VR in godot you can also join the [official Godot Discord](https://discord.gg/zH7NUgz) #XR channel.

## Showcases
A list of links to projects and prototypes that use the Oculus Quest Toolkit that I'm aware of. If you are using the toolkit and would like to be here you can ping me or open an issue with a link to your project and I will add it.

| | | |
| -- | -- | -- |
|[![Voxel Works Quest](doc/images/showcase/voxel_works_quest.jpg)](https://sidequestvr.com/#/app/431) | [![Get Wood](doc/images/showcase/getwood.jpg)](https://globalgamejam.org/2020/games/get-wood-0) | [![Seurat TPS test](doc/images/showcase/seurat_tps_test.jpg)](https://www.youtube.com/watch?v=2RgMMeGQi2Q) |
|[![Seurat Capture](doc/images/showcase/seurat_capture.jpg)](https://www.youtube.com/watch?v=ikYTkyIMV8k) | [![Pipelines](doc/images/showcase/pipelines.jpg)](https://saoigames.itch.io/pipelines-quest) | [![Mawashi](doc/images/showcase/mawashi.jpg)](https://sidequestvr.com/#/app/460) |
|[![Blocks](doc/images/showcase/blocks.jpg)](https://kosmosschool.itch.io/blocks) | [![The Impossible Crypt](doc/images/showcase/impossible_crypt.jpg)](https://neospark314.itch.io/the-impossible-crypt)  | [![SpaceToys](doc/images/showcase/spacetoys.jpg)](https://github.com/ssj71/SpaceToys)|
| [![Fugitive](doc/images/showcase/fugitive.jpg)](https://wavesonics.itch.io/fugitive-3d) | [![NeonGunslingerVR](doc/images/showcase/neon_gunslinger_vr.jpg)](https://sidequestvr.com/app/2680)| [![JapaneseInANutshell](doc/images/showcase/japanese_in_a_nutshell.jpg)](https://sidequestvr.com/app/2519)|
| | | |

## Demo Scenes and Games
The toolkit contains several demo scenes in the [Demo Scene Folder](demo_scenes/) that can be inspected to see how the individual features work.

In addition there is also a more complete example in the [Demo Games Folder](dmeo_games/). It is a beat saber clone called BeepSaber; you can watch [a video here](https://www.youtube.com/watch?v=kg3yiwaphlk). This demo game now also exists as a fork (with some additions/improvements in its own repository at
[https://github.com/NeoSpark314/BeepSaber](https://github.com/NeoSpark314/BeepSaber))

[![BeepSaber Demo Video](doc/images/showcase/beepsaber.jpg)](https://www.youtube.com/watch?v=kg3yiwaphlk)

## Features
- Touch controller button handling and controller models
- 2D UI canvas with controller interaction and Virtual Keyboard
- Joystick locomotion and rotation (smooth and step)
- Rigid body grab
- Basic Player Collision
- Falling and Climbing logic

[![Feature Images](doc/images/feature_overview.jpg?raw=true)](https://youtu.be/-jzkHOum1kU)
![Feature Images 2](doc/images/feature_overview_2.jpg)

- Oculus Mixed Reality Capture Integration

[![Video of the Godot MRC Plugin in action](https://img.youtube.com/vi/LDKzn48-3cs/0.jpg)](https://www.youtube.com/watch?v=LDKzn48-3cs)

- Hand Tracking support with included hand models and basic gesture detection

[![Simple Hand Gestures](doc/images/hand_gestures.jpg?raw=true)](https://twitter.com/NeoSpark314/status/1213443646755934208)


- VR Simulator and VR Recorder (for easier testing on desktop)
- Several utilities to accelerate prototyping and debugging (Log, Labels, ...)
- Jog in Place detection

![Medieval City Test Scene](doc/images/medieval_city_screenshot.jpg?raw=true)


# Documentation
The documentation is in the [project wiki](https://github.com/NeoSpark314/godot_oculus_quest_toolkit/wiki). It includes
a more detailed getting started section and an overview of the included features.

## Known issues

As this is a very early version there are some known issues that are not yet resolved. If you know a solution feel free to open a github issue to further discuss it or catch me on the [official Godot Discord](https://discord.gg/zH7NUgz): @NeoSpark314.

- No shader precompilation/caching. This means there will be a **very** noticeable hiccup when new objects/materials are rendered for the first time (like showing the UI pointer or when transitioning scenes). This will be essential to resolve for actual applications!
- No mip-mapping for UI canvas (thus text looks very bad at some distance)


## Planned features

There are a lot of potential extensions and missing features. Some of the things I think I will tackle next are on this list; but if you have some other suggestions feel free to open an issue to discuss it.

- Jumping of ledges while climbing
- Grabbed objects
  - handing over objects
  - interaction trigger
- Improvements to the labeling system
- Physics interactors (levers, rotators, buttons, maybe doors)

# Credits
- The Medieval Town scene was created by fangzhangmnm: [Sketchfab Page](https://sketchfab.com/3d-models/medieval-town-a174a1449da345b8ab51308032587e71); released under [CC Attribution] (https://creativecommons.org/licenses/by/4.0/). The lightmap applied to the scene was baked in Blender.
- The Music Track used in the BeepSaber demo game is Time Lapse by TheFatRat (https://www.youtube.com/watch?v=3fxq7kqyWO8)


# Licensing
The Godot Oculus Quest Toolkit and the demo scenes in this repository are licensed under the MIT License. The Oculus Touch controller 3d models the hand model and the Oculus Mobile SDK contained in this repository are copyright Oculus, see http://oculus.com for license information.
The Roboto font used is licensed under an Apache License and available at https://github.com/google/roboto.
