using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class FrameRate : MonoBehaviour {

    Text Textfeld;
	// Use this for initialization
	void Start () {
        Textfeld = GetComponent<Text>();
	}

    float fps = 60;

	// Update is called once per frame
	void Update () {
        fps = Mathf.Lerp(fps, 1 / Time.deltaTime, 0.1f);
        Textfeld.text = fps.ToString("N2")+" fps";
	}
}
