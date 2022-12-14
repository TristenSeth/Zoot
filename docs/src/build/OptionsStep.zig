<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>build/OptionsStep.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> build = std.build;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> fs = std.fs;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> Step = build.Step;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> Builder = build.Builder;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> GeneratedFile = build.GeneratedFile;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> LibExeObjStep = build.LibExeObjStep;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> FileSource = build.FileSource;</span>
<span class="line" id="L10"></span>
<span class="line" id="L11"><span class="tok-kw">const</span> OptionsStep = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L12"></span>
<span class="line" id="L13">step: Step,</span>
<span class="line" id="L14">generated_file: GeneratedFile,</span>
<span class="line" id="L15">builder: *Builder,</span>
<span class="line" id="L16"></span>
<span class="line" id="L17">contents: std.ArrayList(<span class="tok-type">u8</span>),</span>
<span class="line" id="L18">artifact_args: std.ArrayList(OptionArtifactArg),</span>
<span class="line" id="L19">file_source_args: std.ArrayList(OptionFileSourceArg),</span>
<span class="line" id="L20"></span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(builder: *Builder) *OptionsStep {</span>
<span class="line" id="L22">    <span class="tok-kw">const</span> self = builder.allocator.create(OptionsStep) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L23">    self.* = .{</span>
<span class="line" id="L24">        .builder = builder,</span>
<span class="line" id="L25">        .step = Step.init(.options, <span class="tok-str">&quot;options&quot;</span>, builder.allocator, make),</span>
<span class="line" id="L26">        .generated_file = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L27">        .contents = std.ArrayList(<span class="tok-type">u8</span>).init(builder.allocator),</span>
<span class="line" id="L28">        .artifact_args = std.ArrayList(OptionArtifactArg).init(builder.allocator),</span>
<span class="line" id="L29">        .file_source_args = std.ArrayList(OptionFileSourceArg).init(builder.allocator),</span>
<span class="line" id="L30">    };</span>
<span class="line" id="L31">    self.generated_file = .{ .step = &amp;self.step };</span>
<span class="line" id="L32"></span>
<span class="line" id="L33">    <span class="tok-kw">return</span> self;</span>
<span class="line" id="L34">}</span>
<span class="line" id="L35"></span>
<span class="line" id="L36"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addOption</span>(self: *OptionsStep, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: T) <span class="tok-type">void</span> {</span>
<span class="line" id="L37">    <span class="tok-kw">const</span> out = self.contents.writer();</span>
<span class="line" id="L38">    <span class="tok-kw">switch</span> (T) {</span>
<span class="line" id="L39">        []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span> =&gt; {</span>
<span class="line" id="L40">            out.print(<span class="tok-str">&quot;pub const {}: []const []const u8 = &amp;[_][]const u8{{\n&quot;</span>, .{std.zig.fmtId(name)}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L41">            <span class="tok-kw">for</span> (value) |slice| {</span>
<span class="line" id="L42">                out.print(<span class="tok-str">&quot;    \&quot;{}\&quot;,\n&quot;</span>, .{std.zig.fmtEscapes(slice)}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L43">            }</span>
<span class="line" id="L44">            out.writeAll(<span class="tok-str">&quot;};\n&quot;</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L45">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L46">        },</span>
<span class="line" id="L47">        [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> =&gt; {</span>
<span class="line" id="L48">            out.print(<span class="tok-str">&quot;pub const {}: [:0]const u8 = \&quot;{}\&quot;;\n&quot;</span>, .{ std.zig.fmtId(name), std.zig.fmtEscapes(value) }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L49">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L50">        },</span>
<span class="line" id="L51">        []<span class="tok-kw">const</span> <span class="tok-type">u8</span> =&gt; {</span>
<span class="line" id="L52">            out.print(<span class="tok-str">&quot;pub const {}: []const u8 = \&quot;{}\&quot;;\n&quot;</span>, .{ std.zig.fmtId(name), std.zig.fmtEscapes(value) }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L53">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L54">        },</span>
<span class="line" id="L55">        ?[:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span> =&gt; {</span>
<span class="line" id="L56">            out.print(<span class="tok-str">&quot;pub const {}: ?[:0]const u8 = &quot;</span>, .{std.zig.fmtId(name)}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L57">            <span class="tok-kw">if</span> (value) |payload| {</span>
<span class="line" id="L58">                out.print(<span class="tok-str">&quot;\&quot;{}\&quot;;\n&quot;</span>, .{std.zig.fmtEscapes(payload)}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L59">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L60">                out.writeAll(<span class="tok-str">&quot;null;\n&quot;</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L61">            }</span>
<span class="line" id="L62">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L63">        },</span>
<span class="line" id="L64">        ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> =&gt; {</span>
<span class="line" id="L65">            out.print(<span class="tok-str">&quot;pub const {}: ?[]const u8 = &quot;</span>, .{std.zig.fmtId(name)}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L66">            <span class="tok-kw">if</span> (value) |payload| {</span>
<span class="line" id="L67">                out.print(<span class="tok-str">&quot;\&quot;{}\&quot;;\n&quot;</span>, .{std.zig.fmtEscapes(payload)}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L68">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L69">                out.writeAll(<span class="tok-str">&quot;null;\n&quot;</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L70">            }</span>
<span class="line" id="L71">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L72">        },</span>
<span class="line" id="L73">        std.builtin.Version =&gt; {</span>
<span class="line" id="L74">            out.print(</span>
<span class="line" id="L75">                <span class="tok-str">\\pub const {}: @import(&quot;std&quot;).builtin.Version = .{{</span></span>

<span class="line" id="L76">                <span class="tok-str">\\    .major = {d},</span></span>

<span class="line" id="L77">                <span class="tok-str">\\    .minor = {d},</span></span>

<span class="line" id="L78">                <span class="tok-str">\\    .patch = {d},</span></span>

<span class="line" id="L79">                <span class="tok-str">\\}};</span></span>

<span class="line" id="L80">                <span class="tok-str">\\</span></span>

<span class="line" id="L81">            , .{</span>
<span class="line" id="L82">                std.zig.fmtId(name),</span>
<span class="line" id="L83"></span>
<span class="line" id="L84">                value.major,</span>
<span class="line" id="L85">                value.minor,</span>
<span class="line" id="L86">                value.patch,</span>
<span class="line" id="L87">            }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L88">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L89">        },</span>
<span class="line" id="L90">        std.SemanticVersion =&gt; {</span>
<span class="line" id="L91">            out.print(</span>
<span class="line" id="L92">                <span class="tok-str">\\pub const {}: @import(&quot;std&quot;).SemanticVersion = .{{</span></span>

<span class="line" id="L93">                <span class="tok-str">\\    .major = {d},</span></span>

<span class="line" id="L94">                <span class="tok-str">\\    .minor = {d},</span></span>

<span class="line" id="L95">                <span class="tok-str">\\    .patch = {d},</span></span>

<span class="line" id="L96">                <span class="tok-str">\\</span></span>

<span class="line" id="L97">            , .{</span>
<span class="line" id="L98">                std.zig.fmtId(name),</span>
<span class="line" id="L99"></span>
<span class="line" id="L100">                value.major,</span>
<span class="line" id="L101">                value.minor,</span>
<span class="line" id="L102">                value.patch,</span>
<span class="line" id="L103">            }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L104">            <span class="tok-kw">if</span> (value.pre) |some| {</span>
<span class="line" id="L105">                out.print(<span class="tok-str">&quot;    .pre = \&quot;{}\&quot;,\n&quot;</span>, .{std.zig.fmtEscapes(some)}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L106">            }</span>
<span class="line" id="L107">            <span class="tok-kw">if</span> (value.build) |some| {</span>
<span class="line" id="L108">                out.print(<span class="tok-str">&quot;    .build = \&quot;{}\&quot;,\n&quot;</span>, .{std.zig.fmtEscapes(some)}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L109">            }</span>
<span class="line" id="L110">            out.writeAll(<span class="tok-str">&quot;};\n&quot;</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L111">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L112">        },</span>
<span class="line" id="L113">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L114">    }</span>
<span class="line" id="L115">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L116">        .Enum =&gt; |enum_info| {</span>
<span class="line" id="L117">            out.print(<span class="tok-str">&quot;pub const {} = enum {{\n&quot;</span>, .{std.zig.fmtId(<span class="tok-builtin">@typeName</span>(T))}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L118">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (enum_info.fields) |field| {</span>
<span class="line" id="L119">                out.print(<span class="tok-str">&quot;    {},\n&quot;</span>, .{std.zig.fmtId(field.name)}) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L120">            }</span>
<span class="line" id="L121">            out.writeAll(<span class="tok-str">&quot;};\n&quot;</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L122">            out.print(<span class="tok-str">&quot;pub const {}: {s} = {s}.{s};\n&quot;</span>, .{</span>
<span class="line" id="L123">                std.zig.fmtId(name),</span>
<span class="line" id="L124">                std.zig.fmtId(<span class="tok-builtin">@typeName</span>(T)),</span>
<span class="line" id="L125">                std.zig.fmtId(<span class="tok-builtin">@typeName</span>(T)),</span>
<span class="line" id="L126">                std.zig.fmtId(<span class="tok-builtin">@tagName</span>(value)),</span>
<span class="line" id="L127">            }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L128">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L129">        },</span>
<span class="line" id="L130">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L131">    }</span>
<span class="line" id="L132">    out.print(<span class="tok-str">&quot;pub const {}: {s} = &quot;</span>, .{ std.zig.fmtId(name), std.zig.fmtId(<span class="tok-builtin">@typeName</span>(T)) }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L133">    printLiteral(out, value, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L134">    out.writeAll(<span class="tok-str">&quot;;\n&quot;</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L135">}</span>
<span class="line" id="L136"></span>
<span class="line" id="L137"><span class="tok-comment">// TODO: non-recursive?</span>
</span>
<span class="line" id="L138"><span class="tok-kw">fn</span> <span class="tok-fn">printLiteral</span>(out: <span class="tok-kw">anytype</span>, val: <span class="tok-kw">anytype</span>, indent: <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L139">    <span class="tok-kw">const</span> T = <span class="tok-builtin">@TypeOf</span>(val);</span>
<span class="line" id="L140">    <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(T)) {</span>
<span class="line" id="L141">        .Array =&gt; {</span>
<span class="line" id="L142">            <span class="tok-kw">try</span> out.print(<span class="tok-str">&quot;{s} {{\n&quot;</span>, .{<span class="tok-builtin">@typeName</span>(T)});</span>
<span class="line" id="L143">            <span class="tok-kw">for</span> (val) |item| {</span>
<span class="line" id="L144">                <span class="tok-kw">try</span> out.writeByteNTimes(<span class="tok-str">' '</span>, indent + <span class="tok-number">4</span>);</span>
<span class="line" id="L145">                <span class="tok-kw">try</span> printLiteral(out, item, indent + <span class="tok-number">4</span>);</span>
<span class="line" id="L146">                <span class="tok-kw">try</span> out.writeAll(<span class="tok-str">&quot;,\n&quot;</span>);</span>
<span class="line" id="L147">            }</span>
<span class="line" id="L148">            <span class="tok-kw">try</span> out.writeByteNTimes(<span class="tok-str">' '</span>, indent);</span>
<span class="line" id="L149">            <span class="tok-kw">try</span> out.writeAll(<span class="tok-str">&quot;}&quot;</span>);</span>
<span class="line" id="L150">        },</span>
<span class="line" id="L151">        .Pointer =&gt; |p| {</span>
<span class="line" id="L152">            <span class="tok-kw">if</span> (p.size != .Slice) {</span>
<span class="line" id="L153">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Non-slice pointers are not yet supported in build options&quot;</span>);</span>
<span class="line" id="L154">            }</span>
<span class="line" id="L155">            <span class="tok-kw">try</span> out.print(<span class="tok-str">&quot;&amp;[_]{s} {{\n&quot;</span>, .{<span class="tok-builtin">@typeName</span>(p.child)});</span>
<span class="line" id="L156">            <span class="tok-kw">for</span> (val) |item| {</span>
<span class="line" id="L157">                <span class="tok-kw">try</span> out.writeByteNTimes(<span class="tok-str">' '</span>, indent + <span class="tok-number">4</span>);</span>
<span class="line" id="L158">                <span class="tok-kw">try</span> printLiteral(out, item, indent + <span class="tok-number">4</span>);</span>
<span class="line" id="L159">                <span class="tok-kw">try</span> out.writeAll(<span class="tok-str">&quot;,\n&quot;</span>);</span>
<span class="line" id="L160">            }</span>
<span class="line" id="L161">            <span class="tok-kw">try</span> out.writeByteNTimes(<span class="tok-str">' '</span>, indent);</span>
<span class="line" id="L162">            <span class="tok-kw">try</span> out.writeAll(<span class="tok-str">&quot;}&quot;</span>);</span>
<span class="line" id="L163">        },</span>
<span class="line" id="L164">        .Optional =&gt; {</span>
<span class="line" id="L165">            <span class="tok-kw">if</span> (val) |inner| {</span>
<span class="line" id="L166">                <span class="tok-kw">return</span> printLiteral(out, inner, indent);</span>
<span class="line" id="L167">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L168">                <span class="tok-kw">return</span> out.writeAll(<span class="tok-str">&quot;null&quot;</span>);</span>
<span class="line" id="L169">            }</span>
<span class="line" id="L170">        },</span>
<span class="line" id="L171">        .Void,</span>
<span class="line" id="L172">        .Bool,</span>
<span class="line" id="L173">        .Int,</span>
<span class="line" id="L174">        .ComptimeInt,</span>
<span class="line" id="L175">        .Float,</span>
<span class="line" id="L176">        .Null,</span>
<span class="line" id="L177">        =&gt; <span class="tok-kw">try</span> out.print(<span class="tok-str">&quot;{any}&quot;</span>, .{val}),</span>
<span class="line" id="L178">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-kw">comptime</span> std.fmt.comptimePrint(<span class="tok-str">&quot;`{s}` are not yet supported as build options&quot;</span>, .{<span class="tok-builtin">@tagName</span>(<span class="tok-builtin">@typeInfo</span>(T))})),</span>
<span class="line" id="L179">    }</span>
<span class="line" id="L180">}</span>
<span class="line" id="L181"></span>
<span class="line" id="L182"><span class="tok-comment">/// The value is the path in the cache dir.</span></span>
<span class="line" id="L183"><span class="tok-comment">/// Adds a dependency automatically.</span></span>
<span class="line" id="L184"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addOptionFileSource</span>(</span>
<span class="line" id="L185">    self: *OptionsStep,</span>
<span class="line" id="L186">    name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L187">    source: FileSource,</span>
<span class="line" id="L188">) <span class="tok-type">void</span> {</span>
<span class="line" id="L189">    self.file_source_args.append(.{</span>
<span class="line" id="L190">        .name = name,</span>
<span class="line" id="L191">        .source = source.dupe(self.builder),</span>
<span class="line" id="L192">    }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L193">    source.addStepDependencies(&amp;self.step);</span>
<span class="line" id="L194">}</span>
<span class="line" id="L195"></span>
<span class="line" id="L196"><span class="tok-comment">/// The value is the path in the cache dir.</span></span>
<span class="line" id="L197"><span class="tok-comment">/// Adds a dependency automatically.</span></span>
<span class="line" id="L198"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">addOptionArtifact</span>(self: *OptionsStep, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, artifact: *LibExeObjStep) <span class="tok-type">void</span> {</span>
<span class="line" id="L199">    self.artifact_args.append(.{ .name = self.builder.dupe(name), .artifact = artifact }) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L200">    self.step.dependOn(&amp;artifact.step);</span>
<span class="line" id="L201">}</span>
<span class="line" id="L202"></span>
<span class="line" id="L203"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPackage</span>(self: *OptionsStep, package_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) build.Pkg {</span>
<span class="line" id="L204">    <span class="tok-kw">return</span> .{ .name = package_name, .source = self.getSource() };</span>
<span class="line" id="L205">}</span>
<span class="line" id="L206"></span>
<span class="line" id="L207"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getSource</span>(self: *OptionsStep) FileSource {</span>
<span class="line" id="L208">    <span class="tok-kw">return</span> .{ .generated = &amp;self.generated_file };</span>
<span class="line" id="L209">}</span>
<span class="line" id="L210"></span>
<span class="line" id="L211"><span class="tok-kw">fn</span> <span class="tok-fn">make</span>(step: *Step) !<span class="tok-type">void</span> {</span>
<span class="line" id="L212">    <span class="tok-kw">const</span> self = <span class="tok-builtin">@fieldParentPtr</span>(OptionsStep, <span class="tok-str">&quot;step&quot;</span>, step);</span>
<span class="line" id="L213"></span>
<span class="line" id="L214">    <span class="tok-kw">for</span> (self.artifact_args.items) |item| {</span>
<span class="line" id="L215">        self.addOption(</span>
<span class="line" id="L216">            []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L217">            item.name,</span>
<span class="line" id="L218">            self.builder.pathFromRoot(item.artifact.getOutputSource().getPath(self.builder)),</span>
<span class="line" id="L219">        );</span>
<span class="line" id="L220">    }</span>
<span class="line" id="L221"></span>
<span class="line" id="L222">    <span class="tok-kw">for</span> (self.file_source_args.items) |item| {</span>
<span class="line" id="L223">        self.addOption(</span>
<span class="line" id="L224">            []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L225">            item.name,</span>
<span class="line" id="L226">            item.source.getPath(self.builder),</span>
<span class="line" id="L227">        );</span>
<span class="line" id="L228">    }</span>
<span class="line" id="L229"></span>
<span class="line" id="L230">    <span class="tok-kw">const</span> options_directory = self.builder.pathFromRoot(</span>
<span class="line" id="L231">        <span class="tok-kw">try</span> fs.path.join(</span>
<span class="line" id="L232">            self.builder.allocator,</span>
<span class="line" id="L233">            &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ self.builder.cache_root, <span class="tok-str">&quot;options&quot;</span> },</span>
<span class="line" id="L234">        ),</span>
<span class="line" id="L235">    );</span>
<span class="line" id="L236"></span>
<span class="line" id="L237">    <span class="tok-kw">try</span> fs.cwd().makePath(options_directory);</span>
<span class="line" id="L238"></span>
<span class="line" id="L239">    <span class="tok-kw">const</span> options_file = <span class="tok-kw">try</span> fs.path.join(</span>
<span class="line" id="L240">        self.builder.allocator,</span>
<span class="line" id="L241">        &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ options_directory, &amp;self.hashContentsToFileName() },</span>
<span class="line" id="L242">    );</span>
<span class="line" id="L243"></span>
<span class="line" id="L244">    <span class="tok-kw">try</span> fs.cwd().writeFile(options_file, self.contents.items);</span>
<span class="line" id="L245"></span>
<span class="line" id="L246">    self.generated_file.path = options_file;</span>
<span class="line" id="L247">}</span>
<span class="line" id="L248"></span>
<span class="line" id="L249"><span class="tok-kw">fn</span> <span class="tok-fn">hashContentsToFileName</span>(self: *OptionsStep) [<span class="tok-number">64</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L250">    <span class="tok-comment">// This implementation is copied from `WriteFileStep.make`</span>
</span>
<span class="line" id="L251"></span>
<span class="line" id="L252">    <span class="tok-kw">var</span> hash = std.crypto.hash.blake2.Blake2b384.init(.{});</span>
<span class="line" id="L253"></span>
<span class="line" id="L254">    <span class="tok-comment">// Random bytes to make OptionsStep unique. Refresh this with</span>
</span>
<span class="line" id="L255">    <span class="tok-comment">// new random bytes when OptionsStep implementation is modified</span>
</span>
<span class="line" id="L256">    <span class="tok-comment">// in a non-backwards-compatible way.</span>
</span>
<span class="line" id="L257">    hash.update(<span class="tok-str">&quot;yL0Ya4KkmcCjBlP8&quot;</span>);</span>
<span class="line" id="L258">    hash.update(self.contents.items);</span>
<span class="line" id="L259"></span>
<span class="line" id="L260">    <span class="tok-kw">var</span> digest: [<span class="tok-number">48</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L261">    hash.final(&amp;digest);</span>
<span class="line" id="L262">    <span class="tok-kw">var</span> hash_basename: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L263">    _ = fs.base64_encoder.encode(&amp;hash_basename, &amp;digest);</span>
<span class="line" id="L264">    <span class="tok-kw">return</span> hash_basename;</span>
<span class="line" id="L265">}</span>
<span class="line" id="L266"></span>
<span class="line" id="L267"><span class="tok-kw">const</span> OptionArtifactArg = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L268">    name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L269">    artifact: *LibExeObjStep,</span>
<span class="line" id="L270">};</span>
<span class="line" id="L271"></span>
<span class="line" id="L272"><span class="tok-kw">const</span> OptionFileSourceArg = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L273">    name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L274">    source: FileSource,</span>
<span class="line" id="L275">};</span>
<span class="line" id="L276"></span>
<span class="line" id="L277"><span class="tok-kw">test</span> <span class="tok-str">&quot;OptionsStep&quot;</span> {</span>
<span class="line" id="L278">    <span class="tok-kw">if</span> (builtin.os.tag == .wasi) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SkipZigTest;</span>
<span class="line" id="L279"></span>
<span class="line" id="L280">    <span class="tok-kw">var</span> arena = std.heap.ArenaAllocator.init(std.testing.allocator);</span>
<span class="line" id="L281">    <span class="tok-kw">defer</span> arena.deinit();</span>
<span class="line" id="L282">    <span class="tok-kw">var</span> builder = <span class="tok-kw">try</span> Builder.create(</span>
<span class="line" id="L283">        arena.allocator(),</span>
<span class="line" id="L284">        <span class="tok-str">&quot;test&quot;</span>,</span>
<span class="line" id="L285">        <span class="tok-str">&quot;test&quot;</span>,</span>
<span class="line" id="L286">        <span class="tok-str">&quot;test&quot;</span>,</span>
<span class="line" id="L287">        <span class="tok-str">&quot;test&quot;</span>,</span>
<span class="line" id="L288">    );</span>
<span class="line" id="L289">    <span class="tok-kw">defer</span> builder.destroy();</span>
<span class="line" id="L290"></span>
<span class="line" id="L291">    <span class="tok-kw">const</span> options = builder.addOptions();</span>
<span class="line" id="L292"></span>
<span class="line" id="L293">    <span class="tok-kw">const</span> KeywordEnum = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L294">        @&quot;0.8.1&quot;,</span>
<span class="line" id="L295">    };</span>
<span class="line" id="L296"></span>
<span class="line" id="L297">    <span class="tok-kw">const</span> nested_array = [<span class="tok-number">2</span>][<span class="tok-number">2</span>]<span class="tok-type">u16</span>{</span>
<span class="line" id="L298">        [<span class="tok-number">2</span>]<span class="tok-type">u16</span>{ <span class="tok-number">300</span>, <span class="tok-number">200</span> },</span>
<span class="line" id="L299">        [<span class="tok-number">2</span>]<span class="tok-type">u16</span>{ <span class="tok-number">300</span>, <span class="tok-number">200</span> },</span>
<span class="line" id="L300">    };</span>
<span class="line" id="L301">    <span class="tok-kw">const</span> nested_slice: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u16</span> = &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u16</span>{ &amp;nested_array[<span class="tok-number">0</span>], &amp;nested_array[<span class="tok-number">1</span>] };</span>
<span class="line" id="L302"></span>
<span class="line" id="L303">    options.addOption(<span class="tok-type">usize</span>, <span class="tok-str">&quot;option1&quot;</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L304">    options.addOption(?<span class="tok-type">usize</span>, <span class="tok-str">&quot;option2&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L305">    options.addOption(?<span class="tok-type">usize</span>, <span class="tok-str">&quot;option3&quot;</span>, <span class="tok-number">3</span>);</span>
<span class="line" id="L306">    options.addOption(<span class="tok-type">comptime_int</span>, <span class="tok-str">&quot;option4&quot;</span>, <span class="tok-number">4</span>);</span>
<span class="line" id="L307">    options.addOption([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-str">&quot;string&quot;</span>, <span class="tok-str">&quot;zigisthebest&quot;</span>);</span>
<span class="line" id="L308">    options.addOption(?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-str">&quot;optional_string&quot;</span>, <span class="tok-null">null</span>);</span>
<span class="line" id="L309">    options.addOption([<span class="tok-number">2</span>][<span class="tok-number">2</span>]<span class="tok-type">u16</span>, <span class="tok-str">&quot;nested_array&quot;</span>, nested_array);</span>
<span class="line" id="L310">    options.addOption([]<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, <span class="tok-str">&quot;nested_slice&quot;</span>, nested_slice);</span>
<span class="line" id="L311">    options.addOption(KeywordEnum, <span class="tok-str">&quot;keyword_enum&quot;</span>, .@&quot;0.8.1&quot;);</span>
<span class="line" id="L312">    options.addOption(std.builtin.Version, <span class="tok-str">&quot;version&quot;</span>, <span class="tok-kw">try</span> std.builtin.Version.parse(<span class="tok-str">&quot;0.1.2&quot;</span>));</span>
<span class="line" id="L313">    options.addOption(std.SemanticVersion, <span class="tok-str">&quot;semantic_version&quot;</span>, <span class="tok-kw">try</span> std.SemanticVersion.parse(<span class="tok-str">&quot;0.1.2-foo+bar&quot;</span>));</span>
<span class="line" id="L314"></span>
<span class="line" id="L315">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(</span>
<span class="line" id="L316">        <span class="tok-str">\\pub const option1: usize = 1;</span></span>

<span class="line" id="L317">        <span class="tok-str">\\pub const option2: ?usize = null;</span></span>

<span class="line" id="L318">        <span class="tok-str">\\pub const option3: ?usize = 3;</span></span>

<span class="line" id="L319">        <span class="tok-str">\\pub const option4: comptime_int = 4;</span></span>

<span class="line" id="L320">        <span class="tok-str">\\pub const string: []const u8 = &quot;zigisthebest&quot;;</span></span>

<span class="line" id="L321">        <span class="tok-str">\\pub const optional_string: ?[]const u8 = null;</span></span>

<span class="line" id="L322">        <span class="tok-str">\\pub const nested_array: [2][2]u16 = [2][2]u16 {</span></span>

<span class="line" id="L323">        <span class="tok-str">\\    [2]u16 {</span></span>

<span class="line" id="L324">        <span class="tok-str">\\        300,</span></span>

<span class="line" id="L325">        <span class="tok-str">\\        200,</span></span>

<span class="line" id="L326">        <span class="tok-str">\\    },</span></span>

<span class="line" id="L327">        <span class="tok-str">\\    [2]u16 {</span></span>

<span class="line" id="L328">        <span class="tok-str">\\        300,</span></span>

<span class="line" id="L329">        <span class="tok-str">\\        200,</span></span>

<span class="line" id="L330">        <span class="tok-str">\\    },</span></span>

<span class="line" id="L331">        <span class="tok-str">\\};</span></span>

<span class="line" id="L332">        <span class="tok-str">\\pub const nested_slice: []const []const u16 = &amp;[_][]const u16 {</span></span>

<span class="line" id="L333">        <span class="tok-str">\\    &amp;[_]u16 {</span></span>

<span class="line" id="L334">        <span class="tok-str">\\        300,</span></span>

<span class="line" id="L335">        <span class="tok-str">\\        200,</span></span>

<span class="line" id="L336">        <span class="tok-str">\\    },</span></span>

<span class="line" id="L337">        <span class="tok-str">\\    &amp;[_]u16 {</span></span>

<span class="line" id="L338">        <span class="tok-str">\\        300,</span></span>

<span class="line" id="L339">        <span class="tok-str">\\        200,</span></span>

<span class="line" id="L340">        <span class="tok-str">\\    },</span></span>

<span class="line" id="L341">        <span class="tok-str">\\};</span></span>

<span class="line" id="L342">        <span class="tok-str">\\pub const KeywordEnum = enum {</span></span>

<span class="line" id="L343">        <span class="tok-str">\\    @&quot;0.8.1&quot;,</span></span>

<span class="line" id="L344">        <span class="tok-str">\\};</span></span>

<span class="line" id="L345">        <span class="tok-str">\\pub const keyword_enum: KeywordEnum = KeywordEnum.@&quot;0.8.1&quot;;</span></span>

<span class="line" id="L346">        <span class="tok-str">\\pub const version: @import(&quot;std&quot;).builtin.Version = .{</span></span>

<span class="line" id="L347">        <span class="tok-str">\\    .major = 0,</span></span>

<span class="line" id="L348">        <span class="tok-str">\\    .minor = 1,</span></span>

<span class="line" id="L349">        <span class="tok-str">\\    .patch = 2,</span></span>

<span class="line" id="L350">        <span class="tok-str">\\};</span></span>

<span class="line" id="L351">        <span class="tok-str">\\pub const semantic_version: @import(&quot;std&quot;).SemanticVersion = .{</span></span>

<span class="line" id="L352">        <span class="tok-str">\\    .major = 0,</span></span>

<span class="line" id="L353">        <span class="tok-str">\\    .minor = 1,</span></span>

<span class="line" id="L354">        <span class="tok-str">\\    .patch = 2,</span></span>

<span class="line" id="L355">        <span class="tok-str">\\    .pre = &quot;foo&quot;,</span></span>

<span class="line" id="L356">        <span class="tok-str">\\    .build = &quot;bar&quot;,</span></span>

<span class="line" id="L357">        <span class="tok-str">\\};</span></span>

<span class="line" id="L358">        <span class="tok-str">\\</span></span>

<span class="line" id="L359">    , options.contents.items);</span>
<span class="line" id="L360"></span>
<span class="line" id="L361">    _ = <span class="tok-kw">try</span> std.zig.parse(arena.allocator(), <span class="tok-kw">try</span> options.contents.toOwnedSliceSentinel(<span class="tok-number">0</span>));</span>
<span class="line" id="L362">}</span>
<span class="line" id="L363"></span>
</code></pre></body>
</html>