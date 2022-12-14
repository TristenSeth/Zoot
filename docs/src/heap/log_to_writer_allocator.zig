<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>heap/log_to_writer_allocator.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-comment">/// This allocator is used in front of another allocator and logs to the provided writer</span></span>
<span class="line" id="L5"><span class="tok-comment">/// on every call to the allocator. Writer errors are ignored.</span></span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">LogToWriterAllocator</span>(<span class="tok-kw">comptime</span> Writer: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L7">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L8">        parent_allocator: Allocator,</span>
<span class="line" id="L9">        writer: Writer,</span>
<span class="line" id="L10"></span>
<span class="line" id="L11">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L12"></span>
<span class="line" id="L13">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(parent_allocator: Allocator, writer: Writer) Self {</span>
<span class="line" id="L14">            <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L15">                .parent_allocator = parent_allocator,</span>
<span class="line" id="L16">                .writer = writer,</span>
<span class="line" id="L17">            };</span>
<span class="line" id="L18">        }</span>
<span class="line" id="L19"></span>
<span class="line" id="L20">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocator</span>(self: *Self) Allocator {</span>
<span class="line" id="L21">            <span class="tok-kw">return</span> Allocator.init(self, alloc, resize, free);</span>
<span class="line" id="L22">        }</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">        <span class="tok-kw">fn</span> <span class="tok-fn">alloc</span>(</span>
<span class="line" id="L25">            self: *Self,</span>
<span class="line" id="L26">            len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L27">            ptr_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L28">            len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L29">            ra: <span class="tok-type">usize</span>,</span>
<span class="line" id="L30">        ) <span class="tok-kw">error</span>{OutOfMemory}![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L31">            self.writer.print(<span class="tok-str">&quot;alloc : {}&quot;</span>, .{len}) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L32">            <span class="tok-kw">const</span> result = self.parent_allocator.rawAlloc(len, ptr_align, len_align, ra);</span>
<span class="line" id="L33">            <span class="tok-kw">if</span> (result) |_| {</span>
<span class="line" id="L34">                self.writer.print(<span class="tok-str">&quot; success!\n&quot;</span>, .{}) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L35">            } <span class="tok-kw">else</span> |_| {</span>
<span class="line" id="L36">                self.writer.print(<span class="tok-str">&quot; failure!\n&quot;</span>, .{}) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L37">            }</span>
<span class="line" id="L38">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L39">        }</span>
<span class="line" id="L40"></span>
<span class="line" id="L41">        <span class="tok-kw">fn</span> <span class="tok-fn">resize</span>(</span>
<span class="line" id="L42">            self: *Self,</span>
<span class="line" id="L43">            buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L44">            buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L45">            new_len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L46">            len_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L47">            ra: <span class="tok-type">usize</span>,</span>
<span class="line" id="L48">        ) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L49">            <span class="tok-kw">if</span> (new_len &lt;= buf.len) {</span>
<span class="line" id="L50">                self.writer.print(<span class="tok-str">&quot;shrink: {} to {}\n&quot;</span>, .{ buf.len, new_len }) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L51">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L52">                self.writer.print(<span class="tok-str">&quot;expand: {} to {}&quot;</span>, .{ buf.len, new_len }) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L53">            }</span>
<span class="line" id="L54"></span>
<span class="line" id="L55">            <span class="tok-kw">if</span> (self.parent_allocator.rawResize(buf, buf_align, new_len, len_align, ra)) |resized_len| {</span>
<span class="line" id="L56">                <span class="tok-kw">if</span> (new_len &gt; buf.len) {</span>
<span class="line" id="L57">                    self.writer.print(<span class="tok-str">&quot; success!\n&quot;</span>, .{}) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L58">                }</span>
<span class="line" id="L59">                <span class="tok-kw">return</span> resized_len;</span>
<span class="line" id="L60">            }</span>
<span class="line" id="L61"></span>
<span class="line" id="L62">            std.debug.assert(new_len &gt; buf.len);</span>
<span class="line" id="L63">            self.writer.print(<span class="tok-str">&quot; failure!\n&quot;</span>, .{}) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L64">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L65">        }</span>
<span class="line" id="L66"></span>
<span class="line" id="L67">        <span class="tok-kw">fn</span> <span class="tok-fn">free</span>(</span>
<span class="line" id="L68">            self: *Self,</span>
<span class="line" id="L69">            buf: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L70">            buf_align: <span class="tok-type">u29</span>,</span>
<span class="line" id="L71">            ra: <span class="tok-type">usize</span>,</span>
<span class="line" id="L72">        ) <span class="tok-type">void</span> {</span>
<span class="line" id="L73">            self.writer.print(<span class="tok-str">&quot;free  : {}\n&quot;</span>, .{buf.len}) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L74">            self.parent_allocator.rawFree(buf, buf_align, ra);</span>
<span class="line" id="L75">        }</span>
<span class="line" id="L76">    };</span>
<span class="line" id="L77">}</span>
<span class="line" id="L78"></span>
<span class="line" id="L79"><span class="tok-comment">/// This allocator is used in front of another allocator and logs to the provided writer</span></span>
<span class="line" id="L80"><span class="tok-comment">/// on every call to the allocator. Writer errors are ignored.</span></span>
<span class="line" id="L81"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">logToWriterAllocator</span>(</span>
<span class="line" id="L82">    parent_allocator: Allocator,</span>
<span class="line" id="L83">    writer: <span class="tok-kw">anytype</span>,</span>
<span class="line" id="L84">) LogToWriterAllocator(<span class="tok-builtin">@TypeOf</span>(writer)) {</span>
<span class="line" id="L85">    <span class="tok-kw">return</span> LogToWriterAllocator(<span class="tok-builtin">@TypeOf</span>(writer)).init(parent_allocator, writer);</span>
<span class="line" id="L86">}</span>
<span class="line" id="L87"></span>
<span class="line" id="L88"><span class="tok-kw">test</span> <span class="tok-str">&quot;LogToWriterAllocator&quot;</span> {</span>
<span class="line" id="L89">    <span class="tok-kw">var</span> log_buf: [<span class="tok-number">255</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L90">    <span class="tok-kw">var</span> fbs = std.io.fixedBufferStream(&amp;log_buf);</span>
<span class="line" id="L91"></span>
<span class="line" id="L92">    <span class="tok-kw">var</span> allocator_buf: [<span class="tok-number">10</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L93">    <span class="tok-kw">var</span> fixedBufferAllocator = std.mem.validationWrap(std.heap.FixedBufferAllocator.init(&amp;allocator_buf));</span>
<span class="line" id="L94">    <span class="tok-kw">var</span> allocator_state = logToWriterAllocator(fixedBufferAllocator.allocator(), fbs.writer());</span>
<span class="line" id="L95">    <span class="tok-kw">const</span> allocator = allocator_state.allocator();</span>
<span class="line" id="L96"></span>
<span class="line" id="L97">    <span class="tok-kw">var</span> a = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, <span class="tok-number">10</span>);</span>
<span class="line" id="L98">    a = allocator.shrink(a, <span class="tok-number">5</span>);</span>
<span class="line" id="L99">    <span class="tok-kw">try</span> std.testing.expect(a.len == <span class="tok-number">5</span>);</span>
<span class="line" id="L100">    <span class="tok-kw">try</span> std.testing.expect(allocator.resize(a, <span class="tok-number">20</span>) == <span class="tok-null">null</span>);</span>
<span class="line" id="L101">    allocator.free(a);</span>
<span class="line" id="L102"></span>
<span class="line" id="L103">    <span class="tok-kw">try</span> std.testing.expectEqualSlices(<span class="tok-type">u8</span>,</span>
<span class="line" id="L104">        <span class="tok-str">\\alloc : 10 success!</span></span>

<span class="line" id="L105">        <span class="tok-str">\\shrink: 10 to 5</span></span>

<span class="line" id="L106">        <span class="tok-str">\\expand: 5 to 20 failure!</span></span>

<span class="line" id="L107">        <span class="tok-str">\\free  : 5</span></span>

<span class="line" id="L108">        <span class="tok-str">\\</span></span>

<span class="line" id="L109">    , fbs.getWritten());</span>
<span class="line" id="L110">}</span>
<span class="line" id="L111"></span>
</code></pre></body>
</html>