using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectManager : MonoBehaviour {

    List<FeelingObject> objectList = new List<FeelingObject>();

	void Start () {
		
	}
	
	void Update () {
		
	}

    public void AddObject(FeelingObject fo)
    {
        if (!objectList.Contains(fo))
        {
            objectList.Add(fo);
        }
    }
    public void RemoveObjects(int amount)
    {

    }


    public void updateFGColor(float h, float s, float v)
    {
        foreach (FeelingObject fo in objectList)
        {
            fo.material.color = Color.HSVToRGB(h, s, v);
        }
    }
    public void updateFGContrast(float brightness, float contrast)
    {
        float minContrast = 0.1f;
        float maxContrast = 4;
        float result = minContrast + contrast * (maxContrast - minContrast);

        foreach (FeelingObject fo in objectList)
        {
            fo.material.SetFloat("_Brightness", brightness);
            fo.material.SetFloat("_Contrast", result);
        }
    }
    public void updateFractionizing(float value)
    {
        float fragFactor = 2.0f;
        foreach (FeelingObject fo in objectList)
        {
            fo.material.SetFloat("_FractAmount", value * fragFactor);
        }
    }
}
