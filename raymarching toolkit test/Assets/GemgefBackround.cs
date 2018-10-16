using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GemgefBackround : MonoBehaviour {

    public GemgefParameters pars;
    public Material material;
    public Light light;
    public string[] properties;
    public Vector2[] speeds;
    private Vector2[] offsets;
    // Use this for initialization
    void Start () {
        material = GetComponent<Renderer>().material;
        properties = material.GetTexturePropertyNames();
        offsets = new Vector2[speeds.Length];
    }



    // Update is called once per frame
    void Update () {

        light.color = Color.Lerp(light.color, Color.HSVToRGB(pars.SL09HHintergrundfarbe, pars.SL09SHintergrundfarbe, pars.SL09BHintergrundfarbe),pars.smoothFactor0to1);
        for (int i = 0; i < properties.Length; i++)
        {
            if(properties[i]!= null && speeds[i]!= null && speeds[i].magnitude>0)
            {
                offsets[i] += speeds[i] * Time.deltaTime;
                material.SetTextureOffset(properties[i], offsets[i]);
            }
        }
      
    }
}
