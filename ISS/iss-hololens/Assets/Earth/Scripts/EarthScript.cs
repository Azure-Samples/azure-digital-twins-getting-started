/*
The MIT License(MIT)
Copyright(c) 2016 Digital Ruby, LLC
http://www.digitalruby.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

using UnityEngine;
using System.Collections.Generic;

namespace DigitalRuby.Earth
{
    [RequireComponent(typeof(MeshRenderer))]
    public class EarthScript : SphereScript
    {
        [Range(-1000.0f, 1000.0f)]
        [Tooltip("Rotation speed around axis")]
        public float RotationSpeed = 1.0f;

        [Tooltip("Planet axis in world vector, defaults to start up vector")]
        public Vector3 Axis;

        [Tooltip("The sun, defaults to first dir light")]
        public Light Sun;

        private MeshRenderer meshRenderer;
        private MaterialPropertyBlock materialBlock;

        private void OnEnable()
        {
            meshRenderer = GetComponent<MeshRenderer>();
            materialBlock = new MaterialPropertyBlock();
            Sun = (Sun == null ? Light.GetLights(LightType.Directional, -1)[0] : Sun);
            if (Axis == Vector3.zero)
            {
                Axis = transform.up;
            }
            else
            {
                Axis = Axis.normalized;
            }
        }

        protected override void Update()
        {
            base.Update();

            if (materialBlock != null && Sun != null && meshRenderer != null)
            {
                meshRenderer.GetPropertyBlock(materialBlock);
                materialBlock.SetVector("_SunDir", -Sun.transform.forward);
                materialBlock.SetVector("_SunColor", new Vector4(Sun.color.r, Sun.color.g, Sun.color.b, Sun.intensity));
                meshRenderer.SetPropertyBlock(materialBlock);
            }

#if UNITY_EDITOR

            if (Application.isPlaying)
            {

#endif

                transform.Rotate(Axis, RotationSpeed * Time.deltaTime);

#if UNITY_EDITOR

            }

#endif

        }
    }
}