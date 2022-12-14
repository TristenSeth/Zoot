<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/isap.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> AuthenticationError = std.crypto.errors.AuthenticationError;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-comment">/// ISAPv2 is an authenticated encryption system hardened against side channels and fault attacks.</span></span>
<span class="line" id="L9"><span class="tok-comment">/// https://csrc.nist.gov/CSRC/media/Projects/lightweight-cryptography/documents/round-2/spec-doc-rnd2/isap-spec-round2.pdf</span></span>
<span class="line" id="L10"><span class="tok-comment">///</span></span>
<span class="line" id="L11"><span class="tok-comment">/// Note that ISAP is not suitable for high-performance applications.</span></span>
<span class="line" id="L12"><span class="tok-comment">///</span></span>
<span class="line" id="L13"><span class="tok-comment">/// However:</span></span>
<span class="line" id="L14"><span class="tok-comment">/// - if allowing physical access to the device is part of your threat model,</span></span>
<span class="line" id="L15"><span class="tok-comment">/// - or if you need resistance against microcode/hardware-level side channel attacks,</span></span>
<span class="line" id="L16"><span class="tok-comment">/// - or if software-induced fault attacks such as rowhammer are a concern,</span></span>
<span class="line" id="L17"><span class="tok-comment">///</span></span>
<span class="line" id="L18"><span class="tok-comment">/// then you may consider ISAP for highly sensitive data.</span></span>
<span class="line" id="L19"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IsapA128A = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L20">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length = <span class="tok-number">16</span>;</span>
<span class="line" id="L21">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> nonce_length = <span class="tok-number">16</span>;</span>
<span class="line" id="L22">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> tag_length: <span class="tok-type">usize</span> = <span class="tok-number">16</span>;</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">    <span class="tok-kw">const</span> iv1 = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x01</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0x40</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0x0c</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0x06</span>, <span class="tok-number">0x0c</span> };</span>
<span class="line" id="L25">    <span class="tok-kw">const</span> iv2 = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x02</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0x40</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0x0c</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0x06</span>, <span class="tok-number">0x0c</span> };</span>
<span class="line" id="L26">    <span class="tok-kw">const</span> iv3 = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x03</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0x40</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0x0c</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0x06</span>, <span class="tok-number">0x0c</span> };</span>
<span class="line" id="L27"></span>
<span class="line" id="L28">    <span class="tok-kw">const</span> Block = [<span class="tok-number">5</span>]<span class="tok-type">u64</span>;</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">    block: Block,</span>
<span class="line" id="L31"></span>
<span class="line" id="L32">    <span class="tok-kw">fn</span> <span class="tok-fn">round</span>(isap: *IsapA128A, rk: <span class="tok-type">u64</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L33">        <span class="tok-kw">var</span> x = &amp;isap.block;</span>
<span class="line" id="L34">        x[<span class="tok-number">2</span>] ^= rk;</span>
<span class="line" id="L35">        x[<span class="tok-number">0</span>] ^= x[<span class="tok-number">4</span>];</span>
<span class="line" id="L36">        x[<span class="tok-number">4</span>] ^= x[<span class="tok-number">3</span>];</span>
<span class="line" id="L37">        x[<span class="tok-number">2</span>] ^= x[<span class="tok-number">1</span>];</span>
<span class="line" id="L38">        <span class="tok-kw">var</span> t = x.*;</span>
<span class="line" id="L39">        x[<span class="tok-number">0</span>] = t[<span class="tok-number">0</span>] ^ ((~t[<span class="tok-number">1</span>]) &amp; t[<span class="tok-number">2</span>]);</span>
<span class="line" id="L40">        x[<span class="tok-number">2</span>] = t[<span class="tok-number">2</span>] ^ ((~t[<span class="tok-number">3</span>]) &amp; t[<span class="tok-number">4</span>]);</span>
<span class="line" id="L41">        x[<span class="tok-number">4</span>] = t[<span class="tok-number">4</span>] ^ ((~t[<span class="tok-number">0</span>]) &amp; t[<span class="tok-number">1</span>]);</span>
<span class="line" id="L42">        x[<span class="tok-number">1</span>] = t[<span class="tok-number">1</span>] ^ ((~t[<span class="tok-number">2</span>]) &amp; t[<span class="tok-number">3</span>]);</span>
<span class="line" id="L43">        x[<span class="tok-number">3</span>] = t[<span class="tok-number">3</span>] ^ ((~t[<span class="tok-number">4</span>]) &amp; t[<span class="tok-number">0</span>]);</span>
<span class="line" id="L44">        x[<span class="tok-number">1</span>] ^= x[<span class="tok-number">0</span>];</span>
<span class="line" id="L45">        t[<span class="tok-number">1</span>] = x[<span class="tok-number">1</span>];</span>
<span class="line" id="L46">        x[<span class="tok-number">1</span>] = math.rotr(<span class="tok-type">u64</span>, x[<span class="tok-number">1</span>], <span class="tok-number">39</span>);</span>
<span class="line" id="L47">        x[<span class="tok-number">3</span>] ^= x[<span class="tok-number">2</span>];</span>
<span class="line" id="L48">        t[<span class="tok-number">2</span>] = x[<span class="tok-number">2</span>];</span>
<span class="line" id="L49">        x[<span class="tok-number">2</span>] = math.rotr(<span class="tok-type">u64</span>, x[<span class="tok-number">2</span>], <span class="tok-number">1</span>);</span>
<span class="line" id="L50">        t[<span class="tok-number">4</span>] = x[<span class="tok-number">4</span>];</span>
<span class="line" id="L51">        t[<span class="tok-number">2</span>] ^= x[<span class="tok-number">2</span>];</span>
<span class="line" id="L52">        x[<span class="tok-number">2</span>] = math.rotr(<span class="tok-type">u64</span>, x[<span class="tok-number">2</span>], <span class="tok-number">5</span>);</span>
<span class="line" id="L53">        t[<span class="tok-number">3</span>] = x[<span class="tok-number">3</span>];</span>
<span class="line" id="L54">        t[<span class="tok-number">1</span>] ^= x[<span class="tok-number">1</span>];</span>
<span class="line" id="L55">        x[<span class="tok-number">3</span>] = math.rotr(<span class="tok-type">u64</span>, x[<span class="tok-number">3</span>], <span class="tok-number">10</span>);</span>
<span class="line" id="L56">        x[<span class="tok-number">0</span>] ^= x[<span class="tok-number">4</span>];</span>
<span class="line" id="L57">        x[<span class="tok-number">4</span>] = math.rotr(<span class="tok-type">u64</span>, x[<span class="tok-number">4</span>], <span class="tok-number">7</span>);</span>
<span class="line" id="L58">        t[<span class="tok-number">3</span>] ^= x[<span class="tok-number">3</span>];</span>
<span class="line" id="L59">        x[<span class="tok-number">2</span>] ^= t[<span class="tok-number">2</span>];</span>
<span class="line" id="L60">        x[<span class="tok-number">1</span>] = math.rotr(<span class="tok-type">u64</span>, x[<span class="tok-number">1</span>], <span class="tok-number">22</span>);</span>
<span class="line" id="L61">        t[<span class="tok-number">0</span>] = x[<span class="tok-number">0</span>];</span>
<span class="line" id="L62">        x[<span class="tok-number">2</span>] = ~x[<span class="tok-number">2</span>];</span>
<span class="line" id="L63">        x[<span class="tok-number">3</span>] = math.rotr(<span class="tok-type">u64</span>, x[<span class="tok-number">3</span>], <span class="tok-number">7</span>);</span>
<span class="line" id="L64">        t[<span class="tok-number">4</span>] ^= x[<span class="tok-number">4</span>];</span>
<span class="line" id="L65">        x[<span class="tok-number">4</span>] = math.rotr(<span class="tok-type">u64</span>, x[<span class="tok-number">4</span>], <span class="tok-number">34</span>);</span>
<span class="line" id="L66">        x[<span class="tok-number">3</span>] ^= t[<span class="tok-number">3</span>];</span>
<span class="line" id="L67">        x[<span class="tok-number">1</span>] ^= t[<span class="tok-number">1</span>];</span>
<span class="line" id="L68">        x[<span class="tok-number">0</span>] = math.rotr(<span class="tok-type">u64</span>, x[<span class="tok-number">0</span>], <span class="tok-number">19</span>);</span>
<span class="line" id="L69">        x[<span class="tok-number">4</span>] ^= t[<span class="tok-number">4</span>];</span>
<span class="line" id="L70">        t[<span class="tok-number">0</span>] ^= x[<span class="tok-number">0</span>];</span>
<span class="line" id="L71">        x[<span class="tok-number">0</span>] = math.rotr(<span class="tok-type">u64</span>, x[<span class="tok-number">0</span>], <span class="tok-number">9</span>);</span>
<span class="line" id="L72">        x[<span class="tok-number">0</span>] ^= t[<span class="tok-number">0</span>];</span>
<span class="line" id="L73">    }</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">    <span class="tok-kw">fn</span> <span class="tok-fn">p12</span>(isap: *IsapA128A) <span class="tok-type">void</span> {</span>
<span class="line" id="L76">        <span class="tok-kw">const</span> rks = [<span class="tok-number">12</span>]<span class="tok-type">u64</span>{ <span class="tok-number">0xf0</span>, <span class="tok-number">0xe1</span>, <span class="tok-number">0xd2</span>, <span class="tok-number">0xc3</span>, <span class="tok-number">0xb4</span>, <span class="tok-number">0xa5</span>, <span class="tok-number">0x96</span>, <span class="tok-number">0x87</span>, <span class="tok-number">0x78</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x5a</span>, <span class="tok-number">0x4b</span> };</span>
<span class="line" id="L77">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (rks) |rk| {</span>
<span class="line" id="L78">            isap.round(rk);</span>
<span class="line" id="L79">        }</span>
<span class="line" id="L80">    }</span>
<span class="line" id="L81"></span>
<span class="line" id="L82">    <span class="tok-kw">fn</span> <span class="tok-fn">p6</span>(isap: *IsapA128A) <span class="tok-type">void</span> {</span>
<span class="line" id="L83">        <span class="tok-kw">const</span> rks = [<span class="tok-number">6</span>]<span class="tok-type">u64</span>{ <span class="tok-number">0x96</span>, <span class="tok-number">0x87</span>, <span class="tok-number">0x78</span>, <span class="tok-number">0x69</span>, <span class="tok-number">0x5a</span>, <span class="tok-number">0x4b</span> };</span>
<span class="line" id="L84">        <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (rks) |rk| {</span>
<span class="line" id="L85">            isap.round(rk);</span>
<span class="line" id="L86">        }</span>
<span class="line" id="L87">    }</span>
<span class="line" id="L88"></span>
<span class="line" id="L89">    <span class="tok-kw">fn</span> <span class="tok-fn">p1</span>(isap: *IsapA128A) <span class="tok-type">void</span> {</span>
<span class="line" id="L90">        isap.round(<span class="tok-number">0x4b</span>);</span>
<span class="line" id="L91">    }</span>
<span class="line" id="L92"></span>
<span class="line" id="L93">    <span class="tok-kw">fn</span> <span class="tok-fn">absorb</span>(isap: *IsapA128A, m: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L94">        <span class="tok-kw">var</span> block = &amp;isap.block;</span>
<span class="line" id="L95">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L96">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (i += <span class="tok-number">8</span>) {</span>
<span class="line" id="L97">            <span class="tok-kw">const</span> left = m.len - i;</span>
<span class="line" id="L98">            <span class="tok-kw">if</span> (left &gt;= <span class="tok-number">8</span>) {</span>
<span class="line" id="L99">                block[<span class="tok-number">0</span>] ^= mem.readIntBig(<span class="tok-type">u64</span>, m[i..][<span class="tok-number">0</span>..<span class="tok-number">8</span>]);</span>
<span class="line" id="L100">                isap.p12();</span>
<span class="line" id="L101">                <span class="tok-kw">if</span> (left == <span class="tok-number">8</span>) {</span>
<span class="line" id="L102">                    block[<span class="tok-number">0</span>] ^= <span class="tok-number">0x8000000000000000</span>;</span>
<span class="line" id="L103">                    isap.p12();</span>
<span class="line" id="L104">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L105">                }</span>
<span class="line" id="L106">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L107">                <span class="tok-kw">var</span> padded = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">8</span>;</span>
<span class="line" id="L108">                mem.copy(<span class="tok-type">u8</span>, padded[<span class="tok-number">0</span>..left], m[i..]);</span>
<span class="line" id="L109">                padded[left] = <span class="tok-number">0x80</span>;</span>
<span class="line" id="L110">                block[<span class="tok-number">0</span>] ^= mem.readIntBig(<span class="tok-type">u64</span>, padded[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L111">                isap.p12();</span>
<span class="line" id="L112">                <span class="tok-kw">break</span>;</span>
<span class="line" id="L113">            }</span>
<span class="line" id="L114">        }</span>
<span class="line" id="L115">    }</span>
<span class="line" id="L116"></span>
<span class="line" id="L117">    <span class="tok-kw">fn</span> <span class="tok-fn">trickle</span>(k: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>, iv: [<span class="tok-number">8</span>]<span class="tok-type">u8</span>, y: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-kw">comptime</span> out_len: <span class="tok-type">usize</span>) [out_len]<span class="tok-type">u8</span> {</span>
<span class="line" id="L118">        <span class="tok-kw">var</span> isap = IsapA128A{</span>
<span class="line" id="L119">            .block = Block{</span>
<span class="line" id="L120">                mem.readIntBig(<span class="tok-type">u64</span>, k[<span class="tok-number">0</span>..<span class="tok-number">8</span>]),</span>
<span class="line" id="L121">                mem.readIntBig(<span class="tok-type">u64</span>, k[<span class="tok-number">8</span>..<span class="tok-number">16</span>]),</span>
<span class="line" id="L122">                mem.readIntBig(<span class="tok-type">u64</span>, iv[<span class="tok-number">0</span>..<span class="tok-number">8</span>]),</span>
<span class="line" id="L123">                <span class="tok-number">0</span>,</span>
<span class="line" id="L124">                <span class="tok-number">0</span>,</span>
<span class="line" id="L125">            },</span>
<span class="line" id="L126">        };</span>
<span class="line" id="L127">        isap.p12();</span>
<span class="line" id="L128"></span>
<span class="line" id="L129">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L130">        <span class="tok-kw">while</span> (i &lt; y.len * <span class="tok-number">8</span> - <span class="tok-number">1</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L131">            <span class="tok-kw">const</span> cur_byte_pos = i / <span class="tok-number">8</span>;</span>
<span class="line" id="L132">            <span class="tok-kw">const</span> cur_bit_pos = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u3</span>, <span class="tok-number">7</span> - (i % <span class="tok-number">8</span>));</span>
<span class="line" id="L133">            <span class="tok-kw">const</span> cur_bit = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, ((y[cur_byte_pos] &gt;&gt; cur_bit_pos) &amp; <span class="tok-number">1</span>) &lt;&lt; <span class="tok-number">7</span>);</span>
<span class="line" id="L134">            isap.block[<span class="tok-number">0</span>] ^= cur_bit &lt;&lt; <span class="tok-number">56</span>;</span>
<span class="line" id="L135">            isap.p1();</span>
<span class="line" id="L136">        }</span>
<span class="line" id="L137">        <span class="tok-kw">const</span> cur_bit = <span class="tok-builtin">@as</span>(<span class="tok-type">u64</span>, (y[y.len - <span class="tok-number">1</span>] &amp; <span class="tok-number">1</span>) &lt;&lt; <span class="tok-number">7</span>);</span>
<span class="line" id="L138">        isap.block[<span class="tok-number">0</span>] ^= cur_bit &lt;&lt; <span class="tok-number">56</span>;</span>
<span class="line" id="L139">        isap.p12();</span>
<span class="line" id="L140"></span>
<span class="line" id="L141">        <span class="tok-kw">var</span> out: [out_len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L142">        <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L143">        <span class="tok-kw">while</span> (j &lt; out_len) : (j += <span class="tok-number">8</span>) {</span>
<span class="line" id="L144">            mem.writeIntBig(<span class="tok-type">u64</span>, out[j..][<span class="tok-number">0</span>..<span class="tok-number">8</span>], isap.block[j / <span class="tok-number">8</span>]);</span>
<span class="line" id="L145">        }</span>
<span class="line" id="L146">        std.crypto.utils.secureZero(<span class="tok-type">u64</span>, &amp;isap.block);</span>
<span class="line" id="L147">        <span class="tok-kw">return</span> out;</span>
<span class="line" id="L148">    }</span>
<span class="line" id="L149"></span>
<span class="line" id="L150">    <span class="tok-kw">fn</span> <span class="tok-fn">mac</span>(c: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, ad: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>, key: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>) [<span class="tok-number">16</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L151">        <span class="tok-kw">var</span> isap = IsapA128A{</span>
<span class="line" id="L152">            .block = Block{</span>
<span class="line" id="L153">                mem.readIntBig(<span class="tok-type">u64</span>, npub[<span class="tok-number">0</span>..<span class="tok-number">8</span>]),</span>
<span class="line" id="L154">                mem.readIntBig(<span class="tok-type">u64</span>, npub[<span class="tok-number">8</span>..<span class="tok-number">16</span>]),</span>
<span class="line" id="L155">                mem.readIntBig(<span class="tok-type">u64</span>, iv1[<span class="tok-number">0</span>..]),</span>
<span class="line" id="L156">                <span class="tok-number">0</span>,</span>
<span class="line" id="L157">                <span class="tok-number">0</span>,</span>
<span class="line" id="L158">            },</span>
<span class="line" id="L159">        };</span>
<span class="line" id="L160">        isap.p12();</span>
<span class="line" id="L161"></span>
<span class="line" id="L162">        isap.absorb(ad);</span>
<span class="line" id="L163">        isap.block[<span class="tok-number">4</span>] ^= <span class="tok-number">1</span>;</span>
<span class="line" id="L164">        isap.absorb(c);</span>
<span class="line" id="L165"></span>
<span class="line" id="L166">        <span class="tok-kw">var</span> y: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L167">        mem.writeIntBig(<span class="tok-type">u64</span>, y[<span class="tok-number">0</span>..<span class="tok-number">8</span>], isap.block[<span class="tok-number">0</span>]);</span>
<span class="line" id="L168">        mem.writeIntBig(<span class="tok-type">u64</span>, y[<span class="tok-number">8</span>..<span class="tok-number">16</span>], isap.block[<span class="tok-number">1</span>]);</span>
<span class="line" id="L169">        <span class="tok-kw">const</span> nb = trickle(key, iv2, y[<span class="tok-number">0</span>..], <span class="tok-number">16</span>);</span>
<span class="line" id="L170">        isap.block[<span class="tok-number">0</span>] = mem.readIntBig(<span class="tok-type">u64</span>, nb[<span class="tok-number">0</span>..<span class="tok-number">8</span>]);</span>
<span class="line" id="L171">        isap.block[<span class="tok-number">1</span>] = mem.readIntBig(<span class="tok-type">u64</span>, nb[<span class="tok-number">8</span>..<span class="tok-number">16</span>]);</span>
<span class="line" id="L172">        isap.p12();</span>
<span class="line" id="L173"></span>
<span class="line" id="L174">        <span class="tok-kw">var</span> tag: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L175">        mem.writeIntBig(<span class="tok-type">u64</span>, tag[<span class="tok-number">0</span>..<span class="tok-number">8</span>], isap.block[<span class="tok-number">0</span>]);</span>
<span class="line" id="L176">        mem.writeIntBig(<span class="tok-type">u64</span>, tag[<span class="tok-number">8</span>..<span class="tok-number">16</span>], isap.block[<span class="tok-number">1</span>]);</span>
<span class="line" id="L177">        std.crypto.utils.secureZero(<span class="tok-type">u64</span>, &amp;isap.block);</span>
<span class="line" id="L178">        <span class="tok-kw">return</span> tag;</span>
<span class="line" id="L179">    }</span>
<span class="line" id="L180"></span>
<span class="line" id="L181">    <span class="tok-kw">fn</span> <span class="tok-fn">xor</span>(out: []<span class="tok-type">u8</span>, in: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>, key: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L182">        debug.assert(in.len == out.len);</span>
<span class="line" id="L183"></span>
<span class="line" id="L184">        <span class="tok-kw">const</span> nb = trickle(key, iv3, npub[<span class="tok-number">0</span>..], <span class="tok-number">24</span>);</span>
<span class="line" id="L185">        <span class="tok-kw">var</span> isap = IsapA128A{</span>
<span class="line" id="L186">            .block = Block{</span>
<span class="line" id="L187">                mem.readIntBig(<span class="tok-type">u64</span>, nb[<span class="tok-number">0</span>..<span class="tok-number">8</span>]),</span>
<span class="line" id="L188">                mem.readIntBig(<span class="tok-type">u64</span>, nb[<span class="tok-number">8</span>..<span class="tok-number">16</span>]),</span>
<span class="line" id="L189">                mem.readIntBig(<span class="tok-type">u64</span>, nb[<span class="tok-number">16</span>..<span class="tok-number">24</span>]),</span>
<span class="line" id="L190">                mem.readIntBig(<span class="tok-type">u64</span>, npub[<span class="tok-number">0</span>..<span class="tok-number">8</span>]),</span>
<span class="line" id="L191">                mem.readIntBig(<span class="tok-type">u64</span>, npub[<span class="tok-number">8</span>..<span class="tok-number">16</span>]),</span>
<span class="line" id="L192">            },</span>
<span class="line" id="L193">        };</span>
<span class="line" id="L194">        isap.p6();</span>
<span class="line" id="L195"></span>
<span class="line" id="L196">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L197">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) : (i += <span class="tok-number">8</span>) {</span>
<span class="line" id="L198">            <span class="tok-kw">const</span> left = in.len - i;</span>
<span class="line" id="L199">            <span class="tok-kw">if</span> (left &gt;= <span class="tok-number">8</span>) {</span>
<span class="line" id="L200">                mem.writeIntNative(<span class="tok-type">u64</span>, out[i..][<span class="tok-number">0</span>..<span class="tok-number">8</span>], mem.bigToNative(<span class="tok-type">u64</span>, isap.block[<span class="tok-number">0</span>]) ^ mem.readIntNative(<span class="tok-type">u64</span>, in[i..][<span class="tok-number">0</span>..<span class="tok-number">8</span>]));</span>
<span class="line" id="L201">                <span class="tok-kw">if</span> (left == <span class="tok-number">8</span>) {</span>
<span class="line" id="L202">                    <span class="tok-kw">break</span>;</span>
<span class="line" id="L203">                }</span>
<span class="line" id="L204">                isap.p6();</span>
<span class="line" id="L205">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L206">                <span class="tok-kw">var</span> pad = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">8</span>;</span>
<span class="line" id="L207">                mem.copy(<span class="tok-type">u8</span>, pad[<span class="tok-number">0</span>..left], in[i..][<span class="tok-number">0</span>..left]);</span>
<span class="line" id="L208">                mem.writeIntNative(<span class="tok-type">u64</span>, pad[i..][<span class="tok-number">0</span>..<span class="tok-number">8</span>], mem.bigToNative(<span class="tok-type">u64</span>, isap.block[<span class="tok-number">0</span>]) ^ mem.readIntNative(<span class="tok-type">u64</span>, pad[i..][<span class="tok-number">0</span>..<span class="tok-number">8</span>]));</span>
<span class="line" id="L209">                mem.copy(<span class="tok-type">u8</span>, out[i..][<span class="tok-number">0</span>..left], pad[<span class="tok-number">0</span>..left]);</span>
<span class="line" id="L210">                <span class="tok-kw">break</span>;</span>
<span class="line" id="L211">            }</span>
<span class="line" id="L212">        }</span>
<span class="line" id="L213">        std.crypto.utils.secureZero(<span class="tok-type">u64</span>, &amp;isap.block);</span>
<span class="line" id="L214">    }</span>
<span class="line" id="L215"></span>
<span class="line" id="L216">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">encrypt</span>(c: []<span class="tok-type">u8</span>, tag: *[tag_length]<span class="tok-type">u8</span>, m: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, ad: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, key: [key_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L217">        xor(c, m, npub, key);</span>
<span class="line" id="L218">        tag.* = mac(c, ad, npub, key);</span>
<span class="line" id="L219">    }</span>
<span class="line" id="L220"></span>
<span class="line" id="L221">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">decrypt</span>(m: []<span class="tok-type">u8</span>, c: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, tag: [tag_length]<span class="tok-type">u8</span>, ad: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, key: [key_length]<span class="tok-type">u8</span>) AuthenticationError!<span class="tok-type">void</span> {</span>
<span class="line" id="L222">        <span class="tok-kw">var</span> computed_tag = mac(c, ad, npub, key);</span>
<span class="line" id="L223">        <span class="tok-kw">var</span> acc: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L224">        <span class="tok-kw">for</span> (computed_tag) |_, j| {</span>
<span class="line" id="L225">            acc |= (computed_tag[j] ^ tag[j]);</span>
<span class="line" id="L226">        }</span>
<span class="line" id="L227">        std.crypto.utils.secureZero(<span class="tok-type">u8</span>, &amp;computed_tag);</span>
<span class="line" id="L228">        <span class="tok-kw">if</span> (acc != <span class="tok-number">0</span>) {</span>
<span class="line" id="L229">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AuthenticationFailed;</span>
<span class="line" id="L230">        }</span>
<span class="line" id="L231">        xor(m, c, npub, key);</span>
<span class="line" id="L232">    }</span>
<span class="line" id="L233">};</span>
<span class="line" id="L234"></span>
<span class="line" id="L235"><span class="tok-kw">test</span> <span class="tok-str">&quot;ISAP&quot;</span> {</span>
<span class="line" id="L236">    <span class="tok-kw">const</span> k = [_]<span class="tok-type">u8</span>{<span class="tok-number">1</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L237">    <span class="tok-kw">const</span> n = [_]<span class="tok-type">u8</span>{<span class="tok-number">2</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L238">    <span class="tok-kw">var</span> tag: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L239">    <span class="tok-kw">const</span> ad = <span class="tok-str">&quot;ad&quot;</span>;</span>
<span class="line" id="L240">    <span class="tok-kw">var</span> msg = <span class="tok-str">&quot;test&quot;</span>;</span>
<span class="line" id="L241">    <span class="tok-kw">var</span> c: [msg.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L242">    IsapA128A.encrypt(c[<span class="tok-number">0</span>..], &amp;tag, msg[<span class="tok-number">0</span>..], ad, n, k);</span>
<span class="line" id="L243">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0x8f</span>, <span class="tok-number">0x68</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x8d</span> }, c[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L244">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, &amp;[_]<span class="tok-type">u8</span>{ <span class="tok-number">0x6c</span>, <span class="tok-number">0x25</span>, <span class="tok-number">0xe8</span>, <span class="tok-number">0xe2</span>, <span class="tok-number">0xe1</span>, <span class="tok-number">0x1f</span>, <span class="tok-number">0x38</span>, <span class="tok-number">0xe9</span>, <span class="tok-number">0x80</span>, <span class="tok-number">0x75</span>, <span class="tok-number">0xde</span>, <span class="tok-number">0xd5</span>, <span class="tok-number">0x2d</span>, <span class="tok-number">0xb2</span>, <span class="tok-number">0x31</span>, <span class="tok-number">0x82</span> }, tag[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L245">    <span class="tok-kw">try</span> IsapA128A.decrypt(c[<span class="tok-number">0</span>..], c[<span class="tok-number">0</span>..], tag, ad, n, k);</span>
<span class="line" id="L246">    <span class="tok-kw">try</span> testing.expect(mem.eql(<span class="tok-type">u8</span>, msg, c[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L247">}</span>
<span class="line" id="L248"></span>
</code></pre></body>
</html>