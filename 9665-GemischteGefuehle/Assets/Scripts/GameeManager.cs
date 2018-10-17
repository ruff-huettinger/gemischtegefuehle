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


    private int SLIDER_ID_FRAGMENT = 9;

    public InputManager inputManagerRef;

	void Awake() {
        Configuration.LoadConfig();
	}

    private void Start()
    {
        objectManager = GameObject.FindObjectOfType<ObjectManager>();
        bg = GameObject.Find("BG").GetComponent<RawImage>();
        singleObject = GameObject.Find("SingleObject");
        singleObjectRenderer = GameObject.Find("SingleObject").GetComponent<Renderer>();

        if (inputManagerRef == null)
            inputManagerRef = GameObject.FindObjectOfType<InputManager>();

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
        //objectManager.updateFGColor(inputManagerRef.sliderValues[4], inputManagerRef.sliderValues[5], inputManagerRef.sliderValues[6]);
        //objectManager.updateFGContrast(inputManagerRef.sliderValues[6], inputManagerRef.sliderValues[7]);
        //objectManager.updateFractionizing(inputManagerRef.sliderValues[SLIDER_ID_FRAGMENT-1]);
    }

    public void debugSliderChanged(Slider _slider)
    {
        int startIndex = _slider.name.IndexOf("(");
        int endIndex = _slider.name.IndexOf(")");
        string stringID = _slider.name.Substring(startIndex+1, (endIndex - startIndex)-1);
        int id = Convert.ToInt32(stringID);

        inputManagerRef.changeValue(id, _slider.value);

        updateAll();


    }
    

    #region updating the separate parameters

    public void updateBGColor()
    {
        bg.material.color = Color.HSVToRGB(inputManagerRef.sliderValues[0], inputManagerRef.sliderValues[1], inputManagerRef.sliderValues[2]);
    }
    public void updateBGContrast()
    {
        float minContrast = 0.1f;
        float maxContrast = 4f;
        float result = minContrast + inputManagerRef.sliderValues[3] * (maxContrast - minContrast);

        bg.material.SetFloat("_Brightness", inputManagerRef.sliderValues[2]);
        bg.material.SetFloat("_Contrast", result);
    }

    #endregion

}
