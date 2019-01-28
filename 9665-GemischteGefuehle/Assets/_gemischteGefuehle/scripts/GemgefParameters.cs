using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using RaymarchingToolkit;
using UnityEngine.PostProcessing;
using UnityEngine.UI;

public class GemgefParameters : MonoBehaviour {

    [Header("HSB Background")]
    [Range(0,1)] public float SL001HHG;
    [Range(0,1)] public float SL001SHG;
    [Range(0,1)] public float SL001BHG;
    [Range(0,1)] public float SL002KontrHG;
    [HideInInspector] public float[] stepsSL002 = new float[] { 0, .2f, .5f, .8f, 1 };

    [Header("HSB Foreground")]
    [Range(0,1)] public float SL003HVG;
    [Range(0,1)] public float SL003SVG;
    [Range(0,1)] public float SL003BVG;
    [Range(0,1)] public float SL004KontrVG;
    [HideInInspector] public float[] stepsSL004 = new float[] { 0, .2f, .5f, .8f, 1 };

    [Header("SLiders")]
    [Range(0,1)] public float SL005Fragmentierung;
    [HideInInspector] public float[] stepsSL005 = new float[] { 0f, 0.2f, 0.4f, 0.6f, 0.8f, 1f };
    [Range(0,1)] public float SL006Teilung;
    [HideInInspector] public float[] stepsSL006 = new float[] { 0, .33f, .66f, 1 };
    [Range(0,1)] public float SL007Muster;
    [HideInInspector] public float[] stepsSL007 = new float[] { 0, .3f, .6f, 1 };
    [Range(0,1)] public float SL008Transparenz;
    [HideInInspector] public float[] stepsSL008 = new float[] { 0.01f, .3f, .8f, 1.0f };
    [Range(0,1)] public float SL009Varianz;
    [Range(0,1)] public float SL010Aggregatzustand;
    [HideInInspector] public float[] stepsSL010 = new float[] { 0, .6f, 1 };
    [HideInInspector] public float[] inputBorders01 = new float[] { 0, 1 };






    [HideInInspector] [Range(0,1)] public float SL04Bewegung;
    [HideInInspector] public float[] stepsSL04 = new float[] { 0, .1f, .2f, .3f, .4f, .55f, .7f, .9f, 1 };

    [Header("quality scaling")]
    public bool autoadjustQuality = true;
    public float deltaTime = 0.0f;
    public float ms = 0;
    public float realFPS = 60;
    public int fps = 60;
    [Range(10, 120)] public float targetFPS = 60;
    [Range(0.9f, 1.1f)] public float deltaQuality = 1;
    [Range(0f, 2f)] public float qualityScaling = 1f;
    public Text InfoText;

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

    public Camera cam;
    PostProcessingBehaviour post;
    CameraFilterPack_Blur_Blurry blur;

    public Vector3[] randomBase;
    public bool overrideRandomBase = false;




    // Use this for initialization
    void Start()
    {
        post = cam.GetComponent<PostProcessingBehaviour>();
        post.profile.colorGrading.enabled = true;
        post.profile.grain.enabled = true;
        blur = cam.GetComponent<CameraFilterPack_Blur_Blurry>();

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
        Application.logMessageReceived += LogCallback;
    }

    public void LogCallback(string condition, string stackTrace, LogType type)
    {
        logCon = condition;

        //Resource ID out of range in UpdateResource: 1326000 (max is 1048575)
        //(Filename: Line: 80)
        if (condition.Contains("Resource ID out of range in UpdateResource"))
        {
            cleanUp();
            atemptsToFixResourceIDBug++;
        }
    }

    public int atemptsToFixResourceIDBug = 0;
    public string logCon;


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



