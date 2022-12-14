<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/sha2.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> htest = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;test.zig&quot;</span>);</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-comment">/////////////////////</span>
</span>
<span class="line" id="L7"><span class="tok-comment">// Sha224 + Sha256</span>
</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-kw">const</span> RoundParam256 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L10">    a: <span class="tok-type">usize</span>,</span>
<span class="line" id="L11">    b: <span class="tok-type">usize</span>,</span>
<span class="line" id="L12">    c: <span class="tok-type">usize</span>,</span>
<span class="line" id="L13">    d: <span class="tok-type">usize</span>,</span>
<span class="line" id="L14">    e: <span class="tok-type">usize</span>,</span>
<span class="line" id="L15">    f: <span class="tok-type">usize</span>,</span>
<span class="line" id="L16">    g: <span class="tok-type">usize</span>,</span>
<span class="line" id="L17">    h: <span class="tok-type">usize</span>,</span>
<span class="line" id="L18">    i: <span class="tok-type">usize</span>,</span>
<span class="line" id="L19">    k: <span class="tok-type">u32</span>,</span>
<span class="line" id="L20">};</span>
<span class="line" id="L21"></span>
<span class="line" id="L22"><span class="tok-kw">fn</span> <span class="tok-fn">roundParam256</span>(a: <span class="tok-type">usize</span>, b: <span class="tok-type">usize</span>, c: <span class="tok-type">usize</span>, d: <span class="tok-type">usize</span>, e: <span class="tok-type">usize</span>, f: <span class="tok-type">usize</span>, g: <span class="tok-type">usize</span>, h: <span class="tok-type">usize</span>, i: <span class="tok-type">usize</span>, k: <span class="tok-type">u32</span>) RoundParam256 {</span>
<span class="line" id="L23">    <span class="tok-kw">return</span> RoundParam256{</span>
<span class="line" id="L24">        .a = a,</span>
<span class="line" id="L25">        .b = b,</span>
<span class="line" id="L26">        .c = c,</span>
<span class="line" id="L27">        .d = d,</span>
<span class="line" id="L28">        .e = e,</span>
<span class="line" id="L29">        .f = f,</span>
<span class="line" id="L30">        .g = g,</span>
<span class="line" id="L31">        .h = h,</span>
<span class="line" id="L32">        .i = i,</span>
<span class="line" id="L33">        .k = k,</span>
<span class="line" id="L34">    };</span>
<span class="line" id="L35">}</span>
<span class="line" id="L36"></span>
<span class="line" id="L37"><span class="tok-kw">const</span> Sha2Params32 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L38">    iv0: <span class="tok-type">u32</span>,</span>
<span class="line" id="L39">    iv1: <span class="tok-type">u32</span>,</span>
<span class="line" id="L40">    iv2: <span class="tok-type">u32</span>,</span>
<span class="line" id="L41">    iv3: <span class="tok-type">u32</span>,</span>
<span class="line" id="L42">    iv4: <span class="tok-type">u32</span>,</span>
<span class="line" id="L43">    iv5: <span class="tok-type">u32</span>,</span>
<span class="line" id="L44">    iv6: <span class="tok-type">u32</span>,</span>
<span class="line" id="L45">    iv7: <span class="tok-type">u32</span>,</span>
<span class="line" id="L46">    digest_bits: <span class="tok-type">usize</span>,</span>
<span class="line" id="L47">};</span>
<span class="line" id="L48"></span>
<span class="line" id="L49"><span class="tok-kw">const</span> Sha224Params = Sha2Params32{</span>
<span class="line" id="L50">    .iv0 = <span class="tok-number">0xC1059ED8</span>,</span>
<span class="line" id="L51">    .iv1 = <span class="tok-number">0x367CD507</span>,</span>
<span class="line" id="L52">    .iv2 = <span class="tok-number">0x3070DD17</span>,</span>
<span class="line" id="L53">    .iv3 = <span class="tok-number">0xF70E5939</span>,</span>
<span class="line" id="L54">    .iv4 = <span class="tok-number">0xFFC00B31</span>,</span>
<span class="line" id="L55">    .iv5 = <span class="tok-number">0x68581511</span>,</span>
<span class="line" id="L56">    .iv6 = <span class="tok-number">0x64F98FA7</span>,</span>
<span class="line" id="L57">    .iv7 = <span class="tok-number">0xBEFA4FA4</span>,</span>
<span class="line" id="L58">    .digest_bits = <span class="tok-number">224</span>,</span>
<span class="line" id="L59">};</span>
<span class="line" id="L60"></span>
<span class="line" id="L61"><span class="tok-kw">const</span> Sha256Params = Sha2Params32{</span>
<span class="line" id="L62">    .iv0 = <span class="tok-number">0x6A09E667</span>,</span>
<span class="line" id="L63">    .iv1 = <span class="tok-number">0xBB67AE85</span>,</span>
<span class="line" id="L64">    .iv2 = <span class="tok-number">0x3C6EF372</span>,</span>
<span class="line" id="L65">    .iv3 = <span class="tok-number">0xA54FF53A</span>,</span>
<span class="line" id="L66">    .iv4 = <span class="tok-number">0x510E527F</span>,</span>
<span class="line" id="L67">    .iv5 = <span class="tok-number">0x9B05688C</span>,</span>
<span class="line" id="L68">    .iv6 = <span class="tok-number">0x1F83D9AB</span>,</span>
<span class="line" id="L69">    .iv7 = <span class="tok-number">0x5BE0CD19</span>,</span>
<span class="line" id="L70">    .digest_bits = <span class="tok-number">256</span>,</span>
<span class="line" id="L71">};</span>
<span class="line" id="L72"></span>
<span class="line" id="L73"><span class="tok-comment">/// SHA-224</span></span>
<span class="line" id="L74"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Sha224 = Sha2x32(Sha224Params);</span>
<span class="line" id="L75"></span>
<span class="line" id="L76"><span class="tok-comment">/// SHA-256</span></span>
<span class="line" id="L77"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Sha256 = Sha2x32(Sha256Params);</span>
<span class="line" id="L78"></span>
<span class="line" id="L79"><span class="tok-kw">fn</span> <span class="tok-fn">Sha2x32</span>(<span class="tok-kw">comptime</span> params: Sha2Params32) <span class="tok-type">type</span> {</span>
<span class="line" id="L80">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L81">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L82">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> block_length = <span class="tok-number">64</span>;</span>
<span class="line" id="L83">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> digest_length = params.digest_bits / <span class="tok-number">8</span>;</span>
<span class="line" id="L84">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Options = <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L85"></span>
<span class="line" id="L86">        s: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>,</span>
<span class="line" id="L87">        <span class="tok-comment">// Streaming Cache</span>
</span>
<span class="line" id="L88">        buf: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L89">        buf_len: <span class="tok-type">u8</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L90">        total_len: <span class="tok-type">u64</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L91"></span>
<span class="line" id="L92">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(options: Options) Self {</span>
<span class="line" id="L93">            _ = options;</span>
<span class="line" id="L94">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L95">                .s = [_]<span class="tok-type">u32</span>{</span>
<span class="line" id="L96">                    params.iv0,</span>
<span class="line" id="L97">                    params.iv1,</span>
<span class="line" id="L98">                    params.iv2,</span>
<span class="line" id="L99">                    params.iv3,</span>
<span class="line" id="L100">                    params.iv4,</span>
<span class="line" id="L101">                    params.iv5,</span>
<span class="line" id="L102">                    params.iv6,</span>
<span class="line" id="L103">                    params.iv7,</span>
<span class="line" id="L104">                },</span>
<span class="line" id="L105">            };</span>
<span class="line" id="L106">        }</span>
<span class="line" id="L107"></span>
<span class="line" id="L108">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, out: *[digest_length]<span class="tok-type">u8</span>, options: Options) <span class="tok-type">void</span> {</span>
<span class="line" id="L109">            <span class="tok-kw">var</span> d = Self.init(options);</span>
<span class="line" id="L110">            d.update(b);</span>
<span class="line" id="L111">            d.final(out);</span>
<span class="line" id="L112">        }</span>
<span class="line" id="L113"></span>
<span class="line" id="L114">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(d: *Self, b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L115">            <span class="tok-kw">var</span> off: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L116"></span>
<span class="line" id="L117">            <span class="tok-comment">// Partial buffer exists from previous update. Copy into buffer then hash.</span>
</span>
<span class="line" id="L118">            <span class="tok-kw">if</span> (d.buf_len != <span class="tok-number">0</span> <span class="tok-kw">and</span> d.buf_len + b.len &gt;= <span class="tok-number">64</span>) {</span>
<span class="line" id="L119">                off += <span class="tok-number">64</span> - d.buf_len;</span>
<span class="line" id="L120">                mem.copy(<span class="tok-type">u8</span>, d.buf[d.buf_len..], b[<span class="tok-number">0</span>..off]);</span>
<span class="line" id="L121"></span>
<span class="line" id="L122">                d.round(&amp;d.buf);</span>
<span class="line" id="L123">                d.buf_len = <span class="tok-number">0</span>;</span>
<span class="line" id="L124">            }</span>
<span class="line" id="L125"></span>
<span class="line" id="L126">            <span class="tok-comment">// Full middle blocks.</span>
</span>
<span class="line" id="L127">            <span class="tok-kw">while</span> (off + <span class="tok-number">64</span> &lt;= b.len) : (off += <span class="tok-number">64</span>) {</span>
<span class="line" id="L128">                d.round(b[off..][<span class="tok-number">0</span>..<span class="tok-number">64</span>]);</span>
<span class="line" id="L129">            }</span>
<span class="line" id="L130"></span>
<span class="line" id="L131">            <span class="tok-comment">// Copy any remainder for next pass.</span>
</span>
<span class="line" id="L132">            mem.copy(<span class="tok-type">u8</span>, d.buf[d.buf_len..], b[off..]);</span>
<span class="line" id="L133">            d.buf_len += <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, b[off..].len);</span>
<span class="line" id="L134"></span>
<span class="line" id="L135">            d.total_len += b.len;</span>
<span class="line" id="L136">        }</span>
<span class="line" id="L137"></span>
<span class="line" id="L138">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">final</span>(d: *Self, out: *[digest_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L139">            <span class="tok-comment">// The buffer here will never be completely full.</span>
</span>
<span class="line" id="L140">            mem.set(<span class="tok-type">u8</span>, d.buf[d.buf_len..], <span class="tok-number">0</span>);</span>
<span class="line" id="L141"></span>
<span class="line" id="L142">            <span class="tok-comment">// Append padding bits.</span>
</span>
<span class="line" id="L143">            d.buf[d.buf_len] = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L144">            d.buf_len += <span class="tok-number">1</span>;</span>
<span class="line" id="L145"></span>
<span class="line" id="L146">            <span class="tok-comment">// &gt; 448 mod 512 so need to add an extra round to wrap around.</span>
</span>
<span class="line" id="L147">            <span class="tok-kw">if</span> (<span class="tok-number">64</span> - d.buf_len &lt; <span class="tok-number">8</span>) {</span>
<span class="line" id="L148">                d.round(&amp;d.buf);</span>
<span class="line" id="L149">                mem.set(<span class="tok-type">u8</span>, d.buf[<span class="tok-number">0</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L150">            }</span>
<span class="line" id="L151"></span>
<span class="line" id="L152">            <span class="tok-comment">// Append message length.</span>
</span>
<span class="line" id="L153">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L154">            <span class="tok-kw">var</span> len = d.total_len &gt;&gt; <span class="tok-number">5</span>;</span>
<span class="line" id="L155">            d.buf[<span class="tok-number">63</span>] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, d.total_len &amp; <span class="tok-number">0x1f</span>) &lt;&lt; <span class="tok-number">3</span>;</span>
<span class="line" id="L156">            <span class="tok-kw">while</span> (i &lt; <span class="tok-number">8</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L157">                d.buf[<span class="tok-number">63</span> - i] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, len &amp; <span class="tok-number">0xff</span>);</span>
<span class="line" id="L158">                len &gt;&gt;= <span class="tok-number">8</span>;</span>
<span class="line" id="L159">            }</span>
<span class="line" id="L160"></span>
<span class="line" id="L161">            d.round(&amp;d.buf);</span>
<span class="line" id="L162"></span>
<span class="line" id="L163">            <span class="tok-comment">// May truncate for possible 224 output</span>
</span>
<span class="line" id="L164">            <span class="tok-kw">const</span> rr = d.s[<span class="tok-number">0</span> .. params.digest_bits / <span class="tok-number">32</span>];</span>
<span class="line" id="L165"></span>
<span class="line" id="L166">            <span class="tok-kw">for</span> (rr) |s, j| {</span>
<span class="line" id="L167">                mem.writeIntBig(<span class="tok-type">u32</span>, out[<span class="tok-number">4</span> * j ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], s);</span>
<span class="line" id="L168">            }</span>
<span class="line" id="L169">        }</span>
<span class="line" id="L170"></span>
<span class="line" id="L171">        <span class="tok-kw">fn</span> <span class="tok-fn">round</span>(d: *Self, b: *<span class="tok-kw">const</span> [<span class="tok-number">64</span>]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L172">            <span class="tok-kw">var</span> s: [<span class="tok-number">64</span>]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L173"></span>
<span class="line" id="L174">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L175">            <span class="tok-kw">while</span> (i &lt; <span class="tok-number">16</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L176">                s[i] = <span class="tok-number">0</span>;</span>
<span class="line" id="L177">                s[i] |= <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[i * <span class="tok-number">4</span> + <span class="tok-number">0</span>]) &lt;&lt; <span class="tok-number">24</span>;</span>
<span class="line" id="L178">                s[i] |= <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[i * <span class="tok-number">4</span> + <span class="tok-number">1</span>]) &lt;&lt; <span class="tok-number">16</span>;</span>
<span class="line" id="L179">                s[i] |= <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[i * <span class="tok-number">4</span> + <span class="tok-number">2</span>]) &lt;&lt; <span class="tok-number">8</span>;</span>
<span class="line" id="L180">                s[i] |= <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, b[i * <span class="tok-number">4</span> + <span class="tok-number">3</span>]) &lt;&lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L181">            }</span>
<span class="line" id="L182">            <span class="tok-kw">while</span> (i &lt; <span class="tok-number">64</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L183">                s[i] = s[i - <span class="tok-number">16</span>] +% s[i - <span class="tok-number">7</span>] +% (math.rotr(<span class="tok-type">u32</span>, s[i - <span class="tok-number">15</span>], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">7</span>)) ^ math.rotr(<span class="tok-type">u32</span>, s[i - <span class="tok-number">15</span>], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">18</span>)) ^ (s[i - <span class="tok-number">15</span>] &gt;&gt; <span class="tok-number">3</span>)) +% (math.rotr(<span class="tok-type">u32</span>, s[i - <span class="tok-number">2</span>], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">17</span>)) ^ math.rotr(<span class="tok-type">u32</span>, s[i - <span class="tok-number">2</span>], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">19</span>)) ^ (s[i - <span class="tok-number">2</span>] &gt;&gt; <span class="tok-number">10</span>));</span>
<span class="line" id="L184">            }</span>
<span class="line" id="L185"></span>
<span class="line" id="L186">            <span class="tok-kw">var</span> v: [<span class="tok-number">8</span>]<span class="tok-type">u32</span> = [_]<span class="tok-type">u32</span>{</span>
<span class="line" id="L187">                d.s[<span class="tok-number">0</span>],</span>
<span class="line" id="L188">                d.s[<span class="tok-number">1</span>],</span>
<span class="line" id="L189">                d.s[<span class="tok-number">2</span>],</span>
<span class="line" id="L190">                d.s[<span class="tok-number">3</span>],</span>
<span class="line" id="L191">                d.s[<span class="tok-number">4</span>],</span>
<span class="line" id="L192">                d.s[<span class="tok-number">5</span>],</span>
<span class="line" id="L193">                d.s[<span class="tok-number">6</span>],</span>
<span class="line" id="L194">                d.s[<span class="tok-number">7</span>],</span>
<span class="line" id="L195">            };</span>
<span class="line" id="L196"></span>
<span class="line" id="L197">            <span class="tok-kw">const</span> round0 = <span class="tok-kw">comptime</span> [_]RoundParam256{</span>
<span class="line" id="L198">                roundParam256(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">0x428A2F98</span>),</span>
<span class="line" id="L199">                roundParam256(<span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">1</span>, <span class="tok-number">0x71374491</span>),</span>
<span class="line" id="L200">                roundParam256(<span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">2</span>, <span class="tok-number">0xB5C0FBCF</span>),</span>
<span class="line" id="L201">                roundParam256(<span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">3</span>, <span class="tok-number">0xE9B5DBA5</span>),</span>
<span class="line" id="L202">                roundParam256(<span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0x3956C25B</span>),</span>
<span class="line" id="L203">                roundParam256(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">5</span>, <span class="tok-number">0x59F111F1</span>),</span>
<span class="line" id="L204">                roundParam256(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">6</span>, <span class="tok-number">0x923F82A4</span>),</span>
<span class="line" id="L205">                roundParam256(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">7</span>, <span class="tok-number">0xAB1C5ED5</span>),</span>
<span class="line" id="L206">                roundParam256(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span>, <span class="tok-number">0xD807AA98</span>),</span>
<span class="line" id="L207">                roundParam256(<span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">9</span>, <span class="tok-number">0x12835B01</span>),</span>
<span class="line" id="L208">                roundParam256(<span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">10</span>, <span class="tok-number">0x243185BE</span>),</span>
<span class="line" id="L209">                roundParam256(<span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">11</span>, <span class="tok-number">0x550C7DC3</span>),</span>
<span class="line" id="L210">                roundParam256(<span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">12</span>, <span class="tok-number">0x72BE5D74</span>),</span>
<span class="line" id="L211">                roundParam256(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">13</span>, <span class="tok-number">0x80DEB1FE</span>),</span>
<span class="line" id="L212">                roundParam256(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">14</span>, <span class="tok-number">0x9BDC06A7</span>),</span>
<span class="line" id="L213">                roundParam256(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">15</span>, <span class="tok-number">0xC19BF174</span>),</span>
<span class="line" id="L214">                roundParam256(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">16</span>, <span class="tok-number">0xE49B69C1</span>),</span>
<span class="line" id="L215">                roundParam256(<span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">17</span>, <span class="tok-number">0xEFBE4786</span>),</span>
<span class="line" id="L216">                roundParam256(<span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">18</span>, <span class="tok-number">0x0FC19DC6</span>),</span>
<span class="line" id="L217">                roundParam256(<span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">19</span>, <span class="tok-number">0x240CA1CC</span>),</span>
<span class="line" id="L218">                roundParam256(<span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">20</span>, <span class="tok-number">0x2DE92C6F</span>),</span>
<span class="line" id="L219">                roundParam256(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">21</span>, <span class="tok-number">0x4A7484AA</span>),</span>
<span class="line" id="L220">                roundParam256(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">22</span>, <span class="tok-number">0x5CB0A9DC</span>),</span>
<span class="line" id="L221">                roundParam256(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">23</span>, <span class="tok-number">0x76F988DA</span>),</span>
<span class="line" id="L222">                roundParam256(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">24</span>, <span class="tok-number">0x983E5152</span>),</span>
<span class="line" id="L223">                roundParam256(<span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">25</span>, <span class="tok-number">0xA831C66D</span>),</span>
<span class="line" id="L224">                roundParam256(<span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">26</span>, <span class="tok-number">0xB00327C8</span>),</span>
<span class="line" id="L225">                roundParam256(<span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">27</span>, <span class="tok-number">0xBF597FC7</span>),</span>
<span class="line" id="L226">                roundParam256(<span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">28</span>, <span class="tok-number">0xC6E00BF3</span>),</span>
<span class="line" id="L227">                roundParam256(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">29</span>, <span class="tok-number">0xD5A79147</span>),</span>
<span class="line" id="L228">                roundParam256(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">30</span>, <span class="tok-number">0x06CA6351</span>),</span>
<span class="line" id="L229">                roundParam256(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">31</span>, <span class="tok-number">0x14292967</span>),</span>
<span class="line" id="L230">                roundParam256(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">32</span>, <span class="tok-number">0x27B70A85</span>),</span>
<span class="line" id="L231">                roundParam256(<span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">33</span>, <span class="tok-number">0x2E1B2138</span>),</span>
<span class="line" id="L232">                roundParam256(<span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">34</span>, <span class="tok-number">0x4D2C6DFC</span>),</span>
<span class="line" id="L233">                roundParam256(<span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">35</span>, <span class="tok-number">0x53380D13</span>),</span>
<span class="line" id="L234">                roundParam256(<span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">36</span>, <span class="tok-number">0x650A7354</span>),</span>
<span class="line" id="L235">                roundParam256(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">37</span>, <span class="tok-number">0x766A0ABB</span>),</span>
<span class="line" id="L236">                roundParam256(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">38</span>, <span class="tok-number">0x81C2C92E</span>),</span>
<span class="line" id="L237">                roundParam256(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">39</span>, <span class="tok-number">0x92722C85</span>),</span>
<span class="line" id="L238">                roundParam256(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">40</span>, <span class="tok-number">0xA2BFE8A1</span>),</span>
<span class="line" id="L239">                roundParam256(<span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">41</span>, <span class="tok-number">0xA81A664B</span>),</span>
<span class="line" id="L240">                roundParam256(<span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">42</span>, <span class="tok-number">0xC24B8B70</span>),</span>
<span class="line" id="L241">                roundParam256(<span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">43</span>, <span class="tok-number">0xC76C51A3</span>),</span>
<span class="line" id="L242">                roundParam256(<span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">44</span>, <span class="tok-number">0xD192E819</span>),</span>
<span class="line" id="L243">                roundParam256(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">45</span>, <span class="tok-number">0xD6990624</span>),</span>
<span class="line" id="L244">                roundParam256(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">46</span>, <span class="tok-number">0xF40E3585</span>),</span>
<span class="line" id="L245">                roundParam256(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">47</span>, <span class="tok-number">0x106AA070</span>),</span>
<span class="line" id="L246">                roundParam256(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">48</span>, <span class="tok-number">0x19A4C116</span>),</span>
<span class="line" id="L247">                roundParam256(<span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">49</span>, <span class="tok-number">0x1E376C08</span>),</span>
<span class="line" id="L248">                roundParam256(<span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">50</span>, <span class="tok-number">0x2748774C</span>),</span>
<span class="line" id="L249">                roundParam256(<span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">51</span>, <span class="tok-number">0x34B0BCB5</span>),</span>
<span class="line" id="L250">                roundParam256(<span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">52</span>, <span class="tok-number">0x391C0CB3</span>),</span>
<span class="line" id="L251">                roundParam256(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">53</span>, <span class="tok-number">0x4ED8AA4A</span>),</span>
<span class="line" id="L252">                roundParam256(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">54</span>, <span class="tok-number">0x5B9CCA4F</span>),</span>
<span class="line" id="L253">                roundParam256(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">55</span>, <span class="tok-number">0x682E6FF3</span>),</span>
<span class="line" id="L254">                roundParam256(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">56</span>, <span class="tok-number">0x748F82EE</span>),</span>
<span class="line" id="L255">                roundParam256(<span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">57</span>, <span class="tok-number">0x78A5636F</span>),</span>
<span class="line" id="L256">                roundParam256(<span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">58</span>, <span class="tok-number">0x84C87814</span>),</span>
<span class="line" id="L257">                roundParam256(<span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">59</span>, <span class="tok-number">0x8CC70208</span>),</span>
<span class="line" id="L258">                roundParam256(<span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">60</span>, <span class="tok-number">0x90BEFFFA</span>),</span>
<span class="line" id="L259">                roundParam256(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">61</span>, <span class="tok-number">0xA4506CEB</span>),</span>
<span class="line" id="L260">                roundParam256(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">62</span>, <span class="tok-number">0xBEF9A3F7</span>),</span>
<span class="line" id="L261">                roundParam256(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">63</span>, <span class="tok-number">0xC67178F2</span>),</span>
<span class="line" id="L262">            };</span>
<span class="line" id="L263">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (round0) |r| {</span>
<span class="line" id="L264">                v[r.h] = v[r.h] +% (math.rotr(<span class="tok-type">u32</span>, v[r.e], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">6</span>)) ^ math.rotr(<span class="tok-type">u32</span>, v[r.e], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">11</span>)) ^ math.rotr(<span class="tok-type">u32</span>, v[r.e], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">25</span>))) +% (v[r.g] ^ (v[r.e] &amp; (v[r.f] ^ v[r.g]))) +% r.k +% s[r.i];</span>
<span class="line" id="L265"></span>
<span class="line" id="L266">                v[r.d] = v[r.d] +% v[r.h];</span>
<span class="line" id="L267"></span>
<span class="line" id="L268">                v[r.h] = v[r.h] +% (math.rotr(<span class="tok-type">u32</span>, v[r.a], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">2</span>)) ^ math.rotr(<span class="tok-type">u32</span>, v[r.a], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">13</span>)) ^ math.rotr(<span class="tok-type">u32</span>, v[r.a], <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">22</span>))) +% ((v[r.a] &amp; (v[r.b] | v[r.c])) | (v[r.b] &amp; v[r.c]));</span>
<span class="line" id="L269">            }</span>
<span class="line" id="L270"></span>
<span class="line" id="L271">            d.s[<span class="tok-number">0</span>] +%= v[<span class="tok-number">0</span>];</span>
<span class="line" id="L272">            d.s[<span class="tok-number">1</span>] +%= v[<span class="tok-number">1</span>];</span>
<span class="line" id="L273">            d.s[<span class="tok-number">2</span>] +%= v[<span class="tok-number">2</span>];</span>
<span class="line" id="L274">            d.s[<span class="tok-number">3</span>] +%= v[<span class="tok-number">3</span>];</span>
<span class="line" id="L275">            d.s[<span class="tok-number">4</span>] +%= v[<span class="tok-number">4</span>];</span>
<span class="line" id="L276">            d.s[<span class="tok-number">5</span>] +%= v[<span class="tok-number">5</span>];</span>
<span class="line" id="L277">            d.s[<span class="tok-number">6</span>] +%= v[<span class="tok-number">6</span>];</span>
<span class="line" id="L278">            d.s[<span class="tok-number">7</span>] +%= v[<span class="tok-number">7</span>];</span>
<span class="line" id="L279">        }</span>
<span class="line" id="L280"></span>
<span class="line" id="L281">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-kw">error</span>{};</span>
<span class="line" id="L282">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Writer = std.io.Writer(*Self, Error, write);</span>
<span class="line" id="L283"></span>
<span class="line" id="L284">        <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: *Self, bytes: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Error!<span class="tok-type">usize</span> {</span>
<span class="line" id="L285">            self.update(bytes);</span>
<span class="line" id="L286">            <span class="tok-kw">return</span> bytes.len;</span>
<span class="line" id="L287">        }</span>
<span class="line" id="L288"></span>
<span class="line" id="L289">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writer</span>(self: *Self) Writer {</span>
<span class="line" id="L290">            <span class="tok-kw">return</span> .{ .context = self };</span>
<span class="line" id="L291">        }</span>
<span class="line" id="L292">    };</span>
<span class="line" id="L293">}</span>
<span class="line" id="L294"></span>
<span class="line" id="L295"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha224 single&quot;</span> {</span>
<span class="line" id="L296">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha224, <span class="tok-str">&quot;d14a028c2a3a2bc9476102bb288234c415a2b01f828ea62ac5b3e42f&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L297">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha224, <span class="tok-str">&quot;23097d223405d8228642a477bda255b32aadbce4bda0b3f7e36c9da7&quot;</span>, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L298">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha224, <span class="tok-str">&quot;c97ca9a559850ce97a04a96def6d99a9e0e0e2ab14e6b8df265fc0b3&quot;</span>, <span class="tok-str">&quot;abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu&quot;</span>);</span>
<span class="line" id="L299">}</span>
<span class="line" id="L300"></span>
<span class="line" id="L301"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha224 streaming&quot;</span> {</span>
<span class="line" id="L302">    <span class="tok-kw">var</span> h = Sha224.init(.{});</span>
<span class="line" id="L303">    <span class="tok-kw">var</span> out: [<span class="tok-number">28</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L304"></span>
<span class="line" id="L305">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L306">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;d14a028c2a3a2bc9476102bb288234c415a2b01f828ea62ac5b3e42f&quot;</span>, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L307"></span>
<span class="line" id="L308">    h = Sha224.init(.{});</span>
<span class="line" id="L309">    h.update(<span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L310">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L311">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;23097d223405d8228642a477bda255b32aadbce4bda0b3f7e36c9da7&quot;</span>, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L312"></span>
<span class="line" id="L313">    h = Sha224.init(.{});</span>
<span class="line" id="L314">    h.update(<span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L315">    h.update(<span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L316">    h.update(<span class="tok-str">&quot;c&quot;</span>);</span>
<span class="line" id="L317">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L318">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;23097d223405d8228642a477bda255b32aadbce4bda0b3f7e36c9da7&quot;</span>, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L319">}</span>
<span class="line" id="L320"></span>
<span class="line" id="L321"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha256 single&quot;</span> {</span>
<span class="line" id="L322">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha256, <span class="tok-str">&quot;e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855&quot;</span>, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L323">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha256, <span class="tok-str">&quot;ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad&quot;</span>, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L324">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha256, <span class="tok-str">&quot;cf5b16a778af8380036ce59e7b0492370b249b11e8f07a51afac45037afee9d1&quot;</span>, <span class="tok-str">&quot;abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu&quot;</span>);</span>
<span class="line" id="L325">}</span>
<span class="line" id="L326"></span>
<span class="line" id="L327"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha256 streaming&quot;</span> {</span>
<span class="line" id="L328">    <span class="tok-kw">var</span> h = Sha256.init(.{});</span>
<span class="line" id="L329">    <span class="tok-kw">var</span> out: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L330"></span>
<span class="line" id="L331">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L332">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855&quot;</span>, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L333"></span>
<span class="line" id="L334">    h = Sha256.init(.{});</span>
<span class="line" id="L335">    h.update(<span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L336">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L337">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad&quot;</span>, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L338"></span>
<span class="line" id="L339">    h = Sha256.init(.{});</span>
<span class="line" id="L340">    h.update(<span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L341">    h.update(<span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L342">    h.update(<span class="tok-str">&quot;c&quot;</span>);</span>
<span class="line" id="L343">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L344">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad&quot;</span>, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L345">}</span>
<span class="line" id="L346"></span>
<span class="line" id="L347"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha256 aligned final&quot;</span> {</span>
<span class="line" id="L348">    <span class="tok-kw">var</span> block = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** Sha256.block_length;</span>
<span class="line" id="L349">    <span class="tok-kw">var</span> out: [Sha256.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L350"></span>
<span class="line" id="L351">    <span class="tok-kw">var</span> h = Sha256.init(.{});</span>
<span class="line" id="L352">    h.update(&amp;block);</span>
<span class="line" id="L353">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L354">}</span>
<span class="line" id="L355"></span>
<span class="line" id="L356"><span class="tok-comment">/////////////////////</span>
</span>
<span class="line" id="L357"><span class="tok-comment">// Sha384 + Sha512</span>
</span>
<span class="line" id="L358"></span>
<span class="line" id="L359"><span class="tok-kw">const</span> RoundParam512 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L360">    a: <span class="tok-type">usize</span>,</span>
<span class="line" id="L361">    b: <span class="tok-type">usize</span>,</span>
<span class="line" id="L362">    c: <span class="tok-type">usize</span>,</span>
<span class="line" id="L363">    d: <span class="tok-type">usize</span>,</span>
<span class="line" id="L364">    e: <span class="tok-type">usize</span>,</span>
<span class="line" id="L365">    f: <span class="tok-type">usize</span>,</span>
<span class="line" id="L366">    g: <span class="tok-type">usize</span>,</span>
<span class="line" id="L367">    h: <span class="tok-type">usize</span>,</span>
<span class="line" id="L368">    i: <span class="tok-type">usize</span>,</span>
<span class="line" id="L369">    k: <span class="tok-type">u64</span>,</span>
<span class="line" id="L370">};</span>
<span class="line" id="L371"></span>
<span class="line" id="L372"><span class="tok-kw">fn</span> <span class="tok-fn">roundParam512</span>(a: <span class="tok-type">usize</span>, b: <span class="tok-type">usize</span>, c: <span class="tok-type">usize</span>, d: <span class="tok-type">usize</span>, e: <span class="tok-type">usize</span>, f: <span class="tok-type">usize</span>, g: <span class="tok-type">usize</span>, h: <span class="tok-type">usize</span>, i: <span class="tok-type">usize</span>, k: <span class="tok-type">u64</span>) RoundParam512 {</span>
<span class="line" id="L373">    <span class="tok-kw">return</span> RoundParam512{</span>
<span class="line" id="L374">        .a = a,</span>
<span class="line" id="L375">        .b = b,</span>
<span class="line" id="L376">        .c = c,</span>
<span class="line" id="L377">        .d = d,</span>
<span class="line" id="L378">        .e = e,</span>
<span class="line" id="L379">        .f = f,</span>
<span class="line" id="L380">        .g = g,</span>
<span class="line" id="L381">        .h = h,</span>
<span class="line" id="L382">        .i = i,</span>
<span class="line" id="L383">        .k = k,</span>
<span class="line" id="L384">    };</span>
<span class="line" id="L385">}</span>
<span class="line" id="L386"></span>
<span class="line" id="L387"><span class="tok-kw">const</span> Sha2Params64 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L388">    iv0: <span class="tok-type">u64</span>,</span>
<span class="line" id="L389">    iv1: <span class="tok-type">u64</span>,</span>
<span class="line" id="L390">    iv2: <span class="tok-type">u64</span>,</span>
<span class="line" id="L391">    iv3: <span class="tok-type">u64</span>,</span>
<span class="line" id="L392">    iv4: <span class="tok-type">u64</span>,</span>
<span class="line" id="L393">    iv5: <span class="tok-type">u64</span>,</span>
<span class="line" id="L394">    iv6: <span class="tok-type">u64</span>,</span>
<span class="line" id="L395">    iv7: <span class="tok-type">u64</span>,</span>
<span class="line" id="L396">    digest_bits: <span class="tok-type">usize</span>,</span>
<span class="line" id="L397">};</span>
<span class="line" id="L398"></span>
<span class="line" id="L399"><span class="tok-kw">const</span> Sha384Params = Sha2Params64{</span>
<span class="line" id="L400">    .iv0 = <span class="tok-number">0xCBBB9D5DC1059ED8</span>,</span>
<span class="line" id="L401">    .iv1 = <span class="tok-number">0x629A292A367CD507</span>,</span>
<span class="line" id="L402">    .iv2 = <span class="tok-number">0x9159015A3070DD17</span>,</span>
<span class="line" id="L403">    .iv3 = <span class="tok-number">0x152FECD8F70E5939</span>,</span>
<span class="line" id="L404">    .iv4 = <span class="tok-number">0x67332667FFC00B31</span>,</span>
<span class="line" id="L405">    .iv5 = <span class="tok-number">0x8EB44A8768581511</span>,</span>
<span class="line" id="L406">    .iv6 = <span class="tok-number">0xDB0C2E0D64F98FA7</span>,</span>
<span class="line" id="L407">    .iv7 = <span class="tok-number">0x47B5481DBEFA4FA4</span>,</span>
<span class="line" id="L408">    .digest_bits = <span class="tok-number">384</span>,</span>
<span class="line" id="L409">};</span>
<span class="line" id="L410"></span>
<span class="line" id="L411"><span class="tok-kw">const</span> Sha512Params = Sha2Params64{</span>
<span class="line" id="L412">    .iv0 = <span class="tok-number">0x6A09E667F3BCC908</span>,</span>
<span class="line" id="L413">    .iv1 = <span class="tok-number">0xBB67AE8584CAA73B</span>,</span>
<span class="line" id="L414">    .iv2 = <span class="tok-number">0x3C6EF372FE94F82B</span>,</span>
<span class="line" id="L415">    .iv3 = <span class="tok-number">0xA54FF53A5F1D36F1</span>,</span>
<span class="line" id="L416">    .iv4 = <span class="tok-number">0x510E527FADE682D1</span>,</span>
<span class="line" id="L417">    .iv5 = <span class="tok-number">0x9B05688C2B3E6C1F</span>,</span>
<span class="line" id="L418">    .iv6 = <span class="tok-number">0x1F83D9ABFB41BD6B</span>,</span>
<span class="line" id="L419">    .iv7 = <span class="tok-number">0x5BE0CD19137E2179</span>,</span>
<span class="line" id="L420">    .digest_bits = <span class="tok-number">512</span>,</span>
<span class="line" id="L421">};</span>
<span class="line" id="L422"></span>
<span class="line" id="L423"><span class="tok-kw">const</span> Sha512256Params = Sha2Params64{</span>
<span class="line" id="L424">    .iv0 = <span class="tok-number">0x22312194FC2BF72C</span>,</span>
<span class="line" id="L425">    .iv1 = <span class="tok-number">0x9F555FA3C84C64C2</span>,</span>
<span class="line" id="L426">    .iv2 = <span class="tok-number">0x2393B86B6F53B151</span>,</span>
<span class="line" id="L427">    .iv3 = <span class="tok-number">0x963877195940EABD</span>,</span>
<span class="line" id="L428">    .iv4 = <span class="tok-number">0x96283EE2A88EFFE3</span>,</span>
<span class="line" id="L429">    .iv5 = <span class="tok-number">0xBE5E1E2553863992</span>,</span>
<span class="line" id="L430">    .iv6 = <span class="tok-number">0x2B0199FC2C85B8AA</span>,</span>
<span class="line" id="L431">    .iv7 = <span class="tok-number">0x0EB72DDC81C52CA2</span>,</span>
<span class="line" id="L432">    .digest_bits = <span class="tok-number">256</span>,</span>
<span class="line" id="L433">};</span>
<span class="line" id="L434"></span>
<span class="line" id="L435"><span class="tok-kw">const</span> Sha512T256Params = Sha2Params64{</span>
<span class="line" id="L436">    .iv0 = <span class="tok-number">0x6A09E667F3BCC908</span>,</span>
<span class="line" id="L437">    .iv1 = <span class="tok-number">0xBB67AE8584CAA73B</span>,</span>
<span class="line" id="L438">    .iv2 = <span class="tok-number">0x3C6EF372FE94F82B</span>,</span>
<span class="line" id="L439">    .iv3 = <span class="tok-number">0xA54FF53A5F1D36F1</span>,</span>
<span class="line" id="L440">    .iv4 = <span class="tok-number">0x510E527FADE682D1</span>,</span>
<span class="line" id="L441">    .iv5 = <span class="tok-number">0x9B05688C2B3E6C1F</span>,</span>
<span class="line" id="L442">    .iv6 = <span class="tok-number">0x1F83D9ABFB41BD6B</span>,</span>
<span class="line" id="L443">    .iv7 = <span class="tok-number">0x5BE0CD19137E2179</span>,</span>
<span class="line" id="L444">    .digest_bits = <span class="tok-number">256</span>,</span>
<span class="line" id="L445">};</span>
<span class="line" id="L446"></span>
<span class="line" id="L447"><span class="tok-comment">/// SHA-384</span></span>
<span class="line" id="L448"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Sha384 = Sha2x64(Sha384Params);</span>
<span class="line" id="L449"></span>
<span class="line" id="L450"><span class="tok-comment">/// SHA-512</span></span>
<span class="line" id="L451"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Sha512 = Sha2x64(Sha512Params);</span>
<span class="line" id="L452"></span>
<span class="line" id="L453"><span class="tok-comment">/// SHA-512/256</span></span>
<span class="line" id="L454"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Sha512256 = Sha2x64(Sha512256Params);</span>
<span class="line" id="L455"></span>
<span class="line" id="L456"><span class="tok-comment">/// Truncated SHA-512</span></span>
<span class="line" id="L457"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Sha512T256 = Sha2x64(Sha512T256Params);</span>
<span class="line" id="L458"></span>
<span class="line" id="L459"><span class="tok-kw">fn</span> <span class="tok-fn">Sha2x64</span>(<span class="tok-kw">comptime</span> params: Sha2Params64) <span class="tok-type">type</span> {</span>
<span class="line" id="L460">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L461">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L462">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> block_length = <span class="tok-number">128</span>;</span>
<span class="line" id="L463">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> digest_length = params.digest_bits / <span class="tok-number">8</span>;</span>
<span class="line" id="L464">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Options = <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L465"></span>
<span class="line" id="L466">        s: [<span class="tok-number">8</span>]<span class="tok-type">u64</span>,</span>
<span class="line" id="L467">        <span class="tok-comment">// Streaming Cache</span>
</span>
<span class="line" id="L468">        buf: [<span class="tok-number">128</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L469">        buf_len: <span class="tok-type">u8</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L470">        total_len: <span class="tok-type">u128</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L471"></span>
<span class="line" id="L472">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(options: Options) Self {</span>
<span class="line" id="L473">            _ = options;</span>
<span class="line" id="L474">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L475">                .s = [_]<span class="tok-type">u64</span>{</span>
<span class="line" id="L476">                    params.iv0,</span>
<span class="line" id="L477">                    params.iv1,</span>
<span class="line" id="L478">                    params.iv2,</span>
<span class="line" id="L479">                    params.iv3,</span>
<span class="line" id="L480">                    params.iv4,</span>
<span class="line" id="L481">                    params.iv5,</span>
<span class="line" id="L482">                    params.iv6,</span>
<span class="line" id="L483">                    params.iv7,</span>
<span class="line" id="L484">                },</span>
<span class="line" id="L485">            };</span>
<span class="line" id="L486">        }</span>
<span class="line" id="L487"></span>
<span class="line" id="L488">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hash</span>(b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, out: *[digest_length]<span class="tok-type">u8</span>, options: Options) <span class="tok-type">void</span> {</span>
<span class="line" id="L489">            <span class="tok-kw">var</span> d = Self.init(options);</span>
<span class="line" id="L490">            d.update(b);</span>
<span class="line" id="L491">            d.final(out);</span>
<span class="line" id="L492">        }</span>
<span class="line" id="L493"></span>
<span class="line" id="L494">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(d: *Self, b: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L495">            <span class="tok-kw">var</span> off: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L496"></span>
<span class="line" id="L497">            <span class="tok-comment">// Partial buffer exists from previous update. Copy into buffer then hash.</span>
</span>
<span class="line" id="L498">            <span class="tok-kw">if</span> (d.buf_len != <span class="tok-number">0</span> <span class="tok-kw">and</span> d.buf_len + b.len &gt;= <span class="tok-number">128</span>) {</span>
<span class="line" id="L499">                off += <span class="tok-number">128</span> - d.buf_len;</span>
<span class="line" id="L500">                mem.copy(<span class="tok-type">u8</span>, d.buf[d.buf_len..], b[<span class="tok-number">0</span>..off]);</span>
<span class="line" id="L501"></span>
<span class="line" id="L502">                d.round(&amp;d.buf);</span>
<span class="line" id="L503">                d.buf_len = <span class="tok-number">0</span>;</span>
<span class="line" id="L504">            }</span>
<span class="line" id="L505"></span>
<span class="line" id="L506">            <span class="tok-comment">// Full middle blocks.</span>
</span>
<span class="line" id="L507">            <span class="tok-kw">while</span> (off + <span class="tok-number">128</span> &lt;= b.len) : (off += <span class="tok-number">128</span>) {</span>
<span class="line" id="L508">                d.round(b[off..][<span class="tok-number">0</span>..<span class="tok-number">128</span>]);</span>
<span class="line" id="L509">            }</span>
<span class="line" id="L510"></span>
<span class="line" id="L511">            <span class="tok-comment">// Copy any remainder for next pass.</span>
</span>
<span class="line" id="L512">            mem.copy(<span class="tok-type">u8</span>, d.buf[d.buf_len..], b[off..]);</span>
<span class="line" id="L513">            d.buf_len += <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, b[off..].len);</span>
<span class="line" id="L514"></span>
<span class="line" id="L515">            d.total_len += b.len;</span>
<span class="line" id="L516">        }</span>
<span class="line" id="L517"></span>
<span class="line" id="L518">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">final</span>(d: *Self, out: *[digest_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L519">            <span class="tok-comment">// The buffer here will never be completely full.</span>
</span>
<span class="line" id="L520">            mem.set(<span class="tok-type">u8</span>, d.buf[d.buf_len..], <span class="tok-number">0</span>);</span>
<span class="line" id="L521"></span>
<span class="line" id="L522">            <span class="tok-comment">// Append padding bits.</span>
</span>
<span class="line" id="L523">            d.buf[d.buf_len] = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L524">            d.buf_len += <span class="tok-number">1</span>;</span>
<span class="line" id="L525"></span>
<span class="line" id="L526">            <span class="tok-comment">// &gt; 896 mod 1024 so need to add an extra round to wrap around.</span>
</span>
<span class="line" id="L527">            <span class="tok-kw">if</span> (<span class="tok-number">128</span> - d.buf_len &lt; <span class="tok-number">16</span>) {</span>
<span class="line" id="L528">                d.round(d.buf[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L529">                mem.set(<span class="tok-type">u8</span>, d.buf[<span class="tok-number">0</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L530">            }</span>
<span class="line" id="L531"></span>
<span class="line" id="L532">            <span class="tok-comment">// Append message length.</span>
</span>
<span class="line" id="L533">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L534">            <span class="tok-kw">var</span> len = d.total_len &gt;&gt; <span class="tok-number">5</span>;</span>
<span class="line" id="L535">            d.buf[<span class="tok-number">127</span>] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, d.total_len &amp; <span class="tok-number">0x1f</span>) &lt;&lt; <span class="tok-number">3</span>;</span>
<span class="line" id="L536">            <span class="tok-kw">while</span> (i &lt; <span class="tok-number">16</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L537">                d.buf[<span class="tok-number">127</span> - i] = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, len &amp; <span class="tok-number">0xff</span>);</span>
<span class="line" id="L538">                len &gt;&gt;= <span class="tok-number">8</span>;</span>
<span class="line" id="L539">            }</span>
<span class="line" id="L540"></span>
<span class="line" id="L541">            d.round(d.buf[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L542"></span>
<span class="line" id="L543">            <span class="tok-comment">// May truncate for possible 384 output</span>
</span>
<span class="line" id="L544">            <span class="tok-kw">const</span> rr = d.s[<span class="tok-number">0</span> .. params.digest_bits / <span class="tok-number">64</span>];</span>
<span class="line" id="L545"></span>
<span class="line" id="L546">            <span class="tok-kw">for</span> (rr) |s, j| {</span>
<span class="line" id="L547">                mem.writeIntBig(<span class="tok-type">u64</span>, out[<span class="tok-number">8</span> * j ..][<span class="tok-number">0</span>..<span class="tok-number">8</span>], s);</span>
<span class="line" id="L548">            }</span>
<span class="line" id="L549">        }</span>
<span class="line" id="L550"></span>
<span class="line" id="L551">        <span class="tok-kw">fn</span> <span class="tok-fn">round</span>(d: *Self, b: *<span class="tok-kw">const</span> [<span class="tok-number">128</span>]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L552">            <span class="tok-kw">var</span> s: [<span class="tok-number">80</span>]<span class="tok-type">u64</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L553"></span>
<span class="line" id="L554">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L555">            <span class="tok-kw">while</span> (i &lt; <span class="tok-number">16</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L556">                s[i] = <span class="tok-number">0</span>;</span>
<span class="line" id="L557">                s[i] |= <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, b[i * <span class="tok-number">8</span> + <span class="tok-number">0</span>]) &lt;&lt; <span class="tok-number">56</span>;</span>
<span class="line" id="L558">                s[i] |= <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, b[i * <span class="tok-number">8</span> + <span class="tok-number">1</span>]) &lt;&lt; <span class="tok-number">48</span>;</span>
<span class="line" id="L559">                s[i] |= <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, b[i * <span class="tok-number">8</span> + <span class="tok-number">2</span>]) &lt;&lt; <span class="tok-number">40</span>;</span>
<span class="line" id="L560">                s[i] |= <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, b[i * <span class="tok-number">8</span> + <span class="tok-number">3</span>]) &lt;&lt; <span class="tok-number">32</span>;</span>
<span class="line" id="L561">                s[i] |= <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, b[i * <span class="tok-number">8</span> + <span class="tok-number">4</span>]) &lt;&lt; <span class="tok-number">24</span>;</span>
<span class="line" id="L562">                s[i] |= <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, b[i * <span class="tok-number">8</span> + <span class="tok-number">5</span>]) &lt;&lt; <span class="tok-number">16</span>;</span>
<span class="line" id="L563">                s[i] |= <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, b[i * <span class="tok-number">8</span> + <span class="tok-number">6</span>]) &lt;&lt; <span class="tok-number">8</span>;</span>
<span class="line" id="L564">                s[i] |= <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, b[i * <span class="tok-number">8</span> + <span class="tok-number">7</span>]) &lt;&lt; <span class="tok-number">0</span>;</span>
<span class="line" id="L565">            }</span>
<span class="line" id="L566">            <span class="tok-kw">while</span> (i &lt; <span class="tok-number">80</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L567">                s[i] = s[i - <span class="tok-number">16</span>] +% s[i - <span class="tok-number">7</span>] +%</span>
<span class="line" id="L568">                    (math.rotr(<span class="tok-type">u64</span>, s[i - <span class="tok-number">15</span>], <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">1</span>)) ^ math.rotr(<span class="tok-type">u64</span>, s[i - <span class="tok-number">15</span>], <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">8</span>)) ^ (s[i - <span class="tok-number">15</span>] &gt;&gt; <span class="tok-number">7</span>)) +%</span>
<span class="line" id="L569">                    (math.rotr(<span class="tok-type">u64</span>, s[i - <span class="tok-number">2</span>], <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">19</span>)) ^ math.rotr(<span class="tok-type">u64</span>, s[i - <span class="tok-number">2</span>], <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">61</span>)) ^ (s[i - <span class="tok-number">2</span>] &gt;&gt; <span class="tok-number">6</span>));</span>
<span class="line" id="L570">            }</span>
<span class="line" id="L571"></span>
<span class="line" id="L572">            <span class="tok-kw">var</span> v: [<span class="tok-number">8</span>]<span class="tok-type">u64</span> = [_]<span class="tok-type">u64</span>{</span>
<span class="line" id="L573">                d.s[<span class="tok-number">0</span>],</span>
<span class="line" id="L574">                d.s[<span class="tok-number">1</span>],</span>
<span class="line" id="L575">                d.s[<span class="tok-number">2</span>],</span>
<span class="line" id="L576">                d.s[<span class="tok-number">3</span>],</span>
<span class="line" id="L577">                d.s[<span class="tok-number">4</span>],</span>
<span class="line" id="L578">                d.s[<span class="tok-number">5</span>],</span>
<span class="line" id="L579">                d.s[<span class="tok-number">6</span>],</span>
<span class="line" id="L580">                d.s[<span class="tok-number">7</span>],</span>
<span class="line" id="L581">            };</span>
<span class="line" id="L582"></span>
<span class="line" id="L583">            <span class="tok-kw">const</span> round0 = <span class="tok-kw">comptime</span> [_]RoundParam512{</span>
<span class="line" id="L584">                roundParam512(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">0x428A2F98D728AE22</span>),</span>
<span class="line" id="L585">                roundParam512(<span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">1</span>, <span class="tok-number">0x7137449123EF65CD</span>),</span>
<span class="line" id="L586">                roundParam512(<span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">2</span>, <span class="tok-number">0xB5C0FBCFEC4D3B2F</span>),</span>
<span class="line" id="L587">                roundParam512(<span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">3</span>, <span class="tok-number">0xE9B5DBA58189DBBC</span>),</span>
<span class="line" id="L588">                roundParam512(<span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">0x3956C25BF348B538</span>),</span>
<span class="line" id="L589">                roundParam512(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">5</span>, <span class="tok-number">0x59F111F1B605D019</span>),</span>
<span class="line" id="L590">                roundParam512(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">6</span>, <span class="tok-number">0x923F82A4AF194F9B</span>),</span>
<span class="line" id="L591">                roundParam512(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">7</span>, <span class="tok-number">0xAB1C5ED5DA6D8118</span>),</span>
<span class="line" id="L592">                roundParam512(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">8</span>, <span class="tok-number">0xD807AA98A3030242</span>),</span>
<span class="line" id="L593">                roundParam512(<span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">9</span>, <span class="tok-number">0x12835B0145706FBE</span>),</span>
<span class="line" id="L594">                roundParam512(<span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">10</span>, <span class="tok-number">0x243185BE4EE4B28C</span>),</span>
<span class="line" id="L595">                roundParam512(<span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">11</span>, <span class="tok-number">0x550C7DC3D5FFB4E2</span>),</span>
<span class="line" id="L596">                roundParam512(<span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">12</span>, <span class="tok-number">0x72BE5D74F27B896F</span>),</span>
<span class="line" id="L597">                roundParam512(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">13</span>, <span class="tok-number">0x80DEB1FE3B1696B1</span>),</span>
<span class="line" id="L598">                roundParam512(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">14</span>, <span class="tok-number">0x9BDC06A725C71235</span>),</span>
<span class="line" id="L599">                roundParam512(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">15</span>, <span class="tok-number">0xC19BF174CF692694</span>),</span>
<span class="line" id="L600">                roundParam512(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">16</span>, <span class="tok-number">0xE49B69C19EF14AD2</span>),</span>
<span class="line" id="L601">                roundParam512(<span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">17</span>, <span class="tok-number">0xEFBE4786384F25E3</span>),</span>
<span class="line" id="L602">                roundParam512(<span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">18</span>, <span class="tok-number">0x0FC19DC68B8CD5B5</span>),</span>
<span class="line" id="L603">                roundParam512(<span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">19</span>, <span class="tok-number">0x240CA1CC77AC9C65</span>),</span>
<span class="line" id="L604">                roundParam512(<span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">20</span>, <span class="tok-number">0x2DE92C6F592B0275</span>),</span>
<span class="line" id="L605">                roundParam512(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">21</span>, <span class="tok-number">0x4A7484AA6EA6E483</span>),</span>
<span class="line" id="L606">                roundParam512(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">22</span>, <span class="tok-number">0x5CB0A9DCBD41FBD4</span>),</span>
<span class="line" id="L607">                roundParam512(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">23</span>, <span class="tok-number">0x76F988DA831153B5</span>),</span>
<span class="line" id="L608">                roundParam512(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">24</span>, <span class="tok-number">0x983E5152EE66DFAB</span>),</span>
<span class="line" id="L609">                roundParam512(<span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">25</span>, <span class="tok-number">0xA831C66D2DB43210</span>),</span>
<span class="line" id="L610">                roundParam512(<span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">26</span>, <span class="tok-number">0xB00327C898FB213F</span>),</span>
<span class="line" id="L611">                roundParam512(<span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">27</span>, <span class="tok-number">0xBF597FC7BEEF0EE4</span>),</span>
<span class="line" id="L612">                roundParam512(<span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">28</span>, <span class="tok-number">0xC6E00BF33DA88FC2</span>),</span>
<span class="line" id="L613">                roundParam512(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">29</span>, <span class="tok-number">0xD5A79147930AA725</span>),</span>
<span class="line" id="L614">                roundParam512(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">30</span>, <span class="tok-number">0x06CA6351E003826F</span>),</span>
<span class="line" id="L615">                roundParam512(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">31</span>, <span class="tok-number">0x142929670A0E6E70</span>),</span>
<span class="line" id="L616">                roundParam512(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">32</span>, <span class="tok-number">0x27B70A8546D22FFC</span>),</span>
<span class="line" id="L617">                roundParam512(<span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">33</span>, <span class="tok-number">0x2E1B21385C26C926</span>),</span>
<span class="line" id="L618">                roundParam512(<span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">34</span>, <span class="tok-number">0x4D2C6DFC5AC42AED</span>),</span>
<span class="line" id="L619">                roundParam512(<span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">35</span>, <span class="tok-number">0x53380D139D95B3DF</span>),</span>
<span class="line" id="L620">                roundParam512(<span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">36</span>, <span class="tok-number">0x650A73548BAF63DE</span>),</span>
<span class="line" id="L621">                roundParam512(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">37</span>, <span class="tok-number">0x766A0ABB3C77B2A8</span>),</span>
<span class="line" id="L622">                roundParam512(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">38</span>, <span class="tok-number">0x81C2C92E47EDAEE6</span>),</span>
<span class="line" id="L623">                roundParam512(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">39</span>, <span class="tok-number">0x92722C851482353B</span>),</span>
<span class="line" id="L624">                roundParam512(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">40</span>, <span class="tok-number">0xA2BFE8A14CF10364</span>),</span>
<span class="line" id="L625">                roundParam512(<span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">41</span>, <span class="tok-number">0xA81A664BBC423001</span>),</span>
<span class="line" id="L626">                roundParam512(<span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">42</span>, <span class="tok-number">0xC24B8B70D0F89791</span>),</span>
<span class="line" id="L627">                roundParam512(<span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">43</span>, <span class="tok-number">0xC76C51A30654BE30</span>),</span>
<span class="line" id="L628">                roundParam512(<span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">44</span>, <span class="tok-number">0xD192E819D6EF5218</span>),</span>
<span class="line" id="L629">                roundParam512(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">45</span>, <span class="tok-number">0xD69906245565A910</span>),</span>
<span class="line" id="L630">                roundParam512(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">46</span>, <span class="tok-number">0xF40E35855771202A</span>),</span>
<span class="line" id="L631">                roundParam512(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">47</span>, <span class="tok-number">0x106AA07032BBD1B8</span>),</span>
<span class="line" id="L632">                roundParam512(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">48</span>, <span class="tok-number">0x19A4C116B8D2D0C8</span>),</span>
<span class="line" id="L633">                roundParam512(<span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">49</span>, <span class="tok-number">0x1E376C085141AB53</span>),</span>
<span class="line" id="L634">                roundParam512(<span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">50</span>, <span class="tok-number">0x2748774CDF8EEB99</span>),</span>
<span class="line" id="L635">                roundParam512(<span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">51</span>, <span class="tok-number">0x34B0BCB5E19B48A8</span>),</span>
<span class="line" id="L636">                roundParam512(<span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">52</span>, <span class="tok-number">0x391C0CB3C5C95A63</span>),</span>
<span class="line" id="L637">                roundParam512(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">53</span>, <span class="tok-number">0x4ED8AA4AE3418ACB</span>),</span>
<span class="line" id="L638">                roundParam512(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">54</span>, <span class="tok-number">0x5B9CCA4F7763E373</span>),</span>
<span class="line" id="L639">                roundParam512(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">55</span>, <span class="tok-number">0x682E6FF3D6B2B8A3</span>),</span>
<span class="line" id="L640">                roundParam512(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">56</span>, <span class="tok-number">0x748F82EE5DEFB2FC</span>),</span>
<span class="line" id="L641">                roundParam512(<span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">57</span>, <span class="tok-number">0x78A5636F43172F60</span>),</span>
<span class="line" id="L642">                roundParam512(<span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">58</span>, <span class="tok-number">0x84C87814A1F0AB72</span>),</span>
<span class="line" id="L643">                roundParam512(<span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">59</span>, <span class="tok-number">0x8CC702081A6439EC</span>),</span>
<span class="line" id="L644">                roundParam512(<span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">60</span>, <span class="tok-number">0x90BEFFFA23631E28</span>),</span>
<span class="line" id="L645">                roundParam512(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">61</span>, <span class="tok-number">0xA4506CEBDE82BDE9</span>),</span>
<span class="line" id="L646">                roundParam512(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">62</span>, <span class="tok-number">0xBEF9A3F7B2C67915</span>),</span>
<span class="line" id="L647">                roundParam512(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">63</span>, <span class="tok-number">0xC67178F2E372532B</span>),</span>
<span class="line" id="L648">                roundParam512(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">64</span>, <span class="tok-number">0xCA273ECEEA26619C</span>),</span>
<span class="line" id="L649">                roundParam512(<span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">65</span>, <span class="tok-number">0xD186B8C721C0C207</span>),</span>
<span class="line" id="L650">                roundParam512(<span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">66</span>, <span class="tok-number">0xEADA7DD6CDE0EB1E</span>),</span>
<span class="line" id="L651">                roundParam512(<span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">67</span>, <span class="tok-number">0xF57D4F7FEE6ED178</span>),</span>
<span class="line" id="L652">                roundParam512(<span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">68</span>, <span class="tok-number">0x06F067AA72176FBA</span>),</span>
<span class="line" id="L653">                roundParam512(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">69</span>, <span class="tok-number">0x0A637DC5A2C898A6</span>),</span>
<span class="line" id="L654">                roundParam512(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">70</span>, <span class="tok-number">0x113F9804BEF90DAE</span>),</span>
<span class="line" id="L655">                roundParam512(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">71</span>, <span class="tok-number">0x1B710B35131C471B</span>),</span>
<span class="line" id="L656">                roundParam512(<span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">72</span>, <span class="tok-number">0x28DB77F523047D84</span>),</span>
<span class="line" id="L657">                roundParam512(<span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">73</span>, <span class="tok-number">0x32CAAB7B40C72493</span>),</span>
<span class="line" id="L658">                roundParam512(<span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">74</span>, <span class="tok-number">0x3C9EBE0A15C9BEBC</span>),</span>
<span class="line" id="L659">                roundParam512(<span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">75</span>, <span class="tok-number">0x431D67C49C100D4C</span>),</span>
<span class="line" id="L660">                roundParam512(<span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">76</span>, <span class="tok-number">0x4CC5D4BECB3E42B6</span>),</span>
<span class="line" id="L661">                roundParam512(<span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">77</span>, <span class="tok-number">0x597F299CFC657E2A</span>),</span>
<span class="line" id="L662">                roundParam512(<span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">78</span>, <span class="tok-number">0x5FCB6FAB3AD6FAEC</span>),</span>
<span class="line" id="L663">                roundParam512(<span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">4</span>, <span class="tok-number">5</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>, <span class="tok-number">0</span>, <span class="tok-number">79</span>, <span class="tok-number">0x6C44198C4A475817</span>),</span>
<span class="line" id="L664">            };</span>
<span class="line" id="L665">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (round0) |r| {</span>
<span class="line" id="L666">                v[r.h] = v[r.h] +% (math.rotr(<span class="tok-type">u64</span>, v[r.e], <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">14</span>)) ^ math.rotr(<span class="tok-type">u64</span>, v[r.e], <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">18</span>)) ^ math.rotr(<span class="tok-type">u64</span>, v[r.e], <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">41</span>))) +% (v[r.g] ^ (v[r.e] &amp; (v[r.f] ^ v[r.g]))) +% r.k +% s[r.i];</span>
<span class="line" id="L667"></span>
<span class="line" id="L668">                v[r.d] = v[r.d] +% v[r.h];</span>
<span class="line" id="L669"></span>
<span class="line" id="L670">                v[r.h] = v[r.h] +% (math.rotr(<span class="tok-type">u64</span>, v[r.a], <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">28</span>)) ^ math.rotr(<span class="tok-type">u64</span>, v[r.a], <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">34</span>)) ^ math.rotr(<span class="tok-type">u64</span>, v[r.a], <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, <span class="tok-number">39</span>))) +% ((v[r.a] &amp; (v[r.b] | v[r.c])) | (v[r.b] &amp; v[r.c]));</span>
<span class="line" id="L671">            }</span>
<span class="line" id="L672"></span>
<span class="line" id="L673">            d.s[<span class="tok-number">0</span>] +%= v[<span class="tok-number">0</span>];</span>
<span class="line" id="L674">            d.s[<span class="tok-number">1</span>] +%= v[<span class="tok-number">1</span>];</span>
<span class="line" id="L675">            d.s[<span class="tok-number">2</span>] +%= v[<span class="tok-number">2</span>];</span>
<span class="line" id="L676">            d.s[<span class="tok-number">3</span>] +%= v[<span class="tok-number">3</span>];</span>
<span class="line" id="L677">            d.s[<span class="tok-number">4</span>] +%= v[<span class="tok-number">4</span>];</span>
<span class="line" id="L678">            d.s[<span class="tok-number">5</span>] +%= v[<span class="tok-number">5</span>];</span>
<span class="line" id="L679">            d.s[<span class="tok-number">6</span>] +%= v[<span class="tok-number">6</span>];</span>
<span class="line" id="L680">            d.s[<span class="tok-number">7</span>] +%= v[<span class="tok-number">7</span>];</span>
<span class="line" id="L681">        }</span>
<span class="line" id="L682">    };</span>
<span class="line" id="L683">}</span>
<span class="line" id="L684"></span>
<span class="line" id="L685"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha384 single&quot;</span> {</span>
<span class="line" id="L686">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b&quot;</span>;</span>
<span class="line" id="L687">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha384, h1, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L688"></span>
<span class="line" id="L689">    <span class="tok-kw">const</span> h2 = <span class="tok-str">&quot;cb00753f45a35e8bb5a03d699ac65007272c32ab0eded1631a8b605a43ff5bed8086072ba1e7cc2358baeca134c825a7&quot;</span>;</span>
<span class="line" id="L690">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha384, h2, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L691"></span>
<span class="line" id="L692">    <span class="tok-kw">const</span> h3 = <span class="tok-str">&quot;09330c33f71147e83d192fc782cd1b4753111b173b3b05d22fa08086e3b0f712fcc7c71a557e2db966c3e9fa91746039&quot;</span>;</span>
<span class="line" id="L693">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha384, h3, <span class="tok-str">&quot;abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu&quot;</span>);</span>
<span class="line" id="L694">}</span>
<span class="line" id="L695"></span>
<span class="line" id="L696"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha384 streaming&quot;</span> {</span>
<span class="line" id="L697">    <span class="tok-kw">var</span> h = Sha384.init(.{});</span>
<span class="line" id="L698">    <span class="tok-kw">var</span> out: [<span class="tok-number">48</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L699"></span>
<span class="line" id="L700">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b&quot;</span>;</span>
<span class="line" id="L701">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L702">    <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L703"></span>
<span class="line" id="L704">    <span class="tok-kw">const</span> h2 = <span class="tok-str">&quot;cb00753f45a35e8bb5a03d699ac65007272c32ab0eded1631a8b605a43ff5bed8086072ba1e7cc2358baeca134c825a7&quot;</span>;</span>
<span class="line" id="L705"></span>
<span class="line" id="L706">    h = Sha384.init(.{});</span>
<span class="line" id="L707">    h.update(<span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L708">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L709">    <span class="tok-kw">try</span> htest.assertEqual(h2, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L710"></span>
<span class="line" id="L711">    h = Sha384.init(.{});</span>
<span class="line" id="L712">    h.update(<span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L713">    h.update(<span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L714">    h.update(<span class="tok-str">&quot;c&quot;</span>);</span>
<span class="line" id="L715">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L716">    <span class="tok-kw">try</span> htest.assertEqual(h2, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L717">}</span>
<span class="line" id="L718"></span>
<span class="line" id="L719"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha512 single&quot;</span> {</span>
<span class="line" id="L720">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e&quot;</span>;</span>
<span class="line" id="L721">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha512, h1, <span class="tok-str">&quot;&quot;</span>);</span>
<span class="line" id="L722"></span>
<span class="line" id="L723">    <span class="tok-kw">const</span> h2 = <span class="tok-str">&quot;ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f&quot;</span>;</span>
<span class="line" id="L724">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha512, h2, <span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L725"></span>
<span class="line" id="L726">    <span class="tok-kw">const</span> h3 = <span class="tok-str">&quot;8e959b75dae313da8cf4f72814fc143f8f7779c6eb9f7fa17299aeadb6889018501d289e4900f7e4331b99dec4b5433ac7d329eeb6dd26545e96e55b874be909&quot;</span>;</span>
<span class="line" id="L727">    <span class="tok-kw">try</span> htest.assertEqualHash(Sha512, h3, <span class="tok-str">&quot;abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu&quot;</span>);</span>
<span class="line" id="L728">}</span>
<span class="line" id="L729"></span>
<span class="line" id="L730"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha512 streaming&quot;</span> {</span>
<span class="line" id="L731">    <span class="tok-kw">var</span> h = Sha512.init(.{});</span>
<span class="line" id="L732">    <span class="tok-kw">var</span> out: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L733"></span>
<span class="line" id="L734">    <span class="tok-kw">const</span> h1 = <span class="tok-str">&quot;cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e&quot;</span>;</span>
<span class="line" id="L735">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L736">    <span class="tok-kw">try</span> htest.assertEqual(h1, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L737"></span>
<span class="line" id="L738">    <span class="tok-kw">const</span> h2 = <span class="tok-str">&quot;ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f&quot;</span>;</span>
<span class="line" id="L739"></span>
<span class="line" id="L740">    h = Sha512.init(.{});</span>
<span class="line" id="L741">    h.update(<span class="tok-str">&quot;abc&quot;</span>);</span>
<span class="line" id="L742">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L743">    <span class="tok-kw">try</span> htest.assertEqual(h2, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L744"></span>
<span class="line" id="L745">    h = Sha512.init(.{});</span>
<span class="line" id="L746">    h.update(<span class="tok-str">&quot;a&quot;</span>);</span>
<span class="line" id="L747">    h.update(<span class="tok-str">&quot;b&quot;</span>);</span>
<span class="line" id="L748">    h.update(<span class="tok-str">&quot;c&quot;</span>);</span>
<span class="line" id="L749">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L750">    <span class="tok-kw">try</span> htest.assertEqual(h2, out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L751">}</span>
<span class="line" id="L752"></span>
<span class="line" id="L753"><span class="tok-kw">test</span> <span class="tok-str">&quot;sha512 aligned final&quot;</span> {</span>
<span class="line" id="L754">    <span class="tok-kw">var</span> block = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** Sha512.block_length;</span>
<span class="line" id="L755">    <span class="tok-kw">var</span> out: [Sha512.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L756"></span>
<span class="line" id="L757">    <span class="tok-kw">var</span> h = Sha512.init(.{});</span>
<span class="line" id="L758">    h.update(&amp;block);</span>
<span class="line" id="L759">    h.final(out[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L760">}</span>
<span class="line" id="L761"></span>
</code></pre></body>
</html>