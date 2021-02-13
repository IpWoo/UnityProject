Shader "Custom/ShaderMobileCharacter"
{
    Properties
    {
        _BaseMap("BaseMap", 2D) = "white"{}
        _CompMask("CompMask(RM)", 2D) = "white"{}
        _NormalMap("NormalMap", 2D) = "bump"{}
        _SpecShininess("SpecShininess", Float) = 10
        _RoughnessAdjust("RoughnessAdjust", Range(-1, 1)) = 0
        _MetalAdjust("MetalAdjust", Range(-1, 1)) = 0

        _SkinLUT("SkinLUT", 2D) = "black"{}
        _CurveOffset("CurveOffset", Range(-1, 1)) = 0
        _SSSOffset("SSSOffset", Range(-1, 1)) = 0

        [Header(IBL)]
        _EnvMap("EnvMap",Cube) = "white"{}
        _Tint("Tint",Color) = (1,1,1,1)
        _Expose("Expose",Float) = 1.0
        _Rotate("Rotate",Range(0,360)) = 0

        custom_SHAr("Custom SHAr", Vector) = (0, 0, 0, 0)
        custom_SHAg("Custom SHAg", Vector) = (0, 0, 0, 0)
        custom_SHAb("Custom SHAb", Vector) = (0, 0, 0, 0)
        custom_SHBr("Custom SHBr", Vector) = (0, 0, 0, 0)
        custom_SHBg("Custom SHBg", Vector) = (0, 0, 0, 0)
        custom_SHBb("Custom SHBb", Vector) = (0, 0, 0, 0)
        custom_SHC("Custom SHC", Vector) = (0, 0, 0, 1)
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
            half _SpecShininess;

            float _RoughnessAdjust;
            float _MetalAdjust;

            sampler2D _SkinLUT;
            float _CurveOffset;
            float _SSSOffset;

            samplerCUBE _EnvMap;
            float4 _EnvMap_HDR;
            float4 _Tint;
            float _Expose;

            half4 custom_SHAr;
            half4 custom_SHAg;
            half4 custom_SHAb;
            half4 custom_SHBr;
            half4 custom_SHBg;
            half4 custom_SHBb;
            half4 custom_SHC;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;

                o.normal_dir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                // o.normal_dir = UnityObjectToWorldNormal(v.normal);
                o.tangent_dir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
                // o.tangent_dir = UnityObjectToWorldDir(v.tangent);
                o.binormal_dir = normalize(cross(o.normal_dir, o.tangent_dir)) * v.tangent.w;
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            half3 custom_sh(float3 normal_dir)
            {
                float4 normalForSH = float4(normal_dir, 1.0);
                //SHEvalLinearL0L1
                half3 x;
                x.r = dot(custom_SHAr, normalForSH);
                x.g = dot(custom_SHAg, normalForSH);
                x.b = dot(custom_SHAb, normalForSH);

                //SHEvalLinearL2
                half3 x1, x2;
                // 4 of the quadratic (L2) polynomials
                half4 vB = normalForSH.xyzz * normalForSH.yzzx;
                x1.r = dot(custom_SHBr, vB);
                x1.g = dot(custom_SHBg, vB);
                x1.b = dot(custom_SHBb, vB);

                // Final (5th) quadratic (L2) polynomial
                half vC = normalForSH.x * normalForSH.x - normalForSH.y * normalForSH.y;
                x2 = custom_SHC.rgb * vC;

                float3 sh = max(float3(0.0, 0.0, 0.0), (x + x1 + x2));
                sh = pow(sh, 1.0 / 2.2);
                return sh;
            }

            float3 ACES_Tonemapping(float3 x)
            {
                float a = 2.51f;
                float b = 0.03f;
                float c = 2.43f;
                float d = 0.59f;
                float e = 0.14f;
                return saturate((x * (a * x + b)) / (x * (c * x + d) + e));
            };

            half4 frag(v2f i) : SV_Target
            {
                // Texture Info
                half4 albedo_color_gamma = tex2D(_BaseMap, i.uv);
                half4 albedo_color = pow(albedo_color_gamma, 2.2);
                half4 comp_mask = tex2D(_CompMask, i.uv);
                half metal = saturate(comp_mask.g + _RoughnessAdjust);
                half roughness = saturate(comp_mask.r + _MetalAdjust);
                half skin_area = 1.0 - comp_mask.b;
                half3 base_color = albedo_color.rgb * (1 - metal);
                half3 spec_color = lerp(0.04, albedo_color, metal);
                half3 normal_data = UnpackNormal(tex2D(_NormalMap, i.uv));

                // Dir
                half3 view_dir = normalize(_WorldSpaceCameraPos - i.pos_world);
                half3 normal_dir = normalize(i.normal_dir);
                half3 tangent_dir = normalize(i.tangent_dir);
                half3 binormal_dir = normalize(i.binormal_dir);
                float3x3 TBN = float3x3(tangent_dir, binormal_dir, normal_dir);
                normal_dir = normalize(mul(normal_data.xyz, TBN));

                // Light Info
                half3 light_dir = normalize(_WorldSpaceLightPos0.xyz);
                half atten = LIGHT_ATTENUATION(i);

                // Direct Diffuse
                half diff_term = max(0.0, dot(normal_dir, light_dir));
                half3 common_diffuse = diff_term * _LightColor0.xyz * atten * base_color.xyz;
                
                float2 uv_lut = float2(diff_term * atten + _SSSOffset, _CurveOffset);
                float3 lut_color_gamma = tex2D(_SkinLUT, uv_lut);
                half3 lut_color = pow(lut_color_gamma, 2.2);
                half half_lambert = (diff_term + 1.0) * 0.5;
                half3 sss_diffuse = lut_color * base_color * half_lambert * _LightColor0.xyz;

                half3 direct_diffuse = lerp(common_diffuse, sss_diffuse, skin_area);

                // Direct Specular
                half3 half_dir = normalize(light_dir + view_dir);
                half smoothness = 1.0 - roughness;
                half shininess = lerp(1, _SpecShininess, smoothness);
                half spec_term = pow(max(0.0, dot(normal_dir, half_dir)), shininess);
                half3 spec_skin_color = lerp(spec_color, 0.1, skin_area);
                half3 direct_specular = spec_term * spec_skin_color * atten * _LightColor0;
                

                // Indirect diffuse
                half3 env_diffuse = custom_sh(normal_dir) * base_color * half_lambert;
                env_diffuse = lerp(env_diffuse * 0.5, env_diffuse* 0.8, skin_area);

                // Indirect Specular
                half3 reflect_dir = reflect(-view_dir, normal_dir);
                roughness = roughness * (1.7 - 0.7 * roughness);
                float mip_level = roughness * 6.0;

                half4 color_cubemap = texCUBElod(_EnvMap, float4(reflect_dir, mip_level));
                half3 env_color = DecodeHDR(color_cubemap, _EnvMap_HDR);
                half3 env_specular = env_color * _Expose * spec_color * half_lambert;

                float3 final_color = direct_diffuse + direct_specular + env_diffuse + env_specular;
                final_color = ACES_Tonemapping(final_color);
                final_color = pow(final_color, 1.0 / 2.2);

                half4 col = half4(final_color, 1.0);
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}