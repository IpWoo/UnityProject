using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AMyCoroutine : MonoBehaviour{
	
	private void Awake()
	{
		Debug.LogFormat("MyCoroutine Awake:{0}", Time.time);
	}
	private void Start()
	{
		Debug.LogFormat("MyCoroutine Start:{0}", Time.time);
	}

	IEnumerator CreateConsole()
	{
		for (int i = 0; i < 100; i++)
		{
			Debug.LogFormat("CreateConsole:{0}", i);
			yield return new WaitForSeconds(1f);
		}
	}

	private Coroutine m_coroutine;
	private void OnGUI()
	{
		if (GUILayout.Button("StartCoroutine"))
		{
			m_coroutine = StartCoroutine(CreateConsole());
		}

		if (GUILayout.Button("StopCoroutine"))
		{
			StopCoroutine(m_coroutine);
		}
	}
}