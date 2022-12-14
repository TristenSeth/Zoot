<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>child_process.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std.zig&quot;</span>);</span>
<span class="line" id="L2"><span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> cstr = std.cstr;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> unicode = std.unicode;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> fs = std.fs;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> process = std.process;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> File = std.fs.File;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> windows = os.windows;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> linux = os.linux;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> debug = std.debug;</span>
<span class="line" id="L15"><span class="tok-kw">const</span> EnvMap = process.EnvMap;</span>
<span class="line" id="L16"><span class="tok-kw">const</span> Os = std.builtin.Os;</span>
<span class="line" id="L17"><span class="tok-kw">const</span> TailQueue = std.TailQueue;</span>
<span class="line" id="L18"><span class="tok-kw">const</span> maxInt = std.math.maxInt;</span>
<span class="line" id="L19"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L20"></span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ChildProcess = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L22">    pid: <span class="tok-kw">if</span> (builtin.os.tag == .windows) <span class="tok-type">void</span> <span class="tok-kw">else</span> <span class="tok-type">i32</span>,</span>
<span class="line" id="L23">    handle: <span class="tok-kw">if</span> (builtin.os.tag == .windows) windows.HANDLE <span class="tok-kw">else</span> <span class="tok-type">void</span>,</span>
<span class="line" id="L24">    thread_handle: <span class="tok-kw">if</span> (builtin.os.tag == .windows) windows.HANDLE <span class="tok-kw">else</span> <span class="tok-type">void</span>,</span>
<span class="line" id="L25"></span>
<span class="line" id="L26">    allocator: mem.Allocator,</span>
<span class="line" id="L27"></span>
<span class="line" id="L28">    stdin: ?File,</span>
<span class="line" id="L29">    stdout: ?File,</span>
<span class="line" id="L30">    stderr: ?File,</span>
<span class="line" id="L31"></span>
<span class="line" id="L32">    term: ?(SpawnError!Term),</span>
<span class="line" id="L33"></span>
<span class="line" id="L34">    argv: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L35"></span>
<span class="line" id="L36">    <span class="tok-comment">/// Leave as null to use the current env map using the supplied allocator.</span></span>
<span class="line" id="L37">    env_map: ?*<span class="tok-kw">const</span> EnvMap,</span>
<span class="line" id="L38"></span>
<span class="line" id="L39">    stdin_behavior: StdIo,</span>
<span class="line" id="L40">    stdout_behavior: StdIo,</span>
<span class="line" id="L41">    stderr_behavior: StdIo,</span>
<span class="line" id="L42"></span>
<span class="line" id="L43">    <span class="tok-comment">/// Set to change the user id when spawning the child process.</span></span>
<span class="line" id="L44">    uid: <span class="tok-kw">if</span> (builtin.os.tag == .windows <span class="tok-kw">or</span> builtin.os.tag == .wasi) <span class="tok-type">void</span> <span class="tok-kw">else</span> ?os.uid_t,</span>
<span class="line" id="L45"></span>
<span class="line" id="L46">    <span class="tok-comment">/// Set to change the group id when spawning the child process.</span></span>
<span class="line" id="L47">    gid: <span class="tok-kw">if</span> (builtin.os.tag == .windows <span class="tok-kw">or</span> builtin.os.tag == .wasi) <span class="tok-type">void</span> <span class="tok-kw">else</span> ?os.gid_t,</span>
<span class="line" id="L48"></span>
<span class="line" id="L49">    <span class="tok-comment">/// Set to change the current working directory when spawning the child process.</span></span>
<span class="line" id="L50">    cwd: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L51">    <span class="tok-comment">/// Set to change the current working directory when spawning the child process.</span></span>
<span class="line" id="L52">    <span class="tok-comment">/// This is not yet implemented for Windows. See https://github.com/ziglang/zig/issues/5190</span></span>
<span class="line" id="L53">    <span class="tok-comment">/// Once that is done, `cwd` will be deprecated in favor of this field.</span></span>
<span class="line" id="L54">    cwd_dir: ?fs.Dir = <span class="tok-null">null</span>,</span>
<span class="line" id="L55"></span>
<span class="line" id="L56">    err_pipe: ?<span class="tok-kw">if</span> (builtin.os.tag == .windows) <span class="tok-type">void</span> <span class="tok-kw">else</span> [<span class="tok-number">2</span>]os.fd_t,</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">    expand_arg0: Arg0Expand,</span>
<span class="line" id="L59"></span>
<span class="line" id="L60">    <span class="tok-comment">/// Darwin-only. Disable ASLR for the child process.</span></span>
<span class="line" id="L61">    disable_aslr: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Arg0Expand = os.Arg0Expand;</span>
<span class="line" id="L64"></span>
<span class="line" id="L65">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SpawnError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L66">        OutOfMemory,</span>
<span class="line" id="L67"></span>
<span class="line" id="L68">        <span class="tok-comment">/// POSIX-only. `StdIo.Ignore` was selected and opening `/dev/null` returned ENODEV.</span></span>
<span class="line" id="L69">        NoDevice,</span>
<span class="line" id="L70"></span>
<span class="line" id="L71">        <span class="tok-comment">/// Windows-only. One of:</span></span>
<span class="line" id="L72">        <span class="tok-comment">/// * `cwd` was provided and it could not be re-encoded into UTF16LE, or</span></span>
<span class="line" id="L73">        <span class="tok-comment">/// * The `PATH` or `PATHEXT` environment variable contained invalid UTF-8.</span></span>
<span class="line" id="L74">        InvalidUtf8,</span>
<span class="line" id="L75"></span>
<span class="line" id="L76">        <span class="tok-comment">/// Windows-only. `cwd` was provided, but the path did not exist when spawning the child process.</span></span>
<span class="line" id="L77">        CurrentWorkingDirectoryUnlinked,</span>
<span class="line" id="L78">    } ||</span>
<span class="line" id="L79">        os.ExecveError ||</span>
<span class="line" id="L80">        os.SetIdError ||</span>
<span class="line" id="L81">        os.ChangeCurDirError ||</span>
<span class="line" id="L82">        windows.CreateProcessError ||</span>
<span class="line" id="L83">        windows.WaitForSingleObjectError ||</span>
<span class="line" id="L84">        os.posix_spawn.Error;</span>
<span class="line" id="L85"></span>
<span class="line" id="L86">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Term = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L87">        Exited: <span class="tok-type">u8</span>,</span>
<span class="line" id="L88">        Signal: <span class="tok-type">u32</span>,</span>
<span class="line" id="L89">        Stopped: <span class="tok-type">u32</span>,</span>
<span class="line" id="L90">        Unknown: <span class="tok-type">u32</span>,</span>
<span class="line" id="L91">    };</span>
<span class="line" id="L92"></span>
<span class="line" id="L93">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> StdIo = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L94">        Inherit,</span>
<span class="line" id="L95">        Ignore,</span>
<span class="line" id="L96">        Pipe,</span>
<span class="line" id="L97">        Close,</span>
<span class="line" id="L98">    };</span>
<span class="line" id="L99"></span>
<span class="line" id="L100">    <span class="tok-comment">/// First argument in argv is the executable.</span></span>
<span class="line" id="L101">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(argv: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, allocator: mem.Allocator) ChildProcess {</span>
<span class="line" id="L102">        <span class="tok-kw">return</span> .{</span>
<span class="line" id="L103">            .allocator = allocator,</span>
<span class="line" id="L104">            .argv = argv,</span>
<span class="line" id="L105">            .pid = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L106">            .handle = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L107">            .thread_handle = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L108">            .err_pipe = <span class="tok-null">null</span>,</span>
<span class="line" id="L109">            .term = <span class="tok-null">null</span>,</span>
<span class="line" id="L110">            .env_map = <span class="tok-null">null</span>,</span>
<span class="line" id="L111">            .cwd = <span class="tok-null">null</span>,</span>
<span class="line" id="L112">            .uid = <span class="tok-kw">if</span> (builtin.os.tag == .windows <span class="tok-kw">or</span> builtin.os.tag == .wasi) {} <span class="tok-kw">else</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L113">            .gid = <span class="tok-kw">if</span> (builtin.os.tag == .windows <span class="tok-kw">or</span> builtin.os.tag == .wasi) {} <span class="tok-kw">else</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L114">            .stdin = <span class="tok-null">null</span>,</span>
<span class="line" id="L115">            .stdout = <span class="tok-null">null</span>,</span>
<span class="line" id="L116">            .stderr = <span class="tok-null">null</span>,</span>
<span class="line" id="L117">            .stdin_behavior = StdIo.Inherit,</span>
<span class="line" id="L118">            .stdout_behavior = StdIo.Inherit,</span>
<span class="line" id="L119">            .stderr_behavior = StdIo.Inherit,</span>
<span class="line" id="L120">            .expand_arg0 = .no_expand,</span>
<span class="line" id="L121">        };</span>
<span class="line" id="L122">    }</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setUserName</span>(self: *ChildProcess, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L125">        <span class="tok-kw">const</span> user_info = <span class="tok-kw">try</span> os.getUserInfo(name);</span>
<span class="line" id="L126">        self.uid = user_info.uid;</span>
<span class="line" id="L127">        self.gid = user_info.gid;</span>
<span class="line" id="L128">    }</span>
<span class="line" id="L129"></span>
<span class="line" id="L130">    <span class="tok-comment">/// On success must call `kill` or `wait`.</span></span>
<span class="line" id="L131">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">spawn</span>(self: *ChildProcess) SpawnError!<span class="tok-type">void</span> {</span>
<span class="line" id="L132">        <span class="tok-kw">if</span> (!std.process.can_spawn) {</span>
<span class="line" id="L133">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;the target operating system cannot spawn processes&quot;</span>);</span>
<span class="line" id="L134">        }</span>
<span class="line" id="L135"></span>
<span class="line" id="L136">        <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> builtin.target.isDarwin()) {</span>
<span class="line" id="L137">            <span class="tok-kw">return</span> self.spawnMacos();</span>
<span class="line" id="L138">        }</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L141">            <span class="tok-kw">return</span> self.spawnWindows();</span>
<span class="line" id="L142">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L143">            <span class="tok-kw">return</span> self.spawnPosix();</span>
<span class="line" id="L144">        }</span>
<span class="line" id="L145">    }</span>
<span class="line" id="L146"></span>
<span class="line" id="L147">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">spawnAndWait</span>(self: *ChildProcess) SpawnError!Term {</span>
<span class="line" id="L148">        <span class="tok-kw">try</span> self.spawn();</span>
<span class="line" id="L149">        <span class="tok-kw">return</span> self.wait();</span>
<span class="line" id="L150">    }</span>
<span class="line" id="L151"></span>
<span class="line" id="L152">    <span class="tok-comment">/// Forcibly terminates child process and then cleans up all resources.</span></span>
<span class="line" id="L153">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">kill</span>(self: *ChildProcess) !Term {</span>
<span class="line" id="L154">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L155">            <span class="tok-kw">return</span> self.killWindows(<span class="tok-number">1</span>);</span>
<span class="line" id="L156">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L157">            <span class="tok-kw">return</span> self.killPosix();</span>
<span class="line" id="L158">        }</span>
<span class="line" id="L159">    }</span>
<span class="line" id="L160"></span>
<span class="line" id="L161">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">killWindows</span>(self: *ChildProcess, exit_code: windows.UINT) !Term {</span>
<span class="line" id="L162">        <span class="tok-kw">if</span> (self.term) |term| {</span>
<span class="line" id="L163">            self.cleanupStreams();</span>
<span class="line" id="L164">            <span class="tok-kw">return</span> term;</span>
<span class="line" id="L165">        }</span>
<span class="line" id="L166"></span>
<span class="line" id="L167">        <span class="tok-kw">try</span> windows.TerminateProcess(self.handle, exit_code);</span>
<span class="line" id="L168">        <span class="tok-kw">try</span> self.waitUnwrappedWindows();</span>
<span class="line" id="L169">        <span class="tok-kw">return</span> self.term.?;</span>
<span class="line" id="L170">    }</span>
<span class="line" id="L171"></span>
<span class="line" id="L172">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">killPosix</span>(self: *ChildProcess) !Term {</span>
<span class="line" id="L173">        <span class="tok-kw">if</span> (self.term) |term| {</span>
<span class="line" id="L174">            self.cleanupStreams();</span>
<span class="line" id="L175">            <span class="tok-kw">return</span> term;</span>
<span class="line" id="L176">        }</span>
<span class="line" id="L177">        <span class="tok-kw">try</span> os.kill(self.pid, os.SIG.TERM);</span>
<span class="line" id="L178">        <span class="tok-kw">try</span> self.waitUnwrapped();</span>
<span class="line" id="L179">        <span class="tok-kw">return</span> self.term.?;</span>
<span class="line" id="L180">    }</span>
<span class="line" id="L181"></span>
<span class="line" id="L182">    <span class="tok-comment">/// Blocks until child process terminates and then cleans up all resources.</span></span>
<span class="line" id="L183">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">wait</span>(self: *ChildProcess) !Term {</span>
<span class="line" id="L184">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L185">            <span class="tok-kw">return</span> self.waitWindows();</span>
<span class="line" id="L186">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L187">            <span class="tok-kw">return</span> self.waitPosix();</span>
<span class="line" id="L188">        }</span>
<span class="line" id="L189">    }</span>
<span class="line" id="L190"></span>
<span class="line" id="L191">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ExecResult = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L192">        term: Term,</span>
<span class="line" id="L193">        stdout: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L194">        stderr: []<span class="tok-type">u8</span>,</span>
<span class="line" id="L195">    };</span>
<span class="line" id="L196"></span>
<span class="line" id="L197">    <span class="tok-kw">fn</span> <span class="tok-fn">collectOutputPosix</span>(</span>
<span class="line" id="L198">        child: ChildProcess,</span>
<span class="line" id="L199">        stdout: *std.ArrayList(<span class="tok-type">u8</span>),</span>
<span class="line" id="L200">        stderr: *std.ArrayList(<span class="tok-type">u8</span>),</span>
<span class="line" id="L201">        max_output_bytes: <span class="tok-type">usize</span>,</span>
<span class="line" id="L202">    ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L203">        <span class="tok-kw">var</span> poll_fds = [_]os.pollfd{</span>
<span class="line" id="L204">            .{ .fd = child.stdout.?.handle, .events = os.POLL.IN, .revents = <span class="tok-null">undefined</span> },</span>
<span class="line" id="L205">            .{ .fd = child.stderr.?.handle, .events = os.POLL.IN, .revents = <span class="tok-null">undefined</span> },</span>
<span class="line" id="L206">        };</span>
<span class="line" id="L207"></span>
<span class="line" id="L208">        <span class="tok-kw">var</span> dead_fds: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L209">        <span class="tok-comment">// We ask for ensureTotalCapacity with this much extra space. This has more of an</span>
</span>
<span class="line" id="L210">        <span class="tok-comment">// effect on small reads because once the reads start to get larger the amount</span>
</span>
<span class="line" id="L211">        <span class="tok-comment">// of space an ArrayList will allocate grows exponentially.</span>
</span>
<span class="line" id="L212">        <span class="tok-kw">const</span> bump_amt = <span class="tok-number">512</span>;</span>
<span class="line" id="L213"></span>
<span class="line" id="L214">        <span class="tok-kw">const</span> err_mask = os.POLL.ERR | os.POLL.NVAL | os.POLL.HUP;</span>
<span class="line" id="L215"></span>
<span class="line" id="L216">        <span class="tok-kw">while</span> (dead_fds &lt; poll_fds.len) {</span>
<span class="line" id="L217">            <span class="tok-kw">const</span> events = <span class="tok-kw">try</span> os.poll(&amp;poll_fds, std.math.maxInt(<span class="tok-type">i32</span>));</span>
<span class="line" id="L218">            <span class="tok-kw">if</span> (events == <span class="tok-number">0</span>) <span class="tok-kw">continue</span>;</span>
<span class="line" id="L219"></span>
<span class="line" id="L220">            <span class="tok-kw">var</span> remove_stdout = <span class="tok-null">false</span>;</span>
<span class="line" id="L221">            <span class="tok-kw">var</span> remove_stderr = <span class="tok-null">false</span>;</span>
<span class="line" id="L222">            <span class="tok-comment">// Try reading whatever is available before checking the error</span>
</span>
<span class="line" id="L223">            <span class="tok-comment">// conditions.</span>
</span>
<span class="line" id="L224">            <span class="tok-comment">// It's still possible to read after a POLL.HUP is received, always</span>
</span>
<span class="line" id="L225">            <span class="tok-comment">// check if there's some data waiting to be read first.</span>
</span>
<span class="line" id="L226">            <span class="tok-kw">if</span> (poll_fds[<span class="tok-number">0</span>].revents &amp; os.POLL.IN != <span class="tok-number">0</span>) {</span>
<span class="line" id="L227">                <span class="tok-comment">// stdout is ready.</span>
</span>
<span class="line" id="L228">                <span class="tok-kw">const</span> new_capacity = std.math.min(stdout.items.len + bump_amt, max_output_bytes);</span>
<span class="line" id="L229">                <span class="tok-kw">try</span> stdout.ensureTotalCapacity(new_capacity);</span>
<span class="line" id="L230">                <span class="tok-kw">const</span> buf = stdout.unusedCapacitySlice();</span>
<span class="line" id="L231">                <span class="tok-kw">if</span> (buf.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.StdoutStreamTooLong;</span>
<span class="line" id="L232">                <span class="tok-kw">const</span> nread = <span class="tok-kw">try</span> os.read(poll_fds[<span class="tok-number">0</span>].fd, buf);</span>
<span class="line" id="L233">                stdout.items.len += nread;</span>
<span class="line" id="L234"></span>
<span class="line" id="L235">                <span class="tok-comment">// Remove the fd when the EOF condition is met.</span>
</span>
<span class="line" id="L236">                remove_stdout = nread == <span class="tok-number">0</span>;</span>
<span class="line" id="L237">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L238">                remove_stdout = poll_fds[<span class="tok-number">0</span>].revents &amp; err_mask != <span class="tok-number">0</span>;</span>
<span class="line" id="L239">            }</span>
<span class="line" id="L240"></span>
<span class="line" id="L241">            <span class="tok-kw">if</span> (poll_fds[<span class="tok-number">1</span>].revents &amp; os.POLL.IN != <span class="tok-number">0</span>) {</span>
<span class="line" id="L242">                <span class="tok-comment">// stderr is ready.</span>
</span>
<span class="line" id="L243">                <span class="tok-kw">const</span> new_capacity = std.math.min(stderr.items.len + bump_amt, max_output_bytes);</span>
<span class="line" id="L244">                <span class="tok-kw">try</span> stderr.ensureTotalCapacity(new_capacity);</span>
<span class="line" id="L245">                <span class="tok-kw">const</span> buf = stderr.unusedCapacitySlice();</span>
<span class="line" id="L246">                <span class="tok-kw">if</span> (buf.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.StderrStreamTooLong;</span>
<span class="line" id="L247">                <span class="tok-kw">const</span> nread = <span class="tok-kw">try</span> os.read(poll_fds[<span class="tok-number">1</span>].fd, buf);</span>
<span class="line" id="L248">                stderr.items.len += nread;</span>
<span class="line" id="L249"></span>
<span class="line" id="L250">                <span class="tok-comment">// Remove the fd when the EOF condition is met.</span>
</span>
<span class="line" id="L251">                remove_stderr = nread == <span class="tok-number">0</span>;</span>
<span class="line" id="L252">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L253">                remove_stderr = poll_fds[<span class="tok-number">1</span>].revents &amp; err_mask != <span class="tok-number">0</span>;</span>
<span class="line" id="L254">            }</span>
<span class="line" id="L255"></span>
<span class="line" id="L256">            <span class="tok-comment">// Exclude the fds that signaled an error.</span>
</span>
<span class="line" id="L257">            <span class="tok-kw">if</span> (remove_stdout) {</span>
<span class="line" id="L258">                poll_fds[<span class="tok-number">0</span>].fd = -<span class="tok-number">1</span>;</span>
<span class="line" id="L259">                dead_fds += <span class="tok-number">1</span>;</span>
<span class="line" id="L260">            }</span>
<span class="line" id="L261">            <span class="tok-kw">if</span> (remove_stderr) {</span>
<span class="line" id="L262">                poll_fds[<span class="tok-number">1</span>].fd = -<span class="tok-number">1</span>;</span>
<span class="line" id="L263">                dead_fds += <span class="tok-number">1</span>;</span>
<span class="line" id="L264">            }</span>
<span class="line" id="L265">        }</span>
<span class="line" id="L266">    }</span>
<span class="line" id="L267"></span>
<span class="line" id="L268">    <span class="tok-kw">const</span> WindowsAsyncReadResult = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L269">        pending,</span>
<span class="line" id="L270">        closed,</span>
<span class="line" id="L271">        full,</span>
<span class="line" id="L272">    };</span>
<span class="line" id="L273"></span>
<span class="line" id="L274">    <span class="tok-kw">fn</span> <span class="tok-fn">windowsAsyncRead</span>(</span>
<span class="line" id="L275">        handle: windows.HANDLE,</span>
<span class="line" id="L276">        overlapped: *windows.OVERLAPPED,</span>
<span class="line" id="L277">        buf: *std.ArrayList(<span class="tok-type">u8</span>),</span>
<span class="line" id="L278">        bump_amt: <span class="tok-type">usize</span>,</span>
<span class="line" id="L279">        max_output_bytes: <span class="tok-type">usize</span>,</span>
<span class="line" id="L280">    ) !WindowsAsyncReadResult {</span>
<span class="line" id="L281">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L282">            <span class="tok-kw">const</span> new_capacity = std.math.min(buf.items.len + bump_amt, max_output_bytes);</span>
<span class="line" id="L283">            <span class="tok-kw">try</span> buf.ensureTotalCapacity(new_capacity);</span>
<span class="line" id="L284">            <span class="tok-kw">const</span> next_buf = buf.unusedCapacitySlice();</span>
<span class="line" id="L285">            <span class="tok-kw">if</span> (next_buf.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span> .full;</span>
<span class="line" id="L286">            <span class="tok-kw">var</span> read_bytes: <span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L287">            <span class="tok-kw">const</span> read_result = windows.kernel32.ReadFile(handle, next_buf.ptr, math.cast(<span class="tok-type">u32</span>, next_buf.len) <span class="tok-kw">orelse</span> maxInt(<span class="tok-type">u32</span>), &amp;read_bytes, overlapped);</span>
<span class="line" id="L288">            <span class="tok-kw">if</span> (read_result == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (windows.kernel32.GetLastError()) {</span>
<span class="line" id="L289">                .IO_PENDING =&gt; .pending,</span>
<span class="line" id="L290">                .BROKEN_PIPE =&gt; .closed,</span>
<span class="line" id="L291">                <span class="tok-kw">else</span> =&gt; |err| windows.unexpectedError(err),</span>
<span class="line" id="L292">            };</span>
<span class="line" id="L293">            buf.items.len += read_bytes;</span>
<span class="line" id="L294">        }</span>
<span class="line" id="L295">    }</span>
<span class="line" id="L296"></span>
<span class="line" id="L297">    <span class="tok-kw">fn</span> <span class="tok-fn">collectOutputWindows</span>(child: ChildProcess, outs: [<span class="tok-number">2</span>]*std.ArrayList(<span class="tok-type">u8</span>), max_output_bytes: <span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L298">        <span class="tok-kw">const</span> bump_amt = <span class="tok-number">512</span>;</span>
<span class="line" id="L299">        <span class="tok-kw">const</span> handles = [_]windows.HANDLE{</span>
<span class="line" id="L300">            child.stdout.?.handle,</span>
<span class="line" id="L301">            child.stderr.?.handle,</span>
<span class="line" id="L302">        };</span>
<span class="line" id="L303"></span>
<span class="line" id="L304">        <span class="tok-kw">var</span> overlapped = [_]windows.OVERLAPPED{</span>
<span class="line" id="L305">            mem.zeroes(windows.OVERLAPPED),</span>
<span class="line" id="L306">            mem.zeroes(windows.OVERLAPPED),</span>
<span class="line" id="L307">        };</span>
<span class="line" id="L308"></span>
<span class="line" id="L309">        <span class="tok-kw">var</span> wait_objects: [<span class="tok-number">2</span>]windows.HANDLE = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L310">        <span class="tok-kw">var</span> wait_object_count: <span class="tok-type">u2</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L311"></span>
<span class="line" id="L312">        <span class="tok-comment">// we need to cancel all pending IO before returning so our OVERLAPPED values don't go out of scope</span>
</span>
<span class="line" id="L313">        <span class="tok-kw">defer</span> <span class="tok-kw">for</span> (wait_objects[<span class="tok-number">0</span>..wait_object_count]) |o| {</span>
<span class="line" id="L314">            _ = windows.kernel32.CancelIo(o);</span>
<span class="line" id="L315">        };</span>
<span class="line" id="L316"></span>
<span class="line" id="L317">        <span class="tok-comment">// Windows Async IO requires an initial call to ReadFile before waiting on the handle</span>
</span>
<span class="line" id="L318">        <span class="tok-kw">for</span> ([_]<span class="tok-type">u1</span>{ <span class="tok-number">0</span>, <span class="tok-number">1</span> }) |i| {</span>
<span class="line" id="L319">            <span class="tok-kw">switch</span> (<span class="tok-kw">try</span> windowsAsyncRead(handles[i], &amp;overlapped[i], outs[i], bump_amt, max_output_bytes)) {</span>
<span class="line" id="L320">                .pending =&gt; {</span>
<span class="line" id="L321">                    wait_objects[wait_object_count] = handles[i];</span>
<span class="line" id="L322">                    wait_object_count += <span class="tok-number">1</span>;</span>
<span class="line" id="L323">                },</span>
<span class="line" id="L324">                .closed =&gt; {}, <span class="tok-comment">// don't add to the wait_objects list</span>
</span>
<span class="line" id="L325">                .full =&gt; <span class="tok-kw">return</span> <span class="tok-kw">if</span> (i == <span class="tok-number">0</span>) <span class="tok-kw">error</span>.StdoutStreamTooLong <span class="tok-kw">else</span> <span class="tok-kw">error</span>.StderrStreamTooLong,</span>
<span class="line" id="L326">            }</span>
<span class="line" id="L327">        }</span>
<span class="line" id="L328"></span>
<span class="line" id="L329">        <span class="tok-kw">while</span> (wait_object_count &gt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L330">            <span class="tok-kw">const</span> status = windows.kernel32.WaitForMultipleObjects(wait_object_count, &amp;wait_objects, <span class="tok-number">0</span>, windows.INFINITE);</span>
<span class="line" id="L331">            <span class="tok-kw">if</span> (status == windows.WAIT_FAILED) {</span>
<span class="line" id="L332">                <span class="tok-kw">switch</span> (windows.kernel32.GetLastError()) {</span>
<span class="line" id="L333">                    <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L334">                }</span>
<span class="line" id="L335">            }</span>
<span class="line" id="L336">            <span class="tok-kw">if</span> (status &lt; windows.WAIT_OBJECT_0 <span class="tok-kw">or</span> status &gt; windows.WAIT_OBJECT_0 + wait_object_count - <span class="tok-number">1</span>)</span>
<span class="line" id="L337">                <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L338"></span>
<span class="line" id="L339">            <span class="tok-kw">const</span> wait_idx = status - windows.WAIT_OBJECT_0;</span>
<span class="line" id="L340"></span>
<span class="line" id="L341">            <span class="tok-comment">// this extra `i` index is needed to map the wait handle back to the stdout or stderr</span>
</span>
<span class="line" id="L342">            <span class="tok-comment">// values since the wait_idx can change which handle it corresponds with</span>
</span>
<span class="line" id="L343">            <span class="tok-kw">const</span> i: <span class="tok-type">u1</span> = <span class="tok-kw">if</span> (wait_objects[wait_idx] == handles[<span class="tok-number">0</span>]) <span class="tok-number">0</span> <span class="tok-kw">else</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L344"></span>
<span class="line" id="L345">            <span class="tok-comment">// remove completed event from the wait list</span>
</span>
<span class="line" id="L346">            wait_object_count -= <span class="tok-number">1</span>;</span>
<span class="line" id="L347">            <span class="tok-kw">if</span> (wait_idx == <span class="tok-number">0</span>)</span>
<span class="line" id="L348">                wait_objects[<span class="tok-number">0</span>] = wait_objects[<span class="tok-number">1</span>];</span>
<span class="line" id="L349"></span>
<span class="line" id="L350">            <span class="tok-kw">var</span> read_bytes: <span class="tok-type">u32</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L351">            <span class="tok-kw">if</span> (windows.kernel32.GetOverlappedResult(handles[i], &amp;overlapped[i], &amp;read_bytes, <span class="tok-number">0</span>) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L352">                <span class="tok-kw">switch</span> (windows.kernel32.GetLastError()) {</span>
<span class="line" id="L353">                    .BROKEN_PIPE =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L354">                    <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L355">                }</span>
<span class="line" id="L356">            }</span>
<span class="line" id="L357"></span>
<span class="line" id="L358">            outs[i].items.len += read_bytes;</span>
<span class="line" id="L359"></span>
<span class="line" id="L360">            <span class="tok-kw">switch</span> (<span class="tok-kw">try</span> windowsAsyncRead(handles[i], &amp;overlapped[i], outs[i], bump_amt, max_output_bytes)) {</span>
<span class="line" id="L361">                .pending =&gt; {</span>
<span class="line" id="L362">                    wait_objects[wait_object_count] = handles[i];</span>
<span class="line" id="L363">                    wait_object_count += <span class="tok-number">1</span>;</span>
<span class="line" id="L364">                },</span>
<span class="line" id="L365">                .closed =&gt; {}, <span class="tok-comment">// don't add to the wait_objects list</span>
</span>
<span class="line" id="L366">                .full =&gt; <span class="tok-kw">return</span> <span class="tok-kw">if</span> (i == <span class="tok-number">0</span>) <span class="tok-kw">error</span>.StdoutStreamTooLong <span class="tok-kw">else</span> <span class="tok-kw">error</span>.StderrStreamTooLong,</span>
<span class="line" id="L367">            }</span>
<span class="line" id="L368">        }</span>
<span class="line" id="L369">    }</span>
<span class="line" id="L370"></span>
<span class="line" id="L371">    <span class="tok-comment">/// Spawns a child process, waits for it, collecting stdout and stderr, and then returns.</span></span>
<span class="line" id="L372">    <span class="tok-comment">/// If it succeeds, the caller owns result.stdout and result.stderr memory.</span></span>
<span class="line" id="L373">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">exec</span>(args: <span class="tok-kw">struct</span> {</span>
<span class="line" id="L374">        allocator: mem.Allocator,</span>
<span class="line" id="L375">        argv: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L376">        cwd: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L377">        cwd_dir: ?fs.Dir = <span class="tok-null">null</span>,</span>
<span class="line" id="L378">        env_map: ?*<span class="tok-kw">const</span> EnvMap = <span class="tok-null">null</span>,</span>
<span class="line" id="L379">        max_output_bytes: <span class="tok-type">usize</span> = <span class="tok-number">50</span> * <span class="tok-number">1024</span>,</span>
<span class="line" id="L380">        expand_arg0: Arg0Expand = .no_expand,</span>
<span class="line" id="L381">    }) !ExecResult {</span>
<span class="line" id="L382">        <span class="tok-kw">var</span> child = ChildProcess.init(args.argv, args.allocator);</span>
<span class="line" id="L383">        child.stdin_behavior = .Ignore;</span>
<span class="line" id="L384">        child.stdout_behavior = .Pipe;</span>
<span class="line" id="L385">        child.stderr_behavior = .Pipe;</span>
<span class="line" id="L386">        child.cwd = args.cwd;</span>
<span class="line" id="L387">        child.cwd_dir = args.cwd_dir;</span>
<span class="line" id="L388">        child.env_map = args.env_map;</span>
<span class="line" id="L389">        child.expand_arg0 = args.expand_arg0;</span>
<span class="line" id="L390"></span>
<span class="line" id="L391">        <span class="tok-kw">try</span> child.spawn();</span>
<span class="line" id="L392"></span>
<span class="line" id="L393">        <span class="tok-kw">if</span> (builtin.os.tag == .haiku) {</span>
<span class="line" id="L394">            <span class="tok-kw">const</span> stdout_in = child.stdout.?.reader();</span>
<span class="line" id="L395">            <span class="tok-kw">const</span> stderr_in = child.stderr.?.reader();</span>
<span class="line" id="L396"></span>
<span class="line" id="L397">            <span class="tok-kw">const</span> stdout = <span class="tok-kw">try</span> stdout_in.readAllAlloc(args.allocator, args.max_output_bytes);</span>
<span class="line" id="L398">            <span class="tok-kw">errdefer</span> args.allocator.free(stdout);</span>
<span class="line" id="L399">            <span class="tok-kw">const</span> stderr = <span class="tok-kw">try</span> stderr_in.readAllAlloc(args.allocator, args.max_output_bytes);</span>
<span class="line" id="L400">            <span class="tok-kw">errdefer</span> args.allocator.free(stderr);</span>
<span class="line" id="L401"></span>
<span class="line" id="L402">            <span class="tok-kw">return</span> ExecResult{</span>
<span class="line" id="L403">                .term = <span class="tok-kw">try</span> child.wait(),</span>
<span class="line" id="L404">                .stdout = stdout,</span>
<span class="line" id="L405">                .stderr = stderr,</span>
<span class="line" id="L406">            };</span>
<span class="line" id="L407">        }</span>
<span class="line" id="L408"></span>
<span class="line" id="L409">        <span class="tok-kw">var</span> stdout = std.ArrayList(<span class="tok-type">u8</span>).init(args.allocator);</span>
<span class="line" id="L410">        <span class="tok-kw">var</span> stderr = std.ArrayList(<span class="tok-type">u8</span>).init(args.allocator);</span>
<span class="line" id="L411">        <span class="tok-kw">errdefer</span> {</span>
<span class="line" id="L412">            stdout.deinit();</span>
<span class="line" id="L413">            stderr.deinit();</span>
<span class="line" id="L414">        }</span>
<span class="line" id="L415"></span>
<span class="line" id="L416">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L417">            <span class="tok-kw">try</span> collectOutputWindows(child, [_]*std.ArrayList(<span class="tok-type">u8</span>){ &amp;stdout, &amp;stderr }, args.max_output_bytes);</span>
<span class="line" id="L418">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L419">            <span class="tok-kw">try</span> collectOutputPosix(child, &amp;stdout, &amp;stderr, args.max_output_bytes);</span>
<span class="line" id="L420">        }</span>
<span class="line" id="L421"></span>
<span class="line" id="L422">        <span class="tok-kw">return</span> ExecResult{</span>
<span class="line" id="L423">            .term = <span class="tok-kw">try</span> child.wait(),</span>
<span class="line" id="L424">            .stdout = stdout.toOwnedSlice(),</span>
<span class="line" id="L425">            .stderr = stderr.toOwnedSlice(),</span>
<span class="line" id="L426">        };</span>
<span class="line" id="L427">    }</span>
<span class="line" id="L428"></span>
<span class="line" id="L429">    <span class="tok-kw">fn</span> <span class="tok-fn">waitWindows</span>(self: *ChildProcess) !Term {</span>
<span class="line" id="L430">        <span class="tok-kw">if</span> (self.term) |term| {</span>
<span class="line" id="L431">            self.cleanupStreams();</span>
<span class="line" id="L432">            <span class="tok-kw">return</span> term;</span>
<span class="line" id="L433">        }</span>
<span class="line" id="L434"></span>
<span class="line" id="L435">        <span class="tok-kw">try</span> self.waitUnwrappedWindows();</span>
<span class="line" id="L436">        <span class="tok-kw">return</span> self.term.?;</span>
<span class="line" id="L437">    }</span>
<span class="line" id="L438"></span>
<span class="line" id="L439">    <span class="tok-kw">fn</span> <span class="tok-fn">waitPosix</span>(self: *ChildProcess) !Term {</span>
<span class="line" id="L440">        <span class="tok-kw">if</span> (self.term) |term| {</span>
<span class="line" id="L441">            self.cleanupStreams();</span>
<span class="line" id="L442">            <span class="tok-kw">return</span> term;</span>
<span class="line" id="L443">        }</span>
<span class="line" id="L444"></span>
<span class="line" id="L445">        <span class="tok-kw">try</span> self.waitUnwrapped();</span>
<span class="line" id="L446">        <span class="tok-kw">return</span> self.term.?;</span>
<span class="line" id="L447">    }</span>
<span class="line" id="L448"></span>
<span class="line" id="L449">    <span class="tok-kw">fn</span> <span class="tok-fn">waitUnwrappedWindows</span>(self: *ChildProcess) !<span class="tok-type">void</span> {</span>
<span class="line" id="L450">        <span class="tok-kw">const</span> result = windows.WaitForSingleObjectEx(self.handle, windows.INFINITE, <span class="tok-null">false</span>);</span>
<span class="line" id="L451"></span>
<span class="line" id="L452">        self.term = <span class="tok-builtin">@as</span>(SpawnError!Term, x: {</span>
<span class="line" id="L453">            <span class="tok-kw">var</span> exit_code: windows.DWORD = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L454">            <span class="tok-kw">if</span> (windows.kernel32.GetExitCodeProcess(self.handle, &amp;exit_code) == <span class="tok-number">0</span>) {</span>
<span class="line" id="L455">                <span class="tok-kw">break</span> :x Term{ .Unknown = <span class="tok-number">0</span> };</span>
<span class="line" id="L456">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L457">                <span class="tok-kw">break</span> :x Term{ .Exited = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, exit_code) };</span>
<span class="line" id="L458">            }</span>
<span class="line" id="L459">        });</span>
<span class="line" id="L460"></span>
<span class="line" id="L461">        os.close(self.handle);</span>
<span class="line" id="L462">        os.close(self.thread_handle);</span>
<span class="line" id="L463">        self.cleanupStreams();</span>
<span class="line" id="L464">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L465">    }</span>
<span class="line" id="L466"></span>
<span class="line" id="L467">    <span class="tok-kw">fn</span> <span class="tok-fn">waitUnwrapped</span>(self: *ChildProcess) !<span class="tok-type">void</span> {</span>
<span class="line" id="L468">        <span class="tok-kw">const</span> res: os.WaitPidResult = <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> builtin.target.isDarwin())</span>
<span class="line" id="L469">            <span class="tok-kw">try</span> os.posix_spawn.waitpid(self.pid, <span class="tok-number">0</span>)</span>
<span class="line" id="L470">        <span class="tok-kw">else</span></span>
<span class="line" id="L471">            os.waitpid(self.pid, <span class="tok-number">0</span>);</span>
<span class="line" id="L472">        <span class="tok-kw">const</span> status = res.status;</span>
<span class="line" id="L473">        self.cleanupStreams();</span>
<span class="line" id="L474">        self.handleWaitResult(status);</span>
<span class="line" id="L475">    }</span>
<span class="line" id="L476"></span>
<span class="line" id="L477">    <span class="tok-kw">fn</span> <span class="tok-fn">handleWaitResult</span>(self: *ChildProcess, status: <span class="tok-type">u32</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L478">        self.term = self.cleanupAfterWait(status);</span>
<span class="line" id="L479">    }</span>
<span class="line" id="L480"></span>
<span class="line" id="L481">    <span class="tok-kw">fn</span> <span class="tok-fn">cleanupStreams</span>(self: *ChildProcess) <span class="tok-type">void</span> {</span>
<span class="line" id="L482">        <span class="tok-kw">if</span> (self.stdin) |*stdin| {</span>
<span class="line" id="L483">            stdin.close();</span>
<span class="line" id="L484">            self.stdin = <span class="tok-null">null</span>;</span>
<span class="line" id="L485">        }</span>
<span class="line" id="L486">        <span class="tok-kw">if</span> (self.stdout) |*stdout| {</span>
<span class="line" id="L487">            stdout.close();</span>
<span class="line" id="L488">            self.stdout = <span class="tok-null">null</span>;</span>
<span class="line" id="L489">        }</span>
<span class="line" id="L490">        <span class="tok-kw">if</span> (self.stderr) |*stderr| {</span>
<span class="line" id="L491">            stderr.close();</span>
<span class="line" id="L492">            self.stderr = <span class="tok-null">null</span>;</span>
<span class="line" id="L493">        }</span>
<span class="line" id="L494">    }</span>
<span class="line" id="L495"></span>
<span class="line" id="L496">    <span class="tok-kw">fn</span> <span class="tok-fn">cleanupAfterWait</span>(self: *ChildProcess, status: <span class="tok-type">u32</span>) !Term {</span>
<span class="line" id="L497">        <span class="tok-kw">if</span> (self.err_pipe) |err_pipe| {</span>
<span class="line" id="L498">            <span class="tok-kw">defer</span> destroyPipe(err_pipe);</span>
<span class="line" id="L499"></span>
<span class="line" id="L500">            <span class="tok-kw">if</span> (builtin.os.tag == .linux) {</span>
<span class="line" id="L501">                <span class="tok-kw">var</span> fd = [<span class="tok-number">1</span>]std.os.pollfd{std.os.pollfd{</span>
<span class="line" id="L502">                    .fd = err_pipe[<span class="tok-number">0</span>],</span>
<span class="line" id="L503">                    .events = std.os.POLL.IN,</span>
<span class="line" id="L504">                    .revents = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L505">                }};</span>
<span class="line" id="L506"></span>
<span class="line" id="L507">                <span class="tok-comment">// Check if the eventfd buffer stores a non-zero value by polling</span>
</span>
<span class="line" id="L508">                <span class="tok-comment">// it, that's the error code returned by the child process.</span>
</span>
<span class="line" id="L509">                _ = std.os.poll(&amp;fd, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L510"></span>
<span class="line" id="L511">                <span class="tok-comment">// According to eventfd(2) the descriptro is readable if the counter</span>
</span>
<span class="line" id="L512">                <span class="tok-comment">// has a value greater than 0</span>
</span>
<span class="line" id="L513">                <span class="tok-kw">if</span> ((fd[<span class="tok-number">0</span>].revents &amp; std.os.POLL.IN) != <span class="tok-number">0</span>) {</span>
<span class="line" id="L514">                    <span class="tok-kw">const</span> err_int = <span class="tok-kw">try</span> readIntFd(err_pipe[<span class="tok-number">0</span>]);</span>
<span class="line" id="L515">                    <span class="tok-kw">return</span> <span class="tok-builtin">@errSetCast</span>(SpawnError, <span class="tok-builtin">@intToError</span>(err_int));</span>
<span class="line" id="L516">                }</span>
<span class="line" id="L517">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L518">                <span class="tok-comment">// Write maxInt(ErrInt) to the write end of the err_pipe. This is after</span>
</span>
<span class="line" id="L519">                <span class="tok-comment">// waitpid, so this write is guaranteed to be after the child</span>
</span>
<span class="line" id="L520">                <span class="tok-comment">// pid potentially wrote an error. This way we can do a blocking</span>
</span>
<span class="line" id="L521">                <span class="tok-comment">// read on the error pipe and either get maxInt(ErrInt) (no error) or</span>
</span>
<span class="line" id="L522">                <span class="tok-comment">// an error code.</span>
</span>
<span class="line" id="L523">                <span class="tok-kw">try</span> writeIntFd(err_pipe[<span class="tok-number">1</span>], maxInt(ErrInt));</span>
<span class="line" id="L524">                <span class="tok-kw">const</span> err_int = <span class="tok-kw">try</span> readIntFd(err_pipe[<span class="tok-number">0</span>]);</span>
<span class="line" id="L525">                <span class="tok-comment">// Here we potentially return the fork child's error from the parent</span>
</span>
<span class="line" id="L526">                <span class="tok-comment">// pid.</span>
</span>
<span class="line" id="L527">                <span class="tok-kw">if</span> (err_int != maxInt(ErrInt)) {</span>
<span class="line" id="L528">                    <span class="tok-kw">return</span> <span class="tok-builtin">@errSetCast</span>(SpawnError, <span class="tok-builtin">@intToError</span>(err_int));</span>
<span class="line" id="L529">                }</span>
<span class="line" id="L530">            }</span>
<span class="line" id="L531">        }</span>
<span class="line" id="L532"></span>
<span class="line" id="L533">        <span class="tok-kw">return</span> statusToTerm(status);</span>
<span class="line" id="L534">    }</span>
<span class="line" id="L535"></span>
<span class="line" id="L536">    <span class="tok-kw">fn</span> <span class="tok-fn">statusToTerm</span>(status: <span class="tok-type">u32</span>) Term {</span>
<span class="line" id="L537">        <span class="tok-kw">return</span> <span class="tok-kw">if</span> (os.W.IFEXITED(status))</span>
<span class="line" id="L538">            Term{ .Exited = os.W.EXITSTATUS(status) }</span>
<span class="line" id="L539">        <span class="tok-kw">else</span> <span class="tok-kw">if</span> (os.W.IFSIGNALED(status))</span>
<span class="line" id="L540">            Term{ .Signal = os.W.TERMSIG(status) }</span>
<span class="line" id="L541">        <span class="tok-kw">else</span> <span class="tok-kw">if</span> (os.W.IFSTOPPED(status))</span>
<span class="line" id="L542">            Term{ .Stopped = os.W.STOPSIG(status) }</span>
<span class="line" id="L543">        <span class="tok-kw">else</span></span>
<span class="line" id="L544">            Term{ .Unknown = status };</span>
<span class="line" id="L545">    }</span>
<span class="line" id="L546"></span>
<span class="line" id="L547">    <span class="tok-kw">fn</span> <span class="tok-fn">spawnMacos</span>(self: *ChildProcess) SpawnError!<span class="tok-type">void</span> {</span>
<span class="line" id="L548">        <span class="tok-kw">const</span> pipe_flags = <span class="tok-kw">if</span> (io.is_async) os.O.NONBLOCK <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L549">        <span class="tok-kw">const</span> stdin_pipe = <span class="tok-kw">if</span> (self.stdin_behavior == StdIo.Pipe) <span class="tok-kw">try</span> os.pipe2(pipe_flags) <span class="tok-kw">else</span> <span class="tok-null">undefined</span>;</span>
<span class="line" id="L550">        <span class="tok-kw">errdefer</span> <span class="tok-kw">if</span> (self.stdin_behavior == StdIo.Pipe) destroyPipe(stdin_pipe);</span>
<span class="line" id="L551"></span>
<span class="line" id="L552">        <span class="tok-kw">const</span> stdout_pipe = <span class="tok-kw">if</span> (self.stdout_behavior == StdIo.Pipe) <span class="tok-kw">try</span> os.pipe2(pipe_flags) <span class="tok-kw">else</span> <span class="tok-null">undefined</span>;</span>
<span class="line" id="L553">        <span class="tok-kw">errdefer</span> <span class="tok-kw">if</span> (self.stdout_behavior == StdIo.Pipe) destroyPipe(stdout_pipe);</span>
<span class="line" id="L554"></span>
<span class="line" id="L555">        <span class="tok-kw">const</span> stderr_pipe = <span class="tok-kw">if</span> (self.stderr_behavior == StdIo.Pipe) <span class="tok-kw">try</span> os.pipe2(pipe_flags) <span class="tok-kw">else</span> <span class="tok-null">undefined</span>;</span>
<span class="line" id="L556">        <span class="tok-kw">errdefer</span> <span class="tok-kw">if</span> (self.stderr_behavior == StdIo.Pipe) destroyPipe(stderr_pipe);</span>
<span class="line" id="L557"></span>
<span class="line" id="L558">        <span class="tok-kw">const</span> any_ignore = (self.stdin_behavior == StdIo.Ignore <span class="tok-kw">or</span> self.stdout_behavior == StdIo.Ignore <span class="tok-kw">or</span> self.stderr_behavior == StdIo.Ignore);</span>
<span class="line" id="L559">        <span class="tok-kw">const</span> dev_null_fd = <span class="tok-kw">if</span> (any_ignore)</span>
<span class="line" id="L560">            os.openZ(<span class="tok-str">&quot;/dev/null&quot;</span>, os.O.RDWR, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L561">                <span class="tok-kw">error</span>.PathAlreadyExists =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L562">                <span class="tok-kw">error</span>.NoSpaceLeft =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L563">                <span class="tok-kw">error</span>.FileTooBig =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L564">                <span class="tok-kw">error</span>.DeviceBusy =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L565">                <span class="tok-kw">error</span>.FileLocksNotSupported =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L566">                <span class="tok-kw">error</span>.BadPathName =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Windows-only</span>
</span>
<span class="line" id="L567">                <span class="tok-kw">error</span>.InvalidHandle =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// WASI-only</span>
</span>
<span class="line" id="L568">                <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L569">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L570">            }</span>
<span class="line" id="L571">        <span class="tok-kw">else</span></span>
<span class="line" id="L572">            <span class="tok-null">undefined</span>;</span>
<span class="line" id="L573">        <span class="tok-kw">defer</span> <span class="tok-kw">if</span> (any_ignore) os.close(dev_null_fd);</span>
<span class="line" id="L574"></span>
<span class="line" id="L575">        <span class="tok-kw">var</span> attr = <span class="tok-kw">try</span> os.posix_spawn.Attr.init();</span>
<span class="line" id="L576">        <span class="tok-kw">defer</span> attr.deinit();</span>
<span class="line" id="L577">        <span class="tok-kw">var</span> flags: <span class="tok-type">u16</span> = os.darwin.POSIX_SPAWN_SETSIGDEF | os.darwin.POSIX_SPAWN_SETSIGMASK;</span>
<span class="line" id="L578">        <span class="tok-kw">if</span> (self.disable_aslr) {</span>
<span class="line" id="L579">            flags |= os.darwin._POSIX_SPAWN_DISABLE_ASLR;</span>
<span class="line" id="L580">        }</span>
<span class="line" id="L581">        <span class="tok-kw">try</span> attr.set(flags);</span>
<span class="line" id="L582"></span>
<span class="line" id="L583">        <span class="tok-kw">var</span> actions = <span class="tok-kw">try</span> os.posix_spawn.Actions.init();</span>
<span class="line" id="L584">        <span class="tok-kw">defer</span> actions.deinit();</span>
<span class="line" id="L585"></span>
<span class="line" id="L586">        <span class="tok-kw">try</span> setUpChildIoPosixSpawn(self.stdin_behavior, &amp;actions, stdin_pipe, os.STDIN_FILENO, dev_null_fd);</span>
<span class="line" id="L587">        <span class="tok-kw">try</span> setUpChildIoPosixSpawn(self.stdout_behavior, &amp;actions, stdout_pipe, os.STDOUT_FILENO, dev_null_fd);</span>
<span class="line" id="L588">        <span class="tok-kw">try</span> setUpChildIoPosixSpawn(self.stderr_behavior, &amp;actions, stderr_pipe, os.STDERR_FILENO, dev_null_fd);</span>
<span class="line" id="L589"></span>
<span class="line" id="L590">        <span class="tok-kw">if</span> (self.cwd_dir) |cwd| {</span>
<span class="line" id="L591">            <span class="tok-kw">try</span> actions.fchdir(cwd.fd);</span>
<span class="line" id="L592">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (self.cwd) |cwd| {</span>
<span class="line" id="L593">            <span class="tok-kw">try</span> actions.chdir(cwd);</span>
<span class="line" id="L594">        }</span>
<span class="line" id="L595"></span>
<span class="line" id="L596">        <span class="tok-kw">var</span> arena_allocator = std.heap.ArenaAllocator.init(self.allocator);</span>
<span class="line" id="L597">        <span class="tok-kw">defer</span> arena_allocator.deinit();</span>
<span class="line" id="L598">        <span class="tok-kw">const</span> arena = arena_allocator.allocator();</span>
<span class="line" id="L599"></span>
<span class="line" id="L600">        <span class="tok-kw">const</span> argv_buf = <span class="tok-kw">try</span> arena.allocSentinel(?[*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, self.argv.len, <span class="tok-null">null</span>);</span>
<span class="line" id="L601">        <span class="tok-kw">for</span> (self.argv) |arg, i| argv_buf[i] = (<span class="tok-kw">try</span> arena.dupeZ(<span class="tok-type">u8</span>, arg)).ptr;</span>
<span class="line" id="L602"></span>
<span class="line" id="L603">        <span class="tok-kw">const</span> envp = <span class="tok-kw">if</span> (self.env_map) |env_map| m: {</span>
<span class="line" id="L604">            <span class="tok-kw">const</span> envp_buf = <span class="tok-kw">try</span> createNullDelimitedEnvMap(arena, env_map);</span>
<span class="line" id="L605">            <span class="tok-kw">break</span> :m envp_buf.ptr;</span>
<span class="line" id="L606">        } <span class="tok-kw">else</span> std.c.environ;</span>
<span class="line" id="L607"></span>
<span class="line" id="L608">        <span class="tok-kw">const</span> pid = <span class="tok-kw">try</span> os.posix_spawn.spawnp(self.argv[<span class="tok-number">0</span>], actions, attr, argv_buf, envp);</span>
<span class="line" id="L609"></span>
<span class="line" id="L610">        <span class="tok-kw">if</span> (self.stdin_behavior == StdIo.Pipe) {</span>
<span class="line" id="L611">            self.stdin = File{ .handle = stdin_pipe[<span class="tok-number">1</span>] };</span>
<span class="line" id="L612">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L613">            self.stdin = <span class="tok-null">null</span>;</span>
<span class="line" id="L614">        }</span>
<span class="line" id="L615">        <span class="tok-kw">if</span> (self.stdout_behavior == StdIo.Pipe) {</span>
<span class="line" id="L616">            self.stdout = File{ .handle = stdout_pipe[<span class="tok-number">0</span>] };</span>
<span class="line" id="L617">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L618">            self.stdout = <span class="tok-null">null</span>;</span>
<span class="line" id="L619">        }</span>
<span class="line" id="L620">        <span class="tok-kw">if</span> (self.stderr_behavior == StdIo.Pipe) {</span>
<span class="line" id="L621">            self.stderr = File{ .handle = stderr_pipe[<span class="tok-number">0</span>] };</span>
<span class="line" id="L622">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L623">            self.stderr = <span class="tok-null">null</span>;</span>
<span class="line" id="L624">        }</span>
<span class="line" id="L625"></span>
<span class="line" id="L626">        self.pid = pid;</span>
<span class="line" id="L627">        self.term = <span class="tok-null">null</span>;</span>
<span class="line" id="L628"></span>
<span class="line" id="L629">        <span class="tok-kw">if</span> (self.stdin_behavior == StdIo.Pipe) {</span>
<span class="line" id="L630">            os.close(stdin_pipe[<span class="tok-number">0</span>]);</span>
<span class="line" id="L631">        }</span>
<span class="line" id="L632">        <span class="tok-kw">if</span> (self.stdout_behavior == StdIo.Pipe) {</span>
<span class="line" id="L633">            os.close(stdout_pipe[<span class="tok-number">1</span>]);</span>
<span class="line" id="L634">        }</span>
<span class="line" id="L635">        <span class="tok-kw">if</span> (self.stderr_behavior == StdIo.Pipe) {</span>
<span class="line" id="L636">            os.close(stderr_pipe[<span class="tok-number">1</span>]);</span>
<span class="line" id="L637">        }</span>
<span class="line" id="L638">    }</span>
<span class="line" id="L639"></span>
<span class="line" id="L640">    <span class="tok-kw">fn</span> <span class="tok-fn">setUpChildIoPosixSpawn</span>(</span>
<span class="line" id="L641">        stdio: StdIo,</span>
<span class="line" id="L642">        actions: *os.posix_spawn.Actions,</span>
<span class="line" id="L643">        pipe_fd: [<span class="tok-number">2</span>]<span class="tok-type">i32</span>,</span>
<span class="line" id="L644">        std_fileno: <span class="tok-type">i32</span>,</span>
<span class="line" id="L645">        dev_null_fd: <span class="tok-type">i32</span>,</span>
<span class="line" id="L646">    ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L647">        <span class="tok-kw">switch</span> (stdio) {</span>
<span class="line" id="L648">            .Pipe =&gt; {</span>
<span class="line" id="L649">                <span class="tok-kw">const</span> idx: <span class="tok-type">usize</span> = <span class="tok-kw">if</span> (std_fileno == <span class="tok-number">0</span>) <span class="tok-number">0</span> <span class="tok-kw">else</span> <span class="tok-number">1</span>;</span>
<span class="line" id="L650">                <span class="tok-kw">try</span> actions.dup2(pipe_fd[idx], std_fileno);</span>
<span class="line" id="L651">                <span class="tok-kw">try</span> actions.close(pipe_fd[<span class="tok-number">1</span> - idx]);</span>
<span class="line" id="L652">            },</span>
<span class="line" id="L653">            .Close =&gt; <span class="tok-kw">try</span> actions.close(std_fileno),</span>
<span class="line" id="L654">            .Inherit =&gt; {},</span>
<span class="line" id="L655">            .Ignore =&gt; <span class="tok-kw">try</span> actions.dup2(dev_null_fd, std_fileno),</span>
<span class="line" id="L656">        }</span>
<span class="line" id="L657">    }</span>
<span class="line" id="L658"></span>
<span class="line" id="L659">    <span class="tok-kw">fn</span> <span class="tok-fn">spawnPosix</span>(self: *ChildProcess) SpawnError!<span class="tok-type">void</span> {</span>
<span class="line" id="L660">        <span class="tok-kw">const</span> pipe_flags = <span class="tok-kw">if</span> (io.is_async) os.O.NONBLOCK <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L661">        <span class="tok-kw">const</span> stdin_pipe = <span class="tok-kw">if</span> (self.stdin_behavior == StdIo.Pipe) <span class="tok-kw">try</span> os.pipe2(pipe_flags) <span class="tok-kw">else</span> <span class="tok-null">undefined</span>;</span>
<span class="line" id="L662">        <span class="tok-kw">errdefer</span> <span class="tok-kw">if</span> (self.stdin_behavior == StdIo.Pipe) {</span>
<span class="line" id="L663">            destroyPipe(stdin_pipe);</span>
<span class="line" id="L664">        };</span>
<span class="line" id="L665"></span>
<span class="line" id="L666">        <span class="tok-kw">const</span> stdout_pipe = <span class="tok-kw">if</span> (self.stdout_behavior == StdIo.Pipe) <span class="tok-kw">try</span> os.pipe2(pipe_flags) <span class="tok-kw">else</span> <span class="tok-null">undefined</span>;</span>
<span class="line" id="L667">        <span class="tok-kw">errdefer</span> <span class="tok-kw">if</span> (self.stdout_behavior == StdIo.Pipe) {</span>
<span class="line" id="L668">            destroyPipe(stdout_pipe);</span>
<span class="line" id="L669">        };</span>
<span class="line" id="L670"></span>
<span class="line" id="L671">        <span class="tok-kw">const</span> stderr_pipe = <span class="tok-kw">if</span> (self.stderr_behavior == StdIo.Pipe) <span class="tok-kw">try</span> os.pipe2(pipe_flags) <span class="tok-kw">else</span> <span class="tok-null">undefined</span>;</span>
<span class="line" id="L672">        <span class="tok-kw">errdefer</span> <span class="tok-kw">if</span> (self.stderr_behavior == StdIo.Pipe) {</span>
<span class="line" id="L673">            destroyPipe(stderr_pipe);</span>
<span class="line" id="L674">        };</span>
<span class="line" id="L675"></span>
<span class="line" id="L676">        <span class="tok-kw">const</span> any_ignore = (self.stdin_behavior == StdIo.Ignore <span class="tok-kw">or</span> self.stdout_behavior == StdIo.Ignore <span class="tok-kw">or</span> self.stderr_behavior == StdIo.Ignore);</span>
<span class="line" id="L677">        <span class="tok-kw">const</span> dev_null_fd = <span class="tok-kw">if</span> (any_ignore)</span>
<span class="line" id="L678">            os.openZ(<span class="tok-str">&quot;/dev/null&quot;</span>, os.O.RDWR, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L679">                <span class="tok-kw">error</span>.PathAlreadyExists =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L680">                <span class="tok-kw">error</span>.NoSpaceLeft =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L681">                <span class="tok-kw">error</span>.FileTooBig =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L682">                <span class="tok-kw">error</span>.DeviceBusy =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L683">                <span class="tok-kw">error</span>.FileLocksNotSupported =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L684">                <span class="tok-kw">error</span>.BadPathName =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Windows-only</span>
</span>
<span class="line" id="L685">                <span class="tok-kw">error</span>.InvalidHandle =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// WASI-only</span>
</span>
<span class="line" id="L686">                <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L687">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L688">            }</span>
<span class="line" id="L689">        <span class="tok-kw">else</span></span>
<span class="line" id="L690">            <span class="tok-null">undefined</span>;</span>
<span class="line" id="L691">        <span class="tok-kw">defer</span> {</span>
<span class="line" id="L692">            <span class="tok-kw">if</span> (any_ignore) os.close(dev_null_fd);</span>
<span class="line" id="L693">        }</span>
<span class="line" id="L694"></span>
<span class="line" id="L695">        <span class="tok-kw">var</span> arena_allocator = std.heap.ArenaAllocator.init(self.allocator);</span>
<span class="line" id="L696">        <span class="tok-kw">defer</span> arena_allocator.deinit();</span>
<span class="line" id="L697">        <span class="tok-kw">const</span> arena = arena_allocator.allocator();</span>
<span class="line" id="L698"></span>
<span class="line" id="L699">        <span class="tok-comment">// The POSIX standard does not allow malloc() between fork() and execve(),</span>
</span>
<span class="line" id="L700">        <span class="tok-comment">// and `self.allocator` may be a libc allocator.</span>
</span>
<span class="line" id="L701">        <span class="tok-comment">// I have personally observed the child process deadlocking when it tries</span>
</span>
<span class="line" id="L702">        <span class="tok-comment">// to call malloc() due to a heap allocation between fork() and execve(),</span>
</span>
<span class="line" id="L703">        <span class="tok-comment">// in musl v1.1.24.</span>
</span>
<span class="line" id="L704">        <span class="tok-comment">// Additionally, we want to reduce the number of possible ways things</span>
</span>
<span class="line" id="L705">        <span class="tok-comment">// can fail between fork() and execve().</span>
</span>
<span class="line" id="L706">        <span class="tok-comment">// Therefore, we do all the allocation for the execve() before the fork().</span>
</span>
<span class="line" id="L707">        <span class="tok-comment">// This means we must do the null-termination of argv and env vars here.</span>
</span>
<span class="line" id="L708">        <span class="tok-kw">const</span> argv_buf = <span class="tok-kw">try</span> arena.allocSentinel(?[*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, self.argv.len, <span class="tok-null">null</span>);</span>
<span class="line" id="L709">        <span class="tok-kw">for</span> (self.argv) |arg, i| argv_buf[i] = (<span class="tok-kw">try</span> arena.dupeZ(<span class="tok-type">u8</span>, arg)).ptr;</span>
<span class="line" id="L710"></span>
<span class="line" id="L711">        <span class="tok-kw">const</span> envp = m: {</span>
<span class="line" id="L712">            <span class="tok-kw">if</span> (self.env_map) |env_map| {</span>
<span class="line" id="L713">                <span class="tok-kw">const</span> envp_buf = <span class="tok-kw">try</span> createNullDelimitedEnvMap(arena, env_map);</span>
<span class="line" id="L714">                <span class="tok-kw">break</span> :m envp_buf.ptr;</span>
<span class="line" id="L715">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.link_libc) {</span>
<span class="line" id="L716">                <span class="tok-kw">break</span> :m std.c.environ;</span>
<span class="line" id="L717">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.output_mode == .Exe) {</span>
<span class="line" id="L718">                <span class="tok-comment">// Then we have Zig start code and this works.</span>
</span>
<span class="line" id="L719">                <span class="tok-comment">// TODO type-safety for null-termination of `os.environ`.</span>
</span>
<span class="line" id="L720">                <span class="tok-kw">break</span> :m <span class="tok-builtin">@ptrCast</span>([*:<span class="tok-null">null</span>]?[*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, os.environ.ptr);</span>
<span class="line" id="L721">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L722">                <span class="tok-comment">// TODO come up with a solution for this.</span>
</span>
<span class="line" id="L723">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;missing std lib enhancement: ChildProcess implementation has no way to collect the environment variables to forward to the child process&quot;</span>);</span>
<span class="line" id="L724">            }</span>
<span class="line" id="L725">        };</span>
<span class="line" id="L726"></span>
<span class="line" id="L727">        <span class="tok-comment">// This pipe is used to communicate errors between the time of fork</span>
</span>
<span class="line" id="L728">        <span class="tok-comment">// and execve from the child process to the parent process.</span>
</span>
<span class="line" id="L729">        <span class="tok-kw">const</span> err_pipe = blk: {</span>
<span class="line" id="L730">            <span class="tok-kw">if</span> (builtin.os.tag == .linux) {</span>
<span class="line" id="L731">                <span class="tok-kw">const</span> fd = <span class="tok-kw">try</span> os.eventfd(<span class="tok-number">0</span>, linux.EFD.CLOEXEC);</span>
<span class="line" id="L732">                <span class="tok-comment">// There's no distinction between the readable and the writeable</span>
</span>
<span class="line" id="L733">                <span class="tok-comment">// end with eventfd</span>
</span>
<span class="line" id="L734">                <span class="tok-kw">break</span> :blk [<span class="tok-number">2</span>]os.fd_t{ fd, fd };</span>
<span class="line" id="L735">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L736">                <span class="tok-kw">break</span> :blk <span class="tok-kw">try</span> os.pipe2(os.O.CLOEXEC);</span>
<span class="line" id="L737">            }</span>
<span class="line" id="L738">        };</span>
<span class="line" id="L739">        <span class="tok-kw">errdefer</span> destroyPipe(err_pipe);</span>
<span class="line" id="L740"></span>
<span class="line" id="L741">        <span class="tok-kw">const</span> pid_result = <span class="tok-kw">try</span> os.fork();</span>
<span class="line" id="L742">        <span class="tok-kw">if</span> (pid_result == <span class="tok-number">0</span>) {</span>
<span class="line" id="L743">            <span class="tok-comment">// we are the child</span>
</span>
<span class="line" id="L744">            setUpChildIo(self.stdin_behavior, stdin_pipe[<span class="tok-number">0</span>], os.STDIN_FILENO, dev_null_fd) <span class="tok-kw">catch</span> |err| forkChildErrReport(err_pipe[<span class="tok-number">1</span>], err);</span>
<span class="line" id="L745">            setUpChildIo(self.stdout_behavior, stdout_pipe[<span class="tok-number">1</span>], os.STDOUT_FILENO, dev_null_fd) <span class="tok-kw">catch</span> |err| forkChildErrReport(err_pipe[<span class="tok-number">1</span>], err);</span>
<span class="line" id="L746">            setUpChildIo(self.stderr_behavior, stderr_pipe[<span class="tok-number">1</span>], os.STDERR_FILENO, dev_null_fd) <span class="tok-kw">catch</span> |err| forkChildErrReport(err_pipe[<span class="tok-number">1</span>], err);</span>
<span class="line" id="L747"></span>
<span class="line" id="L748">            <span class="tok-kw">if</span> (self.stdin_behavior == .Pipe) {</span>
<span class="line" id="L749">                os.close(stdin_pipe[<span class="tok-number">0</span>]);</span>
<span class="line" id="L750">                os.close(stdin_pipe[<span class="tok-number">1</span>]);</span>
<span class="line" id="L751">            }</span>
<span class="line" id="L752">            <span class="tok-kw">if</span> (self.stdout_behavior == .Pipe) {</span>
<span class="line" id="L753">                os.close(stdout_pipe[<span class="tok-number">0</span>]);</span>
<span class="line" id="L754">                os.close(stdout_pipe[<span class="tok-number">1</span>]);</span>
<span class="line" id="L755">            }</span>
<span class="line" id="L756">            <span class="tok-kw">if</span> (self.stderr_behavior == .Pipe) {</span>
<span class="line" id="L757">                os.close(stderr_pipe[<span class="tok-number">0</span>]);</span>
<span class="line" id="L758">                os.close(stderr_pipe[<span class="tok-number">1</span>]);</span>
<span class="line" id="L759">            }</span>
<span class="line" id="L760"></span>
<span class="line" id="L761">            <span class="tok-kw">if</span> (self.cwd_dir) |cwd| {</span>
<span class="line" id="L762">                os.fchdir(cwd.fd) <span class="tok-kw">catch</span> |err| forkChildErrReport(err_pipe[<span class="tok-number">1</span>], err);</span>
<span class="line" id="L763">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (self.cwd) |cwd| {</span>
<span class="line" id="L764">                os.chdir(cwd) <span class="tok-kw">catch</span> |err| forkChildErrReport(err_pipe[<span class="tok-number">1</span>], err);</span>
<span class="line" id="L765">            }</span>
<span class="line" id="L766"></span>
<span class="line" id="L767">            <span class="tok-kw">if</span> (self.gid) |gid| {</span>
<span class="line" id="L768">                os.setregid(gid, gid) <span class="tok-kw">catch</span> |err| forkChildErrReport(err_pipe[<span class="tok-number">1</span>], err);</span>
<span class="line" id="L769">            }</span>
<span class="line" id="L770"></span>
<span class="line" id="L771">            <span class="tok-kw">if</span> (self.uid) |uid| {</span>
<span class="line" id="L772">                os.setreuid(uid, uid) <span class="tok-kw">catch</span> |err| forkChildErrReport(err_pipe[<span class="tok-number">1</span>], err);</span>
<span class="line" id="L773">            }</span>
<span class="line" id="L774"></span>
<span class="line" id="L775">            <span class="tok-kw">const</span> err = <span class="tok-kw">switch</span> (self.expand_arg0) {</span>
<span class="line" id="L776">                .expand =&gt; os.execvpeZ_expandArg0(.expand, argv_buf.ptr[<span class="tok-number">0</span>].?, argv_buf.ptr, envp),</span>
<span class="line" id="L777">                .no_expand =&gt; os.execvpeZ_expandArg0(.no_expand, argv_buf.ptr[<span class="tok-number">0</span>].?, argv_buf.ptr, envp),</span>
<span class="line" id="L778">            };</span>
<span class="line" id="L779">            forkChildErrReport(err_pipe[<span class="tok-number">1</span>], err);</span>
<span class="line" id="L780">        }</span>
<span class="line" id="L781"></span>
<span class="line" id="L782">        <span class="tok-comment">// we are the parent</span>
</span>
<span class="line" id="L783">        <span class="tok-kw">const</span> pid = <span class="tok-builtin">@intCast</span>(<span class="tok-type">i32</span>, pid_result);</span>
<span class="line" id="L784">        <span class="tok-kw">if</span> (self.stdin_behavior == StdIo.Pipe) {</span>
<span class="line" id="L785">            self.stdin = File{ .handle = stdin_pipe[<span class="tok-number">1</span>] };</span>
<span class="line" id="L786">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L787">            self.stdin = <span class="tok-null">null</span>;</span>
<span class="line" id="L788">        }</span>
<span class="line" id="L789">        <span class="tok-kw">if</span> (self.stdout_behavior == StdIo.Pipe) {</span>
<span class="line" id="L790">            self.stdout = File{ .handle = stdout_pipe[<span class="tok-number">0</span>] };</span>
<span class="line" id="L791">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L792">            self.stdout = <span class="tok-null">null</span>;</span>
<span class="line" id="L793">        }</span>
<span class="line" id="L794">        <span class="tok-kw">if</span> (self.stderr_behavior == StdIo.Pipe) {</span>
<span class="line" id="L795">            self.stderr = File{ .handle = stderr_pipe[<span class="tok-number">0</span>] };</span>
<span class="line" id="L796">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L797">            self.stderr = <span class="tok-null">null</span>;</span>
<span class="line" id="L798">        }</span>
<span class="line" id="L799"></span>
<span class="line" id="L800">        self.pid = pid;</span>
<span class="line" id="L801">        self.err_pipe = err_pipe;</span>
<span class="line" id="L802">        self.term = <span class="tok-null">null</span>;</span>
<span class="line" id="L803"></span>
<span class="line" id="L804">        <span class="tok-kw">if</span> (self.stdin_behavior == StdIo.Pipe) {</span>
<span class="line" id="L805">            os.close(stdin_pipe[<span class="tok-number">0</span>]);</span>
<span class="line" id="L806">        }</span>
<span class="line" id="L807">        <span class="tok-kw">if</span> (self.stdout_behavior == StdIo.Pipe) {</span>
<span class="line" id="L808">            os.close(stdout_pipe[<span class="tok-number">1</span>]);</span>
<span class="line" id="L809">        }</span>
<span class="line" id="L810">        <span class="tok-kw">if</span> (self.stderr_behavior == StdIo.Pipe) {</span>
<span class="line" id="L811">            os.close(stderr_pipe[<span class="tok-number">1</span>]);</span>
<span class="line" id="L812">        }</span>
<span class="line" id="L813">    }</span>
<span class="line" id="L814"></span>
<span class="line" id="L815">    <span class="tok-kw">fn</span> <span class="tok-fn">spawnWindows</span>(self: *ChildProcess) SpawnError!<span class="tok-type">void</span> {</span>
<span class="line" id="L816">        <span class="tok-kw">const</span> saAttr = windows.SECURITY_ATTRIBUTES{</span>
<span class="line" id="L817">            .nLength = <span class="tok-builtin">@sizeOf</span>(windows.SECURITY_ATTRIBUTES),</span>
<span class="line" id="L818">            .bInheritHandle = windows.TRUE,</span>
<span class="line" id="L819">            .lpSecurityDescriptor = <span class="tok-null">null</span>,</span>
<span class="line" id="L820">        };</span>
<span class="line" id="L821"></span>
<span class="line" id="L822">        <span class="tok-kw">const</span> any_ignore = (self.stdin_behavior == StdIo.Ignore <span class="tok-kw">or</span> self.stdout_behavior == StdIo.Ignore <span class="tok-kw">or</span> self.stderr_behavior == StdIo.Ignore);</span>
<span class="line" id="L823"></span>
<span class="line" id="L824">        <span class="tok-kw">const</span> nul_handle = <span class="tok-kw">if</span> (any_ignore)</span>
<span class="line" id="L825">            <span class="tok-comment">// &quot;\Device\Null&quot; or &quot;\??\NUL&quot;</span>
</span>
<span class="line" id="L826">            windows.OpenFile(&amp;[_]<span class="tok-type">u16</span>{ <span class="tok-str">'\\'</span>, <span class="tok-str">'D'</span>, <span class="tok-str">'e'</span>, <span class="tok-str">'v'</span>, <span class="tok-str">'i'</span>, <span class="tok-str">'c'</span>, <span class="tok-str">'e'</span>, <span class="tok-str">'\\'</span>, <span class="tok-str">'N'</span>, <span class="tok-str">'u'</span>, <span class="tok-str">'l'</span>, <span class="tok-str">'l'</span> }, .{</span>
<span class="line" id="L827">                .access_mask = windows.GENERIC_READ | windows.SYNCHRONIZE,</span>
<span class="line" id="L828">                .share_access = windows.FILE_SHARE_READ,</span>
<span class="line" id="L829">                .creation = windows.OPEN_EXISTING,</span>
<span class="line" id="L830">                .io_mode = .blocking,</span>
<span class="line" id="L831">            }) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L832">                <span class="tok-kw">error</span>.PathAlreadyExists =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// not possible for &quot;NUL&quot;</span>
</span>
<span class="line" id="L833">                <span class="tok-kw">error</span>.PipeBusy =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// not possible for &quot;NUL&quot;</span>
</span>
<span class="line" id="L834">                <span class="tok-kw">error</span>.FileNotFound =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// not possible for &quot;NUL&quot;</span>
</span>
<span class="line" id="L835">                <span class="tok-kw">error</span>.AccessDenied =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// not possible for &quot;NUL&quot;</span>
</span>
<span class="line" id="L836">                <span class="tok-kw">error</span>.NameTooLong =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// not possible for &quot;NUL&quot;</span>
</span>
<span class="line" id="L837">                <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// not possible for &quot;NUL&quot;</span>
</span>
<span class="line" id="L838">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L839">            }</span>
<span class="line" id="L840">        <span class="tok-kw">else</span></span>
<span class="line" id="L841">            <span class="tok-null">undefined</span>;</span>
<span class="line" id="L842">        <span class="tok-kw">defer</span> {</span>
<span class="line" id="L843">            <span class="tok-kw">if</span> (any_ignore) os.close(nul_handle);</span>
<span class="line" id="L844">        }</span>
<span class="line" id="L845">        <span class="tok-kw">if</span> (any_ignore) {</span>
<span class="line" id="L846">            <span class="tok-kw">try</span> windows.SetHandleInformation(nul_handle, windows.HANDLE_FLAG_INHERIT, <span class="tok-number">0</span>);</span>
<span class="line" id="L847">        }</span>
<span class="line" id="L848"></span>
<span class="line" id="L849">        <span class="tok-kw">var</span> g_hChildStd_IN_Rd: ?windows.HANDLE = <span class="tok-null">null</span>;</span>
<span class="line" id="L850">        <span class="tok-kw">var</span> g_hChildStd_IN_Wr: ?windows.HANDLE = <span class="tok-null">null</span>;</span>
<span class="line" id="L851">        <span class="tok-kw">switch</span> (self.stdin_behavior) {</span>
<span class="line" id="L852">            StdIo.Pipe =&gt; {</span>
<span class="line" id="L853">                <span class="tok-kw">try</span> windowsMakePipeIn(&amp;g_hChildStd_IN_Rd, &amp;g_hChildStd_IN_Wr, &amp;saAttr);</span>
<span class="line" id="L854">            },</span>
<span class="line" id="L855">            StdIo.Ignore =&gt; {</span>
<span class="line" id="L856">                g_hChildStd_IN_Rd = nul_handle;</span>
<span class="line" id="L857">            },</span>
<span class="line" id="L858">            StdIo.Inherit =&gt; {</span>
<span class="line" id="L859">                g_hChildStd_IN_Rd = windows.GetStdHandle(windows.STD_INPUT_HANDLE) <span class="tok-kw">catch</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L860">            },</span>
<span class="line" id="L861">            StdIo.Close =&gt; {</span>
<span class="line" id="L862">                g_hChildStd_IN_Rd = <span class="tok-null">null</span>;</span>
<span class="line" id="L863">            },</span>
<span class="line" id="L864">        }</span>
<span class="line" id="L865">        <span class="tok-kw">errdefer</span> <span class="tok-kw">if</span> (self.stdin_behavior == StdIo.Pipe) {</span>
<span class="line" id="L866">            windowsDestroyPipe(g_hChildStd_IN_Rd, g_hChildStd_IN_Wr);</span>
<span class="line" id="L867">        };</span>
<span class="line" id="L868"></span>
<span class="line" id="L869">        <span class="tok-kw">var</span> g_hChildStd_OUT_Rd: ?windows.HANDLE = <span class="tok-null">null</span>;</span>
<span class="line" id="L870">        <span class="tok-kw">var</span> g_hChildStd_OUT_Wr: ?windows.HANDLE = <span class="tok-null">null</span>;</span>
<span class="line" id="L871">        <span class="tok-kw">switch</span> (self.stdout_behavior) {</span>
<span class="line" id="L872">            StdIo.Pipe =&gt; {</span>
<span class="line" id="L873">                <span class="tok-kw">try</span> windowsMakeAsyncPipe(&amp;g_hChildStd_OUT_Rd, &amp;g_hChildStd_OUT_Wr, &amp;saAttr);</span>
<span class="line" id="L874">            },</span>
<span class="line" id="L875">            StdIo.Ignore =&gt; {</span>
<span class="line" id="L876">                g_hChildStd_OUT_Wr = nul_handle;</span>
<span class="line" id="L877">            },</span>
<span class="line" id="L878">            StdIo.Inherit =&gt; {</span>
<span class="line" id="L879">                g_hChildStd_OUT_Wr = windows.GetStdHandle(windows.STD_OUTPUT_HANDLE) <span class="tok-kw">catch</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L880">            },</span>
<span class="line" id="L881">            StdIo.Close =&gt; {</span>
<span class="line" id="L882">                g_hChildStd_OUT_Wr = <span class="tok-null">null</span>;</span>
<span class="line" id="L883">            },</span>
<span class="line" id="L884">        }</span>
<span class="line" id="L885">        <span class="tok-kw">errdefer</span> <span class="tok-kw">if</span> (self.stdin_behavior == StdIo.Pipe) {</span>
<span class="line" id="L886">            windowsDestroyPipe(g_hChildStd_OUT_Rd, g_hChildStd_OUT_Wr);</span>
<span class="line" id="L887">        };</span>
<span class="line" id="L888"></span>
<span class="line" id="L889">        <span class="tok-kw">var</span> g_hChildStd_ERR_Rd: ?windows.HANDLE = <span class="tok-null">null</span>;</span>
<span class="line" id="L890">        <span class="tok-kw">var</span> g_hChildStd_ERR_Wr: ?windows.HANDLE = <span class="tok-null">null</span>;</span>
<span class="line" id="L891">        <span class="tok-kw">switch</span> (self.stderr_behavior) {</span>
<span class="line" id="L892">            StdIo.Pipe =&gt; {</span>
<span class="line" id="L893">                <span class="tok-kw">try</span> windowsMakeAsyncPipe(&amp;g_hChildStd_ERR_Rd, &amp;g_hChildStd_ERR_Wr, &amp;saAttr);</span>
<span class="line" id="L894">            },</span>
<span class="line" id="L895">            StdIo.Ignore =&gt; {</span>
<span class="line" id="L896">                g_hChildStd_ERR_Wr = nul_handle;</span>
<span class="line" id="L897">            },</span>
<span class="line" id="L898">            StdIo.Inherit =&gt; {</span>
<span class="line" id="L899">                g_hChildStd_ERR_Wr = windows.GetStdHandle(windows.STD_ERROR_HANDLE) <span class="tok-kw">catch</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L900">            },</span>
<span class="line" id="L901">            StdIo.Close =&gt; {</span>
<span class="line" id="L902">                g_hChildStd_ERR_Wr = <span class="tok-null">null</span>;</span>
<span class="line" id="L903">            },</span>
<span class="line" id="L904">        }</span>
<span class="line" id="L905">        <span class="tok-kw">errdefer</span> <span class="tok-kw">if</span> (self.stdin_behavior == StdIo.Pipe) {</span>
<span class="line" id="L906">            windowsDestroyPipe(g_hChildStd_ERR_Rd, g_hChildStd_ERR_Wr);</span>
<span class="line" id="L907">        };</span>
<span class="line" id="L908"></span>
<span class="line" id="L909">        <span class="tok-kw">const</span> cmd_line = <span class="tok-kw">try</span> windowsCreateCommandLine(self.allocator, self.argv);</span>
<span class="line" id="L910">        <span class="tok-kw">defer</span> self.allocator.free(cmd_line);</span>
<span class="line" id="L911"></span>
<span class="line" id="L912">        <span class="tok-kw">var</span> siStartInfo = windows.STARTUPINFOW{</span>
<span class="line" id="L913">            .cb = <span class="tok-builtin">@sizeOf</span>(windows.STARTUPINFOW),</span>
<span class="line" id="L914">            .hStdError = g_hChildStd_ERR_Wr,</span>
<span class="line" id="L915">            .hStdOutput = g_hChildStd_OUT_Wr,</span>
<span class="line" id="L916">            .hStdInput = g_hChildStd_IN_Rd,</span>
<span class="line" id="L917">            .dwFlags = windows.STARTF_USESTDHANDLES,</span>
<span class="line" id="L918"></span>
<span class="line" id="L919">            .lpReserved = <span class="tok-null">null</span>,</span>
<span class="line" id="L920">            .lpDesktop = <span class="tok-null">null</span>,</span>
<span class="line" id="L921">            .lpTitle = <span class="tok-null">null</span>,</span>
<span class="line" id="L922">            .dwX = <span class="tok-number">0</span>,</span>
<span class="line" id="L923">            .dwY = <span class="tok-number">0</span>,</span>
<span class="line" id="L924">            .dwXSize = <span class="tok-number">0</span>,</span>
<span class="line" id="L925">            .dwYSize = <span class="tok-number">0</span>,</span>
<span class="line" id="L926">            .dwXCountChars = <span class="tok-number">0</span>,</span>
<span class="line" id="L927">            .dwYCountChars = <span class="tok-number">0</span>,</span>
<span class="line" id="L928">            .dwFillAttribute = <span class="tok-number">0</span>,</span>
<span class="line" id="L929">            .wShowWindow = <span class="tok-number">0</span>,</span>
<span class="line" id="L930">            .cbReserved2 = <span class="tok-number">0</span>,</span>
<span class="line" id="L931">            .lpReserved2 = <span class="tok-null">null</span>,</span>
<span class="line" id="L932">        };</span>
<span class="line" id="L933">        <span class="tok-kw">var</span> piProcInfo: windows.PROCESS_INFORMATION = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L934"></span>
<span class="line" id="L935">        <span class="tok-kw">const</span> cwd_w = <span class="tok-kw">if</span> (self.cwd) |cwd| <span class="tok-kw">try</span> unicode.utf8ToUtf16LeWithNull(self.allocator, cwd) <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L936">        <span class="tok-kw">defer</span> <span class="tok-kw">if</span> (cwd_w) |cwd| self.allocator.free(cwd);</span>
<span class="line" id="L937">        <span class="tok-kw">const</span> cwd_w_ptr = <span class="tok-kw">if</span> (cwd_w) |cwd| cwd.ptr <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L938"></span>
<span class="line" id="L939">        <span class="tok-kw">const</span> maybe_envp_buf = <span class="tok-kw">if</span> (self.env_map) |env_map| <span class="tok-kw">try</span> createWindowsEnvBlock(self.allocator, env_map) <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L940">        <span class="tok-kw">defer</span> <span class="tok-kw">if</span> (maybe_envp_buf) |envp_buf| self.allocator.free(envp_buf);</span>
<span class="line" id="L941">        <span class="tok-kw">const</span> envp_ptr = <span class="tok-kw">if</span> (maybe_envp_buf) |envp_buf| envp_buf.ptr <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L942"></span>
<span class="line" id="L943">        <span class="tok-comment">// the cwd set in ChildProcess is in effect when choosing the executable path</span>
</span>
<span class="line" id="L944">        <span class="tok-comment">// to match posix semantics</span>
</span>
<span class="line" id="L945">        <span class="tok-kw">const</span> app_path = x: {</span>
<span class="line" id="L946">            <span class="tok-kw">if</span> (self.cwd) |cwd| {</span>
<span class="line" id="L947">                <span class="tok-kw">const</span> resolved = <span class="tok-kw">try</span> fs.path.resolve(self.allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ cwd, self.argv[<span class="tok-number">0</span>] });</span>
<span class="line" id="L948">                <span class="tok-kw">defer</span> self.allocator.free(resolved);</span>
<span class="line" id="L949">                <span class="tok-kw">break</span> :x <span class="tok-kw">try</span> cstr.addNullByte(self.allocator, resolved);</span>
<span class="line" id="L950">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L951">                <span class="tok-kw">break</span> :x <span class="tok-kw">try</span> cstr.addNullByte(self.allocator, self.argv[<span class="tok-number">0</span>]);</span>
<span class="line" id="L952">            }</span>
<span class="line" id="L953">        };</span>
<span class="line" id="L954">        <span class="tok-kw">defer</span> self.allocator.free(app_path);</span>
<span class="line" id="L955"></span>
<span class="line" id="L956">        <span class="tok-kw">const</span> app_path_w = <span class="tok-kw">try</span> unicode.utf8ToUtf16LeWithNull(self.allocator, app_path);</span>
<span class="line" id="L957">        <span class="tok-kw">defer</span> self.allocator.free(app_path_w);</span>
<span class="line" id="L958"></span>
<span class="line" id="L959">        <span class="tok-kw">const</span> cmd_line_w = <span class="tok-kw">try</span> unicode.utf8ToUtf16LeWithNull(self.allocator, cmd_line);</span>
<span class="line" id="L960">        <span class="tok-kw">defer</span> self.allocator.free(cmd_line_w);</span>
<span class="line" id="L961"></span>
<span class="line" id="L962">        windowsCreateProcess(app_path_w.ptr, cmd_line_w.ptr, envp_ptr, cwd_w_ptr, &amp;siStartInfo, &amp;piProcInfo) <span class="tok-kw">catch</span> |no_path_err| {</span>
<span class="line" id="L963">            <span class="tok-kw">if</span> (no_path_err != <span class="tok-kw">error</span>.FileNotFound) <span class="tok-kw">return</span> no_path_err;</span>
<span class="line" id="L964"></span>
<span class="line" id="L965">            <span class="tok-kw">var</span> free_path = <span class="tok-null">true</span>;</span>
<span class="line" id="L966">            <span class="tok-kw">const</span> PATH = process.getEnvVarOwned(self.allocator, <span class="tok-str">&quot;PATH&quot;</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L967">                <span class="tok-kw">error</span>.EnvironmentVariableNotFound =&gt; blk: {</span>
<span class="line" id="L968">                    free_path = <span class="tok-null">false</span>;</span>
<span class="line" id="L969">                    <span class="tok-kw">break</span> :blk <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L970">                },</span>
<span class="line" id="L971">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L972">            };</span>
<span class="line" id="L973">            <span class="tok-kw">defer</span> <span class="tok-kw">if</span> (free_path) self.allocator.free(PATH);</span>
<span class="line" id="L974"></span>
<span class="line" id="L975">            <span class="tok-kw">var</span> free_path_ext = <span class="tok-null">true</span>;</span>
<span class="line" id="L976">            <span class="tok-kw">const</span> PATHEXT = process.getEnvVarOwned(self.allocator, <span class="tok-str">&quot;PATHEXT&quot;</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L977">                <span class="tok-kw">error</span>.EnvironmentVariableNotFound =&gt; blk: {</span>
<span class="line" id="L978">                    free_path_ext = <span class="tok-null">false</span>;</span>
<span class="line" id="L979">                    <span class="tok-kw">break</span> :blk <span class="tok-str">&quot;&quot;</span>;</span>
<span class="line" id="L980">                },</span>
<span class="line" id="L981">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L982">            };</span>
<span class="line" id="L983">            <span class="tok-kw">defer</span> <span class="tok-kw">if</span> (free_path_ext) self.allocator.free(PATHEXT);</span>
<span class="line" id="L984"></span>
<span class="line" id="L985">            <span class="tok-kw">const</span> app_name = self.argv[<span class="tok-number">0</span>];</span>
<span class="line" id="L986"></span>
<span class="line" id="L987">            <span class="tok-kw">var</span> it = mem.tokenize(<span class="tok-type">u8</span>, PATH, <span class="tok-str">&quot;;&quot;</span>);</span>
<span class="line" id="L988">            retry: <span class="tok-kw">while</span> (it.next()) |search_path| {</span>
<span class="line" id="L989">                <span class="tok-kw">const</span> path_no_ext = <span class="tok-kw">try</span> fs.path.join(self.allocator, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ search_path, app_name });</span>
<span class="line" id="L990">                <span class="tok-kw">defer</span> self.allocator.free(path_no_ext);</span>
<span class="line" id="L991"></span>
<span class="line" id="L992">                <span class="tok-kw">var</span> ext_it = mem.tokenize(<span class="tok-type">u8</span>, PATHEXT, <span class="tok-str">&quot;;&quot;</span>);</span>
<span class="line" id="L993">                <span class="tok-kw">while</span> (ext_it.next()) |app_ext| {</span>
<span class="line" id="L994">                    <span class="tok-kw">const</span> joined_path = <span class="tok-kw">try</span> mem.concat(self.allocator, <span class="tok-type">u8</span>, &amp;[_][]<span class="tok-kw">const</span> <span class="tok-type">u8</span>{ path_no_ext, app_ext });</span>
<span class="line" id="L995">                    <span class="tok-kw">defer</span> self.allocator.free(joined_path);</span>
<span class="line" id="L996"></span>
<span class="line" id="L997">                    <span class="tok-kw">const</span> joined_path_w = <span class="tok-kw">try</span> unicode.utf8ToUtf16LeWithNull(self.allocator, joined_path);</span>
<span class="line" id="L998">                    <span class="tok-kw">defer</span> self.allocator.free(joined_path_w);</span>
<span class="line" id="L999"></span>
<span class="line" id="L1000">                    <span class="tok-kw">if</span> (windowsCreateProcess(joined_path_w.ptr, cmd_line_w.ptr, envp_ptr, cwd_w_ptr, &amp;siStartInfo, &amp;piProcInfo)) |_| {</span>
<span class="line" id="L1001">                        <span class="tok-kw">break</span> :retry;</span>
<span class="line" id="L1002">                    } <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1003">                        <span class="tok-kw">error</span>.FileNotFound =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1004">                        <span class="tok-kw">error</span>.AccessDenied =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L1005">                        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1006">                    }</span>
<span class="line" id="L1007">                }</span>
<span class="line" id="L1008">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1009">                <span class="tok-kw">return</span> no_path_err; <span class="tok-comment">// return the original error</span>
</span>
<span class="line" id="L1010">            }</span>
<span class="line" id="L1011">        };</span>
<span class="line" id="L1012"></span>
<span class="line" id="L1013">        <span class="tok-kw">if</span> (g_hChildStd_IN_Wr) |h| {</span>
<span class="line" id="L1014">            self.stdin = File{ .handle = h };</span>
<span class="line" id="L1015">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1016">            self.stdin = <span class="tok-null">null</span>;</span>
<span class="line" id="L1017">        }</span>
<span class="line" id="L1018">        <span class="tok-kw">if</span> (g_hChildStd_OUT_Rd) |h| {</span>
<span class="line" id="L1019">            self.stdout = File{ .handle = h };</span>
<span class="line" id="L1020">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1021">            self.stdout = <span class="tok-null">null</span>;</span>
<span class="line" id="L1022">        }</span>
<span class="line" id="L1023">        <span class="tok-kw">if</span> (g_hChildStd_ERR_Rd) |h| {</span>
<span class="line" id="L1024">            self.stderr = File{ .handle = h };</span>
<span class="line" id="L1025">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1026">            self.stderr = <span class="tok-null">null</span>;</span>
<span class="line" id="L1027">        }</span>
<span class="line" id="L1028"></span>
<span class="line" id="L1029">        self.handle = piProcInfo.hProcess;</span>
<span class="line" id="L1030">        self.thread_handle = piProcInfo.hThread;</span>
<span class="line" id="L1031">        self.term = <span class="tok-null">null</span>;</span>
<span class="line" id="L1032"></span>
<span class="line" id="L1033">        <span class="tok-kw">if</span> (self.stdin_behavior == StdIo.Pipe) {</span>
<span class="line" id="L1034">            os.close(g_hChildStd_IN_Rd.?);</span>
<span class="line" id="L1035">        }</span>
<span class="line" id="L1036">        <span class="tok-kw">if</span> (self.stderr_behavior == StdIo.Pipe) {</span>
<span class="line" id="L1037">            os.close(g_hChildStd_ERR_Wr.?);</span>
<span class="line" id="L1038">        }</span>
<span class="line" id="L1039">        <span class="tok-kw">if</span> (self.stdout_behavior == StdIo.Pipe) {</span>
<span class="line" id="L1040">            os.close(g_hChildStd_OUT_Wr.?);</span>
<span class="line" id="L1041">        }</span>
<span class="line" id="L1042">    }</span>
<span class="line" id="L1043"></span>
<span class="line" id="L1044">    <span class="tok-kw">fn</span> <span class="tok-fn">setUpChildIo</span>(stdio: StdIo, pipe_fd: <span class="tok-type">i32</span>, std_fileno: <span class="tok-type">i32</span>, dev_null_fd: <span class="tok-type">i32</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1045">        <span class="tok-kw">switch</span> (stdio) {</span>
<span class="line" id="L1046">            .Pipe =&gt; <span class="tok-kw">try</span> os.dup2(pipe_fd, std_fileno),</span>
<span class="line" id="L1047">            .Close =&gt; os.close(std_fileno),</span>
<span class="line" id="L1048">            .Inherit =&gt; {},</span>
<span class="line" id="L1049">            .Ignore =&gt; <span class="tok-kw">try</span> os.dup2(dev_null_fd, std_fileno),</span>
<span class="line" id="L1050">        }</span>
<span class="line" id="L1051">    }</span>
<span class="line" id="L1052">};</span>
<span class="line" id="L1053"></span>
<span class="line" id="L1054"><span class="tok-kw">fn</span> <span class="tok-fn">windowsCreateProcess</span>(app_name: [*:<span class="tok-number">0</span>]<span class="tok-type">u16</span>, cmd_line: [*:<span class="tok-number">0</span>]<span class="tok-type">u16</span>, envp_ptr: ?[*]<span class="tok-type">u16</span>, cwd_ptr: ?[*:<span class="tok-number">0</span>]<span class="tok-type">u16</span>, lpStartupInfo: *windows.STARTUPINFOW, lpProcessInformation: *windows.PROCESS_INFORMATION) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1055">    <span class="tok-comment">// TODO the docs for environment pointer say:</span>
</span>
<span class="line" id="L1056">    <span class="tok-comment">// &gt; A pointer to the environment block for the new process. If this parameter</span>
</span>
<span class="line" id="L1057">    <span class="tok-comment">// &gt; is NULL, the new process uses the environment of the calling process.</span>
</span>
<span class="line" id="L1058">    <span class="tok-comment">// &gt; ...</span>
</span>
<span class="line" id="L1059">    <span class="tok-comment">// &gt; An environment block can contain either Unicode or ANSI characters. If</span>
</span>
<span class="line" id="L1060">    <span class="tok-comment">// &gt; the environment block pointed to by lpEnvironment contains Unicode</span>
</span>
<span class="line" id="L1061">    <span class="tok-comment">// &gt; characters, be sure that dwCreationFlags includes CREATE_UNICODE_ENVIRONMENT.</span>
</span>
<span class="line" id="L1062">    <span class="tok-comment">// &gt; If this parameter is NULL and the environment block of the parent process</span>
</span>
<span class="line" id="L1063">    <span class="tok-comment">// &gt; contains Unicode characters, you must also ensure that dwCreationFlags</span>
</span>
<span class="line" id="L1064">    <span class="tok-comment">// &gt; includes CREATE_UNICODE_ENVIRONMENT.</span>
</span>
<span class="line" id="L1065">    <span class="tok-comment">// This seems to imply that we have to somehow know whether our process parent passed</span>
</span>
<span class="line" id="L1066">    <span class="tok-comment">// CREATE_UNICODE_ENVIRONMENT if we want to pass NULL for the environment parameter.</span>
</span>
<span class="line" id="L1067">    <span class="tok-comment">// Since we do not know this information that would imply that we must not pass NULL</span>
</span>
<span class="line" id="L1068">    <span class="tok-comment">// for the parameter.</span>
</span>
<span class="line" id="L1069">    <span class="tok-comment">// However this would imply that programs compiled with -DUNICODE could not pass</span>
</span>
<span class="line" id="L1070">    <span class="tok-comment">// environment variables to programs that were not, which seems unlikely.</span>
</span>
<span class="line" id="L1071">    <span class="tok-comment">// More investigation is needed.</span>
</span>
<span class="line" id="L1072">    <span class="tok-kw">return</span> windows.CreateProcessW(</span>
<span class="line" id="L1073">        app_name,</span>
<span class="line" id="L1074">        cmd_line,</span>
<span class="line" id="L1075">        <span class="tok-null">null</span>,</span>
<span class="line" id="L1076">        <span class="tok-null">null</span>,</span>
<span class="line" id="L1077">        windows.TRUE,</span>
<span class="line" id="L1078">        windows.CREATE_UNICODE_ENVIRONMENT,</span>
<span class="line" id="L1079">        <span class="tok-builtin">@ptrCast</span>(?*<span class="tok-type">anyopaque</span>, envp_ptr),</span>
<span class="line" id="L1080">        cwd_ptr,</span>
<span class="line" id="L1081">        lpStartupInfo,</span>
<span class="line" id="L1082">        lpProcessInformation,</span>
<span class="line" id="L1083">    );</span>
<span class="line" id="L1084">}</span>
<span class="line" id="L1085"></span>
<span class="line" id="L1086"><span class="tok-comment">/// Caller must dealloc.</span></span>
<span class="line" id="L1087"><span class="tok-kw">fn</span> <span class="tok-fn">windowsCreateCommandLine</span>(allocator: mem.Allocator, argv: []<span class="tok-kw">const</span> []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![:<span class="tok-number">0</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1088">    <span class="tok-kw">var</span> buf = std.ArrayList(<span class="tok-type">u8</span>).init(allocator);</span>
<span class="line" id="L1089">    <span class="tok-kw">defer</span> buf.deinit();</span>
<span class="line" id="L1090"></span>
<span class="line" id="L1091">    <span class="tok-kw">for</span> (argv) |arg, arg_i| {</span>
<span class="line" id="L1092">        <span class="tok-kw">if</span> (arg_i != <span class="tok-number">0</span>) <span class="tok-kw">try</span> buf.append(<span class="tok-str">' '</span>);</span>
<span class="line" id="L1093">        <span class="tok-kw">if</span> (mem.indexOfAny(<span class="tok-type">u8</span>, arg, <span class="tok-str">&quot; \t\n\&quot;&quot;</span>) == <span class="tok-null">null</span>) {</span>
<span class="line" id="L1094">            <span class="tok-kw">try</span> buf.appendSlice(arg);</span>
<span class="line" id="L1095">            <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1096">        }</span>
<span class="line" id="L1097">        <span class="tok-kw">try</span> buf.append(<span class="tok-str">'&quot;'</span>);</span>
<span class="line" id="L1098">        <span class="tok-kw">var</span> backslash_count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1099">        <span class="tok-kw">for</span> (arg) |byte| {</span>
<span class="line" id="L1100">            <span class="tok-kw">switch</span> (byte) {</span>
<span class="line" id="L1101">                <span class="tok-str">'\\'</span> =&gt; backslash_count += <span class="tok-number">1</span>,</span>
<span class="line" id="L1102">                <span class="tok-str">'&quot;'</span> =&gt; {</span>
<span class="line" id="L1103">                    <span class="tok-kw">try</span> buf.appendNTimes(<span class="tok-str">'\\'</span>, backslash_count * <span class="tok-number">2</span> + <span class="tok-number">1</span>);</span>
<span class="line" id="L1104">                    <span class="tok-kw">try</span> buf.append(<span class="tok-str">'&quot;'</span>);</span>
<span class="line" id="L1105">                    backslash_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L1106">                },</span>
<span class="line" id="L1107">                <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L1108">                    <span class="tok-kw">try</span> buf.appendNTimes(<span class="tok-str">'\\'</span>, backslash_count);</span>
<span class="line" id="L1109">                    <span class="tok-kw">try</span> buf.append(byte);</span>
<span class="line" id="L1110">                    backslash_count = <span class="tok-number">0</span>;</span>
<span class="line" id="L1111">                },</span>
<span class="line" id="L1112">            }</span>
<span class="line" id="L1113">        }</span>
<span class="line" id="L1114">        <span class="tok-kw">try</span> buf.appendNTimes(<span class="tok-str">'\\'</span>, backslash_count * <span class="tok-number">2</span>);</span>
<span class="line" id="L1115">        <span class="tok-kw">try</span> buf.append(<span class="tok-str">'&quot;'</span>);</span>
<span class="line" id="L1116">    }</span>
<span class="line" id="L1117"></span>
<span class="line" id="L1118">    <span class="tok-kw">return</span> buf.toOwnedSliceSentinel(<span class="tok-number">0</span>);</span>
<span class="line" id="L1119">}</span>
<span class="line" id="L1120"></span>
<span class="line" id="L1121"><span class="tok-kw">fn</span> <span class="tok-fn">windowsDestroyPipe</span>(rd: ?windows.HANDLE, wr: ?windows.HANDLE) <span class="tok-type">void</span> {</span>
<span class="line" id="L1122">    <span class="tok-kw">if</span> (rd) |h| os.close(h);</span>
<span class="line" id="L1123">    <span class="tok-kw">if</span> (wr) |h| os.close(h);</span>
<span class="line" id="L1124">}</span>
<span class="line" id="L1125"></span>
<span class="line" id="L1126"><span class="tok-kw">fn</span> <span class="tok-fn">windowsMakePipeIn</span>(rd: *?windows.HANDLE, wr: *?windows.HANDLE, sattr: *<span class="tok-kw">const</span> windows.SECURITY_ATTRIBUTES) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1127">    <span class="tok-kw">var</span> rd_h: windows.HANDLE = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1128">    <span class="tok-kw">var</span> wr_h: windows.HANDLE = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1129">    <span class="tok-kw">try</span> windows.CreatePipe(&amp;rd_h, &amp;wr_h, sattr);</span>
<span class="line" id="L1130">    <span class="tok-kw">errdefer</span> windowsDestroyPipe(rd_h, wr_h);</span>
<span class="line" id="L1131">    <span class="tok-kw">try</span> windows.SetHandleInformation(wr_h, windows.HANDLE_FLAG_INHERIT, <span class="tok-number">0</span>);</span>
<span class="line" id="L1132">    rd.* = rd_h;</span>
<span class="line" id="L1133">    wr.* = wr_h;</span>
<span class="line" id="L1134">}</span>
<span class="line" id="L1135"></span>
<span class="line" id="L1136"><span class="tok-kw">var</span> pipe_name_counter = std.atomic.Atomic(<span class="tok-type">u32</span>).init(<span class="tok-number">1</span>);</span>
<span class="line" id="L1137"></span>
<span class="line" id="L1138"><span class="tok-kw">fn</span> <span class="tok-fn">windowsMakeAsyncPipe</span>(rd: *?windows.HANDLE, wr: *?windows.HANDLE, sattr: *<span class="tok-kw">const</span> windows.SECURITY_ATTRIBUTES) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1139">    <span class="tok-kw">var</span> tmp_bufw: [<span class="tok-number">128</span>]<span class="tok-type">u16</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1140"></span>
<span class="line" id="L1141">    <span class="tok-comment">// Anonymous pipes are built upon Named pipes.</span>
</span>
<span class="line" id="L1142">    <span class="tok-comment">// https://docs.microsoft.com/en-us/windows/win32/api/namedpipeapi/nf-namedpipeapi-createpipe</span>
</span>
<span class="line" id="L1143">    <span class="tok-comment">// Asynchronous (overlapped) read and write operations are not supported by anonymous pipes.</span>
</span>
<span class="line" id="L1144">    <span class="tok-comment">// https://docs.microsoft.com/en-us/windows/win32/ipc/anonymous-pipe-operations</span>
</span>
<span class="line" id="L1145">    <span class="tok-kw">const</span> pipe_path = blk: {</span>
<span class="line" id="L1146">        <span class="tok-kw">var</span> tmp_buf: [<span class="tok-number">128</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1147">        <span class="tok-comment">// Forge a random path for the pipe.</span>
</span>
<span class="line" id="L1148">        <span class="tok-kw">const</span> pipe_path = std.fmt.bufPrintZ(</span>
<span class="line" id="L1149">            &amp;tmp_buf,</span>
<span class="line" id="L1150">            <span class="tok-str">&quot;\\\\.\\pipe\\zig-childprocess-{d}-{d}&quot;</span>,</span>
<span class="line" id="L1151">            .{ windows.kernel32.GetCurrentProcessId(), pipe_name_counter.fetchAdd(<span class="tok-number">1</span>, .Monotonic) },</span>
<span class="line" id="L1152">        ) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1153">        <span class="tok-kw">const</span> len = std.unicode.utf8ToUtf16Le(&amp;tmp_bufw, pipe_path) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L1154">        tmp_bufw[len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L1155">        <span class="tok-kw">break</span> :blk tmp_bufw[<span class="tok-number">0</span>..len :<span class="tok-number">0</span>];</span>
<span class="line" id="L1156">    };</span>
<span class="line" id="L1157"></span>
<span class="line" id="L1158">    <span class="tok-comment">// Create the read handle that can be used with overlapped IO ops.</span>
</span>
<span class="line" id="L1159">    <span class="tok-kw">const</span> read_handle = windows.kernel32.CreateNamedPipeW(</span>
<span class="line" id="L1160">        pipe_path.ptr,</span>
<span class="line" id="L1161">        windows.PIPE_ACCESS_INBOUND | windows.FILE_FLAG_OVERLAPPED,</span>
<span class="line" id="L1162">        windows.PIPE_TYPE_BYTE,</span>
<span class="line" id="L1163">        <span class="tok-number">1</span>,</span>
<span class="line" id="L1164">        <span class="tok-number">4096</span>,</span>
<span class="line" id="L1165">        <span class="tok-number">4096</span>,</span>
<span class="line" id="L1166">        <span class="tok-number">0</span>,</span>
<span class="line" id="L1167">        sattr,</span>
<span class="line" id="L1168">    );</span>
<span class="line" id="L1169">    <span class="tok-kw">if</span> (read_handle == windows.INVALID_HANDLE_VALUE) {</span>
<span class="line" id="L1170">        <span class="tok-kw">switch</span> (windows.kernel32.GetLastError()) {</span>
<span class="line" id="L1171">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1172">        }</span>
<span class="line" id="L1173">    }</span>
<span class="line" id="L1174">    <span class="tok-kw">errdefer</span> os.close(read_handle);</span>
<span class="line" id="L1175"></span>
<span class="line" id="L1176">    <span class="tok-kw">var</span> sattr_copy = sattr.*;</span>
<span class="line" id="L1177">    <span class="tok-kw">const</span> write_handle = windows.kernel32.CreateFileW(</span>
<span class="line" id="L1178">        pipe_path.ptr,</span>
<span class="line" id="L1179">        windows.GENERIC_WRITE,</span>
<span class="line" id="L1180">        <span class="tok-number">0</span>,</span>
<span class="line" id="L1181">        &amp;sattr_copy,</span>
<span class="line" id="L1182">        windows.OPEN_EXISTING,</span>
<span class="line" id="L1183">        windows.FILE_ATTRIBUTE_NORMAL,</span>
<span class="line" id="L1184">        <span class="tok-null">null</span>,</span>
<span class="line" id="L1185">    );</span>
<span class="line" id="L1186">    <span class="tok-kw">if</span> (write_handle == windows.INVALID_HANDLE_VALUE) {</span>
<span class="line" id="L1187">        <span class="tok-kw">switch</span> (windows.kernel32.GetLastError()) {</span>
<span class="line" id="L1188">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> windows.unexpectedError(err),</span>
<span class="line" id="L1189">        }</span>
<span class="line" id="L1190">    }</span>
<span class="line" id="L1191">    <span class="tok-kw">errdefer</span> os.close(write_handle);</span>
<span class="line" id="L1192"></span>
<span class="line" id="L1193">    <span class="tok-kw">try</span> windows.SetHandleInformation(read_handle, windows.HANDLE_FLAG_INHERIT, <span class="tok-number">0</span>);</span>
<span class="line" id="L1194"></span>
<span class="line" id="L1195">    rd.* = read_handle;</span>
<span class="line" id="L1196">    wr.* = write_handle;</span>
<span class="line" id="L1197">}</span>
<span class="line" id="L1198"></span>
<span class="line" id="L1199"><span class="tok-kw">fn</span> <span class="tok-fn">destroyPipe</span>(pipe: [<span class="tok-number">2</span>]os.fd_t) <span class="tok-type">void</span> {</span>
<span class="line" id="L1200">    os.close(pipe[<span class="tok-number">0</span>]);</span>
<span class="line" id="L1201">    <span class="tok-kw">if</span> (pipe[<span class="tok-number">0</span>] != pipe[<span class="tok-number">1</span>]) os.close(pipe[<span class="tok-number">1</span>]);</span>
<span class="line" id="L1202">}</span>
<span class="line" id="L1203"></span>
<span class="line" id="L1204"><span class="tok-comment">// Child of fork calls this to report an error to the fork parent.</span>
</span>
<span class="line" id="L1205"><span class="tok-comment">// Then the child exits.</span>
</span>
<span class="line" id="L1206"><span class="tok-kw">fn</span> <span class="tok-fn">forkChildErrReport</span>(fd: <span class="tok-type">i32</span>, err: ChildProcess.SpawnError) <span class="tok-type">noreturn</span> {</span>
<span class="line" id="L1207">    writeIntFd(fd, <span class="tok-builtin">@as</span>(ErrInt, <span class="tok-builtin">@errorToInt</span>(err))) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L1208">    <span class="tok-comment">// If we're linking libc, some naughty applications may have registered atexit handlers</span>
</span>
<span class="line" id="L1209">    <span class="tok-comment">// which we really do not want to run in the fork child. I caught LLVM doing this and</span>
</span>
<span class="line" id="L1210">    <span class="tok-comment">// it caused a deadlock instead of doing an exit syscall. In the words of Avril Lavigne,</span>
</span>
<span class="line" id="L1211">    <span class="tok-comment">// &quot;Why'd you have to go and make things so complicated?&quot;</span>
</span>
<span class="line" id="L1212">    <span class="tok-kw">if</span> (builtin.link_libc) {</span>
<span class="line" id="L1213">        <span class="tok-comment">// The _exit(2) function does nothing but make the exit syscall, unlike exit(3)</span>
</span>
<span class="line" id="L1214">        std.c._exit(<span class="tok-number">1</span>);</span>
<span class="line" id="L1215">    }</span>
<span class="line" id="L1216">    os.exit(<span class="tok-number">1</span>);</span>
<span class="line" id="L1217">}</span>
<span class="line" id="L1218"></span>
<span class="line" id="L1219"><span class="tok-kw">const</span> ErrInt = std.meta.Int(.unsigned, <span class="tok-builtin">@sizeOf</span>(<span class="tok-type">anyerror</span>) * <span class="tok-number">8</span>);</span>
<span class="line" id="L1220"></span>
<span class="line" id="L1221"><span class="tok-kw">fn</span> <span class="tok-fn">writeIntFd</span>(fd: <span class="tok-type">i32</span>, value: ErrInt) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1222">    <span class="tok-kw">const</span> file = File{</span>
<span class="line" id="L1223">        .handle = fd,</span>
<span class="line" id="L1224">        .capable_io_mode = .blocking,</span>
<span class="line" id="L1225">        .intended_io_mode = .blocking,</span>
<span class="line" id="L1226">    };</span>
<span class="line" id="L1227">    file.writer().writeIntNative(<span class="tok-type">u64</span>, <span class="tok-builtin">@intCast</span>(<span class="tok-type">u64</span>, value)) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources;</span>
<span class="line" id="L1228">}</span>
<span class="line" id="L1229"></span>
<span class="line" id="L1230"><span class="tok-kw">fn</span> <span class="tok-fn">readIntFd</span>(fd: <span class="tok-type">i32</span>) !ErrInt {</span>
<span class="line" id="L1231">    <span class="tok-kw">const</span> file = File{</span>
<span class="line" id="L1232">        .handle = fd,</span>
<span class="line" id="L1233">        .capable_io_mode = .blocking,</span>
<span class="line" id="L1234">        .intended_io_mode = .blocking,</span>
<span class="line" id="L1235">    };</span>
<span class="line" id="L1236">    <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(ErrInt, file.reader().readIntNative(<span class="tok-type">u64</span>) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources);</span>
<span class="line" id="L1237">}</span>
<span class="line" id="L1238"></span>
<span class="line" id="L1239"><span class="tok-comment">/// Caller must free result.</span></span>
<span class="line" id="L1240"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createWindowsEnvBlock</span>(allocator: mem.Allocator, env_map: *<span class="tok-kw">const</span> EnvMap) ![]<span class="tok-type">u16</span> {</span>
<span class="line" id="L1241">    <span class="tok-comment">// count bytes needed</span>
</span>
<span class="line" id="L1242">    <span class="tok-kw">const</span> max_chars_needed = x: {</span>
<span class="line" id="L1243">        <span class="tok-kw">var</span> max_chars_needed: <span class="tok-type">usize</span> = <span class="tok-number">4</span>; <span class="tok-comment">// 4 for the final 4 null bytes</span>
</span>
<span class="line" id="L1244">        <span class="tok-kw">var</span> it = env_map.iterator();</span>
<span class="line" id="L1245">        <span class="tok-kw">while</span> (it.next()) |pair| {</span>
<span class="line" id="L1246">            <span class="tok-comment">// +1 for '='</span>
</span>
<span class="line" id="L1247">            <span class="tok-comment">// +1 for null byte</span>
</span>
<span class="line" id="L1248">            max_chars_needed += pair.key_ptr.len + pair.value_ptr.len + <span class="tok-number">2</span>;</span>
<span class="line" id="L1249">        }</span>
<span class="line" id="L1250">        <span class="tok-kw">break</span> :x max_chars_needed;</span>
<span class="line" id="L1251">    };</span>
<span class="line" id="L1252">    <span class="tok-kw">const</span> result = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u16</span>, max_chars_needed);</span>
<span class="line" id="L1253">    <span class="tok-kw">errdefer</span> allocator.free(result);</span>
<span class="line" id="L1254"></span>
<span class="line" id="L1255">    <span class="tok-kw">var</span> it = env_map.iterator();</span>
<span class="line" id="L1256">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1257">    <span class="tok-kw">while</span> (it.next()) |pair| {</span>
<span class="line" id="L1258">        i += <span class="tok-kw">try</span> unicode.utf8ToUtf16Le(result[i..], pair.key_ptr.*);</span>
<span class="line" id="L1259">        result[i] = <span class="tok-str">'='</span>;</span>
<span class="line" id="L1260">        i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1261">        i += <span class="tok-kw">try</span> unicode.utf8ToUtf16Le(result[i..], pair.value_ptr.*);</span>
<span class="line" id="L1262">        result[i] = <span class="tok-number">0</span>;</span>
<span class="line" id="L1263">        i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1264">    }</span>
<span class="line" id="L1265">    result[i] = <span class="tok-number">0</span>;</span>
<span class="line" id="L1266">    i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1267">    result[i] = <span class="tok-number">0</span>;</span>
<span class="line" id="L1268">    i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1269">    result[i] = <span class="tok-number">0</span>;</span>
<span class="line" id="L1270">    i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1271">    result[i] = <span class="tok-number">0</span>;</span>
<span class="line" id="L1272">    i += <span class="tok-number">1</span>;</span>
<span class="line" id="L1273">    <span class="tok-kw">return</span> allocator.shrink(result, i);</span>
<span class="line" id="L1274">}</span>
<span class="line" id="L1275"></span>
<span class="line" id="L1276"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createNullDelimitedEnvMap</span>(arena: mem.Allocator, env_map: *<span class="tok-kw">const</span> EnvMap) ![:<span class="tok-null">null</span>]?[*:<span class="tok-number">0</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1277">    <span class="tok-kw">const</span> envp_count = env_map.count();</span>
<span class="line" id="L1278">    <span class="tok-kw">const</span> envp_buf = <span class="tok-kw">try</span> arena.allocSentinel(?[*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, envp_count, <span class="tok-null">null</span>);</span>
<span class="line" id="L1279">    {</span>
<span class="line" id="L1280">        <span class="tok-kw">var</span> it = env_map.iterator();</span>
<span class="line" id="L1281">        <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L1282">        <span class="tok-kw">while</span> (it.next()) |pair| : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L1283">            <span class="tok-kw">const</span> env_buf = <span class="tok-kw">try</span> arena.allocSentinel(<span class="tok-type">u8</span>, pair.key_ptr.len + pair.value_ptr.len + <span class="tok-number">1</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1284">            mem.copy(<span class="tok-type">u8</span>, env_buf, pair.key_ptr.*);</span>
<span class="line" id="L1285">            env_buf[pair.key_ptr.len] = <span class="tok-str">'='</span>;</span>
<span class="line" id="L1286">            mem.copy(<span class="tok-type">u8</span>, env_buf[pair.key_ptr.len + <span class="tok-number">1</span> ..], pair.value_ptr.*);</span>
<span class="line" id="L1287">            envp_buf[i] = env_buf.ptr;</span>
<span class="line" id="L1288">        }</span>
<span class="line" id="L1289">        assert(i == envp_count);</span>
<span class="line" id="L1290">    }</span>
<span class="line" id="L1291">    <span class="tok-kw">return</span> envp_buf;</span>
<span class="line" id="L1292">}</span>
<span class="line" id="L1293"></span>
<span class="line" id="L1294"><span class="tok-kw">test</span> <span class="tok-str">&quot;createNullDelimitedEnvMap&quot;</span> {</span>
<span class="line" id="L1295">    <span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L1296">    <span class="tok-kw">const</span> allocator = testing.allocator;</span>
<span class="line" id="L1297">    <span class="tok-kw">var</span> envmap = EnvMap.init(allocator);</span>
<span class="line" id="L1298">    <span class="tok-kw">defer</span> envmap.deinit();</span>
<span class="line" id="L1299"></span>
<span class="line" id="L1300">    <span class="tok-kw">try</span> envmap.put(<span class="tok-str">&quot;HOME&quot;</span>, <span class="tok-str">&quot;/home/ifreund&quot;</span>);</span>
<span class="line" id="L1301">    <span class="tok-kw">try</span> envmap.put(<span class="tok-str">&quot;WAYLAND_DISPLAY&quot;</span>, <span class="tok-str">&quot;wayland-1&quot;</span>);</span>
<span class="line" id="L1302">    <span class="tok-kw">try</span> envmap.put(<span class="tok-str">&quot;DISPLAY&quot;</span>, <span class="tok-str">&quot;:1&quot;</span>);</span>
<span class="line" id="L1303">    <span class="tok-kw">try</span> envmap.put(<span class="tok-str">&quot;DEBUGINFOD_URLS&quot;</span>, <span class="tok-str">&quot; &quot;</span>);</span>
<span class="line" id="L1304">    <span class="tok-kw">try</span> envmap.put(<span class="tok-str">&quot;XCURSOR_SIZE&quot;</span>, <span class="tok-str">&quot;24&quot;</span>);</span>
<span class="line" id="L1305"></span>
<span class="line" id="L1306">    <span class="tok-kw">var</span> arena = std.heap.ArenaAllocator.init(allocator);</span>
<span class="line" id="L1307">    <span class="tok-kw">defer</span> arena.deinit();</span>
<span class="line" id="L1308">    <span class="tok-kw">const</span> environ = <span class="tok-kw">try</span> createNullDelimitedEnvMap(arena.allocator(), &amp;envmap);</span>
<span class="line" id="L1309"></span>
<span class="line" id="L1310">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">5</span>), environ.len);</span>
<span class="line" id="L1311"></span>
<span class="line" id="L1312">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (.{</span>
<span class="line" id="L1313">        <span class="tok-str">&quot;HOME=/home/ifreund&quot;</span>,</span>
<span class="line" id="L1314">        <span class="tok-str">&quot;WAYLAND_DISPLAY=wayland-1&quot;</span>,</span>
<span class="line" id="L1315">        <span class="tok-str">&quot;DISPLAY=:1&quot;</span>,</span>
<span class="line" id="L1316">        <span class="tok-str">&quot;DEBUGINFOD_URLS= &quot;</span>,</span>
<span class="line" id="L1317">        <span class="tok-str">&quot;XCURSOR_SIZE=24&quot;</span>,</span>
<span class="line" id="L1318">    }) |target| {</span>
<span class="line" id="L1319">        <span class="tok-kw">for</span> (environ) |variable| {</span>
<span class="line" id="L1320">            <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, mem.span(variable <span class="tok-kw">orelse</span> <span class="tok-kw">continue</span>), target)) <span class="tok-kw">break</span>;</span>
<span class="line" id="L1321">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1322">            <span class="tok-kw">try</span> testing.expect(<span class="tok-null">false</span>); <span class="tok-comment">// Environment variable not found</span>
</span>
<span class="line" id="L1323">        }</span>
<span class="line" id="L1324">    }</span>
<span class="line" id="L1325">}</span>
<span class="line" id="L1326"></span>
</code></pre></body>
</html>