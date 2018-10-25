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
        if (!readShader && !writeShader)
            readShader = true;
        if (readShader)
        {
            //see if there is a raymarcher
            if (ray == null)
            {
                ray = FindObjectOfType<Raymarcher>();
                if (ray == null) return;
            }
            // get its shader
            generatedShader = ray.GetRaymarchMaterial().shader;
;            if (generatedShader == null || generatedShader.name == "Hidden/InternalErrorShader")
            {
                //shader has gone, see if there is something in the cache
                info = "shader missing";
                if (test1 !=null && test1.Length > 0 && path != null && path.Length>0)
                {
                    info += "- writing shader from cache";
                    readShader = false;
                    writeShader = true;
                }
                else
                {
                    Debug.LogError("the shader is missing and nothing has been cashed, please regenerate the shader by pressing 'compile', if neccesairy disable auto compile", ray.gameObject);
                }
                return;
            }
            path = generatedShader.name;
            path = path.Remove(0, path.IndexOf('/', 0) + 1);
            path = Application.dataPath + "/Scenes/Shaders/Generated/" + path + ".shader";
            ReadString(path);
            
            if (test1.Contains(",5)"))
            {

                readShader = false;
                 test1 = test1.Replace(",5)", ".5)");
                writeShader = true;
                info = "shader fixed, delete old shader file (click generated shader below)";
                Debug.LogError("found problem in shader, please delete old shader file " + path, generatedShader);
                return;
            }
            else
            {
                info = "shader looks ok";
            }
        }
        if (writeShader && !File.Exists(path))
        {
            WriteString(path, test1);
            Debug.Log("raymarching generated shader fixed - sometimes I impress myself");
            readShader = false;
            writeShader = true;
        }

    }
    public string info = "please tick read shader box above";
    bool readShader = true;
    public Shader generatedShader;
    bool writeShader = false;
    public string path;
    public static string test1;



}
