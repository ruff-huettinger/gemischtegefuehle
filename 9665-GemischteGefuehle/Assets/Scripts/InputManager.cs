﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class InputManager : MonoBehaviour {


    public BmcmSensor usbAD;

    const int NUM_SLIDER = 14;
    public float[] sliderValues = new float[NUM_SLIDER];
    Slider[] sliders = new Slider[NUM_SLIDER];
    float minSensorValue = 0;
    float maxSensorValue = 5;

    public bool useSensor = false;

    void Start () {

        useSensor = Configuration.GetInnerTextByTagName("useSensor", "0") == "1";
        minSensorValue = Configuration.GetInnerTextByTagName("minSensorValue", 0);
        maxSensorValue = Configuration.GetInnerTextByTagName("maxSensorValue", 5);


        if (useSensor)
        {
            usbAD = new BmcmSensor("usb-ad");
            usbAD.Init();
        }

        for (int i = 0; i < NUM_SLIDER; i++)
        {
            sliders[i] = GameObject.Find("Slider (" + (i + 1) + ")").GetComponent<Slider>();
            sliderValues[i] = sliders[i].value;
        }
    }
	
	void FixedUpdate () {
        if (useSensor)
        {
            for (int i = 0; i < NUM_SLIDER; i++)
            {
                sliderValues[i] = 1 - Mathf.InverseLerp( minSensorValue, maxSensorValue, usbAD.GetAnalogIn(i));

                //Debug.Log(sliderValues[i]);
                sliders[i].value = sliderValues[i];
            }
        }
    }

    public void changeValue(int id, float value)
    {
        //Debug.Log(id + " changeValue value is " + value);
        sliderValues[id - 1] = value;
    }

}