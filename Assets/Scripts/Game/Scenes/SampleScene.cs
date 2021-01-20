using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class SampleScene : MonoBehaviour
{
	// Start is called before the first frame update
	void Start()
	{
		// this.transform.Find();
		var myLoadedAssetBundle =
			AssetBundle.LoadFromFile(Path.Combine(Application.streamingAssetsPath, "test_bundle"));
		if (myLoadedAssetBundle == null)
		{
			Debug.Log("Failed to load AssetBundle!");
			return;
		}
		
		var textAsset = myLoadedAssetBundle.LoadAsset<TextAsset>("Assets/AssetsPackages/Excels/test.txt");
		Debug.Log(textAsset.text);
		// Instantiate(prefab);
	}

	// Update is called once per frame
	void Update()
	{
	}
}