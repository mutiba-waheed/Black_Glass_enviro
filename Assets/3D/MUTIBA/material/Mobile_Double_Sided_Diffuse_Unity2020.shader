Shader "Custom/Mobile/Double Sided Diffuse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        // Render both front and back faces
        Cull Off
        ZWrite On

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i, fixed facing : VFACE) : SV_Target
            {
                fixed3 normal = normalize(i.worldNormal);

                // Flip normal on back faces so lighting works on both sides.
                if (facing < 0)
                    normal = -normal;

                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed NdotL = saturate(dot(normal, lightDir));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 lighting = ambient + _LightColor0.rgb * NdotL;

                fixed4 tex = tex2D(_MainTex, i.uv) * _Color;

                return fixed4(tex.rgb * lighting, tex.a);
            }
            ENDCG
        }
    }

    FallBack "Mobile/Diffuse"
}
