using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using RaymarchingToolkit;

public class GemgefObject : MonoBehaviour {


    public RaymarchModifier displacement;
    private GemgefParameters.Modifier dispFreq;
    private GemgefParameters.Modifier dispInt;
    private GemgefParameters.Modifier dispSpeed;

    public RaymarchModifier pixelate;
    private GemgefParameters.Modifier pixInt;
    private GemgefParameters.Modifier pixSep;

    public RaymarchBlend morpher;
    private GemgefParameters.Modifier morph;
    private Transform trafo;

    GemgefParameters pars;
    public RaymarchObject[] objs;
    private GemgefParameters.Modifier[] col;

    public Vector3 randomBase = Vector3.one;
    public Vector3 scale;

    private float smooth = 0.5f;

    // Use this for initialization
    void Start()
    {
        pars = FindObjectOfType<GemgefParameters>();
        dispInt = new GemgefParameters.Modifier(displacement, "intensity");
        dispFreq = new GemgefParameters.Modifier(displacement, "freq");
        dispSpeed = new GemgefParameters.Modifier(displacement, "speed");
        pixInt = new GemgefParameters.Modifier(pixelate, "intensity");
        pixSep = new GemgefParameters.Modifier(pixelate, "separation");
        morph = new GemgefParameters.Modifier(morpher, "whichObject");
        trafo = morpher.transform;
        objs = trafo.GetComponentsInChildren<RaymarchObject>();
        col = new GemgefParameters.Modifier[objs.Length];
        for (int i= 0;i< objs.Length;i++)
        {
            col[i] = new GemgefParameters.Modifier(objs[i], "color",true);
        }
        scale = trafo.localScale;
    }

    public float n = 0;

    public void setup(Vector3 the_randomBase, float the_n , float the_smooth, Vector3 the_repeatDistance)
    {
        n = the_n;
        rad = n * 2 * 3.14159f; //will use this for a circular spread
        randomBase = the_randomBase;
        smooth = the_smooth;
        repeatDistance = the_repeatDistance;
        eulers = randomBase * 360;
        trafo = morpher.transform;
        trafo.localEulerAngles = eulers;

        isSetUp = true;
    }

    bool isSetUp = false;

    [Header("info - dont touch")]
    public float rad;
    public Vector3 offset = new Vector3();
    public float speedU;
    public float speedV;
    public float speedRot = 0;
    public Vector3 floating = new Vector2();
    Vector3 repeatDistance = new Vector3(40, 0, 60);


