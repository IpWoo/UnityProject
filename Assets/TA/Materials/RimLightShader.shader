Shader "Unlit/RimLightShader"
{
    Properties
    {
        _BaseColor("BaseColor", Color) = (0.0, 0.0, 0.0, 1.0)
        _RimColor("RimColor", Color) = (0.0, 0.0, 0.0, 1.0)
        _RimPower("RimPower", Float) = 0.0
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
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 world_normal : TEXCOORD0;
                float3 world_pos : TEXCOORD1;
            };

            half4 _BaseColor;
            half4 _RimColor;
            float _RimPower;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.world_normal = UnityObjectToWorldNormal(v.normal);
                o.world_pos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            half4 frag(v2f i) :SV_Target
            {
                float3 view_dir = normalize(UnityWorldSpaceViewDir(i.world_pos));
                float rim = pow(1.0 - dot(view_dir, normalize(i.world_normal)), _RimPower);
                float4 rim_color = _RimColor * rim;//float4(_RimColor.xyz * rim, 1.0);
                half4 col = _BaseColor + rim_color;
                return col;
            }
            ENDCG
        }
    }
}