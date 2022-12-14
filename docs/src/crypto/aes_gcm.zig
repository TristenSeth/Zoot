<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/aes_gcm.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> crypto = std.crypto;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> Ghash = std.crypto.onetimeauth.Ghash;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> modes = crypto.core.modes;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> AuthenticationError = crypto.errors.AuthenticationError;</span>
<span class="line" id="L9"></span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Aes128Gcm = AesGcm(crypto.core.aes.Aes128);</span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Aes256Gcm = AesGcm(crypto.core.aes.Aes256);</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">fn</span> <span class="tok-fn">AesGcm</span>(<span class="tok-kw">comptime</span> Aes: <span class="tok-kw">anytype</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L14">    debug.assert(Aes.block.block_length == <span class="tok-number">16</span>);</span>
<span class="line" id="L15"></span>
<span class="line" id="L16">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L17">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> tag_length = <span class="tok-number">16</span>;</span>
<span class="line" id="L18">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> nonce_length = <span class="tok-number">12</span>;</span>
<span class="line" id="L19">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> key_length = Aes.key_bits / <span class="tok-number">8</span>;</span>
<span class="line" id="L20"></span>
<span class="line" id="L21">        <span class="tok-kw">const</span> zeros = [_]<span class="tok-type">u8</span>{<span class="tok-number">0</span>} ** <span class="tok-number">16</span>;</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">encrypt</span>(c: []<span class="tok-type">u8</span>, tag: *[tag_length]<span class="tok-type">u8</span>, m: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, ad: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, key: [key_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L24">            debug.assert(c.len == m.len);</span>
<span class="line" id="L25">            debug.assert(m.len &lt;= <span class="tok-number">16</span> * ((<span class="tok-number">1</span> &lt;&lt; <span class="tok-number">32</span>) - <span class="tok-number">2</span>));</span>
<span class="line" id="L26"></span>
<span class="line" id="L27">            <span class="tok-kw">const</span> aes = Aes.initEnc(key);</span>
<span class="line" id="L28">            <span class="tok-kw">var</span> h: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L29">            aes.encrypt(&amp;h, &amp;zeros);</span>
<span class="line" id="L30"></span>
<span class="line" id="L31">            <span class="tok-kw">var</span> t: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L32">            <span class="tok-kw">var</span> j: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L33">            mem.copy(<span class="tok-type">u8</span>, j[<span class="tok-number">0</span>..nonce_length], npub[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L34">            mem.writeIntBig(<span class="tok-type">u32</span>, j[nonce_length..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], <span class="tok-number">1</span>);</span>
<span class="line" id="L35">            aes.encrypt(&amp;t, &amp;j);</span>
<span class="line" id="L36"></span>
<span class="line" id="L37">            <span class="tok-kw">var</span> mac = Ghash.init(&amp;h);</span>
<span class="line" id="L38">            mac.update(ad);</span>
<span class="line" id="L39">            mac.pad();</span>
<span class="line" id="L40"></span>
<span class="line" id="L41">            mem.writeIntBig(<span class="tok-type">u32</span>, j[nonce_length..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], <span class="tok-number">2</span>);</span>
<span class="line" id="L42">            modes.ctr(<span class="tok-builtin">@TypeOf</span>(aes), aes, c, m, j, std.builtin.Endian.Big);</span>
<span class="line" id="L43">            mac.update(c[<span class="tok-number">0</span>..m.len][<span class="tok-number">0</span>..]);</span>
<span class="line" id="L44">            mac.pad();</span>
<span class="line" id="L45"></span>
<span class="line" id="L46">            <span class="tok-kw">var</span> final_block = h;</span>
<span class="line" id="L47">            mem.writeIntBig(<span class="tok-type">u64</span>, final_block[<span class="tok-number">0</span>..<span class="tok-number">8</span>], ad.len * <span class="tok-number">8</span>);</span>
<span class="line" id="L48">            mem.writeIntBig(<span class="tok-type">u64</span>, final_block[<span class="tok-number">8</span>..<span class="tok-number">16</span>], m.len * <span class="tok-number">8</span>);</span>
<span class="line" id="L49">            mac.update(&amp;final_block);</span>
<span class="line" id="L50">            mac.final(tag);</span>
<span class="line" id="L51">            <span class="tok-kw">for</span> (t) |x, i| {</span>
<span class="line" id="L52">                tag[i] ^= x;</span>
<span class="line" id="L53">            }</span>
<span class="line" id="L54">        }</span>
<span class="line" id="L55"></span>
<span class="line" id="L56">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">decrypt</span>(m: []<span class="tok-type">u8</span>, c: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, tag: [tag_length]<span class="tok-type">u8</span>, ad: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, npub: [nonce_length]<span class="tok-type">u8</span>, key: [key_length]<span class="tok-type">u8</span>) AuthenticationError!<span class="tok-type">void</span> {</span>
<span class="line" id="L57">            assert(c.len == m.len);</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">            <span class="tok-kw">const</span> aes = Aes.initEnc(key);</span>
<span class="line" id="L60">            <span class="tok-kw">var</span> h: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L61">            aes.encrypt(&amp;h, &amp;zeros);</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">            <span class="tok-kw">var</span> t: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L64">            <span class="tok-kw">var</span> j: [<span class="tok-number">16</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L65">            mem.copy(<span class="tok-type">u8</span>, j[<span class="tok-number">0</span>..nonce_length], npub[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L66">            mem.writeIntBig(<span class="tok-type">u32</span>, j[nonce_length..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], <span class="tok-number">1</span>);</span>
<span class="line" id="L67">            aes.encrypt(&amp;t, &amp;j);</span>
<span class="line" id="L68"></span>
<span class="line" id="L69">            <span class="tok-kw">var</span> mac = Ghash.init(&amp;h);</span>
<span class="line" id="L70">            mac.update(ad);</span>
<span class="line" id="L71">            mac.pad();</span>
<span class="line" id="L72"></span>
<span class="line" id="L73">            mac.update(c);</span>
<span class="line" id="L74">            mac.pad();</span>
<span class="line" id="L75"></span>
<span class="line" id="L76">            <span class="tok-kw">var</span> final_block = h;</span>
<span class="line" id="L77">            mem.writeIntBig(<span class="tok-type">u64</span>, final_block[<span class="tok-number">0</span>..<span class="tok-number">8</span>], ad.len * <span class="tok-number">8</span>);</span>
<span class="line" id="L78">            mem.writeIntBig(<span class="tok-type">u64</span>, final_block[<span class="tok-number">8</span>..<span class="tok-number">16</span>], m.len * <span class="tok-number">8</span>);</span>
<span class="line" id="L79">            mac.update(&amp;final_block);</span>
<span class="line" id="L80">            <span class="tok-kw">var</span> computed_tag: [Ghash.mac_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L81">            mac.final(&amp;computed_tag);</span>
<span class="line" id="L82">            <span class="tok-kw">for</span> (t) |x, i| {</span>
<span class="line" id="L83">                computed_tag[i] ^= x;</span>
<span class="line" id="L84">            }</span>
<span class="line" id="L85"></span>
<span class="line" id="L86">            <span class="tok-kw">var</span> acc: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L87">            <span class="tok-kw">for</span> (computed_tag) |_, p| {</span>
<span class="line" id="L88">                acc |= (computed_tag[p] ^ tag[p]);</span>
<span class="line" id="L89">            }</span>
<span class="line" id="L90">            <span class="tok-kw">if</span> (acc != <span class="tok-number">0</span>) {</span>
<span class="line" id="L91">                mem.set(<span class="tok-type">u8</span>, m, <span class="tok-number">0xaa</span>);</span>
<span class="line" id="L92">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AuthenticationFailed;</span>
<span class="line" id="L93">            }</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">            mem.writeIntBig(<span class="tok-type">u32</span>, j[nonce_length..][<span class="tok-number">0</span>..<span class="tok-number">4</span>], <span class="tok-number">2</span>);</span>
<span class="line" id="L96">            modes.ctr(<span class="tok-builtin">@TypeOf</span>(aes), aes, m, c, j, std.builtin.Endian.Big);</span>
<span class="line" id="L97">        }</span>
<span class="line" id="L98">    };</span>
<span class="line" id="L99">}</span>
<span class="line" id="L100"></span>
<span class="line" id="L101"><span class="tok-kw">const</span> htest = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;test.zig&quot;</span>);</span>
<span class="line" id="L102"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L103"></span>
<span class="line" id="L104"><span class="tok-kw">test</span> <span class="tok-str">&quot;Aes256Gcm - Empty message and no associated data&quot;</span> {</span>
<span class="line" id="L105">    <span class="tok-kw">const</span> key: [Aes256Gcm.key_length]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x69</span>} ** Aes256Gcm.key_length;</span>
<span class="line" id="L106">    <span class="tok-kw">const</span> nonce: [Aes256Gcm.nonce_length]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x42</span>} ** Aes256Gcm.nonce_length;</span>
<span class="line" id="L107">    <span class="tok-kw">const</span> ad = <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L108">    <span class="tok-kw">const</span> m = <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L109">    <span class="tok-kw">var</span> c: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L110">    <span class="tok-kw">var</span> tag: [Aes256Gcm.tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L111"></span>
<span class="line" id="L112">    Aes256Gcm.encrypt(&amp;c, &amp;tag, m, ad, nonce, key);</span>
<span class="line" id="L113">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;6b6ff610a16fa4cd59f1fb7903154e92&quot;</span>, &amp;tag);</span>
<span class="line" id="L114">}</span>
<span class="line" id="L115"></span>
<span class="line" id="L116"><span class="tok-kw">test</span> <span class="tok-str">&quot;Aes256Gcm - Associated data only&quot;</span> {</span>
<span class="line" id="L117">    <span class="tok-kw">const</span> key: [Aes256Gcm.key_length]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x69</span>} ** Aes256Gcm.key_length;</span>
<span class="line" id="L118">    <span class="tok-kw">const</span> nonce: [Aes256Gcm.nonce_length]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x42</span>} ** Aes256Gcm.nonce_length;</span>
<span class="line" id="L119">    <span class="tok-kw">const</span> m = <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L120">    <span class="tok-kw">const</span> ad = <span class="tok-str">&quot;Test with associated data&quot;</span>;</span>
<span class="line" id="L121">    <span class="tok-kw">var</span> c: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L122">    <span class="tok-kw">var</span> tag: [Aes256Gcm.tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">    Aes256Gcm.encrypt(&amp;c, &amp;tag, m, ad, nonce, key);</span>
<span class="line" id="L125">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;262ed164c2dfb26e080a9d108dd9dd4c&quot;</span>, &amp;tag);</span>
<span class="line" id="L126">}</span>
<span class="line" id="L127"></span>
<span class="line" id="L128"><span class="tok-kw">test</span> <span class="tok-str">&quot;Aes256Gcm - Message only&quot;</span> {</span>
<span class="line" id="L129">    <span class="tok-kw">const</span> key: [Aes256Gcm.key_length]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x69</span>} ** Aes256Gcm.key_length;</span>
<span class="line" id="L130">    <span class="tok-kw">const</span> nonce: [Aes256Gcm.nonce_length]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x42</span>} ** Aes256Gcm.nonce_length;</span>
<span class="line" id="L131">    <span class="tok-kw">const</span> m = <span class="tok-str">&quot;Test with message only&quot;</span>;</span>
<span class="line" id="L132">    <span class="tok-kw">const</span> ad = <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L133">    <span class="tok-kw">var</span> c: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L134">    <span class="tok-kw">var</span> m2: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L135">    <span class="tok-kw">var</span> tag: [Aes256Gcm.tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L136"></span>
<span class="line" id="L137">    Aes256Gcm.encrypt(&amp;c, &amp;tag, m, ad, nonce, key);</span>
<span class="line" id="L138">    <span class="tok-kw">try</span> Aes256Gcm.decrypt(&amp;m2, &amp;c, tag, ad, nonce, key);</span>
<span class="line" id="L139">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, m[<span class="tok-number">0</span>..], m2[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L140"></span>
<span class="line" id="L141">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;5ca1642d90009fea33d01f78cf6eefaf01d539472f7c&quot;</span>, &amp;c);</span>
<span class="line" id="L142">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;07cd7fc9103e2f9e9bf2dfaa319caff4&quot;</span>, &amp;tag);</span>
<span class="line" id="L143">}</span>
<span class="line" id="L144"></span>
<span class="line" id="L145"><span class="tok-kw">test</span> <span class="tok-str">&quot;Aes256Gcm - Message and associated data&quot;</span> {</span>
<span class="line" id="L146">    <span class="tok-kw">const</span> key: [Aes256Gcm.key_length]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x69</span>} ** Aes256Gcm.key_length;</span>
<span class="line" id="L147">    <span class="tok-kw">const</span> nonce: [Aes256Gcm.nonce_length]<span class="tok-type">u8</span> = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x42</span>} ** Aes256Gcm.nonce_length;</span>
<span class="line" id="L148">    <span class="tok-kw">const</span> m = <span class="tok-str">&quot;Test with message&quot;</span>;</span>
<span class="line" id="L149">    <span class="tok-kw">const</span> ad = <span class="tok-str">&quot;Test with associated data&quot;</span>;</span>
<span class="line" id="L150">    <span class="tok-kw">var</span> c: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L151">    <span class="tok-kw">var</span> m2: [m.len]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L152">    <span class="tok-kw">var</span> tag: [Aes256Gcm.tag_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L153"></span>
<span class="line" id="L154">    Aes256Gcm.encrypt(&amp;c, &amp;tag, m, ad, nonce, key);</span>
<span class="line" id="L155">    <span class="tok-kw">try</span> Aes256Gcm.decrypt(&amp;m2, &amp;c, tag, ad, nonce, key);</span>
<span class="line" id="L156">    <span class="tok-kw">try</span> testing.expectEqualSlices(<span class="tok-type">u8</span>, m[<span class="tok-number">0</span>..], m2[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L157"></span>
<span class="line" id="L158">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;5ca1642d90009fea33d01f78cf6eefaf01&quot;</span>, &amp;c);</span>
<span class="line" id="L159">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;64accec679d444e2373bd9f6796c0d2c&quot;</span>, &amp;tag);</span>
<span class="line" id="L160">}</span>
<span class="line" id="L161"></span>
</code></pre></body>
</html>