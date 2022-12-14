<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>zig/c_translation.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-comment">/// Given a type and value, cast the value to the type as c would.</span></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cast</span>(<span class="tok-kw">comptime</span> DestType: <span class="tok-type">type</span>, target: <span class="tok-kw">anytype</span>) DestType {</span>
<span class="line" id="L8">    <span class="tok-comment">// this function should behave like transCCast in translate-c, except it's for macros</span>
</span>
<span class="line" id="L9">    <span class="tok-kw">const</span> SourceType = <span class="tok-builtin">@TypeOf</span>(target);</span>
<span class="line" id="L10">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(DestType)) {</span>
<span class="line" id="L11">        .Fn =&gt; <span class="tok-kw">if</span> (<span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>).zig_backend == .stage1)</span>
<span class="line" id="L12">            <span class="tok-kw">return</span> castToPtr(DestType, SourceType, target)</span>
<span class="line" id="L13">        <span class="tok-kw">else</span></span>
<span class="line" id="L14">            <span class="tok-kw">return</span> castToPtr(*<span class="tok-kw">const</span> DestType, SourceType, target),</span>
<span class="line" id="L15">        .Pointer =&gt; <span class="tok-kw">return</span> castToPtr(DestType, SourceType, target),</span>
<span class="line" id="L16">        .Optional =&gt; |dest_opt| {</span>
<span class="line" id="L17">            <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(dest_opt.child) == .Pointer) {</span>
<span class="line" id="L18">                <span class="tok-kw">return</span> castToPtr(DestType, SourceType, target);</span>
<span class="line" id="L19">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(dest_opt.child) == .Fn) {</span>
<span class="line" id="L20">                <span class="tok-kw">if</span> (<span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>).zig_backend == .stage1)</span>
<span class="line" id="L21">                    <span class="tok-kw">return</span> castToPtr(DestType, SourceType, target)</span>
<span class="line" id="L22">                <span class="tok-kw">else</span></span>
<span class="line" id="L23">                    <span class="tok-kw">return</span> castToPtr(?*<span class="tok-kw">const</span> dest_opt.child, SourceType, target);</span>
<span class="line" id="L24">            }</span>
<span class="line" id="L25">        },</span>
<span class="line" id="L26">        .Int =&gt; {</span>
<span class="line" id="L27">            <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(SourceType)) {</span>
<span class="line" id="L28">                .Pointer =&gt; {</span>
<span class="line" id="L29">                    <span class="tok-kw">return</span> castInt(DestType, <span class="tok-builtin">@ptrToInt</span>(target));</span>
<span class="line" id="L30">                },</span>
<span class="line" id="L31">                .Optional =&gt; |opt| {</span>
<span class="line" id="L32">                    <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(opt.child) == .Pointer) {</span>
<span class="line" id="L33">                        <span class="tok-kw">return</span> castInt(DestType, <span class="tok-builtin">@ptrToInt</span>(target));</span>
<span class="line" id="L34">                    }</span>
<span class="line" id="L35">                },</span>
<span class="line" id="L36">                .Int =&gt; {</span>
<span class="line" id="L37">                    <span class="tok-kw">return</span> castInt(DestType, target);</span>
<span class="line" id="L38">                },</span>
<span class="line" id="L39">                .Fn =&gt; {</span>
<span class="line" id="L40">                    <span class="tok-kw">return</span> castInt(DestType, <span class="tok-builtin">@ptrToInt</span>(&amp;target));</span>
<span class="line" id="L41">                },</span>
<span class="line" id="L42">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L43">            }</span>
<span class="line" id="L44">        },</span>
<span class="line" id="L45">        .Union =&gt; |info| {</span>
<span class="line" id="L46">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (info.fields) |field| {</span>
<span class="line" id="L47">                <span class="tok-kw">if</span> (field.field_type == SourceType) <span class="tok-kw">return</span> <span class="tok-builtin">@unionInit</span>(DestType, field.name, target);</span>
<span class="line" id="L48">            }</span>
<span class="line" id="L49">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;cast to union type '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(DestType) ++ <span class="tok-str">&quot;' from type '&quot;</span> ++ <span class="tok-builtin">@typeName</span>(SourceType) ++ <span class="tok-str">&quot;' which is not present in union&quot;</span>);</span>
<span class="line" id="L50">        },</span>
<span class="line" id="L51">        .Bool =&gt; <span class="tok-kw">return</span> cast(<span class="tok-type">usize</span>, target) != <span class="tok-number">0</span>,</span>
<span class="line" id="L52">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L53">    }</span>
<span class="line" id="L54">    <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(DestType, target);</span>
<span class="line" id="L55">}</span>
<span class="line" id="L56"></span>
<span class="line" id="L57"><span class="tok-kw">fn</span> <span class="tok-fn">castInt</span>(<span class="tok-kw">comptime</span> DestType: <span class="tok-type">type</span>, target: <span class="tok-kw">anytype</span>) DestType {</span>
<span class="line" id="L58">    <span class="tok-kw">const</span> dest = <span class="tok-builtin">@typeInfo</span>(DestType).Int;</span>
<span class="line" id="L59">    <span class="tok-kw">const</span> source = <span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(target)).Int;</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">    <span class="tok-kw">if</span> (dest.bits &lt; source.bits)</span>
<span class="line" id="L62">        <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(DestType, <span class="tok-builtin">@truncate</span>(std.meta.Int(source.signedness, dest.bits), target))</span>
<span class="line" id="L63">    <span class="tok-kw">else</span></span>
<span class="line" id="L64">        <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(DestType, <span class="tok-builtin">@as</span>(std.meta.Int(source.signedness, dest.bits), target));</span>
<span class="line" id="L65">}</span>
<span class="line" id="L66"></span>
<span class="line" id="L67"><span class="tok-kw">fn</span> <span class="tok-fn">castPtr</span>(<span class="tok-kw">comptime</span> DestType: <span class="tok-type">type</span>, target: <span class="tok-kw">anytype</span>) DestType {</span>
<span class="line" id="L68">    <span class="tok-kw">const</span> dest = ptrInfo(DestType);</span>
<span class="line" id="L69">    <span class="tok-kw">const</span> source = ptrInfo(<span class="tok-builtin">@TypeOf</span>(target));</span>
<span class="line" id="L70"></span>
<span class="line" id="L71">    <span class="tok-kw">if</span> (source.is_const <span class="tok-kw">and</span> !dest.is_const <span class="tok-kw">or</span> source.is_volatile <span class="tok-kw">and</span> !dest.is_volatile)</span>
<span class="line" id="L72">        <span class="tok-kw">return</span> <span class="tok-builtin">@intToPtr</span>(DestType, <span class="tok-builtin">@ptrToInt</span>(target))</span>
<span class="line" id="L73">    <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(dest.child) == .Opaque)</span>
<span class="line" id="L74">        <span class="tok-comment">// dest.alignment would error out</span>
</span>
<span class="line" id="L75">        <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(DestType, target)</span>
<span class="line" id="L76">    <span class="tok-kw">else</span></span>
<span class="line" id="L77">        <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>(DestType, <span class="tok-builtin">@alignCast</span>(dest.alignment, target));</span>
<span class="line" id="L78">}</span>
<span class="line" id="L79"></span>
<span class="line" id="L80"><span class="tok-kw">fn</span> <span class="tok-fn">castToPtr</span>(<span class="tok-kw">comptime</span> DestType: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> SourceType: <span class="tok-type">type</span>, target: <span class="tok-kw">anytype</span>) DestType {</span>
<span class="line" id="L81">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(SourceType)) {</span>
<span class="line" id="L82">        .Int =&gt; {</span>
<span class="line" id="L83">            <span class="tok-kw">return</span> <span class="tok-builtin">@intToPtr</span>(DestType, castInt(<span class="tok-type">usize</span>, target));</span>
<span class="line" id="L84">        },</span>
<span class="line" id="L85">        .ComptimeInt =&gt; {</span>
<span class="line" id="L86">            <span class="tok-kw">if</span> (target &lt; <span class="tok-number">0</span>)</span>
<span class="line" id="L87">                <span class="tok-kw">return</span> <span class="tok-builtin">@intToPtr</span>(DestType, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@intCast</span>(<span class="tok-type">isize</span>, target)))</span>
<span class="line" id="L88">            <span class="tok-kw">else</span></span>
<span class="line" id="L89">                <span class="tok-kw">return</span> <span class="tok-builtin">@intToPtr</span>(DestType, <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, target));</span>
<span class="line" id="L90">        },</span>
<span class="line" id="L91">        .Pointer =&gt; {</span>
<span class="line" id="L92">            <span class="tok-kw">return</span> castPtr(DestType, target);</span>
<span class="line" id="L93">        },</span>
<span class="line" id="L94">        .Optional =&gt; |target_opt| {</span>
<span class="line" id="L95">            <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(target_opt.child) == .Pointer) {</span>
<span class="line" id="L96">                <span class="tok-kw">return</span> castPtr(DestType, target);</span>
<span class="line" id="L97">            }</span>
<span class="line" id="L98">        },</span>
<span class="line" id="L99">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L100">    }</span>
<span class="line" id="L101">    <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(DestType, target);</span>
<span class="line" id="L102">}</span>
<span class="line" id="L103"></span>
<span class="line" id="L104"><span class="tok-kw">fn</span> <span class="tok-fn">ptrInfo</span>(<span class="tok-kw">comptime</span> PtrType: <span class="tok-type">type</span>) std.builtin.Type.Pointer {</span>
<span class="line" id="L105">    <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(PtrType)) {</span>
<span class="line" id="L106">        .Optional =&gt; |opt_info| <span class="tok-builtin">@typeInfo</span>(opt_info.child).Pointer,</span>
<span class="line" id="L107">        .Pointer =&gt; |ptr_info| ptr_info,</span>
<span class="line" id="L108">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L109">    };</span>
<span class="line" id="L110">}</span>
<span class="line" id="L111"></span>
<span class="line" id="L112"><span class="tok-kw">test</span> <span class="tok-str">&quot;cast&quot;</span> {</span>
<span class="line" id="L113">    <span class="tok-kw">var</span> i = <span class="tok-builtin">@as</span>(<span class="tok-type">i64</span>, <span class="tok-number">10</span>);</span>
<span class="line" id="L114"></span>
<span class="line" id="L115">    <span class="tok-kw">try</span> testing.expect(cast(*<span class="tok-type">u8</span>, <span class="tok-number">16</span>) == <span class="tok-builtin">@intToPtr</span>(*<span class="tok-type">u8</span>, <span class="tok-number">16</span>));</span>
<span class="line" id="L116">    <span class="tok-kw">try</span> testing.expect(cast(*<span class="tok-type">u64</span>, &amp;i).* == <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">10</span>));</span>
<span class="line" id="L117">    <span class="tok-kw">try</span> testing.expect(cast(*<span class="tok-type">i64</span>, <span class="tok-builtin">@as</span>(?*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-type">i64</span>, &amp;i)) == &amp;i);</span>
<span class="line" id="L118"></span>
<span class="line" id="L119">    <span class="tok-kw">try</span> testing.expect(cast(?*<span class="tok-type">u8</span>, <span class="tok-number">2</span>) == <span class="tok-builtin">@intToPtr</span>(*<span class="tok-type">u8</span>, <span class="tok-number">2</span>));</span>
<span class="line" id="L120">    <span class="tok-kw">try</span> testing.expect(cast(?*<span class="tok-type">i64</span>, <span class="tok-builtin">@as</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-type">i64</span>, &amp;i)) == &amp;i);</span>
<span class="line" id="L121">    <span class="tok-kw">try</span> testing.expect(cast(?*<span class="tok-type">i64</span>, <span class="tok-builtin">@as</span>(?*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-type">i64</span>, &amp;i)) == &amp;i);</span>
<span class="line" id="L122"></span>
<span class="line" id="L123">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">4</span>), cast(<span class="tok-type">u32</span>, <span class="tok-builtin">@intToPtr</span>(*<span class="tok-type">u32</span>, <span class="tok-number">4</span>)));</span>
<span class="line" id="L124">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">4</span>), cast(<span class="tok-type">u32</span>, <span class="tok-builtin">@intToPtr</span>(?*<span class="tok-type">u32</span>, <span class="tok-number">4</span>)));</span>
<span class="line" id="L125">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">10</span>), cast(<span class="tok-type">u32</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">10</span>)));</span>
<span class="line" id="L126"></span>
<span class="line" id="L127">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@bitCast</span>(<span class="tok-type">i32</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0x8000_0000</span>)), cast(<span class="tok-type">i32</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0x8000_0000</span>)));</span>
<span class="line" id="L128"></span>
<span class="line" id="L129">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@intToPtr</span>(*<span class="tok-type">u8</span>, <span class="tok-number">2</span>), cast(*<span class="tok-type">u8</span>, <span class="tok-builtin">@intToPtr</span>(*<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-number">2</span>)));</span>
<span class="line" id="L130">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@intToPtr</span>(*<span class="tok-type">u8</span>, <span class="tok-number">2</span>), cast(*<span class="tok-type">u8</span>, <span class="tok-builtin">@intToPtr</span>(*<span class="tok-kw">volatile</span> <span class="tok-type">u8</span>, <span class="tok-number">2</span>)));</span>
<span class="line" id="L131"></span>
<span class="line" id="L132">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@intToPtr</span>(?*<span class="tok-type">anyopaque</span>, <span class="tok-number">2</span>), cast(?*<span class="tok-type">anyopaque</span>, <span class="tok-builtin">@intToPtr</span>(*<span class="tok-type">u8</span>, <span class="tok-number">2</span>)));</span>
<span class="line" id="L133"></span>
<span class="line" id="L134">    <span class="tok-kw">var</span> foo: <span class="tok-type">c_int</span> = -<span class="tok-number">1</span>;</span>
<span class="line" id="L135">    <span class="tok-kw">try</span> testing.expect(cast(*<span class="tok-type">anyopaque</span>, -<span class="tok-number">1</span>) == <span class="tok-builtin">@intToPtr</span>(*<span class="tok-type">anyopaque</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, -<span class="tok-number">1</span>))));</span>
<span class="line" id="L136">    <span class="tok-kw">try</span> testing.expect(cast(*<span class="tok-type">anyopaque</span>, foo) == <span class="tok-builtin">@intToPtr</span>(*<span class="tok-type">anyopaque</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, -<span class="tok-number">1</span>))));</span>
<span class="line" id="L137">    <span class="tok-kw">try</span> testing.expect(cast(?*<span class="tok-type">anyopaque</span>, -<span class="tok-number">1</span>) == <span class="tok-builtin">@intToPtr</span>(?*<span class="tok-type">anyopaque</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, -<span class="tok-number">1</span>))));</span>
<span class="line" id="L138">    <span class="tok-kw">try</span> testing.expect(cast(?*<span class="tok-type">anyopaque</span>, foo) == <span class="tok-builtin">@intToPtr</span>(?*<span class="tok-type">anyopaque</span>, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, -<span class="tok-number">1</span>))));</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">    <span class="tok-kw">const</span> FnPtr = <span class="tok-kw">if</span> (<span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>).zig_backend == .stage1)</span>
<span class="line" id="L141">        ?<span class="tok-kw">fn</span> (*<span class="tok-type">anyopaque</span>) <span class="tok-type">void</span></span>
<span class="line" id="L142">    <span class="tok-kw">else</span></span>
<span class="line" id="L143">        ?*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) <span class="tok-kw">const</span> <span class="tok-kw">fn</span> (*<span class="tok-type">anyopaque</span>) <span class="tok-type">void</span>;</span>
<span class="line" id="L144">    <span class="tok-kw">try</span> testing.expect(cast(FnPtr, <span class="tok-number">0</span>) == <span class="tok-builtin">@intToPtr</span>(FnPtr, <span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>)));</span>
<span class="line" id="L145">    <span class="tok-kw">try</span> testing.expect(cast(FnPtr, foo) == <span class="tok-builtin">@intToPtr</span>(FnPtr, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@as</span>(<span class="tok-type">isize</span>, -<span class="tok-number">1</span>))));</span>
<span class="line" id="L146">}</span>
<span class="line" id="L147"></span>
<span class="line" id="L148"><span class="tok-comment">/// Given a value returns its size as C's sizeof operator would.</span></span>
<span class="line" id="L149"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sizeof</span>(target: <span class="tok-kw">anytype</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L150">    <span class="tok-kw">const</span> T: <span class="tok-type">type</span> = <span class="tok-kw">if</span> (<span class="tok-builtin">@TypeOf</span>(target) == <span class="tok-type">type</span>) target <span class="tok-kw">else</span> <span class="tok-builtin">@TypeOf</span>(target);</span>
<span class="line" id="L151">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L152">        .Float, .Int, .Struct, .Union, .Array, .Bool, .Vector =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@sizeOf</span>(T),</span>
<span class="line" id="L153">        .Fn =&gt; {</span>
<span class="line" id="L154">            <span class="tok-kw">if</span> (<span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>).zig_backend == .stage1) {</span>
<span class="line" id="L155">                <span class="tok-comment">// sizeof(main) returns 1, sizeof(&amp;main) returns pointer size.</span>
</span>
<span class="line" id="L156">                <span class="tok-comment">// We cannot distinguish those types in Zig, so use pointer size.</span>
</span>
<span class="line" id="L157">                <span class="tok-kw">return</span> <span class="tok-builtin">@sizeOf</span>(T);</span>
<span class="line" id="L158">            }</span>
<span class="line" id="L159"></span>
<span class="line" id="L160">            <span class="tok-comment">// sizeof(main) in C returns 1</span>
</span>
<span class="line" id="L161">            <span class="tok-kw">return</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L162">        },</span>
<span class="line" id="L163">        .Null =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@sizeOf</span>(*<span class="tok-type">anyopaque</span>),</span>
<span class="line" id="L164">        .Void =&gt; {</span>
<span class="line" id="L165">            <span class="tok-comment">// Note: sizeof(void) is 1 on clang/gcc and 0 on MSVC.</span>
</span>
<span class="line" id="L166">            <span class="tok-kw">return</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L167">        },</span>
<span class="line" id="L168">        .Opaque =&gt; {</span>
<span class="line" id="L169">            <span class="tok-kw">if</span> (T == <span class="tok-type">anyopaque</span>) {</span>
<span class="line" id="L170">                <span class="tok-comment">// Note: sizeof(void) is 1 on clang/gcc and 0 on MSVC.</span>
</span>
<span class="line" id="L171">                <span class="tok-kw">return</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L172">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L173">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot use C sizeof on opaque type &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T));</span>
<span class="line" id="L174">            }</span>
<span class="line" id="L175">        },</span>
<span class="line" id="L176">        .Optional =&gt; |opt| {</span>
<span class="line" id="L177">            <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(opt.child) == .Pointer) {</span>
<span class="line" id="L178">                <span class="tok-kw">return</span> sizeof(opt.child);</span>
<span class="line" id="L179">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L180">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot use C sizeof on non-pointer optional &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T));</span>
<span class="line" id="L181">            }</span>
<span class="line" id="L182">        },</span>
<span class="line" id="L183">        .Pointer =&gt; |ptr| {</span>
<span class="line" id="L184">            <span class="tok-kw">if</span> (ptr.size == .Slice) {</span>
<span class="line" id="L185">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot use C sizeof on slice type &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T));</span>
<span class="line" id="L186">            }</span>
<span class="line" id="L187">            <span class="tok-comment">// for strings, sizeof(&quot;a&quot;) returns 2.</span>
</span>
<span class="line" id="L188">            <span class="tok-comment">// normal pointer decay scenarios from C are handled</span>
</span>
<span class="line" id="L189">            <span class="tok-comment">// in the .Array case above, but strings remain literals</span>
</span>
<span class="line" id="L190">            <span class="tok-comment">// and are therefore always pointers, so they need to be</span>
</span>
<span class="line" id="L191">            <span class="tok-comment">// specially handled here.</span>
</span>
<span class="line" id="L192">            <span class="tok-kw">if</span> (ptr.size == .One <span class="tok-kw">and</span> ptr.is_const <span class="tok-kw">and</span> <span class="tok-builtin">@typeInfo</span>(ptr.child) == .Array) {</span>
<span class="line" id="L193">                <span class="tok-kw">const</span> array_info = <span class="tok-builtin">@typeInfo</span>(ptr.child).Array;</span>
<span class="line" id="L194">                <span class="tok-kw">if</span> ((array_info.child == <span class="tok-type">u8</span> <span class="tok-kw">or</span> array_info.child == <span class="tok-type">u16</span>) <span class="tok-kw">and</span></span>
<span class="line" id="L195">                    array_info.sentinel != <span class="tok-null">null</span> <span class="tok-kw">and</span></span>
<span class="line" id="L196">                    <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">const</span> array_info.child, array_info.sentinel.?).* == <span class="tok-number">0</span>)</span>
<span class="line" id="L197">                {</span>
<span class="line" id="L198">                    <span class="tok-comment">// length of the string plus one for the null terminator.</span>
</span>
<span class="line" id="L199">                    <span class="tok-kw">return</span> (array_info.len + <span class="tok-number">1</span>) * <span class="tok-builtin">@sizeOf</span>(array_info.child);</span>
<span class="line" id="L200">                }</span>
<span class="line" id="L201">            }</span>
<span class="line" id="L202">            <span class="tok-comment">// When zero sized pointers are removed, this case will no</span>
</span>
<span class="line" id="L203">            <span class="tok-comment">// longer be reachable and can be deleted.</span>
</span>
<span class="line" id="L204">            <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(T) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L205">                <span class="tok-kw">return</span> <span class="tok-builtin">@sizeOf</span>(*<span class="tok-type">anyopaque</span>);</span>
<span class="line" id="L206">            }</span>
<span class="line" id="L207">            <span class="tok-kw">return</span> <span class="tok-builtin">@sizeOf</span>(T);</span>
<span class="line" id="L208">        },</span>
<span class="line" id="L209">        .ComptimeFloat =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">f64</span>), <span class="tok-comment">// TODO c_double #3999</span>
</span>
<span class="line" id="L210">        .ComptimeInt =&gt; {</span>
<span class="line" id="L211">            <span class="tok-comment">// TODO to get the correct result we have to translate</span>
</span>
<span class="line" id="L212">            <span class="tok-comment">// `1073741824 * 4` as `int(1073741824) *% int(4)` since</span>
</span>
<span class="line" id="L213">            <span class="tok-comment">// sizeof(1073741824 * 4) != sizeof(4294967296).</span>
</span>
<span class="line" id="L214"></span>
<span class="line" id="L215">            <span class="tok-comment">// TODO test if target fits in int, long or long long</span>
</span>
<span class="line" id="L216">            <span class="tok-kw">return</span> <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">c_int</span>);</span>
<span class="line" id="L217">        },</span>
<span class="line" id="L218">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;std.meta.sizeof does not support type &quot;</span> ++ <span class="tok-builtin">@typeName</span>(T)),</span>
<span class="line" id="L219">    }</span>
<span class="line" id="L220">}</span>
<span class="line" id="L221"></span>
<span class="line" id="L222"><span class="tok-kw">test</span> <span class="tok-str">&quot;sizeof&quot;</span> {</span>
<span class="line" id="L223">    <span class="tok-kw">const</span> S = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> { a: <span class="tok-type">u32</span> };</span>
<span class="line" id="L224"></span>
<span class="line" id="L225">    <span class="tok-kw">const</span> ptr_size = <span class="tok-builtin">@sizeOf</span>(*<span class="tok-type">anyopaque</span>);</span>
<span class="line" id="L226"></span>
<span class="line" id="L227">    <span class="tok-kw">try</span> testing.expect(sizeof(<span class="tok-type">u32</span>) == <span class="tok-number">4</span>);</span>
<span class="line" id="L228">    <span class="tok-kw">try</span> testing.expect(sizeof(<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>)) == <span class="tok-number">4</span>);</span>
<span class="line" id="L229">    <span class="tok-kw">try</span> testing.expect(sizeof(<span class="tok-number">2</span>) == <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">c_int</span>));</span>
<span class="line" id="L230"></span>
<span class="line" id="L231">    <span class="tok-kw">try</span> testing.expect(sizeof(<span class="tok-number">2.0</span>) == <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">f64</span>));</span>
<span class="line" id="L232"></span>
<span class="line" id="L233">    <span class="tok-kw">try</span> testing.expect(sizeof(S) == <span class="tok-number">4</span>);</span>
<span class="line" id="L234"></span>
<span class="line" id="L235">    <span class="tok-kw">try</span> testing.expect(sizeof([_]<span class="tok-type">u32</span>{ <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span> }) == <span class="tok-number">12</span>);</span>
<span class="line" id="L236">    <span class="tok-kw">try</span> testing.expect(sizeof([<span class="tok-number">3</span>]<span class="tok-type">u32</span>) == <span class="tok-number">12</span>);</span>
<span class="line" id="L237">    <span class="tok-kw">try</span> testing.expect(sizeof([<span class="tok-number">3</span>:<span class="tok-number">0</span>]<span class="tok-type">u32</span>) == <span class="tok-number">16</span>);</span>
<span class="line" id="L238">    <span class="tok-kw">try</span> testing.expect(sizeof(&amp;[_]<span class="tok-type">u32</span>{ <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span> }) == ptr_size);</span>
<span class="line" id="L239"></span>
<span class="line" id="L240">    <span class="tok-kw">try</span> testing.expect(sizeof(*<span class="tok-type">u32</span>) == ptr_size);</span>
<span class="line" id="L241">    <span class="tok-kw">try</span> testing.expect(sizeof([*]<span class="tok-type">u32</span>) == ptr_size);</span>
<span class="line" id="L242">    <span class="tok-kw">try</span> testing.expect(sizeof([*c]<span class="tok-type">u32</span>) == ptr_size);</span>
<span class="line" id="L243">    <span class="tok-kw">try</span> testing.expect(sizeof(?*<span class="tok-type">u32</span>) == ptr_size);</span>
<span class="line" id="L244">    <span class="tok-kw">try</span> testing.expect(sizeof(?[*]<span class="tok-type">u32</span>) == ptr_size);</span>
<span class="line" id="L245">    <span class="tok-kw">try</span> testing.expect(sizeof(*<span class="tok-type">anyopaque</span>) == ptr_size);</span>
<span class="line" id="L246">    <span class="tok-kw">try</span> testing.expect(sizeof(*<span class="tok-type">void</span>) == ptr_size);</span>
<span class="line" id="L247">    <span class="tok-kw">try</span> testing.expect(sizeof(<span class="tok-null">null</span>) == ptr_size);</span>
<span class="line" id="L248"></span>
<span class="line" id="L249">    <span class="tok-kw">try</span> testing.expect(sizeof(<span class="tok-str">&quot;foobar&quot;</span>) == <span class="tok-number">7</span>);</span>
<span class="line" id="L250">    <span class="tok-kw">try</span> testing.expect(sizeof(&amp;[_:<span class="tok-number">0</span>]<span class="tok-type">u16</span>{ <span class="tok-str">'f'</span>, <span class="tok-str">'o'</span>, <span class="tok-str">'o'</span>, <span class="tok-str">'b'</span>, <span class="tok-str">'a'</span>, <span class="tok-str">'r'</span> }) == <span class="tok-number">14</span>);</span>
<span class="line" id="L251">    <span class="tok-kw">try</span> testing.expect(sizeof(*<span class="tok-kw">const</span> [<span class="tok-number">4</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>) == <span class="tok-number">5</span>);</span>
<span class="line" id="L252">    <span class="tok-kw">try</span> testing.expect(sizeof(*[<span class="tok-number">4</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>) == ptr_size);</span>
<span class="line" id="L253">    <span class="tok-kw">try</span> testing.expect(sizeof([*]<span class="tok-kw">const</span> [<span class="tok-number">4</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>) == ptr_size);</span>
<span class="line" id="L254">    <span class="tok-kw">try</span> testing.expect(sizeof(*<span class="tok-kw">const</span> *<span class="tok-kw">const</span> [<span class="tok-number">4</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>) == ptr_size);</span>
<span class="line" id="L255">    <span class="tok-kw">try</span> testing.expect(sizeof(*<span class="tok-kw">const</span> [<span class="tok-number">4</span>]<span class="tok-type">u8</span>) == ptr_size);</span>
<span class="line" id="L256"></span>
<span class="line" id="L257">    <span class="tok-kw">if</span> (<span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>).zig_backend == .stage1) {</span>
<span class="line" id="L258">        <span class="tok-kw">try</span> testing.expect(sizeof(sizeof) == <span class="tok-builtin">@sizeOf</span>(<span class="tok-builtin">@TypeOf</span>(sizeof)));</span>
<span class="line" id="L259">    } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-null">false</span>) { <span class="tok-comment">// TODO</span>
</span>
<span class="line" id="L260">        <span class="tok-kw">try</span> testing.expect(sizeof(&amp;sizeof) == <span class="tok-builtin">@sizeOf</span>(<span class="tok-builtin">@TypeOf</span>(&amp;sizeof)));</span>
<span class="line" id="L261">        <span class="tok-kw">try</span> testing.expect(sizeof(sizeof) == <span class="tok-number">1</span>);</span>
<span class="line" id="L262">    }</span>
<span class="line" id="L263"></span>
<span class="line" id="L264">    <span class="tok-kw">try</span> testing.expect(sizeof(<span class="tok-type">void</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L265">    <span class="tok-kw">try</span> testing.expect(sizeof(<span class="tok-type">anyopaque</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L266">}</span>
<span class="line" id="L267"></span>
<span class="line" id="L268"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CIntLiteralRadix = <span class="tok-kw">enum</span> { decimal, octal, hexadecimal };</span>
<span class="line" id="L269"></span>
<span class="line" id="L270"><span class="tok-kw">fn</span> <span class="tok-fn">PromoteIntLiteralReturnType</span>(<span class="tok-kw">comptime</span> SuffixType: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> number: <span class="tok-type">comptime_int</span>, <span class="tok-kw">comptime</span> radix: CIntLiteralRadix) <span class="tok-type">type</span> {</span>
<span class="line" id="L271">    <span class="tok-kw">const</span> signed_decimal = [_]<span class="tok-type">type</span>{ <span class="tok-type">c_int</span>, <span class="tok-type">c_long</span>, <span class="tok-type">c_longlong</span> };</span>
<span class="line" id="L272">    <span class="tok-kw">const</span> signed_oct_hex = [_]<span class="tok-type">type</span>{ <span class="tok-type">c_int</span>, <span class="tok-type">c_uint</span>, <span class="tok-type">c_long</span>, <span class="tok-type">c_ulong</span>, <span class="tok-type">c_longlong</span>, <span class="tok-type">c_ulonglong</span> };</span>
<span class="line" id="L273">    <span class="tok-kw">const</span> unsigned = [_]<span class="tok-type">type</span>{ <span class="tok-type">c_uint</span>, <span class="tok-type">c_ulong</span>, <span class="tok-type">c_ulonglong</span> };</span>
<span class="line" id="L274"></span>
<span class="line" id="L275">    <span class="tok-kw">const</span> list: []<span class="tok-kw">const</span> <span class="tok-type">type</span> = <span class="tok-kw">if</span> (<span class="tok-builtin">@typeInfo</span>(SuffixType).Int.signedness == .unsigned)</span>
<span class="line" id="L276">        &amp;unsigned</span>
<span class="line" id="L277">    <span class="tok-kw">else</span> <span class="tok-kw">if</span> (radix == .decimal)</span>
<span class="line" id="L278">        &amp;signed_decimal</span>
<span class="line" id="L279">    <span class="tok-kw">else</span></span>
<span class="line" id="L280">        &amp;signed_oct_hex;</span>
<span class="line" id="L281"></span>
<span class="line" id="L282">    <span class="tok-kw">var</span> pos = mem.indexOfScalar(<span class="tok-type">type</span>, list, SuffixType).?;</span>
<span class="line" id="L283"></span>
<span class="line" id="L284">    <span class="tok-kw">while</span> (pos &lt; list.len) : (pos += <span class="tok-number">1</span>) {</span>
<span class="line" id="L285">        <span class="tok-kw">if</span> (number &gt;= math.minInt(list[pos]) <span class="tok-kw">and</span> number &lt;= math.maxInt(list[pos])) {</span>
<span class="line" id="L286">            <span class="tok-kw">return</span> list[pos];</span>
<span class="line" id="L287">        }</span>
<span class="line" id="L288">    }</span>
<span class="line" id="L289">    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Integer literal is too large&quot;</span>);</span>
<span class="line" id="L290">}</span>
<span class="line" id="L291"></span>
<span class="line" id="L292"><span class="tok-comment">/// Promote the type of an integer literal until it fits as C would.</span></span>
<span class="line" id="L293"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">promoteIntLiteral</span>(</span>
<span class="line" id="L294">    <span class="tok-kw">comptime</span> SuffixType: <span class="tok-type">type</span>,</span>
<span class="line" id="L295">    <span class="tok-kw">comptime</span> number: <span class="tok-type">comptime_int</span>,</span>
<span class="line" id="L296">    <span class="tok-kw">comptime</span> radix: CIntLiteralRadix,</span>
<span class="line" id="L297">) PromoteIntLiteralReturnType(SuffixType, number, radix) {</span>
<span class="line" id="L298">    <span class="tok-kw">return</span> number;</span>
<span class="line" id="L299">}</span>
<span class="line" id="L300"></span>
<span class="line" id="L301"><span class="tok-kw">test</span> <span class="tok-str">&quot;promoteIntLiteral&quot;</span> {</span>
<span class="line" id="L302">    <span class="tok-kw">const</span> signed_hex = promoteIntLiteral(<span class="tok-type">c_int</span>, math.maxInt(<span class="tok-type">c_int</span>) + <span class="tok-number">1</span>, .hexadecimal);</span>
<span class="line" id="L303">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-type">c_uint</span>, <span class="tok-builtin">@TypeOf</span>(signed_hex));</span>
<span class="line" id="L304"></span>
<span class="line" id="L305">    <span class="tok-kw">if</span> (math.maxInt(<span class="tok-type">c_longlong</span>) == math.maxInt(<span class="tok-type">c_int</span>)) <span class="tok-kw">return</span>;</span>
<span class="line" id="L306"></span>
<span class="line" id="L307">    <span class="tok-kw">const</span> signed_decimal = promoteIntLiteral(<span class="tok-type">c_int</span>, math.maxInt(<span class="tok-type">c_int</span>) + <span class="tok-number">1</span>, .decimal);</span>
<span class="line" id="L308">    <span class="tok-kw">const</span> unsigned = promoteIntLiteral(<span class="tok-type">c_uint</span>, math.maxInt(<span class="tok-type">c_uint</span>) + <span class="tok-number">1</span>, .hexadecimal);</span>
<span class="line" id="L309"></span>
<span class="line" id="L310">    <span class="tok-kw">if</span> (math.maxInt(<span class="tok-type">c_long</span>) &gt; math.maxInt(<span class="tok-type">c_int</span>)) {</span>
<span class="line" id="L311">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-type">c_long</span>, <span class="tok-builtin">@TypeOf</span>(signed_decimal));</span>
<span class="line" id="L312">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-type">c_ulong</span>, <span class="tok-builtin">@TypeOf</span>(unsigned));</span>
<span class="line" id="L313">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L314">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-type">c_longlong</span>, <span class="tok-builtin">@TypeOf</span>(signed_decimal));</span>
<span class="line" id="L315">        <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-type">c_ulonglong</span>, <span class="tok-builtin">@TypeOf</span>(unsigned));</span>
<span class="line" id="L316">    }</span>
<span class="line" id="L317">}</span>
<span class="line" id="L318"></span>
<span class="line" id="L319"><span class="tok-comment">/// Convert from clang __builtin_shufflevector index to Zig @shuffle index</span></span>
<span class="line" id="L320"><span class="tok-comment">/// clang requires __builtin_shufflevector index arguments to be integer constants.</span></span>
<span class="line" id="L321"><span class="tok-comment">/// negative values for `this_index` indicate &quot;don't care&quot; so we arbitrarily choose 0</span></span>
<span class="line" id="L322"><span class="tok-comment">/// clang enforces that `this_index` is less than the total number of vector elements</span></span>
<span class="line" id="L323"><span class="tok-comment">/// See https://ziglang.org/documentation/master/#shuffle</span></span>
<span class="line" id="L324"><span class="tok-comment">/// See https://clang.llvm.org/docs/LanguageExtensions.html#langext-builtin-shufflevector</span></span>
<span class="line" id="L325"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shuffleVectorIndex</span>(<span class="tok-kw">comptime</span> this_index: <span class="tok-type">c_int</span>, <span class="tok-kw">comptime</span> source_vector_len: <span class="tok-type">usize</span>) <span class="tok-type">i32</span> {</span>
<span class="line" id="L326">    <span class="tok-kw">if</span> (this_index &lt;= <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L327"></span>
<span class="line" id="L328">    <span class="tok-kw">const</span> positive_index = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, this_index);</span>
<span class="line" id="L329">    <span class="tok-kw">if</span> (positive_index &lt; source_vector_len) <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, this_index);</span>
<span class="line" id="L330">    <span class="tok-kw">const</span> b_index = positive_index - source_vector_len;</span>
<span class="line" id="L331">    <span class="tok-kw">return</span> ~<span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, b_index);</span>
<span class="line" id="L332">}</span>
<span class="line" id="L333"></span>
<span class="line" id="L334"><span class="tok-kw">test</span> <span class="tok-str">&quot;shuffleVectorIndex&quot;</span> {</span>
<span class="line" id="L335">    <span class="tok-kw">const</span> vector_len: <span class="tok-type">usize</span> = <span class="tok-number">4</span>;</span>
<span class="line" id="L336"></span>
<span class="line" id="L337">    <span class="tok-kw">try</span> testing.expect(shuffleVectorIndex(-<span class="tok-number">1</span>, vector_len) == <span class="tok-number">0</span>);</span>
<span class="line" id="L338"></span>
<span class="line" id="L339">    <span class="tok-kw">try</span> testing.expect(shuffleVectorIndex(<span class="tok-number">0</span>, vector_len) == <span class="tok-number">0</span>);</span>
<span class="line" id="L340">    <span class="tok-kw">try</span> testing.expect(shuffleVectorIndex(<span class="tok-number">1</span>, vector_len) == <span class="tok-number">1</span>);</span>
<span class="line" id="L341">    <span class="tok-kw">try</span> testing.expect(shuffleVectorIndex(<span class="tok-number">2</span>, vector_len) == <span class="tok-number">2</span>);</span>
<span class="line" id="L342">    <span class="tok-kw">try</span> testing.expect(shuffleVectorIndex(<span class="tok-number">3</span>, vector_len) == <span class="tok-number">3</span>);</span>
<span class="line" id="L343"></span>
<span class="line" id="L344">    <span class="tok-kw">try</span> testing.expect(shuffleVectorIndex(<span class="tok-number">4</span>, vector_len) == -<span class="tok-number">1</span>);</span>
<span class="line" id="L345">    <span class="tok-kw">try</span> testing.expect(shuffleVectorIndex(<span class="tok-number">5</span>, vector_len) == -<span class="tok-number">2</span>);</span>
<span class="line" id="L346">    <span class="tok-kw">try</span> testing.expect(shuffleVectorIndex(<span class="tok-number">6</span>, vector_len) == -<span class="tok-number">3</span>);</span>
<span class="line" id="L347">    <span class="tok-kw">try</span> testing.expect(shuffleVectorIndex(<span class="tok-number">7</span>, vector_len) == -<span class="tok-number">4</span>);</span>
<span class="line" id="L348">}</span>
<span class="line" id="L349"></span>
<span class="line" id="L350"><span class="tok-comment">/// Constructs a [*c] pointer with the const and volatile annotations</span></span>
<span class="line" id="L351"><span class="tok-comment">/// from SelfType for pointing to a C flexible array of ElementType.</span></span>
<span class="line" id="L352"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">FlexibleArrayType</span>(<span class="tok-kw">comptime</span> SelfType: <span class="tok-type">type</span>, ElementType: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L353">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(SelfType)) {</span>
<span class="line" id="L354">        .Pointer =&gt; |ptr| {</span>
<span class="line" id="L355">            <span class="tok-kw">return</span> <span class="tok-builtin">@Type</span>(.{ .Pointer = .{</span>
<span class="line" id="L356">                .size = .C,</span>
<span class="line" id="L357">                .is_const = ptr.is_const,</span>
<span class="line" id="L358">                .is_volatile = ptr.is_volatile,</span>
<span class="line" id="L359">                .alignment = <span class="tok-builtin">@alignOf</span>(ElementType),</span>
<span class="line" id="L360">                .address_space = .generic,</span>
<span class="line" id="L361">                .child = ElementType,</span>
<span class="line" id="L362">                .is_allowzero = <span class="tok-null">true</span>,</span>
<span class="line" id="L363">                .sentinel = <span class="tok-null">null</span>,</span>
<span class="line" id="L364">            } });</span>
<span class="line" id="L365">        },</span>
<span class="line" id="L366">        <span class="tok-kw">else</span> =&gt; |info| <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Invalid self type \&quot;&quot;</span> ++ <span class="tok-builtin">@tagName</span>(info) ++ <span class="tok-str">&quot;\&quot; for flexible array getter: &quot;</span> ++ <span class="tok-builtin">@typeName</span>(SelfType)),</span>
<span class="line" id="L367">    }</span>
<span class="line" id="L368">}</span>
<span class="line" id="L369"></span>
<span class="line" id="L370"><span class="tok-kw">test</span> <span class="tok-str">&quot;Flexible Array Type&quot;</span> {</span>
<span class="line" id="L371">    <span class="tok-kw">const</span> Container = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L372">        size: <span class="tok-type">usize</span>,</span>
<span class="line" id="L373">    };</span>
<span class="line" id="L374"></span>
<span class="line" id="L375">    <span class="tok-kw">try</span> testing.expectEqual(FlexibleArrayType(*Container, <span class="tok-type">c_int</span>), [*c]<span class="tok-type">c_int</span>);</span>
<span class="line" id="L376">    <span class="tok-kw">try</span> testing.expectEqual(FlexibleArrayType(*<span class="tok-kw">const</span> Container, <span class="tok-type">c_int</span>), [*c]<span class="tok-kw">const</span> <span class="tok-type">c_int</span>);</span>
<span class="line" id="L377">    <span class="tok-kw">try</span> testing.expectEqual(FlexibleArrayType(*<span class="tok-kw">volatile</span> Container, <span class="tok-type">c_int</span>), [*c]<span class="tok-kw">volatile</span> <span class="tok-type">c_int</span>);</span>
<span class="line" id="L378">    <span class="tok-kw">try</span> testing.expectEqual(FlexibleArrayType(*<span class="tok-kw">const</span> <span class="tok-kw">volatile</span> Container, <span class="tok-type">c_int</span>), [*c]<span class="tok-kw">const</span> <span class="tok-kw">volatile</span> <span class="tok-type">c_int</span>);</span>
<span class="line" id="L379">}</span>
<span class="line" id="L380"></span>
<span class="line" id="L381"><span class="tok-comment">/// C `%` operator for signed integers</span></span>
<span class="line" id="L382"><span class="tok-comment">/// C standard states: &quot;If the quotient a/b is representable, the expression (a/b)*b + a%b shall equal a&quot;</span></span>
<span class="line" id="L383"><span class="tok-comment">/// The quotient is not representable if denominator is zero, or if numerator is the minimum integer for</span></span>
<span class="line" id="L384"><span class="tok-comment">/// the type and denominator is -1. C has undefined behavior for those two cases; this function has safety</span></span>
<span class="line" id="L385"><span class="tok-comment">/// checked undefined behavior</span></span>
<span class="line" id="L386"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">signedRemainder</span>(numerator: <span class="tok-kw">anytype</span>, denominator: <span class="tok-kw">anytype</span>) <span class="tok-builtin">@TypeOf</span>(numerator, denominator) {</span>
<span class="line" id="L387">    std.debug.assert(<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(numerator, denominator)).Int.signedness == .signed);</span>
<span class="line" id="L388">    <span class="tok-kw">if</span> (denominator &gt; <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-builtin">@rem</span>(numerator, denominator);</span>
<span class="line" id="L389">    <span class="tok-kw">return</span> numerator - <span class="tok-builtin">@divTrunc</span>(numerator, denominator) * denominator;</span>
<span class="line" id="L390">}</span>
<span class="line" id="L391"></span>
<span class="line" id="L392"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Macros = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L393">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">U_SUFFIX</span>(<span class="tok-kw">comptime</span> n: <span class="tok-type">comptime_int</span>) <span class="tok-builtin">@TypeOf</span>(promoteIntLiteral(<span class="tok-type">c_uint</span>, n, .decimal)) {</span>
<span class="line" id="L394">        <span class="tok-kw">return</span> promoteIntLiteral(<span class="tok-type">c_uint</span>, n, .decimal);</span>
<span class="line" id="L395">    }</span>
<span class="line" id="L396"></span>
<span class="line" id="L397">    <span class="tok-kw">fn</span> <span class="tok-fn">L_SUFFIX_ReturnType</span>(<span class="tok-kw">comptime</span> number: <span class="tok-kw">anytype</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L398">        <span class="tok-kw">switch</span> (<span class="tok-builtin">@TypeOf</span>(number)) {</span>
<span class="line" id="L399">            <span class="tok-type">comptime_int</span> =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@TypeOf</span>(promoteIntLiteral(<span class="tok-type">c_long</span>, number, .decimal)),</span>
<span class="line" id="L400">            <span class="tok-type">comptime_float</span> =&gt; <span class="tok-kw">return</span> <span class="tok-type">c_longdouble</span>,</span>
<span class="line" id="L401">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Invalid value for L suffix&quot;</span>),</span>
<span class="line" id="L402">        }</span>
<span class="line" id="L403">    }</span>
<span class="line" id="L404">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">L_SUFFIX</span>(<span class="tok-kw">comptime</span> number: <span class="tok-kw">anytype</span>) L_SUFFIX_ReturnType(number) {</span>
<span class="line" id="L405">        <span class="tok-kw">switch</span> (<span class="tok-builtin">@TypeOf</span>(number)) {</span>
<span class="line" id="L406">            <span class="tok-type">comptime_int</span> =&gt; <span class="tok-kw">return</span> promoteIntLiteral(<span class="tok-type">c_long</span>, number, .decimal),</span>
<span class="line" id="L407">            <span class="tok-type">comptime_float</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;TODO: c_longdouble initialization from comptime_float not supported&quot;</span>),</span>
<span class="line" id="L408">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Invalid value for L suffix&quot;</span>),</span>
<span class="line" id="L409">        }</span>
<span class="line" id="L410">    }</span>
<span class="line" id="L411"></span>
<span class="line" id="L412">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">UL_SUFFIX</span>(<span class="tok-kw">comptime</span> n: <span class="tok-type">comptime_int</span>) <span class="tok-builtin">@TypeOf</span>(promoteIntLiteral(<span class="tok-type">c_ulong</span>, n, .decimal)) {</span>
<span class="line" id="L413">        <span class="tok-kw">return</span> promoteIntLiteral(<span class="tok-type">c_ulong</span>, n, .decimal);</span>
<span class="line" id="L414">    }</span>
<span class="line" id="L415"></span>
<span class="line" id="L416">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">LL_SUFFIX</span>(<span class="tok-kw">comptime</span> n: <span class="tok-type">comptime_int</span>) <span class="tok-builtin">@TypeOf</span>(promoteIntLiteral(<span class="tok-type">c_longlong</span>, n, .decimal)) {</span>
<span class="line" id="L417">        <span class="tok-kw">return</span> promoteIntLiteral(<span class="tok-type">c_longlong</span>, n, .decimal);</span>
<span class="line" id="L418">    }</span>
<span class="line" id="L419"></span>
<span class="line" id="L420">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ULL_SUFFIX</span>(<span class="tok-kw">comptime</span> n: <span class="tok-type">comptime_int</span>) <span class="tok-builtin">@TypeOf</span>(promoteIntLiteral(<span class="tok-type">c_ulonglong</span>, n, .decimal)) {</span>
<span class="line" id="L421">        <span class="tok-kw">return</span> promoteIntLiteral(<span class="tok-type">c_ulonglong</span>, n, .decimal);</span>
<span class="line" id="L422">    }</span>
<span class="line" id="L423"></span>
<span class="line" id="L424">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">F_SUFFIX</span>(<span class="tok-kw">comptime</span> f: <span class="tok-type">comptime_float</span>) <span class="tok-type">f32</span> {</span>
<span class="line" id="L425">        <span class="tok-kw">return</span> <span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, f);</span>
<span class="line" id="L426">    }</span>
<span class="line" id="L427"></span>
<span class="line" id="L428">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">WL_CONTAINER_OF</span>(ptr: <span class="tok-kw">anytype</span>, sample: <span class="tok-kw">anytype</span>, <span class="tok-kw">comptime</span> member: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-builtin">@TypeOf</span>(sample) {</span>
<span class="line" id="L429">        <span class="tok-kw">return</span> <span class="tok-builtin">@fieldParentPtr</span>(<span class="tok-builtin">@TypeOf</span>(sample.*), member, ptr);</span>
<span class="line" id="L430">    }</span>
<span class="line" id="L431"></span>
<span class="line" id="L432">    <span class="tok-comment">/// A 2-argument function-like macro defined as #define FOO(A, B) (A)(B)</span></span>
<span class="line" id="L433">    <span class="tok-comment">/// could be either: cast B to A, or call A with the value B.</span></span>
<span class="line" id="L434">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">CAST_OR_CALL</span>(a: <span class="tok-kw">anytype</span>, b: <span class="tok-kw">anytype</span>) <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(a))) {</span>
<span class="line" id="L435">        .Type =&gt; a,</span>
<span class="line" id="L436">        .Fn =&gt; |fn_info| fn_info.return_type <span class="tok-kw">orelse</span> <span class="tok-type">void</span>,</span>
<span class="line" id="L437">        <span class="tok-kw">else</span> =&gt; |info| <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unexpected argument type: &quot;</span> ++ <span class="tok-builtin">@tagName</span>(info)),</span>
<span class="line" id="L438">    } {</span>
<span class="line" id="L439">        <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(a))) {</span>
<span class="line" id="L440">            .Type =&gt; <span class="tok-kw">return</span> cast(a, b),</span>
<span class="line" id="L441">            .Fn =&gt; <span class="tok-kw">return</span> a(b),</span>
<span class="line" id="L442">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// return type will be a compile error otherwise</span>
</span>
<span class="line" id="L443">        }</span>
<span class="line" id="L444">    }</span>
<span class="line" id="L445"></span>
<span class="line" id="L446">    <span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">DISCARD</span>(x: <span class="tok-kw">anytype</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L447">        _ = x;</span>
<span class="line" id="L448">    }</span>
<span class="line" id="L449">};</span>
<span class="line" id="L450"></span>
<span class="line" id="L451"><span class="tok-kw">test</span> <span class="tok-str">&quot;Macro suffix functions&quot;</span> {</span>
<span class="line" id="L452">    <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@TypeOf</span>(Macros.F_SUFFIX(<span class="tok-number">1</span>)) == <span class="tok-type">f32</span>);</span>
<span class="line" id="L453"></span>
<span class="line" id="L454">    <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@TypeOf</span>(Macros.U_SUFFIX(<span class="tok-number">1</span>)) == <span class="tok-type">c_uint</span>);</span>
<span class="line" id="L455">    <span class="tok-kw">if</span> (math.maxInt(<span class="tok-type">c_ulong</span>) &gt; math.maxInt(<span class="tok-type">c_uint</span>)) {</span>
<span class="line" id="L456">        <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@TypeOf</span>(Macros.U_SUFFIX(math.maxInt(<span class="tok-type">c_uint</span>) + <span class="tok-number">1</span>)) == <span class="tok-type">c_ulong</span>);</span>
<span class="line" id="L457">    }</span>
<span class="line" id="L458">    <span class="tok-kw">if</span> (math.maxInt(<span class="tok-type">c_ulonglong</span>) &gt; math.maxInt(<span class="tok-type">c_ulong</span>)) {</span>
<span class="line" id="L459">        <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@TypeOf</span>(Macros.U_SUFFIX(math.maxInt(<span class="tok-type">c_ulong</span>) + <span class="tok-number">1</span>)) == <span class="tok-type">c_ulonglong</span>);</span>
<span class="line" id="L460">    }</span>
<span class="line" id="L461"></span>
<span class="line" id="L462">    <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@TypeOf</span>(Macros.L_SUFFIX(<span class="tok-number">1</span>)) == <span class="tok-type">c_long</span>);</span>
<span class="line" id="L463">    <span class="tok-kw">if</span> (math.maxInt(<span class="tok-type">c_long</span>) &gt; math.maxInt(<span class="tok-type">c_int</span>)) {</span>
<span class="line" id="L464">        <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@TypeOf</span>(Macros.L_SUFFIX(math.maxInt(<span class="tok-type">c_int</span>) + <span class="tok-number">1</span>)) == <span class="tok-type">c_long</span>);</span>
<span class="line" id="L465">    }</span>
<span class="line" id="L466">    <span class="tok-kw">if</span> (math.maxInt(<span class="tok-type">c_longlong</span>) &gt; math.maxInt(<span class="tok-type">c_long</span>)) {</span>
<span class="line" id="L467">        <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@TypeOf</span>(Macros.L_SUFFIX(math.maxInt(<span class="tok-type">c_long</span>) + <span class="tok-number">1</span>)) == <span class="tok-type">c_longlong</span>);</span>
<span class="line" id="L468">    }</span>
<span class="line" id="L469"></span>
<span class="line" id="L470">    <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@TypeOf</span>(Macros.UL_SUFFIX(<span class="tok-number">1</span>)) == <span class="tok-type">c_ulong</span>);</span>
<span class="line" id="L471">    <span class="tok-kw">if</span> (math.maxInt(<span class="tok-type">c_ulonglong</span>) &gt; math.maxInt(<span class="tok-type">c_ulong</span>)) {</span>
<span class="line" id="L472">        <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@TypeOf</span>(Macros.UL_SUFFIX(math.maxInt(<span class="tok-type">c_ulong</span>) + <span class="tok-number">1</span>)) == <span class="tok-type">c_ulonglong</span>);</span>
<span class="line" id="L473">    }</span>
<span class="line" id="L474"></span>
<span class="line" id="L475">    <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@TypeOf</span>(Macros.LL_SUFFIX(<span class="tok-number">1</span>)) == <span class="tok-type">c_longlong</span>);</span>
<span class="line" id="L476">    <span class="tok-kw">try</span> testing.expect(<span class="tok-builtin">@TypeOf</span>(Macros.ULL_SUFFIX(<span class="tok-number">1</span>)) == <span class="tok-type">c_ulonglong</span>);</span>
<span class="line" id="L477">}</span>
<span class="line" id="L478"></span>
<span class="line" id="L479"><span class="tok-kw">test</span> <span class="tok-str">&quot;WL_CONTAINER_OF&quot;</span> {</span>
<span class="line" id="L480">    <span class="tok-kw">const</span> S = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L481">        a: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L482">        b: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L483">    };</span>
<span class="line" id="L484">    <span class="tok-kw">var</span> x = S{};</span>
<span class="line" id="L485">    <span class="tok-kw">var</span> y = S{};</span>
<span class="line" id="L486">    <span class="tok-kw">var</span> ptr = Macros.WL_CONTAINER_OF(&amp;x.b, &amp;y, <span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L487">    <span class="tok-kw">try</span> testing.expectEqual(&amp;x, ptr);</span>
<span class="line" id="L488">}</span>
<span class="line" id="L489"></span>
<span class="line" id="L490"><span class="tok-kw">test</span> <span class="tok-str">&quot;CAST_OR_CALL casting&quot;</span> {</span>
<span class="line" id="L491">    <span class="tok-kw">var</span> arg = <span class="tok-builtin">@as</span>(<span class="tok-type">c_int</span>, <span class="tok-number">1000</span>);</span>
<span class="line" id="L492">    <span class="tok-kw">var</span> casted = Macros.CAST_OR_CALL(<span class="tok-type">u8</span>, arg);</span>
<span class="line" id="L493">    <span class="tok-kw">try</span> testing.expectEqual(cast(<span class="tok-type">u8</span>, arg), casted);</span>
<span class="line" id="L494"></span>
<span class="line" id="L495">    <span class="tok-kw">const</span> S = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L496">        x: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L497">    };</span>
<span class="line" id="L498">    <span class="tok-kw">var</span> s = S{};</span>
<span class="line" id="L499">    <span class="tok-kw">var</span> casted_ptr = Macros.CAST_OR_CALL(*<span class="tok-type">u8</span>, &amp;s);</span>
<span class="line" id="L500">    <span class="tok-kw">try</span> testing.expectEqual(cast(*<span class="tok-type">u8</span>, &amp;s), casted_ptr);</span>
<span class="line" id="L501">}</span>
<span class="line" id="L502"></span>
<span class="line" id="L503"><span class="tok-kw">test</span> <span class="tok-str">&quot;CAST_OR_CALL calling&quot;</span> {</span>
<span class="line" id="L504">    <span class="tok-kw">const</span> Helper = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L505">        <span class="tok-kw">var</span> last_val: <span class="tok-type">bool</span> = <span class="tok-null">false</span>;</span>
<span class="line" id="L506">        <span class="tok-kw">fn</span> <span class="tok-fn">returnsVoid</span>(val: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L507">            last_val = val;</span>
<span class="line" id="L508">        }</span>
<span class="line" id="L509">        <span class="tok-kw">fn</span> <span class="tok-fn">returnsBool</span>(f: <span class="tok-type">f32</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L510">            <span class="tok-kw">return</span> f &gt; <span class="tok-number">0</span>;</span>
<span class="line" id="L511">        }</span>
<span class="line" id="L512">        <span class="tok-kw">fn</span> <span class="tok-fn">identity</span>(self: <span class="tok-type">c_uint</span>) <span class="tok-type">c_uint</span> {</span>
<span class="line" id="L513">            <span class="tok-kw">return</span> self;</span>
<span class="line" id="L514">        }</span>
<span class="line" id="L515">    };</span>
<span class="line" id="L516"></span>
<span class="line" id="L517">    Macros.CAST_OR_CALL(Helper.returnsVoid, <span class="tok-null">true</span>);</span>
<span class="line" id="L518">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">true</span>, Helper.last_val);</span>
<span class="line" id="L519">    Macros.CAST_OR_CALL(Helper.returnsVoid, <span class="tok-null">false</span>);</span>
<span class="line" id="L520">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">false</span>, Helper.last_val);</span>
<span class="line" id="L521"></span>
<span class="line" id="L522">    <span class="tok-kw">try</span> testing.expectEqual(Helper.returnsBool(<span class="tok-number">1</span>), Macros.CAST_OR_CALL(Helper.returnsBool, <span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, <span class="tok-number">1</span>)));</span>
<span class="line" id="L523">    <span class="tok-kw">try</span> testing.expectEqual(Helper.returnsBool(-<span class="tok-number">1</span>), Macros.CAST_OR_CALL(Helper.returnsBool, <span class="tok-builtin">@as</span>(<span class="tok-type">f32</span>, -<span class="tok-number">1</span>)));</span>
<span class="line" id="L524"></span>
<span class="line" id="L525">    <span class="tok-kw">try</span> testing.expectEqual(Helper.identity(<span class="tok-builtin">@as</span>(<span class="tok-type">c_uint</span>, <span class="tok-number">100</span>)), Macros.CAST_OR_CALL(Helper.identity, <span class="tok-builtin">@as</span>(<span class="tok-type">c_uint</span>, <span class="tok-number">100</span>)));</span>
<span class="line" id="L526">}</span>
<span class="line" id="L527"></span>
</code></pre></body>
</html>