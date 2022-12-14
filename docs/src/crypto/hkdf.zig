<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/hkdf.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> hmac = std.crypto.auth.hmac;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-comment">/// HKDF-SHA256</span></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HkdfSha256 = Hkdf(hmac.sha2.HmacSha256);</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-comment">/// HKDF-SHA512</span></span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HkdfSha512 = Hkdf(hmac.sha2.HmacSha512);</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-comment">/// The Hkdf construction takes some source of initial keying material and</span></span>
<span class="line" id="L13"><span class="tok-comment">/// derives one or more uniform keys from it.</span></span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Hkdf</span>(<span class="tok-kw">comptime</span> Hmac: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L15">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L16">        <span class="tok-comment">/// Return a master key from a salt and initial keying material.</span></span>
<span class="line" id="L17">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">extract</span>(salt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, ikm: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) [Hmac.mac_length]<span class="tok-type">u8</span> {</span>
<span class="line" id="L18">            <span class="tok-kw">var</span> prk: [Hmac.mac_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L19">            Hmac.create(&amp;prk, ikm, salt);</span>
<span class="line" id="L20">            <span class="tok-kw">return</span> prk;</span>
<span class="line" id="L21">        }</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">        <span class="tok-comment">/// Derive a subkey from a master key `prk` and a subkey description `ctx`.</span></span>
<span class="line" id="L24">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">expand</span>(out: []<span class="tok-type">u8</span>, ctx: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, prk: [Hmac.mac_length]<span class="tok-type">u8</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L25">            assert(out.len &lt; Hmac.mac_length * <span class="tok-number">255</span>); <span class="tok-comment">// output size is too large for the Hkdf construction</span>
</span>
<span class="line" id="L26">            <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L27">            <span class="tok-kw">var</span> counter = [<span class="tok-number">1</span>]<span class="tok-type">u8</span>{<span class="tok-number">1</span>};</span>
<span class="line" id="L28">            <span class="tok-kw">while</span> (i + Hmac.mac_length &lt;= out.len) : (i += Hmac.mac_length) {</span>
<span class="line" id="L29">                <span class="tok-kw">var</span> st = Hmac.init(&amp;prk);</span>
<span class="line" id="L30">                <span class="tok-kw">if</span> (i != <span class="tok-number">0</span>) {</span>
<span class="line" id="L31">                    st.update(out[i - Hmac.mac_length ..][<span class="tok-number">0</span>..Hmac.mac_length]);</span>
<span class="line" id="L32">                }</span>
<span class="line" id="L33">                st.update(ctx);</span>
<span class="line" id="L34">                st.update(&amp;counter);</span>
<span class="line" id="L35">                st.final(out[i..][<span class="tok-number">0</span>..Hmac.mac_length]);</span>
<span class="line" id="L36">                counter[<span class="tok-number">0</span>] += <span class="tok-number">1</span>;</span>
<span class="line" id="L37">            }</span>
<span class="line" id="L38">            <span class="tok-kw">const</span> left = out.len % Hmac.mac_length;</span>
<span class="line" id="L39">            <span class="tok-kw">if</span> (left &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L40">                <span class="tok-kw">var</span> st = Hmac.init(&amp;prk);</span>
<span class="line" id="L41">                <span class="tok-kw">if</span> (i != <span class="tok-number">0</span>) {</span>
<span class="line" id="L42">                    st.update(out[i - Hmac.mac_length ..][<span class="tok-number">0</span>..Hmac.mac_length]);</span>
<span class="line" id="L43">                }</span>
<span class="line" id="L44">                st.update(ctx);</span>
<span class="line" id="L45">                st.update(&amp;counter);</span>
<span class="line" id="L46">                <span class="tok-kw">var</span> tmp: [Hmac.mac_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L47">                st.final(tmp[<span class="tok-number">0</span>..Hmac.mac_length]);</span>
<span class="line" id="L48">                mem.copy(<span class="tok-type">u8</span>, out[i..][<span class="tok-number">0</span>..left], tmp[<span class="tok-number">0</span>..left]);</span>
<span class="line" id="L49">            }</span>
<span class="line" id="L50">        }</span>
<span class="line" id="L51">    };</span>
<span class="line" id="L52">}</span>
<span class="line" id="L53"></span>
<span class="line" id="L54"><span class="tok-kw">const</span> htest = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;test.zig&quot;</span>);</span>
<span class="line" id="L55"></span>
<span class="line" id="L56"><span class="tok-kw">test</span> <span class="tok-str">&quot;Hkdf&quot;</span> {</span>
<span class="line" id="L57">    <span class="tok-kw">const</span> ikm = [_]<span class="tok-type">u8</span>{<span class="tok-number">0x0b</span>} ** <span class="tok-number">22</span>;</span>
<span class="line" id="L58">    <span class="tok-kw">const</span> salt = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x00</span>, <span class="tok-number">0x01</span>, <span class="tok-number">0x02</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x04</span>, <span class="tok-number">0x05</span>, <span class="tok-number">0x06</span>, <span class="tok-number">0x07</span>, <span class="tok-number">0x08</span>, <span class="tok-number">0x09</span>, <span class="tok-number">0x0a</span>, <span class="tok-number">0x0b</span>, <span class="tok-number">0x0c</span> };</span>
<span class="line" id="L59">    <span class="tok-kw">const</span> context = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0xf0</span>, <span class="tok-number">0xf1</span>, <span class="tok-number">0xf2</span>, <span class="tok-number">0xf3</span>, <span class="tok-number">0xf4</span>, <span class="tok-number">0xf5</span>, <span class="tok-number">0xf6</span>, <span class="tok-number">0xf7</span>, <span class="tok-number">0xf8</span>, <span class="tok-number">0xf9</span> };</span>
<span class="line" id="L60">    <span class="tok-kw">const</span> kdf = HkdfSha256;</span>
<span class="line" id="L61">    <span class="tok-kw">const</span> prk = kdf.extract(&amp;salt, &amp;ikm);</span>
<span class="line" id="L62">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;077709362c2e32df0ddc3f0dc47bba6390b6c73bb50f9c3122ec844ad7c2b3e5&quot;</span>, &amp;prk);</span>
<span class="line" id="L63">    <span class="tok-kw">var</span> out: [<span class="tok-number">42</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L64">    kdf.expand(&amp;out, &amp;context, prk);</span>
<span class="line" id="L65">    <span class="tok-kw">try</span> htest.assertEqual(<span class="tok-str">&quot;3cb25f25faacd57a90434f64d0362f2a2d2d0a90cf1a5a4c5db02d56ecc4c5bf34007208d5b887185865&quot;</span>, &amp;out);</span>
<span class="line" id="L66">}</span>
<span class="line" id="L67"></span>
</code></pre></body>
</html>