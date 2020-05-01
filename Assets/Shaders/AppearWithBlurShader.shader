Shader "Custom/AppearShaderBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AppearValue("Appear Value", Range(0, 1)) = 0.5
        _LastAppearValue("Last Appear Value", Range(0, 1)) = 0.5

        _BlurDistance("Blur Distance", Range(0, 1)) = 0.1
        _BlurPower("Blur Power", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        BlendOp Add
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
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
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4  _MainTex_TexelSize;

            float _AppearValue;
            float _LastAppearValue;

            float _BlurDistance;
            float _BlurPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f input) : SV_Target
            {
                fixed range = length(input.uv - fixed2(0.5, 0.5)) * 2;

                if (range > _AppearValue)
                    return fixed4(0, 0, 0, 0);

                fixed t_range;
                fixed2 pixelPos;
                fixed totalWeight = 0;
                #define RANGECHECK t_range = length(pixelPos - fixed2(0.5, 0.5)) * 2; if (t_range <= _AppearValue)
                #define PIXELPOS(dx, dy) pixelPos = input.uv + float2(dx, dy);
                #define SAMPLE(dx, dy, weight) PIXELPOS(dx, dy) RANGECHECK col += weight * tex2D(_MainTex, pixelPos); totalWeight += weight;

                fixed4 col = 0;

                #define STEP_COUNT 8
                fixed coeff = 1.0 / (STEP_COUNT * 4);

                for (int i = 1; i <= STEP_COUNT; i++) {
                    fixed distance = _BlurDistance * i / STEP_COUNT;

                    SAMPLE(distance,  0, coeff)
                    SAMPLE(-distance, 0, coeff)
                    SAMPLE(0, distance, coeff)
                    SAMPLE(0, -distance, coeff)
                }

                fixed multiplier = 1 - _BlurPower * clamp(totalWeight, 0, 1);

                fixed appearNormalizedPos = (range - _LastAppearValue) / (_AppearValue - _LastAppearValue);
                appearNormalizedPos = clamp(appearNormalizedPos, 0, 1);
                multiplier = lerp(1, multiplier, appearNormalizedPos);

                col = multiplier * tex2D(_MainTex, input.uv) + col * (1 - multiplier);

                return col;
            }


            
            ENDCG
        }
    }
}
