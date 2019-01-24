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
        properties = materialBack.GetTexturePropertyNames();
        offsets = new Vector2[speeds.Length];
    }

    public float test;
    Color col;
    // Update is called once per frame
    void Update () {

            
        offsets[0] += speeds[0] * Time.deltaTime;
        materialFront.SetTextureOffset("_MainTex", offsets[0]);
        materialBack.SetTextureOffset("_MainTex", offsets[0]);

        offsets[1] += speeds[1] * Time.deltaTime;
        materialFront.SetTextureOffset("_DetailAlbedoMap", offsets[1]);
        materialBack.SetTextureOffset("_DetailAlbedoMap", offsets[1]);

        col = materialFront.GetColor("_Color");
        
        float value = BenjasMath.mapSteps(pars.SL008Transparenz, pars.stepsSL008, new float[] {.0f,.3f,.5f,.8f });

        // since transparency hits stronger, the more equal the colors of foreground and background, 
        // lets make it less strong then
        float diffCol = Mathf.Clamp01(0.3f + Mathf.Abs(pars.SL003HVG - pars.SL001HHG)*5 + Mathf.Abs(pars.SL003SVG - pars.SL001SHG));
        float diffBright = Mathf.Clamp01(Mathf.Abs(pars.SL003BVG - pars.SL001BHG) + pars.SL003BVG);
        value *= BenjasMath.map(diffBright * diffCol,0.0f, 0.5f, 0.1f, 1.0f);

        value = Mathf.Lerp(value, col.a, pars.smoothFactor0to1);
        col = Color.Lerp(Color.HSVToRGB(pars.SL001HHG, pars.SL001SHG, pars.SL001BHG * 3), col, pars.smoothFactor0to1);
        col.a = value;

        test = value;
        materialFront.SetColor("_Color", col);
        col.a = 1;
        materialBack.SetColor("_Color", col);

        value = materialBack.GetFloat("_lowContrast");
        value = Mathf.Lerp(BenjasMath.mapSteps(pars.SL002KontrHG, new float[] { 0, 0.1f, 0.3f }, new float[] { 0, 0.5f, 1 }), value, pars.smoothFactor0to1);
        materialBack.SetFloat("_lowContrast", value);
        materialFront.SetFloat("_lowContrast", value);

        value = materialBack.GetFloat("_highContrast");
        value = Mathf.Lerp(BenjasMath.mapSteps(pars.SL002KontrHG, new float[] { 0.5f, 0.7f, 0.9f, 1 }, new float[] { 0, 2, 32,200 }), value, pars.smoothFactor0to1);
        materialBack.SetFloat("_highContrast", value);
        materialFront.SetFloat("_highContrast", value);

        value = materialBack.GetFloat("_pickTexture");
        value = BenjasMath.mapSteps(pars.SL002KontrHG, new float[] { 0.3f, 0.5f, 0.7f }, new float[] { 0.1f, 0.9f, 0.25f });
        materialFront.SetFloat("_pickTexture", value);
        materialBack.SetFloat("_pickTexture", value);
    }
    public string info = "";
}
