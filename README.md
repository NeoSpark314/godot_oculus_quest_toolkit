# Godot Oculus Quest Toolkit <!-- omit in toc --> 
This is an early alpha version of a toolkit for basic VR interactions with the Oculus Quest using the Godot game engine.
The toolkit in this repository requires (at the time of writing) a recent version of Godot 3.2 alpha.
If you have questions or run into problems please open an issue here or contact me at the [official Godot Discord](https://discord.gg/zH7NUgz): @NeoSpark314 or in the #XR channel.


## Table of contents <!-- omit in toc --> 
- [Features (so far... early alpha)](#features-so-far-early-alpha)
- [Running the included demos](#running-the-included-demos)
- [A note about performance](#a-note-about-performance)
- [Toolkit design and usage](#toolkit-design-and-usage)
  - [Basic setup](#basic-setup)
- [OQ_Toolkit feature documentation](#oq_toolkit-feature-documentation)
  - [vr_autoload.gd](#vr_autoloadgd)
  - [QO_ARVROrigin](#qo_arvrorigin)
  - [QO_ARVRCamera](#qo_arvrcamera)
  - [OQ_ARVRController](#oq_arvrcontroller)
  - [OQ_UI2D](#oq_ui2d)
  - [OQ_Helpers](#oq_helpers)
- [Known issues](#known-issues)
- [Planned features](#planned-features)
- [Licensing](#licensing)


## Features (so far... early alpha)
- Touch controller button handling and controller models
- Joystick locomotion and rotation
- 2D UI canvas with controller interaction
- Simple climbing
- Rigid body grab
- VR Simulator (for easier testing on desktop)

[![Feature Images](doc/images/feature_overview.jpg?raw=true)](https://youtu.be/-jzkHOum1kU)

A video of some of the alpha features can be seen [on youtube here](https://youtu.be/-jzkHOum1kU).

## Running the included demos
For convenience this repo includes already prebuild version of the 
godot oculus mobile plugin ([Godot Oculus Mobile](https://github.com/GodotVR/godot_oculus_mobile))
and  an android debug package. The included demo scene is directly exportable without
any modifications needed.
You need to use a recent build of Godot 3.2 alpha.  Prebuild alpha versions can be downloaded form [https://hugo.pro/projects/godot-builds/](https://hugo.pro/projects/godot-builds/).
You then need to have adb and jarsigner setup inside Godot->Editor->Editor Settings->Export->Android ([details can be found here](https://docs.godotengine.org/en/latest/getting_started/workflow/export/exporting_for_android.html)), connect your Quest to your PC and press the deploy button:

![deploy](doc/images/godot_deploy_to_android.jpg?raw=true)


## A note about performance
The Oculus Quest uses a mobile chip for rendering, has a high resolution display and needs to render the scene for each eye.
It is thus severely limited in it's computational power. Performance if of utmost importance for VR and having a stable framerate is essential!

I would **strongly** suggest to **always** use a tool like the [OVR Metrics Tool](https://developer.oculus.com/documentation/quest/latest/concepts/mobile-ovrmetricstool/) and check the current framerate (and other stats) during development. This is how the OVR Metrics tool looks inside the Quest when running:

![ovr_metrics](doc/images/ovr_metrics_tool.jpg?raw=true)

Even a minor change (like a transparent UI element) might heavily impact the performance and result in an unplayable application/game. These things are hard to find after several changes occurred and extremely time consuming to track down. 

Two talks on YouTube from OC5 that provide a good introduction to performance on Quest are [Porting Your App to Oculus Quest](https://www.youtube.com/watch?v=JvMQUz0g_Tk) and [Reinforcing Mobile Performance with RenderDoc](https://www.youtube.com/watch?v=CQxkE_56xMU).


## Toolkit design and usage
The idea of this toolkit is to provide each feature as a .scn file in the [OQ_Toolkit/](OQ_Toolkit/)
folder that can be used via drag-n-drop on the approriate base node in the scene.
Examples of how these .scn files can be used can be found in the [demo_scenes/](demo_scenes/) folder.

### Basic setup
The glue logic of the nodes depends on a single global autoload and requires to use the
provided `OQ_ARVROrigin.tscn, OQ_ARVRCamera.tscn, OQ_LeftController.tscn, OQ_RightController.tscn`
to be used instead of the ARVR base classes. The steps for a simple setup in your own scene are

1. copy the `OQ_Toolkit` folder and the `addons` folder to your project.
2. Under Project->Project Settings->AutoLoad add `OQ_Toolkit/vr_autload.gd` with the name *vr*.
3. Setup in you main scene the ARVR nodes (via drag and drop) as:
   - SceneRoot
     - OQ_ARVROrigin
       - OQ_ARVRCamera
       - OQ_LeftController
       - OQ_RightController

4. In your main `_ready()` function call
   ```
   func _ready():
	vr.initialize();
    ```

To add now features to the individual nodes the subfolders in the `OQ_Toolkit/` folder contain scripts
that can be added via drag and drop to the respective ARVR nodes in your scene.

This is an example of the physics demo scene running on desktop using the `QO_ARVROrigin/Feature_VRSimulator.tscn` node. You can see the feature setup in the scene tree on the left:
![simulator_example](doc/images/simulator_example.jpg?raw=true)

## OQ_Toolkit feature documentation
This is a short overview of the available nodes in the OQ_Toolkit. The best place to see the nodes in action is to have a look at the example scenes in [demo_scenes/](demo_scenes/).

### vr_autoload.gd
This file needs to be registers as an autoload with the global name `vr` in your project. It contains the `vr.intialize()` function that needs to be called on application start and also is used as the central place to sync between features.

It contains some global helper functions and enums.

Log functions (that store the messages for in-game display on an `OQ_UI2D/OQ_UI2DLogWindow`)
- `vr.log_info(string)`
- `vr.log_warning(string)`
- `vr.log_error(string)`

Controller access helper functions:
- `vr.BUTTON`: enum for left and right controller buttons
- `vr.get_controller_axis(vr.BUTTON)`
- `vr.button_pressed(vr.BUTTON)`
- `vr.button_just_pressed(vr.BUTTON)`
- `vr.button_just_released(vr.BUTTON)`
- `vr.AXIS`: enum for left and right controller axis
- `vr.get_controller_axis(vr.AXIS)`

Some wrapper functions around the Oculus VrAPI (to be extended in the future):
- `vr.get_supported_display_refresh_rates()`
- `vr.set_display_refresh_rate(value)`
- `vr.get_boundary_oriented_bounding_box()`
- `vr.get_tracking_space()`

### QO_ARVROrigin
The OQ_ARVROrigin is the place where anything related to player movement needs to take place.

**Feature_Climbing.tscn**:
In combination with the `OQ_ARVRController/Feature_StaticGrab.tscn` it allows to climb by moving the origin relative to the grab position.

**Feature_Falling.tscn**:
If the player is above the ground and not fixed by a `OQ_ARVRController/Feature_StaticGrab.tscn` it will
move the player downwards.

**Feature_VRSimulator.tscn**:
Adding this to your scene allows to interact/change the ARVROrigin and ARVRCamera and ARVRController
via keyboard commands to allow some basic testing of functionality without the need to deploy to
the Oculus Quest. This will be ignored when the variable `vr.inVR` is true and thus does not need to be removed when running on oculus quest.

**Locomotion_Stick.tscn**:
Moves and/or rotates the origin based on joystick input.

### QO_ARVRCamera
Nothing here yet (planned is fade to black and movement vignette...)

### OQ_ARVRController

**Feature_ControllerModel_Left/Right.tscn**: A model of the Oculus Touch Controller..

**Feature_StaticGrab.tscn**: a basic indicator that something grabable has been grabbed. This is used by the  
`QO_ARVROrigin/Feature_Climbing.tscn` for example.

**Feature_RigidBodyGrab.tscn**: simple logic to grab any rigid body with a controller and release it again.
Uses at the moment only velcoity based tracking. It allows basic physics interaction but
introduces one physics-frame of delay an will get unstable if there is too much penetration.

**Feature_UIRayCast.tscn**: A RayCast with a visible representation that allows to interact with a `OQ_UI2D/OQ_UI2DCanvas.tscn`


### OQ_UI2D
**OQ_UI2DCanvas.tscn**: A world space quad that will render a Control child onto it's surface and contains the logic to interact with a `OQ_ARVRController/Feature_UIRayCast.tscn`.
Important Note: At runtime the child Control will be re-parented under the canvas. So if you need to access control nodes from code you need to use `find_node(...)` and can not rely
on an absolute node path.

**OQ_UI2DLabel_IPD.tscn**: A `OQ_UI2DLabel` with a script attached that checks and displays the current IPD

**OQ_UI2DLabel.tscn**: A world space label to show static text.

**OQ_UI2DLogWindow.tscn**: A world space quad that will show the text log messages that were printed using the `vr.log_info(str)`, `vr.log_warning(str)` and `vr.log_error(str)` functions.

**OQ_UI2DVRSettings.tscn**: A helper dialog that exposes some VR settings for easy change at runtime. The intended use-case is to be able to check the impact of 
(performance) settings live fixed foveated rendering at runtime. Best attached as a child to a controller to have it available where needed.

### OQ_Helpers
**OQ_VisibilityToggle.tscn**: A node that will toggle the visibility of it's child based on a controller button. Use this
for example to show/hide a UI element attached to a controller.

**OQ_SplashScreen.tscn**: A Godot logo splash screen (always make sure to advertise Godot at the beginning of your app :-)


## Known issues

As this is a very early version there are some known issues that are not yet resolved. If you know a solution feel free to open a github issue to further discuss it or catch me on the [official Godot Discord](https://discord.gg/zH7NUgz): @NeoSpark314.

- No shader precompilation/caching. This means there will be a **very** noticeable hiccup when new objects/materials are rendered for the first time (like showing the UI pointer or when transitioning scenes). This will be essential to resolve for actual applications!
- No mip-mapping for UI canvas (thus text looks very bad at some distance)


## Planned features

There are a lot of potential extensions and missing features. Some of the things I think I will tackle next are on this list; but if you have some other suggestions feel free to open an issue to discuss it.

- Teleport movement option
- Jumping of ledges while climbing
- Grabbed objects
  - more grab-follow modes (like kinematic body)
  - handing over objects
  - interaction trigger
- Improvements to the labeling system
- Physics interactors (levers, rotators, buttons, maybe doors)
- Fade to black for scene transitions
- Movement vignette



## Licensing
The Godot Oculus Quest Toolkit and the demo scenes in this repository are licensed under an MIT License. The Oculus Touch controller 3d models and the Oculus Mobile SDK contained in this repository are copyright Oculus, see http://oculus.com for license information.
The Roboto font used is licensed under an Apache License and available at https://github.com/google/roboto.