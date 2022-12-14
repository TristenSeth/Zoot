<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>mmio.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">/// A register can be read or written, but may have different behavior or characteristics depending on which</span></span>
<span class="line" id="L2"><span class="tok-comment">/// you choose to do. This allows us to instantiate Register instances that</span></span>
<span class="line" id="L3"><span class="tok-comment">/// can handle that fact by having distinct read and write types.</span></span>
<span class="line" id="L4"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">Register</span>(<span class="tok-kw">comptime</span> Read: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> Write: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L5"></span>
<span class="line" id="L6">    <span class="tok-comment">// does not make sense to try and make a register that cannot be read from</span>
</span>
<span class="line" id="L7">    <span class="tok-comment">// or written to, so raise a compile error to let the programmer know.</span>
</span>
<span class="line" id="L8">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L9">        <span class="tok-kw">if</span> (Read == <span class="tok-type">void</span> <span class="tok-kw">and</span> Write == <span class="tok-type">void</span>) {</span>
<span class="line" id="L10">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot have register that cannot be read or written.&quot;</span>);</span>
<span class="line" id="L11">        }</span>
<span class="line" id="L12">    }</span>
<span class="line" id="L13"></span>
<span class="line" id="L14">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L15">        <span class="tok-comment">// mark the ptr as volatile so the compiler wont</span>
</span>
<span class="line" id="L16">        <span class="tok-comment">// reorder reads/writes</span>
</span>
<span class="line" id="L17">        raw_ptr: *<span class="tok-kw">volatile</span> <span class="tok-type">u32</span> = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L18"></span>
<span class="line" id="L19">        <span class="tok-comment">// The type being returned inside this function doesnt have a name</span>
</span>
<span class="line" id="L20">        <span class="tok-comment">// yet when its being created, so we have to refer to it using</span>
</span>
<span class="line" id="L21">        <span class="tok-comment">// '@This()'</span>
</span>
<span class="line" id="L22">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">        <span class="tok-comment">// Since we are representing MMIO here, the addr of a register should be</span>
</span>
<span class="line" id="L25">        <span class="tok-comment">// known at compile time. This will complain if we try to pass it an</span>
</span>
<span class="line" id="L26">        <span class="tok-comment">// addr only known at runtime.</span>
</span>
<span class="line" id="L27">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(<span class="tok-kw">comptime</span> addr: <span class="tok-type">u32</span>) Self {</span>
<span class="line" id="L28">            <span class="tok-comment">// check if we are trying to make a register from the null addr</span>
</span>
<span class="line" id="L29">            <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L30">                <span class="tok-kw">if</span> (addr == <span class="tok-number">0</span>) {</span>
<span class="line" id="L31">                    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot assign address 0 as a register.&quot;</span>);</span>
<span class="line" id="L32">                }</span>
<span class="line" id="L33">            }</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">            <span class="tok-kw">return</span> .{</span>
<span class="line" id="L36">                .raw_ptr = <span class="tok-builtin">@intToPtr</span>(*<span class="tok-kw">volatile</span> <span class="tok-type">u32</span>, addr),</span>
<span class="line" id="L37">            };</span>
<span class="line" id="L38">        }</span>
<span class="line" id="L39"></span>
<span class="line" id="L40">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read_raw</span>(self: Self) <span class="tok-type">u32</span> {</span>
<span class="line" id="L41">            <span class="tok-comment">// Can give a register a void read type to prevent reads to</span>
</span>
<span class="line" id="L42">            <span class="tok-comment">// a write only register. This will raise a compiler error to the</span>
</span>
<span class="line" id="L43">            <span class="tok-comment">// developer if they try to read after setting the register as</span>
</span>
<span class="line" id="L44">            <span class="tok-comment">// Write only.</span>
</span>
<span class="line" id="L45">            <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L46">                <span class="tok-kw">if</span> (Read == <span class="tok-type">void</span>) {</span>
<span class="line" id="L47">                    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot read from write-only register.&quot;</span>);</span>
<span class="line" id="L48">                }</span>
<span class="line" id="L49">            }</span>
<span class="line" id="L50">            <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, self.raw_ptr.*);</span>
<span class="line" id="L51">        }</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">write_raw</span>(self: Self, val: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L54">            <span class="tok-comment">// can give a register a void write type to prevent writes</span>
</span>
<span class="line" id="L55">            <span class="tok-comment">// to a read only register</span>
</span>
<span class="line" id="L56">            <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L57">                <span class="tok-kw">if</span> (Write == <span class="tok-type">void</span>) {</span>
<span class="line" id="L58">                    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot write to read-only register.&quot;</span>);</span>
<span class="line" id="L59">                }</span>
<span class="line" id="L60">            }</span>
<span class="line" id="L61">            self.raw_ptr.* = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, val);</span>
<span class="line" id="L62">        }</span>
<span class="line" id="L63"></span>
<span class="line" id="L64">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">read</span>(self: Self) Read {</span>
<span class="line" id="L65">            <span class="tok-comment">// Can give a register a void read type to prevent reads to</span>
</span>
<span class="line" id="L66">            <span class="tok-comment">// a write only register</span>
</span>
<span class="line" id="L67">            <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L68">                <span class="tok-kw">if</span> (Read == <span class="tok-type">void</span>) {</span>
<span class="line" id="L69">                    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot read from write-only register.&quot;</span>);</span>
<span class="line" id="L70">                }</span>
<span class="line" id="L71">            }</span>
<span class="line" id="L72">            <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(Read, self.raw_ptr.*);</span>
<span class="line" id="L73">        }</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: Self, val: Write) <span class="tok-type">void</span> {</span>
<span class="line" id="L76">            <span class="tok-comment">// can give a register a void write type to prevent writes</span>
</span>
<span class="line" id="L77">            <span class="tok-comment">// to a read only register</span>
</span>
<span class="line" id="L78">            <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L79">                <span class="tok-kw">if</span> (Write == <span class="tok-type">void</span>) {</span>
<span class="line" id="L80">                    <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot write to read-only register.&quot;</span>);</span>
<span class="line" id="L81">                }</span>
<span class="line" id="L82">            }</span>
<span class="line" id="L83"></span>
<span class="line" id="L84">            <span class="tok-comment">// cast to u32 here because thats what the underlying ptr is expecting</span>
</span>
<span class="line" id="L85">            self.raw_ptr.* = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, val);</span>
<span class="line" id="L86">        }</span>
<span class="line" id="L87"></span>
<span class="line" id="L88">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">modify</span>(self: Self, new_val: Write) <span class="tok-type">void</span> {</span>
<span class="line" id="L89">            <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L90">                <span class="tok-kw">if</span> (Read != Write) {</span>
<span class="line" id="L91">                    <span class="tok-builtin">@compileError</span>(</span>
<span class="line" id="L92">                        <span class="tok-str">\\Can't modify register b/c read and write types for </span></span>

<span class="line" id="L93">                        <span class="tok-str">\\this register aren't the same</span></span>

<span class="line" id="L94">                    );</span>
<span class="line" id="L95">                }</span>
<span class="line" id="L96">            }</span>
<span class="line" id="L97">            <span class="tok-kw">var</span> old_val = self.read();</span>
<span class="line" id="L98">            self.write(old_val | new_val);</span>
<span class="line" id="L99">        }</span>
<span class="line" id="L100">    };</span>
<span class="line" id="L101">}</span>
<span class="line" id="L102"></span>
</code></pre></body>
</html>