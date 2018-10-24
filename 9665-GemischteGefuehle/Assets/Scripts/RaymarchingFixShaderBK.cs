using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using RaymarchingToolkit;
using System.IO;
//using UnityEditor;

[ExecuteInEditMode]
public class RaymarchingFixShaderBK : MonoBehaviour {
 
	// Use this for initialization
	void Start () {
		
	}

    Raymarcher ray;

    static void WriteString(string path, string text)
    {

        //writeShader some text to the test.txt file
        StreamWriter writer = new StreamWriter(path, true);
        writer.Write(text);
        writer.Close();

        //Re-import the file to update the reference in the editor
        //AssetDatabase.ImportAsset(path);
        TextAsset asset = (TextAsset) Resources.Load("test");

    }

    static void ReadString(string path)
    {
     

        //readShader the text from directly from the test.txt file
        StreamReader reader = new StreamReader(path);
        test1 = reader.ReadToEnd();
        reader.Close();  
    }
    
    // Update is called once per frame
    void Update () {
        //test = test1;
        if (readShader)
        {
            readShader = false;
            if (ray == null)
            {
                ray = FindObjectOfType<Raymarcher>();
                if (ray == null) return;
            }
            generatedShader = ray.GetRaymarchMaterial().shader;
            if (generatedShader == null) return;
            path = generatedShader.name;
            path = path.Remove(0, path.IndexOf('/', 0) + 1);
            path = Application.dataPath + "/Scenes/Shaders/Generated/" + path + ".shader";
            ReadString(path);
            info = "done, now delete shader (click generated shader below)";
            writeShader = true;
        }
        if(writeShader && !File.Exists(path))
        {
            writeShader = false;
            test1 = test1.Replace(",5)", ".5)");
            WriteString(path,test1);
            info = "please tick read shader box above";
}
    }
    public string info = "please tick read shader box above";
    public bool readShader;
    public Shader generatedShader;
    bool writeShader = false;
    public string path;
    public static string test1;



}
