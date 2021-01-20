using UnityEditor;
using System.IO;
using UnityEngine;

public class CreateAssetBundles
{
	[MenuItem("Assets/Build AssetBundles")]
	static void BuildAllAssetBundles()
	{
		string assetBundleDirectory = "AssetBundles";
		if(!Directory.Exists(assetBundleDirectory))
		{
			Directory.CreateDirectory(assetBundleDirectory);
		}
		BuildPipeline.BuildAssetBundles(Application.streamingAssetsPath, 
			BuildAssetBundleOptions.UncompressedAssetBundle, 
			BuildTarget.StandaloneWindows);
	}
}