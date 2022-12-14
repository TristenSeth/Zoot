<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/aegis.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> AesBlock = std.crypto.core.aes.Block;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> AuthenticationError = std.crypto.errors.AuthenticationError;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">const</span> State128L = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L8">    blocks: [<span class="tok-number">8</span>]AesBlock,</span>
<span class="line" id="L9"></span>
<span class="line" id="L10">    <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(key: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>, nonce: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>) State128L {</span>
<span class="line" id="L11">        <span class="tok-kw">const</span> c1 = AesBlock.fromBytes(&amp;[<span class="tok-number">16</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0xdb</span>, <span class="tok-number">0x3d</span>, <span class="tok-number">0x18</span>, <span class="tok-number">0x55</span>, <span class="tok-number">0x6d</span>, <span class="tok-number">0xc2</span>, <span class="tok-number">0x2f</span>, <span class="tok-number">0xf1</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x31</span>, <span class="tok-number">0x42</span>, <span class="tok-number">0x73</span>, <span class="tok-number">0xb5</span>, <span class="tok-number">0x28</span>, <span class="tok-number">0xdd</span> });</span>
<span class="line" id="L12">        <span class="tok-kw">const</span> c2 = AesBlock.fromBytes(&amp;[<span class="tok-number">16</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0x0</span>, <span class="tok-number">0x1</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0x02</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x05</span>, <span class="tok-number">0x08</span>, <span class="tok-number">0x0d</span>, <span class="tok-number">0x15</span>, <span class="tok-number">0x22</span>, <span class="tok-number">0x37</span>, <span class="tok-number">0x59</span>, <span class="tok-number">0x90</span>, <span class="tok-number">0xe9</span>, <span class="tok-number">0x79</span>, <span class="tok-number">0x62</span> });</span>
<span class="line" id="L13">        <span class="tok-kw">const</span> key_block = AesBlock.fromBytes(&amp;key);</span>
<span class="line" id="L14">        <span class="tok-kw">const</span> nonce_block = AesBlock.fromBytes(&amp;nonce);</span>
<span class="line" id="L15">        <span class="tok-kw">const</span> blocks = [<span class="tok-number">8</span>]AesBlock{</span>
<span class="line" id="L16">            key_block.xorBlocks(nonce_block),</span>
<span class="line" id="L17">            c1,</span>
<span class="line" id="L18">            c2,</span>
<span class="line" id="L19">            c1,</span>
<span class="line" id="L20">            key_block.xorBlocks(nonce_block),</span>
<span class="line" id="L21">            key_block.xorBlocks(c2),</span>
<span class="line" id="L22">            key_block.xorBlocks(c1),</span>
<span class="line" id="L23">            key_block.xorBlocks(c2),</span>
<span class="line" id="L24">        };</span>
<span class="line" id="L25">        <span class="tok-kw">var</span> state = State128L{ .blocks = blocks };</span>
<span class="line" id="L26">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L27">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">10</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L28">            state.update(nonce_block, key_block);</span>
<span class="line" id="L29">        }</span>
<span class="line" id="L30">        <span class="tok-kw">return</span> state;</span>
<span class="line" id="L31">    }</span>
<span class="line" id="L32"></span>
<span class="line" id="L33">    <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(state: *State128L, d1: AesBlock, d2: AesBlock) <span class="tok-type">void</span> {</span>
<span class="line" id="L34">        <span class="tok-kw">const</span> blocks = &amp;state.blocks;</span>
<span class="line" id="L35">        <span class="tok-kw">const</span> tmp = blocks[<span class="tok-number">7</span>];</span>
<span class="line" id="L36">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">7</span>;</span>
<span class="line" id="L37">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &gt; <span class="tok-number">0</span>) : (i -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L38">            blocks[i] = blocks[i - <span class="tok-number">1</span>].encrypt(blocks[i]);</span>
<span class="line" id="L39">        }</span>
<span class="line" id="L40">        blocks[<span class="tok-number">0</span>] = tmp.encrypt(blocks[<span class="tok-number">0</span>]);</span>
<span class="line" id="L41">        blocks[<span class="tok-number">0</span>] = blocks[<span class="tok-number">0</span>].xorBlocks(d1);</span>
<span class="line" id="L42">        blocks[<span class="tok-number">4</span>] = blocks[<span class="tok-number">4</span>].xorBlocks(d2);</span>
<span class="line" id="L43">    }</span>
<span class="line" id="L44"></span>
<span class="line" id="L45">    <span class="tok-kw">fn</span> <span class="tok-fn">enc</span>(state: *State128L, dst: *[<span class="tok-number">32</span>]<span class="tok-type">u8</span>, src: *<span class="tok-kw">const</span> [<span class="tok-number">32</span>]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L46">        <span class="tok-kw">const</span> blocks = &amp;state.blocks;</span>
<span class="line" id="L47">        <span class="tok-kw">const</span> msg0 = AesBlock.fromBytes(src[<span class="tok-number">0</span>..<span class="tok-number">16</span>]);</span>
<span class="line" id="L48">        <span class="tok-kw">const</span> msg1 = AesBlock.fromBytes(src[<span class="tok-number">16</span>..<span class="tok-number">32</span>]);</span>
<span class="line" id="L49">        <span class="tok-kw">var</span> tmp0 = msg0.xorBlocks(blocks[<span class="tok-number">6</span>]).xorBlocks(blocks[<span class="tok-number">1</span>]);</span>
<span class="line" id="L50">        <span class="tok-kw">var</span> tmp1 = msg1.xorBlocks(blocks[<span class="tok-number">2</span>]).xorBlocks(blocks[<span class="tok-number">5</span>]);</span>
<span class="line" id="L51">        tmp0 = tmp0.xorBlocks(blocks[<span class="tok-number">2</span>].andBlocks(blocks[<span class="tok-number">3</span>]));</span>
<span class="line" id="L52">        tmp1 = tmp1.xorBlocks(blocks[<span class="tok-number">6</span>].andBlocks(blocks[<span class="tok-number">7</span>]));</span>
<span class="line" id="L53">        dst[<span class="tok-number">0</span>..<span class="tok-number">16</span>].* = tmp0.toBytes();</span>
<span class="line" id="L54">        dst[<span class="tok-number">16</span>..<span class="tok-number">32</span>].* = tmp1.toBytes();</span>
<span class="line" id="L55">        state.update(msg0, msg1);</span>
<span class="line" id="L56">    }</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">    <span class="tok-kw">fn</span> <span class="tok-fn">dec</span>(state: *State128L, dst: *[<span class="tok-number">32</span>]<span class="tok-type">u8</span>, src: *<span class="tok-kw">const</span> [<span class="tok-number">32</span>]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L59">        <span class="tok-kw">const</span> blocks = &amp;state.blocks;</span>
<span class="line" id="L60">        <span class="tok-kw">var</span> msg0 = AesBlock.fromBytes(src[<span class="tok-number">0</span>..<span class="tok-number">16</span>]).xorBlocks(blocks[<span class="tok-number">6</span>]).xorBlocks(blocks[<span class="tok-number">1</span>]);</span>
<span class="line" id="L61">        <span class="tok-kw">var</span> msg1 = AesBlock.fromBytes(src[<span class="tok-number">16</span>..<span class="tok-number">32</span>]).xorBlocks(blocks[<span class="tok-number">2</span>]).xorBlocks(blocks[<span class="tok-number">5</span>]);</span>
<span class="line" id="L62">        msg0 = msg0.xorBlocks(blocks[<span class="tok-number">2</span>].andBlocks(blocks[<span class="tok-number">3</span>]));</span>
<span class="line" id="L63">        msg1 = msg1.xorBlocks(blocks[<span class="tok-number">6</span>].andBlocks(blocks[<span class="tok-number">7</span>]));</span>
<span class="line" id="L64">        dst[<span class="tok-number">0</span>..<span class="tok-number">16</span>].* = msg0.toBytes();</span>
<span class="line" id="L65">        dst[<span class="tok-number">16</span>..<span class="tok-number">32</span>].* = msg1.toBytes();</span>
<span class="line" id="L66">        state.update(msg0, msg1);</span>
<span class="line" id="L67">    }</span>
<span class="line" id="L68"></span>
<span class="line" id="L69">    <span class="tok-kw">fn</span> <span class="tok-fn">mac</span>(state: *State128L, adlen: <span class="tok-type">usize</span>, mlen: <span class="tok-type">usize</span>) [<span class="tok-number">16</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L70">        <span class="tok-kw">const</span> blocks = &amp;state.blocks;</span>
<span class="line" id="L71">        <span class="tok-kw">var</span> sizes: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L72">        mem.writeIntLittle(<span class="tok-type">u64</span>, sizes[<span class="tok-number">0</span>..<span class="tok-number">8</span>], adlen * <span class="tok-number">8</span>);</span>
<span class="line" id="L73">        mem.writeIntLittle(<span class="tok-type">u64</span>, sizes[<span class="tok-number">8</span>..<span class="tok-number">16</span>], mlen * <span class="tok-number">8</span>);</span>
<span class="line" id="L74">        <span class="tok-kw">const</span> tmp = AesBlock.fromBytes(&amp;sizes).xorBlocks(blocks[<span class="tok-number">2</span>]);</span>
<span class="line" id="L75">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L76">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">7</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L77">            state.update(tmp, tmp);</span>
<span class="line" id="L78">        }</span>
<span class="line" id="L79">        <span class="tok-kw">return</span> blocks[<span class="tok-number">0</span>].xorBlocks(blocks[<span class="tok-number">1</span>]).xorBlocks(blocks[<span class="tok-number">2</span>]).xorBlocks(blocks[<span class="tok-number">3</span>]).xorBlocks(blocks[<span class="tok-number">4</span>])</span>
<span class="line" id="L80">            .xorBlocks(blocks[<span class="tok-number">5</span>]).xorBlocks(blocks[<span class="tok-number">6</span>]).toBytes();</span>
<span class="line" id="L81">    }</span>
<span class="line" id="L82">};</span>
<span class="line" id="L83"></span>
<span class="line" id="L84"><span class="tok-comment">/// AEGIS is a very fast authenticated encryption system built on top of the core AES function.</span></span>
<span class="line" id="L85"><span class="tok-comment">///</span></span>
<span class="line" id="L86"><span class="tok-comment">/// The 128L variant of AEGIS has a 128 bit key, a 128 bit nonce, and processes 256 bit message blocks.</span></span>
<span class="line" id="L87"><span class="tok-comment">/// It was designed to fully exploit the parallelism and built-in AES support of recent Intel and ARM CPUs.</span></span>
<span class="line" id="L88"><span class="tok-comment">///</span></span>
<span class="line" id="L89"><span class="tok-comment">/// https://competitions.cr.yp.to/round3/aegisv11.pdf</span></span>
<span class="line" id="L90"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Aegis128L = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L91">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> tag_length = <span class="tok-number">16</span>;</span>
<span class="line" id="L92">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> nonce_length = <span class="tok-number">16</span>;</span>
<span class="line" id="L93">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length = <span class="tok-number">16</span>;</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">    <span class="tok-comment">/// c: ciphertext: output buffer should be of size m.len</span></span>
<span class="line" id="L96">    <span class="tok-comment">/// tag: authentication tag: output MAC</span></span>
<span class="line" id="L97">    <span class="tok-comment">/// m: message</span></span>
<span class="line" id="L98">    <span class="tok-comment">/// ad: Associated Data</span></span>
<span class="line" id="L99">    <span class="tok-comment">/// npub: public nonce</span></span>
<span class="line" id="L100">    <span class="tok-comment">/// k: private key</span></span>
<span class="line" id="L101">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">encrypt</span>(c: []<span class="tok-type">u8</span>, tag: *[tag_length]<span class="tok-type">u8</span>, m: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, ad: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, key: [key_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L102">        assert(c.len == m.len);</span>
<span class="line" id="L103">        <span class="tok-kw">var</span> state = State128L.init(key, npub);</span>
<span class="line" id="L104">        <span class="tok-kw">var</span> src: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L105">        <span class="tok-kw">var</span> dst: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L106">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L107">        <span class="tok-kw">while</span> (i + <span class="tok-number">32</span> &lt;= ad.len) : (i += <span class="tok-number">32</span>) {</span>
<span class="line" id="L108">            state.enc(&amp;dst, ad[i..][<span class="tok-number">0</span>..<span class="tok-number">32</span>]);</span>
<span class="line" id="L109">        }</span>
<span class="line" id="L110">        <span class="tok-kw">if</span> (ad.len % <span class="tok-number">32</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L111">            mem.set(<span class="tok-type">u8</span>, src[<span class="tok-number">0</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L112">            mem.copy(<span class="tok-type">u8</span>, src[<span class="tok-number">0</span> .. ad.len % <span class="tok-number">32</span>], ad[i .. i + ad.len % <span class="tok-number">32</span>]);</span>
<span class="line" id="L113">            state.enc(&amp;dst, &amp;src);</span>
<span class="line" id="L114">        }</span>
<span class="line" id="L115">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L116">        <span class="tok-kw">while</span> (i + <span class="tok-number">32</span> &lt;= m.len) : (i += <span class="tok-number">32</span>) {</span>
<span class="line" id="L117">            state.enc(c[i..][<span class="tok-number">0</span>..<span class="tok-number">32</span>], m[i..][<span class="tok-number">0</span>..<span class="tok-number">32</span>]);</span>
<span class="line" id="L118">        }</span>
<span class="line" id="L119">        <span class="tok-kw">if</span> (m.len % <span class="tok-number">32</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L120">            mem.set(<span class="tok-type">u8</span>, src[<span class="tok-number">0</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L121">            mem.copy(<span class="tok-type">u8</span>, src[<span class="tok-number">0</span> .. m.len % <span class="tok-number">32</span>], m[i .. i + m.len % <span class="tok-number">32</span>]);</span>
<span class="line" id="L122">            state.enc(&amp;dst, &amp;src);</span>
<span class="line" id="L123">            mem.copy(<span class="tok-type">u8</span>, c[i .. i + m.len % <span class="tok-number">32</span>], dst[<span class="tok-number">0</span> .. m.len % <span class="tok-number">32</span>]);</span>
<span class="line" id="L124">        }</span>
<span class="line" id="L125">        tag.* = state.mac(ad.len, m.len);</span>
<span class="line" id="L126">    }</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">    <span class="tok-comment">/// m: message: output buffer should be of size c.len</span></span>
<span class="line" id="L129">    <span class="tok-comment">/// c: ciphertext</span></span>
<span class="line" id="L130">    <span class="tok-comment">/// tag: authentication tag</span></span>
<span class="line" id="L131">    <span class="tok-comment">/// ad: Associated Data</span></span>
<span class="line" id="L132">    <span class="tok-comment">/// npub: public nonce</span></span>
<span class="line" id="L133">    <span class="tok-comment">/// k: private key</span></span>
<span class="line" id="L134">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">decrypt</span>(m: []<span class="tok-type">u8</span>, c: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, tag: [tag_length]<span class="tok-type">u8</span>, ad: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, key: [key_length]<span class="tok-type">u8</span>) AuthenticationError!<span class="tok-type">void</span> {</span>
<span class="line" id="L135">        assert(c.len == m.len);</span>
<span class="line" id="L136">        <span class="tok-kw">var</span> state = State128L.init(key, npub);</span>
<span class="line" id="L137">        <span class="tok-kw">var</span> src: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L138">        <span class="tok-kw">var</span> dst: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L139">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L140">        <span class="tok-kw">while</span> (i + <span class="tok-number">32</span> &lt;= ad.len) : (i += <span class="tok-number">32</span>) {</span>
<span class="line" id="L141">            state.enc(&amp;dst, ad[i..][<span class="tok-number">0</span>..<span class="tok-number">32</span>]);</span>
<span class="line" id="L142">        }</span>
<span class="line" id="L143">        <span class="tok-kw">if</span> (ad.len % <span class="tok-number">32</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L144">            mem.set(<span class="tok-type">u8</span>, src[<span class="tok-number">0</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L145">            mem.copy(<span class="tok-type">u8</span>, src[<span class="tok-number">0</span> .. ad.len % <span class="tok-number">32</span>], ad[i .. i + ad.len % <span class="tok-number">32</span>]);</span>
<span class="line" id="L146">            state.enc(&amp;dst, &amp;src);</span>
<span class="line" id="L147">        }</span>
<span class="line" id="L148">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L149">        <span class="tok-kw">while</span> (i + <span class="tok-number">32</span> &lt;= m.len) : (i += <span class="tok-number">32</span>) {</span>
<span class="line" id="L150">            state.dec(m[i..][<span class="tok-number">0</span>..<span class="tok-number">32</span>], c[i..][<span class="tok-number">0</span>..<span class="tok-number">32</span>]);</span>
<span class="line" id="L151">        }</span>
<span class="line" id="L152">        <span class="tok-kw">if</span> (m.len % <span class="tok-number">32</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L153">            mem.set(<span class="tok-type">u8</span>, src[<span class="tok-number">0</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L154">            mem.copy(<span class="tok-type">u8</span>, src[<span class="tok-number">0</span> .. m.len % <span class="tok-number">32</span>], c[i .. i + m.len % <span class="tok-number">32</span>]);</span>
<span class="line" id="L155">            state.dec(&amp;dst, &amp;src);</span>
<span class="line" id="L156">            mem.copy(<span class="tok-type">u8</span>, m[i .. i + m.len % <span class="tok-number">32</span>], dst[<span class="tok-number">0</span> .. m.len % <span class="tok-number">32</span>]);</span>
<span class="line" id="L157">            mem.set(<span class="tok-type">u8</span>, dst[<span class="tok-number">0</span> .. m.len % <span class="tok-number">32</span>], <span class="tok-number">0</span>);</span>
<span class="line" id="L158">            <span class="tok-kw">const</span> blocks = &amp;state.blocks;</span>
<span class="line" id="L159">            blocks[<span class="tok-number">0</span>] = blocks[<span class="tok-number">0</span>].xorBlocks(AesBlock.fromBytes(dst[<span class="tok-number">0</span>..<span class="tok-number">16</span>]));</span>
<span class="line" id="L160">            blocks[<span class="tok-number">4</span>] = blocks[<span class="tok-number">4</span>].xorBlocks(AesBlock.fromBytes(dst[<span class="tok-number">16</span>..<span class="tok-number">32</span>]));</span>
<span class="line" id="L161">        }</span>
<span class="line" id="L162">        <span class="tok-kw">const</span> computed_tag = state.mac(ad.len, m.len);</span>
<span class="line" id="L163">        <span class="tok-kw">var</span> acc: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L164">        <span class="tok-kw">for</span> (computed_tag) |_, j| {</span>
<span class="line" id="L165">            acc |= (computed_tag[j] ^ tag[j]);</span>
<span class="line" id="L166">        }</span>
<span class="line" id="L167">        <span class="tok-kw">if</span> (acc != <span class="tok-number">0</span>) {</span>
<span class="line" id="L168">            mem.set(<span class="tok-type">u8</span>, m, <span class="tok-number">0xaa</span>);</span>
<span class="line" id="L169">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AuthenticationFailed;</span>
<span class="line" id="L170">        }</span>
<span class="line" id="L171">    }</span>
<span class="line" id="L172">};</span>
<span class="line" id="L173"></span>
<span class="line" id="L174"><span class="tok-kw">const</span> State256 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L175">    blocks: [<span class="tok-number">6</span>]AesBlock,</span>
<span class="line" id="L176"></span>
<span class="line" id="L177">    <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(key: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>, nonce: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>) State256 {</span>
<span class="line" id="L178">        <span class="tok-kw">const</span> c1 = AesBlock.fromBytes(&amp;[<span class="tok-number">16</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0xdb</span>, <span class="tok-number">0x3d</span>, <span class="tok-number">0x18</span>, <span class="tok-number">0x55</span>, <span class="tok-number">0x6d</span>, <span class="tok-number">0xc2</span>, <span class="tok-number">0x2f</span>, <span class="tok-number">0xf1</span>, <span class="tok-number">0x20</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x31</span>, <span class="tok-number">0x42</span>, <span class="tok-number">0x73</span>, <span class="tok-number">0xb5</span>, <span class="tok-number">0x28</span>, <span class="tok-number">0xdd</span> });</span>
<span class="line" id="L179">        <span class="tok-kw">const</span> c2 = AesBlock.fromBytes(&amp;[<span class="tok-number">16</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0x0</span>, <span class="tok-number">0x1</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0x02</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x05</span>, <span class="tok-number">0x08</span>, <span class="tok-number">0x0d</span>, <span class="tok-number">0x15</span>, <span class="tok-number">0x22</span>, <span class="tok-number">0x37</span>, <span class="tok-number">0x59</span>, <span class="tok-number">0x90</span>, <span class="tok-number">0xe9</span>, <span class="tok-number">0x79</span>, <span class="tok-number">0x62</span> });</span>
<span class="line" id="L180">        <span class="tok-kw">const</span> key_block1 = AesBlock.fromBytes(key[<span class="tok-number">0</span>..<span class="tok-number">16</span>]);</span>
<span class="line" id="L181">        <span class="tok-kw">const</span> key_block2 = AesBlock.fromBytes(key[<span class="tok-number">16</span>..<span class="tok-number">32</span>]);</span>
<span class="line" id="L182">        <span class="tok-kw">const</span> nonce_block1 = AesBlock.fromBytes(nonce[<span class="tok-number">0</span>..<span class="tok-number">16</span>]);</span>
<span class="line" id="L183">        <span class="tok-kw">const</span> nonce_block2 = AesBlock.fromBytes(nonce[<span class="tok-number">16</span>..<span class="tok-number">32</span>]);</span>
<span class="line" id="L184">        <span class="tok-kw">const</span> kxn1 = key_block1.xorBlocks(nonce_block1);</span>
<span class="line" id="L185">        <span class="tok-kw">const</span> kxn2 = key_block2.xorBlocks(nonce_block2);</span>
<span class="line" id="L186">        <span class="tok-kw">const</span> blocks = [<span class="tok-number">6</span>]AesBlock{</span>
<span class="line" id="L187">            kxn1,</span>
<span class="line" id="L188">            kxn2,</span>
<span class="line" id="L189">            c1,</span>
<span class="line" id="L190">            c2,</span>
<span class="line" id="L191">            key_block1.xorBlocks(c2),</span>
<span class="line" id="L192">            key_block2.xorBlocks(c1),</span>
<span class="line" id="L193">        };</span>
<span class="line" id="L194">        <span class="tok-kw">var</span> state = State256{ .blocks = blocks };</span>
<span class="line" id="L195">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L196">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">4</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L197">            state.update(key_block1);</span>
<span class="line" id="L198">            state.update(key_block2);</span>
<span class="line" id="L199">            state.update(kxn1);</span>
<span class="line" id="L200">            state.update(kxn2);</span>
<span class="line" id="L201">        }</span>
<span class="line" id="L202">        <span class="tok-kw">return</span> state;</span>
<span class="line" id="L203">    }</span>
<span class="line" id="L204"></span>
<span class="line" id="L205">    <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">update</span>(state: *State256, d: AesBlock) <span class="tok-type">void</span> {</span>
<span class="line" id="L206">        <span class="tok-kw">const</span> blocks = &amp;state.blocks;</span>
<span class="line" id="L207">        <span class="tok-kw">const</span> tmp = blocks[<span class="tok-number">5</span>].encrypt(blocks[<span class="tok-number">0</span>]);</span>
<span class="line" id="L208">        <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">5</span>;</span>
<span class="line" id="L209">        <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &gt; <span class="tok-number">0</span>) : (i -= <span class="tok-number">1</span>) {</span>
<span class="line" id="L210">            blocks[i] = blocks[i - <span class="tok-number">1</span>].encrypt(blocks[i]);</span>
<span class="line" id="L211">        }</span>
<span class="line" id="L212">        blocks[<span class="tok-number">0</span>] = tmp.xorBlocks(d);</span>
<span class="line" id="L213">    }</span>
<span class="line" id="L214"></span>
<span class="line" id="L215">    <span class="tok-kw">fn</span> <span class="tok-fn">enc</span>(state: *State256, dst: *[<span class="tok-number">16</span>]<span class="tok-type">u8</span>, src: *<span class="tok-kw">const</span> [<span class="tok-number">16</span>]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L216">        <span class="tok-kw">const</span> blocks = &amp;state.blocks;</span>
<span class="line" id="L217">        <span class="tok-kw">const</span> msg = AesBlock.fromBytes(src);</span>
<span class="line" id="L218">        <span class="tok-kw">var</span> tmp = msg.xorBlocks(blocks[<span class="tok-number">5</span>]).xorBlocks(blocks[<span class="tok-number">4</span>]).xorBlocks(blocks[<span class="tok-number">1</span>]);</span>
<span class="line" id="L219">        tmp = tmp.xorBlocks(blocks[<span class="tok-number">2</span>].andBlocks(blocks[<span class="tok-number">3</span>]));</span>
<span class="line" id="L220">        dst.* = tmp.toBytes();</span>
<span class="line" id="L221">        state.update(msg);</span>
<span class="line" id="L222">    }</span>
<span class="line" id="L223"></span>
<span class="line" id="L224">    <span class="tok-kw">fn</span> <span class="tok-fn">dec</span>(state: *State256, dst: *[<span class="tok-number">16</span>]<span class="tok-type">u8</span>, src: *<span class="tok-kw">const</span> [<span class="tok-number">16</span>]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L225">        <span class="tok-kw">const</span> blocks = &amp;state.blocks;</span>
<span class="line" id="L226">        <span class="tok-kw">var</span> msg = AesBlock.fromBytes(src).xorBlocks(blocks[<span class="tok-number">5</span>]).xorBlocks(blocks[<span class="tok-number">4</span>]).xorBlocks(blocks[<span class="tok-number">1</span>]);</span>
<span class="line" id="L227">        msg = msg.xorBlocks(blocks[<span class="tok-number">2</span>].andBlocks(blocks[<span class="tok-number">3</span>]));</span>
<span class="line" id="L228">        dst.* = msg.toBytes();</span>
<span class="line" id="L229">        state.update(msg);</span>
<span class="line" id="L230">    }</span>
<span class="line" id="L231"></span>
<span class="line" id="L232">    <span class="tok-kw">fn</span> <span class="tok-fn">mac</span>(state: *State256, adlen: <span class="tok-type">usize</span>, mlen: <span class="tok-type">usize</span>) [<span class="tok-number">16</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L233">        <span class="tok-kw">const</span> blocks = &amp;state.blocks;</span>
<span class="line" id="L234">        <span class="tok-kw">var</span> sizes: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L235">        mem.writeIntLittle(<span class="tok-type">u64</span>, sizes[<span class="tok-number">0</span>..<span class="tok-number">8</span>], adlen * <span class="tok-number">8</span>);</span>
<span class="line" id="L236">        mem.writeIntLittle(<span class="tok-type">u64</span>, sizes[<span class="tok-number">8</span>..<span class="tok-number">16</span>], mlen * <span class="tok-number">8</span>);</span>
<span class="line" id="L237">        <span class="tok-kw">const</span> tmp = AesBlock.fromBytes(&amp;sizes).xorBlocks(blocks[<span class="tok-number">3</span>]);</span>
<span class="line" id="L238">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L239">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">7</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L240">            state.update(tmp);</span>
<span class="line" id="L241">        }</span>
<span class="line" id="L242">        <span class="tok-kw">return</span> blocks[<span class="tok-number">0</span>].xorBlocks(blocks[<span class="tok-number">1</span>]).xorBlocks(blocks[<span class="tok-number">2</span>]).xorBlocks(blocks[<span class="tok-number">3</span>]).xorBlocks(blocks[<span class="tok-number">4</span>])</span>
<span class="line" id="L243">            .xorBlocks(blocks[<span class="tok-number">5</span>]).toBytes();</span>
<span class="line" id="L244">    }</span>
<span class="line" id="L245">};</span>
<span class="line" id="L246"></span>
<span class="line" id="L247"><span class="tok-comment">/// AEGIS is a very fast authenticated encryption system built on top of the core AES function.</span></span>
<span class="line" id="L248"><span class="tok-comment">///</span></span>
<span class="line" id="L249"><span class="tok-comment">/// The 256 bit variant of AEGIS has a 256 bit key, a 256 bit nonce, and processes 128 bit message blocks.</span></span>
<span class="line" id="L250"><span class="tok-comment">///</span></span>
<span class="line" id="L251"><span class="tok-comment">/// https://competitions.cr.yp.to/round3/aegisv11.pdf</span></span>
<span class="line" id="L252"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Aegis256 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L253">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> tag_length = <span class="tok-number">16</span>;</span>
<span class="line" id="L254">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> nonce_length = <span class="tok-number">32</span>;</span>
<span class="line" id="L255">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length = <span class="tok-number">32</span>;</span>
<span class="line" id="L256"></span>
<span class="line" id="L257">    <span class="tok-comment">/// c: ciphertext: output buffer should be of size m.len</span></span>
<span class="line" id="L258">    <span class="tok-comment">/// tag: authentication tag: output MAC</span></span>
<span class="line" id="L259">    <span class="tok-comment">/// m: message</span></span>
<span class="line" id="L260">    <span class="tok-comment">/// ad: Associated Data</span></span>
<span class="line" id="L261">    <span class="tok-comment">/// npub: public nonce</span></span>
<span class="line" id="L262">    <span class="tok-comment">/// k: private key</span></span>
<span class="line" id="L263">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">encrypt</span>(c: []<span class="tok-type">u8</span>, tag: *[tag_length]<span class="tok-type">u8</span>, m: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, ad: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, key: [key_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L264">        assert(c.len == m.len);</span>
<span class="line" id="L265">        <span class="tok-kw">var</span> state = State256.init(key, npub);</span>
<span class="line" id="L266">        <span class="tok-kw">var</span> src: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L267">        <span class="tok-kw">var</span> dst: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L268">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L269">        <span class="tok-kw">while</span> (i + <span class="tok-number">16</span> &lt;= ad.len) : (i += <span class="tok-number">16</span>) {</span>
<span class="line" id="L270">            state.enc(&amp;dst, ad[i..][<span class="tok-number">0</span>..<span class="tok-number">16</span>]);</span>
<span class="line" id="L271">        }</span>
<span class="line" id="L272">        <span class="tok-kw">if</span> (ad.len % <span class="tok-number">16</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L273">            mem.set(<span class="tok-type">u8</span>, src[<span class="tok-number">0</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L274">            mem.copy(<span class="tok-type">u8</span>, src[<span class="tok-number">0</span> .. ad.len % <span class="tok-number">16</span>], ad[i .. i + ad.len % <span class="tok-number">16</span>]);</span>
<span class="line" id="L275">            state.enc(&amp;dst, &amp;src);</span>
<span class="line" id="L276">        }</span>
<span class="line" id="L277">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L278">        <span class="tok-kw">while</span> (i + <span class="tok-number">16</span> &lt;= m.len) : (i += <span class="tok-number">16</span>) {</span>
<span class="line" id="L279">            state.enc(c[i..][<span class="tok-number">0</span>..<span class="tok-number">16</span>], m[i..][<span class="tok-number">0</span>..<span class="tok-number">16</span>]);</span>
<span class="line" id="L280">        }</span>
<span class="line" id="L281">        <span class="tok-kw">if</span> (m.len % <span class="tok-number">16</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L282">            mem.set(<span class="tok-type">u8</span>, src[<span class="tok-number">0</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L283">            mem.copy(<span class="tok-type">u8</span>, src[<span class="tok-number">0</span> .. m.len % <span class="tok-number">16</span>], m[i .. i + m.len % <span class="tok-number">16</span>]);</span>
<span class="line" id="L284">            state.enc(&amp;dst, &amp;src);</span>
<span class="line" id="L285">            mem.copy(<span class="tok-type">u8</span>, c[i .. i + m.len % <span class="tok-number">16</span>], dst[<span class="tok-number">0</span> .. m.len % <span class="tok-number">16</span>]);</span>
<span class="line" id="L286">        }</span>
<span class="line" id="L287">        tag.* = state.mac(ad.len, m.len);</span>
<span class="line" id="L288">    }</span>
<span class="line" id="L289"></span>
<span class="line" id="L290">    <span class="tok-comment">/// m: message: output buffer should be of size c.len</span></span>
<span class="line" id="L291">    <span class="tok-comment">/// c: ciphertext</span></span>
<span class="line" id="L292">    <span class="tok-comment">/// tag: authentication tag</span></span>
<span class="line" id="L293">    <span class="tok-comment">/// ad: Associated Data</span></span>
<span class="line" id="L294">    <span class="tok-comment">/// npub: public nonce</span></span>
<span class="line" id="L295">    <span class="tok-comment">/// k: private key</span></span>
<span class="line" id="L296">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">decrypt</span>(m: []<span class="tok-type">u8</span>, c: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, tag: [tag_length]<span class="tok-type">u8</span>, ad: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, key: [key_length]<span class="tok-type">u8</span>) AuthenticationError!<span class="tok-type">void</span> {</span>
<span class="line" id="L297">        assert(c.len == m.len);</span>
<span class="line" id="L298">        <span class="tok-kw">var</span> state = State256.init(key, npub);</span>
<span class="line" id="L299">        <span class="tok-kw">var</span> src: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L300">        <span class="tok-kw">var</span> dst: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-number">16</span>) = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L301">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L302">        <span class="tok-kw">while</span> (i + <span class="tok-number">16</span> &lt;= ad.len) : (i += <span class="tok-number">16</span>) {</span>
<span class="line" id="L303">            state.enc(&amp;dst, ad[i..][<span class="tok-number">0</span>..<span class="tok-number">16</span>]);</span>
<span class="line" id="L304">        }</span>
<span class="line" id="L305">        <span class="tok-kw">if</span> (ad.len % <span class="tok-number">16</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L306">            mem.set(<span class="tok-type">u8</span>, src[<span class="tok-number">0</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L307">            mem.copy(<span class="tok-type">u8</span>, src[<span class="tok-number">0</span> .. ad.len % <span class="tok-number">16</span>], ad[i .. i + ad.len % <span class="tok-number">16</span>]);</span>
<span class="line" id="L308">            state.enc(&amp;dst, &amp;src);</span>
<span class="line" id="L309">        }</span>
<span class="line" id="L310">        i = <span class="tok-number">0</span>;</span>
<span class="line" id="L311">        <span class="tok-kw">while</span> (i + <span class="tok-number">16</span> &lt;= m.len) : (i += <span class="tok-number">16</span>) {</span>
<span class="line" id="L312">            state.dec(m[i..][<span class="tok-number">0</span>..<span class="tok-number">16</span>], c[i..][<span class="tok-number">0</span>..<span class="tok-number">16</span>]);</span>
<span class="line" id="L313">        }</span>
<span class="line" id="L314">        <span class="tok-kw">if</span> (m.len % <span class="tok-number">16</span> != <span class="tok-number">0</span>) {</span>
<span class="line" id="L315">            mem.set(<span class="tok-type">u8</span>, src[<span class="tok-number">0</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L316">            mem.copy(<span class="tok-type">u8</span>, src[<span class="tok-number">0</span> .. m.len % <span class="tok-number">16</span>], c[i .. i + m.len % <span class="tok-number">16</span>]);</span>
<span class="line" id="L317">            state.dec(&amp;dst, &amp;src);</span>
<span class="line" id="L318">            mem.copy(<span class="tok-type">u8</span>, m[i .. i + m.len % <span class="tok-number">16</span>], dst[<span class="tok-number">0</span> .. m.len % <span class="tok-number">16</span>]);</span>
<span class="line" id="L319">            mem.set(<span class="tok-type">u8</span>, dst[<span class="tok-number">0</span> .. m.len % <span class="tok-number">16</span>], <span class="tok-number">0</span>);</span>
<span class="line" id="L320">            <span class="tok-kw">const</span> blocks = &amp;state.blocks;</span>
<span class="line" id="L321">            blocks[<span class="tok-number">0</span>] = blocks[<span class="tok-number">0</span>].xorBlocks(AesBlock.fromBytes(&amp;dst));</span>
<span class="line" id="L322">        }</span>
<span class="line" id="L323">        <span class="tok-kw">const</span> computed_tag = state.mac(ad.len, m.len);</span>
<span class="line" id="L324">        <span class="tok-kw">var</span> acc: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L325">        <span class="tok-kw">for</span> (computed_tag) |_, j| {</span>
<span class="line" id="L326">            acc |= (computed_tag[j] ^ tag[j]);</span>
<span class="line" id="L327">        }</span>
<span class="line" id="L328">        <span class="tok-kw">if</span> (acc != <span class="tok-number">0</span>) {</span>
<span class="line" id="L329">            mem.set(<span class="tok-type">u8</span>, m, <span class="tok-number">0xaa</span>);</span>
<span class="line" id="L330">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AuthenticationFailed;</span>
<span class="line" id="L331">        }</span>
<span class="line" id="L332">    }</span>
<span class="line" id="L333">};</span>
<span class="line" id="L334"></span>
<span class="line" id="L335"><span class="tok-kw">const</span> htest = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;test.zig&quot;</span>);</span>
<span class="line" id="L336"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L337"></span>
<span class="line" id="L338"><span class="tok-kw">test</span> <span class="tok-str">&quot;Aegis128L test vector 1&quot;</span> {</span>
<span class="line" id="L339">    <span class="tok-kw">const</span> key: [Aegis128L.key_length]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x10</span>, <span class="tok-number">0x01</span> } ++ [_]<span class="tok-type">u8</span>{<span class="tok-number">0x00</span>} ** <span class="tok-number">14</span>;</span>
<span class="line" id="L340">    <span class="tok-kw">const</span> nonce: [Aegis128L.nonce_length]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x10</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x02</span> } ++ [_]<span class="tok-type">u8</span>{<span class="tok-number">0x00</span>} ** <span class="tok-number">13</span>;</span>
<span class="line" id="L341">    <span class="tok-kw">const</span> ad = [<span class="tok-number">8</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0x00</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0x02</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x04</span>, <span class="tok-number">0x05</span>, <span class="tok-number">0x06</span>, <span class="tok-number">0x07</span> };</span>
<span class="line" id="L342">    <span class="tok-kw">const</span> m = [<span class="tok-number">32</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0x00</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0x02</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x04</span>, <span class="tok-number">0x05</span>, <span class="tok-number">0x06</span>, <span class="tok-number">0x07</span>, <span class="tok-number">0x08</span>, <span class="tok-number">0x09</span>, <span class="tok-number">0x0a</span>, <span class="tok-number">0x0b</span>, <span class="tok-number">0x0c</span>, <span class="tok-number">0x0d</span>, <span class="tok-number">0x0e</span>, <span class="tok-number">0x0f</span>, <span class="tok-number">0x10</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x12</span>, <span class="tok-number">0x13</span>, <span class="tok-number">0x14</span>, <span class="tok-number">0x15</span>, <span class="tok-number">0x16</span>, <span class="tok-number">0x17</span>, <span class="tok-number">0x18</span>, <span class="tok-number">0x19</span>, <span class="tok-number">0x1a</span>, <span class="tok-number">0x1b</span>, <span class="tok-number">0x1c</span>, <span class="tok-number">0x1d</span>, <span class="tok-number">0x1e</span>, <span class="tok-number">0x1f</span> };</span>
<span class="line" id="L343">    <span class="tok-kw">var</span> c: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L344">    <span class="tok-kw">var</span> m2: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L345">    <span class="tok-kw">var</span> tag: [Aegis128L.tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L346"></span>
<span class="line" id="L347">    Aegis128L.encrypt(&amp;c, &amp;tag, &amp;m, &amp;ad, nonce, key);</span>
<span class="line" id="L348">    <span class="tok-kw">try</span> Aegis128L.decrypt(&amp;m2, &amp;c, tag, &amp;ad, nonce, key);</span>
<span class="line" id="L349">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;m, &amp;m2);</span>
<span class="line" id="L350"></span>
<span class="line" id="L351">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;79d94593d8c2119d7e8fd9b8fc77845c5c077a05b2528b6ac54b563aed8efe84&quot;</span>, &amp;c);</span>
<span class="line" id="L352">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;cc6f3372f6aa1bb82388d695c3962d9a&quot;</span>, &amp;tag);</span>
<span class="line" id="L353"></span>
<span class="line" id="L354">    c[<span class="tok-number">0</span>] +%= <span class="tok-number">1</span>;</span>
<span class="line" id="L355">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.AuthenticationFailed, Aegis128L.decrypt(&amp;m2, &amp;c, tag, &amp;ad, nonce, key));</span>
<span class="line" id="L356">    c[<span class="tok-number">0</span>] -%= <span class="tok-number">1</span>;</span>
<span class="line" id="L357">    tag[<span class="tok-number">0</span>] +%= <span class="tok-number">1</span>;</span>
<span class="line" id="L358">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.AuthenticationFailed, Aegis128L.decrypt(&amp;m2, &amp;c, tag, &amp;ad, nonce, key));</span>
<span class="line" id="L359">}</span>
<span class="line" id="L360"></span>
<span class="line" id="L361"><span class="tok-kw">test</span> <span class="tok-str">&quot;Aegis128L test vector 2&quot;</span> {</span>
<span class="line" id="L362">    <span class="tok-kw">const</span> key: [Aegis128L.key_length]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x00</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L363">    <span class="tok-kw">const</span> nonce: [Aegis128L.nonce_length]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x00</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L364">    <span class="tok-kw">const</span> ad = [_]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L365">    <span class="tok-kw">const</span> m = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x00</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L366">    <span class="tok-kw">var</span> c: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L367">    <span class="tok-kw">var</span> m2: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L368">    <span class="tok-kw">var</span> tag: [Aegis128L.tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L369"></span>
<span class="line" id="L370">    Aegis128L.encrypt(&amp;c, &amp;tag, &amp;m, &amp;ad, nonce, key);</span>
<span class="line" id="L371">    <span class="tok-kw">try</span> Aegis128L.decrypt(&amp;m2, &amp;c, tag, &amp;ad, nonce, key);</span>
<span class="line" id="L372">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;m, &amp;m2);</span>
<span class="line" id="L373"></span>
<span class="line" id="L374">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;41de9000a7b5e40e2d68bb64d99ebb19&quot;</span>, &amp;c);</span>
<span class="line" id="L375">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;f4d997cc9b94227ada4fe4165422b1c8&quot;</span>, &amp;tag);</span>
<span class="line" id="L376">}</span>
<span class="line" id="L377"></span>
<span class="line" id="L378"><span class="tok-kw">test</span> <span class="tok-str">&quot;Aegis128L test vector 3&quot;</span> {</span>
<span class="line" id="L379">    <span class="tok-kw">const</span> key: [Aegis128L.key_length]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x00</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L380">    <span class="tok-kw">const</span> nonce: [Aegis128L.nonce_length]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x00</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L381">    <span class="tok-kw">const</span> ad = [_]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L382">    <span class="tok-kw">const</span> m = [_]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L383">    <span class="tok-kw">var</span> c: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L384">    <span class="tok-kw">var</span> m2: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L385">    <span class="tok-kw">var</span> tag: [Aegis128L.tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L386"></span>
<span class="line" id="L387">    Aegis128L.encrypt(&amp;c, &amp;tag, &amp;m, &amp;ad, nonce, key);</span>
<span class="line" id="L388">    <span class="tok-kw">try</span> Aegis128L.decrypt(&amp;m2, &amp;c, tag, &amp;ad, nonce, key);</span>
<span class="line" id="L389">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;m, &amp;m2);</span>
<span class="line" id="L390"></span>
<span class="line" id="L391">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;83cc600dc4e3e7e62d4055826174f149&quot;</span>, &amp;tag);</span>
<span class="line" id="L392">}</span>
<span class="line" id="L393"></span>
<span class="line" id="L394"><span class="tok-kw">test</span> <span class="tok-str">&quot;Aegis256 test vector 1&quot;</span> {</span>
<span class="line" id="L395">    <span class="tok-kw">const</span> key: [Aegis256.key_length]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x10</span>, <span class="tok-number">0x01</span> } ++ [_]<span class="tok-type">u8</span>{<span class="tok-number">0x00</span>} ** <span class="tok-number">30</span>;</span>
<span class="line" id="L396">    <span class="tok-kw">const</span> nonce: [Aegis256.nonce_length]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x10</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x02</span> } ++ [_]<span class="tok-type">u8</span>{<span class="tok-number">0x00</span>} ** <span class="tok-number">29</span>;</span>
<span class="line" id="L397">    <span class="tok-kw">const</span> ad = [<span class="tok-number">8</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0x00</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0x02</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x04</span>, <span class="tok-number">0x05</span>, <span class="tok-number">0x06</span>, <span class="tok-number">0x07</span> };</span>
<span class="line" id="L398">    <span class="tok-kw">const</span> m = [<span class="tok-number">32</span>]<span class="tok-type">u8</span>{ <span class="tok-number">0x00</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0x02</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x04</span>, <span class="tok-number">0x05</span>, <span class="tok-number">0x06</span>, <span class="tok-number">0x07</span>, <span class="tok-number">0x08</span>, <span class="tok-number">0x09</span>, <span class="tok-number">0x0a</span>, <span class="tok-number">0x0b</span>, <span class="tok-number">0x0c</span>, <span class="tok-number">0x0d</span>, <span class="tok-number">0x0e</span>, <span class="tok-number">0x0f</span>, <span class="tok-number">0x10</span>, <span class="tok-number">0x11</span>, <span class="tok-number">0x12</span>, <span class="tok-number">0x13</span>, <span class="tok-number">0x14</span>, <span class="tok-number">0x15</span>, <span class="tok-number">0x16</span>, <span class="tok-number">0x17</span>, <span class="tok-number">0x18</span>, <span class="tok-number">0x19</span>, <span class="tok-number">0x1a</span>, <span class="tok-number">0x1b</span>, <span class="tok-number">0x1c</span>, <span class="tok-number">0x1d</span>, <span class="tok-number">0x1e</span>, <span class="tok-number">0x1f</span> };</span>
<span class="line" id="L399">    <span class="tok-kw">var</span> c: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L400">    <span class="tok-kw">var</span> m2: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L401">    <span class="tok-kw">var</span> tag: [Aegis256.tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L402"></span>
<span class="line" id="L403">    Aegis256.encrypt(&amp;c, &amp;tag, &amp;m, &amp;ad, nonce, key);</span>
<span class="line" id="L404">    <span class="tok-kw">try</span> Aegis256.decrypt(&amp;m2, &amp;c, tag, &amp;ad, nonce, key);</span>
<span class="line" id="L405">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;m, &amp;m2);</span>
<span class="line" id="L406"></span>
<span class="line" id="L407">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;f373079ed84b2709faee373584585d60accd191db310ef5d8b11833df9dec711&quot;</span>, &amp;c);</span>
<span class="line" id="L408">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;8d86f91ee606e9ff26a01b64ccbdd91d&quot;</span>, &amp;tag);</span>
<span class="line" id="L409"></span>
<span class="line" id="L410">    c[<span class="tok-number">0</span>] +%= <span class="tok-number">1</span>;</span>
<span class="line" id="L411">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.AuthenticationFailed, Aegis256.decrypt(&amp;m2, &amp;c, tag, &amp;ad, nonce, key));</span>
<span class="line" id="L412">    c[<span class="tok-number">0</span>] -%= <span class="tok-number">1</span>;</span>
<span class="line" id="L413">    tag[<span class="tok-number">0</span>] +%= <span class="tok-number">1</span>;</span>
<span class="line" id="L414">    <span class="tok-kw">try</span> testing.expectError(<span class="tok-kw">error</span>.AuthenticationFailed, Aegis256.decrypt(&amp;m2, &amp;c, tag, &amp;ad, nonce, key));</span>
<span class="line" id="L415">}</span>
<span class="line" id="L416"></span>
<span class="line" id="L417"><span class="tok-kw">test</span> <span class="tok-str">&quot;Aegis256 test vector 2&quot;</span> {</span>
<span class="line" id="L418">    <span class="tok-kw">const</span> key: [Aegis256.key_length]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x00</span>} ** <span class="tok-number">32</span>;</span>
<span class="line" id="L419">    <span class="tok-kw">const</span> nonce: [Aegis256.nonce_length]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x00</span>} ** <span class="tok-number">32</span>;</span>
<span class="line" id="L420">    <span class="tok-kw">const</span> ad = [_]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L421">    <span class="tok-kw">const</span> m = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x00</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L422">    <span class="tok-kw">var</span> c: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L423">    <span class="tok-kw">var</span> m2: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L424">    <span class="tok-kw">var</span> tag: [Aegis256.tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L425"></span>
<span class="line" id="L426">    Aegis256.encrypt(&amp;c, &amp;tag, &amp;m, &amp;ad, nonce, key);</span>
<span class="line" id="L427">    <span class="tok-kw">try</span> Aegis256.decrypt(&amp;m2, &amp;c, tag, &amp;ad, nonce, key);</span>
<span class="line" id="L428">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;m, &amp;m2);</span>
<span class="line" id="L429"></span>
<span class="line" id="L430">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;b98f03a947807713d75a4fff9fc277a6&quot;</span>, &amp;c);</span>
<span class="line" id="L431">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;478f3b50dc478ef7d5cf2d0f7cc13180&quot;</span>, &amp;tag);</span>
<span class="line" id="L432">}</span>
<span class="line" id="L433"></span>
<span class="line" id="L434"><span class="tok-kw">test</span> <span class="tok-str">&quot;Aegis256 test vector 3&quot;</span> {</span>
<span class="line" id="L435">    <span class="tok-kw">const</span> key: [Aegis256.key_length]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x00</span>} ** <span class="tok-number">32</span>;</span>
<span class="line" id="L436">    <span class="tok-kw">const</span> nonce: [Aegis256.nonce_length]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x00</span>} ** <span class="tok-number">32</span>;</span>
<span class="line" id="L437">    <span class="tok-kw">const</span> ad = [_]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L438">    <span class="tok-kw">const</span> m = [_]<span class="tok-type">u8</span>{};</span>
<span class="line" id="L439">    <span class="tok-kw">var</span> c: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L440">    <span class="tok-kw">var</span> m2: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L441">    <span class="tok-kw">var</span> tag: [Aegis256.tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L442"></span>
<span class="line" id="L443">    Aegis256.encrypt(&amp;c, &amp;tag, &amp;m, &amp;ad, nonce, key);</span>
<span class="line" id="L444">    <span class="tok-kw">try</span> Aegis256.decrypt(&amp;m2, &amp;c, tag, &amp;ad, nonce, key);</span>
<span class="line" id="L445">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;m, &amp;m2);</span>
<span class="line" id="L446"></span>
<span class="line" id="L447">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;f7a0878f68bd083e8065354071fc27c3&quot;</span>, &amp;tag);</span>
<span class="line" id="L448">}</span>
<span class="line" id="L449"></span>
</code></pre></body>
</html>