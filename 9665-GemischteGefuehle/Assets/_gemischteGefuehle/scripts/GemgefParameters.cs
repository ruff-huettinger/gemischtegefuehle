using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using RaymarchingToolkit;
using UnityEngine.PostProcessing;

public class GemgefParameters : MonoBehaviour {

    [Header("SLiders")]
    public float SL01Fragmentierung;
    [HideInInspector] public float[] stepsSL01 = new float[] { 0f, 0.2f, 0.4f, 0.6f, 0.8f, 1f };
    public float SL02Teilung;
    [HideInInspector] public float[] stepsSL02 = new float[] { 0, .33f, .66f, 1 };
    public float SL03Muster;
    [HideInInspector] public float[] stepsSL03 = new float[] { 0, .3f, .6f, 1 };
    public float SL04Bewegung;
    [HideInInspector] public float[] stepsSL04 = new float[] { 0, .1f, .2f , .3f, .4f, .55f, .7f, .9f ,  1};
    public float SL05Aggregatzustand;
    [HideInInspector] public float[] stepsSL05 = new float[] { 0, .6f, 1 };
    public float SL06Varianz;
    public float SL06Transparenz;
    [HideInInspector] public float[] stepsSL06 = new float[] { 0, 1 };
    public float SL07Kontrast;
    [HideInInspector] public float[] stepsSL07 = new float[] { 0, .2f,.5f,.8f, 1 };
    public float SL08Helligkeit;
    [HideInInspector] public float[] stepsSL08 = new float[] { 0, .2f, .5f, .8f, 1 };

    [Header("HSB Background")]
    public float SL09HHintergrundfarbe;
    public float SL09SHintergrundfarbe;
    public float SL09BHintergrundfarbe;

    [Header("HSB Foreground")]
    public float SL10HVordergrundfarbe;
    public float SL10SVordergrundfarbe;
    public float SL10BVordergrundfarbe;

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

    GemgefObject[] Obj;

    public PostProcessingBehaviour post;
    PostProcessingProfile postpro;

    public Vector3[] randomBase;
    public bool overrideRandomBase = false;
    

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
        SL01Fragmentierung = Mathf.Clamp01(SL01Fragmentierung);
        SL03Muster = Mathf.Clamp01(SL03Muster);
        SL04Bewegung = Mathf.Clamp01(SL04Bewegung);
        SL06Varianz = Mathf.Clamp01(SL06Varianz);
        SL06Transparenz = Mathf.Clamp01(SL06Transparenz);
        SL05Aggregatzustand = Mathf.Clamp01(SL05Aggregatzustand);
        SL02Teilung = Mathf.Clamp01(SL02Teilung);
        SL07Kontrast = Mathf.Clamp01(SL07Kontrast);
        SL08Helligkeit = Mathf.Clamp01(SL08Helligkeit);
        SL09HHintergrundfarbe = Mathf.Clamp01(SL09HHintergrundfarbe);
        SL09SHintergrundfarbe = Mathf.Clamp01(SL09SHintergrundfarbe);
        SL09BHintergrundfarbe = Mathf.Clamp01(SL09BHintergrundfarbe);
        SL10HVordergrundfarbe = Mathf.Clamp01(SL10HVordergrundfarbe);
        SL10SVordergrundfarbe = Mathf.Clamp01(SL10SVordergrundfarbe);
        SL10BVordergrundfarbe = Mathf.Clamp01(SL10BVordergrundfarbe);
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
    // Update is called once per frame
    void Update() {

        float time = Time.realtimeSinceStartup;

        if (!prohibitUpdate)
        {

            clampSliders();

            updateSwarm();


            //displacements

            dispInt.set(BenjasMath.mapSteps(SL01Fragmentierung, stepsSL01, new float[] { 0, .5f, 1, 2, 7, 0 }));


            // gas stuff
            twist.set(BenjasMath.mapSteps(SL05Aggregatzustand, stepsSL05, new float[] { 0, 0, 5 }));
            blend.set(BenjasMath.mapSteps(SL05Aggregatzustand, stepsSL05, new float[] { 0, 6, 2 }));
            ray.Resolution = BenjasMath.mapSteps(SL05Aggregatzustand, stepsSL05, new float[] { 0.6f, 0.6f, 0.5f })
                            + BenjasMath.mapSteps(SL01Fragmentierung, stepsSL01, new float[] { 0f, 0.0f, 0.05f, 0.1f, 0.2f, 0.2f });
            ray.Steps = (int) BenjasMath.mapSteps(SL05Aggregatzustand, stepsSL05, new float[] { 150, 140, 100 });
            ray.ExtraAccuracy = BenjasMath.mapSteps(SL05Aggregatzustand, stepsSL05, new float[] { 0.5f, 0.4f, 0.3f })
                                + BenjasMath.mapSteps(SL01Fragmentierung, stepsSL01, new float[] { 0f, 0.0f, 0.05f, 0.1f, 0.2f, 0f });

            //brightness and Contrast

            GrainModel.Settings grain = postpro.grain.settings;
            grain.intensity = BenjasMath.mapSteps(SL07Kontrast,stepsSL07,new float[] { 1, 0,0,0, 2 });
            //grain.intensity += BenjasMath.mapSteps(SL05Aggregatzustand, stepsSL05, new float[] { .1f, 0, 1.5f });
            postpro.grain.settings = grain;
            ColorGradingModel.Settings grading = postpro.colorGrading.settings;
            grading.basic.contrast = BenjasMath.mapSteps(SL07Kontrast, stepsSL07, new float[] { 0.1f, 0.2f, 1, 2, 2 });
            grading.basic.postExposure = BenjasMath.mapSteps(SL08Helligkeit, stepsSL08, new float[] { -5, -4, 0, 10, 10 });
            grading.basic.saturation = BenjasMath.mapSteps(SL08Helligkeit, stepsSL08, new float[] { 1.1f, 1f, 1, 1, .9f });
            grading.basic.saturation *= BenjasMath.mapSteps(SL07Kontrast, stepsSL07, new float[] { .7f, .85f, 1, 1.2f, 1.4f });
            postpro.colorGrading.settings = grading;
            DepthOfFieldModel.Settings lense = postpro.depthOfField.settings;
            lense.focalLength = BenjasMath.mapSteps(SL07Kontrast, stepsSL07, new float[] { 10f, 1.2f, 1.1f, 1, -10 });
            lense.focalLength +=  BenjasMath.mapSteps(SL05Aggregatzustand, stepsSL05, new float[] { 0f, 0.05f, 9f });
            lense.focalLength += Mathf.Pow(SL06Transparenz, 4)*8f;
            lense.focalLength = Mathf.Clamp(lense.focalLength, 0, 100);


            postpro.depthOfField.settings = lense;

        }
        time = Time.realtimeSinceStartup - time;
        if (time > 0)
        {
            realFPS = Mathf.Lerp(1 / time, realFPS, 0.9f);
            fps = (int) realFPS;
            ms =  (time * 1000f);
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







 