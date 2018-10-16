using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GemgefBackround : MonoBehaviour {

    public GemgefParameters pars;
    public Renderer quadfront;
    public Renderer quadback;
     Material materialFront;
     Material materialBack;
    public Light light;
    public string[] properties;
    public Vector2[] speeds;
    private Vector2[] offsets;
    // Use this for initialization
    void Start () {
        materialFront = quadfront.GetComponent<Renderer>().material;
        materialBack = quadback.GetComponent<Renderer>().material;
        properties = materialFront.GetTexturePropertyNames();
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
                materialFront.SetTextureOffset(properties[i], offsets[i]);
                materialBack.SetTextureOffset(properties[i], offsets[i]);
            }
        }
        Color col = materialFront.color;
        col.a = Mathf.Lerp(pars.SL06Transparenz, col.a, pars.smoothFactor0to1);
        materialFront.SetColor("_Color", col);

    }
}
