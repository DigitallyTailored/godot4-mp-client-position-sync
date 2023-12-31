﻿# godot4-mp-client-position-sync

I recently started trying out the MultiplayerSpawner and MultiplayerSynchronizer nodes as I wanted to simplify my networking code for my project which was originally done entirely with RPCs: https://devanew.com/

As others have pointed out, the docs are a little lacking for this particular feature. I did, however, find some great information in the original merge request https://github.com/godotengine/godot/pull/62961#issuecomment-1184677418 and this one too https://github.com/godotengine/godot/pull/68678

One of the comments in the MR includes a demo where visibility of connected peers can be controlled by the server, which sounds great, but if you try it out, you'll notice that on the client side there is noticeable lag and jumpiness as the demo is sending control inputs to the server and the server is sending an updated position to all clients.

To get around this, I spent the last few weeks (on and off admittedly) trying to keep the server as the authority while having the clients be in control of their own position and last night I finally figured it out! I've put my code here which is a modified version of the 2D example provided in the original MR. Apart from being in 3D, the visibility code is actually unchanged. https://github.com/DigitallyTailored/godot4-mp-client-position-sync

My demo also includes an example of AI players (spheres) which are controlled by the server to move around randomly.
 
![Screenshot 2023-09-23 035327](https://github.com/DigitallyTailored/godot4-mp-client-position-sync/assets/13086157/674bc828-538a-4072-aa7f-bcfdf83d1ae3)

Small video:

https://github.com/DigitallyTailored/godot4-mp-client-position-sync/assets/13086157/e42061c3-0171-4b60-b859-13cde2044687

