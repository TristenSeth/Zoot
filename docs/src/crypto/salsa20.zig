<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/salsa20.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> crypto = std.crypto;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> utils = std.crypto.utils;</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-kw">const</span> Poly1305 = crypto.onetimeauth.Poly1305;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> Blake2b = crypto.hash.blake2.Blake2b;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> X25519 = crypto.dh.X25519;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">const</span> AuthenticationError = crypto.errors.AuthenticationError;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> IdentityElementError = crypto.errors.IdentityElementError;</span>
<span class="line" id="L15"><span class="tok-kw">const</span> WeakPublicKeyError = crypto.errors.WeakPublicKeyError;</span>
<span class="line" id="L16"></span>
<span class="line" id="L17"><span class="tok-kw">const</span> Salsa20VecImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L18">    <span class="tok-kw">const</span> Lane = <span class="tok-builtin">@Vector</span>(<span class="tok-number">4</span>, <span class="tok-type">u32</span>);</span>
<span class="line" id="L19">    <span class="tok-kw">const</span> Half = <span class="tok-builtin">@Vector</span>(<span class="tok-number">2</span>, <span class="tok-type">u32</span>);</span>
<span class="line" id="L20">    <span class="tok-kw">const</span> BlockVec = [<span class="tok-number">4</span>]Lane;</span>
<span class="line" id="L21"></span>
<span class="line" id="L22">    <span class="tok-kw">fn</span> <span class="tok-fn">initContext</span>(key: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>, d: [<span class="tok-number">4</span>]<span class="tok-type">u32</span>) BlockVec {</span>
<span class="line" id="L23">        <span class="tok-kw">const</span> c = <span class="tok-str">&quot;expand 32-byte k&quot;</span>;</span>
<span class="line" id="L24">        <span class="tok-kw">const</span> constant_le = <span class="tok-kw">comptime</span> [<span class="tok-number">4</span>]<span class="tok-type">u32</span>{</span>
<span class="line" id="L25">            mem.readIntLittle(<span class="tok-type">u32</span>, c[<span class="tok-number">0</span>..<span class="tok-number">4</span>]),</span>
<span class="line" id="L26">            mem.readIntLittle(<span class="tok-type">u32</span>, c[<span class="tok-number">4</span>..<span class="tok-number">8</span>]),</span>
<span class="line" id="L27">            mem.readIntLittle(<span class="tok-type">u32</span>, c[<span class="tok-number">8</span>..<span class="tok-number">12</span>]),</span>
<span class="line" id="L28">            mem.readIntLittle(<span class="tok-type">u32</span>, c[<span class="tok-number">12</span>..<span class="tok-number">16</span>]),</span>
<span class="line" id="L29">        };</span>
<span class="line" id="L30">        <span class="tok-kw">return</span> BlockVec{</span>
<span class="line" id="L31">            Lane{ key[<span class="tok-number">0</span>], key[<span class="tok-number">1</span>], key[<span class="tok-number">2</span>], key[<span class="tok-number">3</span>] },</span>
<span class="line" id="L32">            Lane{ key[<span class="tok-number">4</span>], key[<span class="tok-number">5</span>], key[<span class="tok-number">6</span>], key[<span class="tok-number">7</span>] },</span>
<span class="line" id="L33">            Lane{ constant_le[<span class="tok-number">0</span>], constant_le[<span class="tok-number">1</span>], constant_le[<span class="tok-number">2</span>], constant_le[<span class="tok-number">3</span>] },</span>
<span class="line" id="L34">            Lane{ d[<span class="tok-number">0</span>], d[<span class="tok-number">1</span>], d[<span class="tok-number">2</span>], d[<span class="tok-number">3</span>] },</span>
<span class="line" id="L35">        };</span>
<span class="line" id="L36">    }</span>
<span class="line" id="L37"></span>
<span class="line" id="L38">    <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">salsa20Core</span>(x: *BlockVec, input: BlockVec, <span class="tok-kw">comptime</span> feedback: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L39">        <span class="tok-kw">const</span> n1n2n3n0 = Lane{ input[<span class="tok-number">3</span>][<span class="tok-number">1</span>], input[<span class="tok-number">3</span>][<span class="tok-number">2</span>], input[<span class="tok-number">3</span>][<span class="tok-number">3</span>], input[<span class="tok-number">3</span>][<span class="tok-number">0</span>] };</span>
<span class="line" id="L40">        <span class="tok-kw">const</span> n1n2 = Half{ n1n2n3n0[<span class="tok-number">0</span>], n1n2n3n0[<span class="tok-number">1</span>] };</span>
<span class="line" id="L41">        <span class="tok-kw">const</span> n3n0 = Half{ n1n2n3n0[<span class="tok-number">2</span>], n1n2n3n0[<span class="tok-number">3</span>] };</span>
<span class="line" id="L42">        <span class="tok-kw">const</span> k0k1 = Half{ input[<span class="tok-number">0</span>][<span class="tok-number">0</span>], input[<span class="tok-number">0</span>][<span class="tok-number">1</span>] };</span>
<span class="line" id="L43">        <span class="tok-kw">const</span> k2k3 = Half{ input[<span class="tok-number">0</span>][<span class="tok-number">2</span>], input[<span class="tok-number">0</span>][<span class="tok-number">3</span>] };</span>
<span class="line" id="L44">        <span class="tok-kw">const</span> k4k5 = Half{ input[<span class="tok-number">1</span>][<span class="tok-number">0</span>], input[<span class="tok-number">1</span>][<span class="tok-number">1</span>] };</span>
<span class="line" id="L45">        <span class="tok-kw">const</span> k6k7 = Half{ input[<span class="tok-number">1</span>][<span class="tok-number">2</span>], input[<span class="tok-number">1</span>][<span class="tok-number">3</span>] };</span>
<span class="line" id="L46">        <span class="tok-kw">const</span> n0k0 = Half{ n3n0[<span class="tok-number">1</span>], k0k1[<span class="tok-number">0</span>] };</span>
<span class="line" id="L47">        <span class="tok-kw">const</span> k0n0 = Half{ n0k0[<span class="tok-number">1</span>], n0k0[<span class="tok-number">0</span>] };</span>
<span class="line" id="L48">        <span class="tok-kw">const</span> k4k5k0n0 = Lane{ k4k5[<span class="tok-number">0</span>], k4k5[<span class="tok-number">1</span>], k0n0[<span class="tok-number">0</span>], k0n0[<span class="tok-number">1</span>] };</span>
<span class="line" id="L49">        <span class="tok-kw">const</span> k1k6 = Half{ k0k1[<span class="tok-number">1</span>], k6k7[<span class="tok-number">0</span>] };</span>
<span class="line" id="L50">        <span class="tok-kw">const</span> k6k1 = Half{ k1k6[<span class="tok-number">1</span>], k1k6[<span class="tok-number">0</span>] };</span>
<span class="line" id="L51">        <span class="tok-kw">const</span> n1n2k6k1 = Lane{ n1n2[<span class="tok-number">0</span>], n1n2[<span class="tok-number">1</span>], k6k1[<span class="tok-number">0</span>], k6k1[<span class="tok-number">1</span>] };</span>
<span class="line" id="L52">        <span class="tok-kw">const</span> k7n3 = Half{ k6k7[<span class="tok-number">1</span>], n3n0[<span class="tok-number">0</span>] };</span>
<span class="line" id="L53">        <span class="tok-kw">const</span> n3k7 = Half{ k7n3[<span class="tok-number">1</span>], k7n3[<span class="tok-number">0</span>] };</span>
<span class="line" id="L54">        <span class="tok-kw">const</span> k2k3n3k7 = Lane{ k2k3[<span class="tok-number">0</span>], k2k3[<span class="tok-number">1</span>], n3k7[<span class="tok-number">0</span>], n3k7[<span class="tok-number">1</span>] };</span>
<span class="line" id="L55"></span>
<span class="line" id="L56">        <span class="tok-kw">var</span> diag0 = input[<span class="tok-number">2</span>];</span>
<span class="line" id="L57">        <span class="tok-kw">var</span> diag1 = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, k4k5k0n0, <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span> });</span>
<span class="line" id="L58">        <span class="tok-kw">var</span> diag2 = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, n1n2k6k1, <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span> });</span>
<span class="line" id="L59">        <span class="tok-kw">var</span> diag3 = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, k2k3n3k7, <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span> });</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">        <span class="tok-kw">const</span> start0 = diag0;</span>
<span class="line" id="L62">        <span class="tok-kw">const</span> start1 = diag1;</span>
<span class="line" id="L63">        <span class="tok-kw">const</span> start2 = diag2;</span>
<span class="line" id="L64">        <span class="tok-kw">const</span> start3 = diag3;</span>
<span class="line" id="L65"></span>
<span class="line" id="L66">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L67">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">20</span>) : (i += <span class="tok-number">2</span>) {</span>
<span class="line" id="L68">            <span class="tok-kw">var</span> a0 = diag1 +% diag0;</span>
<span class="line" id="L69">            diag3 ^= math.rotl(Lane, a0, <span class="tok-number">7</span>);</span>
<span class="line" id="L70">            <span class="tok-kw">var</span> a1 = diag0 +% diag3;</span>
<span class="line" id="L71">            diag2 ^= math.rotl(Lane, a1, <span class="tok-number">9</span>);</span>
<span class="line" id="L72">            <span class="tok-kw">var</span> a2 = diag3 +% diag2;</span>
<span class="line" id="L73">            diag1 ^= math.rotl(Lane, a2, <span class="tok-number">13</span>);</span>
<span class="line" id="L74">            <span class="tok-kw">var</span> a3 = diag2 +% diag1;</span>
<span class="line" id="L75">            diag0 ^= math.rotl(Lane, a3, <span class="tok-number">18</span>);</span>
<span class="line" id="L76"></span>
<span class="line" id="L77">            <span class="tok-kw">var</span> diag3_shift = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, diag3, <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span> });</span>
<span class="line" id="L78">            <span class="tok-kw">var</span> diag2_shift = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, diag2, <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span> });</span>
<span class="line" id="L79">            <span class="tok-kw">var</span> diag1_shift = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, diag1, <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span> });</span>
<span class="line" id="L80">            diag3 = diag3_shift;</span>
<span class="line" id="L81">            diag2 = diag2_shift;</span>
<span class="line" id="L82">            diag1 = diag1_shift;</span>
<span class="line" id="L83"></span>
<span class="line" id="L84">            a0 = diag3 +% diag0;</span>
<span class="line" id="L85">            diag1 ^= math.rotl(Lane, a0, <span class="tok-number">7</span>);</span>
<span class="line" id="L86">            a1 = diag0 +% diag1;</span>
<span class="line" id="L87">            diag2 ^= math.rotl(Lane, a1, <span class="tok-number">9</span>);</span>
<span class="line" id="L88">            a2 = diag1 +% diag2;</span>
<span class="line" id="L89">            diag3 ^= math.rotl(Lane, a2, <span class="tok-number">13</span>);</span>
<span class="line" id="L90">            a3 = diag2 +% diag3;</span>
<span class="line" id="L91">            diag0 ^= math.rotl(Lane, a3, <span class="tok-number">18</span>);</span>
<span class="line" id="L92"></span>
<span class="line" id="L93">            diag1_shift = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, diag1, <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span>, <span class="tok-number">2</span> });</span>
<span class="line" id="L94">            diag2_shift = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, diag2, <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span>, <span class="tok-number">1</span> });</span>
<span class="line" id="L95">            diag3_shift = <span class="tok-builtin">@shuffle</span>(<span class="tok-type">u32</span>, diag3, <span class="tok-null">undefined</span>, [_]<span class="tok-type">i32</span>{ <span class="tok-number">1</span>, <span class="tok-number">2</span>, <span class="tok-number">3</span>, <span class="tok-number">0</span> });</span>
<span class="line" id="L96">            diag1 = diag1_shift;</span>
<span class="line" id="L97">            diag2 = diag2_shift;</span>
<span class="line" id="L98">            diag3 = diag3_shift;</span>
<span class="line" id="L99">        }</span>
<span class="line" id="L100"></span>
<span class="line" id="L101">        <span class="tok-kw">if</span> (feedback) {</span>
<span class="line" id="L102">            diag0 +%= start0;</span>
<span class="line" id="L103">            diag1 +%= start1;</span>
<span class="line" id="L104">            diag2 +%= start2;</span>
<span class="line" id="L105">            diag3 +%= start3;</span>
<span class="line" id="L106">        }</span>
<span class="line" id="L107"></span>
<span class="line" id="L108">        <span class="tok-kw">const</span> x0x1x10x11 = Lane{ diag0[<span class="tok-number">0</span>], diag1[<span class="tok-number">1</span>], diag0[<span class="tok-number">2</span>], diag1[<span class="tok-number">3</span>] };</span>
<span class="line" id="L109">        <span class="tok-kw">const</span> x12x13x6x7 = Lane{ diag1[<span class="tok-number">0</span>], diag2[<span class="tok-number">1</span>], diag1[<span class="tok-number">2</span>], diag2[<span class="tok-number">3</span>] };</span>
<span class="line" id="L110">        <span class="tok-kw">const</span> x8x9x2x3 = Lane{ diag2[<span class="tok-number">0</span>], diag3[<span class="tok-number">1</span>], diag2[<span class="tok-number">2</span>], diag3[<span class="tok-number">3</span>] };</span>
<span class="line" id="L111">        <span class="tok-kw">const</span> x4x5x14x15 = Lane{ diag3[<span class="tok-number">0</span>], diag0[<span class="tok-number">1</span>], diag3[<span class="tok-number">2</span>], diag0[<span class="tok-number">3</span>] };</span>
<span class="line" id="L112"></span>
<span class="line" id="L113">        x[<span class="tok-number">0</span>] = Lane{ x0x1x10x11[<span class="tok-number">0</span>], x0x1x10x11[<span class="tok-number">1</span>], x8x9x2x3[<span class="tok-number">2</span>], x8x9x2x3[<span class="tok-number">3</span>] };</span>
<span class="line" id="L114">        x[<span class="tok-number">1</span>] = Lane{ x4x5x14x15[<span class="tok-number">0</span>], x4x5x14x15[<span class="tok-number">1</span>], x12x13x6x7[<span class="tok-number">2</span>], x12x13x6x7[<span class="tok-number">3</span>] };</span>
<span class="line" id="L115">        x[<span class="tok-number">2</span>] = Lane{ x8x9x2x3[<span class="tok-number">0</span>], x8x9x2x3[<span class="tok-number">1</span>], x0x1x10x11[<span class="tok-number">2</span>], x0x1x10x11[<span class="tok-number">3</span>] };</span>
<span class="line" id="L116">        x[<span class="tok-number">3</span>] = Lane{ x12x13x6x7[<span class="tok-number">0</span>], x12x13x6x7[<span class="tok-number">1</span>], x4x5x14x15[<span class="tok-number">2</span>], x4x5x14x15[<span class="tok-number">3</span>] };</span>
<span class="line" id="L117">    }</span>
<span class="line" id="L118"></span>
<span class="line" id="L119">    <span class="tok-kw">fn</span> <span class="tok-fn">hashToBytes</span>(out: *[<span class="tok-number">64</span>]<span class="tok-type">u8</span>, x: BlockVec) <span class="tok-type">void</span> {</span>
<span class="line" id="L120">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L121">        <span class="tok-kw">while</span> (i &lt; <span class="tok-number">4</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L122">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">16</span> * i + <span class="tok-number">0</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], x[i][<span class="tok-number">0</span>]);</span>
<span class="line" id="L123">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">16</span> * i + <span class="tok-number">4</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], x[i][<span class="tok-number">1</span>]);</span>
<span class="line" id="L124">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">16</span> * i + <span class="tok-number">8</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], x[i][<span class="tok-number">2</span>]);</span>
<span class="line" id="L125">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">16</span> * i + <span class="tok-number">12</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], x[i][<span class="tok-number">3</span>]);</span>
<span class="line" id="L126">        }</span>
<span class="line" id="L127">    }</span>
<span class="line" id="L128"></span>
<span class="line" id="L129">    <span class="tok-kw">fn</span> <span class="tok-fn">salsa20Xor</span>(out: []<span class="tok-type">u8</span>, in: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, key: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>, d: [<span class="tok-number">4</span>]<span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L130">        <span class="tok-kw">var</span> ctx = initContext(key, d);</span>
<span class="line" id="L131">        <span class="tok-kw">var</span> x: BlockVec = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L132">        <span class="tok-kw">var</span> buf: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L133">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L134">        <span class="tok-kw">while</span> (i + <span class="tok-number">64</span> &lt;= in.len) : (i += <span class="tok-number">64</span>) {</span>
<span class="line" id="L135">            salsa20Core(x[<span class="tok-number">0</span>..], ctx, <span class="tok-null">true</span>);</span>
<span class="line" id="L136">            hashToBytes(buf[<span class="tok-number">0</span>..], x);</span>
<span class="line" id="L137">            <span class="tok-kw">var</span> xout = out[i..];</span>
<span class="line" id="L138">            <span class="tok-kw">const</span> xin = in[i..];</span>
<span class="line" id="L139">            <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L140">            <span class="tok-kw">while</span> (j &lt; <span class="tok-number">64</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L141">                xout[j] = xin[j];</span>
<span class="line" id="L142">            }</span>
<span class="line" id="L143">            j = <span class="tok-number">0</span>;</span>
<span class="line" id="L144">            <span class="tok-kw">while</span> (j &lt; <span class="tok-number">64</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L145">                xout[j] ^= buf[j];</span>
<span class="line" id="L146">            }</span>
<span class="line" id="L147">            ctx[<span class="tok-number">3</span>][<span class="tok-number">2</span>] +%= <span class="tok-number">1</span>;</span>
<span class="line" id="L148">            <span class="tok-kw">if</span> (ctx[<span class="tok-number">3</span>][<span class="tok-number">2</span>] == <span class="tok-number">0</span>) {</span>
<span class="line" id="L149">                ctx[<span class="tok-number">3</span>][<span class="tok-number">3</span>] += <span class="tok-number">1</span>;</span>
<span class="line" id="L150">            }</span>
<span class="line" id="L151">        }</span>
<span class="line" id="L152">        <span class="tok-kw">if</span> (i &lt; in.len) {</span>
<span class="line" id="L153">            salsa20Core(x[<span class="tok-number">0</span>..], ctx, <span class="tok-null">true</span>);</span>
<span class="line" id="L154">            hashToBytes(buf[<span class="tok-number">0</span>..], x);</span>
<span class="line" id="L155"></span>
<span class="line" id="L156">            <span class="tok-kw">var</span> xout = out[i..];</span>
<span class="line" id="L157">            <span class="tok-kw">const</span> xin = in[i..];</span>
<span class="line" id="L158">            <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L159">            <span class="tok-kw">while</span> (j &lt; in.len % <span class="tok-number">64</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L160">                xout[j] = xin[j] ^ buf[j];</span>
<span class="line" id="L161">            }</span>
<span class="line" id="L162">        }</span>
<span class="line" id="L163">    }</span>
<span class="line" id="L164"></span>
<span class="line" id="L165">    <span class="tok-kw">fn</span> <span class="tok-fn">hsalsa20</span>(input: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>, key: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>) [<span class="tok-number">32</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L166">        <span class="tok-kw">var</span> c: [<span class="tok-number">4</span>]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L167">        <span class="tok-kw">for</span> (c) |_, i| {</span>
<span class="line" id="L168">            c[i] = mem.readIntLittle(<span class="tok-type">u32</span>, input[<span class="tok-number">4</span> * i ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>]);</span>
<span class="line" id="L169">        }</span>
<span class="line" id="L170">        <span class="tok-kw">const</span> ctx = initContext(keyToWords(key), c);</span>
<span class="line" id="L171">        <span class="tok-kw">var</span> x: BlockVec = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L172">        salsa20Core(x[<span class="tok-number">0</span>..], ctx, <span class="tok-null">false</span>);</span>
<span class="line" id="L173">        <span class="tok-kw">var</span> out: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L174">        mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">0</span>..<span class="tok-number">4</span>], x[<span class="tok-number">0</span>][<span class="tok-number">0</span>]);</span>
<span class="line" id="L175">        mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">4</span>..<span class="tok-number">8</span>], x[<span class="tok-number">1</span>][<span class="tok-number">1</span>]);</span>
<span class="line" id="L176">        mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">8</span>..<span class="tok-number">12</span>], x[<span class="tok-number">2</span>][<span class="tok-number">2</span>]);</span>
<span class="line" id="L177">        mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">12</span>..<span class="tok-number">16</span>], x[<span class="tok-number">3</span>][<span class="tok-number">3</span>]);</span>
<span class="line" id="L178">        mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">16</span>..<span class="tok-number">20</span>], x[<span class="tok-number">1</span>][<span class="tok-number">2</span>]);</span>
<span class="line" id="L179">        mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">20</span>..<span class="tok-number">24</span>], x[<span class="tok-number">1</span>][<span class="tok-number">3</span>]);</span>
<span class="line" id="L180">        mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">24</span>..<span class="tok-number">28</span>], x[<span class="tok-number">2</span>][<span class="tok-number">0</span>]);</span>
<span class="line" id="L181">        mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">28</span>..<span class="tok-number">32</span>], x[<span class="tok-number">2</span>][<span class="tok-number">1</span>]);</span>
<span class="line" id="L182">        <span class="tok-kw">return</span> out;</span>
<span class="line" id="L183">    }</span>
<span class="line" id="L184">};</span>
<span class="line" id="L185"></span>
<span class="line" id="L186"><span class="tok-kw">const</span> Salsa20NonVecImpl = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L187">    <span class="tok-kw">const</span> BlockVec = [<span class="tok-number">16</span>]<span class="tok-type">u32</span>;</span>
<span class="line" id="L188"></span>
<span class="line" id="L189">    <span class="tok-kw">fn</span> <span class="tok-fn">initContext</span>(key: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>, d: [<span class="tok-number">4</span>]<span class="tok-type">u32</span>) BlockVec {</span>
<span class="line" id="L190">        <span class="tok-kw">const</span> c = <span class="tok-str">&quot;expand 32-byte k&quot;</span>;</span>
<span class="line" id="L191">        <span class="tok-kw">const</span> constant_le = <span class="tok-kw">comptime</span> [<span class="tok-number">4</span>]<span class="tok-type">u32</span>{</span>
<span class="line" id="L192">            mem.readIntLittle(<span class="tok-type">u32</span>, c[<span class="tok-number">0</span>..<span class="tok-number">4</span>]),</span>
<span class="line" id="L193">            mem.readIntLittle(<span class="tok-type">u32</span>, c[<span class="tok-number">4</span>..<span class="tok-number">8</span>]),</span>
<span class="line" id="L194">            mem.readIntLittle(<span class="tok-type">u32</span>, c[<span class="tok-number">8</span>..<span class="tok-number">12</span>]),</span>
<span class="line" id="L195">            mem.readIntLittle(<span class="tok-type">u32</span>, c[<span class="tok-number">12</span>..<span class="tok-number">16</span>]),</span>
<span class="line" id="L196">        };</span>
<span class="line" id="L197">        <span class="tok-kw">return</span> BlockVec{</span>
<span class="line" id="L198">            constant_le[<span class="tok-number">0</span>], key[<span class="tok-number">0</span>],         key[<span class="tok-number">1</span>],         key[<span class="tok-number">2</span>],</span>
<span class="line" id="L199">            key[<span class="tok-number">3</span>],         constant_le[<span class="tok-number">1</span>], d[<span class="tok-number">0</span>],           d[<span class="tok-number">1</span>],</span>
<span class="line" id="L200">            d[<span class="tok-number">2</span>],           d[<span class="tok-number">3</span>],           constant_le[<span class="tok-number">2</span>], key[<span class="tok-number">4</span>],</span>
<span class="line" id="L201">            key[<span class="tok-number">5</span>],         key[<span class="tok-number">6</span>],         key[<span class="tok-number">7</span>],         constant_le[<span class="tok-number">3</span>],</span>
<span class="line" id="L202">        };</span>
<span class="line" id="L203">    }</span>
<span class="line" id="L204"></span>
<span class="line" id="L205">    <span class="tok-kw">const</span> QuarterRound = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L206">        a: <span class="tok-type">usize</span>,</span>
<span class="line" id="L207">        b: <span class="tok-type">usize</span>,</span>
<span class="line" id="L208">        c: <span class="tok-type">usize</span>,</span>
<span class="line" id="L209">        d: <span class="tok-type">u6</span>,</span>
<span class="line" id="L210">    };</span>
<span class="line" id="L211"></span>
<span class="line" id="L212">    <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">Rp</span>(a: <span class="tok-type">usize</span>, b: <span class="tok-type">usize</span>, c: <span class="tok-type">usize</span>, d: <span class="tok-type">u6</span>) QuarterRound {</span>
<span class="line" id="L213">        <span class="tok-kw">return</span> QuarterRound{</span>
<span class="line" id="L214">            .a = a,</span>
<span class="line" id="L215">            .b = b,</span>
<span class="line" id="L216">            .c = c,</span>
<span class="line" id="L217">            .d = d,</span>
<span class="line" id="L218">        };</span>
<span class="line" id="L219">    }</span>
<span class="line" id="L220"></span>
<span class="line" id="L221">    <span class="tok-kw">inline</span> <span class="tok-kw">fn</span> <span class="tok-fn">salsa20Core</span>(x: *BlockVec, input: BlockVec, <span class="tok-kw">comptime</span> feedback: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L222">        <span class="tok-kw">const</span> arx_steps = <span class="tok-kw">comptime</span> [_]QuarterRound{</span>
<span class="line" id="L223">            Rp(<span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">12</span>, <span class="tok-number">7</span>),   Rp(<span class="tok-number">8</span>, <span class="tok-number">4</span>, <span class="tok-number">0</span>, <span class="tok-number">9</span>),    Rp(<span class="tok-number">12</span>, <span class="tok-number">8</span>, <span class="tok-number">4</span>, <span class="tok-number">13</span>),   Rp(<span class="tok-number">0</span>, <span class="tok-number">12</span>, <span class="tok-number">8</span>, <span class="tok-number">18</span>),</span>
<span class="line" id="L224">            Rp(<span class="tok-number">9</span>, <span class="tok-number">5</span>, <span class="tok-number">1</span>, <span class="tok-number">7</span>),    Rp(<span class="tok-number">13</span>, <span class="tok-number">9</span>, <span class="tok-number">5</span>, <span class="tok-number">9</span>),   Rp(<span class="tok-number">1</span>, <span class="tok-number">13</span>, <span class="tok-number">9</span>, <span class="tok-number">13</span>),   Rp(<span class="tok-number">5</span>, <span class="tok-number">1</span>, <span class="tok-number">13</span>, <span class="tok-number">18</span>),</span>
<span class="line" id="L225">            Rp(<span class="tok-number">14</span>, <span class="tok-number">10</span>, <span class="tok-number">6</span>, <span class="tok-number">7</span>),  Rp(<span class="tok-number">2</span>, <span class="tok-number">14</span>, <span class="tok-number">10</span>, <span class="tok-number">9</span>),  Rp(<span class="tok-number">6</span>, <span class="tok-number">2</span>, <span class="tok-number">14</span>, <span class="tok-number">13</span>),   Rp(<span class="tok-number">10</span>, <span class="tok-number">6</span>, <span class="tok-number">2</span>, <span class="tok-number">18</span>),</span>
<span class="line" id="L226">            Rp(<span class="tok-number">3</span>, <span class="tok-number">15</span>, <span class="tok-number">11</span>, <span class="tok-number">7</span>),  Rp(<span class="tok-number">7</span>, <span class="tok-number">3</span>, <span class="tok-number">15</span>, <span class="tok-number">9</span>),   Rp(<span class="tok-number">11</span>, <span class="tok-number">7</span>, <span class="tok-number">3</span>, <span class="tok-number">13</span>),   Rp(<span class="tok-number">15</span>, <span class="tok-number">11</span>, <span class="tok-number">7</span>, <span class="tok-number">18</span>),</span>
<span class="line" id="L227">            Rp(<span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">3</span>, <span class="tok-number">7</span>),    Rp(<span class="tok-number">2</span>, <span class="tok-number">1</span>, <span class="tok-number">0</span>, <span class="tok-number">9</span>),    Rp(<span class="tok-number">3</span>, <span class="tok-number">2</span>, <span class="tok-number">1</span>, <span class="tok-number">13</span>),    Rp(<span class="tok-number">0</span>, <span class="tok-number">3</span>, <span class="tok-number">2</span>, <span class="tok-number">18</span>),</span>
<span class="line" id="L228">            Rp(<span class="tok-number">6</span>, <span class="tok-number">5</span>, <span class="tok-number">4</span>, <span class="tok-number">7</span>),    Rp(<span class="tok-number">7</span>, <span class="tok-number">6</span>, <span class="tok-number">5</span>, <span class="tok-number">9</span>),    Rp(<span class="tok-number">4</span>, <span class="tok-number">7</span>, <span class="tok-number">6</span>, <span class="tok-number">13</span>),    Rp(<span class="tok-number">5</span>, <span class="tok-number">4</span>, <span class="tok-number">7</span>, <span class="tok-number">18</span>),</span>
<span class="line" id="L229">            Rp(<span class="tok-number">11</span>, <span class="tok-number">10</span>, <span class="tok-number">9</span>, <span class="tok-number">7</span>),  Rp(<span class="tok-number">8</span>, <span class="tok-number">11</span>, <span class="tok-number">10</span>, <span class="tok-number">9</span>),  Rp(<span class="tok-number">9</span>, <span class="tok-number">8</span>, <span class="tok-number">11</span>, <span class="tok-number">13</span>),   Rp(<span class="tok-number">10</span>, <span class="tok-number">9</span>, <span class="tok-number">8</span>, <span class="tok-number">18</span>),</span>
<span class="line" id="L230">            Rp(<span class="tok-number">12</span>, <span class="tok-number">15</span>, <span class="tok-number">14</span>, <span class="tok-number">7</span>), Rp(<span class="tok-number">13</span>, <span class="tok-number">12</span>, <span class="tok-number">15</span>, <span class="tok-number">9</span>), Rp(<span class="tok-number">14</span>, <span class="tok-number">13</span>, <span class="tok-number">12</span>, <span class="tok-number">13</span>), Rp(<span class="tok-number">15</span>, <span class="tok-number">14</span>, <span class="tok-number">13</span>, <span class="tok-number">18</span>),</span>
<span class="line" id="L231">        };</span>
<span class="line" id="L232">        x.* = input;</span>
<span class="line" id="L233">        <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L234">        <span class="tok-kw">while</span> (j &lt; <span class="tok-number">20</span>) : (j += <span class="tok-number">2</span>) {</span>
<span class="line" id="L235">            <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (arx_steps) |r| {</span>
<span class="line" id="L236">                x[r.a] ^= math.rotl(<span class="tok-type">u32</span>, x[r.b] +% x[r.c], r.d);</span>
<span class="line" id="L237">            }</span>
<span class="line" id="L238">        }</span>
<span class="line" id="L239">        <span class="tok-kw">if</span> (feedback) {</span>
<span class="line" id="L240">            j = <span class="tok-number">0</span>;</span>
<span class="line" id="L241">            <span class="tok-kw">while</span> (j &lt; <span class="tok-number">16</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L242">                x[j] +%= input[j];</span>
<span class="line" id="L243">            }</span>
<span class="line" id="L244">        }</span>
<span class="line" id="L245">    }</span>
<span class="line" id="L246"></span>
<span class="line" id="L247">    <span class="tok-kw">fn</span> <span class="tok-fn">hashToBytes</span>(out: *[<span class="tok-number">64</span>]<span class="tok-type">u8</span>, x: BlockVec) <span class="tok-type">void</span> {</span>
<span class="line" id="L248">        <span class="tok-kw">for</span> (x) |w, i| {</span>
<span class="line" id="L249">            mem.writeIntLittle(<span class="tok-type">u32</span>, out[i * <span class="tok-number">4</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], w);</span>
<span class="line" id="L250">        }</span>
<span class="line" id="L251">    }</span>
<span class="line" id="L252"></span>
<span class="line" id="L253">    <span class="tok-kw">fn</span> <span class="tok-fn">salsa20Xor</span>(out: []<span class="tok-type">u8</span>, in: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, key: [<span class="tok-number">8</span>]<span class="tok-type">u32</span>, d: [<span class="tok-number">4</span>]<span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L254">        <span class="tok-kw">var</span> ctx = initContext(key, d);</span>
<span class="line" id="L255">        <span class="tok-kw">var</span> x: BlockVec = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L256">        <span class="tok-kw">var</span> buf: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L257">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L258">        <span class="tok-kw">while</span> (i + <span class="tok-number">64</span> &lt;= in.len) : (i += <span class="tok-number">64</span>) {</span>
<span class="line" id="L259">            salsa20Core(x[<span class="tok-number">0</span>..], ctx, <span class="tok-null">true</span>);</span>
<span class="line" id="L260">            hashToBytes(buf[<span class="tok-number">0</span>..], x);</span>
<span class="line" id="L261">            <span class="tok-kw">var</span> xout = out[i..];</span>
<span class="line" id="L262">            <span class="tok-kw">const</span> xin = in[i..];</span>
<span class="line" id="L263">            <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L264">            <span class="tok-kw">while</span> (j &lt; <span class="tok-number">64</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L265">                xout[j] = xin[j];</span>
<span class="line" id="L266">            }</span>
<span class="line" id="L267">            j = <span class="tok-number">0</span>;</span>
<span class="line" id="L268">            <span class="tok-kw">while</span> (j &lt; <span class="tok-number">64</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L269">                xout[j] ^= buf[j];</span>
<span class="line" id="L270">            }</span>
<span class="line" id="L271">            ctx[<span class="tok-number">9</span>] += <span class="tok-builtin">@boolToInt</span>(<span class="tok-builtin">@addWithOverflow</span>(<span class="tok-type">u32</span>, ctx[<span class="tok-number">8</span>], <span class="tok-number">1</span>, &amp;ctx[<span class="tok-number">8</span>]));</span>
<span class="line" id="L272">        }</span>
<span class="line" id="L273">        <span class="tok-kw">if</span> (i &lt; in.len) {</span>
<span class="line" id="L274">            salsa20Core(x[<span class="tok-number">0</span>..], ctx, <span class="tok-null">true</span>);</span>
<span class="line" id="L275">            hashToBytes(buf[<span class="tok-number">0</span>..], x);</span>
<span class="line" id="L276"></span>
<span class="line" id="L277">            <span class="tok-kw">var</span> xout = out[i..];</span>
<span class="line" id="L278">            <span class="tok-kw">const</span> xin = in[i..];</span>
<span class="line" id="L279">            <span class="tok-kw">var</span> j: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L280">            <span class="tok-kw">while</span> (j &lt; in.len % <span class="tok-number">64</span>) : (j += <span class="tok-number">1</span>) {</span>
<span class="line" id="L281">                xout[j] = xin[j] ^ buf[j];</span>
<span class="line" id="L282">            }</span>
<span class="line" id="L283">        }</span>
<span class="line" id="L284">    }</span>
<span class="line" id="L285"></span>
<span class="line" id="L286">    <span class="tok-kw">fn</span> <span class="tok-fn">hsalsa20</span>(input: [<span class="tok-number">16</span>]<span class="tok-type">u8</span>, key: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>) [<span class="tok-number">32</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L287">        <span class="tok-kw">var</span> c: [<span class="tok-number">4</span>]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L288">        <span class="tok-kw">for</span> (c) |_, i| {</span>
<span class="line" id="L289">            c[i] = mem.readIntLittle(<span class="tok-type">u32</span>, input[<span class="tok-number">4</span> * i ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>]);</span>
<span class="line" id="L290">        }</span>
<span class="line" id="L291">        <span class="tok-kw">const</span> ctx = initContext(keyToWords(key), c);</span>
<span class="line" id="L292">        <span class="tok-kw">var</span> x: BlockVec = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L293">        salsa20Core(x[<span class="tok-number">0</span>..], ctx, <span class="tok-null">false</span>);</span>
<span class="line" id="L294">        <span class="tok-kw">var</span> out: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L295">        mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">0</span>..<span class="tok-number">4</span>], x[<span class="tok-number">0</span>]);</span>
<span class="line" id="L296">        mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">4</span>..<span class="tok-number">8</span>], x[<span class="tok-number">5</span>]);</span>
<span class="line" id="L297">        mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">8</span>..<span class="tok-number">12</span>], x[<span class="tok-number">10</span>]);</span>
<span class="line" id="L298">        mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">12</span>..<span class="tok-number">16</span>], x[<span class="tok-number">15</span>]);</span>
<span class="line" id="L299">        mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">16</span>..<span class="tok-number">20</span>], x[<span class="tok-number">6</span>]);</span>
<span class="line" id="L300">        mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">20</span>..<span class="tok-number">24</span>], x[<span class="tok-number">7</span>]);</span>
<span class="line" id="L301">        mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">24</span>..<span class="tok-number">28</span>], x[<span class="tok-number">8</span>]);</span>
<span class="line" id="L302">        mem.writeIntLittle(<span class="tok-type">u32</span>, out[<span class="tok-number">28</span>..<span class="tok-number">32</span>], x[<span class="tok-number">9</span>]);</span>
<span class="line" id="L303">        <span class="tok-kw">return</span> out;</span>
<span class="line" id="L304">    }</span>
<span class="line" id="L305">};</span>
<span class="line" id="L306"></span>
<span class="line" id="L307"><span class="tok-kw">const</span> Salsa20Impl = <span class="tok-kw">if</span> (builtin.cpu.arch == .x86_64) Salsa20VecImpl <span class="tok-kw">else</span> Salsa20NonVecImpl;</span>
<span class="line" id="L308"></span>
<span class="line" id="L309"><span class="tok-kw">fn</span> <span class="tok-fn">keyToWords</span>(key: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>) [<span class="tok-number">8</span>]<span class="tok-type">u32</span> {</span>
<span class="line" id="L310">    <span class="tok-kw">var</span> k: [<span class="tok-number">8</span>]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L311">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L312">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">8</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L313">        k[i] = mem.readIntLittle(<span class="tok-type">u32</span>, key[i * <span class="tok-number">4</span> ..][<span class="tok-number">0</span>..<span class="tok-number">4</span>]);</span>
<span class="line" id="L314">    }</span>
<span class="line" id="L315">    <span class="tok-kw">return</span> k;</span>
<span class="line" id="L316">}</span>
<span class="line" id="L317"></span>
<span class="line" id="L318"><span class="tok-kw">fn</span> <span class="tok-fn">extend</span>(key: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>, nonce: [<span class="tok-number">24</span>]<span class="tok-type">u8</span>) <span class="tok-kw">struct</span> { key: [<span class="tok-number">32</span>]<span class="tok-type">u8</span>, nonce: [<span class="tok-number">8</span>]<span class="tok-type">u8</span> } {</span>
<span class="line" id="L319">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L320">        .key = Salsa20Impl.hsalsa20(nonce[<span class="tok-number">0</span>..<span class="tok-number">16</span>].*, key),</span>
<span class="line" id="L321">        .nonce = nonce[<span class="tok-number">16</span>..<span class="tok-number">24</span>].*,</span>
<span class="line" id="L322">    };</span>
<span class="line" id="L323">}</span>
<span class="line" id="L324"></span>
<span class="line" id="L325"><span class="tok-comment">/// The Salsa20 stream cipher.</span></span>
<span class="line" id="L326"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Salsa20 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L327">    <span class="tok-comment">/// Nonce length in bytes.</span></span>
<span class="line" id="L328">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> nonce_length = <span class="tok-number">8</span>;</span>
<span class="line" id="L329">    <span class="tok-comment">/// Key length in bytes.</span></span>
<span class="line" id="L330">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length = <span class="tok-number">32</span>;</span>
<span class="line" id="L331"></span>
<span class="line" id="L332">    <span class="tok-comment">/// Add the output of the Salsa20 stream cipher to `in` and stores the result into `out`.</span></span>
<span class="line" id="L333">    <span class="tok-comment">/// WARNING: This function doesn't provide authenticated encryption.</span></span>
<span class="line" id="L334">    <span class="tok-comment">/// Using the AEAD or one of the `box` versions is usually preferred.</span></span>
<span class="line" id="L335">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">xor</span>(out: []<span class="tok-type">u8</span>, in: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, counter: <span class="tok-type">u64</span>, key: [key_length]<span class="tok-type">u8</span>, nonce: [nonce_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L336">        debug.assert(in.len == out.len);</span>
<span class="line" id="L337"></span>
<span class="line" id="L338">        <span class="tok-kw">var</span> d: [<span class="tok-number">4</span>]<span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L339">        d[<span class="tok-number">0</span>] = mem.readIntLittle(<span class="tok-type">u32</span>, nonce[<span class="tok-number">0</span>..<span class="tok-number">4</span>]);</span>
<span class="line" id="L340">        d[<span class="tok-number">1</span>] = mem.readIntLittle(<span class="tok-type">u32</span>, nonce[<span class="tok-number">4</span>..<span class="tok-number">8</span>]);</span>
<span class="line" id="L341">        d[<span class="tok-number">2</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, counter);</span>
<span class="line" id="L342">        d[<span class="tok-number">3</span>] = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u32</span>, counter &gt;&gt; <span class="tok-number">32</span>);</span>
<span class="line" id="L343">        Salsa20Impl.salsa20Xor(out, in, keyToWords(key), d);</span>
<span class="line" id="L344">    }</span>
<span class="line" id="L345">};</span>
<span class="line" id="L346"></span>
<span class="line" id="L347"><span class="tok-comment">/// The XSalsa20 stream cipher.</span></span>
<span class="line" id="L348"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XSalsa20 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L349">    <span class="tok-comment">/// Nonce length in bytes.</span></span>
<span class="line" id="L350">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> nonce_length = <span class="tok-number">24</span>;</span>
<span class="line" id="L351">    <span class="tok-comment">/// Key length in bytes.</span></span>
<span class="line" id="L352">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length = <span class="tok-number">32</span>;</span>
<span class="line" id="L353"></span>
<span class="line" id="L354">    <span class="tok-comment">/// Add the output of the XSalsa20 stream cipher to `in` and stores the result into `out`.</span></span>
<span class="line" id="L355">    <span class="tok-comment">/// WARNING: This function doesn't provide authenticated encryption.</span></span>
<span class="line" id="L356">    <span class="tok-comment">/// Using the AEAD or one of the `box` versions is usually preferred.</span></span>
<span class="line" id="L357">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">xor</span>(out: []<span class="tok-type">u8</span>, in: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, counter: <span class="tok-type">u64</span>, key: [key_length]<span class="tok-type">u8</span>, nonce: [nonce_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L358">        <span class="tok-kw">const</span> extended = extend(key, nonce);</span>
<span class="line" id="L359">        Salsa20.xor(out, in, counter, extended.key, extended.nonce);</span>
<span class="line" id="L360">    }</span>
<span class="line" id="L361">};</span>
<span class="line" id="L362"></span>
<span class="line" id="L363"><span class="tok-comment">/// The XSalsa20 stream cipher, combined with the Poly1305 MAC</span></span>
<span class="line" id="L364"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> XSalsa20Poly1305 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L365">    <span class="tok-comment">/// Authentication tag length in bytes.</span></span>
<span class="line" id="L366">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> tag_length = Poly1305.mac_length;</span>
<span class="line" id="L367">    <span class="tok-comment">/// Nonce length in bytes.</span></span>
<span class="line" id="L368">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> nonce_length = XSalsa20.nonce_length;</span>
<span class="line" id="L369">    <span class="tok-comment">/// Key length in bytes.</span></span>
<span class="line" id="L370">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length = XSalsa20.key_length;</span>
<span class="line" id="L371"></span>
<span class="line" id="L372">    <span class="tok-comment">/// c: ciphertext: output buffer should be of size m.len</span></span>
<span class="line" id="L373">    <span class="tok-comment">/// tag: authentication tag: output MAC</span></span>
<span class="line" id="L374">    <span class="tok-comment">/// m: message</span></span>
<span class="line" id="L375">    <span class="tok-comment">/// ad: Associated Data</span></span>
<span class="line" id="L376">    <span class="tok-comment">/// npub: public nonce</span></span>
<span class="line" id="L377">    <span class="tok-comment">/// k: private key</span></span>
<span class="line" id="L378">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">encrypt</span>(c: []<span class="tok-type">u8</span>, tag: *[tag_length]<span class="tok-type">u8</span>, m: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, ad: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, k: [key_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L379">        debug.assert(c.len == m.len);</span>
<span class="line" id="L380">        <span class="tok-kw">const</span> extended = extend(k, npub);</span>
<span class="line" id="L381">        <span class="tok-kw">var</span> block0 = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">64</span>;</span>
<span class="line" id="L382">        <span class="tok-kw">const</span> mlen0 = math.min(<span class="tok-number">32</span>, m.len);</span>
<span class="line" id="L383">        mem.copy(<span class="tok-type">u8</span>, block0[<span class="tok-number">32</span>..][<span class="tok-number">0</span>..mlen0], m[<span class="tok-number">0</span>..mlen0]);</span>
<span class="line" id="L384">        Salsa20.xor(block0[<span class="tok-number">0</span>..], block0[<span class="tok-number">0</span>..], <span class="tok-number">0</span>, extended.key, extended.nonce);</span>
<span class="line" id="L385">        mem.copy(<span class="tok-type">u8</span>, c[<span class="tok-number">0</span>..mlen0], block0[<span class="tok-number">32</span>..][<span class="tok-number">0</span>..mlen0]);</span>
<span class="line" id="L386">        Salsa20.xor(c[mlen0..], m[mlen0..], <span class="tok-number">1</span>, extended.key, extended.nonce);</span>
<span class="line" id="L387">        <span class="tok-kw">var</span> mac = Poly1305.init(block0[<span class="tok-number">0</span>..<span class="tok-number">32</span>]);</span>
<span class="line" id="L388">        mac.update(ad);</span>
<span class="line" id="L389">        mac.update(c);</span>
<span class="line" id="L390">        mac.final(tag);</span>
<span class="line" id="L391">    }</span>
<span class="line" id="L392"></span>
<span class="line" id="L393">    <span class="tok-comment">/// m: message: output buffer should be of size c.len</span></span>
<span class="line" id="L394">    <span class="tok-comment">/// c: ciphertext</span></span>
<span class="line" id="L395">    <span class="tok-comment">/// tag: authentication tag</span></span>
<span class="line" id="L396">    <span class="tok-comment">/// ad: Associated Data</span></span>
<span class="line" id="L397">    <span class="tok-comment">/// npub: public nonce</span></span>
<span class="line" id="L398">    <span class="tok-comment">/// k: private key</span></span>
<span class="line" id="L399">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">decrypt</span>(m: []<span class="tok-type">u8</span>, c: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, tag: [tag_length]<span class="tok-type">u8</span>, ad: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, k: [key_length]<span class="tok-type">u8</span>) AuthenticationError!<span class="tok-type">void</span> {</span>
<span class="line" id="L400">        debug.assert(c.len == m.len);</span>
<span class="line" id="L401">        <span class="tok-kw">const</span> extended = extend(k, npub);</span>
<span class="line" id="L402">        <span class="tok-kw">var</span> block0 = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">64</span>;</span>
<span class="line" id="L403">        <span class="tok-kw">const</span> mlen0 = math.min(<span class="tok-number">32</span>, c.len);</span>
<span class="line" id="L404">        mem.copy(<span class="tok-type">u8</span>, block0[<span class="tok-number">32</span>..][<span class="tok-number">0</span>..mlen0], c[<span class="tok-number">0</span>..mlen0]);</span>
<span class="line" id="L405">        Salsa20.xor(block0[<span class="tok-number">0</span>..], block0[<span class="tok-number">0</span>..], <span class="tok-number">0</span>, extended.key, extended.nonce);</span>
<span class="line" id="L406">        <span class="tok-kw">var</span> mac = Poly1305.init(block0[<span class="tok-number">0</span>..<span class="tok-number">32</span>]);</span>
<span class="line" id="L407">        mac.update(ad);</span>
<span class="line" id="L408">        mac.update(c);</span>
<span class="line" id="L409">        <span class="tok-kw">var</span> computedTag: [tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L410">        mac.final(&amp;computedTag);</span>
<span class="line" id="L411">        <span class="tok-kw">var</span> acc: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L412">        <span class="tok-kw">for</span> (computedTag) |_, i| {</span>
<span class="line" id="L413">            acc |= computedTag[i] ^ tag[i];</span>
<span class="line" id="L414">        }</span>
<span class="line" id="L415">        <span class="tok-kw">if</span> (acc != <span class="tok-number">0</span>) {</span>
<span class="line" id="L416">            utils.secureZero(<span class="tok-type">u8</span>, &amp;computedTag);</span>
<span class="line" id="L417">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AuthenticationFailed;</span>
<span class="line" id="L418">        }</span>
<span class="line" id="L419">        mem.copy(<span class="tok-type">u8</span>, m[<span class="tok-number">0</span>..mlen0], block0[<span class="tok-number">32</span>..][<span class="tok-number">0</span>..mlen0]);</span>
<span class="line" id="L420">        Salsa20.xor(m[mlen0..], c[mlen0..], <span class="tok-number">1</span>, extended.key, extended.nonce);</span>
<span class="line" id="L421">    }</span>
<span class="line" id="L422">};</span>
<span class="line" id="L423"></span>
<span class="line" id="L424"><span class="tok-comment">/// NaCl-compatible secretbox API.</span></span>
<span class="line" id="L425"><span class="tok-comment">///</span></span>
<span class="line" id="L426"><span class="tok-comment">/// A secretbox contains both an encrypted message and an authentication tag to verify that it hasn't been tampered with.</span></span>
<span class="line" id="L427"><span class="tok-comment">/// A secret key shared by all the recipients must be already known in order to use this API.</span></span>
<span class="line" id="L428"><span class="tok-comment">///</span></span>
<span class="line" id="L429"><span class="tok-comment">/// Nonces are 192-bit large and can safely be chosen with a random number generator.</span></span>
<span class="line" id="L430"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SecretBox = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L431">    <span class="tok-comment">/// Key length in bytes.</span></span>
<span class="line" id="L432">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length = XSalsa20Poly1305.key_length;</span>
<span class="line" id="L433">    <span class="tok-comment">/// Nonce length in bytes.</span></span>
<span class="line" id="L434">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> nonce_length = XSalsa20Poly1305.nonce_length;</span>
<span class="line" id="L435">    <span class="tok-comment">/// Authentication tag length in bytes.</span></span>
<span class="line" id="L436">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> tag_length = XSalsa20Poly1305.tag_length;</span>
<span class="line" id="L437"></span>
<span class="line" id="L438">    <span class="tok-comment">/// Encrypt and authenticate `m` using a nonce `npub` and a key `k`.</span></span>
<span class="line" id="L439">    <span class="tok-comment">/// `c` must be exactly `tag_length` longer than `m`, as it will store both the ciphertext and the authentication tag.</span></span>
<span class="line" id="L440">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">seal</span>(c: []<span class="tok-type">u8</span>, m: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, k: [key_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L441">        debug.assert(c.len == tag_length + m.len);</span>
<span class="line" id="L442">        XSalsa20Poly1305.encrypt(c[tag_length..], c[<span class="tok-number">0</span>..tag_length], m, <span class="tok-str">&quot;&quot;</span>, npub, k);</span>
<span class="line" id="L443">    }</span>
<span class="line" id="L444"></span>
<span class="line" id="L445">    <span class="tok-comment">/// Verify and decrypt `c` using a nonce `npub` and a key `k`.</span></span>
<span class="line" id="L446">    <span class="tok-comment">/// `m` must be exactly `tag_length` smaller than `c`, as `c` includes an authentication tag in addition to the encrypted message.</span></span>
<span class="line" id="L447">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">open</span>(m: []<span class="tok-type">u8</span>, c: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, k: [key_length]<span class="tok-type">u8</span>) AuthenticationError!<span class="tok-type">void</span> {</span>
<span class="line" id="L448">        <span class="tok-kw">if</span> (c.len &lt; tag_length) {</span>
<span class="line" id="L449">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AuthenticationFailed;</span>
<span class="line" id="L450">        }</span>
<span class="line" id="L451">        debug.assert(m.len == c.len - tag_length);</span>
<span class="line" id="L452">        <span class="tok-kw">return</span> XSalsa20Poly1305.decrypt(m, c[tag_length..], c[<span class="tok-number">0</span>..tag_length].*, <span class="tok-str">&quot;&quot;</span>, npub, k);</span>
<span class="line" id="L453">    }</span>
<span class="line" id="L454">};</span>
<span class="line" id="L455"></span>
<span class="line" id="L456"><span class="tok-comment">/// NaCl-compatible box API.</span></span>
<span class="line" id="L457"><span class="tok-comment">///</span></span>
<span class="line" id="L458"><span class="tok-comment">/// A secretbox contains both an encrypted message and an authentication tag to verify that it hasn't been tampered with.</span></span>
<span class="line" id="L459"><span class="tok-comment">/// This construction uses public-key cryptography. A shared secret doesn't have to be known in advance by both parties.</span></span>
<span class="line" id="L460"><span class="tok-comment">/// Instead, a message is encrypted using a sender's secret key and a recipient's public key,</span></span>
<span class="line" id="L461"><span class="tok-comment">/// and is decrypted using the recipient's secret key and the sender's public key.</span></span>
<span class="line" id="L462"><span class="tok-comment">///</span></span>
<span class="line" id="L463"><span class="tok-comment">/// Nonces are 192-bit large and can safely be chosen with a random number generator.</span></span>
<span class="line" id="L464"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Box = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L465">    <span class="tok-comment">/// Public key length in bytes.</span></span>
<span class="line" id="L466">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> public_length = X25519.public_length;</span>
<span class="line" id="L467">    <span class="tok-comment">/// Secret key length in bytes.</span></span>
<span class="line" id="L468">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> secret_length = X25519.secret_length;</span>
<span class="line" id="L469">    <span class="tok-comment">/// Shared key length in bytes.</span></span>
<span class="line" id="L470">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> shared_length = XSalsa20Poly1305.key_length;</span>
<span class="line" id="L471">    <span class="tok-comment">/// Seed (for key pair creation) length in bytes.</span></span>
<span class="line" id="L472">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> seed_length = X25519.seed_length;</span>
<span class="line" id="L473">    <span class="tok-comment">/// Nonce length in bytes.</span></span>
<span class="line" id="L474">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> nonce_length = XSalsa20Poly1305.nonce_length;</span>
<span class="line" id="L475">    <span class="tok-comment">/// Authentication tag length in bytes.</span></span>
<span class="line" id="L476">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> tag_length = XSalsa20Poly1305.tag_length;</span>
<span class="line" id="L477"></span>
<span class="line" id="L478">    <span class="tok-comment">/// A key pair.</span></span>
<span class="line" id="L479">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KeyPair = X25519.KeyPair;</span>
<span class="line" id="L480"></span>
<span class="line" id="L481">    <span class="tok-comment">/// Compute a secret suitable for `secretbox` given a recipent's public key and a sender's secret key.</span></span>
<span class="line" id="L482">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createSharedSecret</span>(public_key: [public_length]<span class="tok-type">u8</span>, secret_key: [secret_length]<span class="tok-type">u8</span>) (IdentityElementError || WeakPublicKeyError)![shared_length]<span class="tok-type">u8</span> {</span>
<span class="line" id="L483">        <span class="tok-kw">const</span> p = <span class="tok-kw">try</span> X25519.scalarmult(secret_key, public_key);</span>
<span class="line" id="L484">        <span class="tok-kw">const</span> zero = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L485">        <span class="tok-kw">return</span> Salsa20Impl.hsalsa20(zero, p);</span>
<span class="line" id="L486">    }</span>
<span class="line" id="L487"></span>
<span class="line" id="L488">    <span class="tok-comment">/// Encrypt and authenticate a message using a recipient's public key `public_key` and a sender's `secret_key`.</span></span>
<span class="line" id="L489">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">seal</span>(c: []<span class="tok-type">u8</span>, m: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, public_key: [public_length]<span class="tok-type">u8</span>, secret_key: [secret_length]<span class="tok-type">u8</span>) (IdentityElementError || WeakPublicKeyError)!<span class="tok-type">void</span> {</span>
<span class="line" id="L490">        <span class="tok-kw">const</span> shared_key = <span class="tok-kw">try</span> createSharedSecret(public_key, secret_key);</span>
<span class="line" id="L491">        <span class="tok-kw">return</span> SecretBox.seal(c, m, npub, shared_key);</span>
<span class="line" id="L492">    }</span>
<span class="line" id="L493"></span>
<span class="line" id="L494">    <span class="tok-comment">/// Verify and decrypt a message using a recipient's secret key `public_key` and a sender's `public_key`.</span></span>
<span class="line" id="L495">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">open</span>(m: []<span class="tok-type">u8</span>, c: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, public_key: [public_length]<span class="tok-type">u8</span>, secret_key: [secret_length]<span class="tok-type">u8</span>) (IdentityElementError || WeakPublicKeyError || AuthenticationError)!<span class="tok-type">void</span> {</span>
<span class="line" id="L496">        <span class="tok-kw">const</span> shared_key = <span class="tok-kw">try</span> createSharedSecret(public_key, secret_key);</span>
<span class="line" id="L497">        <span class="tok-kw">return</span> SecretBox.open(m, c, npub, shared_key);</span>
<span class="line" id="L498">    }</span>
<span class="line" id="L499">};</span>
<span class="line" id="L500"></span>
<span class="line" id="L501"><span class="tok-comment">/// libsodium-compatible sealed boxes</span></span>
<span class="line" id="L502"><span class="tok-comment">///</span></span>
<span class="line" id="L503"><span class="tok-comment">/// Sealed boxes are designed to anonymously send messages to a recipient given their public key.</span></span>
<span class="line" id="L504"><span class="tok-comment">/// Only the recipient can decrypt these messages, using their private key.</span></span>
<span class="line" id="L505"><span class="tok-comment">/// While the recipient can verify the integrity of the message, it cannot verify the identity of the sender.</span></span>
<span class="line" id="L506"><span class="tok-comment">///</span></span>
<span class="line" id="L507"><span class="tok-comment">/// A message is encrypted using an ephemeral key pair, whose secret part is destroyed right after the encryption process.</span></span>
<span class="line" id="L508"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SealedBox = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L509">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> public_length = Box.public_length;</span>
<span class="line" id="L510">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> secret_length = Box.secret_length;</span>
<span class="line" id="L511">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> seed_length = Box.seed_length;</span>
<span class="line" id="L512">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> seal_length = Box.public_length + Box.tag_length;</span>
<span class="line" id="L513"></span>
<span class="line" id="L514">    <span class="tok-comment">/// A key pair.</span></span>
<span class="line" id="L515">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KeyPair = Box.KeyPair;</span>
<span class="line" id="L516"></span>
<span class="line" id="L517">    <span class="tok-kw">fn</span> <span class="tok-fn">createNonce</span>(pk1: [public_length]<span class="tok-type">u8</span>, pk2: [public_length]<span class="tok-type">u8</span>) [Box.nonce_length]<span class="tok-type">u8</span> {</span>
<span class="line" id="L518">        <span class="tok-kw">var</span> hasher = Blake2b(Box.nonce_length * <span class="tok-number">8</span>).init(.{});</span>
<span class="line" id="L519">        hasher.update(&amp;pk1);</span>
<span class="line" id="L520">        hasher.update(&amp;pk2);</span>
<span class="line" id="L521">        <span class="tok-kw">var</span> nonce: [Box.nonce_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L522">        hasher.final(&amp;nonce);</span>
<span class="line" id="L523">        <span class="tok-kw">return</span> nonce;</span>
<span class="line" id="L524">    }</span>
<span class="line" id="L525"></span>
<span class="line" id="L526">    <span class="tok-comment">/// Encrypt a message `m` for a recipient whose public key is `public_key`.</span></span>
<span class="line" id="L527">    <span class="tok-comment">/// `c` must be `seal_length` bytes larger than `m`, so that the required metadata can be added.</span></span>
<span class="line" id="L528">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">seal</span>(c: []<span class="tok-type">u8</span>, m: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, public_key: [public_length]<span class="tok-type">u8</span>) (WeakPublicKeyError || IdentityElementError)!<span class="tok-type">void</span> {</span>
<span class="line" id="L529">        debug.assert(c.len == m.len + seal_length);</span>
<span class="line" id="L530">        <span class="tok-kw">var</span> ekp = <span class="tok-kw">try</span> KeyPair.create(<span class="tok-null">null</span>);</span>
<span class="line" id="L531">        <span class="tok-kw">const</span> nonce = createNonce(ekp.public_key, public_key);</span>
<span class="line" id="L532">        mem.copy(<span class="tok-type">u8</span>, c[<span class="tok-number">0</span>..public_length], ekp.public_key[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L533">        <span class="tok-kw">try</span> Box.seal(c[Box.public_length..], m, nonce, public_key, ekp.secret_key);</span>
<span class="line" id="L534">        utils.secureZero(<span class="tok-type">u8</span>, ekp.secret_key[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L535">    }</span>
<span class="line" id="L536"></span>
<span class="line" id="L537">    <span class="tok-comment">/// Decrypt a message using a key pair.</span></span>
<span class="line" id="L538">    <span class="tok-comment">/// `m` must be exactly `seal_length` bytes smaller than `c`, as `c` also includes metadata.</span></span>
<span class="line" id="L539">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">open</span>(m: []<span class="tok-type">u8</span>, c: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, keypair: KeyPair) (IdentityElementError || WeakPublicKeyError || AuthenticationError)!<span class="tok-type">void</span> {</span>
<span class="line" id="L540">        <span class="tok-kw">if</span> (c.len &lt; seal_length) {</span>
<span class="line" id="L541">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AuthenticationFailed;</span>
<span class="line" id="L542">        }</span>
<span class="line" id="L543">        <span class="tok-kw">const</span> epk = c[<span class="tok-number">0</span>..public_length];</span>
<span class="line" id="L544">        <span class="tok-kw">const</span> nonce = createNonce(epk.*, keypair.public_key);</span>
<span class="line" id="L545">        <span class="tok-kw">return</span> Box.open(m, c[public_length..], nonce, epk.*, keypair.secret_key);</span>
<span class="line" id="L546">    }</span>
<span class="line" id="L547">};</span>
<span class="line" id="L548"></span>
<span class="line" id="L549"><span class="tok-kw">const</span> htest = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;test.zig&quot;</span>);</span>
<span class="line" id="L550"></span>
<span class="line" id="L551"><span class="tok-kw">test</span> <span class="tok-str">&quot;(x)salsa20&quot;</span> {</span>
<span class="line" id="L552">    <span class="tok-kw">const</span> key = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x69</span>} ** <span class="tok-number">32</span>;</span>
<span class="line" id="L553">    <span class="tok-kw">const</span> nonce = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x42</span>} ** <span class="tok-number">8</span>;</span>
<span class="line" id="L554">    <span class="tok-kw">const</span> msg = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">20</span>;</span>
<span class="line" id="L555">    <span class="tok-kw">var</span> c: [msg.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L556"></span>
<span class="line" id="L557">    Salsa20.xor(&amp;c, msg[<span class="tok-number">0</span>..], <span class="tok-number">0</span>, key, nonce);</span>
<span class="line" id="L558">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;30ff9933aa6534ff5207142593cd1fca4b23bdd8&quot;</span>, c[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L559"></span>
<span class="line" id="L560">    <span class="tok-kw">const</span> extended_nonce = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x42</span>} ** <span class="tok-number">24</span>;</span>
<span class="line" id="L561">    XSalsa20.xor(&amp;c, msg[<span class="tok-number">0</span>..], <span class="tok-number">0</span>, key, extended_nonce);</span>
<span class="line" id="L562">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;b4ab7d82e750ec07644fa3281bce6cd91d4243f9&quot;</span>, c[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L563">}</span>
<span class="line" id="L564"></span>
<span class="line" id="L565"><span class="tok-kw">test</span> <span class="tok-str">&quot;xsalsa20poly1305&quot;</span> {</span>
<span class="line" id="L566">    <span class="tok-kw">var</span> msg: [<span class="tok-number">100</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L567">    <span class="tok-kw">var</span> msg2: [msg.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L568">    <span class="tok-kw">var</span> c: [msg.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L569">    <span class="tok-kw">var</span> key: [XSalsa20Poly1305.key_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L570">    <span class="tok-kw">var</span> nonce: [XSalsa20Poly1305.nonce_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L571">    <span class="tok-kw">var</span> tag: [XSalsa20Poly1305.tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L572">    crypto.random.bytes(&amp;msg);</span>
<span class="line" id="L573">    crypto.random.bytes(&amp;key);</span>
<span class="line" id="L574">    crypto.random.bytes(&amp;nonce);</span>
<span class="line" id="L575"></span>
<span class="line" id="L576">    XSalsa20Poly1305.encrypt(c[<span class="tok-number">0</span>..], &amp;tag, msg[<span class="tok-number">0</span>..], <span class="tok-str">&quot;ad&quot;</span>, nonce, key);</span>
<span class="line" id="L577">    <span class="tok-kw">try</span> XSalsa20Poly1305.decrypt(msg2[<span class="tok-number">0</span>..], c[<span class="tok-number">0</span>..], tag, <span class="tok-str">&quot;ad&quot;</span>, nonce, key);</span>
<span class="line" id="L578">}</span>
<span class="line" id="L579"></span>
<span class="line" id="L580"><span class="tok-kw">test</span> <span class="tok-str">&quot;xsalsa20poly1305 secretbox&quot;</span> {</span>
<span class="line" id="L581">    <span class="tok-kw">var</span> msg: [<span class="tok-number">100</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L582">    <span class="tok-kw">var</span> msg2: [msg.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L583">    <span class="tok-kw">var</span> key: [XSalsa20Poly1305.key_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L584">    <span class="tok-kw">var</span> nonce: [Box.nonce_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L585">    <span class="tok-kw">var</span> boxed: [msg.len + Box.tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L586">    crypto.random.bytes(&amp;msg);</span>
<span class="line" id="L587">    crypto.random.bytes(&amp;key);</span>
<span class="line" id="L588">    crypto.random.bytes(&amp;nonce);</span>
<span class="line" id="L589"></span>
<span class="line" id="L590">    SecretBox.seal(boxed[<span class="tok-number">0</span>..], msg[<span class="tok-number">0</span>..], nonce, key);</span>
<span class="line" id="L591">    <span class="tok-kw">try</span> SecretBox.open(msg2[<span class="tok-number">0</span>..], boxed[<span class="tok-number">0</span>..], nonce, key);</span>
<span class="line" id="L592">}</span>
<span class="line" id="L593"></span>
<span class="line" id="L594"><span class="tok-kw">test</span> <span class="tok-str">&quot;xsalsa20poly1305 box&quot;</span> {</span>
<span class="line" id="L595">    <span class="tok-kw">var</span> msg: [<span class="tok-number">100</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L596">    <span class="tok-kw">var</span> msg2: [msg.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L597">    <span class="tok-kw">var</span> nonce: [Box.nonce_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L598">    <span class="tok-kw">var</span> boxed: [msg.len + Box.tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L599">    crypto.random.bytes(&amp;msg);</span>
<span class="line" id="L600">    crypto.random.bytes(&amp;nonce);</span>
<span class="line" id="L601"></span>
<span class="line" id="L602">    <span class="tok-kw">var</span> kp1 = <span class="tok-kw">try</span> Box.KeyPair.create(<span class="tok-null">null</span>);</span>
<span class="line" id="L603">    <span class="tok-kw">var</span> kp2 = <span class="tok-kw">try</span> Box.KeyPair.create(<span class="tok-null">null</span>);</span>
<span class="line" id="L604">    <span class="tok-kw">try</span> Box.seal(boxed[<span class="tok-number">0</span>..], msg[<span class="tok-number">0</span>..], nonce, kp1.public_key, kp2.secret_key);</span>
<span class="line" id="L605">    <span class="tok-kw">try</span> Box.open(msg2[<span class="tok-number">0</span>..], boxed[<span class="tok-number">0</span>..], nonce, kp2.public_key, kp1.secret_key);</span>
<span class="line" id="L606">}</span>
<span class="line" id="L607"></span>
<span class="line" id="L608"><span class="tok-kw">test</span> <span class="tok-str">&quot;xsalsa20poly1305 sealedbox&quot;</span> {</span>
<span class="line" id="L609">    <span class="tok-kw">var</span> msg: [<span class="tok-number">100</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L610">    <span class="tok-kw">var</span> msg2: [msg.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L611">    <span class="tok-kw">var</span> boxed: [msg.len + SealedBox.seal_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L612">    crypto.random.bytes(&amp;msg);</span>
<span class="line" id="L613"></span>
<span class="line" id="L614">    <span class="tok-kw">var</span> kp = <span class="tok-kw">try</span> Box.KeyPair.create(<span class="tok-null">null</span>);</span>
<span class="line" id="L615">    <span class="tok-kw">try</span> SealedBox.seal(boxed[<span class="tok-number">0</span>..], msg[<span class="tok-number">0</span>..], kp.public_key);</span>
<span class="line" id="L616">    <span class="tok-kw">try</span> SealedBox.open(msg2[<span class="tok-number">0</span>..], boxed[<span class="tok-number">0</span>..], kp);</span>
<span class="line" id="L617">}</span>
<span class="line" id="L618"></span>
<span class="line" id="L619"><span class="tok-kw">test</span> <span class="tok-str">&quot;secretbox twoblocks&quot;</span> {</span>
<span class="line" id="L620">    <span class="tok-kw">const</span> key = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0xc9</span>, <span class="tok-number">0xc9</span>, <span class="tok-number">0x4d</span>, <span class="tok-number">0xcf</span>, <span class="tok-number">0x68</span>, <span class="tok-number">0xbe</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0xe4</span>, <span class="tok-number">0x7f</span>, <span class="tok-number">0xe6</span>, <span class="tok-number">0x13</span>, <span class="tok-number">0x26</span>, <span class="tok-number">0xfc</span>, <span class="tok-number">0xc4</span>, <span class="tok-number">0x2f</span>, <span class="tok-number">0xd0</span>, <span class="tok-number">0xdb</span>, <span class="tok-number">0x93</span>, <span class="tok-number">0x91</span>, <span class="tok-number">0x1c</span>, <span class="tok-number">0x09</span>, <span class="tok-number">0x94</span>, <span class="tok-number">0x89</span>, <span class="tok-number">0xe1</span>, <span class="tok-number">0x1b</span>, <span class="tok-number">0x88</span>, <span class="tok-number">0x63</span>, <span class="tok-number">0x18</span>, <span class="tok-number">0x86</span>, <span class="tok-number">0x64</span>, <span class="tok-number">0x8b</span>, <span class="tok-number">0x7b</span> };</span>
<span class="line" id="L621">    <span class="tok-kw">const</span> nonce = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0xa4</span>, <span class="tok-number">0x33</span>, <span class="tok-number">0xe9</span>, <span class="tok-number">0x0a</span>, <span class="tok-number">0x07</span>, <span class="tok-number">0x68</span>, <span class="tok-number">0x6e</span>, <span class="tok-number">0x9a</span>, <span class="tok-number">0x2b</span>, <span class="tok-number">0x6d</span>, <span class="tok-number">0xd4</span>, <span class="tok-number">0x59</span>, <span class="tok-number">0x04</span>, <span class="tok-number">0x72</span>, <span class="tok-number">0x3e</span>, <span class="tok-number">0xd3</span>, <span class="tok-number">0x8a</span>, <span class="tok-number">0x67</span>, <span class="tok-number">0x55</span>, <span class="tok-number">0xc7</span>, <span class="tok-number">0x9e</span>, <span class="tok-number">0x3e</span>, <span class="tok-number">0x77</span>, <span class="tok-number">0xdc</span> };</span>
<span class="line" id="L622">    <span class="tok-kw">const</span> msg = [_]<span class="tok-type">u8</span>{<span class="tok-str">'a'</span>} ** <span class="tok-number">97</span>;</span>
<span class="line" id="L623">    <span class="tok-kw">var</span> ciphertext: [msg.len + SecretBox.tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L624">    SecretBox.seal(&amp;ciphertext, &amp;msg, nonce, key);</span>
<span class="line" id="L625">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;b05760e217288ba079caa2fd57fd3701784974ffcfda20fe523b89211ad8af065a6eb37cdb29d51aca5bd75dafdd21d18b044c54bb7c526cf576c94ee8900f911ceab0147e82b667a28c52d58ceb29554ff45471224d37b03256b01c119b89ff6d36855de8138d103386dbc9d971f52261&quot;</span>, &amp;ciphertext);</span>
<span class="line" id="L626">}</span>
<span class="line" id="L627"></span>
</code></pre></body>
</html>