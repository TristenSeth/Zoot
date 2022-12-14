<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/posix_spawn.zig - source view</title>
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
<span class="line" id="L3"></span>
<span class="line" id="L4"><span class="tok-kw">const</span> os = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../os.zig&quot;</span>);</span>
<span class="line" id="L5"><span class="tok-kw">const</span> system = os.system;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> errno = system.getErrno;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> fd_t = system.fd_t;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> mode_t = system.mode_t;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> pid_t = system.pid_t;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> unexpectedErrno = os.unexpectedErrno;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> UnexpectedError = os.UnexpectedError;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> toPosixPath = os.toPosixPath;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> WaitPidResult = os.WaitPidResult;</span>
<span class="line" id="L14"></span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> posix_spawn;</span>
<span class="line" id="L16"></span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = <span class="tok-kw">error</span>{</span>
<span class="line" id="L18">    SystemResources,</span>
<span class="line" id="L19">    InvalidFileDescriptor,</span>
<span class="line" id="L20">    NameTooLong,</span>
<span class="line" id="L21">    TooBig,</span>
<span class="line" id="L22">    PermissionDenied,</span>
<span class="line" id="L23">    InputOutput,</span>
<span class="line" id="L24">    FileSystem,</span>
<span class="line" id="L25">    FileNotFound,</span>
<span class="line" id="L26">    InvalidExe,</span>
<span class="line" id="L27">    NotDir,</span>
<span class="line" id="L28">    FileBusy,</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">    <span class="tok-comment">/// Returned when the child fails to execute either in the pre-exec() initialization step, or</span></span>
<span class="line" id="L31">    <span class="tok-comment">/// when exec(3) is invoked.</span></span>
<span class="line" id="L32">    ChildExecFailed,</span>
<span class="line" id="L33">} || UnexpectedError;</span>
<span class="line" id="L34"></span>
<span class="line" id="L35"><span class="tok-kw">const</span> posix_spawn = <span class="tok-kw">if</span> (builtin.target.isDarwin()) <span class="tok-kw">struct</span> {</span>
<span class="line" id="L36">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Attr = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L37">        attr: system.posix_spawnattr_t,</span>
<span class="line" id="L38"></span>
<span class="line" id="L39">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>() Error!Attr {</span>
<span class="line" id="L40">            <span class="tok-kw">var</span> attr: system.posix_spawnattr_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L41">            <span class="tok-kw">switch</span> (errno(system.posix_spawnattr_init(&amp;attr))) {</span>
<span class="line" id="L42">                .SUCCESS =&gt; <span class="tok-kw">return</span> Attr{ .attr = attr },</span>
<span class="line" id="L43">                .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L44">                .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L45">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L46">            }</span>
<span class="line" id="L47">        }</span>
<span class="line" id="L48"></span>
<span class="line" id="L49">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Attr) <span class="tok-type">void</span> {</span>
<span class="line" id="L50">            system.posix_spawnattr_destroy(&amp;self.attr);</span>
<span class="line" id="L51">            self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L52">        }</span>
<span class="line" id="L53"></span>
<span class="line" id="L54">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get</span>(self: Attr) Error!<span class="tok-type">u16</span> {</span>
<span class="line" id="L55">            <span class="tok-kw">var</span> flags: <span class="tok-type">c_short</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L56">            <span class="tok-kw">switch</span> (errno(system.posix_spawnattr_getflags(&amp;self.attr, &amp;flags))) {</span>
<span class="line" id="L57">                .SUCCESS =&gt; <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u16</span>, flags),</span>
<span class="line" id="L58">                .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L59">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L60">            }</span>
<span class="line" id="L61">        }</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">set</span>(self: *Attr, flags: <span class="tok-type">u16</span>) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L64">            <span class="tok-kw">switch</span> (errno(system.posix_spawnattr_setflags(&amp;self.attr, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">c_short</span>, flags)))) {</span>
<span class="line" id="L65">                .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L66">                .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L67">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L68">            }</span>
<span class="line" id="L69">        }</span>
<span class="line" id="L70">    };</span>
<span class="line" id="L71"></span>
<span class="line" id="L72">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Actions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L73">        actions: system.posix_spawn_file_actions_t,</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>() Error!Actions {</span>
<span class="line" id="L76">            <span class="tok-kw">var</span> actions: system.posix_spawn_file_actions_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L77">            <span class="tok-kw">switch</span> (errno(system.posix_spawn_file_actions_init(&amp;actions))) {</span>
<span class="line" id="L78">                .SUCCESS =&gt; <span class="tok-kw">return</span> Actions{ .actions = actions },</span>
<span class="line" id="L79">                .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L80">                .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L81">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L82">            }</span>
<span class="line" id="L83">        }</span>
<span class="line" id="L84"></span>
<span class="line" id="L85">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Actions) <span class="tok-type">void</span> {</span>
<span class="line" id="L86">            system.posix_spawn_file_actions_destroy(&amp;self.actions);</span>
<span class="line" id="L87">            self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L88">        }</span>
<span class="line" id="L89"></span>
<span class="line" id="L90">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">open</span>(self: *Actions, fd: fd_t, path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>, mode: mode_t) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L91">            <span class="tok-kw">const</span> posix_path = <span class="tok-kw">try</span> toPosixPath(path);</span>
<span class="line" id="L92">            <span class="tok-kw">return</span> self.openZ(fd, &amp;posix_path, flags, mode);</span>
<span class="line" id="L93">        }</span>
<span class="line" id="L94"></span>
<span class="line" id="L95">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openZ</span>(self: *Actions, fd: fd_t, path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>, mode: mode_t) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L96">            <span class="tok-kw">switch</span> (errno(system.posix_spawn_file_actions_addopen(&amp;self.actions, fd, path, <span class="tok-builtin">@bitCast</span>(<span class="tok-type">c_int</span>, flags), mode))) {</span>
<span class="line" id="L97">                .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L98">                .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidFileDescriptor,</span>
<span class="line" id="L99">                .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L100">                .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L101">                .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// the value of file actions is invalid</span>
</span>
<span class="line" id="L102">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L103">            }</span>
<span class="line" id="L104">        }</span>
<span class="line" id="L105"></span>
<span class="line" id="L106">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">close</span>(self: *Actions, fd: fd_t) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L107">            <span class="tok-kw">switch</span> (errno(system.posix_spawn_file_actions_addclose(&amp;self.actions, fd))) {</span>
<span class="line" id="L108">                .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L109">                .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidFileDescriptor,</span>
<span class="line" id="L110">                .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L111">                .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// the value of file actions is invalid</span>
</span>
<span class="line" id="L112">                .NAMETOOLONG =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L113">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L114">            }</span>
<span class="line" id="L115">        }</span>
<span class="line" id="L116"></span>
<span class="line" id="L117">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">dup2</span>(self: *Actions, fd: fd_t, newfd: fd_t) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L118">            <span class="tok-kw">switch</span> (errno(system.posix_spawn_file_actions_adddup2(&amp;self.actions, fd, newfd))) {</span>
<span class="line" id="L119">                .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L120">                .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidFileDescriptor,</span>
<span class="line" id="L121">                .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L122">                .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// the value of file actions is invalid</span>
</span>
<span class="line" id="L123">                .NAMETOOLONG =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L124">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L125">            }</span>
<span class="line" id="L126">        }</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">inherit</span>(self: *Actions, fd: fd_t) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L129">            <span class="tok-kw">switch</span> (errno(system.posix_spawn_file_actions_addinherit_np(&amp;self.actions, fd))) {</span>
<span class="line" id="L130">                .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L131">                .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidFileDescriptor,</span>
<span class="line" id="L132">                .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L133">                .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// the value of file actions is invalid</span>
</span>
<span class="line" id="L134">                .NAMETOOLONG =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L135">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L136">            }</span>
<span class="line" id="L137">        }</span>
<span class="line" id="L138"></span>
<span class="line" id="L139">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">chdir</span>(self: *Actions, path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L140">            <span class="tok-kw">const</span> posix_path = <span class="tok-kw">try</span> toPosixPath(path);</span>
<span class="line" id="L141">            <span class="tok-kw">return</span> self.chdirZ(&amp;posix_path);</span>
<span class="line" id="L142">        }</span>
<span class="line" id="L143"></span>
<span class="line" id="L144">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">chdirZ</span>(self: *Actions, path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L145">            <span class="tok-kw">switch</span> (errno(system.posix_spawn_file_actions_addchdir_np(&amp;self.actions, path))) {</span>
<span class="line" id="L146">                .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L147">                .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L148">                .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L149">                .BADF =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L150">                .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// the value of file actions is invalid</span>
</span>
<span class="line" id="L151">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L152">            }</span>
<span class="line" id="L153">        }</span>
<span class="line" id="L154"></span>
<span class="line" id="L155">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fchdir</span>(self: *Actions, fd: fd_t) Error!<span class="tok-type">void</span> {</span>
<span class="line" id="L156">            <span class="tok-kw">switch</span> (errno(system.posix_spawn_file_actions_addfchdir_np(&amp;self.actions, fd))) {</span>
<span class="line" id="L157">                .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L158">                .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidFileDescriptor,</span>
<span class="line" id="L159">                .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L160">                .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// the value of file actions is invalid</span>
</span>
<span class="line" id="L161">                .NAMETOOLONG =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L162">                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L163">            }</span>
<span class="line" id="L164">        }</span>
<span class="line" id="L165">    };</span>
<span class="line" id="L166"></span>
<span class="line" id="L167">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">spawn</span>(</span>
<span class="line" id="L168">        path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L169">        actions: ?Actions,</span>
<span class="line" id="L170">        attr: ?Attr,</span>
<span class="line" id="L171">        argv: [*:<span class="tok-null">null</span>]?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L172">        envp: [*:<span class="tok-null">null</span>]?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L173">    ) Error!pid_t {</span>
<span class="line" id="L174">        <span class="tok-kw">const</span> posix_path = <span class="tok-kw">try</span> toPosixPath(path);</span>
<span class="line" id="L175">        <span class="tok-kw">return</span> spawnZ(&amp;posix_path, actions, attr, argv, envp);</span>
<span class="line" id="L176">    }</span>
<span class="line" id="L177"></span>
<span class="line" id="L178">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">spawnZ</span>(</span>
<span class="line" id="L179">        path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L180">        actions: ?Actions,</span>
<span class="line" id="L181">        attr: ?Attr,</span>
<span class="line" id="L182">        argv: [*:<span class="tok-null">null</span>]?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L183">        envp: [*:<span class="tok-null">null</span>]?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L184">    ) Error!pid_t {</span>
<span class="line" id="L185">        <span class="tok-kw">var</span> pid: pid_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L186">        <span class="tok-kw">switch</span> (errno(system.posix_spawn(</span>
<span class="line" id="L187">            &amp;pid,</span>
<span class="line" id="L188">            path,</span>
<span class="line" id="L189">            <span class="tok-kw">if</span> (actions) |a| &amp;a.actions <span class="tok-kw">else</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L190">            <span class="tok-kw">if</span> (attr) |a| &amp;a.attr <span class="tok-kw">else</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L191">            argv,</span>
<span class="line" id="L192">            envp,</span>
<span class="line" id="L193">        ))) {</span>
<span class="line" id="L194">            .SUCCESS =&gt; <span class="tok-kw">return</span> pid,</span>
<span class="line" id="L195">            .@&quot;2BIG&quot; =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TooBig,</span>
<span class="line" id="L196">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L197">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidFileDescriptor,</span>
<span class="line" id="L198">            .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L199">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L200">            .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L201">            .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L202">            .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L203">            .NOEXEC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidExe,</span>
<span class="line" id="L204">            .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L205">            .TXTBSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileBusy,</span>
<span class="line" id="L206">            .BADARCH =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidExe,</span>
<span class="line" id="L207">            .BADEXEC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidExe,</span>
<span class="line" id="L208">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L209">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L210">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L211">        }</span>
<span class="line" id="L212">    }</span>
<span class="line" id="L213"></span>
<span class="line" id="L214">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">spawnp</span>(</span>
<span class="line" id="L215">        file: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L216">        actions: ?Actions,</span>
<span class="line" id="L217">        attr: ?Attr,</span>
<span class="line" id="L218">        argv: [*:<span class="tok-null">null</span>]?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L219">        envp: [*:<span class="tok-null">null</span>]?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L220">    ) Error!pid_t {</span>
<span class="line" id="L221">        <span class="tok-kw">const</span> posix_file = <span class="tok-kw">try</span> toPosixPath(file);</span>
<span class="line" id="L222">        <span class="tok-kw">return</span> spawnpZ(&amp;posix_file, actions, attr, argv, envp);</span>
<span class="line" id="L223">    }</span>
<span class="line" id="L224"></span>
<span class="line" id="L225">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">spawnpZ</span>(</span>
<span class="line" id="L226">        file: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L227">        actions: ?Actions,</span>
<span class="line" id="L228">        attr: ?Attr,</span>
<span class="line" id="L229">        argv: [*:<span class="tok-null">null</span>]?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L230">        envp: [*:<span class="tok-null">null</span>]?[*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L231">    ) Error!pid_t {</span>
<span class="line" id="L232">        <span class="tok-kw">var</span> pid: pid_t = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L233">        <span class="tok-kw">switch</span> (errno(system.posix_spawnp(</span>
<span class="line" id="L234">            &amp;pid,</span>
<span class="line" id="L235">            file,</span>
<span class="line" id="L236">            <span class="tok-kw">if</span> (actions) |a| &amp;a.actions <span class="tok-kw">else</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L237">            <span class="tok-kw">if</span> (attr) |a| &amp;a.attr <span class="tok-kw">else</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L238">            argv,</span>
<span class="line" id="L239">            envp,</span>
<span class="line" id="L240">        ))) {</span>
<span class="line" id="L241">            .SUCCESS =&gt; <span class="tok-kw">return</span> pid,</span>
<span class="line" id="L242">            .@&quot;2BIG&quot; =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.TooBig,</span>
<span class="line" id="L243">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L244">            .BADF =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidFileDescriptor,</span>
<span class="line" id="L245">            .ACCES =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.PermissionDenied,</span>
<span class="line" id="L246">            .IO =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InputOutput,</span>
<span class="line" id="L247">            .LOOP =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L248">            .NAMETOOLONG =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L249">            .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L250">            .NOEXEC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidExe,</span>
<span class="line" id="L251">            .NOTDIR =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L252">            .TXTBSY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileBusy,</span>
<span class="line" id="L253">            .BADARCH =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidExe,</span>
<span class="line" id="L254">            .BADEXEC =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidExe,</span>
<span class="line" id="L255">            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L256">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L257">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> unexpectedErrno(err),</span>
<span class="line" id="L258">        }</span>
<span class="line" id="L259">    }</span>
<span class="line" id="L260"></span>
<span class="line" id="L261">    <span class="tok-comment">/// Use this version of the `waitpid` wrapper if you spawned your child process using `posix_spawn`</span></span>
<span class="line" id="L262">    <span class="tok-comment">/// or `posix_spawnp` syscalls.</span></span>
<span class="line" id="L263">    <span class="tok-comment">/// See also `std.os.waitpid` for an alternative if your child process was spawned via `fork` and</span></span>
<span class="line" id="L264">    <span class="tok-comment">/// `execve` method.</span></span>
<span class="line" id="L265">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">waitpid</span>(pid: pid_t, flags: <span class="tok-type">u32</span>) Error!WaitPidResult {</span>
<span class="line" id="L266">        <span class="tok-kw">const</span> Status = <span class="tok-kw">if</span> (builtin.link_libc) <span class="tok-type">c_int</span> <span class="tok-kw">else</span> <span class="tok-type">u32</span>;</span>
<span class="line" id="L267">        <span class="tok-kw">var</span> status: Status = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L268">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L269">            <span class="tok-kw">const</span> rc = system.waitpid(pid, &amp;status, <span class="tok-kw">if</span> (builtin.link_libc) <span class="tok-builtin">@intCast</span>(<span class="tok-type">c_int</span>, flags) <span class="tok-kw">else</span> flags);</span>
<span class="line" id="L270">            <span class="tok-kw">switch</span> (errno(rc)) {</span>
<span class="line" id="L271">                .SUCCESS =&gt; <span class="tok-kw">return</span> WaitPidResult{</span>
<span class="line" id="L272">                    .pid = <span class="tok-builtin">@intCast</span>(pid_t, rc),</span>
<span class="line" id="L273">                    .status = <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u32</span>, status),</span>
<span class="line" id="L274">                },</span>
<span class="line" id="L275">                .INTR =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L276">                .CHILD =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.ChildExecFailed,</span>
<span class="line" id="L277">                .INVAL =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Invalid flags.</span>
</span>
<span class="line" id="L278">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L279">            }</span>
<span class="line" id="L280">        }</span>
<span class="line" id="L281">    }</span>
<span class="line" id="L282">} <span class="tok-kw">else</span> <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L283"></span>
</code></pre></body>
</html>