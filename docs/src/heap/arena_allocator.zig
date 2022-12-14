<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>heap/arena_allocator.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-comment">/// This allocator takes an existing allocator, wraps it, and provides an interface</span></span>
<span class="line" id="L7"><span class="tok-comment">/// where you can allocate without freeing, and then free it all together.</span></span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ArenaAllocator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L9">    child_allocator: Allocator,</span>
<span class="line" id="L10">    state: State,</span>
<span class="line" id="L11"></span>
<span class="line" id="L12">    <span class="tok-comment">/// Inner state of ArenaAllocator. Can be stored rather than the entire ArenaAllocator</span></span>
<span class="line" id="L13">    <span class="tok-comment">/// as a memory-saving optimization.</span></span>
<span class="line" id="L14">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> State = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L15">        buffer_list: std.SinglyLinkedList([]<span class="tok-type">u8</span>) = <span class="tok-builtin">@as</span>(std.SinglyLinkedList([]<span class="tok-type">u8</span>), .{}),</span>
<span class="line" id="L16">        end_index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L17"></span>
<span class="line" id="L18">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">promote</span>(self: State, child_allocator: Allocator) ArenaAllocator {</span>
<span class="line" id="L19">            <span class="tok-kw">return</span> .{</span>
<span class="line" id="L20">                .child_allocator = child_allocator,</span>
<span class="line" id="L21">                .state = self,</span>
<span class="line" id="L22">            };</span>
<span class="line" id="L23">        }</span>
<span class="line" id="L24">    };</span>
<span class="line" id="L25"></span>
<span class="line" id="L26">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">allocator</span>(self: *ArenaAllocator) Allocator {</span>
<span class="line" id="L27">        <span class="tok-kw">return</span> Allocator.init(self, alloc, resize, free);</span>
<span class="line" id="L28">    }</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">    <span class="tok-kw">const</span> BufNode = std.SinglyLinkedList([]<span class="tok-type">u8</span>).Node;</span>
<span class="line" id="L31"></span>
<span class="line" id="L32">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(child_allocator: Allocator) ArenaAllocator {</span>
<span class="line" id="L33">        <span class="tok-kw">return</span> (State{}).promote(child_allocator);</span>
<span class="line" id="L34">    }</span>
<span class="line" id="L35"></span>
<span class="line" id="L36">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: ArenaAllocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L37">        <span class="tok-kw">var</span> it = self.state.buffer_list.first;</span>
<span class="line" id="L38">        <span class="tok-kw">while</span> (it) |node| {</span>
<span class="line" id="L39">            <span class="tok-comment">// this has to occur before the free because the free frees node</span>
</span>
<span class="line" id="L40">            <span class="tok-kw">const</span> next_it = node.next;</span>
<span class="line" id="L41">            self.child_allocator.free(node.data);</span>
<span class="line" id="L42">            it = next_it;</span>
<span class="line" id="L43">        }</span>
<span class="line" id="L44">    }</span>
<span class="line" id="L45"></span>
<span class="line" id="L46">    <span class="tok-kw">fn</span> <span class="tok-fn">createNode</span>(self: *ArenaAllocator, prev_len: <span class="tok-type">usize</span>, minimum_size: <span class="tok-type">usize</span>) !*BufNode {</span>
<span class="line" id="L47">        <span class="tok-kw">const</span> actual_min_size = minimum_size + (<span class="tok-builtin">@sizeOf</span>(BufNode) + <span class="tok-number">16</span>);</span>
<span class="line" id="L48">        <span class="tok-kw">const</span> big_enough_len = prev_len + actual_min_size;</span>
<span class="line" id="L49">        <span class="tok-kw">const</span> len = big_enough_len + big_enough_len / <span class="tok-number">2</span>;</span>
<span class="line" id="L50">        <span class="tok-kw">const</span> buf = <span class="tok-kw">try</span> self.child_allocator.rawAlloc(len, <span class="tok-builtin">@alignOf</span>(BufNode), <span class="tok-number">1</span>, <span class="tok-builtin">@returnAddress</span>());</span>
<span class="line" id="L51">        <span class="tok-kw">const</span> buf_node = <span class="tok-builtin">@ptrCast</span>(*BufNode, <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(BufNode), buf.ptr));</span>
<span class="line" id="L52">        buf_node.* = BufNode{</span>
<span class="line" id="L53">            .data = buf,</span>
<span class="line" id="L54">            .next = <span class="tok-null">null</span>,</span>
<span class="line" id="L55">        };</span>
<span class="line" id="L56">        self.state.buffer_list.prepend(buf_node);</span>
<span class="line" id="L57">        self.state.end_index = <span class="tok-number">0</span>;</span>
<span class="line" id="L58">        <span class="tok-kw">return</span> buf_node;</span>
<span class="line" id="L59">    }</span>
<span class="line" id="L60"></span>
<span class="line" id="L61">    <span class="tok-kw">fn</span> <span class="tok-fn">alloc</span>(self: *ArenaAllocator, n: <span class="tok-type">usize</span>, ptr_align: <span class="tok-type">u29</span>, len_align: <span class="tok-type">u29</span>, ra: <span class="tok-type">usize</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L62">        _ = len_align;</span>
<span class="line" id="L63">        _ = ra;</span>
<span class="line" id="L64"></span>
<span class="line" id="L65">        <span class="tok-kw">var</span> cur_node = <span class="tok-kw">if</span> (self.state.buffer_list.first) |first_node| first_node <span class="tok-kw">else</span> <span class="tok-kw">try</span> self.createNode(<span class="tok-number">0</span>, n + ptr_align);</span>
<span class="line" id="L66">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L67">            <span class="tok-kw">const</span> cur_buf = cur_node.data[<span class="tok-builtin">@sizeOf</span>(BufNode)..];</span>
<span class="line" id="L68">            <span class="tok-kw">const</span> addr = <span class="tok-builtin">@ptrToInt</span>(cur_buf.ptr) + self.state.end_index;</span>
<span class="line" id="L69">            <span class="tok-kw">const</span> adjusted_addr = mem.alignForward(addr, ptr_align);</span>
<span class="line" id="L70">            <span class="tok-kw">const</span> adjusted_index = self.state.end_index + (adjusted_addr - addr);</span>
<span class="line" id="L71">            <span class="tok-kw">const</span> new_end_index = adjusted_index + n;</span>
<span class="line" id="L72"></span>
<span class="line" id="L73">            <span class="tok-kw">if</span> (new_end_index &lt;= cur_buf.len) {</span>
<span class="line" id="L74">                <span class="tok-kw">const</span> result = cur_buf[adjusted_index..new_end_index];</span>
<span class="line" id="L75">                self.state.end_index = new_end_index;</span>
<span class="line" id="L76">                <span class="tok-kw">return</span> result;</span>
<span class="line" id="L77">            }</span>
<span class="line" id="L78"></span>
<span class="line" id="L79">            <span class="tok-kw">const</span> bigger_buf_size = <span class="tok-builtin">@sizeOf</span>(BufNode) + new_end_index;</span>
<span class="line" id="L80">            <span class="tok-comment">// Try to grow the buffer in-place</span>
</span>
<span class="line" id="L81">            cur_node.data = self.child_allocator.resize(cur_node.data, bigger_buf_size) <span class="tok-kw">orelse</span> {</span>
<span class="line" id="L82">                <span class="tok-comment">// Allocate a new node if that's not possible</span>
</span>
<span class="line" id="L83">                cur_node = <span class="tok-kw">try</span> self.createNode(cur_buf.len, n + ptr_align);</span>
<span class="line" id="L84">                <span class="tok-kw">continue</span>;</span>
<span class="line" id="L85">            };</span>
<span class="line" id="L86">        }</span>
<span class="line" id="L87">    }</span>
<span class="line" id="L88"></span>
<span class="line" id="L89">    <span class="tok-kw">fn</span> <span class="tok-fn">resize</span>(self: *ArenaAllocator, buf: []<span class="tok-type">u8</span>, buf_align: <span class="tok-type">u29</span>, new_len: <span class="tok-type">usize</span>, len_align: <span class="tok-type">u29</span>, ret_addr: <span class="tok-type">usize</span>) ?<span class="tok-type">usize</span> {</span>
<span class="line" id="L90">        _ = buf_align;</span>
<span class="line" id="L91">        _ = len_align;</span>
<span class="line" id="L92">        _ = ret_addr;</span>
<span class="line" id="L93"></span>
<span class="line" id="L94">        <span class="tok-kw">const</span> cur_node = self.state.buffer_list.first <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L95">        <span class="tok-kw">const</span> cur_buf = cur_node.data[<span class="tok-builtin">@sizeOf</span>(BufNode)..];</span>
<span class="line" id="L96">        <span class="tok-kw">if</span> (<span class="tok-builtin">@ptrToInt</span>(cur_buf.ptr) + self.state.end_index != <span class="tok-builtin">@ptrToInt</span>(buf.ptr) + buf.len) {</span>
<span class="line" id="L97">            <span class="tok-kw">if</span> (new_len &gt; buf.len) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L98">            <span class="tok-kw">return</span> new_len;</span>
<span class="line" id="L99">        }</span>
<span class="line" id="L100"></span>
<span class="line" id="L101">        <span class="tok-kw">if</span> (buf.len &gt;= new_len) {</span>
<span class="line" id="L102">            self.state.end_index -= buf.len - new_len;</span>
<span class="line" id="L103">            <span class="tok-kw">return</span> new_len;</span>
<span class="line" id="L104">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (cur_buf.len - self.state.end_index &gt;= new_len - buf.len) {</span>
<span class="line" id="L105">            self.state.end_index += new_len - buf.len;</span>
<span class="line" id="L106">            <span class="tok-kw">return</span> new_len;</span>
<span class="line" id="L107">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L108">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L109">        }</span>
<span class="line" id="L110">    }</span>
<span class="line" id="L111"></span>
<span class="line" id="L112">    <span class="tok-kw">fn</span> <span class="tok-fn">free</span>(self: *ArenaAllocator, buf: []<span class="tok-type">u8</span>, buf_align: <span class="tok-type">u29</span>, ret_addr: <span class="tok-type">usize</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L113">        _ = buf_align;</span>
<span class="line" id="L114">        _ = ret_addr;</span>
<span class="line" id="L115"></span>
<span class="line" id="L116">        <span class="tok-kw">const</span> cur_node = self.state.buffer_list.first <span class="tok-kw">orelse</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L117">        <span class="tok-kw">const</span> cur_buf = cur_node.data[<span class="tok-builtin">@sizeOf</span>(BufNode)..];</span>
<span class="line" id="L118"></span>
<span class="line" id="L119">        <span class="tok-kw">if</span> (<span class="tok-builtin">@ptrToInt</span>(cur_buf.ptr) + self.state.end_index == <span class="tok-builtin">@ptrToInt</span>(buf.ptr) + buf.len) {</span>
<span class="line" id="L120">            self.state.end_index -= buf.len;</span>
<span class="line" id="L121">        }</span>
<span class="line" id="L122">    }</span>
<span class="line" id="L123">};</span>
<span class="line" id="L124"></span>
</code></pre></body>
</html>