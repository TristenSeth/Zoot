<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>rand.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! The engines provided here should be initialized from an external source.</span></span>
<span class="line" id="L2"><span class="tok-comment">//! For a thread-local cryptographically secure pseudo random number generator,</span></span>
<span class="line" id="L3"><span class="tok-comment">//! use `std.crypto.random`.</span></span>
<span class="line" id="L4"><span class="tok-comment">//! Be sure to use a CSPRNG when required, otherwise using a normal PRNG will</span></span>
<span class="line" id="L5"><span class="tok-comment">//! be faster and use substantially less stack space.</span></span>
<span class="line" id="L6"><span class="tok-comment">//!</span></span>
<span class="line" id="L7"><span class="tok-comment">//! TODO(tiehuis): Benchmark these against other reference implementations.</span></span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std.zig&quot;</span>);</span>
<span class="line" id="L10"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L11"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> ziggurat = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;rand/ziggurat.zig&quot;</span>);</span>
<span class="line" id="L15"><span class="tok-kw">const</span> maxInt = std.math.maxInt;</span>
<span class="line" id="L16"></span>
<span class="line" id="L17"><span class="tok-comment">/// Fast unbiased random numbers.</span></span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DefaultPrng = Xoshiro256;</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-comment">/// Cryptographically secure random numbers.</span></span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DefaultCsprng = Xoodoo;</span>
<span class="line" id="L22"></span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Isaac64 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;rand/Isaac64.zig&quot;</span>);</span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Xoodoo = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;rand/Xoodoo.zig&quot;</span>);</span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Pcg = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;rand/Pcg.zig&quot;</span>);</span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Xoroshiro128 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;rand/Xoroshiro128.zig&quot;</span>);</span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Xoshiro256 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;rand/Xoshiro256.zig&quot;</span>);</span>
<span class="line" id="L28"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Sfc64 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;rand/Sfc64.zig&quot;</span>);</span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RomuTrio = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;rand/RomuTrio.zig&quot;</span>);</span>
<span class="line" id="L30"></span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Random = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L32">    ptr: *<span class="tok-type">anyopaque</span>,</span>
<span class="line" id="L33">    fillFn: <span class="tok-kw">if</span> (builtin.zig_backend == .stage1)</span>
<span class="line" id="L34">        <span class="tok-kw">fn</span> (ptr: *<span class="tok-type">anyopaque</span>, buf: []<span class="tok-type">u8</span>) <span class="tok-type">void</span></span>
<span class="line" id="L35">    <span class="tok-kw">else</span></span>
<span class="line" id="L36">        *<span class="tok-kw">const</span> <span class="tok-kw">fn</span> (ptr: *<span class="tok-type">anyopaque</span>, buf: []<span class="tok-type">u8</span>) <span class="tok-type">void</span>,</span>
<span class="line" id="L37"></span>
<span class="line" id="L38">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(pointer: <span class="tok-kw">anytype</span>, <span class="tok-kw">comptime</span> fillFn: <span class="tok-kw">fn</span> (ptr: <span class="tok-builtin">@TypeOf</span>(pointer), buf: []<span class="tok-type">u8</span>) <span class="tok-type">void</span>) Random {</span>
<span class="line" id="L39">        <span class="tok-kw">const</span> Ptr = <span class="tok-builtin">@TypeOf</span>(pointer);</span>
<span class="line" id="L40">        assert(<span class="tok-builtin">@typeInfo</span>(Ptr) == .Pointer); <span class="tok-comment">// Must be a pointer</span>
</span>
<span class="line" id="L41">        assert(<span class="tok-builtin">@typeInfo</span>(Ptr).Pointer.size == .One); <span class="tok-comment">// Must be a single-item pointer</span>
</span>
<span class="line" id="L42">        assert(<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@typeInfo</span>(Ptr).Pointer.child) == .Struct); <span class="tok-comment">// Must point to a struct</span>
</span>
<span class="line" id="L43">        <span class="tok-kw">const</span> gen = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L44">            <span class="tok-kw">fn</span> <span class="tok-fn">fill</span>(ptr: *<span class="tok-type">anyopaque</span>, buf: []<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L45">                <span class="tok-kw">const</span> alignment = <span class="tok-builtin">@typeInfo</span>(Ptr).Pointer.alignment;</span>
<span class="line" id="L46">                <span class="tok-kw">const</span> self = <span class="tok-builtin">@ptrCast</span>(Ptr, <span class="tok-builtin">@alignCast</span>(alignment, ptr));</span>
<span class="line" id="L47">                fillFn(self, buf);</span>
<span class="line" id="L48">            }</span>
<span class="line" id="L49">        };</span>
<span class="line" id="L50"></span>
<span class="line" id="L51">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L52">            .ptr = pointer,</span>
<span class="line" id="L53">            .fillFn = gen.fill,</span>
<span class="line" id="L54">        };</span>
<span class="line" id="L55">    }</span>
<span class="line" id="L56"></span>
<span class="line" id="L57">    <span class="tok-comment">/// Read random bytes into the specified buffer until full.</span></span>
<span class="line" id="L58">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">bytes</span>(r: Random, buf: []<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L59">        r.fillFn(r.ptr, buf);</span>
<span class="line" id="L60">    }</span>
<span class="line" id="L61"></span>
<span class="line" id="L62">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">boolean</span>(r: Random) <span class="tok-type">bool</span> {</span>
<span class="line" id="L63">        <span class="tok-kw">return</span> r.int(<span class="tok-type">u1</span>) != <span class="tok-number">0</span>;</span>
<span class="line" id="L64">    }</span>
<span class="line" id="L65"></span>
<span class="line" id="L66">    <span class="tok-comment">/// Returns a random value from an enum, evenly distributed.</span></span>
<span class="line" id="L67">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">enumValue</span>(r: Random, <span class="tok-kw">comptime</span> EnumType: <span class="tok-type">type</span>) EnumType {</span>
<span class="line" id="L68">        <span class="tok-kw">comptime</span> assert(<span class="tok-builtin">@typeInfo</span>(EnumType) == .Enum);</span>
<span class="line" id="L69"></span>
<span class="line" id="L70">        <span class="tok-comment">// We won't use int -&gt; enum casting because enum elements can have</span>
</span>
<span class="line" id="L71">        <span class="tok-comment">//  arbitrary values.  Instead we'll randomly pick one of the type's values.</span>
</span>
<span class="line" id="L72">        <span class="tok-kw">const</span> values = std.enums.values(EnumType);</span>
<span class="line" id="L73">        <span class="tok-kw">const</span> index = r.uintLessThan(<span class="tok-type">usize</span>, values.len);</span>
<span class="line" id="L74">        <span class="tok-kw">return</span> values[index];</span>
<span class="line" id="L75">    }</span>
<span class="line" id="L76"></span>
<span class="line" id="L77">    <span class="tok-comment">/// Returns a random int `i` such that `minInt(T) &lt;= i &lt;= maxInt(T)`.</span></span>
<span class="line" id="L78">    <span class="tok-comment">/// `i` is evenly distributed.</span></span>
<span class="line" id="L79">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">int</span>(r: Random, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) T {</span>
<span class="line" id="L80">        <span class="tok-kw">const</span> bits = <span class="tok-builtin">@typeInfo</span>(T).Int.bits;</span>
<span class="line" id="L81">        <span class="tok-kw">const</span> UnsignedT = std.meta.Int(.unsigned, bits);</span>
<span class="line" id="L82">        <span class="tok-kw">const</span> ByteAlignedT = std.meta.Int(.unsigned, <span class="tok-builtin">@divTrunc</span>(bits + <span class="tok-number">7</span>, <span class="tok-number">8</span>) * <span class="tok-number">8</span>);</span>
<span class="line" id="L83"></span>
<span class="line" id="L84">        <span class="tok-kw">var</span> rand_bytes: [<span class="tok-builtin">@sizeOf</span>(ByteAlignedT)]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L85">        r.bytes(rand_bytes[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">        <span class="tok-comment">// use LE instead of native endian for better portability maybe?</span>
</span>
<span class="line" id="L88">        <span class="tok-comment">// TODO: endian portability is pointless if the underlying prng isn't endian portable.</span>
</span>
<span class="line" id="L89">        <span class="tok-comment">// TODO: document the endian portability of this library.</span>
</span>
<span class="line" id="L90">        <span class="tok-kw">const</span> byte_aligned_result = mem.readIntSliceLittle(ByteAlignedT, &amp;rand_bytes);</span>
<span class="line" id="L91">        <span class="tok-kw">const</span> unsigned_result = <span class="tok-builtin">@truncate</span>(UnsignedT, byte_aligned_result);</span>
<span class="line" id="L92">        <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(T, unsigned_result);</span>
<span class="line" id="L93">    }</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">    <span class="tok-comment">/// Constant-time implementation off `uintLessThan`.</span></span>
<span class="line" id="L96">    <span class="tok-comment">/// The results of this function may be biased.</span></span>
<span class="line" id="L97">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">uintLessThanBiased</span>(r: Random, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, less_than: T) T {</span>
<span class="line" id="L98">        <span class="tok-kw">comptime</span> assert(<span class="tok-builtin">@typeInfo</span>(T).Int.signedness == .unsigned);</span>
<span class="line" id="L99">        <span class="tok-kw">const</span> bits = <span class="tok-builtin">@typeInfo</span>(T).Int.bits;</span>
<span class="line" id="L100">        <span class="tok-kw">comptime</span> assert(bits &lt;= <span class="tok-number">64</span>); <span class="tok-comment">// TODO: workaround: LLVM ERROR: Unsupported library call operation!</span>
</span>
<span class="line" id="L101">        assert(<span class="tok-number">0</span> &lt; less_than);</span>
<span class="line" id="L102">        <span class="tok-kw">if</span> (bits &lt;= <span class="tok-number">32</span>) {</span>
<span class="line" id="L103">            <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(T, limitRangeBiased(<span class="tok-type">u32</span>, r.int(<span class="tok-type">u32</span>), less_than));</span>
<span class="line" id="L104">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L105">            <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(T, limitRangeBiased(<span class="tok-type">u64</span>, r.int(<span class="tok-type">u64</span>), less_than));</span>
<span class="line" id="L106">        }</span>
<span class="line" id="L107">    }</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">    <span class="tok-comment">/// Returns an evenly distributed random unsigned integer `0 &lt;= i &lt; less_than`.</span></span>
<span class="line" id="L110">    <span class="tok-comment">/// This function assumes that the underlying `fillFn` produces evenly distributed values.</span></span>
<span class="line" id="L111">    <span class="tok-comment">/// Within this assumption, the runtime of this function is exponentially distributed.</span></span>
<span class="line" id="L112">    <span class="tok-comment">/// If `fillFn` were backed by a true random generator,</span></span>
<span class="line" id="L113">    <span class="tok-comment">/// the runtime of this function would technically be unbounded.</span></span>
<span class="line" id="L114">    <span class="tok-comment">/// However, if `fillFn` is backed by any evenly distributed pseudo random number generator,</span></span>
<span class="line" id="L115">    <span class="tok-comment">/// this function is guaranteed to return.</span></span>
<span class="line" id="L116">    <span class="tok-comment">/// If you need deterministic runtime bounds, use `uintLessThanBiased`.</span></span>
<span class="line" id="L117">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">uintLessThan</span>(r: Random, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, less_than: T) T {</span>
<span class="line" id="L118">        <span class="tok-kw">comptime</span> assert(<span class="tok-builtin">@typeInfo</span>(T).Int.signedness == .unsigned);</span>
<span class="line" id="L119">        <span class="tok-kw">const</span> bits = <span class="tok-builtin">@typeInfo</span>(T).Int.bits;</span>
<span class="line" id="L120">        <span class="tok-kw">comptime</span> assert(bits &lt;= <span class="tok-number">64</span>); <span class="tok-comment">// TODO: workaround: LLVM ERROR: Unsupported library call operation!</span>
</span>
<span class="line" id="L121">        assert(<span class="tok-number">0</span> &lt; less_than);</span>
<span class="line" id="L122">        <span class="tok-comment">// Small is typically u32</span>
</span>
<span class="line" id="L123">        <span class="tok-kw">const</span> small_bits = <span class="tok-builtin">@divTrunc</span>(bits + <span class="tok-number">31</span>, <span class="tok-number">32</span>) * <span class="tok-number">32</span>;</span>
<span class="line" id="L124">        <span class="tok-kw">const</span> Small = std.meta.Int(.unsigned, small_bits);</span>
<span class="line" id="L125">        <span class="tok-comment">// Large is typically u64</span>
</span>
<span class="line" id="L126">        <span class="tok-kw">const</span> Large = std.meta.Int(.unsigned, small_bits * <span class="tok-number">2</span>);</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">        <span class="tok-comment">// adapted from:</span>
</span>
<span class="line" id="L129">        <span class="tok-comment">//   http://www.pcg-random.org/posts/bounded-rands.html</span>
</span>
<span class="line" id="L130">        <span class="tok-comment">//   &quot;Lemire's (with an extra tweak from me)&quot;</span>
</span>
<span class="line" id="L131">        <span class="tok-kw">var</span> x: Small = r.int(Small);</span>
<span class="line" id="L132">        <span class="tok-kw">var</span> m: Large = <span class="tok-builtin">@as</span>(Large, x) * <span class="tok-builtin">@as</span>(Large, less_than);</span>
<span class="line" id="L133">        <span class="tok-kw">var</span> l: Small = <span class="tok-builtin">@truncate</span>(Small, m);</span>
<span class="line" id="L134">        <span class="tok-kw">if</span> (l &lt; less_than) {</span>
<span class="line" id="L135">            <span class="tok-kw">var</span> t: Small = -%less_than;</span>
<span class="line" id="L136"></span>
<span class="line" id="L137">            <span class="tok-kw">if</span> (t &gt;= less_than) {</span>
<span class="line" id="L138">                t -= less_than;</span>
<span class="line" id="L139">                <span class="tok-kw">if</span> (t &gt;= less_than) {</span>
<span class="line" id="L140">                    t %= less_than;</span>
<span class="line" id="L141">                }</span>
<span class="line" id="L142">            }</span>
<span class="line" id="L143">            <span class="tok-kw">while</span> (l &lt; t) {</span>
<span class="line" id="L144">                x = r.int(Small);</span>
<span class="line" id="L145">                m = <span class="tok-builtin">@as</span>(Large, x) * <span class="tok-builtin">@as</span>(Large, less_than);</span>
<span class="line" id="L146">                l = <span class="tok-builtin">@truncate</span>(Small, m);</span>
<span class="line" id="L147">            }</span>
<span class="line" id="L148">        }</span>
<span class="line" id="L149">        <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(T, m &gt;&gt; small_bits);</span>
<span class="line" id="L150">    }</span>
<span class="line" id="L151"></span>
<span class="line" id="L152">    <span class="tok-comment">/// Constant-time implementation off `uintAtMost`.</span></span>
<span class="line" id="L153">    <span class="tok-comment">/// The results of this function may be biased.</span></span>
<span class="line" id="L154">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">uintAtMostBiased</span>(r: Random, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, at_most: T) T {</span>
<span class="line" id="L155">        assert(<span class="tok-builtin">@typeInfo</span>(T).Int.signedness == .unsigned);</span>
<span class="line" id="L156">        <span class="tok-kw">if</span> (at_most == maxInt(T)) {</span>
<span class="line" id="L157">            <span class="tok-comment">// have the full range</span>
</span>
<span class="line" id="L158">            <span class="tok-kw">return</span> r.int(T);</span>
<span class="line" id="L159">        }</span>
<span class="line" id="L160">        <span class="tok-kw">return</span> r.uintLessThanBiased(T, at_most + <span class="tok-number">1</span>);</span>
<span class="line" id="L161">    }</span>
<span class="line" id="L162"></span>
<span class="line" id="L163">    <span class="tok-comment">/// Returns an evenly distributed random unsigned integer `0 &lt;= i &lt;= at_most`.</span></span>
<span class="line" id="L164">    <span class="tok-comment">/// See `uintLessThan`, which this function uses in most cases,</span></span>
<span class="line" id="L165">    <span class="tok-comment">/// for commentary on the runtime of this function.</span></span>
<span class="line" id="L166">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">uintAtMost</span>(r: Random, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, at_most: T) T {</span>
<span class="line" id="L167">        assert(<span class="tok-builtin">@typeInfo</span>(T).Int.signedness == .unsigned);</span>
<span class="line" id="L168">        <span class="tok-kw">if</span> (at_most == maxInt(T)) {</span>
<span class="line" id="L169">            <span class="tok-comment">// have the full range</span>
</span>
<span class="line" id="L170">            <span class="tok-kw">return</span> r.int(T);</span>
<span class="line" id="L171">        }</span>
<span class="line" id="L172">        <span class="tok-kw">return</span> r.uintLessThan(T, at_most + <span class="tok-number">1</span>);</span>
<span class="line" id="L173">    }</span>
<span class="line" id="L174"></span>
<span class="line" id="L175">    <span class="tok-comment">/// Constant-time implementation off `intRangeLessThan`.</span></span>
<span class="line" id="L176">    <span class="tok-comment">/// The results of this function may be biased.</span></span>
<span class="line" id="L177">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">intRangeLessThanBiased</span>(r: Random, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, at_least: T, less_than: T) T {</span>
<span class="line" id="L178">        assert(at_least &lt; less_than);</span>
<span class="line" id="L179">        <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(T).Int;</span>
<span class="line" id="L180">        <span class="tok-kw">if</span> (info.signedness == .signed) {</span>
<span class="line" id="L181">            <span class="tok-comment">// Two's complement makes this math pretty easy.</span>
</span>
<span class="line" id="L182">            <span class="tok-kw">const</span> UnsignedT = std.meta.Int(.unsigned, info.bits);</span>
<span class="line" id="L183">            <span class="tok-kw">const</span> lo = <span class="tok-builtin">@bitCast</span>(UnsignedT, at_least);</span>
<span class="line" id="L184">            <span class="tok-kw">const</span> hi = <span class="tok-builtin">@bitCast</span>(UnsignedT, less_than);</span>
<span class="line" id="L185">            <span class="tok-kw">const</span> result = lo +% r.uintLessThanBiased(UnsignedT, hi -% lo);</span>
<span class="line" id="L186">            <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(T, result);</span>
<span class="line" id="L187">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L188">            <span class="tok-comment">// The signed implementation would work fine, but we can use stricter arithmetic operators here.</span>
</span>
<span class="line" id="L189">            <span class="tok-kw">return</span> at_least + r.uintLessThanBiased(T, less_than - at_least);</span>
<span class="line" id="L190">        }</span>
<span class="line" id="L191">    }</span>
<span class="line" id="L192"></span>
<span class="line" id="L193">    <span class="tok-comment">/// Returns an evenly distributed random integer `at_least &lt;= i &lt; less_than`.</span></span>
<span class="line" id="L194">    <span class="tok-comment">/// See `uintLessThan`, which this function uses in most cases,</span></span>
<span class="line" id="L195">    <span class="tok-comment">/// for commentary on the runtime of this function.</span></span>
<span class="line" id="L196">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">intRangeLessThan</span>(r: Random, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, at_least: T, less_than: T) T {</span>
<span class="line" id="L197">        assert(at_least &lt; less_than);</span>
<span class="line" id="L198">        <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(T).Int;</span>
<span class="line" id="L199">        <span class="tok-kw">if</span> (info.signedness == .signed) {</span>
<span class="line" id="L200">            <span class="tok-comment">// Two's complement makes this math pretty easy.</span>
</span>
<span class="line" id="L201">            <span class="tok-kw">const</span> UnsignedT = std.meta.Int(.unsigned, info.bits);</span>
<span class="line" id="L202">            <span class="tok-kw">const</span> lo = <span class="tok-builtin">@bitCast</span>(UnsignedT, at_least);</span>
<span class="line" id="L203">            <span class="tok-kw">const</span> hi = <span class="tok-builtin">@bitCast</span>(UnsignedT, less_than);</span>
<span class="line" id="L204">            <span class="tok-kw">const</span> result = lo +% r.uintLessThan(UnsignedT, hi -% lo);</span>
<span class="line" id="L205">            <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(T, result);</span>
<span class="line" id="L206">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L207">            <span class="tok-comment">// The signed implementation would work fine, but we can use stricter arithmetic operators here.</span>
</span>
<span class="line" id="L208">            <span class="tok-kw">return</span> at_least + r.uintLessThan(T, less_than - at_least);</span>
<span class="line" id="L209">        }</span>
<span class="line" id="L210">    }</span>
<span class="line" id="L211"></span>
<span class="line" id="L212">    <span class="tok-comment">/// Constant-time implementation off `intRangeAtMostBiased`.</span></span>
<span class="line" id="L213">    <span class="tok-comment">/// The results of this function may be biased.</span></span>
<span class="line" id="L214">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">intRangeAtMostBiased</span>(r: Random, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, at_least: T, at_most: T) T {</span>
<span class="line" id="L215">        assert(at_least &lt;= at_most);</span>
<span class="line" id="L216">        <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(T).Int;</span>
<span class="line" id="L217">        <span class="tok-kw">if</span> (info.signedness == .signed) {</span>
<span class="line" id="L218">            <span class="tok-comment">// Two's complement makes this math pretty easy.</span>
</span>
<span class="line" id="L219">            <span class="tok-kw">const</span> UnsignedT = std.meta.Int(.unsigned, info.bits);</span>
<span class="line" id="L220">            <span class="tok-kw">const</span> lo = <span class="tok-builtin">@bitCast</span>(UnsignedT, at_least);</span>
<span class="line" id="L221">            <span class="tok-kw">const</span> hi = <span class="tok-builtin">@bitCast</span>(UnsignedT, at_most);</span>
<span class="line" id="L222">            <span class="tok-kw">const</span> result = lo +% r.uintAtMostBiased(UnsignedT, hi -% lo);</span>
<span class="line" id="L223">            <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(T, result);</span>
<span class="line" id="L224">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L225">            <span class="tok-comment">// The signed implementation would work fine, but we can use stricter arithmetic operators here.</span>
</span>
<span class="line" id="L226">            <span class="tok-kw">return</span> at_least + r.uintAtMostBiased(T, at_most - at_least);</span>
<span class="line" id="L227">        }</span>
<span class="line" id="L228">    }</span>
<span class="line" id="L229"></span>
<span class="line" id="L230">    <span class="tok-comment">/// Returns an evenly distributed random integer `at_least &lt;= i &lt;= at_most`.</span></span>
<span class="line" id="L231">    <span class="tok-comment">/// See `uintLessThan`, which this function uses in most cases,</span></span>
<span class="line" id="L232">    <span class="tok-comment">/// for commentary on the runtime of this function.</span></span>
<span class="line" id="L233">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">intRangeAtMost</span>(r: Random, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, at_least: T, at_most: T) T {</span>
<span class="line" id="L234">        assert(at_least &lt;= at_most);</span>
<span class="line" id="L235">        <span class="tok-kw">const</span> info = <span class="tok-builtin">@typeInfo</span>(T).Int;</span>
<span class="line" id="L236">        <span class="tok-kw">if</span> (info.signedness == .signed) {</span>
<span class="line" id="L237">            <span class="tok-comment">// Two's complement makes this math pretty easy.</span>
</span>
<span class="line" id="L238">            <span class="tok-kw">const</span> UnsignedT = std.meta.Int(.unsigned, info.bits);</span>
<span class="line" id="L239">            <span class="tok-kw">const</span> lo = <span class="tok-builtin">@bitCast</span>(UnsignedT, at_least);</span>
<span class="line" id="L240">            <span class="tok-kw">const</span> hi = <span class="tok-builtin">@bitCast</span>(UnsignedT, at_most);</span>
<span class="line" id="L241">            <span class="tok-kw">const</span> result = lo +% r.uintAtMost(UnsignedT, hi -% lo);</span>
<span class="line" id="L242">            <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(T, result);</span>
<span class="line" id="L243">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L244">            <span class="tok-comment">// The signed implementation would work fine, but we can use stricter arithmetic operators here.</span>
</span>
<span class="line" id="L245">            <span class="tok-kw">return</span> at_least + r.uintAtMost(T, at_most - at_least);</span>
<span class="line" id="L246">        }</span>
<span class="line" id="L247">    }</span>
<span class="line" id="L248"></span>
<span class="line" id="L249">    <span class="tok-comment">/// Return a floating point value evenly distributed in the range [0, 1).</span></span>
<span class="line" id="L250">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">float</span>(r: Random, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) T {</span>
<span class="line" id="L251">        <span class="tok-comment">// Generate a uniformly random value for the mantissa.</span>
</span>
<span class="line" id="L252">        <span class="tok-comment">// Then generate an exponentially biased random value for the exponent.</span>
</span>
<span class="line" id="L253">        <span class="tok-comment">// This covers every possible value in the range.</span>
</span>
<span class="line" id="L254">        <span class="tok-kw">switch</span> (T) {</span>
<span class="line" id="L255">            <span class="tok-type">f32</span> =&gt; {</span>
<span class="line" id="L256">                <span class="tok-comment">// Use 23 random bits for the mantissa, and the rest for the exponent.</span>
</span>
<span class="line" id="L257">                <span class="tok-comment">// If all 41 bits are zero, generate additional random bits, until a</span>
</span>
<span class="line" id="L258">                <span class="tok-comment">// set bit is found, or 126 bits have been generated.</span>
</span>
<span class="line" id="L259">                <span class="tok-kw">const</span> rand = r.int(<span class="tok-type">u64</span>);</span>
<span class="line" id="L260">                <span class="tok-kw">var</span> rand_lz = <span class="tok-builtin">@clz</span>(<span class="tok-type">u64</span>, rand);</span>
<span class="line" id="L261">                <span class="tok-kw">if</span> (rand_lz &gt;= <span class="tok-number">41</span>) {</span>
<span class="line" id="L262">                    <span class="tok-comment">// TODO: when #5177 or #489 is implemented,</span>
</span>
<span class="line" id="L263">                    <span class="tok-comment">// tell the compiler it is unlikely (1/2^41) to reach this point.</span>
</span>
<span class="line" id="L264">                    <span class="tok-comment">// (Same for the if branch and the f64 calculations below.)</span>
</span>
<span class="line" id="L265">                    rand_lz = <span class="tok-number">41</span> + <span class="tok-builtin">@clz</span>(<span class="tok-type">u64</span>, r.int(<span class="tok-type">u64</span>));</span>
<span class="line" id="L266">                    <span class="tok-kw">if</span> (rand_lz == <span class="tok-number">41</span> + <span class="tok-number">64</span>) {</span>
<span class="line" id="L267">                        <span class="tok-comment">// It is astronomically unlikely to reach this point.</span>
</span>
<span class="line" id="L268">                        rand_lz += <span class="tok-builtin">@clz</span>(<span class="tok-type">u32</span>, r.int(<span class="tok-type">u32</span>) | <span class="tok-number">0x7FF</span>);</span>
<span class="line" id="L269">                    }</span>
<span class="line" id="L270">                }</span>
<span class="line" id="L271">                <span class="tok-kw">const</span> mantissa = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u23</span>, rand);</span>
<span class="line" id="L272">                <span class="tok-kw">const</span> exponent = <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">126</span> - rand_lz) &lt;&lt; <span class="tok-number">23</span>;</span>
<span class="line" id="L273">                <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f32</span>, exponent | mantissa);</span>
<span class="line" id="L274">            },</span>
<span class="line" id="L275">            <span class="tok-type">f64</span> =&gt; {</span>
<span class="line" id="L276">                <span class="tok-comment">// Use 52 random bits for the mantissa, and the rest for the exponent.</span>
</span>
<span class="line" id="L277">                <span class="tok-comment">// If all 12 bits are zero, generate additional random bits, until a</span>
</span>
<span class="line" id="L278">                <span class="tok-comment">// set bit is found, or 1022 bits have been generated.</span>
</span>
<span class="line" id="L279">                <span class="tok-kw">const</span> rand = r.int(<span class="tok-type">u64</span>);</span>
<span class="line" id="L280">                <span class="tok-kw">var</span> rand_lz: <span class="tok-type">u64</span> = <span class="tok-builtin">@clz</span>(<span class="tok-type">u64</span>, rand);</span>
<span class="line" id="L281">                <span class="tok-kw">if</span> (rand_lz &gt;= <span class="tok-number">12</span>) {</span>
<span class="line" id="L282">                    rand_lz = <span class="tok-number">12</span>;</span>
<span class="line" id="L283">                    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L284">                        <span class="tok-comment">// It is astronomically unlikely for this loop to execute more than once.</span>
</span>
<span class="line" id="L285">                        <span class="tok-kw">const</span> addl_rand_lz = <span class="tok-builtin">@clz</span>(<span class="tok-type">u64</span>, r.int(<span class="tok-type">u64</span>));</span>
<span class="line" id="L286">                        rand_lz += addl_rand_lz;</span>
<span class="line" id="L287">                        <span class="tok-kw">if</span> (addl_rand_lz != <span class="tok-number">64</span>) {</span>
<span class="line" id="L288">                            <span class="tok-kw">break</span>;</span>
<span class="line" id="L289">                        }</span>
<span class="line" id="L290">                        <span class="tok-kw">if</span> (rand_lz &gt;= <span class="tok-number">1022</span>) {</span>
<span class="line" id="L291">                            rand_lz = <span class="tok-number">1022</span>;</span>
<span class="line" id="L292">                            <span class="tok-kw">break</span>;</span>
<span class="line" id="L293">                        }</span>
<span class="line" id="L294">                    }</span>
<span class="line" id="L295">                }</span>
<span class="line" id="L296">                <span class="tok-kw">const</span> mantissa = rand &amp; <span class="tok-number">0xFFFFFFFFFFFFF</span>;</span>
<span class="line" id="L297">                <span class="tok-kw">const</span> exponent = (<span class="tok-number">1022</span> - rand_lz) &lt;&lt; <span class="tok-number">52</span>;</span>
<span class="line" id="L298">                <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">f64</span>, exponent | mantissa);</span>
<span class="line" id="L299">            },</span>
<span class="line" id="L300">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;unknown floating point type&quot;</span>),</span>
<span class="line" id="L301">        }</span>
<span class="line" id="L302">    }</span>
<span class="line" id="L303"></span>
<span class="line" id="L304">    <span class="tok-comment">/// Return a floating point value normally distributed with mean = 0, stddev = 1.</span></span>
<span class="line" id="L305">    <span class="tok-comment">///</span></span>
<span class="line" id="L306">    <span class="tok-comment">/// To use different parameters, use: floatNorm(...) * desiredStddev + desiredMean.</span></span>
<span class="line" id="L307">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">floatNorm</span>(r: Random, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) T {</span>
<span class="line" id="L308">        <span class="tok-kw">const</span> value = ziggurat.next_f64(r, ziggurat.NormDist);</span>
<span class="line" id="L309">        <span class="tok-kw">switch</span> (T) {</span>
<span class="line" id="L310">            <span class="tok-type">f32</span> =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@floatCast</span>(<span class="tok-type">f32</span>, value),</span>
<span class="line" id="L311">            <span class="tok-type">f64</span> =&gt; <span class="tok-kw">return</span> value,</span>
<span class="line" id="L312">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;unknown floating point type&quot;</span>),</span>
<span class="line" id="L313">        }</span>
<span class="line" id="L314">    }</span>
<span class="line" id="L315"></span>
<span class="line" id="L316">    <span class="tok-comment">/// Return an exponentially distributed float with a rate parameter of 1.</span></span>
<span class="line" id="L317">    <span class="tok-comment">///</span></span>
<span class="line" id="L318">    <span class="tok-comment">/// To use a different rate parameter, use: floatExp(...) / desiredRate.</span></span>
<span class="line" id="L319">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">floatExp</span>(r: Random, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) T {</span>
<span class="line" id="L320">        <span class="tok-kw">const</span> value = ziggurat.next_f64(r, ziggurat.ExpDist);</span>
<span class="line" id="L321">        <span class="tok-kw">switch</span> (T) {</span>
<span class="line" id="L322">            <span class="tok-type">f32</span> =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@floatCast</span>(<span class="tok-type">f32</span>, value),</span>
<span class="line" id="L323">            <span class="tok-type">f64</span> =&gt; <span class="tok-kw">return</span> value,</span>
<span class="line" id="L324">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;unknown floating point type&quot;</span>),</span>
<span class="line" id="L325">        }</span>
<span class="line" id="L326">    }</span>
<span class="line" id="L327"></span>
<span class="line" id="L328">    <span class="tok-comment">/// Shuffle a slice into a random order.</span></span>
<span class="line" id="L329">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">shuffle</span>(r: Random, <span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, buf: []T) <span class="tok-type">void</span> {</span>
<span class="line" id="L330">        <span class="tok-kw">if</span> (buf.len &lt; <span class="tok-number">2</span>) {</span>
<span class="line" id="L331">            <span class="tok-kw">return</span>;</span>
<span class="line" id="L332">        }</span>
<span class="line" id="L333"></span>
<span class="line" id="L334">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L335">        <span class="tok-kw">while</span> (i &lt; buf.len - <span class="tok-number">1</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L336">            <span class="tok-kw">const</span> j = r.intRangeLessThan(<span class="tok-type">usize</span>, i, buf.len);</span>
<span class="line" id="L337">            mem.swap(T, &amp;buf[i], &amp;buf[j]);</span>
<span class="line" id="L338">        }</span>
<span class="line" id="L339">    }</span>
<span class="line" id="L340">};</span>
<span class="line" id="L341"></span>
<span class="line" id="L342"><span class="tok-comment">/// Convert a random integer 0 &lt;= random_int &lt;= maxValue(T),</span></span>
<span class="line" id="L343"><span class="tok-comment">/// into an integer 0 &lt;= result &lt; less_than.</span></span>
<span class="line" id="L344"><span class="tok-comment">/// This function introduces a minor bias.</span></span>
<span class="line" id="L345"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">limitRangeBiased</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>, random_int: T, less_than: T) T {</span>
<span class="line" id="L346">    <span class="tok-kw">comptime</span> assert(<span class="tok-builtin">@typeInfo</span>(T).Int.signedness == .unsigned);</span>
<span class="line" id="L347">    <span class="tok-kw">const</span> bits = <span class="tok-builtin">@typeInfo</span>(T).Int.bits;</span>
<span class="line" id="L348">    <span class="tok-kw">const</span> T2 = std.meta.Int(.unsigned, bits * <span class="tok-number">2</span>);</span>
<span class="line" id="L349"></span>
<span class="line" id="L350">    <span class="tok-comment">// adapted from:</span>
</span>
<span class="line" id="L351">    <span class="tok-comment">//   http://www.pcg-random.org/posts/bounded-rands.html</span>
</span>
<span class="line" id="L352">    <span class="tok-comment">//   &quot;Integer Multiplication (Biased)&quot;</span>
</span>
<span class="line" id="L353">    <span class="tok-kw">var</span> m: T2 = <span class="tok-builtin">@as</span>(T2, random_int) * <span class="tok-builtin">@as</span>(T2, less_than);</span>
<span class="line" id="L354">    <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(T, m &gt;&gt; bits);</span>
<span class="line" id="L355">}</span>
<span class="line" id="L356"></span>
<span class="line" id="L357"><span class="tok-comment">// Generator to extend 64-bit seed values into longer sequences.</span>
</span>
<span class="line" id="L358"><span class="tok-comment">//</span>
</span>
<span class="line" id="L359"><span class="tok-comment">// The number of cycles is thus limited to 64-bits regardless of the engine, but this</span>
</span>
<span class="line" id="L360"><span class="tok-comment">// is still plenty for practical purposes.</span>
</span>
<span class="line" id="L361"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SplitMix64 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L362">    s: <span class="tok-type">u64</span>,</span>
<span class="line" id="L363"></span>
<span class="line" id="L364">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(seed: <span class="tok-type">u64</span>) SplitMix64 {</span>
<span class="line" id="L365">        <span class="tok-kw">return</span> SplitMix64{ .s = seed };</span>
<span class="line" id="L366">    }</span>
<span class="line" id="L367"></span>
<span class="line" id="L368">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *SplitMix64) <span class="tok-type">u64</span> {</span>
<span class="line" id="L369">        self.s +%= <span class="tok-number">0x9e3779b97f4a7c15</span>;</span>
<span class="line" id="L370"></span>
<span class="line" id="L371">        <span class="tok-kw">var</span> z = self.s;</span>
<span class="line" id="L372">        z = (z ^ (z &gt;&gt; <span class="tok-number">30</span>)) *% <span class="tok-number">0xbf58476d1ce4e5b9</span>;</span>
<span class="line" id="L373">        z = (z ^ (z &gt;&gt; <span class="tok-number">27</span>)) *% <span class="tok-number">0x94d049bb133111eb</span>;</span>
<span class="line" id="L374">        <span class="tok-kw">return</span> z ^ (z &gt;&gt; <span class="tok-number">31</span>);</span>
<span class="line" id="L375">    }</span>
<span class="line" id="L376">};</span>
<span class="line" id="L377"></span>
<span class="line" id="L378"><span class="tok-kw">test</span> {</span>
<span class="line" id="L379">    std.testing.refAllDecls(<span class="tok-builtin">@This</span>());</span>
<span class="line" id="L380">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;rand/test.zig&quot;</span>);</span>
<span class="line" id="L381">}</span>
<span class="line" id="L382"></span>
</code></pre></body>
</html>