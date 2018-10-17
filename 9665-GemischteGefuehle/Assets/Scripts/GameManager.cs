using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GameManager : MonoBehaviour {


    public static bool debugVisible = false;
    public static bool runningComparison = false;

    // refecernces

    const int NUM_SLIDER = 14;
    public float[] sliderValues = new float[NUM_SLIDER];
    GemgefParameters pars;
    GameObject debug;
    public InputManager inputManagerRef;

    void Awake() {
        Configuration.LoadConfig();
	}

    private void Start()
    {
        sliderValues = new float[NUM_SLIDER];
    float x = Configuration.GetInnerTextByTagName("centerX", 0);
        float y = Configuration.GetInnerTextByTagName("centerY", 0);
        float z = Configuration.GetInnerTextByTagName("centerZ", 1.0f);

        if (pars == null) pars = FindObjectOfType<GemgefParameters>();
        if (inputManagerRef == null) inputManagerRef = GameObject.FindObjectOfType<InputManager>();

        debug = GameObject.Find("DebugCanvas");

        for (int i = 0; i < NUM_SLIDER; i++){
            Slider s = GameObject.Find("Slider ("+(i + 1) + ")").GetComponent<Slider>();
            sliderValues[i] = s.value;
        }
        toggleDebug(false);
    }

    // Update is called once per frame
    void Update () {
        if (Input.GetKeyDown(KeyCode.C))
        {
            
        }
        else if (Input.GetKeyDown(KeyCode.Escape))
        {
            Application.Quit();
        }
        else if (Input.GetKeyDown(KeyCode.D))
        {
            toggleDebug();
        }
        updateAll();
    }

    public void toggleDebug()
    {
        toggleDebug(!debugVisible);
    }

    public void toggleDebug(bool visible)
    {
        debugVisible = visible;
        debug.SetActive(debugVisible);
    }

    public void updateAll()
    {
        for (int id=0; id< sliderValues.Length;id++)
        {
            changeValue(id+1, inputManagerRef.sliderValues[id]); }
    }

    public void debugSliderChanged(Slider _slider)
    {
        int startIndex = _slider.name.IndexOf("(");
        int endIndex = _slider.name.IndexOf(")");
        string stringID = _slider.name.Substring(startIndex+1, (endIndex - startIndex)-1);
        int id = Convert.ToInt32(stringID);
        inputManagerRef.changeValue(id, _slider.value);
        changeValue(id, _slider.value);
        updateAll();
    }

    public void changeValue(int id, float value)
    {
        //Debug.Log(id + " changeValue value is " + value);
        id--;
        sliderValues[id] = value;

        switch (id)
        {
            
            case 0:
                pars.SL09HHintergrundfarbe = Mathf.Clamp01(value); break;
            case 1:
                pars.SL09SHintergrundfarbe = Mathf.Clamp01(value);break;
            case 2:
                pars.SL09BHintergrundfarbe = Mathf.Clamp01(value); break;
            case 3:
                pars.SL07Kontrast = Mathf.Clamp01(value); break;

            case 4:
                pars.SL10HVordergrundfarbe = Mathf.Clamp01(value); break;
            case 5:
                pars.SL10SVordergrundfarbe = Mathf.Clamp01(value); break;
            case 6:
                pars.SL10BVordergrundfarbe = Mathf.Clamp01(value); break;
            case 7:
                pars.SL08Helligkeit = Mathf.Clamp01(value); break;

            case 8:
                pars.SL01Fragmentierung = Mathf.Clamp01(value); break;
            case 9:
                pars.SL02Teilung = Mathf.Clamp01(value); break;
            case 10:
                pars.SL03Muster = Mathf.Clamp01(value); break;
            case 11:
                pars.SL06Transparenz = Mathf.Clamp01(value); break;
            case 12:
                pars.SL04Bewegung = Mathf.Clamp01(value); break;
            case 13:
                pars.SL05Aggregatzustand = Mathf.Clamp01(value); break;

            case 14:
                pars.SL06Varianz = Mathf.Clamp01(value); break;
        }
    }

    #region updating the separate parameters



    #endregion

}
