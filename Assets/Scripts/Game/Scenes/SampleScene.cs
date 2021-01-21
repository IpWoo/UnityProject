using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class SampleScene : MonoBehaviour
{
    public string myName;
    public int myId;
    public GameObject obj;

    private void Awake()
    {
        Debug.Log("Awake");
    }

    private void OnEnable()
    {
        Debug.Log("OnEnable");
    }

    void Start()
    {
        Debug.Log("Start");
        StartCoroutine("Print");
    }

    IEnumerator Print()
    {
        for (;;)
        {    
            Debug.Log("hello");
            yield return new WaitForSeconds(1f);
        }
    }

    void Update()
    {
    }
}