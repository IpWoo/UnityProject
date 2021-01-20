using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class SampleScene : MonoBehaviour
{
	// Start is called before the first frame update
	void Start()
	{
		var myLoadedAssetBundle =
			AssetBundle.LoadFromFile(Path.Combine(Application.streamingAssetsPath, "test_bundle"));
		if (myLoadedAssetBundle == null)
		{
			Debug.Log("Failed to load AssetBundle!");
			return;
		}

		var prefab = myLoadedAssetBundle.LoadAsset<GameObject>("MyObject");
		Instantiate(prefab);
	}

	// Update is called once per frame
	void Update()
	{
	}
}