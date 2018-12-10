using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using RaymarchingToolkit;
using UnityEngine.PostProcessing;
using UnityEngine.UI;

public class GemgefParameters : MonoBehaviour {

    [Header("HSB Background")]
    public float SL001HHG;
    public float SL001SHG;
    public float SL001BHG;
    public float SL002KontrHG;
    [HideInInspector] public float[] stepsSL002 = new float[] { 0, .2f, .5f, .8f, 1 };

    [Header("HSB Foreground")]
    public float SL003HVG;
    public float SL003SVG;
    public float SL003BVG;
    public float SL004KontrVG;
    [HideInInspector] public float[] stepsSL004 = new float[] { 0, .2f, .5f, .8f, 1 };

    [Header("SLiders")]
    public float SL005Fragmentierung;
    [HideInInspector] public float[] stepsSL005 = new float[] { 0f, 0.2f, 0.4f, 0.6f, 0.8f, 1f };
    public float SL006Teilung;
    [HideInInspector] public float[] stepsSL006 = new float[] { 0, .33f, .66f, 1 };
    public float SL007Muster;
    [HideInInspector] public float[] stepsSL007 = new float[] { 0, .3f, .6f, 1 };
    public float SL008Transparenz;
    [HideInInspector] public float[] stepsSL008 = new float[] { 0, 0.8f };
    public float SL009Varianz;
    public float SL010Aggregatzustand;
    [HideInInspector] public float[] stepsSL010 = new float[] { 0, .6f, 1 };
    [HideInInspector] public float[] inputBorders01 = new float[] { 0, 1 };






    [HideInInspector] public float SL04Bewegung;
    [HideInInspector] public float[] stepsSL04 = new float[] { 0, .1f, .2f, .3f, .4f, .55f, .7f, .9f, 1 };

    [Header("Better Dont Touch")]
    public bool prohibitUpdate = false;

    public Raymarcher ray;

    public RaymarchModifier displacement;
    private Modifier dispInt;

    public  RaymarchModifier twister;
    private Modifier twist ;

    public RaymarchBlend blender;
    private Modifier blend;
    public float smoothFactor0to1 = .8f;

    public RaymarchModifier Repeater;
    public Vector3 repeatDistance = new Vector3(40, 0, 60);

    public Light raymarchLight1;
    public Light raymarchLight2;

    GemgefObject[] Obj;

    public PostProcessingBehaviour post;
    PostProcessingProfile postpro;

    public Vector3[] randomBase;
    public bool overrideRandomBase = false;

    public float deltaTime = 0.0f;
    public bool adjustQualityByFrametime = true;
    public float qualityScaling = 1f;
    public Text InfoText;


    // Use this for initialization
    void Start()
    {

        postpro = post.profile;
        postpro.colorGrading.enabled = true;
        postpro.grain.enabled = true;

        dispInt = new Modifier(displacement,"intensity");
        twist = new Modifier(twister, "angle");
        blend = new Modifier(blender, "intensity");
        smoothFactor0to1 = Mathf.Clamp01(smoothFactor0to1);
        Obj = FindObjectsOfType<GemgefObject>();
        if (overrideRandomBase)
        {
            randomBase = new Vector3[128];
            for (int i = 0; i < randomBase.Length; i++)
            {
                randomBase[i] = new Vector3(Random.value, Random.value, Random.value);
            }
        }
        for (int i = 0; i < Obj.Length; i++)
        {
            float n = Mathf.InverseLerp(0, Obj.Length - 1, i);
            Obj[i].setup(randomBase[i], n, smoothFactor0to1 ,repeatDistance);
        }
        Repeater.GetInput("separation").vector4Value = new Vector4(repeatDistance.x,repeatDistance.y,repeatDistance.z,0);
        Repeater.GetInput("x").SetToggle(repeatDistance.x > 1);
        Repeater.GetInput("y").SetToggle(repeatDistance.y > 1);
        Repeater.GetInput("z").SetToggle(repeatDistance.z > 1);
    }


 

