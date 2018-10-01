using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SenderReceiver : MonoBehaviour {

    static string ip = "127.0.0.1";
    static int    senderPort, listenerPort;

    static public bool sendMousePos = false;

    static UDPListener listener;


    void Start () {
        ip = Configuration.GetInnerTextByTagName("ip", "127.0.0.1");
        senderPort = Convert.ToInt32(Configuration.GetInnerTextByTagName("senderPort", "5111"));
        listenerPort = Convert.ToInt32(Configuration.GetInnerTextByTagName("listenerPort", "4111"));

        listener = new UDPListener();

        listener.Start(listenerPort, OnReceive);
    }
	
	void Update () {
        if (Input.GetMouseButtonDown(0))
        {
            TurnMouseOnOff(true);
        } else if (Input.GetMouseButtonUp(0))
        {
            TurnMouseOnOff(false);
        }

        // test
        //if(sendMousePos)
        //    SendMousePosition(Input.mousePosition.x ,Input.mousePosition.y);
    }

    public static void SendMousePosition(float x, float y)
    {
        string message = "mouse," + x + "," + (1-y);
        UDPSender.SendUDPStringASCII(ip, senderPort, message);
    }
    public static void SendTrackingData(float diff, int numOfTracking)
    {
        string message = "tracking," + diff + "," + numOfTracking;
        UDPSender.SendUDPStringASCII(ip, senderPort, message);
    }
    public static void SendCustomMessage(string message)
    {
        UDPSender.SendUDPStringASCII(ip, senderPort, message);
    }

    public static void TurnMouseOnOff(bool onoff)
    {
        sendMousePos = onoff;
        if(onoff)
            UDPSender.SendUDPStringASCII(ip, senderPort, "cursor_on");
        else
            UDPSender.SendUDPStringASCII(ip, senderPort, "cursor_off");
    }

    public void OnReceive(string data, int port)
    {
        Debug.Log("Received: " + data);
        if (data.IndexOf("start") > -1)
        {
            string[] split = data.Split(',');
        }
        else if (data.IndexOf("stop") > -1)
        {
        }
        else if (data == "ping")
        {
            SendCustomMessage("ping");
        }
    }

    public void OnApplicationQuit()
    {
        Debug.Log("Closing listener");
        listener.Close();
    }
}
