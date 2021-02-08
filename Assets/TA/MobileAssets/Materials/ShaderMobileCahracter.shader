Shader "Custom/ShaderMobileCahracter"
{
    Properties
    {
        _BaseMap("BaseMap", 2D) = "white"{}
        _CompMask("CompMask(RM)", 2D) = "white"{}
        _NormalMap("NormalMap", 2D) = "bump"{}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            Tags
            {
                "LightMod"="ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal_dir : TEXCOORD1;
                float3 pos_world : TEXCOORD2;
                float3 tangent_dir : TEXCOORD3;
                float3 binormal_dir : TEXCOORD4;
                LIGHTING_COORDS(5, 6)
            };

            sampler2D _BaseMap;
            sampler2D _CompMask;
            sampler2D _NormalMap;
            half4 _LightColor0;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;

                // o.normal_dir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                o.normal_dir = UnityObjectToWorldNormal(v.normal);
                // o.tangent_dir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
                o.tangent_dir = UnityObjectToWorldDir(v.tangent);
                o.binormal_dir = normalize(cross(o.normal_dir, o.tangent_dir)) * v.tangent.w;
                o.pos_world = mul(unity_ObjectToWorld, v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                // Texture Info
                half4 base_color_gamma = tex2D(_BaseMap, i.uv);
                half4 albedo_color = pow(base_color_gamma, 2.2);
                half4 comp_mask = tex2D(_CompMask, i.uv);
                half metal = comp_mask.g;
                half3 base_color = albedo_color.rgb * (1 - metal);
                half3 spec_color = lerp(0.00, albedo_color, metal);
                half3 normal_data = UnpackNormal(tex2D(_NormalMap, i.uv));

                // Dir
                half3 view_dir = normalize(_WorldSpaceCameraPos - i.pos_world);
                half3 normal_dir = normalize(i.normal_dir);
                half3 tangent_dir = normalize(i.tangent_dir);
                half3 binormal_dir = normalize(i.binormal_dir);
                float3x3 TBN = float3x3(tangent_dir, binormal_dir, normal_dir);
                normal_dir = normalize(mul(normal_dir, TBN));

                // Light Info
                half3 light_dir = normalize(_WorldSpaceLightPos0.xyz);
                half atten = LIGHT_ATTENUATION(i);

                // Direct Diffuse
                half NDotL = max(0.0, dot(normal_dir, light_dir));
                half3 direct_diffuse = NDotL * base_color * atten * _LightColor0 ;

                half4 col = half4(direct_diffuse, 1.0);
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}