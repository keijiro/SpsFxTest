Shader "Hidden/StereoTest"
{
    Properties
    {
        _MainTex("", 2D) = "white" {}
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    float4 _MainTex_TexelSize;
    half4 _MainTex_ST;

    struct v2f_img2
    {
        float4 pos : SV_POSITION;
        float2 uv_scr : TEXCOORD0;
        float2 uv_tex : TEXCOORD1;
    };

    v2f_img2 vert_img2(appdata_img v)
    {
        v2f_img2 o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv_scr = v.texcoord;
        o.uv_tex = UnityStereoScreenSpaceUVAdjust(v.texcoord, _MainTex_ST);
        return o;
    }

    fixed4 frag_checker(v2f_img2 i) : SV_Target
    {
        float4 src = tex2D(_MainTex, i.uv_tex);
        float2 diag = frac(i.uv_tex * _MainTex_TexelSize.zw / 2);
        float bw = abs(diag.x - diag.y) < 0.1;
        return fixed4(src.rgb * bw, src.a);
    }

    fixed4 frag_blur(v2f_img2 i) : SV_Target
    {
        float3 offs = float3(_MainTex_TexelSize.xy, 0);

        float4 s1 = tex2D(_MainTex, i.uv_tex);
        float4 s2 = tex2D(_MainTex, i.uv_tex + offs.xz);
        float4 s3 = tex2D(_MainTex, i.uv_tex + offs.zy);
        float4 s4 = tex2D(_MainTex, i.uv_tex + offs.xy);

        return (s1 + s2 + s3 + s4) / 2;
    }

    fixed4 frag_distortion(v2f_img2 i) : SV_Target
    {
        float dist = length(i.uv_scr - 0.5);
        float wave = sin(dist * 40);
        float2 uv = (i.uv_scr - 0.5) * (1 + wave * 0.04) + 0.5;
        uv = UnityStereoScreenSpaceUVAdjust(uv, _MainTex_ST);
        return tex2D(_MainTex, uv);
    }

    ENDCG

    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img2
            #pragma fragment frag_checker
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img2
            #pragma fragment frag_blur
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img2
            #pragma fragment frag_distortion
            ENDCG
        }
    }
}