    public void updateTransform()
        //n is a value between 0 and 1, stating which object in the array it is
    {
        float SL006Teilung = Mathf.Clamp01(pars.SL006Teilung + 0.001f);
       if (n==0)
        {
            //scale the center up a bit while not parted
            trafo.localScale = Vector3.Lerp(scale * Mathf.Lerp(1 + Mathf.Max(1 - SL006Teilung, .5f),1,pars.SL009Varianz), trafo.localScale, smooth);
        }
       else
       {
            //float moveVariation = Mathf.Lerp(pars.SL04Bewegung, randomBase.z, pars.SL009Varianz);
            float twoPI = 2 * Mathf.PI;




            // now we add the movement depending on time and position

            // put in the random factor

            float speed =  BenjasMath.mapSteps(pars.SL010Aggregatzustand, new float[] { 0, .5f, 1 }, new float[] { .1f, 1.5f, .3f });
            // calculate the speed and magnitude
            speedU = speed *                           BenjasMath.mapSteps(pars.SL007Muster, new float[] { 0, .1f, .3f, .55f, .8f, 0 }, new float[] {  0, 0,  0, 1, 1, 0  });
            speedV = speed *                           BenjasMath.mapSteps(pars.SL007Muster, new float[] { 0, .1f, .3f, .55f, .8f, 0 }, new float[] {  0, 0,  0, 1, 1, 1  });

            speedRot -= .1f * Time.deltaTime * speed * BenjasMath.mapSteps(pars.SL007Muster, new float[] { 0, .1f, .3f, .55f, .8f, 0 }, new float[] {  0, 0,  1, 1, 0, 0 });
            if (speedRot < 0) speedRot += twoPI;

            float floatSpeedU= 10.1f * speed *         BenjasMath.mapSteps(pars.SL007Muster, new float[] { 0, .1f, .3f, .55f, .8f, 0 }, new float[] { 1, 0,  0, 0, 0, 0 });
            float floatSpeedV = 10.1f * speed *        BenjasMath.mapSteps(pars.SL007Muster, new float[] { 0, .1f, .3f, .55f, .8f, 0 }, new float[] { 0, 1,  0, 0, 0, 0 });


            // calculate rotational position, depending on speedRot and SL007

            // influence of pattern
            //horozontal deflection from center
            float lerpHor = BenjasMath.mapSteps(pars.SL007Muster, new float[] { 0, .1f, .3f, .55f, .8f, 0 }, new float[] { 0,0, 1, 1, 1,1 });
            //vertical deflection from center
            float lerpVer = BenjasMath.mapSteps(pars.SL007Muster, new float[] { 0, .1f, .3f, .55f, .8f, 0 }, new float[] { 0,0, 1, 1, 1,1 });
            //second pattern Amplitude
            float ampVer = BenjasMath.mapSteps(pars.SL007Muster, new float[] { 0, .1f, .3f, .55f, .8f, 0 }, new float[] { 0,0, 0, 0, 0 ,0});
            float ampHor = BenjasMath.mapSteps(pars.SL007Muster, new float[] { 0, .1f, .3f, .55f, .8f, 0 }, new float[] { 0,0, 0, 0, 0 ,0});
            //second pattern frequency
            float secondPattern = pars.maxspread.y *  Mathf.Sin(rad *6 + Mathf.PI/2);
            Vector3 symmetrie = new Vector3(Mathf.Lerp(randomBase.x , 1, lerpHor),
                                            Mathf.Lerp(randomBase.y , 1, lerpVer),
                                            Mathf.Lerp(randomBase.x , 1, lerpHor));



            //modifie transform

            //Scale
            float scalefactor = SL006Teilung * Mathf.Lerp(1, randomBase.y, 1 - 5 * pars.SL007Muster);
            scalefactor = Mathf.Lerp(scalefactor, randomBase.z, pars.SL009Varianz);
            trafo.localScale = Vector3.Lerp(scale * scalefactor, trafo.localScale, smooth);

            //basic position depending on SL007 pattern
            Vector3 pos = new Vector3();
            
            //circular pattern
            pos.x = (pars.maxspread.x + secondPattern * ampHor) * Mathf.Sin(rad + speedRot)  * symmetrie.x;
            pos.z = (pars.maxspread.z + secondPattern * ampHor) * Mathf.Cos(rad + speedRot)  * symmetrie.z;
            //vertical pattern
            pos.y = secondPattern * ampVer * symmetrie.y;

            //makes movement without SL007 more random
            pos *= Mathf.Clamp01(SL006Teilung * 1.5f);
            
            float relativeDistance = pos.magnitude / pars.maxspread.magnitude;
            


            // first movement pattern - swinging in y and in xz

            offset = pars.maxspread * relativeDistance;

            offset.x *= .2f *Mathf.Sin(rad) * speedU *  symmetrie.x * Mathf.Cos( symmetrie.x * speedU  * Time.time + n * 4* twoPI);
            offset.y *= .5f *                speedV *  symmetrie.y * Mathf.Sin( symmetrie.y * speedV  * Time.time + n * 4* twoPI);
            offset.z *= .2f *Mathf.Cos(rad) * speedU *  symmetrie.z * Mathf.Cos( symmetrie.x * speedU  * Time.time + n * 4* twoPI);
            pos += offset;

            // second movement pattern - linear floating

            if (pars.SL007Muster > .3f)
            {
                //no floating, set float 0, smoothing will do the movement
                floating = new Vector3();
            }
            else
            {
                // floating, use floatspeed, make it smaller near the center and multiply by time
                relativeDistance = (pos+ floating).magnitude / pars.maxspread.magnitude;
                floating.x += floatSpeedU * (.2f + relativeDistance * .8f)  *Time.deltaTime;
                floating.z += floatSpeedV * (.2f + relativeDistance * .8f) * Time.deltaTime;
            } 

            pos += floating;

            pos = Vector3.Lerp(pos, trafo.localPosition, smooth);
            if (floating.x>0 || floating.z>0)
            {
                if ((pos.x > repeatDistance.x*.5) || (pos.z > repeatDistance.z * .5))
                {
                    offset = BenjasMath.VectorComponentProduct(-floating.normalized, repeatDistance);

                    floating.x += offset.x;
                    pos.x += offset.x;

                    floating.z += offset.z;
                    pos.z += offset.z;
                }
            }
            
            trafo.localPosition = pos;
        }
        trafo.Rotate(10*randomBase * Time.deltaTime);
    }
    





public Vector3 eulers;

