using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using RaymarchingToolkit;
using System.IO;
//using UnityEditor;

[ExecuteInEditMode]
public class RaymarchingFixShaderBK : MonoBehaviour {
 
    Raymarcher ray;
    public bool updateThisWindow = false;
    public string lastUpdate = "never";
    [Header("info only, dont change any values")]
    public bool observingShader = true;
    public Shader generatedShader;
    public string info = "Starting shader fix";
    public bool writeShader = false;
    public string path;
    public static string shaderCode;
     System.DateTime lastWriteTime = System.DateTime.MaxValue;
    public bool shaderHasBeenChanged = true;

    public void OnApplicationQuit()
    {
        observingShader = true;
    }
    public void Start()
    {
        observingShader = true;
    }

    public void FixedUpdate()
    {
        observingShader = false;
        writeShader = false;
    }

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
        //observingShader the text from directly from the test.txt file
        StreamReader reader = new StreamReader(path);
        shaderCode = reader.ReadToEnd();
        reader.Close();  
    }



    // Update is called once per frame
    [ExecuteInEditMode]
    void Update () {
        lastUpdate = System.DateTime.Now.ToLongTimeString();
        updateThisWindow = false;
        //test = shaderCode;




        if (observingShader)
        {
            //see if there is a raymarcher
            if (ray == null)
            {
                ray = FindObjectOfType<Raymarcher>();
                if (ray == null)
                    return; ////////////////////////////////////////////////////////////////
            }
            // get its shader
            generatedShader = ray.GetRaymarchMaterial().shader;
;            if (generatedShader == null || generatedShader.name == "Hidden/InternalErrorShader")
            {
                //shader has gone, see if there is something in the cache
                info = "shader missing";
                if (shaderCode !=null && shaderCode.Length > 0 && path != null && path.Length>0)
                {
                    Debug.Log("shader file was gone, but I have cached some shader data and will write them to the file " + path);
                 
                    info += "- writing shader from cache";
                    observingShader = false;
                    writeShader = true;
                }
                else
                {
                    Debug.LogError("the shader is missing and nothing has been cashed, please regenerate the shader by pressing 'compile', if neccesairy disable auto compile", ray.gameObject);
                }
                return; ////////////////////////////////////////////////////////////////
            }
            path = generatedShader.name;
            path = path.Remove(0, path.IndexOf('/', 0) + 1);
            path = Application.dataPath + "/Scenes/Shaders/Generated/" + path + ".shader";

            if (shaderHasBeenChanged)
            {
                lastWriteTime = File.GetLastWriteTime(path);
                info = "shader changed, reading file";
                ReadString(path);

                if (shaderCode.Contains(",5)"))
                {

                    observingShader = false;
                    shaderCode = shaderCode.Replace(",5)", ".5)");
                    writeShader = true;
                    info = "shader fixed, delete old shader file (click generated shader below)";
                    //Debug.LogError("shader fixed :) , please delete old shader file, so I can write a new one. \n Shader file lies in: \n" + path +"\nor click here", generatedShader);
                }
                else
                {
                    info = "shader looks ok";
                    writeShader = false;
                }
            }
            shaderHasBeenChanged = File.GetLastWriteTime(path) != lastWriteTime;
        }

        if (writeShader)
        {
            if (File.Exists(path))
            {
                FileInfo fileinfo = new FileInfo(path);
                fileinfo.IsReadOnly = false;
                File.Delete(path);
                return;
            }
            else
            {
                WriteString(path, shaderCode);
                Debug.Log("shader code: \n" + shaderCode);
                Debug.Log("raymarching generated shader fixed - sometimes I impress myself");
                lastWriteTime = File.GetLastWriteTime(path);
                shaderHasBeenChanged = false;
                observingShader = true;
                writeShader = false;
                UnityEditor.AssetDatabase.Refresh();
                return;
            }

        }


    }

}
