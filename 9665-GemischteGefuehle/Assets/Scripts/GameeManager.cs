using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GameeManager : MonoBehaviour {


    public static bool debugVisible = false;
    public static bool runningComparison = false;

    // refecernces
    private ObjectManager objectManager;
    private RawImage bg;
    private GameObject singleObject;
    private Renderer singleObjectRenderer;

    const int NUM_SLIDER = 14;
    public float[] sliderValues = new float[NUM_SLIDER];
    private int SLIDER_ID_FRAGMENT = 9;


	void Awake() {
        Configuration.LoadConfig();
	}

    private void Start()
    {
        float x = Configuration.GetInnerTextByTagName("centerX", 0);
        float y = Configuration.GetInnerTextByTagName("centerY", 0);
        float z = Configuration.GetInnerTextByTagName("centerZ", 1.0f);

        objectManager = GameObject.FindObjectOfType<ObjectManager>();
        bg = GameObject.Find("BG").GetComponent<RawImage>();
        singleObject = GameObject.Find("SingleObject");
        singleObjectRenderer = GameObject.Find("SingleObject").GetComponent<Renderer>();

        for(int i = 0; i < NUM_SLIDER; i++){
            Slider s = GameObject.Find("Slider ("+(i + 1) + ")").GetComponent<Slider>();
            sliderValues[i] = s.value;
        }

        objectManager.AddObject(singleObject.GetComponent<FeelingObject>());

        updateAll();
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
            debugVisible = !debugVisible;
            
            GameObject.Find("DebugCanvas").SetActive(debugVisible);
             
        }
        
    }

    public void updateAll()
    {
        updateBGColor();
        updateBGContrast();
        objectManager.updateFGColor(sliderValues[4], sliderValues[5], sliderValues[6]);
        objectManager.updateFGContrast(sliderValues[6], sliderValues[7]);
        objectManager.updateFractionizing(sliderValues[SLIDER_ID_FRAGMENT-1]);
    }

    public void debugSliderChanged(Slider _slider)
    {
        int startIndex = _slider.name.IndexOf("(");
        int endIndex = _slider.name.IndexOf(")");
        string stringID = _slider.name.Substring(startIndex+1, (endIndex - startIndex)-1);
        int id = Convert.ToInt32(stringID);

        changeValue(id, _slider.value);
    
    }
    public void changeValue(int id, float value)
    {
        //Debug.Log(id + " changeValue value is " + value);
        sliderValues[id - 1] = value;

        if (id > 0 && id <= 3)
        {
            updateBGColor();
        }
        else if (id == 4)
        {
            updateBGContrast();
        } else if (id > 4 && id <= 7)
        {
            objectManager.updateFGColor(sliderValues[4], sliderValues[5], sliderValues[6]);
        }
        else if (id == 8)
        {
            objectManager.updateFGContrast(sliderValues[6], sliderValues[7]);
        }   else if (id == SLIDER_ID_FRAGMENT)
        {
            objectManager.updateFractionizing(sliderValues[SLIDER_ID_FRAGMENT -1]);
        }

    }

    #region updating the separate parameters

    public void updateBGColor()
    {
        bg.material.color = Color.HSVToRGB(sliderValues[0], sliderValues[1], sliderValues[2]);
    }
    public void updateBGContrast()
    {
        float minContrast = 0.1f;
        float maxContrast = 4f;
        float result = minContrast + sliderValues[3] * (maxContrast - minContrast);

        bg.material.SetFloat("_Brightness", sliderValues[2]);
        bg.material.SetFloat("_Contrast", result);
    }

    #endregion

}
