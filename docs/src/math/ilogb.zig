<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>math/ilogb.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">// Ported from musl, which is MIT licensed.</span>
</span>
<span class="line" id="L2"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/COPYRIGHT</span>
</span>
<span class="line" id="L3"><span class="tok-comment">//</span>
</span>
<span class="line" id="L4"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/math/ilogbl.c</span>
</span>
<span class="line" id="L5"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/math/ilogbf.c</span>
</span>
<span class="line" id="L6"><span class="tok-comment">// https://git.musl-libc.org/cgit/musl/tree/src/math/ilogb.c</span>
</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L9"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> expect = std.testing.expect;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> maxInt = std.math.maxInt;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> minInt = std.math.minInt;</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-comment">/// Returns the binary exponent of x as an integer.</span></span>
<span class="line" id="L15"><span class="tok-comment">///</span></span>
<span class="line" id="L16"><span class="tok-comment">/// Special Cases:</span></span>
<span class="line" id="L17"><span class="tok-comment">///  - ilogb(+-inf) = maxInt(i32)</span></span>
<span class="line" id="L18"><span class="tok-comment">///  - ilogb(0)     = maxInt(i32)</span></span>
<span class="line" id="L19"><span class="tok-comment">///  - ilogb(nan)   = maxInt(i32)</span></span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ilogb</span>(x: <span class="tok-kw">anytype</span>) <span class="tok-type">i32</span> {</span>
<span class="line" id="L21">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(x);</span>
<span class="line" id="L22">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (T) {</span>
<span class="line" id="L23">        <span class="tok-type">f32</span> =&gt; ilogb32(x),</span>
<span class="line" id="L24">        <span class="tok-type">f64</span> =&gt; ilogb64(x),</span>
<span class="line" id="L25">        <span class="tok-type">f128</span> =&gt; ilogb128(x),</span>
<span class="line" id="L26">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;ilogb not implemented for &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T)),</span>
<span class="line" id="L27">    };</span>
<span class="line" id="L28">}</span>
<span class="line" id="L29"></span>
<span class="line" id="L30"><span class="tok-comment">// TODO: unify these implementations with generics</span>
</span>
<span class="line" id="L31"></span>
<span class="line" id="L32"><span class="tok-comment">// NOTE: Should these be exposed publicly?</span>
</span>
<span class="line" id="L33"><span class="tok-kw">const</span> fp_ilogbnan = -<span class="tok-number">1</span> - <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, maxInt(<span class="tok-type">u32</span>) &gt;&gt; <span class="tok-number">1</span>);</span>
<span class="line" id="L34"><span class="tok-kw">const</span> fp_ilogb0 = fp_ilogbnan;</span>
<span class="line" id="L35"></span>
<span class="line" id="L36"><span class="tok-kw">fn</span> <span class="tok-fn">ilogb32</span>(x: <span class="tok-type">f32</span>) <span class="tok-type">i32</span> {</span>
<span class="line" id="L37">    <span class="tok-kw">var</span> u = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, x);</span>
<span class="line" id="L38">    <span class="tok-kw">var</span> e = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, (u &gt;&gt; <span class="tok-number">23</span>) &amp; <span class="tok-number">0xFF</span>);</span>
<span class="line" id="L39"></span>
<span class="line" id="L40">    <span class="tok-comment">// TODO: We should be able to merge this with the lower check.</span>
</span>
<span class="line" id="L41">    <span class="tok-kw">if</span> (math.isNan(x)) {</span>
<span class="line" id="L42">        <span class="tok-kw">return</span> maxInt(<span class="tok-type">i32</span>);</span>
<span class="line" id="L43">    }</span>
<span class="line" id="L44"></span>
<span class="line" id="L45">    <span class="tok-kw">if</span> (e == <span class="tok-number">0</span>) {</span>
<span class="line" id="L46">        u &lt;&lt;= <span class="tok-number">9</span>;</span>
<span class="line" id="L47">        <span class="tok-kw">if</span> (u == <span class="tok-number">0</span>) {</span>
<span class="line" id="L48">            math.raiseInvalid();</span>
<span class="line" id="L49">            <span class="tok-kw">return</span> fp_ilogb0;</span>
<span class="line" id="L50">        }</span>
<span class="line" id="L51"></span>
<span class="line" id="L52">        <span class="tok-comment">// subnormal</span>
</span>
<span class="line" id="L53">        e = -<span class="tok-number">0x7F</span>;</span>
<span class="line" id="L54">        <span class="tok-kw">while</span> (u &gt;&gt; <span class="tok-number">31</span> == <span class="tok-number">0</span>) : (u &lt;&lt;= <span class="tok-number">1</span>) {</span>
<span class="line" id="L55">            e -= <span class="tok-number">1</span>;</span>
<span class="line" id="L56">        }</span>
<span class="line" id="L57">        <span class="tok-kw">return</span> e;</span>
<span class="line" id="L58">    }</span>
<span class="line" id="L59"></span>
<span class="line" id="L60">    <span class="tok-kw">if</span> (e == <span class="tok-number">0xFF</span>) {</span>
<span class="line" id="L61">        math.raiseInvalid();</span>
<span class="line" id="L62">        <span class="tok-kw">if</span> (u &lt;&lt; <span class="tok-number">9</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L63">            <span class="tok-kw">return</span> fp_ilogbnan;</span>
<span class="line" id="L64">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L65">            <span class="tok-kw">return</span> maxInt(<span class="tok-type">i32</span>);</span>
<span class="line" id="L66">        }</span>
<span class="line" id="L67">    }</span>
<span class="line" id="L68"></span>
<span class="line" id="L69">    <span class="tok-kw">return</span> e - <span class="tok-number">0x7F</span>;</span>
<span class="line" id="L70">}</span>
<span class="line" id="L71"></span>
<span class="line" id="L72"><span class="tok-kw">fn</span> <span class="tok-fn">ilogb64</span>(x: <span class="tok-type">f64</span>) <span class="tok-type">i32</span> {</span>
<span class="line" id="L73">    <span class="tok-kw">var</span> u = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u64</span>, x);</span>
<span class="line" id="L74">    <span class="tok-kw">var</span> e = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, (u &gt;&gt; <span class="tok-number">52</span>) &amp; <span class="tok-number">0x7FF</span>);</span>
<span class="line" id="L75"></span>
<span class="line" id="L76">    <span class="tok-kw">if</span> (math.isNan(x)) {</span>
<span class="line" id="L77">        <span class="tok-kw">return</span> maxInt(<span class="tok-type">i32</span>);</span>
<span class="line" id="L78">    }</span>
<span class="line" id="L79"></span>
<span class="line" id="L80">    <span class="tok-kw">if</span> (e == <span class="tok-number">0</span>) {</span>
<span class="line" id="L81">        u &lt;&lt;= <span class="tok-number">12</span>;</span>
<span class="line" id="L82">        <span class="tok-kw">if</span> (u == <span class="tok-number">0</span>) {</span>
<span class="line" id="L83">            math.raiseInvalid();</span>
<span class="line" id="L84">            <span class="tok-kw">return</span> fp_ilogb0;</span>
<span class="line" id="L85">        }</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">        <span class="tok-comment">// subnormal</span>
</span>
<span class="line" id="L88">        e = -<span class="tok-number">0x3FF</span>;</span>
<span class="line" id="L89">        <span class="tok-kw">while</span> (u &gt;&gt; <span class="tok-number">63</span> == <span class="tok-number">0</span>) : (u &lt;&lt;= <span class="tok-number">1</span>) {</span>
<span class="line" id="L90">            e -= <span class="tok-number">1</span>;</span>
<span class="line" id="L91">        }</span>
<span class="line" id="L92">        <span class="tok-kw">return</span> e;</span>
<span class="line" id="L93">    }</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">    <span class="tok-kw">if</span> (e == <span class="tok-number">0x7FF</span>) {</span>
<span class="line" id="L96">        math.raiseInvalid();</span>
<span class="line" id="L97">        <span class="tok-kw">if</span> (u &lt;&lt; <span class="tok-number">12</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L98">            <span class="tok-kw">return</span> fp_ilogbnan;</span>
<span class="line" id="L99">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L100">            <span class="tok-kw">return</span> maxInt(<span class="tok-type">i32</span>);</span>
<span class="line" id="L101">        }</span>
<span class="line" id="L102">    }</span>
<span class="line" id="L103"></span>
<span class="line" id="L104">    <span class="tok-kw">return</span> e - <span class="tok-number">0x3FF</span>;</span>
<span class="line" id="L105">}</span>
<span class="line" id="L106"></span>
<span class="line" id="L107"><span class="tok-kw">fn</span> <span class="tok-fn">ilogb128</span>(x: <span class="tok-type">f128</span>) <span class="tok-type">i32</span> {</span>
<span class="line" id="L108">    <span class="tok-kw">var</span> u = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u128</span>, x);</span>
<span class="line" id="L109">    <span class="tok-kw">var</span> e = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, (u &gt;&gt; <span class="tok-number">112</span>) &amp; <span class="tok-number">0x7FFF</span>);</span>
<span class="line" id="L110"></span>
<span class="line" id="L111">    <span class="tok-kw">if</span> (math.isNan(x)) {</span>
<span class="line" id="L112">        <span class="tok-kw">return</span> maxInt(<span class="tok-type">i32</span>);</span>
<span class="line" id="L113">    }</span>
<span class="line" id="L114"></span>
<span class="line" id="L115">    <span class="tok-kw">if</span> (e == <span class="tok-number">0</span>) {</span>
<span class="line" id="L116">        u &lt;&lt;= <span class="tok-number">16</span>;</span>
<span class="line" id="L117">        <span class="tok-kw">if</span> (u == <span class="tok-number">0</span>) {</span>
<span class="line" id="L118">            math.raiseInvalid();</span>
<span class="line" id="L119">            <span class="tok-kw">return</span> fp_ilogb0;</span>
<span class="line" id="L120">        }</span>
<span class="line" id="L121"></span>
<span class="line" id="L122">        <span class="tok-comment">// subnormal x</span>
</span>
<span class="line" id="L123">        <span class="tok-kw">return</span> ilogb128(x * <span class="tok-number">0x1p120</span>) - <span class="tok-number">120</span>;</span>
<span class="line" id="L124">    }</span>
<span class="line" id="L125"></span>
<span class="line" id="L126">    <span class="tok-kw">if</span> (e == <span class="tok-number">0x7FFF</span>) {</span>
<span class="line" id="L127">        math.raiseInvalid();</span>
<span class="line" id="L128">        <span class="tok-kw">if</span> (u &lt;&lt; <span class="tok-number">16</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L129">            <span class="tok-kw">return</span> fp_ilogbnan;</span>
<span class="line" id="L130">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L131">            <span class="tok-kw">return</span> maxInt(<span class="tok-type">i32</span>);</span>
<span class="line" id="L132">        }</span>
<span class="line" id="L133">    }</span>
<span class="line" id="L134"></span>
<span class="line" id="L135">    <span class="tok-kw">return</span> e - <span class="tok-number">0x3FFF</span>;</span>
<span class="line" id="L136">}</span>
<span class="line" id="L137"></span>
<span class="line" id="L138"><span class="tok-kw">test</span> <span class="tok-str">&quot;type dispatch&quot;</span> {</span>
<span class="line" id="L139">    <span class="tok-kw">try</span> expect(ilogb(<span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">0.2</span>)) == ilogb32(<span class="tok-number">0.2</span>));</span>
<span class="line" id="L140">    <span class="tok-kw">try</span> expect(ilogb(<span class="tok-builtin">@as</span>(<span class="tok-type">f64</span>, <span class="tok-number">0.2</span>)) == ilogb64(<span class="tok-number">0.2</span>));</span>
<span class="line" id="L141">}</span>
<span class="line" id="L142"></span>
<span class="line" id="L143"><span class="tok-kw">test</span> <span class="tok-str">&quot;32&quot;</span> {</span>
<span class="line" id="L144">    <span class="tok-kw">try</span> expect(ilogb32(<span class="tok-number">0.0</span>) == fp_ilogb0);</span>
<span class="line" id="L145">    <span class="tok-kw">try</span> expect(ilogb32(<span class="tok-number">0.5</span>) == -<span class="tok-number">1</span>);</span>
<span class="line" id="L146">    <span class="tok-kw">try</span> expect(ilogb32(<span class="tok-number">0.8923</span>) == -<span class="tok-number">1</span>);</span>
<span class="line" id="L147">    <span class="tok-kw">try</span> expect(ilogb32(<span class="tok-number">10.0</span>) == <span class="tok-number">3</span>);</span>
<span class="line" id="L148">    <span class="tok-kw">try</span> expect(ilogb32(-<span class="tok-number">123984</span>) == <span class="tok-number">16</span>);</span>
<span class="line" id="L149">    <span class="tok-kw">try</span> expect(ilogb32(<span class="tok-number">2398.23</span>) == <span class="tok-number">11</span>);</span>
<span class="line" id="L150">}</span>
<span class="line" id="L151"></span>
<span class="line" id="L152"><span class="tok-kw">test</span> <span class="tok-str">&quot;64&quot;</span> {</span>
<span class="line" id="L153">    <span class="tok-kw">try</span> expect(ilogb64(<span class="tok-number">0.0</span>) == fp_ilogb0);</span>
<span class="line" id="L154">    <span class="tok-kw">try</span> expect(ilogb64(<span class="tok-number">0.5</span>) == -<span class="tok-number">1</span>);</span>
<span class="line" id="L155">    <span class="tok-kw">try</span> expect(ilogb64(<span class="tok-number">0.8923</span>) == -<span class="tok-number">1</span>);</span>
<span class="line" id="L156">    <span class="tok-kw">try</span> expect(ilogb64(<span class="tok-number">10.0</span>) == <span class="tok-number">3</span>);</span>
<span class="line" id="L157">    <span class="tok-kw">try</span> expect(ilogb64(-<span class="tok-number">123984</span>) == <span class="tok-number">16</span>);</span>
<span class="line" id="L158">    <span class="tok-kw">try</span> expect(ilogb64(<span class="tok-number">2398.23</span>) == <span class="tok-number">11</span>);</span>
<span class="line" id="L159">}</span>
<span class="line" id="L160"></span>
<span class="line" id="L161"><span class="tok-kw">test</span> <span class="tok-str">&quot;128&quot;</span> {</span>
<span class="line" id="L162">    <span class="tok-kw">try</span> expect(ilogb128(<span class="tok-number">0.0</span>) == fp_ilogb0);</span>
<span class="line" id="L163">    <span class="tok-kw">try</span> expect(ilogb128(<span class="tok-number">0.5</span>) == -<span class="tok-number">1</span>);</span>
<span class="line" id="L164">    <span class="tok-kw">try</span> expect(ilogb128(<span class="tok-number">0.8923</span>) == -<span class="tok-number">1</span>);</span>
<span class="line" id="L165">    <span class="tok-kw">try</span> expect(ilogb128(<span class="tok-number">10.0</span>) == <span class="tok-number">3</span>);</span>
<span class="line" id="L166">    <span class="tok-kw">try</span> expect(ilogb128(-<span class="tok-number">123984</span>) == <span class="tok-number">16</span>);</span>
<span class="line" id="L167">    <span class="tok-kw">try</span> expect(ilogb128(<span class="tok-number">2398.23</span>) == <span class="tok-number">11</span>);</span>
<span class="line" id="L168">}</span>
<span class="line" id="L169"></span>
<span class="line" id="L170"><span class="tok-kw">test</span> <span class="tok-str">&quot;32 special&quot;</span> {</span>
<span class="line" id="L171">    <span class="tok-kw">try</span> expect(ilogb32(math.inf(<span class="tok-type">f32</span>)) == maxInt(<span class="tok-type">i32</span>));</span>
<span class="line" id="L172">    <span class="tok-kw">try</span> expect(ilogb32(-math.inf(<span class="tok-type">f32</span>)) == maxInt(<span class="tok-type">i32</span>));</span>
<span class="line" id="L173">    <span class="tok-kw">try</span> expect(ilogb32(<span class="tok-number">0.0</span>) == minInt(<span class="tok-type">i32</span>));</span>
<span class="line" id="L174">    <span class="tok-kw">try</span> expect(ilogb32(math.nan(<span class="tok-type">f32</span>)) == maxInt(<span class="tok-type">i32</span>));</span>
<span class="line" id="L175">}</span>
<span class="line" id="L176"></span>
<span class="line" id="L177"><span class="tok-kw">test</span> <span class="tok-str">&quot;64 special&quot;</span> {</span>
<span class="line" id="L178">    <span class="tok-kw">try</span> expect(ilogb64(math.inf(<span class="tok-type">f64</span>)) == maxInt(<span class="tok-type">i32</span>));</span>
<span class="line" id="L179">    <span class="tok-kw">try</span> expect(ilogb64(-math.inf(<span class="tok-type">f64</span>)) == maxInt(<span class="tok-type">i32</span>));</span>
<span class="line" id="L180">    <span class="tok-kw">try</span> expect(ilogb64(<span class="tok-number">0.0</span>) == minInt(<span class="tok-type">i32</span>));</span>
<span class="line" id="L181">    <span class="tok-kw">try</span> expect(ilogb64(math.nan(<span class="tok-type">f64</span>)) == maxInt(<span class="tok-type">i32</span>));</span>
<span class="line" id="L182">}</span>
<span class="line" id="L183"></span>
<span class="line" id="L184"><span class="tok-kw">test</span> <span class="tok-str">&quot;128 special&quot;</span> {</span>
<span class="line" id="L185">    <span class="tok-kw">try</span> expect(ilogb128(math.inf(<span class="tok-type">f128</span>)) == maxInt(<span class="tok-type">i32</span>));</span>
<span class="line" id="L186">    <span class="tok-kw">try</span> expect(ilogb128(-math.inf(<span class="tok-type">f128</span>)) == maxInt(<span class="tok-type">i32</span>));</span>
<span class="line" id="L187">    <span class="tok-kw">try</span> expect(ilogb128(<span class="tok-number">0.0</span>) == minInt(<span class="tok-type">i32</span>));</span>
<span class="line" id="L188">    <span class="tok-kw">try</span> expect(ilogb128(math.nan(<span class="tok-type">f128</span>)) == maxInt(<span class="tok-type">i32</span>));</span>
<span class="line" id="L189">}</span>
<span class="line" id="L190"></span>
</code></pre></body>
</html>