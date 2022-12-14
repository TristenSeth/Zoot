<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>Thread/RwLock.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! A lock that supports one writer or many readers.</span></span>
<span class="line" id="L2"><span class="tok-comment">//! This API is for kernel threads, not evented I/O.</span></span>
<span class="line" id="L3"><span class="tok-comment">//! This API requires being initialized at runtime, and initialization</span></span>
<span class="line" id="L4"><span class="tok-comment">//! can fail. Once initialized, the core operations cannot fail.</span></span>
<span class="line" id="L5"></span>
<span class="line" id="L6">impl: Impl = .{},</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-kw">const</span> RwLock = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L9"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L10"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L11"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L12"></span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Impl = <span class="tok-kw">if</span> (builtin.single_threaded)</span>
<span class="line" id="L14">    SingleThreadedRwLock</span>
<span class="line" id="L15"><span class="tok-kw">else</span> <span class="tok-kw">if</span> (std.Thread.use_pthreads)</span>
<span class="line" id="L16">    PthreadRwLock</span>
<span class="line" id="L17"><span class="tok-kw">else</span></span>
<span class="line" id="L18">    DefaultRwLock;</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-comment">/// Attempts to obtain exclusive lock ownership.</span></span>
<span class="line" id="L21"><span class="tok-comment">/// Returns `true` if the lock is obtained, `false` otherwise.</span></span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tryLock</span>(rwl: *RwLock) <span class="tok-type">bool</span> {</span>
<span class="line" id="L23">    <span class="tok-kw">return</span> rwl.impl.tryLock();</span>
<span class="line" id="L24">}</span>
<span class="line" id="L25"></span>
<span class="line" id="L26"><span class="tok-comment">/// Blocks until exclusive lock ownership is acquired.</span></span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lock</span>(rwl: *RwLock) <span class="tok-type">void</span> {</span>
<span class="line" id="L28">    <span class="tok-kw">return</span> rwl.impl.lock();</span>
<span class="line" id="L29">}</span>
<span class="line" id="L30"></span>
<span class="line" id="L31"><span class="tok-comment">/// Releases a held exclusive lock.</span></span>
<span class="line" id="L32"><span class="tok-comment">/// Asserts the lock is held exclusively.</span></span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlock</span>(rwl: *RwLock) <span class="tok-type">void</span> {</span>
<span class="line" id="L34">    <span class="tok-kw">return</span> rwl.impl.unlock();</span>
<span class="line" id="L35">}</span>
<span class="line" id="L36"></span>
<span class="line" id="L37"><span class="tok-comment">/// Attempts to obtain shared lock ownership.</span></span>
<span class="line" id="L38"><span class="tok-comment">/// Returns `true` if the lock is obtained, `false` otherwise.</span></span>
<span class="line" id="L39"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tryLockShared</span>(rwl: *RwLock) <span class="tok-type">bool</span> {</span>
<span class="line" id="L40">    <span class="tok-kw">return</span> rwl.impl.tryLockShared();</span>
<span class="line" id="L41">}</span>
<span class="line" id="L42"></span>
<span class="line" id="L43"><span class="tok-comment">/// Blocks until shared lock ownership is acquired.</span></span>
<span class="line" id="L44"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lockShared</span>(rwl: *RwLock) <span class="tok-type">void</span> {</span>
<span class="line" id="L45">    <span class="tok-kw">return</span> rwl.impl.lockShared();</span>
<span class="line" id="L46">}</span>
<span class="line" id="L47"></span>
<span class="line" id="L48"><span class="tok-comment">/// Releases a held shared lock.</span></span>
<span class="line" id="L49"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlockShared</span>(rwl: *RwLock) <span class="tok-type">void</span> {</span>
<span class="line" id="L50">    <span class="tok-kw">return</span> rwl.impl.unlockShared();</span>
<span class="line" id="L51">}</span>
<span class="line" id="L52"></span>
<span class="line" id="L53"><span class="tok-comment">/// Single-threaded applications use this for deadlock checks in</span></span>
<span class="line" id="L54"><span class="tok-comment">/// debug mode, and no-ops in release modes.</span></span>
<span class="line" id="L55"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SingleThreadedRwLock = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L56">    state: <span class="tok-kw">enum</span> { unlocked, locked_exclusive, locked_shared } = .unlocked,</span>
<span class="line" id="L57">    shared_count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L58"></span>
<span class="line" id="L59">    <span class="tok-comment">/// Attempts to obtain exclusive lock ownership.</span></span>
<span class="line" id="L60">    <span class="tok-comment">/// Returns `true` if the lock is obtained, `false` otherwise.</span></span>
<span class="line" id="L61">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tryLock</span>(rwl: *SingleThreadedRwLock) <span class="tok-type">bool</span> {</span>
<span class="line" id="L62">        <span class="tok-kw">switch</span> (rwl.state) {</span>
<span class="line" id="L63">            .unlocked =&gt; {</span>
<span class="line" id="L64">                assert(rwl.shared_count == <span class="tok-number">0</span>);</span>
<span class="line" id="L65">                rwl.state = .locked_exclusive;</span>
<span class="line" id="L66">                <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L67">            },</span>
<span class="line" id="L68">            .locked_exclusive, .locked_shared =&gt; <span class="tok-kw">return</span> <span class="tok-null">false</span>,</span>
<span class="line" id="L69">        }</span>
<span class="line" id="L70">    }</span>
<span class="line" id="L71"></span>
<span class="line" id="L72">    <span class="tok-comment">/// Blocks until exclusive lock ownership is acquired.</span></span>
<span class="line" id="L73">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lock</span>(rwl: *SingleThreadedRwLock) <span class="tok-type">void</span> {</span>
<span class="line" id="L74">        assert(rwl.state == .unlocked); <span class="tok-comment">// deadlock detected</span>
</span>
<span class="line" id="L75">        assert(rwl.shared_count == <span class="tok-number">0</span>); <span class="tok-comment">// corrupted state detected</span>
</span>
<span class="line" id="L76">        rwl.state = .locked_exclusive;</span>
<span class="line" id="L77">    }</span>
<span class="line" id="L78"></span>
<span class="line" id="L79">    <span class="tok-comment">/// Releases a held exclusive lock.</span></span>
<span class="line" id="L80">    <span class="tok-comment">/// Asserts the lock is held exclusively.</span></span>
<span class="line" id="L81">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlock</span>(rwl: *SingleThreadedRwLock) <span class="tok-type">void</span> {</span>
<span class="line" id="L82">        assert(rwl.state == .locked_exclusive);</span>
<span class="line" id="L83">        assert(rwl.shared_count == <span class="tok-number">0</span>); <span class="tok-comment">// corrupted state detected</span>
</span>
<span class="line" id="L84">        rwl.state = .unlocked;</span>
<span class="line" id="L85">    }</span>
<span class="line" id="L86"></span>
<span class="line" id="L87">    <span class="tok-comment">/// Attempts to obtain shared lock ownership.</span></span>
<span class="line" id="L88">    <span class="tok-comment">/// Returns `true` if the lock is obtained, `false` otherwise.</span></span>
<span class="line" id="L89">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tryLockShared</span>(rwl: *SingleThreadedRwLock) <span class="tok-type">bool</span> {</span>
<span class="line" id="L90">        <span class="tok-kw">switch</span> (rwl.state) {</span>
<span class="line" id="L91">            .unlocked =&gt; {</span>
<span class="line" id="L92">                rwl.state = .locked_shared;</span>
<span class="line" id="L93">                assert(rwl.shared_count == <span class="tok-number">0</span>);</span>
<span class="line" id="L94">                rwl.shared_count = <span class="tok-number">1</span>;</span>
<span class="line" id="L95">                <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L96">            },</span>
<span class="line" id="L97">            .locked_exclusive, .locked_shared =&gt; <span class="tok-kw">return</span> <span class="tok-null">false</span>,</span>
<span class="line" id="L98">        }</span>
<span class="line" id="L99">    }</span>
<span class="line" id="L100"></span>
<span class="line" id="L101">    <span class="tok-comment">/// Blocks until shared lock ownership is acquired.</span></span>
<span class="line" id="L102">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lockShared</span>(rwl: *SingleThreadedRwLock) <span class="tok-type">void</span> {</span>
<span class="line" id="L103">        <span class="tok-kw">switch</span> (rwl.state) {</span>
<span class="line" id="L104">            .unlocked =&gt; {</span>
<span class="line" id="L105">                rwl.state = .locked_shared;</span>
<span class="line" id="L106">                assert(rwl.shared_count == <span class="tok-number">0</span>);</span>
<span class="line" id="L107">                rwl.shared_count = <span class="tok-number">1</span>;</span>
<span class="line" id="L108">            },</span>
<span class="line" id="L109">            .locked_shared =&gt; {</span>
<span class="line" id="L110">                rwl.shared_count += <span class="tok-number">1</span>;</span>
<span class="line" id="L111">            },</span>
<span class="line" id="L112">            .locked_exclusive =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// deadlock detected</span>
</span>
<span class="line" id="L113">        }</span>
<span class="line" id="L114">    }</span>
<span class="line" id="L115"></span>
<span class="line" id="L116">    <span class="tok-comment">/// Releases a held shared lock.</span></span>
<span class="line" id="L117">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlockShared</span>(rwl: *SingleThreadedRwLock) <span class="tok-type">void</span> {</span>
<span class="line" id="L118">        <span class="tok-kw">switch</span> (rwl.state) {</span>
<span class="line" id="L119">            .unlocked =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// too many calls to `unlockShared`</span>
</span>
<span class="line" id="L120">            .locked_exclusive =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// exclusively held lock</span>
</span>
<span class="line" id="L121">            .locked_shared =&gt; {</span>
<span class="line" id="L122">                rwl.shared_count -= <span class="tok-number">1</span>;</span>
<span class="line" id="L123">                <span class="tok-kw">if</span> (rwl.shared_count == <span class="tok-number">0</span>) {</span>
<span class="line" id="L124">                    rwl.state = .unlocked;</span>
<span class="line" id="L125">                }</span>
<span class="line" id="L126">            },</span>
<span class="line" id="L127">        }</span>
<span class="line" id="L128">    }</span>
<span class="line" id="L129">};</span>
<span class="line" id="L130"></span>
<span class="line" id="L131"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PthreadRwLock = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L132">    rwlock: std.c.pthread_rwlock_t = .{},</span>
<span class="line" id="L133"></span>
<span class="line" id="L134">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tryLock</span>(rwl: *PthreadRwLock) <span class="tok-type">bool</span> {</span>
<span class="line" id="L135">        <span class="tok-kw">return</span> std.c.pthread_rwlock_trywrlock(&amp;rwl.rwlock) == .SUCCESS;</span>
<span class="line" id="L136">    }</span>
<span class="line" id="L137"></span>
<span class="line" id="L138">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lock</span>(rwl: *PthreadRwLock) <span class="tok-type">void</span> {</span>
<span class="line" id="L139">        <span class="tok-kw">const</span> rc = std.c.pthread_rwlock_wrlock(&amp;rwl.rwlock);</span>
<span class="line" id="L140">        assert(rc == .SUCCESS);</span>
<span class="line" id="L141">    }</span>
<span class="line" id="L142"></span>
<span class="line" id="L143">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlock</span>(rwl: *PthreadRwLock) <span class="tok-type">void</span> {</span>
<span class="line" id="L144">        <span class="tok-kw">const</span> rc = std.c.pthread_rwlock_unlock(&amp;rwl.rwlock);</span>
<span class="line" id="L145">        assert(rc == .SUCCESS);</span>
<span class="line" id="L146">    }</span>
<span class="line" id="L147"></span>
<span class="line" id="L148">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tryLockShared</span>(rwl: *PthreadRwLock) <span class="tok-type">bool</span> {</span>
<span class="line" id="L149">        <span class="tok-kw">return</span> std.c.pthread_rwlock_tryrdlock(&amp;rwl.rwlock) == .SUCCESS;</span>
<span class="line" id="L150">    }</span>
<span class="line" id="L151"></span>
<span class="line" id="L152">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lockShared</span>(rwl: *PthreadRwLock) <span class="tok-type">void</span> {</span>
<span class="line" id="L153">        <span class="tok-kw">const</span> rc = std.c.pthread_rwlock_rdlock(&amp;rwl.rwlock);</span>
<span class="line" id="L154">        assert(rc == .SUCCESS);</span>
<span class="line" id="L155">    }</span>
<span class="line" id="L156"></span>
<span class="line" id="L157">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlockShared</span>(rwl: *PthreadRwLock) <span class="tok-type">void</span> {</span>
<span class="line" id="L158">        <span class="tok-kw">const</span> rc = std.c.pthread_rwlock_unlock(&amp;rwl.rwlock);</span>
<span class="line" id="L159">        assert(rc == .SUCCESS);</span>
<span class="line" id="L160">    }</span>
<span class="line" id="L161">};</span>
<span class="line" id="L162"></span>
<span class="line" id="L163"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DefaultRwLock = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L164">    state: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L165">    mutex: std.Thread.Mutex = .{},</span>
<span class="line" id="L166">    semaphore: std.Thread.Semaphore = .{},</span>
<span class="line" id="L167"></span>
<span class="line" id="L168">    <span class="tok-kw">const</span> IS_WRITING: <span class="tok-type">usize</span> = <span class="tok-number">1</span>;</span>
<span class="line" id="L169">    <span class="tok-kw">const</span> WRITER: <span class="tok-type">usize</span> = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">1</span>;</span>
<span class="line" id="L170">    <span class="tok-kw">const</span> READER: <span class="tok-type">usize</span> = <span class="tok-number">1</span> &lt;&lt; (<span class="tok-number">1</span> + <span class="tok-builtin">@bitSizeOf</span>(Count));</span>
<span class="line" id="L171">    <span class="tok-kw">const</span> WRITER_MASK: <span class="tok-type">usize</span> = std.math.maxInt(Count) &lt;&lt; <span class="tok-builtin">@ctz</span>(<span class="tok-type">usize</span>, WRITER);</span>
<span class="line" id="L172">    <span class="tok-kw">const</span> READER_MASK: <span class="tok-type">usize</span> = std.math.maxInt(Count) &lt;&lt; <span class="tok-builtin">@ctz</span>(<span class="tok-type">usize</span>, READER);</span>
<span class="line" id="L173">    <span class="tok-kw">const</span> Count = std.meta.Int(.unsigned, <span class="tok-builtin">@divFloor</span>(<span class="tok-builtin">@bitSizeOf</span>(<span class="tok-type">usize</span>) - <span class="tok-number">1</span>, <span class="tok-number">2</span>));</span>
<span class="line" id="L174"></span>
<span class="line" id="L175">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tryLock</span>(rwl: *DefaultRwLock) <span class="tok-type">bool</span> {</span>
<span class="line" id="L176">        <span class="tok-kw">if</span> (rwl.mutex.tryLock()) {</span>
<span class="line" id="L177">            <span class="tok-kw">const</span> state = <span class="tok-builtin">@atomicLoad</span>(<span class="tok-type">usize</span>, &amp;rwl.state, .SeqCst);</span>
<span class="line" id="L178">            <span class="tok-kw">if</span> (state &amp; READER_MASK == <span class="tok-number">0</span>) {</span>
<span class="line" id="L179">                _ = <span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">usize</span>, &amp;rwl.state, .Or, IS_WRITING, .SeqCst);</span>
<span class="line" id="L180">                <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L181">            }</span>
<span class="line" id="L182"></span>
<span class="line" id="L183">            rwl.mutex.unlock();</span>
<span class="line" id="L184">        }</span>
<span class="line" id="L185"></span>
<span class="line" id="L186">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L187">    }</span>
<span class="line" id="L188"></span>
<span class="line" id="L189">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lock</span>(rwl: *DefaultRwLock) <span class="tok-type">void</span> {</span>
<span class="line" id="L190">        _ = <span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">usize</span>, &amp;rwl.state, .Add, WRITER, .SeqCst);</span>
<span class="line" id="L191">        rwl.mutex.lock();</span>
<span class="line" id="L192"></span>
<span class="line" id="L193">        <span class="tok-kw">const</span> state = <span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">usize</span>, &amp;rwl.state, .Or, IS_WRITING, .SeqCst);</span>
<span class="line" id="L194">        <span class="tok-kw">if</span> (state &amp; READER_MASK != <span class="tok-number">0</span>)</span>
<span class="line" id="L195">            rwl.semaphore.wait();</span>
<span class="line" id="L196">    }</span>
<span class="line" id="L197"></span>
<span class="line" id="L198">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlock</span>(rwl: *DefaultRwLock) <span class="tok-type">void</span> {</span>
<span class="line" id="L199">        _ = <span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">usize</span>, &amp;rwl.state, .And, ~IS_WRITING, .SeqCst);</span>
<span class="line" id="L200">        rwl.mutex.unlock();</span>
<span class="line" id="L201">    }</span>
<span class="line" id="L202"></span>
<span class="line" id="L203">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">tryLockShared</span>(rwl: *DefaultRwLock) <span class="tok-type">bool</span> {</span>
<span class="line" id="L204">        <span class="tok-kw">const</span> state = <span class="tok-builtin">@atomicLoad</span>(<span class="tok-type">usize</span>, &amp;rwl.state, .SeqCst);</span>
<span class="line" id="L205">        <span class="tok-kw">if</span> (state &amp; (IS_WRITING | WRITER_MASK) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L206">            _ = <span class="tok-builtin">@cmpxchgStrong</span>(</span>
<span class="line" id="L207">                <span class="tok-type">usize</span>,</span>
<span class="line" id="L208">                &amp;rwl.state,</span>
<span class="line" id="L209">                state,</span>
<span class="line" id="L210">                state + READER,</span>
<span class="line" id="L211">                .SeqCst,</span>
<span class="line" id="L212">                .SeqCst,</span>
<span class="line" id="L213">            ) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L214">        }</span>
<span class="line" id="L215"></span>
<span class="line" id="L216">        <span class="tok-kw">if</span> (rwl.mutex.tryLock()) {</span>
<span class="line" id="L217">            _ = <span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">usize</span>, &amp;rwl.state, .Add, READER, .SeqCst);</span>
<span class="line" id="L218">            rwl.mutex.unlock();</span>
<span class="line" id="L219">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L220">        }</span>
<span class="line" id="L221"></span>
<span class="line" id="L222">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L223">    }</span>
<span class="line" id="L224"></span>
<span class="line" id="L225">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lockShared</span>(rwl: *DefaultRwLock) <span class="tok-type">void</span> {</span>
<span class="line" id="L226">        <span class="tok-kw">var</span> state = <span class="tok-builtin">@atomicLoad</span>(<span class="tok-type">usize</span>, &amp;rwl.state, .SeqCst);</span>
<span class="line" id="L227">        <span class="tok-kw">while</span> (state &amp; (IS_WRITING | WRITER_MASK) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L228">            state = <span class="tok-builtin">@cmpxchgWeak</span>(</span>
<span class="line" id="L229">                <span class="tok-type">usize</span>,</span>
<span class="line" id="L230">                &amp;rwl.state,</span>
<span class="line" id="L231">                state,</span>
<span class="line" id="L232">                state + READER,</span>
<span class="line" id="L233">                .SeqCst,</span>
<span class="line" id="L234">                .SeqCst,</span>
<span class="line" id="L235">            ) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span>;</span>
<span class="line" id="L236">        }</span>
<span class="line" id="L237"></span>
<span class="line" id="L238">        rwl.mutex.lock();</span>
<span class="line" id="L239">        _ = <span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">usize</span>, &amp;rwl.state, .Add, READER, .SeqCst);</span>
<span class="line" id="L240">        rwl.mutex.unlock();</span>
<span class="line" id="L241">    }</span>
<span class="line" id="L242"></span>
<span class="line" id="L243">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">unlockShared</span>(rwl: *DefaultRwLock) <span class="tok-type">void</span> {</span>
<span class="line" id="L244">        <span class="tok-kw">const</span> state = <span class="tok-builtin">@atomicRmw</span>(<span class="tok-type">usize</span>, &amp;rwl.state, .Sub, READER, .SeqCst);</span>
<span class="line" id="L245"></span>
<span class="line" id="L246">        <span class="tok-kw">if</span> ((state &amp; READER_MASK == READER) <span class="tok-kw">and</span> (state &amp; IS_WRITING != <span class="tok-number">0</span>))</span>
<span class="line" id="L247">            rwl.semaphore.post();</span>
<span class="line" id="L248">    }</span>
<span class="line" id="L249">};</span>
<span class="line" id="L250"></span>
</code></pre></body>
</html>