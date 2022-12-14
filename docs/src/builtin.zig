<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>builtin.zig - source view</title>
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
<span class="line" id="L2"></span>
<span class="line" id="L3"><span class="tok-comment">/// `explicit_subsystem` is missing when the subsystem is automatically detected,</span></span>
<span class="line" id="L4"><span class="tok-comment">/// so Zig standard library has the subsystem detection logic here. This should generally be</span></span>
<span class="line" id="L5"><span class="tok-comment">/// used rather than `explicit_subsystem`.</span></span>
<span class="line" id="L6"><span class="tok-comment">/// On non-Windows targets, this is `null`.</span></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> subsystem: ?std.Target.SubSystem = blk: {</span>
<span class="line" id="L8">    <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(builtin, <span class="tok-str">&quot;explicit_subsystem&quot;</span>)) <span class="tok-kw">break</span> :blk builtin.explicit_subsystem;</span>
<span class="line" id="L9">    <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L10">        .windows =&gt; {</span>
<span class="line" id="L11">            <span class="tok-kw">if</span> (builtin.is_test) {</span>
<span class="line" id="L12">                <span class="tok-kw">break</span> :blk std.Target.SubSystem.Console;</span>
<span class="line" id="L13">            }</span>
<span class="line" id="L14">            <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;main&quot;</span>) <span class="tok-kw">or</span></span>
<span class="line" id="L15">                <span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;WinMain&quot;</span>) <span class="tok-kw">or</span></span>
<span class="line" id="L16">                <span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;wWinMain&quot;</span>) <span class="tok-kw">or</span></span>
<span class="line" id="L17">                <span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;WinMainCRTStartup&quot;</span>) <span class="tok-kw">or</span></span>
<span class="line" id="L18">                <span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;wWinMainCRTStartup&quot;</span>))</span>
<span class="line" id="L19">            {</span>
<span class="line" id="L20">                <span class="tok-kw">break</span> :blk std.Target.SubSystem.Windows;</span>
<span class="line" id="L21">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L22">                <span class="tok-kw">break</span> :blk std.Target.SubSystem.Console;</span>
<span class="line" id="L23">            }</span>
<span class="line" id="L24">        },</span>
<span class="line" id="L25">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">break</span> :blk <span class="tok-null">null</span>,</span>
<span class="line" id="L26">    }</span>
<span class="line" id="L27">};</span>
<span class="line" id="L28"></span>
<span class="line" id="L29"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L30"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> StackTrace = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L32">    index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L33">    instruction_addresses: []<span class="tok-type">usize</span>,</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">format</span>(</span>
<span class="line" id="L36">        self: StackTrace,</span>
<span class="line" id="L37">        <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L38">        options: std.fmt.FormatOptions,</span>
<span class="line" id="L39">        writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L40">    ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L41">        <span class="tok-comment">// TODO: re-evaluate whether to use format() methods at all.</span>
</span>
<span class="line" id="L42">        <span class="tok-comment">// Until then, avoid an error when using GeneralPurposeAllocator with WebAssembly</span>
</span>
<span class="line" id="L43">        <span class="tok-comment">// where it tries to call detectTTYConfig here.</span>
</span>
<span class="line" id="L44">        <span class="tok-kw">if</span> (builtin.os.tag == .freestanding) <span class="tok-kw">return</span>;</span>
<span class="line" id="L45"></span>
<span class="line" id="L46">        _ = fmt;</span>
<span class="line" id="L47">        _ = options;</span>
<span class="line" id="L48">        <span class="tok-kw">var</span> arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);</span>
<span class="line" id="L49">        <span class="tok-kw">defer</span> arena.deinit();</span>
<span class="line" id="L50">        <span class="tok-kw">const</span> debug_info = std.debug.getSelfDebugInfo() <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L51">            <span class="tok-kw">return</span> writer.print(<span class="tok-str">&quot;\nUnable to print stack trace: Unable to open debug info: {s}\n&quot;</span>, .{<span class="tok-builtin">@errorName</span>(err)});</span>
<span class="line" id="L52">        };</span>
<span class="line" id="L53">        <span class="tok-kw">const</span> tty_config = std.debug.detectTTYConfig();</span>
<span class="line" id="L54">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;\n&quot;</span>);</span>
<span class="line" id="L55">        std.debug.writeStackTrace(self, writer, arena.allocator(), debug_info, tty_config) <span class="tok-kw">catch</span> |err| {</span>
<span class="line" id="L56">            <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;Unable to print stack trace: {s}\n&quot;</span>, .{<span class="tok-builtin">@errorName</span>(err)});</span>
<span class="line" id="L57">        };</span>
<span class="line" id="L58">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;\n&quot;</span>);</span>
<span class="line" id="L59">    }</span>
<span class="line" id="L60">};</span>
<span class="line" id="L61"></span>
<span class="line" id="L62"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L63"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L64"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GlobalLinkage = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L65">    Internal,</span>
<span class="line" id="L66">    Strong,</span>
<span class="line" id="L67">    Weak,</span>
<span class="line" id="L68">    LinkOnce,</span>
<span class="line" id="L69">};</span>
<span class="line" id="L70"></span>
<span class="line" id="L71"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L72"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L73"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SymbolVisibility = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L74">    default,</span>
<span class="line" id="L75">    hidden,</span>
<span class="line" id="L76">    protected,</span>
<span class="line" id="L77">};</span>
<span class="line" id="L78"></span>
<span class="line" id="L79"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L80"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L81"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AtomicOrder = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L82">    Unordered,</span>
<span class="line" id="L83">    Monotonic,</span>
<span class="line" id="L84">    Acquire,</span>
<span class="line" id="L85">    Release,</span>
<span class="line" id="L86">    AcqRel,</span>
<span class="line" id="L87">    SeqCst,</span>
<span class="line" id="L88">};</span>
<span class="line" id="L89"></span>
<span class="line" id="L90"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L91"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L92"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ReduceOp = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L93">    And,</span>
<span class="line" id="L94">    Or,</span>
<span class="line" id="L95">    Xor,</span>
<span class="line" id="L96">    Min,</span>
<span class="line" id="L97">    Max,</span>
<span class="line" id="L98">    Add,</span>
<span class="line" id="L99">    Mul,</span>
<span class="line" id="L100">};</span>
<span class="line" id="L101"></span>
<span class="line" id="L102"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L103"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L104"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AtomicRmwOp = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L105">    Xchg,</span>
<span class="line" id="L106">    Add,</span>
<span class="line" id="L107">    Sub,</span>
<span class="line" id="L108">    And,</span>
<span class="line" id="L109">    Nand,</span>
<span class="line" id="L110">    Or,</span>
<span class="line" id="L111">    Xor,</span>
<span class="line" id="L112">    Max,</span>
<span class="line" id="L113">    Min,</span>
<span class="line" id="L114">};</span>
<span class="line" id="L115"></span>
<span class="line" id="L116"><span class="tok-comment">/// The code model puts constraints on the location of symbols and the size of code and data.</span></span>
<span class="line" id="L117"><span class="tok-comment">/// The selection of a code model is a trade off on speed and restrictions that needs to be selected on a per application basis to meet its requirements.</span></span>
<span class="line" id="L118"><span class="tok-comment">/// A slightly more detailed explanation can be found in (for example) the [System V Application Binary Interface (x86_64)](https://github.com/hjl-tools/x86-psABI/wiki/x86-64-psABI-1.0.pdf) 3.5.1.</span></span>
<span class="line" id="L119"><span class="tok-comment">///</span></span>
<span class="line" id="L120"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L121"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L122"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CodeModel = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L123">    default,</span>
<span class="line" id="L124">    tiny,</span>
<span class="line" id="L125">    small,</span>
<span class="line" id="L126">    kernel,</span>
<span class="line" id="L127">    medium,</span>
<span class="line" id="L128">    large,</span>
<span class="line" id="L129">};</span>
<span class="line" id="L130"></span>
<span class="line" id="L131"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L132"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L133"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Mode = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L134">    Debug,</span>
<span class="line" id="L135">    ReleaseSafe,</span>
<span class="line" id="L136">    ReleaseFast,</span>
<span class="line" id="L137">    ReleaseSmall,</span>
<span class="line" id="L138">};</span>
<span class="line" id="L139"></span>
<span class="line" id="L140"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L141"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L142"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CallingConvention = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L143">    Unspecified,</span>
<span class="line" id="L144">    C,</span>
<span class="line" id="L145">    Naked,</span>
<span class="line" id="L146">    Async,</span>
<span class="line" id="L147">    Inline,</span>
<span class="line" id="L148">    Interrupt,</span>
<span class="line" id="L149">    Signal,</span>
<span class="line" id="L150">    Stdcall,</span>
<span class="line" id="L151">    Fastcall,</span>
<span class="line" id="L152">    Vectorcall,</span>
<span class="line" id="L153">    Thiscall,</span>
<span class="line" id="L154">    APCS,</span>
<span class="line" id="L155">    AAPCS,</span>
<span class="line" id="L156">    AAPCSVFP,</span>
<span class="line" id="L157">    SysV,</span>
<span class="line" id="L158">    Win64,</span>
<span class="line" id="L159">    PtxKernel,</span>
<span class="line" id="L160">};</span>
<span class="line" id="L161"></span>
<span class="line" id="L162"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L163"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L164"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AddressSpace = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L165">    generic,</span>
<span class="line" id="L166">    gs,</span>
<span class="line" id="L167">    fs,</span>
<span class="line" id="L168">    ss,</span>
<span class="line" id="L169">    <span class="tok-comment">// GPU address spaces</span>
</span>
<span class="line" id="L170">    global,</span>
<span class="line" id="L171">    constant,</span>
<span class="line" id="L172">    param,</span>
<span class="line" id="L173">    shared,</span>
<span class="line" id="L174">    local,</span>
<span class="line" id="L175">};</span>
<span class="line" id="L176"></span>
<span class="line" id="L177"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L178"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L179"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SourceLocation = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L180">    file: [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L181">    fn_name: [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L182">    line: <span class="tok-type">u32</span>,</span>
<span class="line" id="L183">    column: <span class="tok-type">u32</span>,</span>
<span class="line" id="L184">};</span>
<span class="line" id="L185"></span>
<span class="line" id="L186"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TypeId = std.meta.Tag(Type);</span>
<span class="line" id="L187"></span>
<span class="line" id="L188"><span class="tok-comment">/// TODO deprecated, use `Type`</span></span>
<span class="line" id="L189"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TypeInfo = Type;</span>
<span class="line" id="L190"></span>
<span class="line" id="L191"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L192"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L193"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Type = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L194">    Type: <span class="tok-type">void</span>,</span>
<span class="line" id="L195">    Void: <span class="tok-type">void</span>,</span>
<span class="line" id="L196">    Bool: <span class="tok-type">void</span>,</span>
<span class="line" id="L197">    NoReturn: <span class="tok-type">void</span>,</span>
<span class="line" id="L198">    Int: Int,</span>
<span class="line" id="L199">    Float: Float,</span>
<span class="line" id="L200">    Pointer: Pointer,</span>
<span class="line" id="L201">    Array: Array,</span>
<span class="line" id="L202">    Struct: Struct,</span>
<span class="line" id="L203">    ComptimeFloat: <span class="tok-type">void</span>,</span>
<span class="line" id="L204">    ComptimeInt: <span class="tok-type">void</span>,</span>
<span class="line" id="L205">    Undefined: <span class="tok-type">void</span>,</span>
<span class="line" id="L206">    Null: <span class="tok-type">void</span>,</span>
<span class="line" id="L207">    Optional: Optional,</span>
<span class="line" id="L208">    ErrorUnion: ErrorUnion,</span>
<span class="line" id="L209">    ErrorSet: ErrorSet,</span>
<span class="line" id="L210">    Enum: Enum,</span>
<span class="line" id="L211">    Union: Union,</span>
<span class="line" id="L212">    Fn: Fn,</span>
<span class="line" id="L213">    BoundFn: Fn,</span>
<span class="line" id="L214">    Opaque: Opaque,</span>
<span class="line" id="L215">    Frame: Frame,</span>
<span class="line" id="L216">    AnyFrame: AnyFrame,</span>
<span class="line" id="L217">    Vector: Vector,</span>
<span class="line" id="L218">    EnumLiteral: <span class="tok-type">void</span>,</span>
<span class="line" id="L219"></span>
<span class="line" id="L220">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L221">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L222">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Int = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L223">        signedness: Signedness,</span>
<span class="line" id="L224">        <span class="tok-comment">/// TODO make this u16 instead of comptime_int</span></span>
<span class="line" id="L225">        bits: <span class="tok-type">comptime_int</span>,</span>
<span class="line" id="L226">    };</span>
<span class="line" id="L227"></span>
<span class="line" id="L228">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L229">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L230">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Float = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L231">        <span class="tok-comment">/// TODO make this u16 instead of comptime_int</span></span>
<span class="line" id="L232">        bits: <span class="tok-type">comptime_int</span>,</span>
<span class="line" id="L233">    };</span>
<span class="line" id="L234"></span>
<span class="line" id="L235">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L236">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L237">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Pointer = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L238">        size: Size,</span>
<span class="line" id="L239">        is_const: <span class="tok-type">bool</span>,</span>
<span class="line" id="L240">        is_volatile: <span class="tok-type">bool</span>,</span>
<span class="line" id="L241">        <span class="tok-comment">/// TODO make this u16 instead of comptime_int</span></span>
<span class="line" id="L242">        alignment: <span class="tok-type">comptime_int</span>,</span>
<span class="line" id="L243">        address_space: AddressSpace,</span>
<span class="line" id="L244">        child: <span class="tok-type">type</span>,</span>
<span class="line" id="L245">        is_allowzero: <span class="tok-type">bool</span>,</span>
<span class="line" id="L246"></span>
<span class="line" id="L247">        <span class="tok-comment">/// The type of the sentinel is the element type of the pointer, which is</span></span>
<span class="line" id="L248">        <span class="tok-comment">/// the value of the `child` field in this struct. However there is no way</span></span>
<span class="line" id="L249">        <span class="tok-comment">/// to refer to that type here, so we use pointer to `anyopaque`.</span></span>
<span class="line" id="L250">        sentinel: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L251"></span>
<span class="line" id="L252">        <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L253">        <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L254">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Size = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L255">            One,</span>
<span class="line" id="L256">            Many,</span>
<span class="line" id="L257">            Slice,</span>
<span class="line" id="L258">            C,</span>
<span class="line" id="L259">        };</span>
<span class="line" id="L260">    };</span>
<span class="line" id="L261"></span>
<span class="line" id="L262">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L263">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L264">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Array = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L265">        len: <span class="tok-type">comptime_int</span>,</span>
<span class="line" id="L266">        child: <span class="tok-type">type</span>,</span>
<span class="line" id="L267"></span>
<span class="line" id="L268">        <span class="tok-comment">/// The type of the sentinel is the element type of the array, which is</span></span>
<span class="line" id="L269">        <span class="tok-comment">/// the value of the `child` field in this struct. However there is no way</span></span>
<span class="line" id="L270">        <span class="tok-comment">/// to refer to that type here, so we use pointer to `anyopaque`.</span></span>
<span class="line" id="L271">        sentinel: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L272">    };</span>
<span class="line" id="L273"></span>
<span class="line" id="L274">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L275">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L276">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ContainerLayout = <span class="tok-kw">enum</span>(<span class="tok-type">u2</span>) {</span>
<span class="line" id="L277">        Auto,</span>
<span class="line" id="L278">        Extern,</span>
<span class="line" id="L279">        Packed,</span>
<span class="line" id="L280">    };</span>
<span class="line" id="L281"></span>
<span class="line" id="L282">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L283">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L284">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> StructField = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L285">        name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L286">        <span class="tok-comment">/// TODO rename to `type`</span></span>
<span class="line" id="L287">        field_type: <span class="tok-type">type</span>,</span>
<span class="line" id="L288">        default_value: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L289">        is_comptime: <span class="tok-type">bool</span>,</span>
<span class="line" id="L290">        alignment: <span class="tok-type">comptime_int</span>,</span>
<span class="line" id="L291">    };</span>
<span class="line" id="L292"></span>
<span class="line" id="L293">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L294">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L295">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Struct = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L296">        layout: ContainerLayout,</span>
<span class="line" id="L297">        <span class="tok-comment">/// Only valid if layout is .Packed</span></span>
<span class="line" id="L298">        backing_integer: ?<span class="tok-type">type</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L299">        fields: []<span class="tok-kw">const</span> StructField,</span>
<span class="line" id="L300">        decls: []<span class="tok-kw">const</span> Declaration,</span>
<span class="line" id="L301">        is_tuple: <span class="tok-type">bool</span>,</span>
<span class="line" id="L302">    };</span>
<span class="line" id="L303"></span>
<span class="line" id="L304">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L305">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L306">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Optional = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L307">        child: <span class="tok-type">type</span>,</span>
<span class="line" id="L308">    };</span>
<span class="line" id="L309"></span>
<span class="line" id="L310">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L311">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L312">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ErrorUnion = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L313">        error_set: <span class="tok-type">type</span>,</span>
<span class="line" id="L314">        payload: <span class="tok-type">type</span>,</span>
<span class="line" id="L315">    };</span>
<span class="line" id="L316"></span>
<span class="line" id="L317">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L318">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L319">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L320">        name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L321">    };</span>
<span class="line" id="L322"></span>
<span class="line" id="L323">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L324">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L325">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ErrorSet = ?[]<span class="tok-kw">const</span> Error;</span>
<span class="line" id="L326"></span>
<span class="line" id="L327">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L328">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L329">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EnumField = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L330">        name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L331">        value: <span class="tok-type">comptime_int</span>,</span>
<span class="line" id="L332">    };</span>
<span class="line" id="L333"></span>
<span class="line" id="L334">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L335">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L336">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Enum = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L337">        <span class="tok-comment">/// TODO enums should no longer have this field in type info.</span></span>
<span class="line" id="L338">        layout: ContainerLayout,</span>
<span class="line" id="L339">        tag_type: <span class="tok-type">type</span>,</span>
<span class="line" id="L340">        fields: []<span class="tok-kw">const</span> EnumField,</span>
<span class="line" id="L341">        decls: []<span class="tok-kw">const</span> Declaration,</span>
<span class="line" id="L342">        is_exhaustive: <span class="tok-type">bool</span>,</span>
<span class="line" id="L343">    };</span>
<span class="line" id="L344"></span>
<span class="line" id="L345">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L346">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L347">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UnionField = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L348">        name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L349">        field_type: <span class="tok-type">type</span>,</span>
<span class="line" id="L350">        alignment: <span class="tok-type">comptime_int</span>,</span>
<span class="line" id="L351">    };</span>
<span class="line" id="L352"></span>
<span class="line" id="L353">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L354">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L355">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Union = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L356">        layout: ContainerLayout,</span>
<span class="line" id="L357">        tag_type: ?<span class="tok-type">type</span>,</span>
<span class="line" id="L358">        fields: []<span class="tok-kw">const</span> UnionField,</span>
<span class="line" id="L359">        decls: []<span class="tok-kw">const</span> Declaration,</span>
<span class="line" id="L360">    };</span>
<span class="line" id="L361"></span>
<span class="line" id="L362">    <span class="tok-comment">/// TODO deprecated use Fn.Param</span></span>
<span class="line" id="L363">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FnArg = Fn.Param;</span>
<span class="line" id="L364"></span>
<span class="line" id="L365">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L366">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L367">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Fn = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L368">        calling_convention: CallingConvention,</span>
<span class="line" id="L369">        alignment: <span class="tok-type">comptime_int</span>,</span>
<span class="line" id="L370">        is_generic: <span class="tok-type">bool</span>,</span>
<span class="line" id="L371">        is_var_args: <span class="tok-type">bool</span>,</span>
<span class="line" id="L372">        <span class="tok-comment">/// TODO change the language spec to make this not optional.</span></span>
<span class="line" id="L373">        return_type: ?<span class="tok-type">type</span>,</span>
<span class="line" id="L374">        args: []<span class="tok-kw">const</span> Param,</span>
<span class="line" id="L375"></span>
<span class="line" id="L376">        <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L377">        <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L378">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Param = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L379">            is_generic: <span class="tok-type">bool</span>,</span>
<span class="line" id="L380">            is_noalias: <span class="tok-type">bool</span>,</span>
<span class="line" id="L381">            arg_type: ?<span class="tok-type">type</span>,</span>
<span class="line" id="L382">        };</span>
<span class="line" id="L383">    };</span>
<span class="line" id="L384"></span>
<span class="line" id="L385">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L386">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L387">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Opaque = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L388">        decls: []<span class="tok-kw">const</span> Declaration,</span>
<span class="line" id="L389">    };</span>
<span class="line" id="L390"></span>
<span class="line" id="L391">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L392">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L393">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Frame = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L394">        function: *<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L395">    };</span>
<span class="line" id="L396"></span>
<span class="line" id="L397">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L398">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L399">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> AnyFrame = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L400">        child: ?<span class="tok-type">type</span>,</span>
<span class="line" id="L401">    };</span>
<span class="line" id="L402"></span>
<span class="line" id="L403">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L404">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L405">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Vector = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L406">        len: <span class="tok-type">comptime_int</span>,</span>
<span class="line" id="L407">        child: <span class="tok-type">type</span>,</span>
<span class="line" id="L408">    };</span>
<span class="line" id="L409"></span>
<span class="line" id="L410">    <span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L411">    <span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L412">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Declaration = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L413">        name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L414">        is_pub: <span class="tok-type">bool</span>,</span>
<span class="line" id="L415">    };</span>
<span class="line" id="L416">};</span>
<span class="line" id="L417"></span>
<span class="line" id="L418"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L419"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L420"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FloatMode = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L421">    Strict,</span>
<span class="line" id="L422">    Optimized,</span>
<span class="line" id="L423">};</span>
<span class="line" id="L424"></span>
<span class="line" id="L425"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L426"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L427"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Endian = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L428">    Big,</span>
<span class="line" id="L429">    Little,</span>
<span class="line" id="L430">};</span>
<span class="line" id="L431"></span>
<span class="line" id="L432"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L433"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L434"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Signedness = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L435">    signed,</span>
<span class="line" id="L436">    unsigned,</span>
<span class="line" id="L437">};</span>
<span class="line" id="L438"></span>
<span class="line" id="L439"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L440"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L441"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OutputMode = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L442">    Exe,</span>
<span class="line" id="L443">    Lib,</span>
<span class="line" id="L444">    Obj,</span>
<span class="line" id="L445">};</span>
<span class="line" id="L446"></span>
<span class="line" id="L447"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L448"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L449"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LinkMode = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L450">    Static,</span>
<span class="line" id="L451">    Dynamic,</span>
<span class="line" id="L452">};</span>
<span class="line" id="L453"></span>
<span class="line" id="L454"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L455"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L456"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WasiExecModel = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L457">    command,</span>
<span class="line" id="L458">    reactor,</span>
<span class="line" id="L459">};</span>
<span class="line" id="L460"></span>
<span class="line" id="L461"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L462"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L463"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Version = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L464">    major: <span class="tok-type">u32</span>,</span>
<span class="line" id="L465">    minor: <span class="tok-type">u32</span>,</span>
<span class="line" id="L466">    patch: <span class="tok-type">u32</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L467"></span>
<span class="line" id="L468">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Range = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L469">        min: Version,</span>
<span class="line" id="L470">        max: Version,</span>
<span class="line" id="L471"></span>
<span class="line" id="L472">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">includesVersion</span>(self: Range, ver: Version) <span class="tok-type">bool</span> {</span>
<span class="line" id="L473">            <span class="tok-kw">if</span> (self.min.order(ver) == .gt) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L474">            <span class="tok-kw">if</span> (self.max.order(ver) == .lt) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L475">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L476">        }</span>
<span class="line" id="L477"></span>
<span class="line" id="L478">        <span class="tok-comment">/// Checks if system is guaranteed to be at least `version` or older than `version`.</span></span>
<span class="line" id="L479">        <span class="tok-comment">/// Returns `null` if a runtime check is required.</span></span>
<span class="line" id="L480">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">isAtLeast</span>(self: Range, ver: Version) ?<span class="tok-type">bool</span> {</span>
<span class="line" id="L481">            <span class="tok-kw">if</span> (self.min.order(ver) != .lt) <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L482">            <span class="tok-kw">if</span> (self.max.order(ver) == .lt) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L483">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L484">        }</span>
<span class="line" id="L485">    };</span>
<span class="line" id="L486"></span>
<span class="line" id="L487">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">order</span>(lhs: Version, rhs: Version) std.math.Order {</span>
<span class="line" id="L488">        <span class="tok-kw">if</span> (lhs.major &lt; rhs.major) <span class="tok-kw">return</span> .lt;</span>
<span class="line" id="L489">        <span class="tok-kw">if</span> (lhs.major &gt; rhs.major) <span class="tok-kw">return</span> .gt;</span>
<span class="line" id="L490">        <span class="tok-kw">if</span> (lhs.minor &lt; rhs.minor) <span class="tok-kw">return</span> .lt;</span>
<span class="line" id="L491">        <span class="tok-kw">if</span> (lhs.minor &gt; rhs.minor) <span class="tok-kw">return</span> .gt;</span>
<span class="line" id="L492">        <span class="tok-kw">if</span> (lhs.patch &lt; rhs.patch) <span class="tok-kw">return</span> .lt;</span>
<span class="line" id="L493">        <span class="tok-kw">if</span> (lhs.patch &gt; rhs.patch) <span class="tok-kw">return</span> .gt;</span>
<span class="line" id="L494">        <span class="tok-kw">return</span> .eq;</span>
<span class="line" id="L495">    }</span>
<span class="line" id="L496"></span>
<span class="line" id="L497">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parse</span>(text: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !Version {</span>
<span class="line" id="L498">        <span class="tok-kw">var</span> end: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L499">        <span class="tok-kw">while</span> (end &lt; text.len) : (end += <span class="tok-number">1</span>) {</span>
<span class="line" id="L500">            <span class="tok-kw">const</span> c = text[end];</span>
<span class="line" id="L501">            <span class="tok-kw">if</span> (!std.ascii.isDigit(c) <span class="tok-kw">and</span> c != <span class="tok-str">'.'</span>) <span class="tok-kw">break</span>;</span>
<span class="line" id="L502">        }</span>
<span class="line" id="L503">        <span class="tok-comment">// found no digits or '.' before unexpected character</span>
</span>
<span class="line" id="L504">        <span class="tok-kw">if</span> (end == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidVersion;</span>
<span class="line" id="L505"></span>
<span class="line" id="L506">        <span class="tok-kw">var</span> it = std.mem.split(<span class="tok-type">u8</span>, text[<span class="tok-number">0</span>..end], <span class="tok-str">&quot;.&quot;</span>);</span>
<span class="line" id="L507">        <span class="tok-comment">// substring is not empty, first call will succeed</span>
</span>
<span class="line" id="L508">        <span class="tok-kw">const</span> major = it.first();</span>
<span class="line" id="L509">        <span class="tok-kw">if</span> (major.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidVersion;</span>
<span class="line" id="L510">        <span class="tok-kw">const</span> minor = it.next() <span class="tok-kw">orelse</span> <span class="tok-str">&quot;0&quot;</span>;</span>
<span class="line" id="L511">        <span class="tok-comment">// ignore 'patch' if 'minor' is invalid</span>
</span>
<span class="line" id="L512">        <span class="tok-kw">const</span> patch = <span class="tok-kw">if</span> (minor.len == <span class="tok-number">0</span>) <span class="tok-str">&quot;0&quot;</span> <span class="tok-kw">else</span> (it.next() <span class="tok-kw">orelse</span> <span class="tok-str">&quot;0&quot;</span>);</span>
<span class="line" id="L513"></span>
<span class="line" id="L514">        <span class="tok-kw">return</span> Version{</span>
<span class="line" id="L515">            .major = <span class="tok-kw">try</span> std.fmt.parseUnsigned(<span class="tok-type">u32</span>, major, <span class="tok-number">10</span>),</span>
<span class="line" id="L516">            .minor = <span class="tok-kw">try</span> std.fmt.parseUnsigned(<span class="tok-type">u32</span>, <span class="tok-kw">if</span> (minor.len == <span class="tok-number">0</span>) <span class="tok-str">&quot;0&quot;</span> <span class="tok-kw">else</span> minor, <span class="tok-number">10</span>),</span>
<span class="line" id="L517">            .patch = <span class="tok-kw">try</span> std.fmt.parseUnsigned(<span class="tok-type">u32</span>, <span class="tok-kw">if</span> (patch.len == <span class="tok-number">0</span>) <span class="tok-str">&quot;0&quot;</span> <span class="tok-kw">else</span> patch, <span class="tok-number">10</span>),</span>
<span class="line" id="L518">        };</span>
<span class="line" id="L519">    }</span>
<span class="line" id="L520"></span>
<span class="line" id="L521">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">format</span>(</span>
<span class="line" id="L522">        self: Version,</span>
<span class="line" id="L523">        <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L524">        options: std.fmt.FormatOptions,</span>
<span class="line" id="L525">        out_stream: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L526">    ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L527">        _ = options;</span>
<span class="line" id="L528">        <span class="tok-kw">if</span> (fmt.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L529">            <span class="tok-kw">if</span> (self.patch == <span class="tok-number">0</span>) {</span>
<span class="line" id="L530">                <span class="tok-kw">if</span> (self.minor == <span class="tok-number">0</span>) {</span>
<span class="line" id="L531">                    <span class="tok-kw">return</span> std.fmt.format(out_stream, <span class="tok-str">&quot;{d}&quot;</span>, .{self.major});</span>
<span class="line" id="L532">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L533">                    <span class="tok-kw">return</span> std.fmt.format(out_stream, <span class="tok-str">&quot;{d}.{d}&quot;</span>, .{ self.major, self.minor });</span>
<span class="line" id="L534">                }</span>
<span class="line" id="L535">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L536">                <span class="tok-kw">return</span> std.fmt.format(out_stream, <span class="tok-str">&quot;{d}.{d}.{d}&quot;</span>, .{ self.major, self.minor, self.patch });</span>
<span class="line" id="L537">            }</span>
<span class="line" id="L538">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L539">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Unknown format string: '&quot;</span> ++ fmt ++ <span class="tok-str">&quot;'&quot;</span>);</span>
<span class="line" id="L540">        }</span>
<span class="line" id="L541">    }</span>
<span class="line" id="L542">};</span>
<span class="line" id="L543"></span>
<span class="line" id="L544"><span class="tok-kw">test</span> <span class="tok-str">&quot;Version.parse&quot;</span> {</span>
<span class="line" id="L545">    <span class="tok-builtin">@setEvalBranchQuota</span>(<span class="tok-number">3000</span>);</span>
<span class="line" id="L546">    <span class="tok-kw">try</span> testVersionParse();</span>
<span class="line" id="L547">    <span class="tok-kw">comptime</span> (<span class="tok-kw">try</span> testVersionParse());</span>
<span class="line" id="L548">}</span>
<span class="line" id="L549"></span>
<span class="line" id="L550"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">testVersionParse</span>() !<span class="tok-type">void</span> {</span>
<span class="line" id="L551">    <span class="tok-kw">const</span> f = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L552">        <span class="tok-kw">fn</span> <span class="tok-fn">eql</span>(text: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, v1: <span class="tok-type">u32</span>, v2: <span class="tok-type">u32</span>, v3: <span class="tok-type">u32</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L553">            <span class="tok-kw">const</span> v = <span class="tok-kw">try</span> Version.parse(text);</span>
<span class="line" id="L554">            <span class="tok-kw">try</span> std.testing.expect(v.major == v1 <span class="tok-kw">and</span> v.minor == v2 <span class="tok-kw">and</span> v.patch == v3);</span>
<span class="line" id="L555">        }</span>
<span class="line" id="L556"></span>
<span class="line" id="L557">        <span class="tok-kw">fn</span> <span class="tok-fn">err</span>(text: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, expected_err: <span class="tok-type">anyerror</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L558">            _ = Version.parse(text) <span class="tok-kw">catch</span> |actual_err| {</span>
<span class="line" id="L559">                <span class="tok-kw">if</span> (actual_err == expected_err) <span class="tok-kw">return</span>;</span>
<span class="line" id="L560">                <span class="tok-kw">return</span> actual_err;</span>
<span class="line" id="L561">            };</span>
<span class="line" id="L562">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unreachable;</span>
<span class="line" id="L563">        }</span>
<span class="line" id="L564">    };</span>
<span class="line" id="L565"></span>
<span class="line" id="L566">    <span class="tok-kw">try</span> f.eql(<span class="tok-str">&quot;2.6.32.11-svn21605&quot;</span>, <span class="tok-number">2</span>, <span class="tok-number">6</span>, <span class="tok-number">32</span>); <span class="tok-comment">// Debian PPC</span>
</span>
<span class="line" id="L567">    <span class="tok-kw">try</span> f.eql(<span class="tok-str">&quot;2.11.2(0.329/5/3)&quot;</span>, <span class="tok-number">2</span>, <span class="tok-number">11</span>, <span class="tok-number">2</span>); <span class="tok-comment">// MinGW</span>
</span>
<span class="line" id="L568">    <span class="tok-kw">try</span> f.eql(<span class="tok-str">&quot;5.4.0-1018-raspi&quot;</span>, <span class="tok-number">5</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>); <span class="tok-comment">// Ubuntu</span>
</span>
<span class="line" id="L569">    <span class="tok-kw">try</span> f.eql(<span class="tok-str">&quot;5.7.12_3&quot;</span>, <span class="tok-number">5</span>, <span class="tok-number">7</span>, <span class="tok-number">12</span>); <span class="tok-comment">// Void</span>
</span>
<span class="line" id="L570">    <span class="tok-kw">try</span> f.eql(<span class="tok-str">&quot;2.13-DEVELOPMENT&quot;</span>, <span class="tok-number">2</span>, <span class="tok-number">13</span>, <span class="tok-number">0</span>); <span class="tok-comment">// DragonFly</span>
</span>
<span class="line" id="L571">    <span class="tok-kw">try</span> f.eql(<span class="tok-str">&quot;2.3-35&quot;</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L572">    <span class="tok-kw">try</span> f.eql(<span class="tok-str">&quot;1a.4&quot;</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L573">    <span class="tok-kw">try</span> f.eql(<span class="tok-str">&quot;3.b1.0&quot;</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L574">    <span class="tok-kw">try</span> f.eql(<span class="tok-str">&quot;1.4beta&quot;</span>, <span class="tok-number">1</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L575">    <span class="tok-kw">try</span> f.eql(<span class="tok-str">&quot;2.7.pre&quot;</span>, <span class="tok-number">2</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L576">    <span class="tok-kw">try</span> f.eql(<span class="tok-str">&quot;0..3&quot;</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L577">    <span class="tok-kw">try</span> f.eql(<span class="tok-str">&quot;8.008.&quot;</span>, <span class="tok-number">8</span>, <span class="tok-number">8</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L578">    <span class="tok-kw">try</span> f.eql(<span class="tok-str">&quot;01...&quot;</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L579">    <span class="tok-kw">try</span> f.eql(<span class="tok-str">&quot;55&quot;</span>, <span class="tok-number">55</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L580">    <span class="tok-kw">try</span> f.eql(<span class="tok-str">&quot;4294967295.0.1&quot;</span>, <span class="tok-number">4294967295</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>);</span>
<span class="line" id="L581">    <span class="tok-kw">try</span> f.eql(<span class="tok-str">&quot;429496729_6&quot;</span>, <span class="tok-number">429496729</span>, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L582"></span>
<span class="line" id="L583">    <span class="tok-kw">try</span> f.err(<span class="tok-str">&quot;foobar&quot;</span>, <span class="tok-kw">error</span>.InvalidVersion);</span>
<span class="line" id="L584">    <span class="tok-kw">try</span> f.err(<span class="tok-str">&quot;&quot;</span>, <span class="tok-kw">error</span>.InvalidVersion);</span>
<span class="line" id="L585">    <span class="tok-kw">try</span> f.err(<span class="tok-str">&quot;-1&quot;</span>, <span class="tok-kw">error</span>.InvalidVersion);</span>
<span class="line" id="L586">    <span class="tok-kw">try</span> f.err(<span class="tok-str">&quot;+4&quot;</span>, <span class="tok-kw">error</span>.InvalidVersion);</span>
<span class="line" id="L587">    <span class="tok-kw">try</span> f.err(<span class="tok-str">&quot;.&quot;</span>, <span class="tok-kw">error</span>.InvalidVersion);</span>
<span class="line" id="L588">    <span class="tok-kw">try</span> f.err(<span class="tok-str">&quot;....3&quot;</span>, <span class="tok-kw">error</span>.InvalidVersion);</span>
<span class="line" id="L589">    <span class="tok-kw">try</span> f.err(<span class="tok-str">&quot;4294967296&quot;</span>, <span class="tok-kw">error</span>.Overflow);</span>
<span class="line" id="L590">    <span class="tok-kw">try</span> f.err(<span class="tok-str">&quot;5000877755&quot;</span>, <span class="tok-kw">error</span>.Overflow);</span>
<span class="line" id="L591">    <span class="tok-comment">// error.InvalidCharacter is not possible anymore</span>
</span>
<span class="line" id="L592">}</span>
<span class="line" id="L593"></span>
<span class="line" id="L594"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L595"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L596"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CallOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L597">    modifier: Modifier = .auto,</span>
<span class="line" id="L598"></span>
<span class="line" id="L599">    <span class="tok-comment">/// Only valid when `Modifier` is `Modifier.async_kw`.</span></span>
<span class="line" id="L600">    stack: ?[]<span class="tok-kw">align</span>(std.Target.stack_align) <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L601"></span>
<span class="line" id="L602">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Modifier = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L603">        <span class="tok-comment">/// Equivalent to function call syntax.</span></span>
<span class="line" id="L604">        auto,</span>
<span class="line" id="L605"></span>
<span class="line" id="L606">        <span class="tok-comment">/// Equivalent to async keyword used with function call syntax.</span></span>
<span class="line" id="L607">        async_kw,</span>
<span class="line" id="L608"></span>
<span class="line" id="L609">        <span class="tok-comment">/// Prevents tail call optimization. This guarantees that the return</span></span>
<span class="line" id="L610">        <span class="tok-comment">/// address will point to the callsite, as opposed to the callsite's</span></span>
<span class="line" id="L611">        <span class="tok-comment">/// callsite. If the call is otherwise required to be tail-called</span></span>
<span class="line" id="L612">        <span class="tok-comment">/// or inlined, a compile error is emitted instead.</span></span>
<span class="line" id="L613">        never_tail,</span>
<span class="line" id="L614"></span>
<span class="line" id="L615">        <span class="tok-comment">/// Guarantees that the call will not be inlined. If the call is</span></span>
<span class="line" id="L616">        <span class="tok-comment">/// otherwise required to be inlined, a compile error is emitted instead.</span></span>
<span class="line" id="L617">        never_inline,</span>
<span class="line" id="L618"></span>
<span class="line" id="L619">        <span class="tok-comment">/// Asserts that the function call will not suspend. This allows a</span></span>
<span class="line" id="L620">        <span class="tok-comment">/// non-async function to call an async function.</span></span>
<span class="line" id="L621">        no_async,</span>
<span class="line" id="L622"></span>
<span class="line" id="L623">        <span class="tok-comment">/// Guarantees that the call will be generated with tail call optimization.</span></span>
<span class="line" id="L624">        <span class="tok-comment">/// If this is not possible, a compile error is emitted instead.</span></span>
<span class="line" id="L625">        always_tail,</span>
<span class="line" id="L626"></span>
<span class="line" id="L627">        <span class="tok-comment">/// Guarantees that the call will inlined at the callsite.</span></span>
<span class="line" id="L628">        <span class="tok-comment">/// If this is not possible, a compile error is emitted instead.</span></span>
<span class="line" id="L629">        always_inline,</span>
<span class="line" id="L630"></span>
<span class="line" id="L631">        <span class="tok-comment">/// Evaluates the call at compile-time. If the call cannot be completed at</span></span>
<span class="line" id="L632">        <span class="tok-comment">/// compile-time, a compile error is emitted instead.</span></span>
<span class="line" id="L633">        compile_time,</span>
<span class="line" id="L634">    };</span>
<span class="line" id="L635">};</span>
<span class="line" id="L636"></span>
<span class="line" id="L637"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L638"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L639"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PrefetchOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L640">    <span class="tok-comment">/// Whether the prefetch should prepare for a read or a write.</span></span>
<span class="line" id="L641">    rw: Rw = .read,</span>
<span class="line" id="L642">    <span class="tok-comment">/// 0 means no temporal locality. That is, the data can be immediately</span></span>
<span class="line" id="L643">    <span class="tok-comment">/// dropped from the cache after it is accessed.</span></span>
<span class="line" id="L644">    <span class="tok-comment">///</span></span>
<span class="line" id="L645">    <span class="tok-comment">/// 3 means high temporal locality. That is, the data should be kept in</span></span>
<span class="line" id="L646">    <span class="tok-comment">/// the cache as it is likely to be accessed again soon.</span></span>
<span class="line" id="L647">    locality: <span class="tok-type">u2</span> = <span class="tok-number">3</span>,</span>
<span class="line" id="L648">    <span class="tok-comment">/// The cache that the prefetch should be preformed on.</span></span>
<span class="line" id="L649">    cache: Cache = .data,</span>
<span class="line" id="L650"></span>
<span class="line" id="L651">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Rw = <span class="tok-kw">enum</span>(<span class="tok-type">u1</span>) {</span>
<span class="line" id="L652">        read,</span>
<span class="line" id="L653">        write,</span>
<span class="line" id="L654">    };</span>
<span class="line" id="L655"></span>
<span class="line" id="L656">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Cache = <span class="tok-kw">enum</span>(<span class="tok-type">u1</span>) {</span>
<span class="line" id="L657">        instruction,</span>
<span class="line" id="L658">        data,</span>
<span class="line" id="L659">    };</span>
<span class="line" id="L660">};</span>
<span class="line" id="L661"></span>
<span class="line" id="L662"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L663"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L664"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ExportOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L665">    name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L666">    linkage: GlobalLinkage = .Strong,</span>
<span class="line" id="L667">    section: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L668">    visibility: SymbolVisibility = .default,</span>
<span class="line" id="L669">};</span>
<span class="line" id="L670"></span>
<span class="line" id="L671"><span class="tok-comment">/// This data structure is used by the Zig language code generation and</span></span>
<span class="line" id="L672"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L673"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ExternOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L674">    name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L675">    library_name: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L676">    linkage: GlobalLinkage = .Strong,</span>
<span class="line" id="L677">    is_thread_local: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L678">};</span>
<span class="line" id="L679"></span>
<span class="line" id="L680"><span class="tok-comment">/// This enum is set by the compiler and communicates which compiler backend is</span></span>
<span class="line" id="L681"><span class="tok-comment">/// used to produce machine code.</span></span>
<span class="line" id="L682"><span class="tok-comment">/// Think carefully before deciding to observe this value. Nearly all code should</span></span>
<span class="line" id="L683"><span class="tok-comment">/// be agnostic to the backend that implements the language. The use case</span></span>
<span class="line" id="L684"><span class="tok-comment">/// to use this value is to **work around problems with compiler implementations.**</span></span>
<span class="line" id="L685"><span class="tok-comment">///</span></span>
<span class="line" id="L686"><span class="tok-comment">/// Avoid failing the compilation if the compiler backend does not match a</span></span>
<span class="line" id="L687"><span class="tok-comment">/// whitelist of backends; rather one should detect that a known problem would</span></span>
<span class="line" id="L688"><span class="tok-comment">/// occur in a blacklist of backends.</span></span>
<span class="line" id="L689"><span class="tok-comment">///</span></span>
<span class="line" id="L690"><span class="tok-comment">/// The enum is nonexhaustive so that alternate Zig language implementations may</span></span>
<span class="line" id="L691"><span class="tok-comment">/// choose a number as their tag (please use a random number generator rather</span></span>
<span class="line" id="L692"><span class="tok-comment">/// than a &quot;cute&quot; number) and codebases can interact with these values even if</span></span>
<span class="line" id="L693"><span class="tok-comment">/// this upstream enum does not have a name for the number. Of course, upstream</span></span>
<span class="line" id="L694"><span class="tok-comment">/// is happy to accept pull requests to add Zig implementations to this enum.</span></span>
<span class="line" id="L695"><span class="tok-comment">///</span></span>
<span class="line" id="L696"><span class="tok-comment">/// This data structure is part of the Zig language specification.</span></span>
<span class="line" id="L697"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CompilerBackend = <span class="tok-kw">enum</span>(<span class="tok-type">u64</span>) {</span>
<span class="line" id="L698">    <span class="tok-comment">/// It is allowed for a compiler implementation to not reveal its identity,</span></span>
<span class="line" id="L699">    <span class="tok-comment">/// in which case this value is appropriate. Be cool and make sure your</span></span>
<span class="line" id="L700">    <span class="tok-comment">/// code supports `other` Zig compilers!</span></span>
<span class="line" id="L701">    other = <span class="tok-number">0</span>,</span>
<span class="line" id="L702">    <span class="tok-comment">/// The original Zig compiler created in 2015 by Andrew Kelley.</span></span>
<span class="line" id="L703">    <span class="tok-comment">/// Implemented in C++. Uses LLVM.</span></span>
<span class="line" id="L704">    stage1 = <span class="tok-number">1</span>,</span>
<span class="line" id="L705">    <span class="tok-comment">/// The reference implementation self-hosted compiler of Zig, using the</span></span>
<span class="line" id="L706">    <span class="tok-comment">/// LLVM backend.</span></span>
<span class="line" id="L707">    stage2_llvm = <span class="tok-number">2</span>,</span>
<span class="line" id="L708">    <span class="tok-comment">/// The reference implementation self-hosted compiler of Zig, using the</span></span>
<span class="line" id="L709">    <span class="tok-comment">/// backend that generates C source code.</span></span>
<span class="line" id="L710">    <span class="tok-comment">/// Note that one can observe whether the compilation will output C code</span></span>
<span class="line" id="L711">    <span class="tok-comment">/// directly with `object_format` value rather than the `compiler_backend` value.</span></span>
<span class="line" id="L712">    stage2_c = <span class="tok-number">3</span>,</span>
<span class="line" id="L713">    <span class="tok-comment">/// The reference implementation self-hosted compiler of Zig, using the</span></span>
<span class="line" id="L714">    <span class="tok-comment">/// WebAssembly backend.</span></span>
<span class="line" id="L715">    stage2_wasm = <span class="tok-number">4</span>,</span>
<span class="line" id="L716">    <span class="tok-comment">/// The reference implementation self-hosted compiler of Zig, using the</span></span>
<span class="line" id="L717">    <span class="tok-comment">/// arm backend.</span></span>
<span class="line" id="L718">    stage2_arm = <span class="tok-number">5</span>,</span>
<span class="line" id="L719">    <span class="tok-comment">/// The reference implementation self-hosted compiler of Zig, using the</span></span>
<span class="line" id="L720">    <span class="tok-comment">/// x86_64 backend.</span></span>
<span class="line" id="L721">    stage2_x86_64 = <span class="tok-number">6</span>,</span>
<span class="line" id="L722">    <span class="tok-comment">/// The reference implementation self-hosted compiler of Zig, using the</span></span>
<span class="line" id="L723">    <span class="tok-comment">/// aarch64 backend.</span></span>
<span class="line" id="L724">    stage2_aarch64 = <span class="tok-number">7</span>,</span>
<span class="line" id="L725">    <span class="tok-comment">/// The reference implementation self-hosted compiler of Zig, using the</span></span>
<span class="line" id="L726">    <span class="tok-comment">/// x86 backend.</span></span>
<span class="line" id="L727">    stage2_x86 = <span class="tok-number">8</span>,</span>
<span class="line" id="L728">    <span class="tok-comment">/// The reference implementation self-hosted compiler of Zig, using the</span></span>
<span class="line" id="L729">    <span class="tok-comment">/// riscv64 backend.</span></span>
<span class="line" id="L730">    stage2_riscv64 = <span class="tok-number">9</span>,</span>
<span class="line" id="L731">    <span class="tok-comment">/// The reference implementation self-hosted compiler of Zig, using the</span></span>
<span class="line" id="L732">    <span class="tok-comment">/// sparc64 backend.</span></span>
<span class="line" id="L733">    stage2_sparc64 = <span class="tok-number">10</span>,</span>
<span class="line" id="L734"></span>
<span class="line" id="L735">    _,</span>
<span class="line" id="L736">};</span>
<span class="line" id="L737"></span>
<span class="line" id="L738"><span class="tok-comment">/// This function type is used by the Zig language code generation and</span></span>
<span class="line" id="L739"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L740"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TestFn = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L741">    name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L742">    func: testFnProto,</span>
<span class="line" id="L743">    async_frame_size: ?<span class="tok-type">usize</span>,</span>
<span class="line" id="L744">};</span>
<span class="line" id="L745"></span>
<span class="line" id="L746"><span class="tok-comment">/// stage1 is *wrong*. It is not yet updated to support the new function type semantics.</span></span>
<span class="line" id="L747"><span class="tok-kw">const</span> testFnProto = <span class="tok-kw">switch</span> (builtin.zig_backend) {</span>
<span class="line" id="L748">    .stage1 =&gt; <span class="tok-kw">fn</span> () <span class="tok-type">anyerror</span>!<span class="tok-type">void</span>, <span class="tok-comment">// wrong!</span>
</span>
<span class="line" id="L749">    <span class="tok-kw">else</span> =&gt; *<span class="tok-kw">const</span> <span class="tok-kw">fn</span> () <span class="tok-type">anyerror</span>!<span class="tok-type">void</span>,</span>
<span class="line" id="L750">};</span>
<span class="line" id="L751"></span>
<span class="line" id="L752"><span class="tok-comment">/// This function type is used by the Zig language code generation and</span></span>
<span class="line" id="L753"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L754"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PanicFn = <span class="tok-kw">fn</span> ([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, ?*StackTrace) <span class="tok-type">noreturn</span>;</span>
<span class="line" id="L755"></span>
<span class="line" id="L756"><span class="tok-comment">/// This function is used by the Zig language code generation and</span></span>
<span class="line" id="L757"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L758"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> panic: PanicFn = <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;panic&quot;</span>))</span>
<span class="line" id="L759">    root.panic</span>
<span class="line" id="L760"><span class="tok-kw">else</span> <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;os&quot;</span>) <span class="tok-kw">and</span> <span class="tok-builtin">@hasDecl</span>(root.os, <span class="tok-str">&quot;panic&quot;</span>))</span>
<span class="line" id="L761">    root.os.panic</span>
<span class="line" id="L762"><span class="tok-kw">else</span></span>
<span class="line" id="L763">    default_panic;</span>
<span class="line" id="L764"></span>
<span class="line" id="L765"><span class="tok-comment">/// This function is used by the Zig language code generation and</span></span>
<span class="line" id="L766"><span class="tok-comment">/// therefore must be kept in sync with the compiler implementation.</span></span>
<span class="line" id="L767"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">default_panic</span>(msg: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, error_return_trace: ?*StackTrace) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L768">    <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L769"></span>
<span class="line" id="L770">    <span class="tok-comment">// Until self-hosted catches up with stage1 language features, we have a simpler</span>
</span>
<span class="line" id="L771">    <span class="tok-comment">// default panic function:</span>
</span>
<span class="line" id="L772">    <span class="tok-kw">if</span> (builtin.zig_backend == .stage2_c <span class="tok-kw">or</span></span>
<span class="line" id="L773">        builtin.zig_backend == .stage2_wasm <span class="tok-kw">or</span></span>
<span class="line" id="L774">        builtin.zig_backend == .stage2_arm <span class="tok-kw">or</span></span>
<span class="line" id="L775">        builtin.zig_backend == .stage2_aarch64 <span class="tok-kw">or</span></span>
<span class="line" id="L776">        builtin.zig_backend == .stage2_x86_64 <span class="tok-kw">or</span></span>
<span class="line" id="L777">        builtin.zig_backend == .stage2_x86 <span class="tok-kw">or</span></span>
<span class="line" id="L778">        builtin.zig_backend == .stage2_riscv64 <span class="tok-kw">or</span></span>
<span class="line" id="L779">        builtin.zig_backend == .stage2_sparc64)</span>
<span class="line" id="L780">    {</span>
<span class="line" id="L781">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L782">            <span class="tok-builtin">@breakpoint</span>();</span>
<span class="line" id="L783">        }</span>
<span class="line" id="L784">    }</span>
<span class="line" id="L785">    <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L786">        .freestanding =&gt; {</span>
<span class="line" id="L787">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L788">                <span class="tok-builtin">@breakpoint</span>();</span>
<span class="line" id="L789">            }</span>
<span class="line" id="L790">        },</span>
<span class="line" id="L791">        .wasi =&gt; {</span>
<span class="line" id="L792">            std.debug.print(<span class="tok-str">&quot;{s}&quot;</span>, .{msg});</span>
<span class="line" id="L793">            std.os.abort();</span>
<span class="line" id="L794">        },</span>
<span class="line" id="L795">        .uefi =&gt; {</span>
<span class="line" id="L796">            <span class="tok-kw">const</span> uefi = std.os.uefi;</span>
<span class="line" id="L797"></span>
<span class="line" id="L798">            <span class="tok-kw">const</span> ExitData = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L799">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create_exit_data</span>(exit_msg: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, exit_size: *<span class="tok-type">usize</span>) ![*:<span class="tok-number">0</span>]<span class="tok-type">u16</span> {</span>
<span class="line" id="L800">                    <span class="tok-comment">// Need boot services for pool allocation</span>
</span>
<span class="line" id="L801">                    <span class="tok-kw">if</span> (uefi.system_table.boot_services == <span class="tok-null">null</span>) {</span>
<span class="line" id="L802">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.BootServicesUnavailable;</span>
<span class="line" id="L803">                    }</span>
<span class="line" id="L804"></span>
<span class="line" id="L805">                    <span class="tok-comment">// ExitData buffer must be allocated using boot_services.allocatePool</span>
</span>
<span class="line" id="L806">                    <span class="tok-kw">var</span> utf16: []<span class="tok-type">u16</span> = <span class="tok-kw">try</span> uefi.raw_pool_allocator.alloc(<span class="tok-type">u16</span>, <span class="tok-number">256</span>);</span>
<span class="line" id="L807">                    <span class="tok-kw">errdefer</span> uefi.raw_pool_allocator.free(utf16);</span>
<span class="line" id="L808"></span>
<span class="line" id="L809">                    <span class="tok-kw">if</span> (exit_msg.len &gt; <span class="tok-number">255</span>) {</span>
<span class="line" id="L810">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.MessageTooLong;</span>
<span class="line" id="L811">                    }</span>
<span class="line" id="L812"></span>
<span class="line" id="L813">                    <span class="tok-kw">var</span> fmt: [<span class="tok-number">256</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L814">                    <span class="tok-kw">var</span> slice = <span class="tok-kw">try</span> std.fmt.bufPrint(&amp;fmt, <span class="tok-str">&quot;\r\nerr: {s}\r\n&quot;</span>, .{exit_msg});</span>
<span class="line" id="L815"></span>
<span class="line" id="L816">                    <span class="tok-kw">var</span> len = <span class="tok-kw">try</span> std.unicode.utf8ToUtf16Le(utf16, slice);</span>
<span class="line" id="L817"></span>
<span class="line" id="L818">                    utf16[len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L819"></span>
<span class="line" id="L820">                    exit_size.* = <span class="tok-number">256</span>;</span>
<span class="line" id="L821"></span>
<span class="line" id="L822">                    <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>([*:<span class="tok-number">0</span>]<span class="tok-type">u16</span>, utf16.ptr);</span>
<span class="line" id="L823">                }</span>
<span class="line" id="L824">            };</span>
<span class="line" id="L825"></span>
<span class="line" id="L826">            <span class="tok-kw">var</span> exit_size: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L827">            <span class="tok-kw">var</span> exit_data = ExitData.create_exit_data(msg, &amp;exit_size) <span class="tok-kw">catch</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L828"></span>
<span class="line" id="L829">            <span class="tok-kw">if</span> (exit_data) |data| {</span>
<span class="line" id="L830">                <span class="tok-kw">if</span> (uefi.system_table.std_err) |out| {</span>
<span class="line" id="L831">                    _ = out.setAttribute(uefi.protocols.SimpleTextOutputProtocol.red);</span>
<span class="line" id="L832">                    _ = out.outputString(data);</span>
<span class="line" id="L833">                    _ = out.setAttribute(uefi.protocols.SimpleTextOutputProtocol.white);</span>
<span class="line" id="L834">                }</span>
<span class="line" id="L835">            }</span>
<span class="line" id="L836"></span>
<span class="line" id="L837">            <span class="tok-kw">if</span> (uefi.system_table.boot_services) |bs| {</span>
<span class="line" id="L838">                _ = bs.exit(uefi.handle, .Aborted, exit_size, exit_data);</span>
<span class="line" id="L839">            }</span>
<span class="line" id="L840"></span>
<span class="line" id="L841">            <span class="tok-comment">// Didn't have boot_services, just fallback to whatever.</span>
</span>
<span class="line" id="L842">            std.os.abort();</span>
<span class="line" id="L843">        },</span>
<span class="line" id="L844">        <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L845">            <span class="tok-kw">const</span> first_trace_addr = <span class="tok-builtin">@returnAddress</span>();</span>
<span class="line" id="L846">            std.debug.panicImpl(error_return_trace, first_trace_addr, msg);</span>
<span class="line" id="L847">        },</span>
<span class="line" id="L848">    }</span>
<span class="line" id="L849">}</span>
<span class="line" id="L850"></span>
<span class="line" id="L851"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">checkNonScalarSentinel</span>(expected: <span class="tok-kw">anytype</span>, actual: <span class="tok-builtin">@TypeOf</span>(expected)) <span class="tok-type">void</span> {</span>
<span class="line" id="L852">    <span class="tok-kw">if</span> (!std.meta.eql(expected, actual)) {</span>
<span class="line" id="L853">        panicSentinelMismatch(expected, actual);</span>
<span class="line" id="L854">    }</span>
<span class="line" id="L855">}</span>
<span class="line" id="L856"></span>
<span class="line" id="L857"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">panicSentinelMismatch</span>(expected: <span class="tok-kw">anytype</span>, actual: <span class="tok-builtin">@TypeOf</span>(expected)) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L858">    <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L859">    std.debug.panic(<span class="tok-str">&quot;sentinel mismatch: expected {any}, found {any}&quot;</span>, .{ expected, actual });</span>
<span class="line" id="L860">}</span>
<span class="line" id="L861"></span>
<span class="line" id="L862"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">panicUnwrapError</span>(st: ?*StackTrace, err: <span class="tok-type">anyerror</span>) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L863">    <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L864">    std.debug.panicExtra(st, <span class="tok-str">&quot;attempt to unwrap error: {s}&quot;</span>, .{<span class="tok-builtin">@errorName</span>(err)});</span>
<span class="line" id="L865">}</span>
<span class="line" id="L866"></span>
<span class="line" id="L867"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">panicOutOfBounds</span>(index: <span class="tok-type">usize</span>, len: <span class="tok-type">usize</span>) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L868">    <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L869">    std.debug.panic(<span class="tok-str">&quot;index out of bounds: index {d}, len {d}&quot;</span>, .{ index, len });</span>
<span class="line" id="L870">}</span>
<span class="line" id="L871"></span>
<span class="line" id="L872"><span class="tok-kw">pub</span> <span class="tok-kw">noinline</span> <span class="tok-kw">fn</span> <span class="tok-fn">returnError</span>(st: *StackTrace) <span class="tok-type">void</span> {</span>
<span class="line" id="L873">    <span class="tok-builtin">@setCold</span>(<span class="tok-null">true</span>);</span>
<span class="line" id="L874">    <span class="tok-builtin">@setRuntimeSafety</span>(<span class="tok-null">false</span>);</span>
<span class="line" id="L875">    addErrRetTraceAddr(st, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L876">}</span>
<span class="line" id="L877"></span>
<span class="line" id="L878"><span class="tok-kw">pub</span> <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">addErrRetTraceAddr</span>(st: *StackTrace, addr: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L879">    st.instruction_addresses[st.index &amp; (st.instruction_addresses.len - <span class="tok-number">1</span>)] = addr;</span>
<span class="line" id="L880">    st.index +%= <span class="tok-number">1</span>;</span>
<span class="line" id="L881">}</span>
<span class="line" id="L882"></span>
<span class="line" id="L883"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std.zig&quot;</span>);</span>
<span class="line" id="L884"><span class="tok-kw">const</span> root = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;root&quot;</span>);</span>
<span class="line" id="L885"></span>
</code></pre></body>
</html>