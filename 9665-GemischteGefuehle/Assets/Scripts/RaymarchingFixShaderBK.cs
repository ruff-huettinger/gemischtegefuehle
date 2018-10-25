﻿using System.Collections;
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
    bool writeShader = false;
    public string path;
    public static string shaderCode;
    public System.DateTime lastWriteTime;
    public bool shaderHasBeenChanged = true;
    

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
    void Update () {
        lastUpdate = System.DateTime.Now.ToLongTimeString();
        updateThisWindow = false;
        //test = shaderCode;
        if (!observingShader && !writeShader)
            observingShader = true;
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

            shaderHasBeenChanged = File.GetLastWriteTime(path) != lastWriteTime;
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
                    Debug.LogError("shader fixed :) , please delete old shader file, so I can write a new one. \n Shader file lies in: \n" + path +"\nor click here", generatedShader);
                    return; ////////////////////////////////////////////////////////////////
                }
                else
                {
                    info = "shader looks ok";
                }
            }
        }
        if (writeShader && !File.Exists(path))
        {
            WriteString(path, shaderCode);
            Debug.Log("shader code: \n"+shaderCode);
            Debug.Log("raymarching generated shader fixed - sometimes I impress myself");
            observingShader = false;
            writeShader = true;
        }

    }




}
