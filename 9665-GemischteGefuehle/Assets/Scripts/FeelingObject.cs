using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FeelingObject : MonoBehaviour {

    public float angularSpeedX = 0.01f;
    public float angularSpeedY = 0.1f;
    public float angularSpeedZ = 0.01f;

    public Material material;

	void Awake () {
        material = GetComponent<Renderer>().material;
	}
	
	void Update () {
        transform.Rotate(new Vector3(angularSpeedX, angularSpeedY, angularSpeedZ));
	}

    void UpdateSize(float site)
    {

    }
}
