<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>zig/system/linux.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> fs = std.fs;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> fmt = std.fmt;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-kw">const</span> Target = std.Target;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> CrossTarget = std.zig.CrossTarget;</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-kw">const</span> SparcCpuinfoImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L15">    model: ?*<span class="tok-kw">const</span> Target.Cpu.Model = <span class="tok-null">null</span>,</span>
<span class="line" id="L16">    is_64bit: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L17"></span>
<span class="line" id="L18">    <span class="tok-kw">const</span> cpu_names = .{</span>
<span class="line" id="L19">        .{ <span class="tok-str">&quot;SuperSparc&quot;</span>, &amp;Target.sparc.cpu.supersparc },</span>
<span class="line" id="L20">        .{ <span class="tok-str">&quot;HyperSparc&quot;</span>, &amp;Target.sparc.cpu.hypersparc },</span>
<span class="line" id="L21">        .{ <span class="tok-str">&quot;SpitFire&quot;</span>, &amp;Target.sparc.cpu.ultrasparc },</span>
<span class="line" id="L22">        .{ <span class="tok-str">&quot;BlackBird&quot;</span>, &amp;Target.sparc.cpu.ultrasparc },</span>
<span class="line" id="L23">        .{ <span class="tok-str">&quot;Sabre&quot;</span>, &amp;Target.sparc.cpu.ultrasparc },</span>
<span class="line" id="L24">        .{ <span class="tok-str">&quot;Hummingbird&quot;</span>, &amp;Target.sparc.cpu.ultrasparc },</span>
<span class="line" id="L25">        .{ <span class="tok-str">&quot;Cheetah&quot;</span>, &amp;Target.sparc.cpu.ultrasparc3 },</span>
<span class="line" id="L26">        .{ <span class="tok-str">&quot;Jalapeno&quot;</span>, &amp;Target.sparc.cpu.ultrasparc3 },</span>
<span class="line" id="L27">        .{ <span class="tok-str">&quot;Jaguar&quot;</span>, &amp;Target.sparc.cpu.ultrasparc3 },</span>
<span class="line" id="L28">        .{ <span class="tok-str">&quot;Panther&quot;</span>, &amp;Target.sparc.cpu.ultrasparc3 },</span>
<span class="line" id="L29">        .{ <span class="tok-str">&quot;Serrano&quot;</span>, &amp;Target.sparc.cpu.ultrasparc3 },</span>
<span class="line" id="L30">        .{ <span class="tok-str">&quot;UltraSparc T1&quot;</span>, &amp;Target.sparc.cpu.niagara },</span>
<span class="line" id="L31">        .{ <span class="tok-str">&quot;UltraSparc T2&quot;</span>, &amp;Target.sparc.cpu.niagara2 },</span>
<span class="line" id="L32">        .{ <span class="tok-str">&quot;UltraSparc T3&quot;</span>, &amp;Target.sparc.cpu.niagara3 },</span>
<span class="line" id="L33">        .{ <span class="tok-str">&quot;UltraSparc T4&quot;</span>, &amp;Target.sparc.cpu.niagara4 },</span>
<span class="line" id="L34">        .{ <span class="tok-str">&quot;UltraSparc T5&quot;</span>, &amp;Target.sparc.cpu.niagara4 },</span>
<span class="line" id="L35">        .{ <span class="tok-str">&quot;LEON&quot;</span>, &amp;Target.sparc.cpu.leon3 },</span>
<span class="line" id="L36">    };</span>
<span class="line" id="L37"></span>
<span class="line" id="L38">    <span class="tok-kw">fn</span> <span class="tok-fn">line_hook</span>(self: *SparcCpuinfoImpl, key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">bool</span> {</span>
<span class="line" id="L39">        <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, key, <span class="tok-str">&quot;cpu&quot;</span>)) {</span>
<span class="line" id="L40">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (cpu_names) |pair| {</span>
<span class="line" id="L41">                <span class="tok-kw">if</span> (mem.indexOfPos(<span class="tok-type">u8</span>, value, <span class="tok-number">0</span>, pair[<span class="tok-number">0</span>]) != <span class="tok-null">null</span>) {</span>
<span class="line" id="L42">                    self.model = pair[<span class="tok-number">1</span>];</span>
<span class="line" id="L43">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L44">                }</span>
<span class="line" id="L45">            }</span>
<span class="line" id="L46">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, key, <span class="tok-str">&quot;type&quot;</span>)) {</span>
<span class="line" id="L47">            self.is_64bit = mem.eql(<span class="tok-type">u8</span>, value, <span class="tok-str">&quot;sun4u&quot;</span>) <span class="tok-kw">or</span> mem.eql(<span class="tok-type">u8</span>, value, <span class="tok-str">&quot;sun4v&quot;</span>);</span>
<span class="line" id="L48">        }</span>
<span class="line" id="L49"></span>
<span class="line" id="L50">        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L51">    }</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">    <span class="tok-kw">fn</span> <span class="tok-fn">finalize</span>(self: *<span class="tok-kw">const</span> SparcCpuinfoImpl, arch: Target.Cpu.Arch) ?Target.Cpu {</span>
<span class="line" id="L54">        <span class="tok-comment">// At the moment we only support 64bit SPARC systems.</span>
</span>
<span class="line" id="L55">        assert(self.is_64bit);</span>
<span class="line" id="L56"></span>
<span class="line" id="L57">        <span class="tok-kw">const</span> model = self.model <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L58">        <span class="tok-kw">return</span> Target.Cpu{</span>
<span class="line" id="L59">            .arch = arch,</span>
<span class="line" id="L60">            .model = model,</span>
<span class="line" id="L61">            .features = model.features,</span>
<span class="line" id="L62">        };</span>
<span class="line" id="L63">    }</span>
<span class="line" id="L64">};</span>
<span class="line" id="L65"></span>
<span class="line" id="L66"><span class="tok-kw">const</span> SparcCpuinfoParser = CpuinfoParser(SparcCpuinfoImpl);</span>
<span class="line" id="L67"></span>
<span class="line" id="L68"><span class="tok-kw">test</span> <span class="tok-str">&quot;cpuinfo: SPARC&quot;</span> {</span>
<span class="line" id="L69">    <span class="tok-kw">try</span> testParser(SparcCpuinfoParser, .sparc64, &amp;Target.sparc.cpu.niagara2,</span>
<span class="line" id="L70">        <span class="tok-str">\\cpu             : UltraSparc T2 (Niagara2)</span></span>

<span class="line" id="L71">        <span class="tok-str">\\fpu             : UltraSparc T2 integrated FPU</span></span>

<span class="line" id="L72">        <span class="tok-str">\\pmu             : niagara2</span></span>

<span class="line" id="L73">        <span class="tok-str">\\type            : sun4v</span></span>

<span class="line" id="L74">    );</span>
<span class="line" id="L75">}</span>
<span class="line" id="L76"></span>
<span class="line" id="L77"><span class="tok-kw">const</span> PowerpcCpuinfoImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L78">    model: ?*<span class="tok-kw">const</span> Target.Cpu.Model = <span class="tok-null">null</span>,</span>
<span class="line" id="L79"></span>
<span class="line" id="L80">    <span class="tok-kw">const</span> cpu_names = .{</span>
<span class="line" id="L81">        .{ <span class="tok-str">&quot;604e&quot;</span>, &amp;Target.powerpc.cpu.@&quot;604e&quot; },</span>
<span class="line" id="L82">        .{ <span class="tok-str">&quot;604&quot;</span>, &amp;Target.powerpc.cpu.@&quot;604&quot; },</span>
<span class="line" id="L83">        .{ <span class="tok-str">&quot;7400&quot;</span>, &amp;Target.powerpc.cpu.@&quot;7400&quot; },</span>
<span class="line" id="L84">        .{ <span class="tok-str">&quot;7410&quot;</span>, &amp;Target.powerpc.cpu.@&quot;7400&quot; },</span>
<span class="line" id="L85">        .{ <span class="tok-str">&quot;7447&quot;</span>, &amp;Target.powerpc.cpu.@&quot;7400&quot; },</span>
<span class="line" id="L86">        .{ <span class="tok-str">&quot;7455&quot;</span>, &amp;Target.powerpc.cpu.@&quot;7450&quot; },</span>
<span class="line" id="L87">        .{ <span class="tok-str">&quot;G4&quot;</span>, &amp;Target.powerpc.cpu.@&quot;g4&quot; },</span>
<span class="line" id="L88">        .{ <span class="tok-str">&quot;POWER4&quot;</span>, &amp;Target.powerpc.cpu.@&quot;970&quot; },</span>
<span class="line" id="L89">        .{ <span class="tok-str">&quot;PPC970FX&quot;</span>, &amp;Target.powerpc.cpu.@&quot;970&quot; },</span>
<span class="line" id="L90">        .{ <span class="tok-str">&quot;PPC970MP&quot;</span>, &amp;Target.powerpc.cpu.@&quot;970&quot; },</span>
<span class="line" id="L91">        .{ <span class="tok-str">&quot;G5&quot;</span>, &amp;Target.powerpc.cpu.@&quot;g5&quot; },</span>
<span class="line" id="L92">        .{ <span class="tok-str">&quot;POWER5&quot;</span>, &amp;Target.powerpc.cpu.@&quot;g5&quot; },</span>
<span class="line" id="L93">        .{ <span class="tok-str">&quot;A2&quot;</span>, &amp;Target.powerpc.cpu.@&quot;a2&quot; },</span>
<span class="line" id="L94">        .{ <span class="tok-str">&quot;POWER6&quot;</span>, &amp;Target.powerpc.cpu.@&quot;pwr6&quot; },</span>
<span class="line" id="L95">        .{ <span class="tok-str">&quot;POWER7&quot;</span>, &amp;Target.powerpc.cpu.@&quot;pwr7&quot; },</span>
<span class="line" id="L96">        .{ <span class="tok-str">&quot;POWER8&quot;</span>, &amp;Target.powerpc.cpu.@&quot;pwr8&quot; },</span>
<span class="line" id="L97">        .{ <span class="tok-str">&quot;POWER8E&quot;</span>, &amp;Target.powerpc.cpu.@&quot;pwr8&quot; },</span>
<span class="line" id="L98">        .{ <span class="tok-str">&quot;POWER8NVL&quot;</span>, &amp;Target.powerpc.cpu.@&quot;pwr8&quot; },</span>
<span class="line" id="L99">        .{ <span class="tok-str">&quot;POWER9&quot;</span>, &amp;Target.powerpc.cpu.@&quot;pwr9&quot; },</span>
<span class="line" id="L100">        .{ <span class="tok-str">&quot;POWER10&quot;</span>, &amp;Target.powerpc.cpu.@&quot;pwr10&quot; },</span>
<span class="line" id="L101">    };</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">    <span class="tok-kw">fn</span> <span class="tok-fn">line_hook</span>(self: *PowerpcCpuinfoImpl, key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">bool</span> {</span>
<span class="line" id="L104">        <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, key, <span class="tok-str">&quot;cpu&quot;</span>)) {</span>
<span class="line" id="L105">            <span class="tok-comment">// The model name is often followed by a comma or space and extra</span>
</span>
<span class="line" id="L106">            <span class="tok-comment">// info.</span>
</span>
<span class="line" id="L107">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (cpu_names) |pair| {</span>
<span class="line" id="L108">                <span class="tok-kw">const</span> end_index = mem.indexOfAny(<span class="tok-type">u8</span>, value, <span class="tok-str">&quot;, &quot;</span>) <span class="tok-kw">orelse</span> value.len;</span>
<span class="line" id="L109">                <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, value[<span class="tok-number">0</span>..end_index], pair[<span class="tok-number">0</span>])) {</span>
<span class="line" id="L110">                    self.model = pair[<span class="tok-number">1</span>];</span>
<span class="line" id="L111">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L112">                }</span>
<span class="line" id="L113">            }</span>
<span class="line" id="L114"></span>
<span class="line" id="L115">            <span class="tok-comment">// Stop the detection once we've seen the first core.</span>
</span>
<span class="line" id="L116">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L117">        }</span>
<span class="line" id="L118"></span>
<span class="line" id="L119">        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L120">    }</span>
<span class="line" id="L121"></span>
<span class="line" id="L122">    <span class="tok-kw">fn</span> <span class="tok-fn">finalize</span>(self: *<span class="tok-kw">const</span> PowerpcCpuinfoImpl, arch: Target.Cpu.Arch) ?Target.Cpu {</span>
<span class="line" id="L123">        <span class="tok-kw">const</span> model = self.model <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L124">        <span class="tok-kw">return</span> Target.Cpu{</span>
<span class="line" id="L125">            .arch = arch,</span>
<span class="line" id="L126">            .model = model,</span>
<span class="line" id="L127">            .features = model.features,</span>
<span class="line" id="L128">        };</span>
<span class="line" id="L129">    }</span>
<span class="line" id="L130">};</span>
<span class="line" id="L131"></span>
<span class="line" id="L132"><span class="tok-kw">const</span> PowerpcCpuinfoParser = CpuinfoParser(PowerpcCpuinfoImpl);</span>
<span class="line" id="L133"></span>
<span class="line" id="L134"><span class="tok-kw">test</span> <span class="tok-str">&quot;cpuinfo: PowerPC&quot;</span> {</span>
<span class="line" id="L135">    <span class="tok-kw">try</span> testParser(PowerpcCpuinfoParser, .powerpc, &amp;Target.powerpc.cpu.@&quot;970&quot;,</span>
<span class="line" id="L136">        <span class="tok-str">\\processor	: 0</span></span>

<span class="line" id="L137">        <span class="tok-str">\\cpu		: PPC970MP, altivec supported</span></span>

<span class="line" id="L138">        <span class="tok-str">\\clock		: 1250.000000MHz</span></span>

<span class="line" id="L139">        <span class="tok-str">\\revision	: 1.1 (pvr 0044 0101)</span></span>

<span class="line" id="L140">    );</span>
<span class="line" id="L141">    <span class="tok-kw">try</span> testParser(PowerpcCpuinfoParser, .powerpc64le, &amp;Target.powerpc.cpu.pwr8,</span>
<span class="line" id="L142">        <span class="tok-str">\\processor	: 0</span></span>

<span class="line" id="L143">        <span class="tok-str">\\cpu		: POWER8 (raw), altivec supported</span></span>

<span class="line" id="L144">        <span class="tok-str">\\clock		: 2926.000000MHz</span></span>

<span class="line" id="L145">        <span class="tok-str">\\revision	: 2.0 (pvr 004d 0200)</span></span>

<span class="line" id="L146">    );</span>
<span class="line" id="L147">}</span>
<span class="line" id="L148"></span>
<span class="line" id="L149"><span class="tok-kw">const</span> ArmCpuinfoImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L150">    cores: [<span class="tok-number">4</span>]CoreInfo = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L151">    core_no: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L152">    have_fields: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L153"></span>
<span class="line" id="L154">    <span class="tok-kw">const</span> CoreInfo = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L155">        architecture: <span class="tok-type">u8</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L156">        implementer: <span class="tok-type">u8</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L157">        variant: <span class="tok-type">u8</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L158">        part: <span class="tok-type">u16</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L159">        is_really_v6: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L160">    };</span>
<span class="line" id="L161"></span>
<span class="line" id="L162">    <span class="tok-kw">const</span> cpu_models = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L163">        <span class="tok-comment">// Shorthands to simplify the tables below.</span>
</span>
<span class="line" id="L164">        <span class="tok-kw">const</span> A32 = Target.arm.cpu;</span>
<span class="line" id="L165">        <span class="tok-kw">const</span> A64 = Target.aarch64.cpu;</span>
<span class="line" id="L166"></span>
<span class="line" id="L167">        <span class="tok-kw">const</span> E = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L168">            part: <span class="tok-type">u16</span>,</span>
<span class="line" id="L169">            variant: ?<span class="tok-type">u8</span> = <span class="tok-null">null</span>, <span class="tok-comment">// null if matches any variant</span>
</span>
<span class="line" id="L170">            m32: ?*<span class="tok-kw">const</span> Target.Cpu.Model = <span class="tok-null">null</span>,</span>
<span class="line" id="L171">            m64: ?*<span class="tok-kw">const</span> Target.Cpu.Model = <span class="tok-null">null</span>,</span>
<span class="line" id="L172">        };</span>
<span class="line" id="L173"></span>
<span class="line" id="L174">        <span class="tok-comment">// implementer = 0x41</span>
</span>
<span class="line" id="L175">        <span class="tok-kw">const</span> ARM = [_]E{</span>
<span class="line" id="L176">            E{ .part = <span class="tok-number">0x926</span>, .m32 = &amp;A32.arm926ej_s, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L177">            E{ .part = <span class="tok-number">0xb02</span>, .m32 = &amp;A32.mpcore, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L178">            E{ .part = <span class="tok-number">0xb36</span>, .m32 = &amp;A32.arm1136j_s, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L179">            E{ .part = <span class="tok-number">0xb56</span>, .m32 = &amp;A32.arm1156t2_s, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L180">            E{ .part = <span class="tok-number">0xb76</span>, .m32 = &amp;A32.arm1176jz_s, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L181">            E{ .part = <span class="tok-number">0xc05</span>, .m32 = &amp;A32.cortex_a5, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L182">            E{ .part = <span class="tok-number">0xc07</span>, .m32 = &amp;A32.cortex_a7, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L183">            E{ .part = <span class="tok-number">0xc08</span>, .m32 = &amp;A32.cortex_a8, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L184">            E{ .part = <span class="tok-number">0xc09</span>, .m32 = &amp;A32.cortex_a9, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L185">            E{ .part = <span class="tok-number">0xc0d</span>, .m32 = &amp;A32.cortex_a17, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L186">            E{ .part = <span class="tok-number">0xc0f</span>, .m32 = &amp;A32.cortex_a15, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L187">            E{ .part = <span class="tok-number">0xc0e</span>, .m32 = &amp;A32.cortex_a17, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L188">            E{ .part = <span class="tok-number">0xc14</span>, .m32 = &amp;A32.cortex_r4, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L189">            E{ .part = <span class="tok-number">0xc15</span>, .m32 = &amp;A32.cortex_r5, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L190">            E{ .part = <span class="tok-number">0xc17</span>, .m32 = &amp;A32.cortex_r7, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L191">            E{ .part = <span class="tok-number">0xc18</span>, .m32 = &amp;A32.cortex_r8, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L192">            E{ .part = <span class="tok-number">0xc20</span>, .m32 = &amp;A32.cortex_m0, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L193">            E{ .part = <span class="tok-number">0xc21</span>, .m32 = &amp;A32.cortex_m1, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L194">            E{ .part = <span class="tok-number">0xc23</span>, .m32 = &amp;A32.cortex_m3, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L195">            E{ .part = <span class="tok-number">0xc24</span>, .m32 = &amp;A32.cortex_m4, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L196">            E{ .part = <span class="tok-number">0xc27</span>, .m32 = &amp;A32.cortex_m7, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L197">            E{ .part = <span class="tok-number">0xc60</span>, .m32 = &amp;A32.cortex_m0plus, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L198">            E{ .part = <span class="tok-number">0xd01</span>, .m32 = &amp;A32.cortex_a32, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L199">            E{ .part = <span class="tok-number">0xd03</span>, .m32 = &amp;A32.cortex_a53, .m64 = &amp;A64.cortex_a53 },</span>
<span class="line" id="L200">            E{ .part = <span class="tok-number">0xd04</span>, .m32 = &amp;A32.cortex_a35, .m64 = &amp;A64.cortex_a35 },</span>
<span class="line" id="L201">            E{ .part = <span class="tok-number">0xd05</span>, .m32 = &amp;A32.cortex_a55, .m64 = &amp;A64.cortex_a55 },</span>
<span class="line" id="L202">            E{ .part = <span class="tok-number">0xd07</span>, .m32 = &amp;A32.cortex_a57, .m64 = &amp;A64.cortex_a57 },</span>
<span class="line" id="L203">            E{ .part = <span class="tok-number">0xd08</span>, .m32 = &amp;A32.cortex_a72, .m64 = &amp;A64.cortex_a72 },</span>
<span class="line" id="L204">            E{ .part = <span class="tok-number">0xd09</span>, .m32 = &amp;A32.cortex_a73, .m64 = &amp;A64.cortex_a73 },</span>
<span class="line" id="L205">            E{ .part = <span class="tok-number">0xd0a</span>, .m32 = &amp;A32.cortex_a75, .m64 = &amp;A64.cortex_a75 },</span>
<span class="line" id="L206">            E{ .part = <span class="tok-number">0xd0b</span>, .m32 = &amp;A32.cortex_a76, .m64 = &amp;A64.cortex_a76 },</span>
<span class="line" id="L207">            E{ .part = <span class="tok-number">0xd0c</span>, .m32 = &amp;A32.neoverse_n1, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L208">            E{ .part = <span class="tok-number">0xd0d</span>, .m32 = &amp;A32.cortex_a77, .m64 = &amp;A64.cortex_a77 },</span>
<span class="line" id="L209">            E{ .part = <span class="tok-number">0xd13</span>, .m32 = &amp;A32.cortex_r52, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L210">            E{ .part = <span class="tok-number">0xd20</span>, .m32 = &amp;A32.cortex_m23, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L211">            E{ .part = <span class="tok-number">0xd21</span>, .m32 = &amp;A32.cortex_m33, .m64 = <span class="tok-null">null</span> },</span>
<span class="line" id="L212">            E{ .part = <span class="tok-number">0xd41</span>, .m32 = &amp;A32.cortex_a78, .m64 = &amp;A64.cortex_a78 },</span>
<span class="line" id="L213">            E{ .part = <span class="tok-number">0xd4b</span>, .m32 = &amp;A32.cortex_a78c, .m64 = &amp;A64.cortex_a78c },</span>
<span class="line" id="L214">            E{ .part = <span class="tok-number">0xd44</span>, .m32 = &amp;A32.cortex_x1, .m64 = &amp;A64.cortex_x1 },</span>
<span class="line" id="L215">            E{ .part = <span class="tok-number">0xd02</span>, .m64 = &amp;A64.cortex_a34 },</span>
<span class="line" id="L216">            E{ .part = <span class="tok-number">0xd06</span>, .m64 = &amp;A64.cortex_a65 },</span>
<span class="line" id="L217">            E{ .part = <span class="tok-number">0xd43</span>, .m64 = &amp;A64.cortex_a65ae },</span>
<span class="line" id="L218">        };</span>
<span class="line" id="L219">        <span class="tok-comment">// implementer = 0x42</span>
</span>
<span class="line" id="L220">        <span class="tok-kw">const</span> Broadcom = [_]E{</span>
<span class="line" id="L221">            E{ .part = <span class="tok-number">0x516</span>, .m64 = &amp;A64.thunderx2t99 },</span>
<span class="line" id="L222">        };</span>
<span class="line" id="L223">        <span class="tok-comment">// implementer = 0x43</span>
</span>
<span class="line" id="L224">        <span class="tok-kw">const</span> Cavium = [_]E{</span>
<span class="line" id="L225">            E{ .part = <span class="tok-number">0x0a0</span>, .m64 = &amp;A64.thunderx },</span>
<span class="line" id="L226">            E{ .part = <span class="tok-number">0x0a2</span>, .m64 = &amp;A64.thunderxt81 },</span>
<span class="line" id="L227">            E{ .part = <span class="tok-number">0x0a3</span>, .m64 = &amp;A64.thunderxt83 },</span>
<span class="line" id="L228">            E{ .part = <span class="tok-number">0x0a1</span>, .m64 = &amp;A64.thunderxt88 },</span>
<span class="line" id="L229">            E{ .part = <span class="tok-number">0x0af</span>, .m64 = &amp;A64.thunderx2t99 },</span>
<span class="line" id="L230">        };</span>
<span class="line" id="L231">        <span class="tok-comment">// implementer = 0x46</span>
</span>
<span class="line" id="L232">        <span class="tok-kw">const</span> Fujitsu = [_]E{</span>
<span class="line" id="L233">            E{ .part = <span class="tok-number">0x001</span>, .m64 = &amp;A64.a64fx },</span>
<span class="line" id="L234">        };</span>
<span class="line" id="L235">        <span class="tok-comment">// implementer = 0x48</span>
</span>
<span class="line" id="L236">        <span class="tok-kw">const</span> HiSilicon = [_]E{</span>
<span class="line" id="L237">            E{ .part = <span class="tok-number">0xd01</span>, .m64 = &amp;A64.tsv110 },</span>
<span class="line" id="L238">        };</span>
<span class="line" id="L239">        <span class="tok-comment">// implementer = 0x4e</span>
</span>
<span class="line" id="L240">        <span class="tok-kw">const</span> Nvidia = [_]E{</span>
<span class="line" id="L241">            E{ .part = <span class="tok-number">0x004</span>, .m64 = &amp;A64.carmel },</span>
<span class="line" id="L242">        };</span>
<span class="line" id="L243">        <span class="tok-comment">// implementer = 0x50</span>
</span>
<span class="line" id="L244">        <span class="tok-kw">const</span> Ampere = [_]E{</span>
<span class="line" id="L245">            E{ .part = <span class="tok-number">0x000</span>, .variant = <span class="tok-number">3</span>, .m64 = &amp;A64.emag },</span>
<span class="line" id="L246">            E{ .part = <span class="tok-number">0x000</span>, .m64 = &amp;A64.xgene1 },</span>
<span class="line" id="L247">        };</span>
<span class="line" id="L248">        <span class="tok-comment">// implementer = 0x51</span>
</span>
<span class="line" id="L249">        <span class="tok-kw">const</span> Qualcomm = [_]E{</span>
<span class="line" id="L250">            E{ .part = <span class="tok-number">0x06f</span>, .m32 = &amp;A32.krait },</span>
<span class="line" id="L251">            E{ .part = <span class="tok-number">0x201</span>, .m64 = &amp;A64.kryo, .m32 = &amp;A64.kryo },</span>
<span class="line" id="L252">            E{ .part = <span class="tok-number">0x205</span>, .m64 = &amp;A64.kryo, .m32 = &amp;A64.kryo },</span>
<span class="line" id="L253">            E{ .part = <span class="tok-number">0x211</span>, .m64 = &amp;A64.kryo, .m32 = &amp;A64.kryo },</span>
<span class="line" id="L254">            E{ .part = <span class="tok-number">0x800</span>, .m64 = &amp;A64.cortex_a73, .m32 = &amp;A64.cortex_a73 },</span>
<span class="line" id="L255">            E{ .part = <span class="tok-number">0x801</span>, .m64 = &amp;A64.cortex_a73, .m32 = &amp;A64.cortex_a73 },</span>
<span class="line" id="L256">            E{ .part = <span class="tok-number">0x802</span>, .m64 = &amp;A64.cortex_a75, .m32 = &amp;A64.cortex_a75 },</span>
<span class="line" id="L257">            E{ .part = <span class="tok-number">0x803</span>, .m64 = &amp;A64.cortex_a75, .m32 = &amp;A64.cortex_a75 },</span>
<span class="line" id="L258">            E{ .part = <span class="tok-number">0x804</span>, .m64 = &amp;A64.cortex_a76, .m32 = &amp;A64.cortex_a76 },</span>
<span class="line" id="L259">            E{ .part = <span class="tok-number">0x805</span>, .m64 = &amp;A64.cortex_a76, .m32 = &amp;A64.cortex_a76 },</span>
<span class="line" id="L260">            E{ .part = <span class="tok-number">0xc00</span>, .m64 = &amp;A64.falkor },</span>
<span class="line" id="L261">            E{ .part = <span class="tok-number">0xc01</span>, .m64 = &amp;A64.saphira },</span>
<span class="line" id="L262">        };</span>
<span class="line" id="L263"></span>
<span class="line" id="L264">        <span class="tok-kw">fn</span> <span class="tok-fn">isKnown</span>(core: CoreInfo, is_64bit: <span class="tok-type">bool</span>) ?*<span class="tok-kw">const</span> Target.Cpu.Model {</span>
<span class="line" id="L265">            <span class="tok-kw">const</span> models = <span class="tok-kw">switch</span> (core.implementer) {</span>
<span class="line" id="L266">                <span class="tok-number">0x41</span> =&gt; &amp;ARM,</span>
<span class="line" id="L267">                <span class="tok-number">0x42</span> =&gt; &amp;Broadcom,</span>
<span class="line" id="L268">                <span class="tok-number">0x43</span> =&gt; &amp;Cavium,</span>
<span class="line" id="L269">                <span class="tok-number">0x46</span> =&gt; &amp;Fujitsu,</span>
<span class="line" id="L270">                <span class="tok-number">0x48</span> =&gt; &amp;HiSilicon,</span>
<span class="line" id="L271">                <span class="tok-number">0x50</span> =&gt; &amp;Ampere,</span>
<span class="line" id="L272">                <span class="tok-number">0x51</span> =&gt; &amp;Qualcomm,</span>
<span class="line" id="L273">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L274">            };</span>
<span class="line" id="L275"></span>
<span class="line" id="L276">            <span class="tok-kw">for</span> (models) |model| {</span>
<span class="line" id="L277">                <span class="tok-kw">if</span> (model.part == core.part <span class="tok-kw">and</span></span>
<span class="line" id="L278">                    (model.variant == <span class="tok-null">null</span> <span class="tok-kw">or</span> model.variant.? == core.variant))</span>
<span class="line" id="L279">                    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (is_64bit) model.m64 <span class="tok-kw">else</span> model.m32;</span>
<span class="line" id="L280">            }</span>
<span class="line" id="L281"></span>
<span class="line" id="L282">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L283">        }</span>
<span class="line" id="L284">    };</span>
<span class="line" id="L285"></span>
<span class="line" id="L286">    <span class="tok-kw">fn</span> <span class="tok-fn">addOne</span>(self: *ArmCpuinfoImpl) <span class="tok-type">void</span> {</span>
<span class="line" id="L287">        <span class="tok-kw">if</span> (self.have_fields == <span class="tok-number">4</span> <span class="tok-kw">and</span> self.core_no &lt; self.cores.len) {</span>
<span class="line" id="L288">            <span class="tok-kw">if</span> (self.core_no &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L289">                <span class="tok-comment">// Deduplicate the core info.</span>
</span>
<span class="line" id="L290">                <span class="tok-kw">for</span> (self.cores[<span class="tok-number">0</span>..self.core_no]) |it| {</span>
<span class="line" id="L291">                    <span class="tok-kw">if</span> (std.meta.eql(it, self.cores[self.core_no]))</span>
<span class="line" id="L292">                        <span class="tok-kw">return</span>;</span>
<span class="line" id="L293">                }</span>
<span class="line" id="L294">            }</span>
<span class="line" id="L295">            self.core_no += <span class="tok-number">1</span>;</span>
<span class="line" id="L296">        }</span>
<span class="line" id="L297">    }</span>
<span class="line" id="L298"></span>
<span class="line" id="L299">    <span class="tok-kw">fn</span> <span class="tok-fn">line_hook</span>(self: *ArmCpuinfoImpl, key: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, value: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">bool</span> {</span>
<span class="line" id="L300">        <span class="tok-kw">const</span> info = &amp;self.cores[self.core_no];</span>
<span class="line" id="L301"></span>
<span class="line" id="L302">        <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, key, <span class="tok-str">&quot;processor&quot;</span>)) {</span>
<span class="line" id="L303">            <span class="tok-comment">// Handle both old-style and new-style cpuinfo formats.</span>
</span>
<span class="line" id="L304">            <span class="tok-comment">// The former prints a sequence of &quot;processor: N&quot; lines for each</span>
</span>
<span class="line" id="L305">            <span class="tok-comment">// core and then the info for the core that's executing this code(!)</span>
</span>
<span class="line" id="L306">            <span class="tok-comment">// while the latter prints the infos for each core right after the</span>
</span>
<span class="line" id="L307">            <span class="tok-comment">// &quot;processor&quot; key.</span>
</span>
<span class="line" id="L308">            self.have_fields = <span class="tok-number">0</span>;</span>
<span class="line" id="L309">            self.cores[self.core_no] = .{};</span>
<span class="line" id="L310">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, key, <span class="tok-str">&quot;CPU implementer&quot;</span>)) {</span>
<span class="line" id="L311">            info.implementer = <span class="tok-kw">try</span> fmt.parseInt(<span class="tok-type">u8</span>, value, <span class="tok-number">0</span>);</span>
<span class="line" id="L312">            self.have_fields += <span class="tok-number">1</span>;</span>
<span class="line" id="L313">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, key, <span class="tok-str">&quot;CPU architecture&quot;</span>)) {</span>
<span class="line" id="L314">            <span class="tok-comment">// &quot;AArch64&quot; on older kernels.</span>
</span>
<span class="line" id="L315">            info.architecture = <span class="tok-kw">if</span> (mem.startsWith(<span class="tok-type">u8</span>, value, <span class="tok-str">&quot;AArch64&quot;</span>))</span>
<span class="line" id="L316">                <span class="tok-number">8</span></span>
<span class="line" id="L317">            <span class="tok-kw">else</span></span>
<span class="line" id="L318">                <span class="tok-kw">try</span> fmt.parseInt(<span class="tok-type">u8</span>, value, <span class="tok-number">0</span>);</span>
<span class="line" id="L319">            self.have_fields += <span class="tok-number">1</span>;</span>
<span class="line" id="L320">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, key, <span class="tok-str">&quot;CPU variant&quot;</span>)) {</span>
<span class="line" id="L321">            info.variant = <span class="tok-kw">try</span> fmt.parseInt(<span class="tok-type">u8</span>, value, <span class="tok-number">0</span>);</span>
<span class="line" id="L322">            self.have_fields += <span class="tok-number">1</span>;</span>
<span class="line" id="L323">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, key, <span class="tok-str">&quot;CPU part&quot;</span>)) {</span>
<span class="line" id="L324">            info.part = <span class="tok-kw">try</span> fmt.parseInt(<span class="tok-type">u16</span>, value, <span class="tok-number">0</span>);</span>
<span class="line" id="L325">            self.have_fields += <span class="tok-number">1</span>;</span>
<span class="line" id="L326">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, key, <span class="tok-str">&quot;model name&quot;</span>)) {</span>
<span class="line" id="L327">            <span class="tok-comment">// ARMv6 cores report &quot;CPU architecture&quot; equal to 7.</span>
</span>
<span class="line" id="L328">            <span class="tok-kw">if</span> (mem.indexOf(<span class="tok-type">u8</span>, value, <span class="tok-str">&quot;(v6l)&quot;</span>)) |_| {</span>
<span class="line" id="L329">                info.is_really_v6 = <span class="tok-null">true</span>;</span>
<span class="line" id="L330">            }</span>
<span class="line" id="L331">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, key, <span class="tok-str">&quot;CPU revision&quot;</span>)) {</span>
<span class="line" id="L332">            <span class="tok-comment">// This field is always the last one for each CPU section.</span>
</span>
<span class="line" id="L333">            _ = self.addOne();</span>
<span class="line" id="L334">        }</span>
<span class="line" id="L335"></span>
<span class="line" id="L336">        <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L337">    }</span>
<span class="line" id="L338"></span>
<span class="line" id="L339">    <span class="tok-kw">fn</span> <span class="tok-fn">finalize</span>(self: *ArmCpuinfoImpl, arch: Target.Cpu.Arch) ?Target.Cpu {</span>
<span class="line" id="L340">        <span class="tok-kw">if</span> (self.core_no == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L341"></span>
<span class="line" id="L342">        <span class="tok-kw">const</span> is_64bit = <span class="tok-kw">switch</span> (arch) {</span>
<span class="line" id="L343">            .aarch64, .aarch64_be, .aarch64_32 =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L344">            <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L345">        };</span>
<span class="line" id="L346"></span>
<span class="line" id="L347">        <span class="tok-kw">var</span> known_models: [self.cores.len]?*<span class="tok-kw">const</span> Target.Cpu.Model = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L348">        <span class="tok-kw">for</span> (self.cores[<span class="tok-number">0</span>..self.core_no]) |core, i| {</span>
<span class="line" id="L349">            known_models[i] = cpu_models.isKnown(core, is_64bit);</span>
<span class="line" id="L350">        }</span>
<span class="line" id="L351"></span>
<span class="line" id="L352">        <span class="tok-comment">// XXX We pick the first core on big.LITTLE systems, hopefully the</span>
</span>
<span class="line" id="L353">        <span class="tok-comment">// LITTLE one.</span>
</span>
<span class="line" id="L354">        <span class="tok-kw">const</span> model = known_models[<span class="tok-number">0</span>] <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L355">        <span class="tok-kw">return</span> Target.Cpu{</span>
<span class="line" id="L356">            .arch = arch,</span>
<span class="line" id="L357">            .model = model,</span>
<span class="line" id="L358">            .features = model.features,</span>
<span class="line" id="L359">        };</span>
<span class="line" id="L360">    }</span>
<span class="line" id="L361">};</span>
<span class="line" id="L362"></span>
<span class="line" id="L363"><span class="tok-kw">const</span> ArmCpuinfoParser = CpuinfoParser(ArmCpuinfoImpl);</span>
<span class="line" id="L364"></span>
<span class="line" id="L365"><span class="tok-kw">test</span> <span class="tok-str">&quot;cpuinfo: ARM&quot;</span> {</span>
<span class="line" id="L366">    <span class="tok-kw">try</span> testParser(ArmCpuinfoParser, .arm, &amp;Target.arm.cpu.arm1176jz_s,</span>
<span class="line" id="L367">        <span class="tok-str">\\processor       : 0</span></span>

<span class="line" id="L368">        <span class="tok-str">\\model name      : ARMv6-compatible processor rev 7 (v6l)</span></span>

<span class="line" id="L369">        <span class="tok-str">\\BogoMIPS        : 997.08</span></span>

<span class="line" id="L370">        <span class="tok-str">\\Features        : half thumb fastmult vfp edsp java tls</span></span>

<span class="line" id="L371">        <span class="tok-str">\\CPU implementer : 0x41</span></span>

<span class="line" id="L372">        <span class="tok-str">\\CPU architecture: 7</span></span>

<span class="line" id="L373">        <span class="tok-str">\\CPU variant     : 0x0</span></span>

<span class="line" id="L374">        <span class="tok-str">\\CPU part        : 0xb76</span></span>

<span class="line" id="L375">        <span class="tok-str">\\CPU revision    : 7</span></span>

<span class="line" id="L376">    );</span>
<span class="line" id="L377">    <span class="tok-kw">try</span> testParser(ArmCpuinfoParser, .arm, &amp;Target.arm.cpu.cortex_a7,</span>
<span class="line" id="L378">        <span class="tok-str">\\processor	: 0</span></span>

<span class="line" id="L379">        <span class="tok-str">\\model name	: ARMv7 Processor rev 3 (v7l)</span></span>

<span class="line" id="L380">        <span class="tok-str">\\BogoMIPS	: 18.00</span></span>

<span class="line" id="L381">        <span class="tok-str">\\Features	: half thumb fastmult vfp edsp neon vfpv3 tls vfpv4 idiva idivt vfpd32 lpae</span></span>

<span class="line" id="L382">        <span class="tok-str">\\CPU implementer	: 0x41</span></span>

<span class="line" id="L383">        <span class="tok-str">\\CPU architecture: 7</span></span>

<span class="line" id="L384">        <span class="tok-str">\\CPU variant	: 0x0</span></span>

<span class="line" id="L385">        <span class="tok-str">\\CPU part	: 0xc07</span></span>

<span class="line" id="L386">        <span class="tok-str">\\CPU revision	: 3</span></span>

<span class="line" id="L387">        <span class="tok-str">\\</span></span>

<span class="line" id="L388">        <span class="tok-str">\\processor	: 4</span></span>

<span class="line" id="L389">        <span class="tok-str">\\model name	: ARMv7 Processor rev 3 (v7l)</span></span>

<span class="line" id="L390">        <span class="tok-str">\\BogoMIPS	: 90.00</span></span>

<span class="line" id="L391">        <span class="tok-str">\\Features	: half thumb fastmult vfp edsp neon vfpv3 tls vfpv4 idiva idivt vfpd32 lpae</span></span>

<span class="line" id="L392">        <span class="tok-str">\\CPU implementer	: 0x41</span></span>

<span class="line" id="L393">        <span class="tok-str">\\CPU architecture: 7</span></span>

<span class="line" id="L394">        <span class="tok-str">\\CPU variant	: 0x2</span></span>

<span class="line" id="L395">        <span class="tok-str">\\CPU part	: 0xc0f</span></span>

<span class="line" id="L396">        <span class="tok-str">\\CPU revision	: 3</span></span>

<span class="line" id="L397">    );</span>
<span class="line" id="L398">    <span class="tok-kw">try</span> testParser(ArmCpuinfoParser, .aarch64, &amp;Target.aarch64.cpu.cortex_a72,</span>
<span class="line" id="L399">        <span class="tok-str">\\processor       : 0</span></span>

<span class="line" id="L400">        <span class="tok-str">\\BogoMIPS        : 108.00</span></span>

<span class="line" id="L401">        <span class="tok-str">\\Features        : fp asimd evtstrm crc32 cpuid</span></span>

<span class="line" id="L402">        <span class="tok-str">\\CPU implementer : 0x41</span></span>

<span class="line" id="L403">        <span class="tok-str">\\CPU architecture: 8</span></span>

<span class="line" id="L404">        <span class="tok-str">\\CPU variant     : 0x0</span></span>

<span class="line" id="L405">        <span class="tok-str">\\CPU part        : 0xd08</span></span>

<span class="line" id="L406">        <span class="tok-str">\\CPU revision    : 3</span></span>

<span class="line" id="L407">    );</span>
<span class="line" id="L408">}</span>
<span class="line" id="L409"></span>
<span class="line" id="L410"><span class="tok-kw">fn</span> <span class="tok-fn">testParser</span>(</span>
<span class="line" id="L411">    parser: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L412">    arch: Target.Cpu.Arch,</span>
<span class="line" id="L413">    expected_model: *<span class="tok-kw">const</span> Target.Cpu.Model,</span>
<span class="line" id="L414">    input: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L415">) !<span class="tok-type">void</span> {</span>
<span class="line" id="L416">    <span class="tok-kw">var</span> fbs = io.fixedBufferStream(input);</span>
<span class="line" id="L417">    <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> parser.parse(arch, fbs.reader());</span>
<span class="line" id="L418">    <span class="tok-kw">try</span> testing.expectEqual(expected_model, result.?.model);</span>
<span class="line" id="L419">    <span class="tok-kw">try</span> testing.expect(expected_model.features.eql(result.?.features));</span>
<span class="line" id="L420">}</span>
<span class="line" id="L421"></span>
<span class="line" id="L422"><span class="tok-comment">// The generic implementation of a /proc/cpuinfo parser.</span>
</span>
<span class="line" id="L423"><span class="tok-comment">// For every line it invokes the line_hook method with the key and value strings</span>
</span>
<span class="line" id="L424"><span class="tok-comment">// as first and second parameters. Returning false from the hook function stops</span>
</span>
<span class="line" id="L425"><span class="tok-comment">// the iteration without raising an error.</span>
</span>
<span class="line" id="L426"><span class="tok-comment">// When all the lines have been analyzed the finalize method is called.</span>
</span>
<span class="line" id="L427"><span class="tok-kw">fn</span> <span class="tok-fn">CpuinfoParser</span>(<span class="tok-kw">comptime</span> impl: <span class="tok-kw">anytype</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L428">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L429">        <span class="tok-kw">fn</span> <span class="tok-fn">parse</span>(arch: Target.Cpu.Arch, reader: <span class="tok-kw">anytype</span>) <span class="tok-type">anyerror</span>!?Target.Cpu {</span>
<span class="line" id="L430">            <span class="tok-kw">var</span> line_buf: [<span class="tok-number">1024</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L431">            <span class="tok-kw">var</span> obj: impl = .{};</span>
<span class="line" id="L432"></span>
<span class="line" id="L433">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L434">                <span class="tok-kw">const</span> line = (<span class="tok-kw">try</span> reader.readUntilDelimiterOrEof(&amp;line_buf, <span class="tok-str">'\n'</span>)) <span class="tok-kw">orelse</span> <span class="tok-kw">break</span>;</span>
<span class="line" id="L435">                <span class="tok-kw">const</span> colon_pos = mem.indexOfScalar(<span class="tok-type">u8</span>, line, <span class="tok-str">':'</span>) <span class="tok-kw">orelse</span> <span class="tok-kw">continue</span>;</span>
<span class="line" id="L436">                <span class="tok-kw">const</span> key = mem.trimRight(<span class="tok-type">u8</span>, line[<span class="tok-number">0</span>..colon_pos], <span class="tok-str">&quot; \t&quot;</span>);</span>
<span class="line" id="L437">                <span class="tok-kw">const</span> value = mem.trimLeft(<span class="tok-type">u8</span>, line[colon_pos + <span class="tok-number">1</span> ..], <span class="tok-str">&quot; \t&quot;</span>);</span>
<span class="line" id="L438"></span>
<span class="line" id="L439">                <span class="tok-kw">if</span> (!<span class="tok-kw">try</span> obj.line_hook(key, value))</span>
<span class="line" id="L440">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L441">            }</span>
<span class="line" id="L442"></span>
<span class="line" id="L443">            <span class="tok-kw">return</span> obj.finalize(arch);</span>
<span class="line" id="L444">        }</span>
<span class="line" id="L445">    };</span>
<span class="line" id="L446">}</span>
<span class="line" id="L447"></span>
<span class="line" id="L448"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">detectNativeCpuAndFeatures</span>() ?Target.Cpu {</span>
<span class="line" id="L449">    <span class="tok-kw">var</span> f = fs.openFileAbsolute(<span class="tok-str">&quot;/proc/cpuinfo&quot;</span>, .{ .intended_io_mode = .blocking }) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L450">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L451">    };</span>
<span class="line" id="L452">    <span class="tok-kw">defer</span> f.close();</span>
<span class="line" id="L453"></span>
<span class="line" id="L454">    <span class="tok-kw">const</span> current_arch = builtin.cpu.arch;</span>
<span class="line" id="L455">    <span class="tok-kw">switch</span> (current_arch) {</span>
<span class="line" id="L456">        .arm, .armeb, .thumb, .thumbeb, .aarch64, .aarch64_be, .aarch64_32 =&gt; {</span>
<span class="line" id="L457">            <span class="tok-kw">return</span> ArmCpuinfoParser.parse(current_arch, f.reader()) <span class="tok-kw">catch</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L458">        },</span>
<span class="line" id="L459">        .sparc64 =&gt; {</span>
<span class="line" id="L460">            <span class="tok-kw">return</span> SparcCpuinfoParser.parse(current_arch, f.reader()) <span class="tok-kw">catch</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L461">        },</span>
<span class="line" id="L462">        .powerpc, .powerpcle, .powerpc64, .powerpc64le =&gt; {</span>
<span class="line" id="L463">            <span class="tok-kw">return</span> PowerpcCpuinfoParser.parse(current_arch, f.reader()) <span class="tok-kw">catch</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L464">        },</span>
<span class="line" id="L465">        <span class="tok-kw">else</span> =&gt; {},</span>
<span class="line" id="L466">    }</span>
<span class="line" id="L467"></span>
<span class="line" id="L468">    <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L469">}</span>
<span class="line" id="L470"></span>
</code></pre></body>
</html>