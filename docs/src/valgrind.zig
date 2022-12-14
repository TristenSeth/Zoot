<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>valgrind.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std.zig&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">doClientRequest</span>(default: <span class="tok-type">usize</span>, request: <span class="tok-type">usize</span>, a1: <span class="tok-type">usize</span>, a2: <span class="tok-type">usize</span>, a3: <span class="tok-type">usize</span>, a4: <span class="tok-type">usize</span>, a5: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L6">    <span class="tok-kw">if</span> (!builtin.valgrind_support) {</span>
<span class="line" id="L7">        <span class="tok-kw">return</span> default;</span>
<span class="line" id="L8">    }</span>
<span class="line" id="L9"></span>
<span class="line" id="L10">    <span class="tok-kw">switch</span> (builtin.target.cpu.arch) {</span>
<span class="line" id="L11">        .<span class="tok-type">i386</span> =&gt; {</span>
<span class="line" id="L12">            <span class="tok-kw">return</span> <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L13">                <span class="tok-str">\\ roll $3,  %%edi ; roll $13, %%edi</span></span>

<span class="line" id="L14">                <span class="tok-str">\\ roll $29, %%edi ; roll $19, %%edi</span></span>

<span class="line" id="L15">                <span class="tok-str">\\ xchgl %%ebx,%%ebx</span></span>

<span class="line" id="L16">                : [_] <span class="tok-str">&quot;={edx}&quot;</span> (-&gt; <span class="tok-type">usize</span>),</span>
<span class="line" id="L17">                : [_] <span class="tok-str">&quot;{eax}&quot;</span> (&amp;[_]<span class="tok-type">usize</span>{ request, a1, a2, a3, a4, a5 }),</span>
<span class="line" id="L18">                  [_] <span class="tok-str">&quot;0&quot;</span> (default),</span>
<span class="line" id="L19">                : <span class="tok-str">&quot;cc&quot;</span>, <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L20">            );</span>
<span class="line" id="L21">        },</span>
<span class="line" id="L22">        .x86_64 =&gt; {</span>
<span class="line" id="L23">            <span class="tok-kw">return</span> <span class="tok-kw">asm</span> <span class="tok-kw">volatile</span> (</span>
<span class="line" id="L24">                <span class="tok-str">\\ rolq $3,  %%rdi ; rolq $13, %%rdi</span></span>

<span class="line" id="L25">                <span class="tok-str">\\ rolq $61, %%rdi ; rolq $51, %%rdi</span></span>

<span class="line" id="L26">                <span class="tok-str">\\ xchgq %%rbx,%%rbx</span></span>

<span class="line" id="L27">                : [_] <span class="tok-str">&quot;={rdx}&quot;</span> (-&gt; <span class="tok-type">usize</span>),</span>
<span class="line" id="L28">                : [_] <span class="tok-str">&quot;{rax}&quot;</span> (&amp;[_]<span class="tok-type">usize</span>{ request, a1, a2, a3, a4, a5 }),</span>
<span class="line" id="L29">                  [_] <span class="tok-str">&quot;0&quot;</span> (default),</span>
<span class="line" id="L30">                : <span class="tok-str">&quot;cc&quot;</span>, <span class="tok-str">&quot;memory&quot;</span></span>
<span class="line" id="L31">            );</span>
<span class="line" id="L32">        },</span>
<span class="line" id="L33">        <span class="tok-comment">// ppc32</span>
</span>
<span class="line" id="L34">        <span class="tok-comment">// ppc64</span>
</span>
<span class="line" id="L35">        <span class="tok-comment">// arm</span>
</span>
<span class="line" id="L36">        <span class="tok-comment">// arm64</span>
</span>
<span class="line" id="L37">        <span class="tok-comment">// s390x</span>
</span>
<span class="line" id="L38">        <span class="tok-comment">// mips32</span>
</span>
<span class="line" id="L39">        <span class="tok-comment">// mips64</span>
</span>
<span class="line" id="L40">        <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L41">            <span class="tok-kw">return</span> default;</span>
<span class="line" id="L42">        },</span>
<span class="line" id="L43">    }</span>
<span class="line" id="L44">}</span>
<span class="line" id="L45"></span>
<span class="line" id="L46"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ClientRequest = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L47">    RunningOnValgrind = <span class="tok-number">4097</span>,</span>
<span class="line" id="L48">    DiscardTranslations = <span class="tok-number">4098</span>,</span>
<span class="line" id="L49">    ClientCall0 = <span class="tok-number">4353</span>,</span>
<span class="line" id="L50">    ClientCall1 = <span class="tok-number">4354</span>,</span>
<span class="line" id="L51">    ClientCall2 = <span class="tok-number">4355</span>,</span>
<span class="line" id="L52">    ClientCall3 = <span class="tok-number">4356</span>,</span>
<span class="line" id="L53">    CountErrors = <span class="tok-number">4609</span>,</span>
<span class="line" id="L54">    GdbMonitorCommand = <span class="tok-number">4610</span>,</span>
<span class="line" id="L55">    MalloclikeBlock = <span class="tok-number">4865</span>,</span>
<span class="line" id="L56">    ResizeinplaceBlock = <span class="tok-number">4875</span>,</span>
<span class="line" id="L57">    FreelikeBlock = <span class="tok-number">4866</span>,</span>
<span class="line" id="L58">    CreateMempool = <span class="tok-number">4867</span>,</span>
<span class="line" id="L59">    DestroyMempool = <span class="tok-number">4868</span>,</span>
<span class="line" id="L60">    MempoolAlloc = <span class="tok-number">4869</span>,</span>
<span class="line" id="L61">    MempoolFree = <span class="tok-number">4870</span>,</span>
<span class="line" id="L62">    MempoolTrim = <span class="tok-number">4871</span>,</span>
<span class="line" id="L63">    MoveMempool = <span class="tok-number">4872</span>,</span>
<span class="line" id="L64">    MempoolChange = <span class="tok-number">4873</span>,</span>
<span class="line" id="L65">    MempoolExists = <span class="tok-number">4874</span>,</span>
<span class="line" id="L66">    Printf = <span class="tok-number">5121</span>,</span>
<span class="line" id="L67">    PrintfBacktrace = <span class="tok-number">5122</span>,</span>
<span class="line" id="L68">    PrintfValistByRef = <span class="tok-number">5123</span>,</span>
<span class="line" id="L69">    PrintfBacktraceValistByRef = <span class="tok-number">5124</span>,</span>
<span class="line" id="L70">    StackRegister = <span class="tok-number">5377</span>,</span>
<span class="line" id="L71">    StackDeregister = <span class="tok-number">5378</span>,</span>
<span class="line" id="L72">    StackChange = <span class="tok-number">5379</span>,</span>
<span class="line" id="L73">    LoadPdbDebuginfo = <span class="tok-number">5633</span>,</span>
<span class="line" id="L74">    MapIpToSrcloc = <span class="tok-number">5889</span>,</span>
<span class="line" id="L75">    ChangeErrDisablement = <span class="tok-number">6145</span>,</span>
<span class="line" id="L76">    VexInitForIri = <span class="tok-number">6401</span>,</span>
<span class="line" id="L77">    InnerThreads = <span class="tok-number">6402</span>,</span>
<span class="line" id="L78">};</span>
<span class="line" id="L79"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ToolBase</span>(base: [<span class="tok-number">2</span>]<span class="tok-type">u8</span>) <span class="tok-type">u32</span> {</span>
<span class="line" id="L80">    <span class="tok-kw">return</span> (<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, base[<span class="tok-number">0</span>] &amp; <span class="tok-number">0xff</span>) &lt;&lt; <span class="tok-number">24</span>) | (<span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, base[<span class="tok-number">1</span>] &amp; <span class="tok-number">0xff</span>) &lt;&lt; <span class="tok-number">16</span>);</span>
<span class="line" id="L81">}</span>
<span class="line" id="L82"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">IsTool</span>(base: [<span class="tok-number">2</span>]<span class="tok-type">u8</span>, code: <span class="tok-type">usize</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L83">    <span class="tok-kw">return</span> ToolBase(base) == (code &amp; <span class="tok-number">0xffff0000</span>);</span>
<span class="line" id="L84">}</span>
<span class="line" id="L85"></span>
<span class="line" id="L86"><span class="tok-kw">fn</span> <span class="tok-fn">doClientRequestExpr</span>(default: <span class="tok-type">usize</span>, request: ClientRequest, a1: <span class="tok-type">usize</span>, a2: <span class="tok-type">usize</span>, a3: <span class="tok-type">usize</span>, a4: <span class="tok-type">usize</span>, a5: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L87">    <span class="tok-kw">return</span> doClientRequest(default, <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@enumToInt</span>(request)), a1, a2, a3, a4, a5);</span>
<span class="line" id="L88">}</span>
<span class="line" id="L89"></span>
<span class="line" id="L90"><span class="tok-kw">fn</span> <span class="tok-fn">doClientRequestStmt</span>(request: ClientRequest, a1: <span class="tok-type">usize</span>, a2: <span class="tok-type">usize</span>, a3: <span class="tok-type">usize</span>, a4: <span class="tok-type">usize</span>, a5: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L91">    _ = doClientRequestExpr(<span class="tok-number">0</span>, request, a1, a2, a3, a4, a5);</span>
<span class="line" id="L92">}</span>
<span class="line" id="L93"></span>
<span class="line" id="L94"><span class="tok-comment">/// Returns the number of Valgrinds this code is running under.  That</span></span>
<span class="line" id="L95"><span class="tok-comment">/// is, 0 if running natively, 1 if running under Valgrind, 2 if</span></span>
<span class="line" id="L96"><span class="tok-comment">/// running under Valgrind which is running under another Valgrind,</span></span>
<span class="line" id="L97"><span class="tok-comment">/// etc.</span></span>
<span class="line" id="L98"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">runningOnValgrind</span>() <span class="tok-type">usize</span> {</span>
<span class="line" id="L99">    <span class="tok-kw">return</span> doClientRequestExpr(<span class="tok-number">0</span>, .RunningOnValgrind, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L100">}</span>
<span class="line" id="L101"></span>
<span class="line" id="L102"><span class="tok-kw">test</span> <span class="tok-str">&quot;works whether running on valgrind or not&quot;</span> {</span>
<span class="line" id="L103">    _ = runningOnValgrind();</span>
<span class="line" id="L104">}</span>
<span class="line" id="L105"></span>
<span class="line" id="L106"><span class="tok-comment">/// Discard translation of code in the slice qzz.  Useful if you are debugging</span></span>
<span class="line" id="L107"><span class="tok-comment">/// a JITter or some such, since it provides a way to make sure valgrind will</span></span>
<span class="line" id="L108"><span class="tok-comment">/// retranslate the invalidated area.  Returns no value.</span></span>
<span class="line" id="L109"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">discardTranslations</span>(qzz: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L110">    doClientRequestStmt(.DiscardTranslations, <span class="tok-builtin">@ptrToInt</span>(qzz.ptr), qzz.len, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L111">}</span>
<span class="line" id="L112"></span>
<span class="line" id="L113"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">innerThreads</span>(qzz: [*]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L114">    doClientRequestStmt(.InnerThreads, qzz, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L115">}</span>
<span class="line" id="L116"></span>
<span class="line" id="L117"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">nonSIMDCall0</span>(func: <span class="tok-kw">fn</span> (<span class="tok-type">usize</span>) <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L118">    <span class="tok-kw">return</span> doClientRequestExpr(<span class="tok-number">0</span>, .ClientCall0, <span class="tok-builtin">@ptrToInt</span>(func), <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L119">}</span>
<span class="line" id="L120"></span>
<span class="line" id="L121"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">nonSIMDCall1</span>(func: <span class="tok-kw">fn</span> (<span class="tok-type">usize</span>, <span class="tok-type">usize</span>) <span class="tok-type">usize</span>, a1: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L122">    <span class="tok-kw">return</span> doClientRequestExpr(<span class="tok-number">0</span>, .ClientCall1, <span class="tok-builtin">@ptrToInt</span>(func), a1, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L123">}</span>
<span class="line" id="L124"></span>
<span class="line" id="L125"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">nonSIMDCall2</span>(func: <span class="tok-kw">fn</span> (<span class="tok-type">usize</span>, <span class="tok-type">usize</span>, <span class="tok-type">usize</span>) <span class="tok-type">usize</span>, a1: <span class="tok-type">usize</span>, a2: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L126">    <span class="tok-kw">return</span> doClientRequestExpr(<span class="tok-number">0</span>, .ClientCall2, <span class="tok-builtin">@ptrToInt</span>(func), a1, a2, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L127">}</span>
<span class="line" id="L128"></span>
<span class="line" id="L129"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">nonSIMDCall3</span>(func: <span class="tok-kw">fn</span> (<span class="tok-type">usize</span>, <span class="tok-type">usize</span>, <span class="tok-type">usize</span>, <span class="tok-type">usize</span>) <span class="tok-type">usize</span>, a1: <span class="tok-type">usize</span>, a2: <span class="tok-type">usize</span>, a3: <span class="tok-type">usize</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L130">    <span class="tok-kw">return</span> doClientRequestExpr(<span class="tok-number">0</span>, .ClientCall3, <span class="tok-builtin">@ptrToInt</span>(func), a1, a2, a3, <span class="tok-number">0</span>);</span>
<span class="line" id="L131">}</span>
<span class="line" id="L132"></span>
<span class="line" id="L133"><span class="tok-comment">/// Counts the number of errors that have been recorded by a tool.  Nb:</span></span>
<span class="line" id="L134"><span class="tok-comment">/// the tool must record the errors with VG_(maybe_record_error)() or</span></span>
<span class="line" id="L135"><span class="tok-comment">/// VG_(unique_error)() for them to be counted.</span></span>
<span class="line" id="L136"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">countErrors</span>() <span class="tok-type">usize</span> {</span>
<span class="line" id="L137">    <span class="tok-kw">return</span> doClientRequestExpr(<span class="tok-number">0</span>, <span class="tok-comment">// default return</span>
</span>
<span class="line" id="L138">        .CountErrors, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L139">}</span>
<span class="line" id="L140"></span>
<span class="line" id="L141"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mallocLikeBlock</span>(mem: []<span class="tok-type">u8</span>, rzB: <span class="tok-type">usize</span>, is_zeroed: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L142">    doClientRequestStmt(.MalloclikeBlock, <span class="tok-builtin">@ptrToInt</span>(mem.ptr), mem.len, rzB, <span class="tok-builtin">@boolToInt</span>(is_zeroed), <span class="tok-number">0</span>);</span>
<span class="line" id="L143">}</span>
<span class="line" id="L144"></span>
<span class="line" id="L145"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">resizeInPlaceBlock</span>(oldmem: []<span class="tok-type">u8</span>, newsize: <span class="tok-type">usize</span>, rzB: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L146">    doClientRequestStmt(.ResizeinplaceBlock, <span class="tok-builtin">@ptrToInt</span>(oldmem.ptr), oldmem.len, newsize, rzB, <span class="tok-number">0</span>);</span>
<span class="line" id="L147">}</span>
<span class="line" id="L148"></span>
<span class="line" id="L149"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">freeLikeBlock</span>(addr: [*]<span class="tok-type">u8</span>, rzB: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L150">    doClientRequestStmt(.FreelikeBlock, <span class="tok-builtin">@ptrToInt</span>(addr), rzB, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L151">}</span>
<span class="line" id="L152"></span>
<span class="line" id="L153"><span class="tok-comment">/// Create a memory pool.</span></span>
<span class="line" id="L154"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MempoolFlags = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L155">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> AutoFree = <span class="tok-number">1</span>;</span>
<span class="line" id="L156">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MetaPool = <span class="tok-number">2</span>;</span>
<span class="line" id="L157">};</span>
<span class="line" id="L158"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createMempool</span>(pool: [*]<span class="tok-type">u8</span>, rzB: <span class="tok-type">usize</span>, is_zeroed: <span class="tok-type">bool</span>, flags: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L159">    doClientRequestStmt(.CreateMempool, <span class="tok-builtin">@ptrToInt</span>(pool), rzB, <span class="tok-builtin">@boolToInt</span>(is_zeroed), flags, <span class="tok-number">0</span>);</span>
<span class="line" id="L160">}</span>
<span class="line" id="L161"></span>
<span class="line" id="L162"><span class="tok-comment">/// Destroy a memory pool.</span></span>
<span class="line" id="L163"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">destroyMempool</span>(pool: [*]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L164">    doClientRequestStmt(.DestroyMempool, pool, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L165">}</span>
<span class="line" id="L166"></span>
<span class="line" id="L167"><span class="tok-comment">/// Associate a piece of memory with a memory pool.</span></span>
<span class="line" id="L168"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mempoolAlloc</span>(pool: [*]<span class="tok-type">u8</span>, mem: []<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L169">    doClientRequestStmt(.MempoolAlloc, <span class="tok-builtin">@ptrToInt</span>(pool), <span class="tok-builtin">@ptrToInt</span>(mem.ptr), mem.len, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L170">}</span>
<span class="line" id="L171"></span>
<span class="line" id="L172"><span class="tok-comment">/// Disassociate a piece of memory from a memory pool.</span></span>
<span class="line" id="L173"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mempoolFree</span>(pool: [*]<span class="tok-type">u8</span>, addr: [*]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L174">    doClientRequestStmt(.MempoolFree, <span class="tok-builtin">@ptrToInt</span>(pool), <span class="tok-builtin">@ptrToInt</span>(addr), <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L175">}</span>
<span class="line" id="L176"></span>
<span class="line" id="L177"><span class="tok-comment">/// Disassociate any pieces outside a particular range.</span></span>
<span class="line" id="L178"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mempoolTrim</span>(pool: [*]<span class="tok-type">u8</span>, mem: []<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L179">    doClientRequestStmt(.MempoolTrim, <span class="tok-builtin">@ptrToInt</span>(pool), <span class="tok-builtin">@ptrToInt</span>(mem.ptr), mem.len, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L180">}</span>
<span class="line" id="L181"></span>
<span class="line" id="L182"><span class="tok-comment">/// Resize and/or move a piece associated with a memory pool.</span></span>
<span class="line" id="L183"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">moveMempool</span>(poolA: [*]<span class="tok-type">u8</span>, poolB: [*]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L184">    doClientRequestStmt(.MoveMempool, <span class="tok-builtin">@ptrToInt</span>(poolA), <span class="tok-builtin">@ptrToInt</span>(poolB), <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L185">}</span>
<span class="line" id="L186"></span>
<span class="line" id="L187"><span class="tok-comment">/// Resize and/or move a piece associated with a memory pool.</span></span>
<span class="line" id="L188"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mempoolChange</span>(pool: [*]<span class="tok-type">u8</span>, addrA: [*]<span class="tok-type">u8</span>, mem: []<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L189">    doClientRequestStmt(.MempoolChange, <span class="tok-builtin">@ptrToInt</span>(pool), <span class="tok-builtin">@ptrToInt</span>(addrA), <span class="tok-builtin">@ptrToInt</span>(mem.ptr), mem.len, <span class="tok-number">0</span>);</span>
<span class="line" id="L190">}</span>
<span class="line" id="L191"></span>
<span class="line" id="L192"><span class="tok-comment">/// Return if a mempool exists.</span></span>
<span class="line" id="L193"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mempoolExists</span>(pool: [*]<span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L194">    <span class="tok-kw">return</span> doClientRequestExpr(<span class="tok-number">0</span>, .MempoolExists, <span class="tok-builtin">@ptrToInt</span>(pool), <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>) != <span class="tok-number">0</span>;</span>
<span class="line" id="L195">}</span>
<span class="line" id="L196"></span>
<span class="line" id="L197"><span class="tok-comment">/// Mark a piece of memory as being a stack. Returns a stack id.</span></span>
<span class="line" id="L198"><span class="tok-comment">/// start is the lowest addressable stack byte, end is the highest</span></span>
<span class="line" id="L199"><span class="tok-comment">/// addressable stack byte.</span></span>
<span class="line" id="L200"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">stackRegister</span>(stack: []<span class="tok-type">u8</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L201">    <span class="tok-kw">return</span> doClientRequestExpr(<span class="tok-number">0</span>, .StackRegister, <span class="tok-builtin">@ptrToInt</span>(stack.ptr), <span class="tok-builtin">@ptrToInt</span>(stack.ptr) + stack.len, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L202">}</span>
<span class="line" id="L203"></span>
<span class="line" id="L204"><span class="tok-comment">/// Unmark the piece of memory associated with a stack id as being a stack.</span></span>
<span class="line" id="L205"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">stackDeregister</span>(id: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L206">    doClientRequestStmt(.StackDeregister, id, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L207">}</span>
<span class="line" id="L208"></span>
<span class="line" id="L209"><span class="tok-comment">/// Change the start and end address of the stack id.</span></span>
<span class="line" id="L210"><span class="tok-comment">/// start is the new lowest addressable stack byte, end is the new highest</span></span>
<span class="line" id="L211"><span class="tok-comment">/// addressable stack byte.</span></span>
<span class="line" id="L212"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">stackChange</span>(id: <span class="tok-type">usize</span>, newstack: []<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L213">    doClientRequestStmt(.StackChange, id, <span class="tok-builtin">@ptrToInt</span>(newstack.ptr), <span class="tok-builtin">@ptrToInt</span>(newstack.ptr) + newstack.len, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L214">}</span>
<span class="line" id="L215"></span>
<span class="line" id="L216"><span class="tok-comment">// Load PDB debug info for Wine PE image_map.</span>
</span>
<span class="line" id="L217"><span class="tok-comment">// pub fn loadPdbDebuginfo(fd, ptr, total_size, delta) void {</span>
</span>
<span class="line" id="L218"><span class="tok-comment">//     doClientRequestStmt(.LoadPdbDebuginfo,</span>
</span>
<span class="line" id="L219"><span class="tok-comment">//         fd, ptr, total_size, delta,</span>
</span>
<span class="line" id="L220"><span class="tok-comment">//         0);</span>
</span>
<span class="line" id="L221"><span class="tok-comment">// }</span>
</span>
<span class="line" id="L222"></span>
<span class="line" id="L223"><span class="tok-comment">/// Map a code address to a source file name and line number.  buf64</span></span>
<span class="line" id="L224"><span class="tok-comment">/// must point to a 64-byte buffer in the caller's address space. The</span></span>
<span class="line" id="L225"><span class="tok-comment">/// result will be dumped in there and is guaranteed to be zero</span></span>
<span class="line" id="L226"><span class="tok-comment">/// terminated.  If no info is found, the first byte is set to zero.</span></span>
<span class="line" id="L227"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mapIpToSrcloc</span>(addr: *<span class="tok-kw">const</span> <span class="tok-type">u8</span>, buf64: [<span class="tok-number">64</span>]<span class="tok-type">u8</span>) <span class="tok-type">usize</span> {</span>
<span class="line" id="L228">    <span class="tok-kw">return</span> doClientRequestExpr(<span class="tok-number">0</span>, .MapIpToSrcloc, <span class="tok-builtin">@ptrToInt</span>(addr), <span class="tok-builtin">@ptrToInt</span>(&amp;buf64[<span class="tok-number">0</span>]), <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L229">}</span>
<span class="line" id="L230"></span>
<span class="line" id="L231"><span class="tok-comment">/// Disable error reporting for this thread.  Behaves in a stack like</span></span>
<span class="line" id="L232"><span class="tok-comment">/// way, so you can safely call this multiple times provided that</span></span>
<span class="line" id="L233"><span class="tok-comment">/// enableErrorReporting() is called the same number of times</span></span>
<span class="line" id="L234"><span class="tok-comment">/// to re-enable reporting.  The first call of this macro disables</span></span>
<span class="line" id="L235"><span class="tok-comment">/// reporting.  Subsequent calls have no effect except to increase the</span></span>
<span class="line" id="L236"><span class="tok-comment">/// number of enableErrorReporting() calls needed to re-enable</span></span>
<span class="line" id="L237"><span class="tok-comment">/// reporting.  Child threads do not inherit this setting from their</span></span>
<span class="line" id="L238"><span class="tok-comment">/// parents -- they are always created with reporting enabled.</span></span>
<span class="line" id="L239"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">disableErrorReporting</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L240">    doClientRequestStmt(.ChangeErrDisablement, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L241">}</span>
<span class="line" id="L242"></span>
<span class="line" id="L243"><span class="tok-comment">/// Re-enable error reporting, (see disableErrorReporting())</span></span>
<span class="line" id="L244"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">enableErrorReporting</span>() <span class="tok-type">void</span> {</span>
<span class="line" id="L245">    doClientRequestStmt(.ChangeErrDisablement, math.maxInt(<span class="tok-type">usize</span>), <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L246">}</span>
<span class="line" id="L247"></span>
<span class="line" id="L248"><span class="tok-comment">/// Execute a monitor command from the client program.</span></span>
<span class="line" id="L249"><span class="tok-comment">/// If a connection is opened with GDB, the output will be sent</span></span>
<span class="line" id="L250"><span class="tok-comment">/// according to the output mode set for vgdb.</span></span>
<span class="line" id="L251"><span class="tok-comment">/// If no connection is opened, output will go to the log output.</span></span>
<span class="line" id="L252"><span class="tok-comment">/// Returns 1 if command not recognised, 0 otherwise.</span></span>
<span class="line" id="L253"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">monitorCommand</span>(command: [*]<span class="tok-type">u8</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L254">    <span class="tok-kw">return</span> doClientRequestExpr(<span class="tok-number">0</span>, .GdbMonitorCommand, <span class="tok-builtin">@ptrToInt</span>(command.ptr), <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>) != <span class="tok-number">0</span>;</span>
<span class="line" id="L255">}</span>
<span class="line" id="L256"></span>
<span class="line" id="L257"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> memcheck = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;valgrind/memcheck.zig&quot;</span>);</span>
<span class="line" id="L258"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> callgrind = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;valgrind/callgrind.zig&quot;</span>);</span>
<span class="line" id="L259"></span>
<span class="line" id="L260"><span class="tok-kw">test</span> {</span>
<span class="line" id="L261">    _ = memcheck;</span>
<span class="line" id="L262">    _ = callgrind;</span>
<span class="line" id="L263">}</span>
<span class="line" id="L264"></span>
</code></pre></body>
</html>