Shader "TestShader"
{
    Properties
    {
        _MyFloat("MyFloat", Float) = 1.0
        _MyRange("MyRange", Range(0.0, 1.0)) = 0.0
        _MyVector("MyVector", Vector) = (0.0, 0.0, 0.0, 0.0)
        _MyColor("Mycolor", Color) = (0.0, 0.0, 0.0, 0.0)
        _MyTexture("MyTexture", 2D) = "black" {}
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 _MyColor;
            sampler2D _MyTexture;

            float4 frag(v2f i):SV_Target
            {
                float4 col = tex2D(_MyTexture, i.uv);
                return col;
            }
            
            ENDCG
        }
    }
}