using System;
using UnityEngine;
using UnityEngine.UI;

public class InputManager : MonoBehaviour {
    public BmcmSensor usbAD;

    const int NUM_SLIDER = 14;
    public float[] sliderValues = new float[NUM_SLIDER];
    Slider[] sliders = new Slider[NUM_SLIDER];
    float minSensorValue = 0;
    float maxSensorValue = 5;
    int counter = 0;

    public bool useSensor = false;

    private int senderPort;
    private float MOVEMENT_THRESHOLD = 0.2f;
    private int UPDATE_FREQ = 2;

    void Start () {

        useSensor = Configuration.GetInnerTextByTagName("useSensor", "0") == "1";
        minSensorValue = Configuration.GetInnerTextByTagName("minSensorValue", 0);
        maxSensorValue = Configuration.GetInnerTextByTagName("maxSensorValue", 5);
        senderPort = Convert.ToInt32( Configuration.GetInnerTextByTagName("senderPort", 4567));


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
            if (counter % UPDATE_FREQ == 0) {
                bool movement = false;
                for (int i = 0; i < NUM_SLIDER; i++)
                {
                    float newValue = 1 - Mathf.InverseLerp(minSensorValue, maxSensorValue, usbAD.GetAnalogIn(i));
                    if (Mathf.Abs(sliderValues[i] - newValue) > MOVEMENT_THRESHOLD)
                    {
                        movement = true;
                    }

                    sliderValues[i] = newValue;

                    //Debug.Log(sliderValues[i]);
                    sliders[i].value = sliderValues[i];
                }
                if (movement)
                    UDPSender.SendUDPStringASCII("127.0.0.1", senderPort, "movement");
            }
            counter++;
        }
    }

    public void changeValue(int id, float value)
    {
        //Debug.Log(id + " changeValue value is " + value);
        sliderValues[id - 1] = value;
    }

}
