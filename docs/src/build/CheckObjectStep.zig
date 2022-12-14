<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>build/CheckObjectStep.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> build = std.build;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> fs = std.fs;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> macho = std.macho;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-kw">const</span> CheckObjectStep = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-kw">const</span> Allocator = mem.Allocator;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> Builder = build.Builder;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> Step = build.Step;</span>
<span class="line" id="L15"><span class="tok-kw">const</span> EmulatableRunStep = build.EmulatableRunStep;</span>
<span class="line" id="L16"></span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> base_id = .check_obj;</span>
<span class="line" id="L18"></span>
<span class="line" id="L19">step: Step,</span>
<span class="line" id="L20">builder: *Builder,</span>
<span class="line" id="L21">source: build.FileSource,</span>
<span class="line" id="L22">max_bytes: <span class="tok-type">usize</span> = <span class="tok-number">20</span> * <span class="tok-number">1024</span> * <span class="tok-number">1024</span>,</span>
<span class="line" id="L23">checks: std.ArrayList(Check),</span>
<span class="line" id="L24">dump_symtab: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L25">obj_format: std.Target.ObjectFormat,</span>
<span class="line" id="L26"></span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(builder: *Builder, source: build.FileSource, obj_format: std.Target.ObjectFormat) *CheckObjectStep {</span>
<span class="line" id="L28">    <span class="tok-kw">const</span> gpa = builder.allocator;</span>
<span class="line" id="L29">    <span class="tok-kw">const</span> self = gpa.create(CheckObjectStep) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L30">    self.* = .{</span>
<span class="line" id="L31">        .builder = builder,</span>
<span class="line" id="L32">        .step = Step.init(.check_file, <span class="tok-str">&quot;CheckObject&quot;</span>, gpa, make),</span>
<span class="line" id="L33">        .source = source.dupe(builder),</span>
<span class="line" id="L34">        .checks = std.ArrayList(Check).init(gpa),</span>
<span class="line" id="L35">        .obj_format = obj_format,</span>
<span class="line" id="L36">    };</span>
<span class="line" id="L37">    self.source.addStepDependencies(&amp;self.step);</span>
<span class="line" id="L38">    <span class="tok-kw">return</span> self;</span>
<span class="line" id="L39">}</span>
<span class="line" id="L40"></span>
<span class="line" id="L41"><span class="tok-comment">/// Runs and (optionally) compares the output of a binary.</span></span>
<span class="line" id="L42"><span class="tok-comment">/// Asserts `self` was generated from an executable step.</span></span>
<span class="line" id="L43"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">runAndCompare</span>(self: *CheckObjectStep) *EmulatableRunStep {</span>
<span class="line" id="L44">    <span class="tok-kw">const</span> dependencies_len = self.step.dependencies.items.len;</span>
<span class="line" id="L45">    assert(dependencies_len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L46">    <span class="tok-kw">const</span> exe_step = self.step.dependencies.items[dependencies_len - <span class="tok-number">1</span>];</span>
<span class="line" id="L47">    <span class="tok-kw">const</span> exe = exe_step.cast(std.build.LibExeObjStep).?;</span>
<span class="line" id="L48">    <span class="tok-kw">return</span> EmulatableRunStep.create(self.builder, <span class="tok-str">&quot;EmulatableRun&quot;</span>, exe);</span>
<span class="line" id="L49">}</span>
<span class="line" id="L50"></span>
<span class="line" id="L51"><span class="tok-comment">/// There two types of actions currently suported:</span></span>
<span class="line" id="L52"><span class="tok-comment">/// * `.match` - is the main building block of standard matchers with optional eat-all token `{*}`</span></span>
<span class="line" id="L53"><span class="tok-comment">/// and extractors by name such as `{n_value}`. Please note this action is very simplistic in nature</span></span>
<span class="line" id="L54"><span class="tok-comment">/// i.e., it won't really handle edge cases/nontrivial examples. But given that we do want to use</span></span>
<span class="line" id="L55"><span class="tok-comment">/// it mainly to test the output of our object format parser-dumpers when testing the linkers, etc.</span></span>
<span class="line" id="L56"><span class="tok-comment">/// it should be plenty useful in its current form.</span></span>
<span class="line" id="L57"><span class="tok-comment">/// * `.compute_cmp` - can be used to perform an operation on the extracted global variables</span></span>
<span class="line" id="L58"><span class="tok-comment">/// using the MatchAction. It currently only supports an addition. The operation is required</span></span>
<span class="line" id="L59"><span class="tok-comment">/// to be specified in Reverse Polish Notation to ease in operator-precedence parsing (well,</span></span>
<span class="line" id="L60"><span class="tok-comment">/// to avoid any parsing really).</span></span>
<span class="line" id="L61"><span class="tok-comment">/// For example, if the two extracted values were saved as `vmaddr` and `entryoff` respectively</span></span>
<span class="line" id="L62"><span class="tok-comment">/// they could then be added with this simple program `vmaddr entryoff +`.</span></span>
<span class="line" id="L63"><span class="tok-kw">const</span> Action = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L64">    tag: <span class="tok-kw">enum</span> { match, not_present, compute_cmp },</span>
<span class="line" id="L65">    phrase: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L66">    expected: ?ComputeCompareExpected = <span class="tok-null">null</span>,</span>
<span class="line" id="L67"></span>
<span class="line" id="L68">    <span class="tok-comment">/// Will return true if the `phrase` was found in the `haystack`.</span></span>
<span class="line" id="L69">    <span class="tok-comment">/// Some examples include:</span></span>
<span class="line" id="L70">    <span class="tok-comment">///</span></span>
<span class="line" id="L71">    <span class="tok-comment">/// LC 0                     =&gt; will match in its entirety</span></span>
<span class="line" id="L72">    <span class="tok-comment">/// vmaddr {vmaddr}          =&gt; will match `vmaddr` and then extract the following value as u64</span></span>
<span class="line" id="L73">    <span class="tok-comment">///                             and save under `vmaddr` global name (see `global_vars` param)</span></span>
<span class="line" id="L74">    <span class="tok-comment">/// name {*}libobjc{*}.dylib =&gt; will match `name` followed by a token which contains `libobjc` and `.dylib`</span></span>
<span class="line" id="L75">    <span class="tok-comment">///                             in that order with other letters in between</span></span>
<span class="line" id="L76">    <span class="tok-kw">fn</span> <span class="tok-fn">match</span>(act: Action, haystack: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, global_vars: <span class="tok-kw">anytype</span>) !<span class="tok-type">bool</span> {</span>
<span class="line" id="L77">        assert(act.tag == .match <span class="tok-kw">or</span> act.tag == .not_present);</span>
<span class="line" id="L78"></span>
<span class="line" id="L79">        <span class="tok-kw">var</span> candidate_var: ?<span class="tok-kw">struct</span> { name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: <span class="tok-type">u64</span> } = <span class="tok-null">null</span>;</span>
<span class="line" id="L80">        <span class="tok-kw">var</span> hay_it = mem.tokenize(<span class="tok-type">u8</span>, mem.trim(<span class="tok-type">u8</span>, haystack, <span class="tok-str">&quot; &quot;</span>), <span class="tok-str">&quot; &quot;</span>);</span>
<span class="line" id="L81">        <span class="tok-kw">var</span> needle_it = mem.tokenize(<span class="tok-type">u8</span>, mem.trim(<span class="tok-type">u8</span>, act.phrase, <span class="tok-str">&quot; &quot;</span>), <span class="tok-str">&quot; &quot;</span>);</span>
<span class="line" id="L82"></span>
<span class="line" id="L83">        <span class="tok-kw">while</span> (needle_it.next()) |needle_tok| {</span>
<span class="line" id="L84">            <span class="tok-kw">const</span> hay_tok = hay_it.next() <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L85"></span>
<span class="line" id="L86">            <span class="tok-kw">if</span> (mem.indexOf(<span class="tok-type">u8</span>, needle_tok, <span class="tok-str">&quot;{*}&quot;</span>)) |index| {</span>
<span class="line" id="L87">                <span class="tok-comment">// We have fuzzy matchers within the search pattern, so we match substrings.</span>
</span>
<span class="line" id="L88">                <span class="tok-kw">var</span> start = index;</span>
<span class="line" id="L89">                <span class="tok-kw">var</span> n_tok = needle_tok;</span>
<span class="line" id="L90">                <span class="tok-kw">var</span> h_tok = hay_tok;</span>
<span class="line" id="L91">                <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L92">                    n_tok = n_tok[start + <span class="tok-number">3</span> ..];</span>
<span class="line" id="L93">                    <span class="tok-kw">const</span> inner = <span class="tok-kw">if</span> (mem.indexOf(<span class="tok-type">u8</span>, n_tok, <span class="tok-str">&quot;{*}&quot;</span>)) |sub_end|</span>
<span class="line" id="L94">                        n_tok[<span class="tok-number">0</span>..sub_end]</span>
<span class="line" id="L95">                    <span class="tok-kw">else</span></span>
<span class="line" id="L96">                        n_tok;</span>
<span class="line" id="L97">                    <span class="tok-kw">if</span> (mem.indexOf(<span class="tok-type">u8</span>, h_tok, inner) == <span class="tok-null">null</span>) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L98">                    start = mem.indexOf(<span class="tok-type">u8</span>, n_tok, <span class="tok-str">&quot;{*}&quot;</span>) <span class="tok-kw">orelse</span> <span class="tok-kw">break</span>;</span>
<span class="line" id="L99">                }</span>
<span class="line" id="L100">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.startsWith(<span class="tok-type">u8</span>, needle_tok, <span class="tok-str">&quot;{&quot;</span>)) {</span>
<span class="line" id="L101">                <span class="tok-kw">const</span> closing_brace = mem.indexOf(<span class="tok-type">u8</span>, needle_tok, <span class="tok-str">&quot;}&quot;</span>) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingClosingBrace;</span>
<span class="line" id="L102">                <span class="tok-kw">if</span> (closing_brace != needle_tok.len - <span class="tok-number">1</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ClosingBraceNotLast;</span>
<span class="line" id="L103"></span>
<span class="line" id="L104">                <span class="tok-kw">const</span> name = needle_tok[<span class="tok-number">1</span>..closing_brace];</span>
<span class="line" id="L105">                <span class="tok-kw">if</span> (name.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingBraceValue;</span>
<span class="line" id="L106">                <span class="tok-kw">const</span> value = <span class="tok-kw">try</span> std.fmt.parseInt(<span class="tok-type">u64</span>, hay_tok, <span class="tok-number">16</span>);</span>
<span class="line" id="L107">                candidate_var = .{</span>
<span class="line" id="L108">                    .name = name,</span>
<span class="line" id="L109">                    .value = value,</span>
<span class="line" id="L110">                };</span>
<span class="line" id="L111">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L112">                <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, hay_tok, needle_tok)) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L113">            }</span>
<span class="line" id="L114">        }</span>
<span class="line" id="L115"></span>
<span class="line" id="L116">        <span class="tok-kw">if</span> (candidate_var) |v| {</span>
<span class="line" id="L117">            <span class="tok-kw">try</span> global_vars.putNoClobber(v.name, v.value);</span>
<span class="line" id="L118">        }</span>
<span class="line" id="L119"></span>
<span class="line" id="L120">        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L121">    }</span>
<span class="line" id="L122"></span>
<span class="line" id="L123">    <span class="tok-comment">/// Will return true if the `phrase` is correctly parsed into an RPN program and</span></span>
<span class="line" id="L124">    <span class="tok-comment">/// its reduced, computed value compares using `op` with the expected value, either</span></span>
<span class="line" id="L125">    <span class="tok-comment">/// a literal or another extracted variable.</span></span>
<span class="line" id="L126">    <span class="tok-kw">fn</span> <span class="tok-fn">computeCmp</span>(act: Action, gpa: Allocator, global_vars: <span class="tok-kw">anytype</span>) !<span class="tok-type">bool</span> {</span>
<span class="line" id="L127">        <span class="tok-kw">var</span> op_stack = std.ArrayList(<span class="tok-kw">enum</span> { add }).init(gpa);</span>
<span class="line" id="L128">        <span class="tok-kw">var</span> values = std.ArrayList(<span class="tok-type">u64</span>).init(gpa);</span>
<span class="line" id="L129"></span>
<span class="line" id="L130">        <span class="tok-kw">var</span> it = mem.tokenize(<span class="tok-type">u8</span>, act.phrase, <span class="tok-str">&quot; &quot;</span>);</span>
<span class="line" id="L131">        <span class="tok-kw">while</span> (it.next()) |next| {</span>
<span class="line" id="L132">            <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, next, <span class="tok-str">&quot;+&quot;</span>)) {</span>
<span class="line" id="L133">                <span class="tok-kw">try</span> op_stack.append(.add);</span>
<span class="line" id="L134">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L135">                <span class="tok-kw">const</span> val = global_vars.get(next) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L136">                    std.debug.print(</span>
<span class="line" id="L137">                        <span class="tok-str">\\</span></span>

<span class="line" id="L138">                        <span class="tok-str">\\========= Variable was not extracted: ===========</span></span>

<span class="line" id="L139">                        <span class="tok-str">\\{s}</span></span>

<span class="line" id="L140">                        <span class="tok-str">\\</span></span>

<span class="line" id="L141">                    , .{next});</span>
<span class="line" id="L142">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownVariable;</span>
<span class="line" id="L143">                };</span>
<span class="line" id="L144">                <span class="tok-kw">try</span> values.append(val);</span>
<span class="line" id="L145">            }</span>
<span class="line" id="L146">        }</span>
<span class="line" id="L147"></span>
<span class="line" id="L148">        <span class="tok-kw">var</span> op_i: <span class="tok-type">usize</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L149">        <span class="tok-kw">var</span> reduced: <span class="tok-type">u64</span> = values.items[<span class="tok-number">0</span>];</span>
<span class="line" id="L150">        <span class="tok-kw">for</span> (op_stack.items) |op| {</span>
<span class="line" id="L151">            <span class="tok-kw">const</span> other = values.items[op_i];</span>
<span class="line" id="L152">            <span class="tok-kw">switch</span> (op) {</span>
<span class="line" id="L153">                .add =&gt; {</span>
<span class="line" id="L154">                    reduced += other;</span>
<span class="line" id="L155">                },</span>
<span class="line" id="L156">            }</span>
<span class="line" id="L157">        }</span>
<span class="line" id="L158"></span>
<span class="line" id="L159">        <span class="tok-kw">const</span> exp_value = <span class="tok-kw">switch</span> (act.expected.?.value) {</span>
<span class="line" id="L160">            .variable =&gt; |name| global_vars.get(name) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L161">                std.debug.print(</span>
<span class="line" id="L162">                    <span class="tok-str">\\</span></span>

<span class="line" id="L163">                    <span class="tok-str">\\========= Variable was not extracted: ===========</span></span>

<span class="line" id="L164">                    <span class="tok-str">\\{s}</span></span>

<span class="line" id="L165">                    <span class="tok-str">\\</span></span>

<span class="line" id="L166">                , .{name});</span>
<span class="line" id="L167">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnknownVariable;</span>
<span class="line" id="L168">            },</span>
<span class="line" id="L169">            .literal =&gt; |x| x,</span>
<span class="line" id="L170">        };</span>
<span class="line" id="L171">        <span class="tok-kw">return</span> math.compare(reduced, act.expected.?.op, exp_value);</span>
<span class="line" id="L172">    }</span>
<span class="line" id="L173">};</span>
<span class="line" id="L174"></span>
<span class="line" id="L175"><span class="tok-kw">const</span> ComputeCompareExpected = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L176">    op: math.CompareOperator,</span>
<span class="line" id="L177">    value: <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L178">        variable: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L179">        literal: <span class="tok-type">u64</span>,</span>
<span class="line" id="L180">    },</span>
<span class="line" id="L181"></span>
<span class="line" id="L182">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">format</span>(</span>
<span class="line" id="L183">        value: <span class="tok-builtin">@This</span>(),</span>
<span class="line" id="L184">        <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L185">        options: std.fmt.FormatOptions,</span>
<span class="line" id="L186">        writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L187">    ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L188">        _ = fmt;</span>
<span class="line" id="L189">        _ = options;</span>
<span class="line" id="L190">        <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;{s} &quot;</span>, .{<span class="tok-builtin">@tagName</span>(value.op)});</span>
<span class="line" id="L191">        <span class="tok-kw">switch</span> (value.value) {</span>
<span class="line" id="L192">            .variable =&gt; |name| <span class="tok-kw">try</span> writer.writeAll(name),</span>
<span class="line" id="L193">            .literal =&gt; |x| <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;{x}&quot;</span>, .{x}),</span>
<span class="line" id="L194">        }</span>
<span class="line" id="L195">    }</span>
<span class="line" id="L196">};</span>
<span class="line" id="L197"></span>
<span class="line" id="L198"><span class="tok-kw">const</span> Check = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L199">    builder: *Builder,</span>
<span class="line" id="L200">    actions: std.ArrayList(Action),</span>
<span class="line" id="L201"></span>
<span class="line" id="L202">    <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(b: *Builder) Check {</span>
<span class="line" id="L203">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L204">            .builder = b,</span>
<span class="line" id="L205">            .actions = std.ArrayList(Action).init(b.allocator),</span>
<span class="line" id="L206">        };</span>
<span class="line" id="L207">    }</span>
<span class="line" id="L208"></span>
<span class="line" id="L209">    <span class="tok-kw">fn</span> <span class="tok-fn">match</span>(self: *Check, phrase: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L210">        self.actions.append(.{</span>
<span class="line" id="L211">            .tag = .match,</span>
<span class="line" id="L212">            .phrase = self.builder.dupe(phrase),</span>
<span class="line" id="L213">        }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L214">    }</span>
<span class="line" id="L215"></span>
<span class="line" id="L216">    <span class="tok-kw">fn</span> <span class="tok-fn">notPresent</span>(self: *Check, phrase: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L217">        self.actions.append(.{</span>
<span class="line" id="L218">            .tag = .not_present,</span>
<span class="line" id="L219">            .phrase = self.builder.dupe(phrase),</span>
<span class="line" id="L220">        }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L221">    }</span>
<span class="line" id="L222"></span>
<span class="line" id="L223">    <span class="tok-kw">fn</span> <span class="tok-fn">computeCmp</span>(self: *Check, phrase: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected: ComputeCompareExpected) <span class="tok-type">void</span> {</span>
<span class="line" id="L224">        self.actions.append(.{</span>
<span class="line" id="L225">            .tag = .compute_cmp,</span>
<span class="line" id="L226">            .phrase = self.builder.dupe(phrase),</span>
<span class="line" id="L227">            .expected = expected,</span>
<span class="line" id="L228">        }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L229">    }</span>
<span class="line" id="L230">};</span>
<span class="line" id="L231"></span>
<span class="line" id="L232"><span class="tok-comment">/// Creates a new sequence of actions with `phrase` as the first anchor searched phrase.</span></span>
<span class="line" id="L233"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">checkStart</span>(self: *CheckObjectStep, phrase: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L234">    <span class="tok-kw">var</span> new_check = Check.create(self.builder);</span>
<span class="line" id="L235">    new_check.match(phrase);</span>
<span class="line" id="L236">    self.checks.append(new_check) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L237">}</span>
<span class="line" id="L238"></span>
<span class="line" id="L239"><span class="tok-comment">/// Adds another searched phrase to the latest created Check with `CheckObjectStep.checkStart(...)`.</span></span>
<span class="line" id="L240"><span class="tok-comment">/// Asserts at least one check already exists.</span></span>
<span class="line" id="L241"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">checkNext</span>(self: *CheckObjectStep, phrase: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L242">    assert(self.checks.items.len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L243">    <span class="tok-kw">const</span> last = &amp;self.checks.items[self.checks.items.len - <span class="tok-number">1</span>];</span>
<span class="line" id="L244">    last.match(phrase);</span>
<span class="line" id="L245">}</span>
<span class="line" id="L246"></span>
<span class="line" id="L247"><span class="tok-comment">/// Adds another searched phrase to the latest created Check with `CheckObjectStep.checkStart(...)`</span></span>
<span class="line" id="L248"><span class="tok-comment">/// however ensures there is no matching phrase in the output.</span></span>
<span class="line" id="L249"><span class="tok-comment">/// Asserts at least one check already exists.</span></span>
<span class="line" id="L250"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">checkNotPresent</span>(self: *CheckObjectStep, phrase: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L251">    assert(self.checks.items.len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L252">    <span class="tok-kw">const</span> last = &amp;self.checks.items[self.checks.items.len - <span class="tok-number">1</span>];</span>
<span class="line" id="L253">    last.notPresent(phrase);</span>
<span class="line" id="L254">}</span>
<span class="line" id="L255"></span>
<span class="line" id="L256"><span class="tok-comment">/// Creates a new check checking specifically symbol table parsed and dumped from the object</span></span>
<span class="line" id="L257"><span class="tok-comment">/// file.</span></span>
<span class="line" id="L258"><span class="tok-comment">/// Issuing this check will force parsing and dumping of the symbol table.</span></span>
<span class="line" id="L259"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">checkInSymtab</span>(self: *CheckObjectStep) <span class="tok-type">void</span> {</span>
<span class="line" id="L260">    self.dump_symtab = <span class="tok-null">true</span>;</span>
<span class="line" id="L261">    <span class="tok-kw">const</span> symtab_label = <span class="tok-kw">switch</span> (self.obj_format) {</span>
<span class="line" id="L262">        .macho =&gt; MachODumper.symtab_label,</span>
<span class="line" id="L263">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;TODO other parsers&quot;</span>),</span>
<span class="line" id="L264">    };</span>
<span class="line" id="L265">    self.checkStart(symtab_label);</span>
<span class="line" id="L266">}</span>
<span class="line" id="L267"></span>
<span class="line" id="L268"><span class="tok-comment">/// Creates a new standalone, singular check which allows running simple binary operations</span></span>
<span class="line" id="L269"><span class="tok-comment">/// on the extracted variables. It will then compare the reduced program with the value of</span></span>
<span class="line" id="L270"><span class="tok-comment">/// the expected variable.</span></span>
<span class="line" id="L271"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">checkComputeCompare</span>(</span>
<span class="line" id="L272">    self: *CheckObjectStep,</span>
<span class="line" id="L273">    program: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L274">    expected: ComputeCompareExpected,</span>
<span class="line" id="L275">) <span class="tok-type">void</span> {</span>
<span class="line" id="L276">    <span class="tok-kw">var</span> new_check = Check.create(self.builder);</span>
<span class="line" id="L277">    new_check.computeCmp(program, expected);</span>
<span class="line" id="L278">    self.checks.append(new_check) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L279">}</span>
<span class="line" id="L280"></span>
<span class="line" id="L281"><span class="tok-kw">fn</span> <span class="tok-fn">make</span>(step: *Step) !<span class="tok-type">void</span> {</span>
<span class="line" id="L282">    <span class="tok-kw">const</span> self = <span class="tok-builtin">@fieldParentPtr</span>(CheckObjectStep, <span class="tok-str">&quot;step&quot;</span>, step);</span>
<span class="line" id="L283"></span>
<span class="line" id="L284">    <span class="tok-kw">const</span> gpa = self.builder.allocator;</span>
<span class="line" id="L285">    <span class="tok-kw">const</span> src_path = self.source.getPath(self.builder);</span>
<span class="line" id="L286">    <span class="tok-kw">const</span> contents = <span class="tok-kw">try</span> fs.cwd().readFileAllocOptions(</span>
<span class="line" id="L287">        gpa,</span>
<span class="line" id="L288">        src_path,</span>
<span class="line" id="L289">        self.max_bytes,</span>
<span class="line" id="L290">        <span class="tok-null">null</span>,</span>
<span class="line" id="L291">        <span class="tok-builtin">@alignOf</span>(<span class="tok-type">u64</span>),</span>
<span class="line" id="L292">        <span class="tok-null">null</span>,</span>
<span class="line" id="L293">    );</span>
<span class="line" id="L294"></span>
<span class="line" id="L295">    <span class="tok-kw">const</span> output = <span class="tok-kw">switch</span> (self.obj_format) {</span>
<span class="line" id="L296">        .macho =&gt; <span class="tok-kw">try</span> MachODumper.parseAndDump(contents, .{</span>
<span class="line" id="L297">            .gpa = gpa,</span>
<span class="line" id="L298">            .dump_symtab = self.dump_symtab,</span>
<span class="line" id="L299">        }),</span>
<span class="line" id="L300">        .elf =&gt; <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;TODO elf parser&quot;</span>),</span>
<span class="line" id="L301">        .coff =&gt; <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;TODO coff parser&quot;</span>),</span>
<span class="line" id="L302">        .wasm =&gt; <span class="tok-kw">try</span> WasmDumper.parseAndDump(contents, .{</span>
<span class="line" id="L303">            .gpa = gpa,</span>
<span class="line" id="L304">            .dump_symtab = self.dump_symtab,</span>
<span class="line" id="L305">        }),</span>
<span class="line" id="L306">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L307">    };</span>
<span class="line" id="L308"></span>
<span class="line" id="L309">    <span class="tok-kw">var</span> vars = std.StringHashMap(<span class="tok-type">u64</span>).init(gpa);</span>
<span class="line" id="L310"></span>
<span class="line" id="L311">    <span class="tok-kw">for</span> (self.checks.items) |chk| {</span>
<span class="line" id="L312">        <span class="tok-kw">var</span> it = mem.tokenize(<span class="tok-type">u8</span>, output, <span class="tok-str">&quot;\r\n&quot;</span>);</span>
<span class="line" id="L313">        <span class="tok-kw">for</span> (chk.actions.items) |act| {</span>
<span class="line" id="L314">            <span class="tok-kw">switch</span> (act.tag) {</span>
<span class="line" id="L315">                .match =&gt; {</span>
<span class="line" id="L316">                    <span class="tok-kw">while</span> (it.next()) |line| {</span>
<span class="line" id="L317">                        <span class="tok-kw">if</span> (<span class="tok-kw">try</span> act.match(line, &amp;vars)) <span class="tok-kw">break</span>;</span>
<span class="line" id="L318">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L319">                        std.debug.print(</span>
<span class="line" id="L320">                            <span class="tok-str">\\</span></span>

<span class="line" id="L321">                            <span class="tok-str">\\========= Expected to find: ==========================</span></span>

<span class="line" id="L322">                            <span class="tok-str">\\{s}</span></span>

<span class="line" id="L323">                            <span class="tok-str">\\========= But parsed file does not contain it: =======</span></span>

<span class="line" id="L324">                            <span class="tok-str">\\{s}</span></span>

<span class="line" id="L325">                            <span class="tok-str">\\</span></span>

<span class="line" id="L326">                        , .{ act.phrase, output });</span>
<span class="line" id="L327">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestFailed;</span>
<span class="line" id="L328">                    }</span>
<span class="line" id="L329">                },</span>
<span class="line" id="L330">                .not_present =&gt; {</span>
<span class="line" id="L331">                    <span class="tok-kw">while</span> (it.next()) |line| {</span>
<span class="line" id="L332">                        <span class="tok-kw">if</span> (<span class="tok-kw">try</span> act.match(line, &amp;vars)) {</span>
<span class="line" id="L333">                            std.debug.print(</span>
<span class="line" id="L334">                                <span class="tok-str">\\</span></span>

<span class="line" id="L335">                                <span class="tok-str">\\========= Expected not to find: ===================</span></span>

<span class="line" id="L336">                                <span class="tok-str">\\{s}</span></span>

<span class="line" id="L337">                                <span class="tok-str">\\========= But parsed file does contain it: ========</span></span>

<span class="line" id="L338">                                <span class="tok-str">\\{s}</span></span>

<span class="line" id="L339">                                <span class="tok-str">\\</span></span>

<span class="line" id="L340">                            , .{ act.phrase, output });</span>
<span class="line" id="L341">                            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestFailed;</span>
<span class="line" id="L342">                        }</span>
<span class="line" id="L343">                    }</span>
<span class="line" id="L344">                },</span>
<span class="line" id="L345">                .compute_cmp =&gt; {</span>
<span class="line" id="L346">                    <span class="tok-kw">const</span> res = act.computeCmp(gpa, vars) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L347">                        <span class="tok-kw">error</span>.UnknownVariable =&gt; {</span>
<span class="line" id="L348">                            std.debug.print(</span>
<span class="line" id="L349">                                <span class="tok-str">\\========= From parsed file: =====================</span></span>

<span class="line" id="L350">                                <span class="tok-str">\\{s}</span></span>

<span class="line" id="L351">                                <span class="tok-str">\\</span></span>

<span class="line" id="L352">                            , .{output});</span>
<span class="line" id="L353">                            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestFailed;</span>
<span class="line" id="L354">                        },</span>
<span class="line" id="L355">                        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L356">                    };</span>
<span class="line" id="L357">                    <span class="tok-kw">if</span> (!res) {</span>
<span class="line" id="L358">                        std.debug.print(</span>
<span class="line" id="L359">                            <span class="tok-str">\\</span></span>

<span class="line" id="L360">                            <span class="tok-str">\\========= Comparison failed for action: ===========</span></span>

<span class="line" id="L361">                            <span class="tok-str">\\{s} {s}</span></span>

<span class="line" id="L362">                            <span class="tok-str">\\========= From parsed file: =======================</span></span>

<span class="line" id="L363">                            <span class="tok-str">\\{s}</span></span>

<span class="line" id="L364">                            <span class="tok-str">\\</span></span>

<span class="line" id="L365">                        , .{ act.phrase, act.expected.?, output });</span>
<span class="line" id="L366">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TestFailed;</span>
<span class="line" id="L367">                    }</span>
<span class="line" id="L368">                },</span>
<span class="line" id="L369">            }</span>
<span class="line" id="L370">        }</span>
<span class="line" id="L371">    }</span>
<span class="line" id="L372">}</span>
<span class="line" id="L373"></span>
<span class="line" id="L374"><span class="tok-kw">const</span> Opts = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L375">    gpa: ?Allocator = <span class="tok-null">null</span>,</span>
<span class="line" id="L376">    dump_symtab: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L377">};</span>
<span class="line" id="L378"></span>
<span class="line" id="L379"><span class="tok-kw">const</span> MachODumper = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L380">    <span class="tok-kw">const</span> LoadCommandIterator = macho.LoadCommandIterator;</span>
<span class="line" id="L381">    <span class="tok-kw">const</span> symtab_label = <span class="tok-str">&quot;symtab&quot;</span>;</span>
<span class="line" id="L382"></span>
<span class="line" id="L383">    <span class="tok-kw">fn</span> <span class="tok-fn">parseAndDump</span>(bytes: []<span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u64</span>)) <span class="tok-kw">const</span> <span class="tok-type">u8</span>, opts: Opts) ![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L384">        <span class="tok-kw">const</span> gpa = opts.gpa <span class="tok-kw">orelse</span> <span class="tok-kw">unreachable</span>; <span class="tok-comment">// MachO dumper requires an allocator</span>
</span>
<span class="line" id="L385">        <span class="tok-kw">var</span> stream = std.io.fixedBufferStream(bytes);</span>
<span class="line" id="L386">        <span class="tok-kw">const</span> reader = stream.reader();</span>
<span class="line" id="L387"></span>
<span class="line" id="L388">        <span class="tok-kw">const</span> hdr = <span class="tok-kw">try</span> reader.readStruct(macho.mach_header_64);</span>
<span class="line" id="L389">        <span class="tok-kw">if</span> (hdr.magic != macho.MH_MAGIC_64) {</span>
<span class="line" id="L390">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidMagicNumber;</span>
<span class="line" id="L391">        }</span>
<span class="line" id="L392"></span>
<span class="line" id="L393">        <span class="tok-kw">var</span> output = std.ArrayList(<span class="tok-type">u8</span>).init(gpa);</span>
<span class="line" id="L394">        <span class="tok-kw">const</span> writer = output.writer();</span>
<span class="line" id="L395"></span>
<span class="line" id="L396">        <span class="tok-kw">var</span> symtab: []<span class="tok-kw">const</span> macho.nlist_64 = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L397">        <span class="tok-kw">var</span> strtab: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L398">        <span class="tok-kw">var</span> sections = std.ArrayList(macho.section_64).init(gpa);</span>
<span class="line" id="L399">        <span class="tok-kw">var</span> imports = std.ArrayList([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>).init(gpa);</span>
<span class="line" id="L400"></span>
<span class="line" id="L401">        <span class="tok-kw">var</span> it = LoadCommandIterator{</span>
<span class="line" id="L402">            .ncmds = hdr.ncmds,</span>
<span class="line" id="L403">            .buffer = bytes[<span class="tok-builtin">@sizeOf</span>(macho.mach_header_64)..][<span class="tok-number">0</span>..hdr.sizeofcmds],</span>
<span class="line" id="L404">        };</span>
<span class="line" id="L405">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L406">        <span class="tok-kw">while</span> (it.next()) |cmd| {</span>
<span class="line" id="L407">            <span class="tok-kw">switch</span> (cmd.cmd()) {</span>
<span class="line" id="L408">                .SEGMENT_64 =&gt; {</span>
<span class="line" id="L409">                    <span class="tok-kw">const</span> seg = cmd.cast(macho.segment_command_64).?;</span>
<span class="line" id="L410">                    <span class="tok-kw">try</span> sections.ensureUnusedCapacity(seg.nsects);</span>
<span class="line" id="L411">                    <span class="tok-kw">for</span> (cmd.getSections()) |sect| {</span>
<span class="line" id="L412">                        sections.appendAssumeCapacity(sect);</span>
<span class="line" id="L413">                    }</span>
<span class="line" id="L414">                },</span>
<span class="line" id="L415">                .SYMTAB =&gt; <span class="tok-kw">if</span> (opts.dump_symtab) {</span>
<span class="line" id="L416">                    <span class="tok-kw">const</span> lc = cmd.cast(macho.symtab_command).?;</span>
<span class="line" id="L417">                    symtab = <span class="tok-builtin">@ptrCast</span>(</span>
<span class="line" id="L418">                        [*]<span class="tok-kw">const</span> macho.nlist_64,</span>
<span class="line" id="L419">                        <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(macho.nlist_64), &amp;bytes[lc.symoff]),</span>
<span class="line" id="L420">                    )[<span class="tok-number">0</span>..lc.nsyms];</span>
<span class="line" id="L421">                    strtab = bytes[lc.stroff..][<span class="tok-number">0</span>..lc.strsize];</span>
<span class="line" id="L422">                },</span>
<span class="line" id="L423">                .LOAD_DYLIB,</span>
<span class="line" id="L424">                .LOAD_WEAK_DYLIB,</span>
<span class="line" id="L425">                .REEXPORT_DYLIB,</span>
<span class="line" id="L426">                =&gt; {</span>
<span class="line" id="L427">                    <span class="tok-kw">try</span> imports.append(cmd.getDylibPathName());</span>
<span class="line" id="L428">                },</span>
<span class="line" id="L429">                <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L430">            }</span>
<span class="line" id="L431"></span>
<span class="line" id="L432">            <span class="tok-kw">try</span> dumpLoadCommand(cmd, i, writer);</span>
<span class="line" id="L433">            <span class="tok-kw">try</span> writer.writeByte(<span class="tok-str">'\n'</span>);</span>
<span class="line" id="L434"></span>
<span class="line" id="L435">            i += <span class="tok-number">1</span>;</span>
<span class="line" id="L436">        }</span>
<span class="line" id="L437"></span>
<span class="line" id="L438">        <span class="tok-kw">if</span> (opts.dump_symtab) {</span>
<span class="line" id="L439">            <span class="tok-kw">for</span> (symtab) |sym| {</span>
<span class="line" id="L440">                <span class="tok-kw">if</span> (sym.stab()) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L441">                <span class="tok-kw">const</span> sym_name = mem.sliceTo(<span class="tok-builtin">@ptrCast</span>([*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, strtab.ptr + sym.n_strx), <span class="tok-number">0</span>);</span>
<span class="line" id="L442">                <span class="tok-kw">if</span> (sym.sect()) {</span>
<span class="line" id="L443">                    <span class="tok-kw">const</span> sect = sections.items[sym.n_sect - <span class="tok-number">1</span>];</span>
<span class="line" id="L444">                    <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;{x} ({s},{s})&quot;</span>, .{</span>
<span class="line" id="L445">                        sym.n_value,</span>
<span class="line" id="L446">                        sect.segName(),</span>
<span class="line" id="L447">                        sect.sectName(),</span>
<span class="line" id="L448">                    });</span>
<span class="line" id="L449">                    <span class="tok-kw">if</span> (sym.ext()) {</span>
<span class="line" id="L450">                        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot; external&quot;</span>);</span>
<span class="line" id="L451">                    }</span>
<span class="line" id="L452">                    <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot; {s}\n&quot;</span>, .{sym_name});</span>
<span class="line" id="L453">                } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (sym.undf()) {</span>
<span class="line" id="L454">                    <span class="tok-kw">const</span> ordinal = <span class="tok-builtin">@divTrunc</span>(<span class="tok-builtin">@bitCast</span>(<span class="tok-type">i16</span>, sym.n_desc), macho.N_SYMBOL_RESOLVER);</span>
<span class="line" id="L455">                    <span class="tok-kw">const</span> import_name = blk: {</span>
<span class="line" id="L456">                        <span class="tok-kw">if</span> (ordinal &lt;= <span class="tok-number">0</span>) {</span>
<span class="line" id="L457">                            <span class="tok-kw">if</span> (ordinal == macho.BIND_SPECIAL_DYLIB_SELF)</span>
<span class="line" id="L458">                                <span class="tok-kw">break</span> :blk <span class="tok-str">&quot;self import&quot;</span>;</span>
<span class="line" id="L459">                            <span class="tok-kw">if</span> (ordinal == macho.BIND_SPECIAL_DYLIB_MAIN_EXECUTABLE)</span>
<span class="line" id="L460">                                <span class="tok-kw">break</span> :blk <span class="tok-str">&quot;main executable&quot;</span>;</span>
<span class="line" id="L461">                            <span class="tok-kw">if</span> (ordinal == macho.BIND_SPECIAL_DYLIB_FLAT_LOOKUP)</span>
<span class="line" id="L462">                                <span class="tok-kw">break</span> :blk <span class="tok-str">&quot;flat lookup&quot;</span>;</span>
<span class="line" id="L463">                            <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L464">                        }</span>
<span class="line" id="L465">                        <span class="tok-kw">const</span> full_path = imports.items[<span class="tok-builtin">@bitCast</span>(<span class="tok-type">u16</span>, ordinal) - <span class="tok-number">1</span>];</span>
<span class="line" id="L466">                        <span class="tok-kw">const</span> basename = fs.path.basename(full_path);</span>
<span class="line" id="L467">                        assert(basename.len &gt; <span class="tok-number">0</span>);</span>
<span class="line" id="L468">                        <span class="tok-kw">const</span> ext = mem.lastIndexOfScalar(<span class="tok-type">u8</span>, basename, <span class="tok-str">'.'</span>) <span class="tok-kw">orelse</span> basename.len;</span>
<span class="line" id="L469">                        <span class="tok-kw">break</span> :blk basename[<span class="tok-number">0</span>..ext];</span>
<span class="line" id="L470">                    };</span>
<span class="line" id="L471">                    <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;(undefined)&quot;</span>);</span>
<span class="line" id="L472">                    <span class="tok-kw">if</span> (sym.weakRef()) {</span>
<span class="line" id="L473">                        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot; weak&quot;</span>);</span>
<span class="line" id="L474">                    }</span>
<span class="line" id="L475">                    <span class="tok-kw">if</span> (sym.ext()) {</span>
<span class="line" id="L476">                        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot; external&quot;</span>);</span>
<span class="line" id="L477">                    }</span>
<span class="line" id="L478">                    <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot; {s} (from {s})\n&quot;</span>, .{</span>
<span class="line" id="L479">                        sym_name,</span>
<span class="line" id="L480">                        import_name,</span>
<span class="line" id="L481">                    });</span>
<span class="line" id="L482">                } <span class="tok-kw">else</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L483">            }</span>
<span class="line" id="L484">        }</span>
<span class="line" id="L485"></span>
<span class="line" id="L486">        <span class="tok-kw">return</span> output.toOwnedSlice();</span>
<span class="line" id="L487">    }</span>
<span class="line" id="L488"></span>
<span class="line" id="L489">    <span class="tok-kw">fn</span> <span class="tok-fn">dumpLoadCommand</span>(lc: macho.LoadCommandIterator.LoadCommand, index: <span class="tok-type">usize</span>, writer: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L490">        <span class="tok-comment">// print header first</span>
</span>
<span class="line" id="L491">        <span class="tok-kw">try</span> writer.print(</span>
<span class="line" id="L492">            <span class="tok-str">\\LC {d}</span></span>

<span class="line" id="L493">            <span class="tok-str">\\cmd {s}</span></span>

<span class="line" id="L494">            <span class="tok-str">\\cmdsize {d}</span></span>

<span class="line" id="L495">        , .{ index, <span class="tok-builtin">@tagName</span>(lc.cmd()), lc.cmdsize() });</span>
<span class="line" id="L496"></span>
<span class="line" id="L497">        <span class="tok-kw">switch</span> (lc.cmd()) {</span>
<span class="line" id="L498">            .SEGMENT_64 =&gt; {</span>
<span class="line" id="L499">                <span class="tok-kw">const</span> seg = lc.cast(macho.segment_command_64).?;</span>
<span class="line" id="L500">                <span class="tok-kw">try</span> writer.writeByte(<span class="tok-str">'\n'</span>);</span>
<span class="line" id="L501">                <span class="tok-kw">try</span> writer.print(</span>
<span class="line" id="L502">                    <span class="tok-str">\\segname {s}</span></span>

<span class="line" id="L503">                    <span class="tok-str">\\vmaddr {x}</span></span>

<span class="line" id="L504">                    <span class="tok-str">\\vmsize {x}</span></span>

<span class="line" id="L505">                    <span class="tok-str">\\fileoff {x}</span></span>

<span class="line" id="L506">                    <span class="tok-str">\\filesz {x}</span></span>

<span class="line" id="L507">                , .{</span>
<span class="line" id="L508">                    seg.segName(),</span>
<span class="line" id="L509">                    seg.vmaddr,</span>
<span class="line" id="L510">                    seg.vmsize,</span>
<span class="line" id="L511">                    seg.fileoff,</span>
<span class="line" id="L512">                    seg.filesize,</span>
<span class="line" id="L513">                });</span>
<span class="line" id="L514"></span>
<span class="line" id="L515">                <span class="tok-kw">for</span> (lc.getSections()) |sect| {</span>
<span class="line" id="L516">                    <span class="tok-kw">try</span> writer.writeByte(<span class="tok-str">'\n'</span>);</span>
<span class="line" id="L517">                    <span class="tok-kw">try</span> writer.print(</span>
<span class="line" id="L518">                        <span class="tok-str">\\sectname {s}</span></span>

<span class="line" id="L519">                        <span class="tok-str">\\addr {x}</span></span>

<span class="line" id="L520">                        <span class="tok-str">\\size {x}</span></span>

<span class="line" id="L521">                        <span class="tok-str">\\offset {x}</span></span>

<span class="line" id="L522">                        <span class="tok-str">\\align {x}</span></span>

<span class="line" id="L523">                    , .{</span>
<span class="line" id="L524">                        sect.sectName(),</span>
<span class="line" id="L525">                        sect.addr,</span>
<span class="line" id="L526">                        sect.size,</span>
<span class="line" id="L527">                        sect.offset,</span>
<span class="line" id="L528">                        sect.@&quot;align&quot;,</span>
<span class="line" id="L529">                    });</span>
<span class="line" id="L530">                }</span>
<span class="line" id="L531">            },</span>
<span class="line" id="L532"></span>
<span class="line" id="L533">            .ID_DYLIB,</span>
<span class="line" id="L534">            .LOAD_DYLIB,</span>
<span class="line" id="L535">            .LOAD_WEAK_DYLIB,</span>
<span class="line" id="L536">            .REEXPORT_DYLIB,</span>
<span class="line" id="L537">            =&gt; {</span>
<span class="line" id="L538">                <span class="tok-kw">const</span> dylib = lc.cast(macho.dylib_command).?;</span>
<span class="line" id="L539">                <span class="tok-kw">try</span> writer.writeByte(<span class="tok-str">'\n'</span>);</span>
<span class="line" id="L540">                <span class="tok-kw">try</span> writer.print(</span>
<span class="line" id="L541">                    <span class="tok-str">\\name {s}</span></span>

<span class="line" id="L542">                    <span class="tok-str">\\timestamp {d}</span></span>

<span class="line" id="L543">                    <span class="tok-str">\\current version {x}</span></span>

<span class="line" id="L544">                    <span class="tok-str">\\compatibility version {x}</span></span>

<span class="line" id="L545">                , .{</span>
<span class="line" id="L546">                    lc.getDylibPathName(),</span>
<span class="line" id="L547">                    dylib.dylib.timestamp,</span>
<span class="line" id="L548">                    dylib.dylib.current_version,</span>
<span class="line" id="L549">                    dylib.dylib.compatibility_version,</span>
<span class="line" id="L550">                });</span>
<span class="line" id="L551">            },</span>
<span class="line" id="L552"></span>
<span class="line" id="L553">            .MAIN =&gt; {</span>
<span class="line" id="L554">                <span class="tok-kw">const</span> main = lc.cast(macho.entry_point_command).?;</span>
<span class="line" id="L555">                <span class="tok-kw">try</span> writer.writeByte(<span class="tok-str">'\n'</span>);</span>
<span class="line" id="L556">                <span class="tok-kw">try</span> writer.print(</span>
<span class="line" id="L557">                    <span class="tok-str">\\entryoff {x}</span></span>

<span class="line" id="L558">                    <span class="tok-str">\\stacksize {x}</span></span>

<span class="line" id="L559">                , .{ main.entryoff, main.stacksize });</span>
<span class="line" id="L560">            },</span>
<span class="line" id="L561"></span>
<span class="line" id="L562">            .RPATH =&gt; {</span>
<span class="line" id="L563">                <span class="tok-kw">try</span> writer.writeByte(<span class="tok-str">'\n'</span>);</span>
<span class="line" id="L564">                <span class="tok-kw">try</span> writer.print(</span>
<span class="line" id="L565">                    <span class="tok-str">\\path {s}</span></span>

<span class="line" id="L566">                , .{</span>
<span class="line" id="L567">                    lc.getRpathPathName(),</span>
<span class="line" id="L568">                });</span>
<span class="line" id="L569">            },</span>
<span class="line" id="L570"></span>
<span class="line" id="L571">            <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L572">        }</span>
<span class="line" id="L573">    }</span>
<span class="line" id="L574">};</span>
<span class="line" id="L575"></span>
<span class="line" id="L576"><span class="tok-kw">const</span> WasmDumper = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L577">    <span class="tok-kw">const</span> symtab_label = <span class="tok-str">&quot;symbols&quot;</span>;</span>
<span class="line" id="L578"></span>
<span class="line" id="L579">    <span class="tok-kw">fn</span> <span class="tok-fn">parseAndDump</span>(bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, opts: Opts) ![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L580">        <span class="tok-kw">const</span> gpa = opts.gpa <span class="tok-kw">orelse</span> <span class="tok-kw">unreachable</span>; <span class="tok-comment">// Wasm dumper requires an allocator</span>
</span>
<span class="line" id="L581">        <span class="tok-kw">if</span> (opts.dump_symtab) {</span>
<span class="line" id="L582">            <span class="tok-builtin">@panic</span>(<span class="tok-str">&quot;TODO: Implement symbol table parsing and dumping&quot;</span>);</span>
<span class="line" id="L583">        }</span>
<span class="line" id="L584"></span>
<span class="line" id="L585">        <span class="tok-kw">var</span> fbs = std.io.fixedBufferStream(bytes);</span>
<span class="line" id="L586">        <span class="tok-kw">const</span> reader = fbs.reader();</span>
<span class="line" id="L587"></span>
<span class="line" id="L588">        <span class="tok-kw">const</span> buf = <span class="tok-kw">try</span> reader.readBytesNoEof(<span class="tok-number">8</span>);</span>
<span class="line" id="L589">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, buf[<span class="tok-number">0</span>..<span class="tok-number">4</span>], &amp;std.wasm.magic)) {</span>
<span class="line" id="L590">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidMagicByte;</span>
<span class="line" id="L591">        }</span>
<span class="line" id="L592">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, buf[<span class="tok-number">4</span>..], &amp;std.wasm.version)) {</span>
<span class="line" id="L593">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnsupportedWasmVersion;</span>
<span class="line" id="L594">        }</span>
<span class="line" id="L595"></span>
<span class="line" id="L596">        <span class="tok-kw">var</span> output = std.ArrayList(<span class="tok-type">u8</span>).init(gpa);</span>
<span class="line" id="L597">        <span class="tok-kw">errdefer</span> output.deinit();</span>
<span class="line" id="L598">        <span class="tok-kw">const</span> writer = output.writer();</span>
<span class="line" id="L599"></span>
<span class="line" id="L600">        <span class="tok-kw">while</span> (reader.readByte()) |current_byte| {</span>
<span class="line" id="L601">            <span class="tok-kw">const</span> section = std.meta.intToEnum(std.wasm.Section, current_byte) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L602">                std.debug.print(<span class="tok-str">&quot;Found invalid section id '{d}'\n&quot;</span>, .{current_byte});</span>
<span class="line" id="L603">                <span class="tok-kw">return</span> err;</span>
<span class="line" id="L604">            };</span>
<span class="line" id="L605"></span>
<span class="line" id="L606">            <span class="tok-kw">const</span> section_length = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader);</span>
<span class="line" id="L607">            <span class="tok-kw">try</span> parseAndDumpSection(section, bytes[fbs.pos..][<span class="tok-number">0</span>..section_length], writer);</span>
<span class="line" id="L608">            fbs.pos += section_length;</span>
<span class="line" id="L609">        } <span class="tok-kw">else</span> |_| {} <span class="tok-comment">// reached end of stream</span>
</span>
<span class="line" id="L610"></span>
<span class="line" id="L611">        <span class="tok-kw">return</span> output.toOwnedSlice();</span>
<span class="line" id="L612">    }</span>
<span class="line" id="L613"></span>
<span class="line" id="L614">    <span class="tok-kw">fn</span> <span class="tok-fn">parseAndDumpSection</span>(section: std.wasm.Section, data: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, writer: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L615">        <span class="tok-kw">var</span> fbs = std.io.fixedBufferStream(data);</span>
<span class="line" id="L616">        <span class="tok-kw">const</span> reader = fbs.reader();</span>
<span class="line" id="L617"></span>
<span class="line" id="L618">        <span class="tok-kw">try</span> writer.print(</span>
<span class="line" id="L619">            <span class="tok-str">\\Section {s}</span></span>

<span class="line" id="L620">            <span class="tok-str">\\size {d}</span></span>

<span class="line" id="L621">        , .{ <span class="tok-builtin">@tagName</span>(section), data.len });</span>
<span class="line" id="L622"></span>
<span class="line" id="L623">        <span class="tok-kw">switch</span> (section) {</span>
<span class="line" id="L624">            .<span class="tok-type">type</span>,</span>
<span class="line" id="L625">            .import,</span>
<span class="line" id="L626">            .function,</span>
<span class="line" id="L627">            .table,</span>
<span class="line" id="L628">            .memory,</span>
<span class="line" id="L629">            .global,</span>
<span class="line" id="L630">            .@&quot;export&quot;,</span>
<span class="line" id="L631">            .element,</span>
<span class="line" id="L632">            .code,</span>
<span class="line" id="L633">            .data,</span>
<span class="line" id="L634">            =&gt; {</span>
<span class="line" id="L635">                <span class="tok-kw">const</span> entries = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader);</span>
<span class="line" id="L636">                <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;\nentries {d}\n&quot;</span>, .{entries});</span>
<span class="line" id="L637">                <span class="tok-kw">try</span> dumpSection(section, data[fbs.pos..], entries, writer);</span>
<span class="line" id="L638">            },</span>
<span class="line" id="L639">            .custom =&gt; {</span>
<span class="line" id="L640">                <span class="tok-kw">const</span> name_length = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader);</span>
<span class="line" id="L641">                <span class="tok-kw">const</span> name = data[fbs.pos..][<span class="tok-number">0</span>..name_length];</span>
<span class="line" id="L642">                fbs.pos += name_length;</span>
<span class="line" id="L643">                <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;\nname {s}\n&quot;</span>, .{name});</span>
<span class="line" id="L644"></span>
<span class="line" id="L645">                <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;name&quot;</span>)) {</span>
<span class="line" id="L646">                    <span class="tok-kw">try</span> parseDumpNames(reader, writer, data);</span>
<span class="line" id="L647">                }</span>
<span class="line" id="L648">                <span class="tok-comment">// TODO: Implement parsing and dumping other custom sections (such as relocations)</span>
</span>
<span class="line" id="L649">            },</span>
<span class="line" id="L650">            .start =&gt; {</span>
<span class="line" id="L651">                <span class="tok-kw">const</span> start = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader);</span>
<span class="line" id="L652">                <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;\nstart {d}\n&quot;</span>, .{start});</span>
<span class="line" id="L653">            },</span>
<span class="line" id="L654">            <span class="tok-kw">else</span> =&gt; {}, <span class="tok-comment">// skip unknown sections</span>
</span>
<span class="line" id="L655">        }</span>
<span class="line" id="L656">    }</span>
<span class="line" id="L657"></span>
<span class="line" id="L658">    <span class="tok-kw">fn</span> <span class="tok-fn">dumpSection</span>(section: std.wasm.Section, data: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, entries: <span class="tok-type">u32</span>, writer: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L659">        <span class="tok-kw">var</span> fbs = std.io.fixedBufferStream(data);</span>
<span class="line" id="L660">        <span class="tok-kw">const</span> reader = fbs.reader();</span>
<span class="line" id="L661"></span>
<span class="line" id="L662">        <span class="tok-kw">switch</span> (section) {</span>
<span class="line" id="L663">            .<span class="tok-type">type</span> =&gt; {</span>
<span class="line" id="L664">                <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L665">                <span class="tok-kw">while</span> (i &lt; entries) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L666">                    <span class="tok-kw">const</span> func_type = <span class="tok-kw">try</span> reader.readByte();</span>
<span class="line" id="L667">                    <span class="tok-kw">if</span> (func_type != std.wasm.function_type) {</span>
<span class="line" id="L668">                        std.debug.print(<span class="tok-str">&quot;Expected function type, found byte '{d}'\n&quot;</span>, .{func_type});</span>
<span class="line" id="L669">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedByte;</span>
<span class="line" id="L670">                    }</span>
<span class="line" id="L671">                    <span class="tok-kw">const</span> params = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader);</span>
<span class="line" id="L672">                    <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;params {d}\n&quot;</span>, .{params});</span>
<span class="line" id="L673">                    <span class="tok-kw">var</span> index: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L674">                    <span class="tok-kw">while</span> (index &lt; params) : (index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L675">                        <span class="tok-kw">try</span> parseDumpType(std.wasm.Valtype, reader, writer);</span>
<span class="line" id="L676">                    } <span class="tok-kw">else</span> index = <span class="tok-number">0</span>;</span>
<span class="line" id="L677">                    <span class="tok-kw">const</span> returns = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader);</span>
<span class="line" id="L678">                    <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;returns {d}\n&quot;</span>, .{returns});</span>
<span class="line" id="L679">                    <span class="tok-kw">while</span> (index &lt; returns) : (index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L680">                        <span class="tok-kw">try</span> parseDumpType(std.wasm.Valtype, reader, writer);</span>
<span class="line" id="L681">                    }</span>
<span class="line" id="L682">                }</span>
<span class="line" id="L683">            },</span>
<span class="line" id="L684">            .import =&gt; {</span>
<span class="line" id="L685">                <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L686">                <span class="tok-kw">while</span> (i &lt; entries) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L687">                    <span class="tok-kw">const</span> module_name_len = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader);</span>
<span class="line" id="L688">                    <span class="tok-kw">const</span> module_name = data[fbs.pos..][<span class="tok-number">0</span>..module_name_len];</span>
<span class="line" id="L689">                    fbs.pos += module_name_len;</span>
<span class="line" id="L690">                    <span class="tok-kw">const</span> name_len = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader);</span>
<span class="line" id="L691">                    <span class="tok-kw">const</span> name = data[fbs.pos..][<span class="tok-number">0</span>..name_len];</span>
<span class="line" id="L692">                    fbs.pos += name_len;</span>
<span class="line" id="L693"></span>
<span class="line" id="L694">                    <span class="tok-kw">const</span> kind = std.meta.intToEnum(std.wasm.ExternalKind, <span class="tok-kw">try</span> reader.readByte()) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L695">                        std.debug.print(<span class="tok-str">&quot;Invalid import kind\n&quot;</span>, .{});</span>
<span class="line" id="L696">                        <span class="tok-kw">return</span> err;</span>
<span class="line" id="L697">                    };</span>
<span class="line" id="L698"></span>
<span class="line" id="L699">                    <span class="tok-kw">try</span> writer.print(</span>
<span class="line" id="L700">                        <span class="tok-str">\\module {s}</span></span>

<span class="line" id="L701">                        <span class="tok-str">\\name {s}</span></span>

<span class="line" id="L702">                        <span class="tok-str">\\kind {s}</span></span>

<span class="line" id="L703">                    , .{ module_name, name, <span class="tok-builtin">@tagName</span>(kind) });</span>
<span class="line" id="L704">                    <span class="tok-kw">try</span> writer.writeByte(<span class="tok-str">'\n'</span>);</span>
<span class="line" id="L705">                    <span class="tok-kw">switch</span> (kind) {</span>
<span class="line" id="L706">                        .function =&gt; {</span>
<span class="line" id="L707">                            <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;index {d}\n&quot;</span>, .{<span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader)});</span>
<span class="line" id="L708">                        },</span>
<span class="line" id="L709">                        .memory =&gt; {</span>
<span class="line" id="L710">                            <span class="tok-kw">try</span> parseDumpLimits(reader, writer);</span>
<span class="line" id="L711">                        },</span>
<span class="line" id="L712">                        .global =&gt; {</span>
<span class="line" id="L713">                            <span class="tok-kw">try</span> parseDumpType(std.wasm.Valtype, reader, writer);</span>
<span class="line" id="L714">                            <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;mutable {}\n&quot;</span>, .{<span class="tok-number">0x01</span> == <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader)});</span>
<span class="line" id="L715">                        },</span>
<span class="line" id="L716">                        .table =&gt; {</span>
<span class="line" id="L717">                            <span class="tok-kw">try</span> parseDumpType(std.wasm.RefType, reader, writer);</span>
<span class="line" id="L718">                            <span class="tok-kw">try</span> parseDumpLimits(reader, writer);</span>
<span class="line" id="L719">                        },</span>
<span class="line" id="L720">                    }</span>
<span class="line" id="L721">                }</span>
<span class="line" id="L722">            },</span>
<span class="line" id="L723">            .function =&gt; {</span>
<span class="line" id="L724">                <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L725">                <span class="tok-kw">while</span> (i &lt; entries) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L726">                    <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;index {d}\n&quot;</span>, .{<span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader)});</span>
<span class="line" id="L727">                }</span>
<span class="line" id="L728">            },</span>
<span class="line" id="L729">            .table =&gt; {</span>
<span class="line" id="L730">                <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L731">                <span class="tok-kw">while</span> (i &lt; entries) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L732">                    <span class="tok-kw">try</span> parseDumpType(std.wasm.RefType, reader, writer);</span>
<span class="line" id="L733">                    <span class="tok-kw">try</span> parseDumpLimits(reader, writer);</span>
<span class="line" id="L734">                }</span>
<span class="line" id="L735">            },</span>
<span class="line" id="L736">            .memory =&gt; {</span>
<span class="line" id="L737">                <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L738">                <span class="tok-kw">while</span> (i &lt; entries) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L739">                    <span class="tok-kw">try</span> parseDumpLimits(reader, writer);</span>
<span class="line" id="L740">                }</span>
<span class="line" id="L741">            },</span>
<span class="line" id="L742">            .global =&gt; {</span>
<span class="line" id="L743">                <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L744">                <span class="tok-kw">while</span> (i &lt; entries) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L745">                    <span class="tok-kw">try</span> parseDumpType(std.wasm.Valtype, reader, writer);</span>
<span class="line" id="L746">                    <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;mutable {}\n&quot;</span>, .{<span class="tok-number">0x01</span> == <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u1</span>, reader)});</span>
<span class="line" id="L747">                    <span class="tok-kw">try</span> parseDumpInit(reader, writer);</span>
<span class="line" id="L748">                }</span>
<span class="line" id="L749">            },</span>
<span class="line" id="L750">            .@&quot;export&quot; =&gt; {</span>
<span class="line" id="L751">                <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L752">                <span class="tok-kw">while</span> (i &lt; entries) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L753">                    <span class="tok-kw">const</span> name_len = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader);</span>
<span class="line" id="L754">                    <span class="tok-kw">const</span> name = data[fbs.pos..][<span class="tok-number">0</span>..name_len];</span>
<span class="line" id="L755">                    fbs.pos += name_len;</span>
<span class="line" id="L756">                    <span class="tok-kw">const</span> kind_byte = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u8</span>, reader);</span>
<span class="line" id="L757">                    <span class="tok-kw">const</span> kind = std.meta.intToEnum(std.wasm.ExternalKind, kind_byte) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L758">                        std.debug.print(<span class="tok-str">&quot;invalid export kind value '{d}'\n&quot;</span>, .{kind_byte});</span>
<span class="line" id="L759">                        <span class="tok-kw">return</span> err;</span>
<span class="line" id="L760">                    };</span>
<span class="line" id="L761">                    <span class="tok-kw">const</span> index = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader);</span>
<span class="line" id="L762">                    <span class="tok-kw">try</span> writer.print(</span>
<span class="line" id="L763">                        <span class="tok-str">\\name {s}</span></span>

<span class="line" id="L764">                        <span class="tok-str">\\kind {s}</span></span>

<span class="line" id="L765">                        <span class="tok-str">\\index {d}</span></span>

<span class="line" id="L766">                    , .{ name, <span class="tok-builtin">@tagName</span>(kind), index });</span>
<span class="line" id="L767">                    <span class="tok-kw">try</span> writer.writeByte(<span class="tok-str">'\n'</span>);</span>
<span class="line" id="L768">                }</span>
<span class="line" id="L769">            },</span>
<span class="line" id="L770">            .element =&gt; {</span>
<span class="line" id="L771">                <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L772">                <span class="tok-kw">while</span> (i &lt; entries) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L773">                    <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;table index {d}\n&quot;</span>, .{<span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader)});</span>
<span class="line" id="L774">                    <span class="tok-kw">try</span> parseDumpInit(reader, writer);</span>
<span class="line" id="L775"></span>
<span class="line" id="L776">                    <span class="tok-kw">const</span> function_indexes = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader);</span>
<span class="line" id="L777">                    <span class="tok-kw">var</span> function_index: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L778">                    <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;indexes {d}\n&quot;</span>, .{function_indexes});</span>
<span class="line" id="L779">                    <span class="tok-kw">while</span> (function_index &lt; function_indexes) : (function_index += <span class="tok-number">1</span>) {</span>
<span class="line" id="L780">                        <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;index {d}\n&quot;</span>, .{<span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader)});</span>
<span class="line" id="L781">                    }</span>
<span class="line" id="L782">                }</span>
<span class="line" id="L783">            },</span>
<span class="line" id="L784">            .code =&gt; {}, <span class="tok-comment">// code section is considered opaque to linker</span>
</span>
<span class="line" id="L785">            .data =&gt; {</span>
<span class="line" id="L786">                <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L787">                <span class="tok-kw">while</span> (i &lt; entries) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L788">                    <span class="tok-kw">const</span> index = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader);</span>
<span class="line" id="L789">                    <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;memory index 0x{x}\n&quot;</span>, .{index});</span>
<span class="line" id="L790">                    <span class="tok-kw">try</span> parseDumpInit(reader, writer);</span>
<span class="line" id="L791">                    <span class="tok-kw">const</span> size = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader);</span>
<span class="line" id="L792">                    <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;size {d}\n&quot;</span>, .{size});</span>
<span class="line" id="L793">                    <span class="tok-kw">try</span> reader.skipBytes(size, .{}); <span class="tok-comment">// we do not care about the content of the segments</span>
</span>
<span class="line" id="L794">                }</span>
<span class="line" id="L795">            },</span>
<span class="line" id="L796">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L797">        }</span>
<span class="line" id="L798">    }</span>
<span class="line" id="L799"></span>
<span class="line" id="L800">    <span class="tok-kw">fn</span> <span class="tok-fn">parseDumpType</span>(<span class="tok-kw">comptime</span> WasmType: <span class="tok-type">type</span>, reader: <span class="tok-kw">anytype</span>, writer: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L801">        <span class="tok-kw">const</span> type_byte = <span class="tok-kw">try</span> reader.readByte();</span>
<span class="line" id="L802">        <span class="tok-kw">const</span> valtype = std.meta.intToEnum(WasmType, type_byte) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L803">            std.debug.print(<span class="tok-str">&quot;Invalid wasm type value '{d}'\n&quot;</span>, .{type_byte});</span>
<span class="line" id="L804">            <span class="tok-kw">return</span> err;</span>
<span class="line" id="L805">        };</span>
<span class="line" id="L806">        <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;type {s}\n&quot;</span>, .{<span class="tok-builtin">@tagName</span>(valtype)});</span>
<span class="line" id="L807">    }</span>
<span class="line" id="L808"></span>
<span class="line" id="L809">    <span class="tok-kw">fn</span> <span class="tok-fn">parseDumpLimits</span>(reader: <span class="tok-kw">anytype</span>, writer: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L810">        <span class="tok-kw">const</span> flags = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u8</span>, reader);</span>
<span class="line" id="L811">        <span class="tok-kw">const</span> min = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader);</span>
<span class="line" id="L812"></span>
<span class="line" id="L813">        <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;min {x}\n&quot;</span>, .{min});</span>
<span class="line" id="L814">        <span class="tok-kw">if</span> (flags != <span class="tok-number">0</span>) {</span>
<span class="line" id="L815">            <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;max {x}\n&quot;</span>, .{<span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader)});</span>
<span class="line" id="L816">        }</span>
<span class="line" id="L817">    }</span>
<span class="line" id="L818"></span>
<span class="line" id="L819">    <span class="tok-kw">fn</span> <span class="tok-fn">parseDumpInit</span>(reader: <span class="tok-kw">anytype</span>, writer: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L820">        <span class="tok-kw">const</span> byte = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u8</span>, reader);</span>
<span class="line" id="L821">        <span class="tok-kw">const</span> opcode = std.meta.intToEnum(std.wasm.Opcode, byte) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L822">            std.debug.print(<span class="tok-str">&quot;invalid wasm opcode '{d}'\n&quot;</span>, .{byte});</span>
<span class="line" id="L823">            <span class="tok-kw">return</span> err;</span>
<span class="line" id="L824">        };</span>
<span class="line" id="L825">        <span class="tok-kw">switch</span> (opcode) {</span>
<span class="line" id="L826">            .i32_const =&gt; <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;i32.const {x}\n&quot;</span>, .{<span class="tok-kw">try</span> std.leb.readILEB128(<span class="tok-type">i32</span>, reader)}),</span>
<span class="line" id="L827">            .i64_const =&gt; <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;i64.const {x}\n&quot;</span>, .{<span class="tok-kw">try</span> std.leb.readILEB128(<span class="tok-type">i64</span>, reader)}),</span>
<span class="line" id="L828">            .f32_const =&gt; <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;f32.const {x}\n&quot;</span>, .{<span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, <span class="tok-kw">try</span> reader.readIntLittle(<span class="tok-type">u32</span>))}),</span>
<span class="line" id="L829">            .f64_const =&gt; <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;f64.const {x}\n&quot;</span>, .{<span class="tok-builtin">@bitCast</span>(<span class="tok-type">f64</span>, <span class="tok-kw">try</span> reader.readIntLittle(<span class="tok-type">u64</span>))}),</span>
<span class="line" id="L830">            .global_get =&gt; <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;global.get {x}\n&quot;</span>, .{<span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader)}),</span>
<span class="line" id="L831">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L832">        }</span>
<span class="line" id="L833">        <span class="tok-kw">const</span> end_opcode = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u8</span>, reader);</span>
<span class="line" id="L834">        <span class="tok-kw">if</span> (end_opcode != std.wasm.opcode(.end)) {</span>
<span class="line" id="L835">            std.debug.print(<span class="tok-str">&quot;expected 'end' opcode in init expression\n&quot;</span>, .{});</span>
<span class="line" id="L836">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MissingEndOpcode;</span>
<span class="line" id="L837">        }</span>
<span class="line" id="L838">    }</span>
<span class="line" id="L839"></span>
<span class="line" id="L840">    <span class="tok-kw">fn</span> <span class="tok-fn">parseDumpNames</span>(reader: <span class="tok-kw">anytype</span>, writer: <span class="tok-kw">anytype</span>, data: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L841">        <span class="tok-kw">while</span> (reader.context.pos &lt; data.len) {</span>
<span class="line" id="L842">            <span class="tok-kw">try</span> parseDumpType(std.wasm.NameSubsection, reader, writer);</span>
<span class="line" id="L843">            <span class="tok-kw">const</span> size = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader);</span>
<span class="line" id="L844">            <span class="tok-kw">const</span> entries = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader);</span>
<span class="line" id="L845">            <span class="tok-kw">try</span> writer.print(</span>
<span class="line" id="L846">                <span class="tok-str">\\size {d}</span></span>

<span class="line" id="L847">                <span class="tok-str">\\names {d}</span></span>

<span class="line" id="L848">            , .{ size, entries });</span>
<span class="line" id="L849">            <span class="tok-kw">try</span> writer.writeByte(<span class="tok-str">'\n'</span>);</span>
<span class="line" id="L850">            <span class="tok-kw">var</span> i: <span class="tok-type">u32</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L851">            <span class="tok-kw">while</span> (i &lt; entries) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L852">                <span class="tok-kw">const</span> index = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader);</span>
<span class="line" id="L853">                <span class="tok-kw">const</span> name_len = <span class="tok-kw">try</span> std.leb.readULEB128(<span class="tok-type">u32</span>, reader);</span>
<span class="line" id="L854">                <span class="tok-kw">const</span> pos = reader.context.pos;</span>
<span class="line" id="L855">                <span class="tok-kw">const</span> name = data[pos..][<span class="tok-number">0</span>..name_len];</span>
<span class="line" id="L856">                reader.context.pos += name_len;</span>
<span class="line" id="L857"></span>
<span class="line" id="L858">                <span class="tok-kw">try</span> writer.print(</span>
<span class="line" id="L859">                    <span class="tok-str">\\index {d}</span></span>

<span class="line" id="L860">                    <span class="tok-str">\\name {s}</span></span>

<span class="line" id="L861">                , .{ index, name });</span>
<span class="line" id="L862">                <span class="tok-kw">try</span> writer.writeByte(<span class="tok-str">'\n'</span>);</span>
<span class="line" id="L863">            }</span>
<span class="line" id="L864">        }</span>
<span class="line" id="L865">    }</span>
<span class="line" id="L866">};</span>
<span class="line" id="L867"></span>
</code></pre></body>
</html>