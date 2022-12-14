<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>math/ldexp.zig - source view</title>
    <link rel="icon" href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAgklEQVR4AWMYWuD7EllJIM4G4g4g5oIJ/odhOJ8wToOxSTXgNxDHoeiBMfA4+wGShjyYOCkG/IGqWQziEzYAoUAeiF9D5U+DxEg14DRU7jWIT5IBIOdCxf+A+CQZAAoopEB7QJwBCBwHiip8UYmRdrAlDpIMgApwQZNnNii5Dq0MBgCxxycBnwEd+wAAAABJRU5ErkJggg=="/>
    <style>
      body{
        font-family: system-ui, -apple-system, Roboto, "Segoe UI", sans-serif;
        margin: 0;
        line-height: 1.5;
      }

      pre > code {
        display: block;
        overflow: auto;
        line-height: normal;
        margin: 0em;
      }
      .tok-kw {
          color: #333;
          font-weight: bold;
      }
      .tok-str {
          color: #d14;
      }
      .tok-builtin {
          color: #005C7A;
      }
      .tok-comment {
          color: #545454;
          font-style: italic;
      }
      .tok-fn {
          color: #900;
          font-weight: bold;
      }
      .tok-null {
          color: #005C5C;
      }
      .tok-number {
          color: #005C5C;
      }
      .tok-type {
          color: #458;
          font-weight: bold;
      }
      pre {
        counter-reset: line;
      }
      pre .line:before {
        counter-increment: line;
        content: counter(line);
        display: inline-block;
        padding-right: 1em;
        width: 2em;
        text-align: right;
        color: #999;
      }

      @media (prefers-color-scheme: dark) {
        body{
            background:#222;
            color: #ccc;
        }
        pre > code {
            color: #ccc;
            background: #222;
            border: unset;
        }
        .tok-kw {
            color: #eee;
        }
        .tok-str {
            color: #2e5;
        }
        .tok-builtin {
            color: #ff894c;
        }
        .tok-comment {
            color: #aa7;
        }
        .tok-fn {
            color: #B1A0F8;
        }
        .tok-null {
            color: #ff8080;
        }
        .tok-number {
            color: #ff8080;
        }
        .tok-type {
            color: #68f;
        }
      }
    </style>
