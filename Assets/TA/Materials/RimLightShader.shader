Shader "Unlit/RimLightShader"
{
    Properties
    {
        _BaseColor("BaseColor", Color) = (0.0, 0.0, 0.0, 1.0)
        _RimColor("RimColor", Color) = (0.0, 0.0, 0.0, 1.0)
        _RimMax("RimMax", Range(0.0, 1.0)) = 1.0
        _RimMin("RimMin", Range(0.0, 1.0)) = 0.0
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

            half _RimMax;
            half _RimMin;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // o.world_normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject));
                o.world_normal = normalize(UnityObjectToWorldNormal(v.normal));
                o.world_pos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            half4 frag(v2f i) :SV_Target
            {
                // float3 view_dir = normalize(UnityWorldSpaceViewDir(i.world_pos));
                half3 view_world = normalize(_WorldSpaceCameraPos - i.world_pos);
                half3 world_normal = normalize(i.world_normal);
                half NdotV = saturate(dot(world_normal, view_world));
                half fresnel = 1.0 - NdotV;
                fresnel = smoothstep(_RimMin, _RimMax, fresnel);
                _RimColor = _RimColor * fresnel;
                half4 col = _BaseColor + _RimColor;
                return col;
            }
            ENDCG
        }
    }
}