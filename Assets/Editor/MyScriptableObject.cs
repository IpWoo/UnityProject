using System.Collections.Generic;
using UnityEngine;

namespace Editor
{
	[CreateAssetMenu]
	public class MyScriptableObject : ScriptableObject
	{
		[SerializeField] public List<PlayerInfo> m_PlayerInfo;

		[System.Serializable]
		public class PlayerInfo
		{
			public int id;
			public string name;
		}
	}
}