</head>
<body>
<pre><code><span class="line" id="L1"><span class="tok-comment">// Ported from musl, which is licensed under the MIT license:</span>
</span>
<span class="line" id="L2"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/COPYRIGHT</span>
</span>
<span class="line" id="L3"><span class="tok-comment">//</span>
</span>
<span class="line" id="L4"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/math/ldexpf.c</span>
</span>
<span class="line" id="L5"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/math/ldexp.c</span>
</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L8"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-comment">/// Returns x * 2^n.</span></span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ldexp</span>(x: <span class="tok-kw">anytype</span>, n: <span class="tok-type">i32</span>) <span class="tok-builtin">@TypeOf</span>(x) {</span>
<span class="line" id="L14">    <span class="tok-kw">var</span> base = x;</span>
<span class="line" id="L15">    <span class="tok-kw">var</span> shift = n;</span>
<span class="line" id="L16"></span>
<span class="line" id="L17">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(base);</span>
<span class="line" id="L18">    <span class="tok-kw">const</span> TBits = std.meta.Int(.unsigned, <span class="tok-builtin">@typeInfo</span>(T).Float.bits);</span>
<span class="line" id="L19"></span>
<span class="line" id="L20">    <span class="tok-kw">const</span> mantissa_bits = math.floatMantissaBits(T);</span>
<span class="line" id="L21">    <span class="tok-kw">const</span> exponent_min = math.floatExponentMin(T);</span>
<span class="line" id="L22">    <span class="tok-kw">const</span> exponent_max = math.floatExponentMax(T);</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">    <span class="tok-kw">const</span> exponent_bias = exponent_max;</span>
<span class="line" id="L25"></span>
<span class="line" id="L26">    <span class="tok-comment">// fix double rounding errors in subnormal ranges</span>
</span>
<span class="line" id="L27">    <span class="tok-comment">// https://git.musl-libc.org/cgit/musl/commit/src/math/ldexp.c?id=8c44a060243f04283ca68dad199aab90336141db</span>
</span>
<span class="line" id="L28">    <span class="tok-kw">const</span> scale_min_expo = exponent_min + mantissa_bits + <span class="tok-number">1</span>;</span>
<span class="line" id="L29">    <span class="tok-kw">const</span> scale_min = <span class="tok-builtin">@bitCast</span>(T, <span class="tok-builtin">@as</span>(TBits, scale_min_expo + exponent_bias) &lt;&lt; mantissa_bits);</span>
<span class="line" id="L30">    <span class="tok-kw">const</span> scale_max = <span class="tok-builtin">@bitCast</span>(T, <span class="tok-builtin">@intCast</span>(TBits, exponent_max + exponent_bias) &lt;&lt; mantissa_bits);</span>
<span class="line" id="L31"></span>
<span class="line" id="L32">    <span class="tok-comment">// scale `shift` within floating point limits, if possible</span>
</span>
<span class="line" id="L33">    <span class="tok-comment">// second pass is possible due to subnormal range</span>
</span>
<span class="line" id="L34">    <span class="tok-comment">// third pass always results in +/-0.0 or +/-inf</span>
</span>
<span class="line" id="L35">    <span class="tok-kw">if</span> (shift &gt; exponent_max) {</span>
<span class="line" id="L36">        base *= scale_max;</span>
<span class="line" id="L37">        shift -= exponent_max;</span>
<span class="line" id="L38">        <span class="tok-kw">if</span> (shift &gt; exponent_max) {</span>
<span class="line" id="L39">            base *= scale_max;</span>
<span class="line" id="L40">            shift -= exponent_max;</span>
<span class="line" id="L41">            <span class="tok-kw">if</span> (shift &gt; exponent_max) shift = exponent_max;</span>
<span class="line" id="L42">        }</span>
<span class="line" id="L43">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (shift &lt; exponent_min) {</span>
<span class="line" id="L44">        base *= scale_min;</span>
<span class="line" id="L45">        shift -= scale_min_expo;</span>
<span class="line" id="L46">        <span class="tok-kw">if</span> (shift &lt; exponent_min) {</span>
<span class="line" id="L47">            base *= scale_min;</span>
<span class="line" id="L48">            shift -= scale_min_expo;</span>
<span class="line" id="L49">            <span class="tok-kw">if</span> (shift &lt; exponent_min) shift = exponent_min;</span>
<span class="line" id="L50">        }</span>
<span class="line" id="L51">    }</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">    <span class="tok-kw">return</span> base * <span class="tok-builtin">@bitCast</span>(T, <span class="tok-builtin">@intCast</span>(TBits, shift + exponent_bias) &lt;&lt; mantissa_bits);</span>
<span class="line" id="L54">}</span>
<span class="line" id="L55"></span>
<span class="line" id="L56"><span class="tok-kw">test</span> <span class="tok-str">&quot;math.ldexp&quot;</span> {</span>
<span class="line" id="L57">    <span class="tok-comment">// TODO derive the various constants here with new maths API</span>
</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">    <span class="tok-comment">// basic usage</span>
</span>
<span class="line" id="L60">    <span class="tok-kw">try</span> expect(ldexp(<span class="tok-builtin">@as</span>(<span class="tok-type">f16</span>, <span class="tok-number">1.5</span>), <span class="tok-number">4</span>) == <span class="tok-number">24.0</span>);</span>
<span class="line" id="L61">    <span class="tok-kw">try</span> expect(ldexp(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">1.5</span>), <span class="tok-number">4</span>) == <span class="tok-number">24.0</span>);</span>
<span class="line" id="L62">    <span class="tok-kw">try</span> expect(ldexp(<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">1.5</span>), <span class="tok-number">4</span>) == <span class="tok-number">24.0</span>);</span>
<span class="line" id="L63">    <span class="tok-kw">try</span> expect(ldexp(<span class="tok-builtin">@as</span>(<span class="tok-type">f128</span>, <span class="tok-number">1.5</span>), <span class="tok-number">4</span>) == <span class="tok-number">24.0</span>);</span>
<span class="line" id="L64"></span>
<span class="line" id="L65">    <span class="tok-comment">// subnormals</span>
</span>
<span class="line" id="L66">    <span class="tok-kw">try</span> expect(math.isNormal(ldexp(<span class="tok-builtin">@as</span>(<span class="tok-type">f16</span>, <span class="tok-number">1.0</span>), -<span class="tok-number">14</span>)));</span>
<span class="line" id="L67">    <span class="tok-kw">try</span> expect(!math.isNormal(ldexp(<span class="tok-builtin">@as</span>(<span class="tok-type">f16</span>, <span class="tok-number">1.0</span>), -<span class="tok-number">15</span>)));</span>
<span class="line" id="L68">    <span class="tok-kw">try</span> expect(math.isNormal(ldexp(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">1.0</span>), -<span class="tok-number">126</span>)));</span>
<span class="line" id="L69">    <span class="tok-kw">try</span> expect(!math.isNormal(ldexp(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">1.0</span>), -<span class="tok-number">127</span>)));</span>
<span class="line" id="L70">    <span class="tok-kw">try</span> expect(math.isNormal(ldexp(<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">1.0</span>), -<span class="tok-number">1022</span>)));</span>
<span class="line" id="L71">    <span class="tok-kw">try</span> expect(!math.isNormal(ldexp(<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">1.0</span>), -<span class="tok-number">1023</span>)));</span>
<span class="line" id="L72">    <span class="tok-kw">try</span> expect(math.isNormal(ldexp(<span class="tok-builtin">@as</span>(<span class="tok-type">f128</span>, <span class="tok-number">1.0</span>), -<span class="tok-number">16382</span>)));</span>
<span class="line" id="L73">    <span class="tok-kw">try</span> expect(!math.isNormal(ldexp(<span class="tok-builtin">@as</span>(<span class="tok-type">f128</span>, <span class="tok-number">1.0</span>), -<span class="tok-number">16383</span>)));</span>
<span class="line" id="L74">    <span class="tok-comment">// unreliable due to lack of native f16 support, see talk on PR #8733</span>
</span>
<span class="line" id="L75">    <span class="tok-comment">// try expect(ldexp(@as(f16, 0x1.1FFp-1), -14 - 9) == math.floatTrueMin(f16));</span>
</span>
<span class="line" id="L76">    <span class="tok-kw">try</span> expect(ldexp(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">0x1.3FFFFFp-1</span>), -<span class="tok-number">126</span> - <span class="tok-number">22</span>) == math.floatTrueMin(<span class="tok-type">f32</span>));</span>
<span class="line" id="L77">    <span class="tok-kw">try</span> expect(ldexp(<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">0x1.7FFFFFFFFFFFFp-1</span>), -<span class="tok-number">1022</span> - <span class="tok-number">51</span>) == math.floatTrueMin(<span class="tok-type">f64</span>));</span>
<span class="line" id="L78">    <span class="tok-kw">try</span> expect(ldexp(<span class="tok-builtin">@as</span>(<span class="tok-type">f128</span>, <span class="tok-number">0x1.7FFFFFFFFFFFFFFFFFFFFFFFFFFFp-1</span>), -<span class="tok-number">16382</span> - <span class="tok-number">111</span>) == math.floatTrueMin(<span class="tok-type">f128</span>));</span>
<span class="line" id="L79"></span>
<span class="line" id="L80">    <span class="tok-comment">// float limits</span>
</span>
<span class="line" id="L81">    <span class="tok-kw">try</span> expect(ldexp(math.floatMax(<span class="tok-type">f32</span>), -<span class="tok-number">128</span> - <span class="tok-number">149</span>) &gt; <span class="tok-number">0.0</span>);</span>
<span class="line" id="L82">    <span class="tok-kw">try</span> expect(ldexp(math.floatMax(<span class="tok-type">f32</span>), -<span class="tok-number">128</span> - <span class="tok-number">149</span> - <span class="tok-number">1</span>) == <span class="tok-number">0.0</span>);</span>
<span class="line" id="L83">    <span class="tok-kw">try</span> expect(!math.isPositiveInf(ldexp(math.floatTrueMin(<span class="tok-type">f16</span>), <span class="tok-number">15</span> + <span class="tok-number">24</span>)));</span>
<span class="line" id="L84">    <span class="tok-kw">try</span> expect(math.isPositiveInf(ldexp(math.floatTrueMin(<span class="tok-type">f16</span>), <span class="tok-number">15</span> + <span class="tok-number">24</span> + <span class="tok-number">1</span>)));</span>
<span class="line" id="L85">    <span class="tok-kw">try</span> expect(!math.isPositiveInf(ldexp(math.floatTrueMin(<span class="tok-type">f32</span>), <span class="tok-number">127</span> + <span class="tok-number">149</span>)));</span>
<span class="line" id="L86">    <span class="tok-kw">try</span> expect(math.isPositiveInf(ldexp(math.floatTrueMin(<span class="tok-type">f32</span>), <span class="tok-number">127</span> + <span class="tok-number">149</span> + <span class="tok-number">1</span>)));</span>
<span class="line" id="L87">    <span class="tok-kw">try</span> expect(!math.isPositiveInf(ldexp(math.floatTrueMin(<span class="tok-type">f64</span>), <span class="tok-number">1023</span> + <span class="tok-number">1074</span>)));</span>
<span class="line" id="L88">    <span class="tok-kw">try</span> expect(math.isPositiveInf(ldexp(math.floatTrueMin(<span class="tok-type">f64</span>), <span class="tok-number">1023</span> + <span class="tok-number">1074</span> + <span class="tok-number">1</span>)));</span>
<span class="line" id="L89">    <span class="tok-kw">try</span> expect(!math.isPositiveInf(ldexp(math.floatTrueMin(<span class="tok-type">f128</span>), <span class="tok-number">16383</span> + <span class="tok-number">16494</span>)));</span>
<span class="line" id="L90">    <span class="tok-kw">try</span> expect(math.isPositiveInf(ldexp(math.floatTrueMin(<span class="tok-type">f128</span>), <span class="tok-number">16383</span> + <span class="tok-number">16494</span> + <span class="tok-number">1</span>)));</span>
<span class="line" id="L91">}</span>
<span class="line" id="L92"></span>
</code></pre></body>
</html>