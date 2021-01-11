using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FPS : MonoBehaviour
{
    private void Awake()
    {
        Debug.LogFormat("FPS Awake:{0}", Time.time);
    }

    // Start is called before the first frame update
    void Start()
    {
        Debug.LogFormat("FPS Start:{0}", Time.time);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnGUI()
    {
        GUIStyle guiStyle = GUIStyle.none; 
        guiStyle.fontSize = 30; 
        guiStyle.normal.textColor = Color.red; 
        guiStyle.alignment = TextAnchor.UpperLeft; 
        Rect rt = new Rect( 40, 0, 100, 100); 
        GUI.Label( rt, "stringFps", guiStyle);
    }
}
