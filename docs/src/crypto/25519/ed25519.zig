<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>crypto/25519/ed25519.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> crypto = std.crypto;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> fmt = std.fmt;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">const</span> Sha512 = crypto.hash.sha2.Sha512;</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-kw">const</span> EncodingError = crypto.errors.EncodingError;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> IdentityElementError = crypto.errors.IdentityElementError;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> NonCanonicalError = crypto.errors.NonCanonicalError;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> SignatureVerificationError = crypto.errors.SignatureVerificationError;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> KeyMismatchError = crypto.errors.KeyMismatchError;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> WeakPublicKeyError = crypto.errors.WeakPublicKeyError;</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-comment">/// Ed25519 (EdDSA) signatures.</span></span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Ed25519 = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L18">    <span class="tok-comment">/// The underlying elliptic curve.</span></span>
<span class="line" id="L19">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Curve = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;edwards25519.zig&quot;</span>).Edwards25519;</span>
<span class="line" id="L20">    <span class="tok-comment">/// Length (in bytes) of a seed required to create a key pair.</span></span>
<span class="line" id="L21">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> seed_length = <span class="tok-number">32</span>;</span>
<span class="line" id="L22">    <span class="tok-comment">/// Length (in bytes) of a compressed secret key.</span></span>
<span class="line" id="L23">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> secret_length = <span class="tok-number">64</span>;</span>
<span class="line" id="L24">    <span class="tok-comment">/// Length (in bytes) of a compressed public key.</span></span>
<span class="line" id="L25">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> public_length = <span class="tok-number">32</span>;</span>
<span class="line" id="L26">    <span class="tok-comment">/// Length (in bytes) of a signature.</span></span>
<span class="line" id="L27">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> signature_length = <span class="tok-number">64</span>;</span>
<span class="line" id="L28">    <span class="tok-comment">/// Length (in bytes) of optional random bytes, for non-deterministic signatures.</span></span>
<span class="line" id="L29">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> noise_length = <span class="tok-number">32</span>;</span>
<span class="line" id="L30"></span>
<span class="line" id="L31">    <span class="tok-kw">const</span> CompressedScalar = Curve.scalar.CompressedScalar;</span>
<span class="line" id="L32">    <span class="tok-kw">const</span> Scalar = Curve.scalar.Scalar;</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">    <span class="tok-comment">/// An Ed25519 key pair.</span></span>
<span class="line" id="L35">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> KeyPair = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L36">        <span class="tok-comment">/// Public part.</span></span>
<span class="line" id="L37">        public_key: [public_length]<span class="tok-type">u8</span>,</span>
<span class="line" id="L38">        <span class="tok-comment">/// Secret part. What we expose as a secret key is, under the hood, the concatenation of the seed and the public key.</span></span>
<span class="line" id="L39">        secret_key: [secret_length]<span class="tok-type">u8</span>,</span>
<span class="line" id="L40"></span>
<span class="line" id="L41">        <span class="tok-comment">/// Derive a key pair from an optional secret seed.</span></span>
<span class="line" id="L42">        <span class="tok-comment">///</span></span>
<span class="line" id="L43">        <span class="tok-comment">/// As in RFC 8032, an Ed25519 public key is generated by hashing</span></span>
<span class="line" id="L44">        <span class="tok-comment">/// the secret key using the SHA-512 function, and interpreting the</span></span>
<span class="line" id="L45">        <span class="tok-comment">/// bit-swapped, clamped lower-half of the output as the secret scalar.</span></span>
<span class="line" id="L46">        <span class="tok-comment">///</span></span>
<span class="line" id="L47">        <span class="tok-comment">/// For this reason, an EdDSA secret key is commonly called a seed,</span></span>
<span class="line" id="L48">        <span class="tok-comment">/// from which the actual secret is derived.</span></span>
<span class="line" id="L49">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(seed: ?[seed_length]<span class="tok-type">u8</span>) IdentityElementError!KeyPair {</span>
<span class="line" id="L50">            <span class="tok-kw">const</span> ss = seed <span class="tok-kw">orelse</span> ss: {</span>
<span class="line" id="L51">                <span class="tok-kw">var</span> random_seed: [seed_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L52">                crypto.random.bytes(&amp;random_seed);</span>
<span class="line" id="L53">                <span class="tok-kw">break</span> :ss random_seed;</span>
<span class="line" id="L54">            };</span>
<span class="line" id="L55">            <span class="tok-kw">var</span> az: [Sha512.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L56">            <span class="tok-kw">var</span> h = Sha512.init(.{});</span>
<span class="line" id="L57">            h.update(&amp;ss);</span>
<span class="line" id="L58">            h.final(&amp;az);</span>
<span class="line" id="L59">            <span class="tok-kw">const</span> p = Curve.basePoint.clampedMul(az[<span class="tok-number">0</span>..<span class="tok-number">32</span>].*) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IdentityElement;</span>
<span class="line" id="L60">            <span class="tok-kw">var</span> sk: [secret_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L61">            mem.copy(<span class="tok-type">u8</span>, &amp;sk, &amp;ss);</span>
<span class="line" id="L62">            <span class="tok-kw">const</span> pk = p.toBytes();</span>
<span class="line" id="L63">            mem.copy(<span class="tok-type">u8</span>, sk[seed_length..], &amp;pk);</span>
<span class="line" id="L64"></span>
<span class="line" id="L65">            <span class="tok-kw">return</span> KeyPair{ .public_key = pk, .secret_key = sk };</span>
<span class="line" id="L66">        }</span>
<span class="line" id="L67"></span>
<span class="line" id="L68">        <span class="tok-comment">/// Create a KeyPair from a secret key.</span></span>
<span class="line" id="L69">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromSecretKey</span>(secret_key: [secret_length]<span class="tok-type">u8</span>) KeyPair {</span>
<span class="line" id="L70">            <span class="tok-kw">return</span> KeyPair{</span>
<span class="line" id="L71">                .secret_key = secret_key,</span>
<span class="line" id="L72">                .public_key = secret_key[seed_length..].*,</span>
<span class="line" id="L73">            };</span>
<span class="line" id="L74">        }</span>
<span class="line" id="L75">    };</span>
<span class="line" id="L76"></span>
<span class="line" id="L77">    <span class="tok-comment">/// Sign a message using a key pair, and optional random noise.</span></span>
<span class="line" id="L78">    <span class="tok-comment">/// Having noise creates non-standard, non-deterministic signatures,</span></span>
<span class="line" id="L79">    <span class="tok-comment">/// but has been proven to increase resilience against fault attacks.</span></span>
<span class="line" id="L80">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sign</span>(msg: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, key_pair: KeyPair, noise: ?[noise_length]<span class="tok-type">u8</span>) (IdentityElementError || WeakPublicKeyError || KeyMismatchError)![signature_length]<span class="tok-type">u8</span> {</span>
<span class="line" id="L81">        <span class="tok-kw">const</span> seed = key_pair.secret_key[<span class="tok-number">0</span>..seed_length];</span>
<span class="line" id="L82">        <span class="tok-kw">const</span> public_key = key_pair.secret_key[seed_length..];</span>
<span class="line" id="L83">        <span class="tok-kw">if</span> (!mem.eql(<span class="tok-type">u8</span>, public_key, &amp;key_pair.public_key)) {</span>
<span class="line" id="L84">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.KeyMismatch;</span>
<span class="line" id="L85">        }</span>
<span class="line" id="L86">        <span class="tok-kw">var</span> az: [Sha512.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L87">        <span class="tok-kw">var</span> h = Sha512.init(.{});</span>
<span class="line" id="L88">        h.update(seed);</span>
<span class="line" id="L89">        h.final(&amp;az);</span>
<span class="line" id="L90"></span>
<span class="line" id="L91">        h = Sha512.init(.{});</span>
<span class="line" id="L92">        <span class="tok-kw">if</span> (noise) |*z| {</span>
<span class="line" id="L93">            h.update(z);</span>
<span class="line" id="L94">        }</span>
<span class="line" id="L95">        h.update(az[<span class="tok-number">32</span>..]);</span>
<span class="line" id="L96">        h.update(msg);</span>
<span class="line" id="L97">        <span class="tok-kw">var</span> nonce64: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L98">        h.final(&amp;nonce64);</span>
<span class="line" id="L99">        <span class="tok-kw">const</span> nonce = Curve.scalar.reduce64(nonce64);</span>
<span class="line" id="L100">        <span class="tok-kw">const</span> r = <span class="tok-kw">try</span> Curve.basePoint.mul(nonce);</span>
<span class="line" id="L101"></span>
<span class="line" id="L102">        <span class="tok-kw">var</span> sig: [signature_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L103">        mem.copy(<span class="tok-type">u8</span>, sig[<span class="tok-number">0</span>..<span class="tok-number">32</span>], &amp;r.toBytes());</span>
<span class="line" id="L104">        mem.copy(<span class="tok-type">u8</span>, sig[<span class="tok-number">32</span>..], public_key);</span>
<span class="line" id="L105">        h = Sha512.init(.{});</span>
<span class="line" id="L106">        h.update(&amp;sig);</span>
<span class="line" id="L107">        h.update(msg);</span>
<span class="line" id="L108">        <span class="tok-kw">var</span> hram64: [Sha512.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L109">        h.final(&amp;hram64);</span>
<span class="line" id="L110">        <span class="tok-kw">const</span> hram = Curve.scalar.reduce64(hram64);</span>
<span class="line" id="L111"></span>
<span class="line" id="L112">        <span class="tok-kw">var</span> x = az[<span class="tok-number">0</span>..<span class="tok-number">32</span>];</span>
<span class="line" id="L113">        Curve.scalar.clamp(x);</span>
<span class="line" id="L114">        <span class="tok-kw">const</span> s = Curve.scalar.mulAdd(hram, x.*, nonce);</span>
<span class="line" id="L115">        mem.copy(<span class="tok-type">u8</span>, sig[<span class="tok-number">32</span>..], s[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L116">        <span class="tok-kw">return</span> sig;</span>
<span class="line" id="L117">    }</span>
<span class="line" id="L118"></span>
<span class="line" id="L119">    <span class="tok-comment">/// Verify an Ed25519 signature given a message and a public key.</span></span>
<span class="line" id="L120">    <span class="tok-comment">/// Returns error.SignatureVerificationFailed is the signature verification failed.</span></span>
<span class="line" id="L121">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">verify</span>(sig: [signature_length]<span class="tok-type">u8</span>, msg: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, public_key: [public_length]<span class="tok-type">u8</span>) (SignatureVerificationError || WeakPublicKeyError || EncodingError || NonCanonicalError || IdentityElementError)!<span class="tok-type">void</span> {</span>
<span class="line" id="L122">        <span class="tok-kw">const</span> r = sig[<span class="tok-number">0</span>..<span class="tok-number">32</span>];</span>
<span class="line" id="L123">        <span class="tok-kw">const</span> s = sig[<span class="tok-number">32</span>..<span class="tok-number">64</span>];</span>
<span class="line" id="L124">        <span class="tok-kw">try</span> Curve.scalar.rejectNonCanonical(s.*);</span>
<span class="line" id="L125">        <span class="tok-kw">try</span> Curve.rejectNonCanonical(public_key);</span>
<span class="line" id="L126">        <span class="tok-kw">const</span> a = <span class="tok-kw">try</span> Curve.fromBytes(public_key);</span>
<span class="line" id="L127">        <span class="tok-kw">try</span> a.rejectIdentity();</span>
<span class="line" id="L128">        <span class="tok-kw">try</span> Curve.rejectNonCanonical(r.*);</span>
<span class="line" id="L129">        <span class="tok-kw">const</span> expected_r = <span class="tok-kw">try</span> Curve.fromBytes(r.*);</span>
<span class="line" id="L130">        <span class="tok-kw">try</span> expected_r.rejectIdentity();</span>
<span class="line" id="L131"></span>
<span class="line" id="L132">        <span class="tok-kw">var</span> h = Sha512.init(.{});</span>
<span class="line" id="L133">        h.update(r);</span>
<span class="line" id="L134">        h.update(&amp;public_key);</span>
<span class="line" id="L135">        h.update(msg);</span>
<span class="line" id="L136">        <span class="tok-kw">var</span> hram64: [Sha512.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L137">        h.final(&amp;hram64);</span>
<span class="line" id="L138">        <span class="tok-kw">const</span> hram = Curve.scalar.reduce64(hram64);</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">        <span class="tok-kw">const</span> sb_ah = <span class="tok-kw">try</span> Curve.basePoint.mulDoubleBasePublic(s.*, a.neg(), hram);</span>
<span class="line" id="L141">        <span class="tok-kw">if</span> (expected_r.sub(sb_ah).clearCofactor().rejectIdentity()) |_| {</span>
<span class="line" id="L142">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SignatureVerificationFailed;</span>
<span class="line" id="L143">        } <span class="tok-kw">else</span> |_| {}</span>
<span class="line" id="L144">    }</span>
<span class="line" id="L145"></span>
<span class="line" id="L146">    <span class="tok-comment">/// A (signature, message, public_key) tuple for batch verification</span></span>
<span class="line" id="L147">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BatchElement = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L148">        sig: [signature_length]<span class="tok-type">u8</span>,</span>
<span class="line" id="L149">        msg: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L150">        public_key: [public_length]<span class="tok-type">u8</span>,</span>
<span class="line" id="L151">    };</span>
<span class="line" id="L152"></span>
<span class="line" id="L153">    <span class="tok-comment">/// Verify several signatures in a single operation, much faster than verifying signatures one-by-one</span></span>
<span class="line" id="L154">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">verifyBatch</span>(<span class="tok-kw">comptime</span> count: <span class="tok-type">usize</span>, signature_batch: [count]BatchElement) (SignatureVerificationError || IdentityElementError || WeakPublicKeyError || EncodingError || NonCanonicalError)!<span class="tok-type">void</span> {</span>
<span class="line" id="L155">        <span class="tok-kw">var</span> r_batch: [count][<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L156">        <span class="tok-kw">var</span> s_batch: [count][<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L157">        <span class="tok-kw">var</span> a_batch: [count]Curve = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L158">        <span class="tok-kw">var</span> expected_r_batch: [count]Curve = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L159"></span>
<span class="line" id="L160">        <span class="tok-kw">for</span> (signature_batch) |signature, i| {</span>
<span class="line" id="L161">            <span class="tok-kw">const</span> r = signature.sig[<span class="tok-number">0</span>..<span class="tok-number">32</span>];</span>
<span class="line" id="L162">            <span class="tok-kw">const</span> s = signature.sig[<span class="tok-number">32</span>..<span class="tok-number">64</span>];</span>
<span class="line" id="L163">            <span class="tok-kw">try</span> Curve.scalar.rejectNonCanonical(s.*);</span>
<span class="line" id="L164">            <span class="tok-kw">try</span> Curve.rejectNonCanonical(signature.public_key);</span>
<span class="line" id="L165">            <span class="tok-kw">const</span> a = <span class="tok-kw">try</span> Curve.fromBytes(signature.public_key);</span>
<span class="line" id="L166">            <span class="tok-kw">try</span> a.rejectIdentity();</span>
<span class="line" id="L167">            <span class="tok-kw">try</span> Curve.rejectNonCanonical(r.*);</span>
<span class="line" id="L168">            <span class="tok-kw">const</span> expected_r = <span class="tok-kw">try</span> Curve.fromBytes(r.*);</span>
<span class="line" id="L169">            <span class="tok-kw">try</span> expected_r.rejectIdentity();</span>
<span class="line" id="L170">            expected_r_batch[i] = expected_r;</span>
<span class="line" id="L171">            r_batch[i] = r.*;</span>
<span class="line" id="L172">            s_batch[i] = s.*;</span>
<span class="line" id="L173">            a_batch[i] = a;</span>
<span class="line" id="L174">        }</span>
<span class="line" id="L175"></span>
<span class="line" id="L176">        <span class="tok-kw">var</span> hram_batch: [count]Curve.scalar.CompressedScalar = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L177">        <span class="tok-kw">for</span> (signature_batch) |signature, i| {</span>
<span class="line" id="L178">            <span class="tok-kw">var</span> h = Sha512.init(.{});</span>
<span class="line" id="L179">            h.update(&amp;r_batch[i]);</span>
<span class="line" id="L180">            h.update(&amp;signature.public_key);</span>
<span class="line" id="L181">            h.update(signature.msg);</span>
<span class="line" id="L182">            <span class="tok-kw">var</span> hram64: [Sha512.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L183">            h.final(&amp;hram64);</span>
<span class="line" id="L184">            hram_batch[i] = Curve.scalar.reduce64(hram64);</span>
<span class="line" id="L185">        }</span>
<span class="line" id="L186"></span>
<span class="line" id="L187">        <span class="tok-kw">var</span> z_batch: [count]Curve.scalar.CompressedScalar = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L188">        <span class="tok-kw">for</span> (z_batch) |*z| {</span>
<span class="line" id="L189">            crypto.random.bytes(z[<span class="tok-number">0</span>..<span class="tok-number">16</span>]);</span>
<span class="line" id="L190">            mem.set(<span class="tok-type">u8</span>, z[<span class="tok-number">16</span>..], <span class="tok-number">0</span>);</span>
<span class="line" id="L191">        }</span>
<span class="line" id="L192"></span>
<span class="line" id="L193">        <span class="tok-kw">var</span> zs_sum = Curve.scalar.zero;</span>
<span class="line" id="L194">        <span class="tok-kw">for</span> (z_batch) |z, i| {</span>
<span class="line" id="L195">            <span class="tok-kw">const</span> zs = Curve.scalar.mul(z, s_batch[i]);</span>
<span class="line" id="L196">            zs_sum = Curve.scalar.add(zs_sum, zs);</span>
<span class="line" id="L197">        }</span>
<span class="line" id="L198">        zs_sum = Curve.scalar.mul8(zs_sum);</span>
<span class="line" id="L199"></span>
<span class="line" id="L200">        <span class="tok-kw">var</span> zhs: [count]Curve.scalar.CompressedScalar = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L201">        <span class="tok-kw">for</span> (z_batch) |z, i| {</span>
<span class="line" id="L202">            zhs[i] = Curve.scalar.mul(z, hram_batch[i]);</span>
<span class="line" id="L203">        }</span>
<span class="line" id="L204"></span>
<span class="line" id="L205">        <span class="tok-kw">const</span> zr = (<span class="tok-kw">try</span> Curve.mulMulti(count, expected_r_batch, z_batch)).clearCofactor();</span>
<span class="line" id="L206">        <span class="tok-kw">const</span> zah = (<span class="tok-kw">try</span> Curve.mulMulti(count, a_batch, zhs)).clearCofactor();</span>
<span class="line" id="L207"></span>
<span class="line" id="L208">        <span class="tok-kw">const</span> zsb = <span class="tok-kw">try</span> Curve.basePoint.mulPublic(zs_sum);</span>
<span class="line" id="L209">        <span class="tok-kw">if</span> (zr.add(zah).sub(zsb).rejectIdentity()) |_| {</span>
<span class="line" id="L210">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SignatureVerificationFailed;</span>
<span class="line" id="L211">        } <span class="tok-kw">else</span> |_| {}</span>
<span class="line" id="L212">    }</span>
<span class="line" id="L213"></span>
<span class="line" id="L214">    <span class="tok-comment">/// Ed25519 signatures with key blinding.</span></span>
<span class="line" id="L215">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BlindKeySignatures = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L216">        <span class="tok-comment">/// Length (in bytes) of a blinding seed.</span></span>
<span class="line" id="L217">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> blind_seed_length = <span class="tok-number">32</span>;</span>
<span class="line" id="L218"></span>
<span class="line" id="L219">        <span class="tok-comment">/// A blind secret key.</span></span>
<span class="line" id="L220">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BlindSecretKey = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L221">            prefix: [<span class="tok-number">64</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L222">            blind_scalar: CompressedScalar,</span>
<span class="line" id="L223">            blind_public_key: CompressedScalar,</span>
<span class="line" id="L224">        };</span>
<span class="line" id="L225"></span>
<span class="line" id="L226">        <span class="tok-comment">/// A blind key pair.</span></span>
<span class="line" id="L227">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> BlindKeyPair = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L228">            blind_public_key: [public_length]<span class="tok-type">u8</span>,</span>
<span class="line" id="L229">            blind_secret_key: BlindSecretKey,</span>
<span class="line" id="L230">        };</span>
<span class="line" id="L231"></span>
<span class="line" id="L232">        <span class="tok-comment">/// Blind an existing key pair with a blinding seed and a context.</span></span>
<span class="line" id="L233">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">blind</span>(key_pair: Ed25519.KeyPair, blind_seed: [blind_seed_length]<span class="tok-type">u8</span>, ctx: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !BlindKeyPair {</span>
<span class="line" id="L234">            <span class="tok-kw">var</span> h: [Sha512.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L235">            Sha512.hash(key_pair.secret_key[<span class="tok-number">0</span>..<span class="tok-number">32</span>], &amp;h, .{});</span>
<span class="line" id="L236">            Curve.scalar.clamp(h[<span class="tok-number">0</span>..<span class="tok-number">32</span>]);</span>
<span class="line" id="L237">            <span class="tok-kw">const</span> scalar = Curve.scalar.reduce(h[<span class="tok-number">0</span>..<span class="tok-number">32</span>].*);</span>
<span class="line" id="L238"></span>
<span class="line" id="L239">            <span class="tok-kw">const</span> blind_h = blindCtx(blind_seed, ctx);</span>
<span class="line" id="L240">            <span class="tok-kw">const</span> blind_factor = Curve.scalar.reduce(blind_h[<span class="tok-number">0</span>..<span class="tok-number">32</span>].*);</span>
<span class="line" id="L241"></span>
<span class="line" id="L242">            <span class="tok-kw">const</span> blind_scalar = Curve.scalar.mul(scalar, blind_factor);</span>
<span class="line" id="L243">            <span class="tok-kw">const</span> blind_public_key = (Curve.basePoint.mul(blind_scalar) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.IdentityElement).toBytes();</span>
<span class="line" id="L244"></span>
<span class="line" id="L245">            <span class="tok-kw">var</span> prefix: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L246">            mem.copy(<span class="tok-type">u8</span>, prefix[<span class="tok-number">0</span>..<span class="tok-number">32</span>], h[<span class="tok-number">32</span>..<span class="tok-number">64</span>]);</span>
<span class="line" id="L247">            mem.copy(<span class="tok-type">u8</span>, prefix[<span class="tok-number">32</span>..<span class="tok-number">64</span>], blind_h[<span class="tok-number">32</span>..<span class="tok-number">64</span>]);</span>
<span class="line" id="L248"></span>
<span class="line" id="L249">            <span class="tok-kw">const</span> blind_secret_key = .{</span>
<span class="line" id="L250">                .prefix = prefix,</span>
<span class="line" id="L251">                .blind_scalar = blind_scalar,</span>
<span class="line" id="L252">                .blind_public_key = blind_public_key,</span>
<span class="line" id="L253">            };</span>
<span class="line" id="L254">            <span class="tok-kw">return</span> BlindKeyPair{</span>
<span class="line" id="L255">                .blind_public_key = blind_public_key,</span>
<span class="line" id="L256">                .blind_secret_key = blind_secret_key,</span>
<span class="line" id="L257">            };</span>
<span class="line" id="L258">        }</span>
<span class="line" id="L259"></span>
<span class="line" id="L260">        <span class="tok-comment">/// Recover a public key from a blind version of it.</span></span>
<span class="line" id="L261">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unblindPublicKey</span>(blind_public_key: [public_length]<span class="tok-type">u8</span>, blind_seed: [blind_seed_length]<span class="tok-type">u8</span>, ctx: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![public_length]<span class="tok-type">u8</span> {</span>
<span class="line" id="L262">            <span class="tok-kw">const</span> blind_h = blindCtx(blind_seed, ctx);</span>
<span class="line" id="L263">            <span class="tok-kw">const</span> inv_blind_factor = Scalar.fromBytes(blind_h[<span class="tok-number">0</span>..<span class="tok-number">32</span>].*).invert().toBytes();</span>
<span class="line" id="L264">            <span class="tok-kw">const</span> public_key = <span class="tok-kw">try</span> (<span class="tok-kw">try</span> Curve.fromBytes(blind_public_key)).mul(inv_blind_factor);</span>
<span class="line" id="L265">            <span class="tok-kw">return</span> public_key.toBytes();</span>
<span class="line" id="L266">        }</span>
<span class="line" id="L267"></span>
<span class="line" id="L268">        <span class="tok-comment">/// Sign a message using a blind key pair, and optional random noise.</span></span>
<span class="line" id="L269">        <span class="tok-comment">/// Having noise creates non-standard, non-deterministic signatures,</span></span>
<span class="line" id="L270">        <span class="tok-comment">/// but has been proven to increase resilience against fault attacks.</span></span>
<span class="line" id="L271">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">sign</span>(msg: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, key_pair: BlindKeyPair, noise: ?[noise_length]<span class="tok-type">u8</span>) ![signature_length]<span class="tok-type">u8</span> {</span>
<span class="line" id="L272">            <span class="tok-kw">var</span> h = Sha512.init(.{});</span>
<span class="line" id="L273">            <span class="tok-kw">if</span> (noise) |*z| {</span>
<span class="line" id="L274">                h.update(z);</span>
<span class="line" id="L275">            }</span>
<span class="line" id="L276">            h.update(&amp;key_pair.blind_secret_key.prefix);</span>
<span class="line" id="L277">            h.update(msg);</span>
<span class="line" id="L278">            <span class="tok-kw">var</span> nonce64: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L279">            h.final(&amp;nonce64);</span>
<span class="line" id="L280"></span>
<span class="line" id="L281">            <span class="tok-kw">const</span> nonce = Curve.scalar.reduce64(nonce64);</span>
<span class="line" id="L282">            <span class="tok-kw">const</span> r = <span class="tok-kw">try</span> Curve.basePoint.mul(nonce);</span>
<span class="line" id="L283"></span>
<span class="line" id="L284">            <span class="tok-kw">var</span> sig: [signature_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L285">            mem.copy(<span class="tok-type">u8</span>, sig[<span class="tok-number">0</span>..<span class="tok-number">32</span>], &amp;r.toBytes());</span>
<span class="line" id="L286">            mem.copy(<span class="tok-type">u8</span>, sig[<span class="tok-number">32</span>..], &amp;key_pair.blind_public_key);</span>
<span class="line" id="L287">            h = Sha512.init(.{});</span>
<span class="line" id="L288">            h.update(&amp;sig);</span>
<span class="line" id="L289">            h.update(msg);</span>
<span class="line" id="L290">            <span class="tok-kw">var</span> hram64: [Sha512.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L291">            h.final(&amp;hram64);</span>
<span class="line" id="L292">            <span class="tok-kw">const</span> hram = Curve.scalar.reduce64(hram64);</span>
<span class="line" id="L293"></span>
<span class="line" id="L294">            <span class="tok-kw">const</span> s = Curve.scalar.mulAdd(hram, key_pair.blind_secret_key.blind_scalar, nonce);</span>
<span class="line" id="L295">            mem.copy(<span class="tok-type">u8</span>, sig[<span class="tok-number">32</span>..], s[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L296">            <span class="tok-kw">return</span> sig;</span>
<span class="line" id="L297">        }</span>
<span class="line" id="L298"></span>
<span class="line" id="L299">        <span class="tok-comment">/// Compute a blind context from a blinding seed and a context.</span></span>
<span class="line" id="L300">        <span class="tok-kw">fn</span> <span class="tok-fn">blindCtx</span>(blind_seed: [blind_seed_length]<span class="tok-type">u8</span>, ctx: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) [Sha512.digest_length]<span class="tok-type">u8</span> {</span>
<span class="line" id="L301">            <span class="tok-kw">var</span> blind_h: [Sha512.digest_length]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L302">            <span class="tok-kw">var</span> hx = Sha512.init(.{});</span>
<span class="line" id="L303">            hx.update(&amp;blind_seed);</span>
<span class="line" id="L304">            hx.update(&amp;[<span class="tok-number">1</span>]<span class="tok-type">u8</span>{<span class="tok-number">0</span>});</span>
<span class="line" id="L305">            hx.update(ctx);</span>
<span class="line" id="L306">            hx.final(&amp;blind_h);</span>
<span class="line" id="L307">            <span class="tok-kw">return</span> blind_h;</span>
<span class="line" id="L308">        }</span>
<span class="line" id="L309">    };</span>
<span class="line" id="L310">};</span>
<span class="line" id="L311"></span>
<span class="line" id="L312"><span class="tok-kw">test</span> <span class="tok-str">&quot;ed25519 key pair creation&quot;</span> {</span>
<span class="line" id="L313">    <span class="tok-kw">var</span> seed: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L314">    _ = <span class="tok-kw">try</span> fmt.hexToBytes(seed[<span class="tok-number">0</span>..], <span class="tok-str">&quot;8052030376d47112be7f73ed7a019293dd12ad910b654455798b4667d73de166&quot;</span>);</span>
<span class="line" id="L315">    <span class="tok-kw">const</span> key_pair = <span class="tok-kw">try</span> Ed25519.KeyPair.create(seed);</span>
<span class="line" id="L316">    <span class="tok-kw">var</span> buf: [<span class="tok-number">256</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L317">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-kw">try</span> std.fmt.bufPrint(&amp;buf, <span class="tok-str">&quot;{s}&quot;</span>, .{std.fmt.fmtSliceHexUpper(&amp;key_pair.secret_key)}), <span class="tok-str">&quot;8052030376D47112BE7F73ED7A019293DD12AD910B654455798B4667D73DE1662D6F7455D97B4A3A10D7293909D1A4F2058CB9A370E43FA8154BB280DB839083&quot;</span>);</span>
<span class="line" id="L318">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-kw">try</span> std.fmt.bufPrint(&amp;buf, <span class="tok-str">&quot;{s}&quot;</span>, .{std.fmt.fmtSliceHexUpper(&amp;key_pair.public_key)}), <span class="tok-str">&quot;2D6F7455D97B4A3A10D7293909D1A4F2058CB9A370E43FA8154BB280DB839083&quot;</span>);</span>
<span class="line" id="L319">}</span>
<span class="line" id="L320"></span>
<span class="line" id="L321"><span class="tok-kw">test</span> <span class="tok-str">&quot;ed25519 signature&quot;</span> {</span>
<span class="line" id="L322">    <span class="tok-kw">var</span> seed: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L323">    _ = <span class="tok-kw">try</span> fmt.hexToBytes(seed[<span class="tok-number">0</span>..], <span class="tok-str">&quot;8052030376d47112be7f73ed7a019293dd12ad910b654455798b4667d73de166&quot;</span>);</span>
<span class="line" id="L324">    <span class="tok-kw">const</span> key_pair = <span class="tok-kw">try</span> Ed25519.KeyPair.create(seed);</span>
<span class="line" id="L325"></span>
<span class="line" id="L326">    <span class="tok-kw">const</span> sig = <span class="tok-kw">try</span> Ed25519.sign(<span class="tok-str">&quot;test&quot;</span>, key_pair, <span class="tok-null">null</span>);</span>
<span class="line" id="L327">    <span class="tok-kw">var</span> buf: [<span class="tok-number">128</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L328">    <span class="tok-kw">try</span> std.testing.expectEqualStrings(<span class="tok-kw">try</span> std.fmt.bufPrint(&amp;buf, <span class="tok-str">&quot;{s}&quot;</span>, .{std.fmt.fmtSliceHexUpper(&amp;sig)}), <span class="tok-str">&quot;10A442B4A80CC4225B154F43BEF28D2472CA80221951262EB8E0DF9091575E2687CC486E77263C3418C757522D54F84B0359236ABBBD4ACD20DC297FDCA66808&quot;</span>);</span>
<span class="line" id="L329">    <span class="tok-kw">try</span> Ed25519.verify(sig, <span class="tok-str">&quot;test&quot;</span>, key_pair.public_key);</span>
<span class="line" id="L330">    <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.SignatureVerificationFailed, Ed25519.verify(sig, <span class="tok-str">&quot;TEST&quot;</span>, key_pair.public_key));</span>
<span class="line" id="L331">}</span>
<span class="line" id="L332"></span>
<span class="line" id="L333"><span class="tok-kw">test</span> <span class="tok-str">&quot;ed25519 batch verification&quot;</span> {</span>
<span class="line" id="L334">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L335">    <span class="tok-kw">while</span> (i &lt; <span class="tok-number">100</span>) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L336">        <span class="tok-kw">const</span> key_pair = <span class="tok-kw">try</span> Ed25519.KeyPair.create(<span class="tok-null">null</span>);</span>
<span class="line" id="L337">        <span class="tok-kw">var</span> msg1: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L338">        <span class="tok-kw">var</span> msg2: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L339">        crypto.random.bytes(&amp;msg1);</span>
<span class="line" id="L340">        crypto.random.bytes(&amp;msg2);</span>
<span class="line" id="L341">        <span class="tok-kw">const</span> sig1 = <span class="tok-kw">try</span> Ed25519.sign(&amp;msg1, key_pair, <span class="tok-null">null</span>);</span>
<span class="line" id="L342">        <span class="tok-kw">const</span> sig2 = <span class="tok-kw">try</span> Ed25519.sign(&amp;msg2, key_pair, <span class="tok-null">null</span>);</span>
<span class="line" id="L343">        <span class="tok-kw">var</span> signature_batch = [_]Ed25519.BatchElement{</span>
<span class="line" id="L344">            Ed25519.BatchElement{</span>
<span class="line" id="L345">                .sig = sig1,</span>
<span class="line" id="L346">                .msg = &amp;msg1,</span>
<span class="line" id="L347">                .public_key = key_pair.public_key,</span>
<span class="line" id="L348">            },</span>
<span class="line" id="L349">            Ed25519.BatchElement{</span>
<span class="line" id="L350">                .sig = sig2,</span>
<span class="line" id="L351">                .msg = &amp;msg2,</span>
<span class="line" id="L352">                .public_key = key_pair.public_key,</span>
<span class="line" id="L353">            },</span>
<span class="line" id="L354">        };</span>
<span class="line" id="L355">        <span class="tok-kw">try</span> Ed25519.verifyBatch(<span class="tok-number">2</span>, signature_batch);</span>
<span class="line" id="L356"></span>
<span class="line" id="L357">        signature_batch[<span class="tok-number">1</span>].sig = sig1;</span>
<span class="line" id="L358">        <span class="tok-comment">// TODO https://github.com/ziglang/zig/issues/12240</span>
</span>
<span class="line" id="L359">        <span class="tok-kw">const</span> sig_len = signature_batch.len;</span>
<span class="line" id="L360">        <span class="tok-kw">try</span> std.testing.expectError(<span class="tok-kw">error</span>.SignatureVerificationFailed, Ed25519.verifyBatch(sig_len, signature_batch));</span>
<span class="line" id="L361">    }</span>
<span class="line" id="L362">}</span>
<span class="line" id="L363"></span>
<span class="line" id="L364"><span class="tok-kw">test</span> <span class="tok-str">&quot;ed25519 test vectors&quot;</span> {</span>
<span class="line" id="L365">    <span class="tok-kw">const</span> Vec = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L366">        msg_hex: *<span class="tok-kw">const</span> [<span class="tok-number">64</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L367">        public_key_hex: *<span class="tok-kw">const</span> [<span class="tok-number">64</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L368">        sig_hex: *<span class="tok-kw">const</span> [<span class="tok-number">128</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L369">        expected: ?<span class="tok-type">anyerror</span>,</span>
<span class="line" id="L370">    };</span>
<span class="line" id="L371"></span>
<span class="line" id="L372">    <span class="tok-kw">const</span> entries = [_]Vec{</span>
<span class="line" id="L373">        Vec{</span>
<span class="line" id="L374">            .msg_hex = <span class="tok-str">&quot;8c93255d71dcab10e8f379c26200f3c7bd5f09d9bc3068d3ef4edeb4853022b6&quot;</span>,</span>
<span class="line" id="L375">            .public_key_hex = <span class="tok-str">&quot;c7176a703d4dd84fba3c0b760d10670f2a2053fa2c39ccc64ec7fd7792ac03fa&quot;</span>,</span>
<span class="line" id="L376">            .sig_hex = <span class="tok-str">&quot;c7176a703d4dd84fba3c0b760d10670f2a2053fa2c39ccc64ec7fd7792ac037a0000000000000000000000000000000000000000000000000000000000000000&quot;</span>,</span>
<span class="line" id="L377">            .expected = <span class="tok-kw">error</span>.WeakPublicKey, <span class="tok-comment">// 0</span>
</span>
<span class="line" id="L378">        },</span>
<span class="line" id="L379">        Vec{</span>
<span class="line" id="L380">            .msg_hex = <span class="tok-str">&quot;9bd9f44f4dcc75bd531b56b2cd280b0bb38fc1cd6d1230e14861d861de092e79&quot;</span>,</span>
<span class="line" id="L381">            .public_key_hex = <span class="tok-str">&quot;c7176a703d4dd84fba3c0b760d10670f2a2053fa2c39ccc64ec7fd7792ac03fa&quot;</span>,</span>
<span class="line" id="L382">            .sig_hex = <span class="tok-str">&quot;f7badec5b8abeaf699583992219b7b223f1df3fbbea919844e3f7c554a43dd43a5bb704786be79fc476f91d3f3f89b03984d8068dcf1bb7dfc6637b45450ac04&quot;</span>,</span>
<span class="line" id="L383">            .expected = <span class="tok-kw">error</span>.WeakPublicKey, <span class="tok-comment">// 1</span>
</span>
<span class="line" id="L384">        },</span>
<span class="line" id="L385">        Vec{</span>
<span class="line" id="L386">            .msg_hex = <span class="tok-str">&quot;aebf3f2601a0c8c5d39cc7d8911642f740b78168218da8471772b35f9d35b9ab&quot;</span>,</span>
<span class="line" id="L387">            .public_key_hex = <span class="tok-str">&quot;f7badec5b8abeaf699583992219b7b223f1df3fbbea919844e3f7c554a43dd43&quot;</span>,</span>
<span class="line" id="L388">            .sig_hex = <span class="tok-str">&quot;c7176a703d4dd84fba3c0b760d10670f2a2053fa2c39ccc64ec7fd7792ac03fa8c4bd45aecaca5b24fb97bc10ac27ac8751a7dfe1baff8b953ec9f5833ca260e&quot;</span>,</span>
<span class="line" id="L389">            .expected = <span class="tok-null">null</span>, <span class="tok-comment">// 2 - small order R is acceptable</span>
</span>
<span class="line" id="L390">        },</span>
<span class="line" id="L391">        Vec{</span>
<span class="line" id="L392">            .msg_hex = <span class="tok-str">&quot;9bd9f44f4dcc75bd531b56b2cd280b0bb38fc1cd6d1230e14861d861de092e79&quot;</span>,</span>
<span class="line" id="L393">            .public_key_hex = <span class="tok-str">&quot;cdb267ce40c5cd45306fa5d2f29731459387dbf9eb933b7bd5aed9a765b88d4d&quot;</span>,</span>
<span class="line" id="L394">            .sig_hex = <span class="tok-str">&quot;9046a64750444938de19f227bb80485e92b83fdb4b6506c160484c016cc1852f87909e14428a7a1d62e9f22f3d3ad7802db02eb2e688b6c52fcd6648a98bd009&quot;</span>,</span>
<span class="line" id="L395">            .expected = <span class="tok-null">null</span>, <span class="tok-comment">// 3 - mixed orders</span>
</span>
<span class="line" id="L396">        },</span>
<span class="line" id="L397">        Vec{</span>
<span class="line" id="L398">            .msg_hex = <span class="tok-str">&quot;e47d62c63f830dc7a6851a0b1f33ae4bb2f507fb6cffec4011eaccd55b53f56c&quot;</span>,</span>
<span class="line" id="L399">            .public_key_hex = <span class="tok-str">&quot;cdb267ce40c5cd45306fa5d2f29731459387dbf9eb933b7bd5aed9a765b88d4d&quot;</span>,</span>
<span class="line" id="L400">            .sig_hex = <span class="tok-str">&quot;160a1cb0dc9c0258cd0a7d23e94d8fa878bcb1925f2c64246b2dee1796bed5125ec6bc982a269b723e0668e540911a9a6a58921d6925e434ab10aa7940551a09&quot;</span>,</span>
<span class="line" id="L401">            .expected = <span class="tok-null">null</span>, <span class="tok-comment">// 4 - cofactored verification</span>
</span>
<span class="line" id="L402">        },</span>
<span class="line" id="L403">        Vec{</span>
<span class="line" id="L404">            .msg_hex = <span class="tok-str">&quot;e47d62c63f830dc7a6851a0b1f33ae4bb2f507fb6cffec4011eaccd55b53f56c&quot;</span>,</span>
<span class="line" id="L405">            .public_key_hex = <span class="tok-str">&quot;cdb267ce40c5cd45306fa5d2f29731459387dbf9eb933b7bd5aed9a765b88d4d&quot;</span>,</span>
<span class="line" id="L406">            .sig_hex = <span class="tok-str">&quot;21122a84e0b5fca4052f5b1235c80a537878b38f3142356b2c2384ebad4668b7e40bc836dac0f71076f9abe3a53f9c03c1ceeeddb658d0030494ace586687405&quot;</span>,</span>
<span class="line" id="L407">            .expected = <span class="tok-null">null</span>, <span class="tok-comment">// 5 - cofactored verification</span>
</span>
<span class="line" id="L408">        },</span>
<span class="line" id="L409">        Vec{</span>
<span class="line" id="L410">            .msg_hex = <span class="tok-str">&quot;85e241a07d148b41e47d62c63f830dc7a6851a0b1f33ae4bb2f507fb6cffec40&quot;</span>,</span>
<span class="line" id="L411">            .public_key_hex = <span class="tok-str">&quot;442aad9f089ad9e14647b1ef9099a1ff4798d78589e66f28eca69c11f582a623&quot;</span>,</span>
<span class="line" id="L412">            .sig_hex = <span class="tok-str">&quot;e96f66be976d82e60150baecff9906684aebb1ef181f67a7189ac78ea23b6c0e547f7690a0e2ddcd04d87dbc3490dc19b3b3052f7ff0538cb68afb369ba3a514&quot;</span>,</span>
<span class="line" id="L413">            .expected = <span class="tok-kw">error</span>.NonCanonical, <span class="tok-comment">// 6 - S &gt; L</span>
</span>
<span class="line" id="L414">        },</span>
<span class="line" id="L415">        Vec{</span>
<span class="line" id="L416">            .msg_hex = <span class="tok-str">&quot;85e241a07d148b41e47d62c63f830dc7a6851a0b1f33ae4bb2f507fb6cffec40&quot;</span>,</span>
<span class="line" id="L417">            .public_key_hex = <span class="tok-str">&quot;442aad9f089ad9e14647b1ef9099a1ff4798d78589e66f28eca69c11f582a623&quot;</span>,</span>
<span class="line" id="L418">            .sig_hex = <span class="tok-str">&quot;8ce5b96c8f26d0ab6c47958c9e68b937104cd36e13c33566acd2fe8d38aa19427e71f98a4734e74f2f13f06f97c20d58cc3f54b8bd0d272f42b695dd7e89a8c2&quot;</span>,</span>
<span class="line" id="L419">            .expected = <span class="tok-kw">error</span>.NonCanonical, <span class="tok-comment">// 7 - S &gt;&gt; L</span>
</span>
<span class="line" id="L420">        },</span>
<span class="line" id="L421">        Vec{</span>
<span class="line" id="L422">            .msg_hex = <span class="tok-str">&quot;9bedc267423725d473888631ebf45988bad3db83851ee85c85e241a07d148b41&quot;</span>,</span>
<span class="line" id="L423">            .public_key_hex = <span class="tok-str">&quot;f7badec5b8abeaf699583992219b7b223f1df3fbbea919844e3f7c554a43dd43&quot;</span>,</span>
<span class="line" id="L424">            .sig_hex = <span class="tok-str">&quot;ecffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff03be9678ac102edcd92b0210bb34d7428d12ffc5df5f37e359941266a4e35f0f&quot;</span>,</span>
<span class="line" id="L425">            .expected = <span class="tok-kw">error</span>.IdentityElement, <span class="tok-comment">// 8 - non-canonical R</span>
</span>
<span class="line" id="L426">        },</span>
<span class="line" id="L427">        Vec{</span>
<span class="line" id="L428">            .msg_hex = <span class="tok-str">&quot;9bedc267423725d473888631ebf45988bad3db83851ee85c85e241a07d148b41&quot;</span>,</span>
<span class="line" id="L429">            .public_key_hex = <span class="tok-str">&quot;f7badec5b8abeaf699583992219b7b223f1df3fbbea919844e3f7c554a43dd43&quot;</span>,</span>
<span class="line" id="L430">            .sig_hex = <span class="tok-str">&quot;ecffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffca8c5b64cd208982aa38d4936621a4775aa233aa0505711d8fdcfdaa943d4908&quot;</span>,</span>
<span class="line" id="L431">            .expected = <span class="tok-kw">error</span>.IdentityElement, <span class="tok-comment">// 9 - non-canonical R</span>
</span>
<span class="line" id="L432">        },</span>
<span class="line" id="L433">        Vec{</span>
<span class="line" id="L434">            .msg_hex = <span class="tok-str">&quot;e96b7021eb39c1a163b6da4e3093dcd3f21387da4cc4572be588fafae23c155b&quot;</span>,</span>
<span class="line" id="L435">            .public_key_hex = <span class="tok-str">&quot;ecffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff&quot;</span>,</span>
<span class="line" id="L436">            .sig_hex = <span class="tok-str">&quot;a9d55260f765261eb9b84e106f665e00b867287a761990d7135963ee0a7d59dca5bb704786be79fc476f91d3f3f89b03984d8068dcf1bb7dfc6637b45450ac04&quot;</span>,</span>
<span class="line" id="L437">            .expected = <span class="tok-kw">error</span>.IdentityElement, <span class="tok-comment">// 10 - small-order A</span>
</span>
<span class="line" id="L438">        },</span>
<span class="line" id="L439">        Vec{</span>
<span class="line" id="L440">            .msg_hex = <span class="tok-str">&quot;39a591f5321bbe07fd5a23dc2f39d025d74526615746727ceefd6e82ae65c06f&quot;</span>,</span>
<span class="line" id="L441">            .public_key_hex = <span class="tok-str">&quot;ecffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff&quot;</span>,</span>
<span class="line" id="L442">            .sig_hex = <span class="tok-str">&quot;a9d55260f765261eb9b84e106f665e00b867287a761990d7135963ee0a7d59dca5bb704786be79fc476f91d3f3f89b03984d8068dcf1bb7dfc6637b45450ac04&quot;</span>,</span>
<span class="line" id="L443">            .expected = <span class="tok-kw">error</span>.IdentityElement, <span class="tok-comment">// 11 - small-order A</span>
</span>
<span class="line" id="L444">        },</span>
<span class="line" id="L445">    };</span>
<span class="line" id="L446">    <span class="tok-kw">for</span> (entries) |entry| {</span>
<span class="line" id="L447">        <span class="tok-kw">var</span> msg: [entry.msg_hex.len / <span class="tok-number">2</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L448">        _ = <span class="tok-kw">try</span> fmt.hexToBytes(&amp;msg, entry.msg_hex);</span>
<span class="line" id="L449">        <span class="tok-kw">var</span> public_key: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L450">        _ = <span class="tok-kw">try</span> fmt.hexToBytes(&amp;public_key, entry.public_key_hex);</span>
<span class="line" id="L451">        <span class="tok-kw">var</span> sig: [<span class="tok-number">64</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L452">        _ = <span class="tok-kw">try</span> fmt.hexToBytes(&amp;sig, entry.sig_hex);</span>
<span class="line" id="L453">        <span class="tok-kw">if</span> (entry.expected) |error_type| {</span>
<span class="line" id="L454">            <span class="tok-kw">try</span> std.testing.expectError(error_type, Ed25519.verify(sig, &amp;msg, public_key));</span>
<span class="line" id="L455">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L456">            <span class="tok-kw">try</span> Ed25519.verify(sig, &amp;msg, public_key);</span>
<span class="line" id="L457">        }</span>
<span class="line" id="L458">    }</span>
<span class="line" id="L459">}</span>
<span class="line" id="L460"></span>
<span class="line" id="L461"><span class="tok-kw">test</span> <span class="tok-str">&quot;ed25519 with blind keys&quot;</span> {</span>
<span class="line" id="L462">    <span class="tok-kw">const</span> BlindKeySignatures = Ed25519.BlindKeySignatures;</span>
<span class="line" id="L463"></span>
<span class="line" id="L464">    <span class="tok-comment">// Create a standard Ed25519 key pair</span>
</span>
<span class="line" id="L465">    <span class="tok-kw">const</span> kp = <span class="tok-kw">try</span> Ed25519.KeyPair.create(<span class="tok-null">null</span>);</span>
<span class="line" id="L466"></span>
<span class="line" id="L467">    <span class="tok-comment">// Create a random blinding seed</span>
</span>
<span class="line" id="L468">    <span class="tok-kw">var</span> blind: [<span class="tok-number">32</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L469">    crypto.random.bytes(&amp;blind);</span>
<span class="line" id="L470"></span>
<span class="line" id="L471">    <span class="tok-comment">// Blind the key pair</span>
</span>
<span class="line" id="L472">    <span class="tok-kw">const</span> blind_kp = <span class="tok-kw">try</span> BlindKeySignatures.blind(kp, blind, <span class="tok-str">&quot;ctx&quot;</span>);</span>
<span class="line" id="L473"></span>
<span class="line" id="L474">    <span class="tok-comment">// Sign a message and check that it can be verified with the blind public key</span>
</span>
<span class="line" id="L475">    <span class="tok-kw">const</span> msg = <span class="tok-str">&quot;test&quot;</span>;</span>
<span class="line" id="L476">    <span class="tok-kw">const</span> sig = <span class="tok-kw">try</span> BlindKeySignatures.sign(msg, blind_kp, <span class="tok-null">null</span>);</span>
<span class="line" id="L477">    <span class="tok-kw">try</span> Ed25519.verify(sig, msg, blind_kp.blind_public_key);</span>
<span class="line" id="L478"></span>
<span class="line" id="L479">    <span class="tok-comment">// Unblind the public key</span>
</span>
<span class="line" id="L480">    <span class="tok-kw">const</span> pk = <span class="tok-kw">try</span> BlindKeySignatures.unblindPublicKey(blind_kp.blind_public_key, blind, <span class="tok-str">&quot;ctx&quot;</span>);</span>
<span class="line" id="L481">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>, &amp;pk, &amp;kp.public_key);</span>
<span class="line" id="L482">}</span>
<span class="line" id="L483"></span>
</code></pre></body>
</html>