    public void update()
    {
        float varianz = pars.SL009Varianz;
        //displacements

        updateTransform();
        try
        {
            dispInt.set(Mathf.Lerp(pars.SL005Fragmentierung, randomBase.x, pars.SL009Varianz), pars.stepsSL005, new float[] { 0, 0, .2f, 1, 2f, 0 });
            dispFreq.set(Mathf.Lerp(pars.SL005Fragmentierung, randomBase.y, pars.SL009Varianz), pars.stepsSL005, new float[] { 3, 4, 4, 3, 5, 0 });
            dispSpeed.set(Mathf.Lerp(pars.SL010Aggregatzustand, randomBase.z, pars.SL009Varianz), pars.stepsSL010, new float[] { 0, .2f, .4f });

        }
        catch 
        {

        }

        //dispY.set(pars.SL005Fragmentierung, pars.stepsSL005, new float[] { 0, 0, 0, 0, 1, 4 }, randomBase.y, varianz);
        //dispYSpeed.set(pars.SL010Aggregatzustand, pars.stepsSL008, new float[] { 0, 2, 1 }, randomBase.z, varianz);

        // gas stuff
        //if pixelate
        pixInt.set(pars.SL010Aggregatzustand, pars.stepsSL010, new float[] { 0, -2, -35 }, randomBase.z, varianz);
        pixSep.set(pars.SL010Aggregatzustand, pars.stepsSL010, new float[] { 0.01f, 0.01f, .12f }, randomBase.z, varianz);

        
        //if displacement noise
        //pixInt.set(pars.SL010Aggregatzustand, pars.stepsSL010, new float[] { 0, 0.1f, 10 }, randomBase.z, varianz);
        //pixSep.set(pars.SL010Aggregatzustand, pars.stepsSL010, new float[] { 0.01f, 10f, .1f }, randomBase.z, varianz);


        value = BenjasMath.mapSteps(Mathf.Lerp(pars.SL005Fragmentierung, randomBase.y, varianz), pars.stepsSL005, new float[] { 0f, 0f, 0f, 0f, 1f, 1f });
        // this value will be used to lerp beween the value determined by 'Agregatszustand' and morphByFrag 
        float morphByFrag = BenjasMath.mapSteps(Mathf.Lerp(pars.SL005Fragmentierung, randomBase.y, varianz), pars.stepsSL005, new float[] { 0f, 0f, 0f, 0f, 1f, 2.85f });
        float morphByAgr = BenjasMath.mapSteps(Mathf.Lerp(pars.SL010Aggregatzustand, randomBase.x, varianz), pars.stepsSL010, new float[] { .66f, 0, 0 });
        value = Mathf.Lerp(morphByAgr, morphByFrag, value);

        morph.set(value);



        for (int i = 0; i < objs.Length; i++)
        {
            col[i].set(pars.SL003HVG, pars.SL003SVG, Mathf.Pow(pars.SL003BVG,3)*8, randomBase, varianz);
        }

    }

    public float value;
    // Update is called once per frame
    void Update()
    {

 


    }
    private void FixedUpdate()
    {
       // updateTransform();
    }

}