    private void clampSliders()
    {
        SL005Fragmentierung = Mathf.Clamp01(SL005Fragmentierung);
        SL007Muster = Mathf.Clamp01(SL007Muster);
        SL04Bewegung = Mathf.Clamp01(SL04Bewegung);
        SL009Varianz = Mathf.Clamp01(SL009Varianz);
        SL008Transparenz = Mathf.Clamp01(SL008Transparenz);
        SL010Aggregatzustand = Mathf.Clamp01(SL010Aggregatzustand);
        SL006Teilung = Mathf.Clamp01(SL006Teilung);
        SL002KontrHG = Mathf.Clamp01(SL002KontrHG);
        SL004KontrVG = Mathf.Clamp01(SL004KontrVG);
        SL001HHG = Mathf.Clamp01(SL001HHG);
        SL001SHG = Mathf.Clamp01(SL001SHG);
        SL001BHG = Mathf.Clamp01(SL001BHG);
        SL003HVG = Mathf.Clamp01(SL003HVG);
        SL003SVG = Mathf.Clamp01(SL003SVG);
        SL003BVG = Mathf.Clamp01(SL003BVG);
    }

    public Vector3 maxspread = new Vector3(16, 9, 16);

    void updateSwarm()
    {
        //spread objects
        for (int i = 0; i < Obj.Length; i++)
        {
            Obj[i].update();
        }
    }


    public int fps = 60;
    public float ms = 0;
    float realFPS = 60;

    void managePerformance()
    {
        deltaTime += (Time.unscaledDeltaTime - deltaTime) * 0.1f;
        if (deltaTime > 0)
        {
            realFPS = 1 / deltaTime;
            fps = (int)realFPS;
            ms = (deltaTime * 1000f);
        }
        if (adjustQualityByFrametime)
        {
            if (realFPS < 13)
                qualityScaling *= 0.90f;
            if (realFPS < 16)
                qualityScaling *= 0.95f;
            else if(realFPS < 18)
                qualityScaling *= 0.99f;
            else if (realFPS > 20 && qualityScaling < 1)
                qualityScaling *= 1.01f;
            else if (realFPS < 30 && qualityScaling > 1)
                qualityScaling *= 0.99f;
            else if (realFPS > 30)
                qualityScaling *= 1.01f;

        // manage some values manually because we know what is going on
        float rayValue; //use this for calculations before applying

        rayValue = BenjasMath.mapSteps(SL010Aggregatzustand, stepsSL010, new float[] { 0.6f, 0.6f, 0.5f });
        rayValue += BenjasMath.mapSteps(SL005Fragmentierung, stepsSL005, new float[] { 0f, 0.0f, 0.05f, 0.1f, 0.2f, 0.2f });
        ray.Resolution = Mathf.Clamp(rayValue * qualityScaling,0.1f, 0.7f);

        rayValue = BenjasMath.mapSteps(SL010Aggregatzustand, stepsSL010, new float[] { 150, 140, 100 });
        ray.Steps = Mathf.RoundToInt(Mathf.Clamp(rayValue * qualityScaling,50, 180));

        rayValue = BenjasMath.mapSteps(SL010Aggregatzustand, stepsSL010, new float[] { 0.5f, 0.4f, 0.3f });
        rayValue += BenjasMath.mapSteps(SL005Fragmentierung, stepsSL005, new float[] { 0f, 0.0f, 0.05f, 0.1f, 0.2f, 0f });
        ray.ExtraAccuracy = Mathf.Clamp(rayValue * (.5f+.5f*qualityScaling),0.3f, 0.8f);
        }

        InfoText.text = (1 / deltaTime).ToString("N0") + " fps"
                + "\n" + (deltaTime * 1000).ToString("N0") + " ms"
                + "\n" + qualityScaling.ToString("N2") + " quality"
                + "\n" + ray.Resolution.ToString("N2") + " resolution"
                + "\n" + ray.Steps.ToString("N0") + " Steps"
                + "\n" + ray.ExtraAccuracy.ToString("N2") + " Accuracy";
    }

