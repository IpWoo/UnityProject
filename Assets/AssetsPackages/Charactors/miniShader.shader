// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "miniShader"
{
    Properties
    {
        _MainTexture("MyTexture", 2D) = "red"{}
        MyFloat("MyFloat", float) = 0.0
        MyRange("MyRange", range(0.0, 1.0)) = 0.0
        MyVector("MyVector", vector) = (1.0, 1.0, 1.0, 1.0)
        //        MyColor("MyColor", color) = (0.0, 1.0, 1.0, 1.0)
        MyColor1("MyColor", Color) = (0.0, 1.0, 0.0, 1.0)
        [Enum(UnityEngine.Rendering.CullMode)] MyCullMode("MyCullMode", int) = 2
    }

    SubShader
    {
        Pass
        {
            Cull [MyCullMode]
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            float4 MyColor1;
            sampler2D _MainTexture;
            float4 _MainTexture_ST;

            v2f vert(appdata v)
            {
                
                v2f o;
                // float4 pos_world = mul(unity_ObjectToWorld, v.vertex);
                // float4 pos_view = mul(UNITY_MATRIX_V, pos_world);
                // float4 pos_clip = mul(UNITY_MATRIX_P, pos_view);
                // o.pos = pos_clip;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * _MainTexture_ST.xy + _MainTexture_ST.zw;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTexture, i.uv);
                return col;
            }
            ENDCG
            
        }
    }
}