﻿Shader "Custom/AppearShader2"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _AppearValue("Appear Value", Range(0, 1)) = 0.5
        _LastAppearValue("Last Appear Value", Range(0, 1)) = 0.5
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 100

            BlendOp Add
            Blend SrcAlpha OneMinusSrcAlpha
            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                // make fog work
                #pragma multi_compile_fog

                #include "UnityCG.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    UNITY_FOG_COORDS(1)
                    float4 vertex : SV_POSITION;
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;
                float _AppearValue;
                float _LastAppearValue;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    UNITY_TRANSFER_FOG(o,o.vertex);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    fixed range = length(i.uv - fixed2(0.5, 0.5)) * 2;
                    fixed4 col = tex2D(_MainTex, i.uv);
                    if (range > _AppearValue)
                        return fixed4(0, 0, 0, 0);
                    if (range > _LastAppearValue && range < _AppearValue)
                        return lerp(fixed4(col.x, col.y, col.z, 0), col, (range - _LastAppearValue) / (range - _AppearValue));
                    UNITY_APPLY_FOG(i.fogCoord, col);
                    return col;
                }
                ENDCG
            }
        }
}
