Earth Model for Unity
(c) 2016 Digital Ruby, LLC
Created by Jeff Johnson

Licensed under the MIT license

Version: 1.1.2

Instructions:
- Set linear color space in player settings.
- Drag the Earth prefab into your scene.
- Setup the material properties on EarthMaterial, or clone to make your own planets by changing out the textures and tweaking the properties.
- Make sure you have at least one dir light in the scene, or set the Sun property on the earth script.
- Setup the earth script with an axis to rotate around, or leave as 0, 0, 0 to rotate around the initial up vector.
- Done!

Details:
I created this Earth asset in my spare time for use in prototyping space sims, and because I needed a dynamic sphere generator of better quality than Unity's default sphere. Plus I wanted an Earth with a separate cloud layer.

You should be able to make any planet you want simply by changing the materials for the earth main object and cloud layer object.

The sphere creation script defaults to IcoSphere which looks better, especially at the poles. For other non-planet cases you may have better luck with non-ico sphere. You don't have to do anything as these work automatically during design time and are stripped out in the final build.

I hope you enjoy this asset. Feel free to include it in your own assets, games and source code. Please just retain the MIT license in the script file and add a credit in your readme or asset description that links back to this asset. Thank you!

- Jeff