    // Update is called once per frame
    void Update() {
        managePerformance();
        if (!prohibitUpdate)
        {

            clampSliders();

            updateSwarm();


            //displacements

            dispInt.set(BenjasMath.mapSteps(SL005Fragmentierung, stepsSL005, new float[] { 0, .5f, 1, 2, 7, 0 }));


            // gas stuff
            twist.set(BenjasMath.mapSteps(SL010Aggregatzustand, stepsSL010, new float[] { 0, 0, 5 }));
            blend.set(BenjasMath.mapSteps(SL010Aggregatzustand, stepsSL010, new float[] { 0, 6, 2 }));


            //brightness and Contrast

            GrainModel.Settings grain = postpro.grain.settings;
            grain.intensity = BenjasMath.mapSteps(SL002KontrHG + SL004KontrVG, new float[] { 0, .1f, 1.9f, 2 }, new float[] { 1, 0,0, 2 });
            //grain.intensity += BenjasMath.mapSteps(SL010Aggregatzustand, stepsSL010, new float[] { .1f, 0, 1.5f });
            postpro.grain.settings = grain;

            ray.AmbientColor = Color.white * (1- SL004KontrVG);
            raymarchLight1.intensity = SL004KontrVG * 2;
            raymarchLight2.intensity = SL004KontrVG * 1;
    /*
    ColorGradingModel.Settings grading = postpro.colorGrading.settings;
    grading.basic.contrast = BenjasMath.mapSteps(SL002KontrHG, stepsSL002, new float[] { 0.1f, 0.2f, 1, 2, 2 });
    grading.basic.postExposure = BenjasMath.mapSteps(SL004KontrVG, stepsSL004, new float[] { -5, -4, 0, 10, 10 });
    grading.basic.saturation = BenjasMath.mapSteps(SL004KontrVG, stepsSL004, new float[] { 1.1f, 1f, 1, 1, .9f });
    grading.basic.saturation *= BenjasMath.mapSteps(SL002KontrHG, stepsSL002, new float[] { .7f, .85f, 1, 1.2f, 1.4f });
    postpro.colorGrading.settings = grading;
    */
    DepthOfFieldModel.Settings lense = postpro.depthOfField.settings;
            lense.focalLength = BenjasMath.map(SL004KontrVG, 0, .1f,  1.2f, 1.1f);
            lense.focalLength += BenjasMath.map(SL002KontrHG + SL004KontrVG,  0.9f, 1 , -1, -10 );
            lense.focalLength +=  BenjasMath.mapSteps(SL010Aggregatzustand, stepsSL010, new float[] { 0f, 0.05f, 7f });
            lense.focalLength += Mathf.Pow(SL008Transparenz, 4)*4f;
            lense.focalLength = Mathf.Clamp(lense.focalLength, 0, 100);


            postpro.depthOfField.settings = lense;

        }


    }

    public class Modifier
    {
        SnippetInput input;
        string name ="undefined Modifier";
        float blend = 0.8f;


        public Modifier(RaymarchModifier modifier, string inputName)
        {
            input = modifier.GetInput(inputName);
            name = "RaymarchModifier." + inputName;
        }

        public Modifier(RaymarchBlend modifier, string inputName)
        {
            input = modifier.GetInput(inputName);
            name = "RaymarchBlend." + inputName;
        }

        public Modifier(RaymarchObject modifier, string inputName, bool getMaterialInput = false)
        {
        if(getMaterialInput) input = modifier.material.GetInput(inputName);
        else input = modifier.GetObjectInput(inputName);
            name = "RaymarchObj." + inputName;
        }


        public void set(float value,  float[] inputs, float[] outputs, float randomBase = 0, float randomValue = 0)
        {
            value = Mathf.Lerp(value, randomBase, randomValue);
            value = BenjasMath.mapSteps(value, inputs, outputs);
            value = Mathf.Lerp(value, input.floatValue, blend);
            input.SetFloat(value);
        }

        public void set(float value)
        {
            value = Mathf.Lerp(value, input.floatValue,  blend);
            input.SetFloat(value);
        }

        public void set(float H, float S, float B,  Vector3 randomBase = new Vector3(), float randomValue = 0)
        {
            H = Mathf.Lerp(H,  randomBase.x, randomValue);
            S = Mathf.Lerp(S,  randomBase.y, randomValue);
            B = Mathf.Lerp(B,  randomBase.z, randomValue);

            input.color = Color.Lerp( Color.HSVToRGB(H,S,B) , input.color, blend);
        }

    }
 
}







 