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

    public float fps = 60;
    public float smoothFps = 60;
    public float smoothtime = 0;
    public float smoothtimeB = 0;
    public float maxTime = 0;
    public float maxTimeB = 0;
    public float time;

    // Update is called once per frame
    void Update () {
        float frametime = Time.realtimeSinceStartup - time;
        time = Time.realtimeSinceStartup;
        maxTime = Mathf.Max(Time.deltaTime, maxTime);
        maxTimeB = Mathf.Max(Mathf.Round(1000*frametime), maxTimeB);
        smoothtime = Mathf.Lerp(1000*Time.deltaTime, smoothtime, 0.9f);
        smoothtimeB = Mathf.Round(Mathf.Lerp(1000 * frametime, smoothtimeB, 0.9f));
        fps = 1 / frametime;
        smoothFps = Mathf.Lerp(fps, smoothFps, 0.9f);
        Textfeld.text = (smoothtime*1000).ToString("N0")+" fps";
	}
}
