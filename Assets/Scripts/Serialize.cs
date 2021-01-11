using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;
using Button = UnityEngine.UI.Button;
#if UNITY_EDITOR
using UnityEditor;

#endif

public class Serialize : MonoBehaviour
{
	[SerializeField] private string myName;
	[SerializeField] private GameObject prefab;

	public Button btn;

	private void Awake()
	{
		btn.onClick.AddListener(() =>
		{
			Debug.Log("hello button");
		});
	}

	public void onBtnClick()
	{
		Debug.Log("hello onBtnClick");
	}
}

// #if UNITY_EDITOR
// [CustomEditor(typeof(Serialize))]
// public class SerializeEditor : Editor
// {
// 	public override void OnInspectorGUI()
// 	{
// 		serializedObject.Update();
//
// 		SerializedProperty property = serializedObject.FindProperty("myName");
//
// 		property.stringValue = EditorGUILayout.TextField("myName", property.stringValue);
// 		
// 		EditorGUILayout.PropertyField(serializedObject.FindProperty("prefab"), true);
//
// 		serializedObject.ApplyModifiedProperties();
// 	}
// }
// #endif