    void managePerformance()
    {
        deltaTime = Time.smoothDeltaTime;
        if (deltaTime > 0)
        {
            realFPS =  1.0f / deltaTime;
            ms = Mathf.Lerp(deltaTime * 1000f,ms,0.99f);
            fps = (int) (1000/ms);
        }
        memoryUsed = (((float)UnityEngine.Profiling.Profiler.GetTotalAllocatedMemoryLong()) / (1024f * 1024f));
        deltaQuality = BenjasMath.mapSteps(realFPS, new float[] { targetFPS * 0.66f, targetFPS * 1.00f, targetFPS * 1.3f }, new float[] { 0.950f, 1, 1.01f });
        if (restartAfterCleanup) cleanUpRestart();
        else if (memoryUsed > 999) cleanUp();
        else if (autoadjustQuality)
        {
            qualityScaling *= deltaQuality;
        }
        qualityScaling = Mathf.Max(qualityScaling, 0.01f);
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



        InfoText.text = fps.ToString("N0") + " fps"
                + " / " + ms.ToString("N0") + " ms"
                + "\n" + memoryUsed.ToString("N2") + " MB Allocated memory"
                + "\n" + "attempts to fix ResouceID Bug " + atemptsToFixResourceIDBug.ToString()
                + "\n" + "raymarching quality adjustments"
                + "\n" + qualityScaling.ToString("N2") + " (x "+deltaQuality.ToString("N3") +")relative quality"
                + "\n" + ray.Resolution.ToString("N2") + " resolution"
                + "\n" + ray.Steps.ToString("N0") + " Steps"
                + "\n" + ray.ExtraAccuracy.ToString("N2") + " Accuracy";

    }

    public float memoryUsed;

    public void cleanUp()
    {
        Debug.Log("cleanup");
        cam.cullingMask = 0 << 0;
        post.profile.grain.enabled = false;
        post.profile.antialiasing.enabled = false;
        post.enabled = false;
        blur.enabled = false;
        ray.enabled = false;



        restartAfterCleanup = true;
    }

    bool restartAfterCleanup = false;

    public void cleanUpRestart()
    {
        Debug.Log("restart after cleanup");
        cam.cullingMask = 99 << 0;
        post.profile.grain.enabled = true;
        post.profile.antialiasing.enabled = true;
        post.enabled = true;
        blur.enabled = true;
        ray.enabled = true;
        restartAfterCleanup = false;
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

            GrainModel.Settings grain = post.profile.grain.settings;
            grain.intensity = BenjasMath.mapSteps(SL002KontrHG + SL004KontrVG, new float[] { 0, .1f, 1.9f, 2 }, new float[] { 1, 0,0, 2 });
            //grain.intensity += BenjasMath.mapSteps(SL010Aggregatzustand, stepsSL010, new float[] { .1f, 0, 1.5f });
            post.profile.grain.settings = grain;

            ray.AmbientColor = Color.white * (1- SL004KontrVG);
            raymarchLight1.intensity = SL004KontrVG * 2;
            raymarchLight2.intensity = SL004KontrVG * 1;
            /*
            ColorGradingModel.Settings grading = post.profile.colorGrading.settings;
            grading.basic.contrast = BenjasMath.mapSteps(SL002KontrHG, stepsSL002, new float[] { 0.1f, 0.2f, 1, 2, 2 });
            grading.basic.postExposure = BenjasMath.mapSteps(SL004KontrVG, stepsSL004, new float[] { -5, -4, 0, 10, 10 });
            grading.basic.saturation = BenjasMath.mapSteps(SL004KontrVG, stepsSL004, new float[] { 1.1f, 1f, 1, 1, .9f });
            grading.basic.saturation *= BenjasMath.mapSteps(SL002KontrHG, stepsSL002, new float[] { .7f, .85f, 1, 1.2f, 1.4f });
            post.profile.colorGrading.settings = grading;
            */


            blur.Amount = .5f;
            blur.Amount += BenjasMath.map(SL004KontrVG, 0, .1f, .2f, .0f);
            blur.Amount += BenjasMath.map(SL002KontrHG + SL004KontrVG, 1.0f, 1.8f, -0, -3);

            blur.Amount += BenjasMath.mapSteps(SL010Aggregatzustand, stepsSL010, new float[] { 0f, 0.05f, 1.5f });
            blur.Amount += Mathf.Pow(SL008Transparenz, 4) * 4f;
            blur.Amount = Mathf.Clamp(blur.Amount, 0, 3f);

            /*
            DepthOfFieldModel.Settings lense = post.profile.depthOfField.settings;
                    lense.focalLength = BenjasMath.map(SL004KontrVG, 0, .1f,  1.2f, 1.1f);
                    lense.focalLength += BenjasMath.map(SL002KontrHG + SL004KontrVG,  0.9f, 1 , -1, -10 );
                    lense.focalLength +=  BenjasMath.mapSteps(SL010Aggregatzustand, stepsSL010, new float[] { 0f, 0.05f, 7f });
                    lense.focalLength += Mathf.Pow(SL008Transparenz, 4)*4f;
                    lense.focalLength = Mathf.Clamp(lense.focalLength, 0, 100);


                    post.profile.depthOfField.settings = lense;
                    */
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







 