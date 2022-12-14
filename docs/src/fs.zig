<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>fs.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> root = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;root&quot;</span>);</span>
<span class="line" id="L4"><span class="tok-kw">const</span> os = std.os;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> mem = std.mem;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> base64 = std.base64;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> crypto = std.crypto;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> math = std.math;</span>
<span class="line" id="L11"></span>
<span class="line" id="L12"><span class="tok-kw">const</span> is_darwin = builtin.os.tag.isDarwin();</span>
<span class="line" id="L13"></span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> path = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;fs/path.zig&quot;</span>);</span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> File = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;fs/file.zig&quot;</span>).File;</span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> wasi = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;fs/wasi.zig&quot;</span>);</span>
<span class="line" id="L17"></span>
<span class="line" id="L18"><span class="tok-comment">// TODO audit these APIs with respect to Dir and absolute paths</span>
</span>
<span class="line" id="L19"></span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> realpath = os.realpath;</span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> realpathZ = os.realpathZ;</span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> realpathW = os.realpathW;</span>
<span class="line" id="L23"></span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> getAppDataDir = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;fs/get_app_data_dir.zig&quot;</span>).getAppDataDir;</span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GetAppDataDirError = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;fs/get_app_data_dir.zig&quot;</span>).GetAppDataDirError;</span>
<span class="line" id="L26"></span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Watch = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;fs/watch.zig&quot;</span>).Watch;</span>
<span class="line" id="L28"></span>
<span class="line" id="L29"><span class="tok-comment">/// This represents the maximum size of a UTF-8 encoded file path that the</span></span>
<span class="line" id="L30"><span class="tok-comment">/// operating system will accept. Paths, including those returned from file</span></span>
<span class="line" id="L31"><span class="tok-comment">/// system operations, may be longer than this length, but such paths cannot</span></span>
<span class="line" id="L32"><span class="tok-comment">/// be successfully passed back in other file system operations. However,</span></span>
<span class="line" id="L33"><span class="tok-comment">/// all path components returned by file system operations are assumed to</span></span>
<span class="line" id="L34"><span class="tok-comment">/// fit into a UTF-8 encoded array of this length.</span></span>
<span class="line" id="L35"><span class="tok-comment">/// The byte count includes room for a null sentinel byte.</span></span>
<span class="line" id="L36"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MAX_PATH_BYTES = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L37">    .linux, .macos, .ios, .freebsd, .netbsd, .dragonfly, .openbsd, .haiku, .solaris =&gt; os.PATH_MAX,</span>
<span class="line" id="L38">    <span class="tok-comment">// Each UTF-16LE character may be expanded to 3 UTF-8 bytes.</span>
</span>
<span class="line" id="L39">    <span class="tok-comment">// If it would require 4 UTF-8 bytes, then there would be a surrogate</span>
</span>
<span class="line" id="L40">    <span class="tok-comment">// pair in the UTF-16LE, and we (over)account 3 bytes for it that way.</span>
</span>
<span class="line" id="L41">    <span class="tok-comment">// +1 for the null byte at the end, which can be encoded in 1 byte.</span>
</span>
<span class="line" id="L42">    .windows =&gt; os.windows.PATH_MAX_WIDE * <span class="tok-number">3</span> + <span class="tok-number">1</span>,</span>
<span class="line" id="L43">    <span class="tok-comment">// TODO work out what a reasonable value we should use here</span>
</span>
<span class="line" id="L44">    .wasi =&gt; <span class="tok-number">4096</span>,</span>
<span class="line" id="L45">    <span class="tok-kw">else</span> =&gt; <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(root, <span class="tok-str">&quot;os&quot;</span>) <span class="tok-kw">and</span> <span class="tok-builtin">@hasDecl</span>(root.os, <span class="tok-str">&quot;PATH_MAX&quot;</span>))</span>
<span class="line" id="L46">        root.os.PATH_MAX</span>
<span class="line" id="L47">    <span class="tok-kw">else</span></span>
<span class="line" id="L48">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;PATH_MAX not implemented for &quot;</span> ++ <span class="tok-builtin">@tagName</span>(builtin.os.tag)),</span>
<span class="line" id="L49">};</span>
<span class="line" id="L50"></span>
<span class="line" id="L51"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> base64_alphabet = <span class="tok-str">&quot;ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_&quot;</span>.*;</span>
<span class="line" id="L52"></span>
<span class="line" id="L53"><span class="tok-comment">/// Base64 encoder, replacing the standard `+/` with `-_` so that it can be used in a file name on any filesystem.</span></span>
<span class="line" id="L54"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> base64_encoder = base64.Base64Encoder.init(base64_alphabet, <span class="tok-null">null</span>);</span>
<span class="line" id="L55"></span>
<span class="line" id="L56"><span class="tok-comment">/// Base64 decoder, replacing the standard `+/` with `-_` so that it can be used in a file name on any filesystem.</span></span>
<span class="line" id="L57"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> base64_decoder = base64.Base64Decoder.init(base64_alphabet, <span class="tok-null">null</span>);</span>
<span class="line" id="L58"></span>
<span class="line" id="L59"><span class="tok-comment">/// Whether or not async file system syscalls need a dedicated thread because the operating</span></span>
<span class="line" id="L60"><span class="tok-comment">/// system does not support non-blocking I/O on the file system.</span></span>
<span class="line" id="L61"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> need_async_thread = std.io.is_async <span class="tok-kw">and</span> <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L62">    .windows, .other =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L63">    <span class="tok-kw">else</span> =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L64">};</span>
<span class="line" id="L65"></span>
<span class="line" id="L66"><span class="tok-comment">/// TODO remove the allocator requirement from this API</span></span>
<span class="line" id="L67"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">atomicSymLink</span>(allocator: Allocator, existing_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, new_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L68">    <span class="tok-kw">if</span> (cwd().symLink(existing_path, new_path, .{})) {</span>
<span class="line" id="L69">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L70">    } <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L71">        <span class="tok-kw">error</span>.PathAlreadyExists =&gt; {},</span>
<span class="line" id="L72">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err, <span class="tok-comment">// TODO zig should know this set does not include PathAlreadyExists</span>
</span>
<span class="line" id="L73">    }</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">    <span class="tok-kw">const</span> dirname = path.dirname(new_path) <span class="tok-kw">orelse</span> <span class="tok-str">&quot;.&quot;</span>;</span>
<span class="line" id="L76"></span>
<span class="line" id="L77">    <span class="tok-kw">var</span> rand_buf: [AtomicFile.RANDOM_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L78">    <span class="tok-kw">const</span> tmp_path = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, dirname.len + <span class="tok-number">1</span> + base64_encoder.calcSize(rand_buf.len));</span>
<span class="line" id="L79">    <span class="tok-kw">defer</span> allocator.free(tmp_path);</span>
<span class="line" id="L80">    mem.copy(<span class="tok-type">u8</span>, tmp_path[<span class="tok-number">0</span>..], dirname);</span>
<span class="line" id="L81">    tmp_path[dirname.len] = path.sep;</span>
<span class="line" id="L82">    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L83">        crypto.random.bytes(rand_buf[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L84">        _ = base64_encoder.encode(tmp_path[dirname.len + <span class="tok-number">1</span> ..], &amp;rand_buf);</span>
<span class="line" id="L85"></span>
<span class="line" id="L86">        <span class="tok-kw">if</span> (cwd().symLink(existing_path, tmp_path, .{})) {</span>
<span class="line" id="L87">            <span class="tok-kw">return</span> cwd().rename(tmp_path, new_path);</span>
<span class="line" id="L88">        } <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L89">            <span class="tok-kw">error</span>.PathAlreadyExists =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L90">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err, <span class="tok-comment">// TODO zig should know this set does not include PathAlreadyExists</span>
</span>
<span class="line" id="L91">        }</span>
<span class="line" id="L92">    }</span>
<span class="line" id="L93">}</span>
<span class="line" id="L94"></span>
<span class="line" id="L95"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PrevStatus = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L96">    stale,</span>
<span class="line" id="L97">    fresh,</span>
<span class="line" id="L98">};</span>
<span class="line" id="L99"></span>
<span class="line" id="L100"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CopyFileOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L101">    <span class="tok-comment">/// When this is `null` the mode is copied from the source file.</span></span>
<span class="line" id="L102">    override_mode: ?File.Mode = <span class="tok-null">null</span>,</span>
<span class="line" id="L103">};</span>
<span class="line" id="L104"></span>
<span class="line" id="L105"><span class="tok-comment">/// Same as `Dir.updateFile`, except asserts that both `source_path` and `dest_path`</span></span>
<span class="line" id="L106"><span class="tok-comment">/// are absolute. See `Dir.updateFile` for a function that operates on both</span></span>
<span class="line" id="L107"><span class="tok-comment">/// absolute and relative paths.</span></span>
<span class="line" id="L108"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">updateFileAbsolute</span>(</span>
<span class="line" id="L109">    source_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L110">    dest_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L111">    args: CopyFileOptions,</span>
<span class="line" id="L112">) !PrevStatus {</span>
<span class="line" id="L113">    assert(path.isAbsolute(source_path));</span>
<span class="line" id="L114">    assert(path.isAbsolute(dest_path));</span>
<span class="line" id="L115">    <span class="tok-kw">const</span> my_cwd = cwd();</span>
<span class="line" id="L116">    <span class="tok-kw">return</span> Dir.updateFile(my_cwd, source_path, my_cwd, dest_path, args);</span>
<span class="line" id="L117">}</span>
<span class="line" id="L118"></span>
<span class="line" id="L119"><span class="tok-comment">/// Same as `Dir.copyFile`, except asserts that both `source_path` and `dest_path`</span></span>
<span class="line" id="L120"><span class="tok-comment">/// are absolute. See `Dir.copyFile` for a function that operates on both</span></span>
<span class="line" id="L121"><span class="tok-comment">/// absolute and relative paths.</span></span>
<span class="line" id="L122"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">copyFileAbsolute</span>(source_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, dest_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: CopyFileOptions) !<span class="tok-type">void</span> {</span>
<span class="line" id="L123">    assert(path.isAbsolute(source_path));</span>
<span class="line" id="L124">    assert(path.isAbsolute(dest_path));</span>
<span class="line" id="L125">    <span class="tok-kw">const</span> my_cwd = cwd();</span>
<span class="line" id="L126">    <span class="tok-kw">return</span> Dir.copyFile(my_cwd, source_path, my_cwd, dest_path, args);</span>
<span class="line" id="L127">}</span>
<span class="line" id="L128"></span>
<span class="line" id="L129"><span class="tok-comment">/// TODO update this API to avoid a getrandom syscall for every operation.</span></span>
<span class="line" id="L130"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AtomicFile = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L131">    file: File,</span>
<span class="line" id="L132">    <span class="tok-comment">// TODO either replace this with rand_buf or use []u16 on Windows</span>
</span>
<span class="line" id="L133">    tmp_path_buf: [TMP_PATH_LEN:<span class="tok-number">0</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L134">    dest_basename: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L135">    file_open: <span class="tok-type">bool</span>,</span>
<span class="line" id="L136">    file_exists: <span class="tok-type">bool</span>,</span>
<span class="line" id="L137">    close_dir_on_deinit: <span class="tok-type">bool</span>,</span>
<span class="line" id="L138">    dir: Dir,</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">    <span class="tok-kw">const</span> InitError = File.OpenError;</span>
<span class="line" id="L141"></span>
<span class="line" id="L142">    <span class="tok-kw">const</span> RANDOM_BYTES = <span class="tok-number">12</span>;</span>
<span class="line" id="L143">    <span class="tok-kw">const</span> TMP_PATH_LEN = base64_encoder.calcSize(RANDOM_BYTES);</span>
<span class="line" id="L144"></span>
<span class="line" id="L145">    <span class="tok-comment">/// Note that the `Dir.atomicFile` API may be more handy than this lower-level function.</span></span>
<span class="line" id="L146">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(</span>
<span class="line" id="L147">        dest_basename: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L148">        mode: File.Mode,</span>
<span class="line" id="L149">        dir: Dir,</span>
<span class="line" id="L150">        close_dir_on_deinit: <span class="tok-type">bool</span>,</span>
<span class="line" id="L151">    ) InitError!AtomicFile {</span>
<span class="line" id="L152">        <span class="tok-kw">var</span> rand_buf: [RANDOM_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L153">        <span class="tok-kw">var</span> tmp_path_buf: [TMP_PATH_LEN:<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L154"></span>
<span class="line" id="L155">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L156">            crypto.random.bytes(rand_buf[<span class="tok-number">0</span>..]);</span>
<span class="line" id="L157">            <span class="tok-kw">const</span> tmp_path = base64_encoder.encode(&amp;tmp_path_buf, &amp;rand_buf);</span>
<span class="line" id="L158">            tmp_path_buf[tmp_path.len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L159"></span>
<span class="line" id="L160">            <span class="tok-kw">const</span> file = dir.createFile(</span>
<span class="line" id="L161">                tmp_path,</span>
<span class="line" id="L162">                .{ .mode = mode, .exclusive = <span class="tok-null">true</span> },</span>
<span class="line" id="L163">            ) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L164">                <span class="tok-kw">error</span>.PathAlreadyExists =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L165">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L166">            };</span>
<span class="line" id="L167"></span>
<span class="line" id="L168">            <span class="tok-kw">return</span> AtomicFile{</span>
<span class="line" id="L169">                .file = file,</span>
<span class="line" id="L170">                .tmp_path_buf = tmp_path_buf,</span>
<span class="line" id="L171">                .dest_basename = dest_basename,</span>
<span class="line" id="L172">                .file_open = <span class="tok-null">true</span>,</span>
<span class="line" id="L173">                .file_exists = <span class="tok-null">true</span>,</span>
<span class="line" id="L174">                .close_dir_on_deinit = close_dir_on_deinit,</span>
<span class="line" id="L175">                .dir = dir,</span>
<span class="line" id="L176">            };</span>
<span class="line" id="L177">        }</span>
<span class="line" id="L178">    }</span>
<span class="line" id="L179"></span>
<span class="line" id="L180">    <span class="tok-comment">/// always call deinit, even after successful finish()</span></span>
<span class="line" id="L181">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *AtomicFile) <span class="tok-type">void</span> {</span>
<span class="line" id="L182">        <span class="tok-kw">if</span> (self.file_open) {</span>
<span class="line" id="L183">            self.file.close();</span>
<span class="line" id="L184">            self.file_open = <span class="tok-null">false</span>;</span>
<span class="line" id="L185">        }</span>
<span class="line" id="L186">        <span class="tok-kw">if</span> (self.file_exists) {</span>
<span class="line" id="L187">            self.dir.deleteFile(&amp;self.tmp_path_buf) <span class="tok-kw">catch</span> {};</span>
<span class="line" id="L188">            self.file_exists = <span class="tok-null">false</span>;</span>
<span class="line" id="L189">        }</span>
<span class="line" id="L190">        <span class="tok-kw">if</span> (self.close_dir_on_deinit) {</span>
<span class="line" id="L191">            self.dir.close();</span>
<span class="line" id="L192">        }</span>
<span class="line" id="L193">        self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L194">    }</span>
<span class="line" id="L195"></span>
<span class="line" id="L196">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FinishError = std.os.RenameError;</span>
<span class="line" id="L197"></span>
<span class="line" id="L198">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">finish</span>(self: *AtomicFile) FinishError!<span class="tok-type">void</span> {</span>
<span class="line" id="L199">        assert(self.file_exists);</span>
<span class="line" id="L200">        <span class="tok-kw">if</span> (self.file_open) {</span>
<span class="line" id="L201">            self.file.close();</span>
<span class="line" id="L202">            self.file_open = <span class="tok-null">false</span>;</span>
<span class="line" id="L203">        }</span>
<span class="line" id="L204">        <span class="tok-kw">try</span> os.renameat(self.dir.fd, self.tmp_path_buf[<span class="tok-number">0</span>..], self.dir.fd, self.dest_basename);</span>
<span class="line" id="L205">        self.file_exists = <span class="tok-null">false</span>;</span>
<span class="line" id="L206">    }</span>
<span class="line" id="L207">};</span>
<span class="line" id="L208"></span>
<span class="line" id="L209"><span class="tok-kw">const</span> default_new_dir_mode = <span class="tok-number">0o755</span>;</span>
<span class="line" id="L210"></span>
<span class="line" id="L211"><span class="tok-comment">/// Create a new directory, based on an absolute path.</span></span>
<span class="line" id="L212"><span class="tok-comment">/// Asserts that the path is absolute. See `Dir.makeDir` for a function that operates</span></span>
<span class="line" id="L213"><span class="tok-comment">/// on both absolute and relative paths.</span></span>
<span class="line" id="L214"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">makeDirAbsolute</span>(absolute_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L215">    assert(path.isAbsolute(absolute_path));</span>
<span class="line" id="L216">    <span class="tok-kw">return</span> os.mkdir(absolute_path, default_new_dir_mode);</span>
<span class="line" id="L217">}</span>
<span class="line" id="L218"></span>
<span class="line" id="L219"><span class="tok-comment">/// Same as `makeDirAbsolute` except the parameter is a null-terminated UTF8-encoded string.</span></span>
<span class="line" id="L220"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">makeDirAbsoluteZ</span>(absolute_path_z: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L221">    assert(path.isAbsoluteZ(absolute_path_z));</span>
<span class="line" id="L222">    <span class="tok-kw">return</span> os.mkdirZ(absolute_path_z, default_new_dir_mode);</span>
<span class="line" id="L223">}</span>
<span class="line" id="L224"></span>
<span class="line" id="L225"><span class="tok-comment">/// Same as `makeDirAbsolute` except the parameter is a null-terminated WTF-16 encoded string.</span></span>
<span class="line" id="L226"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">makeDirAbsoluteW</span>(absolute_path_w: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L227">    assert(path.isAbsoluteWindowsW(absolute_path_w));</span>
<span class="line" id="L228">    <span class="tok-kw">return</span> os.mkdirW(absolute_path_w, default_new_dir_mode);</span>
<span class="line" id="L229">}</span>
<span class="line" id="L230"></span>
<span class="line" id="L231"><span class="tok-comment">/// Same as `Dir.deleteDir` except the path is absolute.</span></span>
<span class="line" id="L232"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deleteDirAbsolute</span>(dir_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L233">    assert(path.isAbsolute(dir_path));</span>
<span class="line" id="L234">    <span class="tok-kw">return</span> os.rmdir(dir_path);</span>
<span class="line" id="L235">}</span>
<span class="line" id="L236"></span>
<span class="line" id="L237"><span class="tok-comment">/// Same as `deleteDirAbsolute` except the path parameter is null-terminated.</span></span>
<span class="line" id="L238"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deleteDirAbsoluteZ</span>(dir_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L239">    assert(path.isAbsoluteZ(dir_path));</span>
<span class="line" id="L240">    <span class="tok-kw">return</span> os.rmdirZ(dir_path);</span>
<span class="line" id="L241">}</span>
<span class="line" id="L242"></span>
<span class="line" id="L243"><span class="tok-comment">/// Same as `deleteDirAbsolute` except the path parameter is WTF-16 and target OS is assumed Windows.</span></span>
<span class="line" id="L244"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deleteDirAbsoluteW</span>(dir_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L245">    assert(path.isAbsoluteWindowsW(dir_path));</span>
<span class="line" id="L246">    <span class="tok-kw">return</span> os.rmdirW(dir_path);</span>
<span class="line" id="L247">}</span>
<span class="line" id="L248"></span>
<span class="line" id="L249"><span class="tok-comment">/// Same as `Dir.rename` except the paths are absolute.</span></span>
<span class="line" id="L250"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">renameAbsolute</span>(old_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, new_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L251">    assert(path.isAbsolute(old_path));</span>
<span class="line" id="L252">    assert(path.isAbsolute(new_path));</span>
<span class="line" id="L253">    <span class="tok-kw">return</span> os.rename(old_path, new_path);</span>
<span class="line" id="L254">}</span>
<span class="line" id="L255"></span>
<span class="line" id="L256"><span class="tok-comment">/// Same as `renameAbsolute` except the path parameters are null-terminated.</span></span>
<span class="line" id="L257"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">renameAbsoluteZ</span>(old_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, new_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L258">    assert(path.isAbsoluteZ(old_path));</span>
<span class="line" id="L259">    assert(path.isAbsoluteZ(new_path));</span>
<span class="line" id="L260">    <span class="tok-kw">return</span> os.renameZ(old_path, new_path);</span>
<span class="line" id="L261">}</span>
<span class="line" id="L262"></span>
<span class="line" id="L263"><span class="tok-comment">/// Same as `renameAbsolute` except the path parameters are WTF-16 and target OS is assumed Windows.</span></span>
<span class="line" id="L264"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">renameAbsoluteW</span>(old_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, new_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L265">    assert(path.isAbsoluteWindowsW(old_path));</span>
<span class="line" id="L266">    assert(path.isAbsoluteWindowsW(new_path));</span>
<span class="line" id="L267">    <span class="tok-kw">return</span> os.renameW(old_path, new_path);</span>
<span class="line" id="L268">}</span>
<span class="line" id="L269"></span>
<span class="line" id="L270"><span class="tok-comment">/// Same as `Dir.rename`, except `new_sub_path` is relative to `new_dir`</span></span>
<span class="line" id="L271"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rename</span>(old_dir: Dir, old_sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, new_dir: Dir, new_sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L272">    <span class="tok-kw">return</span> os.renameat(old_dir.fd, old_sub_path, new_dir.fd, new_sub_path);</span>
<span class="line" id="L273">}</span>
<span class="line" id="L274"></span>
<span class="line" id="L275"><span class="tok-comment">/// Same as `rename` except the parameters are null-terminated.</span></span>
<span class="line" id="L276"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">renameZ</span>(old_dir: Dir, old_sub_path_z: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, new_dir: Dir, new_sub_path_z: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L277">    <span class="tok-kw">return</span> os.renameatZ(old_dir.fd, old_sub_path_z, new_dir.fd, new_sub_path_z);</span>
<span class="line" id="L278">}</span>
<span class="line" id="L279"></span>
<span class="line" id="L280"><span class="tok-comment">/// Same as `rename` except the parameters are UTF16LE, NT prefixed.</span></span>
<span class="line" id="L281"><span class="tok-comment">/// This function is Windows-only.</span></span>
<span class="line" id="L282"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">renameW</span>(old_dir: Dir, old_sub_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, new_dir: Dir, new_sub_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L283">    <span class="tok-kw">return</span> os.renameatW(old_dir.fd, old_sub_path_w, new_dir.fd, new_sub_path_w);</span>
<span class="line" id="L284">}</span>
<span class="line" id="L285"></span>
<span class="line" id="L286"><span class="tok-comment">/// A directory that can be iterated. It is *NOT* legal to initialize this with a regular `Dir`</span></span>
<span class="line" id="L287"><span class="tok-comment">/// that has been opened without iteration permission.</span></span>
<span class="line" id="L288"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IterableDir = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L289">    dir: Dir,</span>
<span class="line" id="L290"></span>
<span class="line" id="L291">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Entry = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L292">        name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L293">        kind: Kind,</span>
<span class="line" id="L294"></span>
<span class="line" id="L295">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Kind = File.Kind;</span>
<span class="line" id="L296">    };</span>
<span class="line" id="L297"></span>
<span class="line" id="L298">    <span class="tok-kw">const</span> IteratorError = <span class="tok-kw">error</span>{ AccessDenied, SystemResources } || os.UnexpectedError;</span>
<span class="line" id="L299"></span>
<span class="line" id="L300">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Iterator = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L301">        .macos, .ios, .freebsd, .netbsd, .dragonfly, .openbsd, .solaris =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L302">            dir: Dir,</span>
<span class="line" id="L303">            seek: <span class="tok-type">i64</span>,</span>
<span class="line" id="L304">            buf: [<span class="tok-number">8192</span>]<span class="tok-type">u8</span>, <span class="tok-comment">// TODO align(@alignOf(os.system.dirent)),</span>
</span>
<span class="line" id="L305">            index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L306">            end_index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L307">            first_iter: <span class="tok-type">bool</span>,</span>
<span class="line" id="L308"></span>
<span class="line" id="L309">            <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L310"></span>
<span class="line" id="L311">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = IteratorError;</span>
<span class="line" id="L312"></span>
<span class="line" id="L313">            <span class="tok-comment">/// Memory such as file names referenced in this returned entry becomes invalid</span></span>
<span class="line" id="L314">            <span class="tok-comment">/// with subsequent calls to `next`, as well as when this `Dir` is deinitialized.</span></span>
<span class="line" id="L315">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Self) Error!?Entry {</span>
<span class="line" id="L316">                <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L317">                    .macos, .ios =&gt; <span class="tok-kw">return</span> self.nextDarwin(),</span>
<span class="line" id="L318">                    .freebsd, .netbsd, .dragonfly, .openbsd =&gt; <span class="tok-kw">return</span> self.nextBsd(),</span>
<span class="line" id="L319">                    .solaris =&gt; <span class="tok-kw">return</span> self.nextSolaris(),</span>
<span class="line" id="L320">                    <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;unimplemented&quot;</span>),</span>
<span class="line" id="L321">                }</span>
<span class="line" id="L322">            }</span>
<span class="line" id="L323"></span>
<span class="line" id="L324">            <span class="tok-kw">fn</span> <span class="tok-fn">nextDarwin</span>(self: *Self) !?Entry {</span>
<span class="line" id="L325">                start_over: <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L326">                    <span class="tok-kw">if</span> (self.index &gt;= self.end_index) {</span>
<span class="line" id="L327">                        <span class="tok-kw">if</span> (self.first_iter) {</span>
<span class="line" id="L328">                            std.os.lseek_SET(self.dir.fd, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>; <span class="tok-comment">// EBADF here likely means that the Dir was not opened with iteration permissions</span>
</span>
<span class="line" id="L329">                            self.first_iter = <span class="tok-null">false</span>;</span>
<span class="line" id="L330">                        }</span>
<span class="line" id="L331">                        <span class="tok-kw">const</span> rc = os.system.__getdirentries64(</span>
<span class="line" id="L332">                            self.dir.fd,</span>
<span class="line" id="L333">                            &amp;self.buf,</span>
<span class="line" id="L334">                            self.buf.len,</span>
<span class="line" id="L335">                            &amp;self.seek,</span>
<span class="line" id="L336">                        );</span>
<span class="line" id="L337">                        <span class="tok-kw">if</span> (rc == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L338">                        <span class="tok-kw">if</span> (rc &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L339">                            <span class="tok-kw">switch</span> (os.errno(rc)) {</span>
<span class="line" id="L340">                                .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Dir is invalid or was opened without iteration ability</span>
</span>
<span class="line" id="L341">                                .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L342">                                .NOTDIR =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L343">                                .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L344">                                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> os.unexpectedErrno(err),</span>
<span class="line" id="L345">                            }</span>
<span class="line" id="L346">                        }</span>
<span class="line" id="L347">                        self.index = <span class="tok-number">0</span>;</span>
<span class="line" id="L348">                        self.end_index = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc);</span>
<span class="line" id="L349">                    }</span>
<span class="line" id="L350">                    <span class="tok-kw">const</span> darwin_entry = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) os.system.dirent, &amp;self.buf[self.index]);</span>
<span class="line" id="L351">                    <span class="tok-kw">const</span> next_index = self.index + darwin_entry.reclen();</span>
<span class="line" id="L352">                    self.index = next_index;</span>
<span class="line" id="L353"></span>
<span class="line" id="L354">                    <span class="tok-kw">const</span> name = <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;darwin_entry.d_name)[<span class="tok-number">0</span>..darwin_entry.d_namlen];</span>
<span class="line" id="L355"></span>
<span class="line" id="L356">                    <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;.&quot;</span>) <span class="tok-kw">or</span> mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;..&quot;</span>) <span class="tok-kw">or</span> (darwin_entry.d_ino == <span class="tok-number">0</span>)) {</span>
<span class="line" id="L357">                        <span class="tok-kw">continue</span> :start_over;</span>
<span class="line" id="L358">                    }</span>
<span class="line" id="L359"></span>
<span class="line" id="L360">                    <span class="tok-kw">const</span> entry_kind = <span class="tok-kw">switch</span> (darwin_entry.d_type) {</span>
<span class="line" id="L361">                        os.DT.BLK =&gt; Entry.Kind.BlockDevice,</span>
<span class="line" id="L362">                        os.DT.CHR =&gt; Entry.Kind.CharacterDevice,</span>
<span class="line" id="L363">                        os.DT.DIR =&gt; Entry.Kind.Directory,</span>
<span class="line" id="L364">                        os.DT.FIFO =&gt; Entry.Kind.NamedPipe,</span>
<span class="line" id="L365">                        os.DT.LNK =&gt; Entry.Kind.SymLink,</span>
<span class="line" id="L366">                        os.DT.REG =&gt; Entry.Kind.File,</span>
<span class="line" id="L367">                        os.DT.SOCK =&gt; Entry.Kind.UnixDomainSocket,</span>
<span class="line" id="L368">                        os.DT.WHT =&gt; Entry.Kind.Whiteout,</span>
<span class="line" id="L369">                        <span class="tok-kw">else</span> =&gt; Entry.Kind.Unknown,</span>
<span class="line" id="L370">                    };</span>
<span class="line" id="L371">                    <span class="tok-kw">return</span> Entry{</span>
<span class="line" id="L372">                        .name = name,</span>
<span class="line" id="L373">                        .kind = entry_kind,</span>
<span class="line" id="L374">                    };</span>
<span class="line" id="L375">                }</span>
<span class="line" id="L376">            }</span>
<span class="line" id="L377"></span>
<span class="line" id="L378">            <span class="tok-kw">fn</span> <span class="tok-fn">nextSolaris</span>(self: *Self) !?Entry {</span>
<span class="line" id="L379">                start_over: <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L380">                    <span class="tok-kw">if</span> (self.index &gt;= self.end_index) {</span>
<span class="line" id="L381">                        <span class="tok-kw">if</span> (self.first_iter) {</span>
<span class="line" id="L382">                            std.os.lseek_SET(self.dir.fd, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>; <span class="tok-comment">// EBADF here likely means that the Dir was not opened with iteration permissions</span>
</span>
<span class="line" id="L383">                            self.first_iter = <span class="tok-null">false</span>;</span>
<span class="line" id="L384">                        }</span>
<span class="line" id="L385">                        <span class="tok-kw">const</span> rc = os.system.getdents(self.dir.fd, &amp;self.buf, self.buf.len);</span>
<span class="line" id="L386">                        <span class="tok-kw">switch</span> (os.errno(rc)) {</span>
<span class="line" id="L387">                            .SUCCESS =&gt; {},</span>
<span class="line" id="L388">                            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Dir is invalid or was opened without iteration ability</span>
</span>
<span class="line" id="L389">                            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L390">                            .NOTDIR =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L391">                            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L392">                            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> os.unexpectedErrno(err),</span>
<span class="line" id="L393">                        }</span>
<span class="line" id="L394">                        <span class="tok-kw">if</span> (rc == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L395">                        self.index = <span class="tok-number">0</span>;</span>
<span class="line" id="L396">                        self.end_index = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc);</span>
<span class="line" id="L397">                    }</span>
<span class="line" id="L398">                    <span class="tok-kw">const</span> entry = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) os.system.dirent, &amp;self.buf[self.index]);</span>
<span class="line" id="L399">                    <span class="tok-kw">const</span> next_index = self.index + entry.reclen();</span>
<span class="line" id="L400">                    self.index = next_index;</span>
<span class="line" id="L401"></span>
<span class="line" id="L402">                    <span class="tok-kw">const</span> name = mem.sliceTo(<span class="tok-builtin">@ptrCast</span>([*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, &amp;entry.d_name), <span class="tok-number">0</span>);</span>
<span class="line" id="L403">                    <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;.&quot;</span>) <span class="tok-kw">or</span> mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;..&quot;</span>))</span>
<span class="line" id="L404">                        <span class="tok-kw">continue</span> :start_over;</span>
<span class="line" id="L405"></span>
<span class="line" id="L406">                    <span class="tok-comment">// Solaris dirent doesn't expose d_type, so we have to call stat to get it.</span>
</span>
<span class="line" id="L407">                    <span class="tok-kw">const</span> stat_info = os.fstatat(</span>
<span class="line" id="L408">                        self.dir.fd,</span>
<span class="line" id="L409">                        name,</span>
<span class="line" id="L410">                        os.AT.SYMLINK_NOFOLLOW,</span>
<span class="line" id="L411">                    ) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L412">                        <span class="tok-kw">error</span>.NameTooLong =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L413">                        <span class="tok-kw">error</span>.SymLinkLoop =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L414">                        <span class="tok-kw">error</span>.FileNotFound =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// lost the race</span>
</span>
<span class="line" id="L415">                        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L416">                    };</span>
<span class="line" id="L417">                    <span class="tok-kw">const</span> entry_kind = <span class="tok-kw">switch</span> (stat_info.mode &amp; os.S.IFMT) {</span>
<span class="line" id="L418">                        os.S.IFIFO =&gt; Entry.Kind.NamedPipe,</span>
<span class="line" id="L419">                        os.S.IFCHR =&gt; Entry.Kind.CharacterDevice,</span>
<span class="line" id="L420">                        os.S.IFDIR =&gt; Entry.Kind.Directory,</span>
<span class="line" id="L421">                        os.S.IFBLK =&gt; Entry.Kind.BlockDevice,</span>
<span class="line" id="L422">                        os.S.IFREG =&gt; Entry.Kind.File,</span>
<span class="line" id="L423">                        os.S.IFLNK =&gt; Entry.Kind.SymLink,</span>
<span class="line" id="L424">                        os.S.IFSOCK =&gt; Entry.Kind.UnixDomainSocket,</span>
<span class="line" id="L425">                        os.S.IFDOOR =&gt; Entry.Kind.Door,</span>
<span class="line" id="L426">                        os.S.IFPORT =&gt; Entry.Kind.EventPort,</span>
<span class="line" id="L427">                        <span class="tok-kw">else</span> =&gt; Entry.Kind.Unknown,</span>
<span class="line" id="L428">                    };</span>
<span class="line" id="L429">                    <span class="tok-kw">return</span> Entry{</span>
<span class="line" id="L430">                        .name = name,</span>
<span class="line" id="L431">                        .kind = entry_kind,</span>
<span class="line" id="L432">                    };</span>
<span class="line" id="L433">                }</span>
<span class="line" id="L434">            }</span>
<span class="line" id="L435"></span>
<span class="line" id="L436">            <span class="tok-kw">fn</span> <span class="tok-fn">nextBsd</span>(self: *Self) !?Entry {</span>
<span class="line" id="L437">                start_over: <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L438">                    <span class="tok-kw">if</span> (self.index &gt;= self.end_index) {</span>
<span class="line" id="L439">                        <span class="tok-kw">if</span> (self.first_iter) {</span>
<span class="line" id="L440">                            std.os.lseek_SET(self.dir.fd, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>; <span class="tok-comment">// EBADF here likely means that the Dir was not opened with iteration permissions</span>
</span>
<span class="line" id="L441">                            self.first_iter = <span class="tok-null">false</span>;</span>
<span class="line" id="L442">                        }</span>
<span class="line" id="L443">                        <span class="tok-kw">const</span> rc = <span class="tok-kw">if</span> (builtin.os.tag == .netbsd)</span>
<span class="line" id="L444">                            os.system.__getdents30(self.dir.fd, &amp;self.buf, self.buf.len)</span>
<span class="line" id="L445">                        <span class="tok-kw">else</span></span>
<span class="line" id="L446">                            os.system.getdents(self.dir.fd, &amp;self.buf, self.buf.len);</span>
<span class="line" id="L447">                        <span class="tok-kw">switch</span> (os.errno(rc)) {</span>
<span class="line" id="L448">                            .SUCCESS =&gt; {},</span>
<span class="line" id="L449">                            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Dir is invalid or was opened without iteration ability</span>
</span>
<span class="line" id="L450">                            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L451">                            .NOTDIR =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L452">                            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L453">                            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> os.unexpectedErrno(err),</span>
<span class="line" id="L454">                        }</span>
<span class="line" id="L455">                        <span class="tok-kw">if</span> (rc == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L456">                        self.index = <span class="tok-number">0</span>;</span>
<span class="line" id="L457">                        self.end_index = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc);</span>
<span class="line" id="L458">                    }</span>
<span class="line" id="L459">                    <span class="tok-kw">const</span> bsd_entry = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) os.system.dirent, &amp;self.buf[self.index]);</span>
<span class="line" id="L460">                    <span class="tok-kw">const</span> next_index = self.index + bsd_entry.reclen();</span>
<span class="line" id="L461">                    self.index = next_index;</span>
<span class="line" id="L462"></span>
<span class="line" id="L463">                    <span class="tok-kw">const</span> name = <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, &amp;bsd_entry.d_name)[<span class="tok-number">0</span>..bsd_entry.d_namlen];</span>
<span class="line" id="L464"></span>
<span class="line" id="L465">                    <span class="tok-kw">const</span> skip_zero_fileno = <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L466">                        <span class="tok-comment">// d_fileno=0 is used to mark invalid entries or deleted files.</span>
</span>
<span class="line" id="L467">                        .openbsd, .netbsd =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L468">                        <span class="tok-kw">else</span> =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L469">                    };</span>
<span class="line" id="L470">                    <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;.&quot;</span>) <span class="tok-kw">or</span> mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;..&quot;</span>) <span class="tok-kw">or</span></span>
<span class="line" id="L471">                        (skip_zero_fileno <span class="tok-kw">and</span> bsd_entry.d_fileno == <span class="tok-number">0</span>))</span>
<span class="line" id="L472">                    {</span>
<span class="line" id="L473">                        <span class="tok-kw">continue</span> :start_over;</span>
<span class="line" id="L474">                    }</span>
<span class="line" id="L475"></span>
<span class="line" id="L476">                    <span class="tok-kw">const</span> entry_kind = <span class="tok-kw">switch</span> (bsd_entry.d_type) {</span>
<span class="line" id="L477">                        os.DT.BLK =&gt; Entry.Kind.BlockDevice,</span>
<span class="line" id="L478">                        os.DT.CHR =&gt; Entry.Kind.CharacterDevice,</span>
<span class="line" id="L479">                        os.DT.DIR =&gt; Entry.Kind.Directory,</span>
<span class="line" id="L480">                        os.DT.FIFO =&gt; Entry.Kind.NamedPipe,</span>
<span class="line" id="L481">                        os.DT.LNK =&gt; Entry.Kind.SymLink,</span>
<span class="line" id="L482">                        os.DT.REG =&gt; Entry.Kind.File,</span>
<span class="line" id="L483">                        os.DT.SOCK =&gt; Entry.Kind.UnixDomainSocket,</span>
<span class="line" id="L484">                        os.DT.WHT =&gt; Entry.Kind.Whiteout,</span>
<span class="line" id="L485">                        <span class="tok-kw">else</span> =&gt; Entry.Kind.Unknown,</span>
<span class="line" id="L486">                    };</span>
<span class="line" id="L487">                    <span class="tok-kw">return</span> Entry{</span>
<span class="line" id="L488">                        .name = name,</span>
<span class="line" id="L489">                        .kind = entry_kind,</span>
<span class="line" id="L490">                    };</span>
<span class="line" id="L491">                }</span>
<span class="line" id="L492">            }</span>
<span class="line" id="L493">        },</span>
<span class="line" id="L494">        .haiku =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L495">            dir: Dir,</span>
<span class="line" id="L496">            buf: [<span class="tok-number">8192</span>]<span class="tok-type">u8</span>, <span class="tok-comment">// TODO align(@alignOf(os.dirent64)),</span>
</span>
<span class="line" id="L497">            index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L498">            end_index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L499">            first_iter: <span class="tok-type">bool</span>,</span>
<span class="line" id="L500"></span>
<span class="line" id="L501">            <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L502"></span>
<span class="line" id="L503">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = IteratorError;</span>
<span class="line" id="L504"></span>
<span class="line" id="L505">            <span class="tok-comment">/// Memory such as file names referenced in this returned entry becomes invalid</span></span>
<span class="line" id="L506">            <span class="tok-comment">/// with subsequent calls to `next`, as well as when this `Dir` is deinitialized.</span></span>
<span class="line" id="L507">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Self) Error!?Entry {</span>
<span class="line" id="L508">                start_over: <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L509">                    <span class="tok-comment">// TODO: find a better max</span>
</span>
<span class="line" id="L510">                    <span class="tok-kw">const</span> HAIKU_MAX_COUNT = <span class="tok-number">10000</span>;</span>
<span class="line" id="L511">                    <span class="tok-kw">if</span> (self.index &gt;= self.end_index) {</span>
<span class="line" id="L512">                        <span class="tok-kw">if</span> (self.first_iter) {</span>
<span class="line" id="L513">                            std.os.lseek_SET(self.dir.fd, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>; <span class="tok-comment">// EBADF here likely means that the Dir was not opened with iteration permissions</span>
</span>
<span class="line" id="L514">                            self.first_iter = <span class="tok-null">false</span>;</span>
<span class="line" id="L515">                        }</span>
<span class="line" id="L516">                        <span class="tok-kw">const</span> rc = os.system._kern_read_dir(</span>
<span class="line" id="L517">                            self.dir.fd,</span>
<span class="line" id="L518">                            &amp;self.buf,</span>
<span class="line" id="L519">                            self.buf.len,</span>
<span class="line" id="L520">                            HAIKU_MAX_COUNT,</span>
<span class="line" id="L521">                        );</span>
<span class="line" id="L522">                        <span class="tok-kw">if</span> (rc == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L523">                        <span class="tok-kw">if</span> (rc &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L524">                            <span class="tok-kw">switch</span> (os.errno(rc)) {</span>
<span class="line" id="L525">                                .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Dir is invalid or was opened without iteration ability</span>
</span>
<span class="line" id="L526">                                .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L527">                                .NOTDIR =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L528">                                .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L529">                                <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> os.unexpectedErrno(err),</span>
<span class="line" id="L530">                            }</span>
<span class="line" id="L531">                        }</span>
<span class="line" id="L532">                        self.index = <span class="tok-number">0</span>;</span>
<span class="line" id="L533">                        self.end_index = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, rc);</span>
<span class="line" id="L534">                    }</span>
<span class="line" id="L535">                    <span class="tok-kw">const</span> haiku_entry = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) os.system.dirent, &amp;self.buf[self.index]);</span>
<span class="line" id="L536">                    <span class="tok-kw">const</span> next_index = self.index + haiku_entry.reclen();</span>
<span class="line" id="L537">                    self.index = next_index;</span>
<span class="line" id="L538">                    <span class="tok-kw">const</span> name = mem.sliceTo(<span class="tok-builtin">@ptrCast</span>([*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, &amp;haiku_entry.d_name), <span class="tok-number">0</span>);</span>
<span class="line" id="L539"></span>
<span class="line" id="L540">                    <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;.&quot;</span>) <span class="tok-kw">or</span> mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;..&quot;</span>) <span class="tok-kw">or</span> (haiku_entry.d_ino == <span class="tok-number">0</span>)) {</span>
<span class="line" id="L541">                        <span class="tok-kw">continue</span> :start_over;</span>
<span class="line" id="L542">                    }</span>
<span class="line" id="L543"></span>
<span class="line" id="L544">                    <span class="tok-kw">var</span> stat_info: os.Stat = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L545">                    <span class="tok-kw">const</span> rc = os.system._kern_read_stat(</span>
<span class="line" id="L546">                        self.dir.fd,</span>
<span class="line" id="L547">                        &amp;haiku_entry.d_name,</span>
<span class="line" id="L548">                        <span class="tok-null">false</span>,</span>
<span class="line" id="L549">                        &amp;stat_info,</span>
<span class="line" id="L550">                        <span class="tok-number">0</span>,</span>
<span class="line" id="L551">                    );</span>
<span class="line" id="L552">                    <span class="tok-kw">if</span> (rc != <span class="tok-number">0</span>) {</span>
<span class="line" id="L553">                        <span class="tok-kw">switch</span> (os.errno(rc)) {</span>
<span class="line" id="L554">                            .SUCCESS =&gt; {},</span>
<span class="line" id="L555">                            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Dir is invalid or was opened without iteration ability</span>
</span>
<span class="line" id="L556">                            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L557">                            .NOTDIR =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L558">                            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L559">                            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> os.unexpectedErrno(err),</span>
<span class="line" id="L560">                        }</span>
<span class="line" id="L561">                    }</span>
<span class="line" id="L562">                    <span class="tok-kw">const</span> statmode = stat_info.mode &amp; os.S.IFMT;</span>
<span class="line" id="L563"></span>
<span class="line" id="L564">                    <span class="tok-kw">const</span> entry_kind = <span class="tok-kw">switch</span> (statmode) {</span>
<span class="line" id="L565">                        os.S.IFDIR =&gt; Entry.Kind.Directory,</span>
<span class="line" id="L566">                        os.S.IFBLK =&gt; Entry.Kind.BlockDevice,</span>
<span class="line" id="L567">                        os.S.IFCHR =&gt; Entry.Kind.CharacterDevice,</span>
<span class="line" id="L568">                        os.S.IFLNK =&gt; Entry.Kind.SymLink,</span>
<span class="line" id="L569">                        os.S.IFREG =&gt; Entry.Kind.File,</span>
<span class="line" id="L570">                        os.S.IFIFO =&gt; Entry.Kind.NamedPipe,</span>
<span class="line" id="L571">                        <span class="tok-kw">else</span> =&gt; Entry.Kind.Unknown,</span>
<span class="line" id="L572">                    };</span>
<span class="line" id="L573"></span>
<span class="line" id="L574">                    <span class="tok-kw">return</span> Entry{</span>
<span class="line" id="L575">                        .name = name,</span>
<span class="line" id="L576">                        .kind = entry_kind,</span>
<span class="line" id="L577">                    };</span>
<span class="line" id="L578">                }</span>
<span class="line" id="L579">            }</span>
<span class="line" id="L580">        },</span>
<span class="line" id="L581">        .linux =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L582">            dir: Dir,</span>
<span class="line" id="L583">            <span class="tok-comment">// The if guard is solely there to prevent compile errors from missing `linux.dirent64`</span>
</span>
<span class="line" id="L584">            <span class="tok-comment">// definition when compiling for other OSes. It doesn't do anything when compiling for Linux.</span>
</span>
<span class="line" id="L585">            buf: [<span class="tok-number">8192</span>]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-kw">if</span> (builtin.os.tag != .linux) <span class="tok-number">1</span> <span class="tok-kw">else</span> <span class="tok-builtin">@alignOf</span>(linux.dirent64)),</span>
<span class="line" id="L586">            index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L587">            end_index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L588">            first_iter: <span class="tok-type">bool</span>,</span>
<span class="line" id="L589"></span>
<span class="line" id="L590">            <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L591">            <span class="tok-kw">const</span> linux = os.linux;</span>
<span class="line" id="L592"></span>
<span class="line" id="L593">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = IteratorError;</span>
<span class="line" id="L594"></span>
<span class="line" id="L595">            <span class="tok-comment">/// Memory such as file names referenced in this returned entry becomes invalid</span></span>
<span class="line" id="L596">            <span class="tok-comment">/// with subsequent calls to `next`, as well as when this `Dir` is deinitialized.</span></span>
<span class="line" id="L597">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Self) Error!?Entry {</span>
<span class="line" id="L598">                <span class="tok-kw">return</span> self.nextLinux() <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L599">                    <span class="tok-comment">// To be consistent across platforms, iteration ends if the directory being iterated is deleted during iteration.</span>
</span>
<span class="line" id="L600">                    <span class="tok-comment">// This matches the behavior of non-Linux UNIX platforms.</span>
</span>
<span class="line" id="L601">                    <span class="tok-kw">error</span>.DirNotFound =&gt; <span class="tok-null">null</span>,</span>
<span class="line" id="L602">                    <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L603">                };</span>
<span class="line" id="L604">            }</span>
<span class="line" id="L605"></span>
<span class="line" id="L606">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ErrorLinux = <span class="tok-kw">error</span>{DirNotFound} || IteratorError;</span>
<span class="line" id="L607"></span>
<span class="line" id="L608">            <span class="tok-comment">/// Implementation of `next` that can return `error.DirNotFound` if the directory being</span></span>
<span class="line" id="L609">            <span class="tok-comment">/// iterated was deleted during iteration (this error is Linux specific).</span></span>
<span class="line" id="L610">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">nextLinux</span>(self: *Self) ErrorLinux!?Entry {</span>
<span class="line" id="L611">                start_over: <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L612">                    <span class="tok-kw">if</span> (self.index &gt;= self.end_index) {</span>
<span class="line" id="L613">                        <span class="tok-kw">if</span> (self.first_iter) {</span>
<span class="line" id="L614">                            std.os.lseek_SET(self.dir.fd, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>; <span class="tok-comment">// EBADF here likely means that the Dir was not opened with iteration permissions</span>
</span>
<span class="line" id="L615">                            self.first_iter = <span class="tok-null">false</span>;</span>
<span class="line" id="L616">                        }</span>
<span class="line" id="L617">                        <span class="tok-kw">const</span> rc = linux.getdents64(self.dir.fd, &amp;self.buf, self.buf.len);</span>
<span class="line" id="L618">                        <span class="tok-kw">switch</span> (linux.getErrno(rc)) {</span>
<span class="line" id="L619">                            .SUCCESS =&gt; {},</span>
<span class="line" id="L620">                            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Dir is invalid or was opened without iteration ability</span>
</span>
<span class="line" id="L621">                            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L622">                            .NOTDIR =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L623">                            .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DirNotFound, <span class="tok-comment">// The directory being iterated was deleted during iteration.</span>
</span>
<span class="line" id="L624">                            .INVAL =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.Unexpected, <span class="tok-comment">// Linux may in some cases return EINVAL when reading /proc/$PID/net.</span>
</span>
<span class="line" id="L625">                            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> os.unexpectedErrno(err),</span>
<span class="line" id="L626">                        }</span>
<span class="line" id="L627">                        <span class="tok-kw">if</span> (rc == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L628">                        self.index = <span class="tok-number">0</span>;</span>
<span class="line" id="L629">                        self.end_index = rc;</span>
<span class="line" id="L630">                    }</span>
<span class="line" id="L631">                    <span class="tok-kw">const</span> linux_entry = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) linux.dirent64, &amp;self.buf[self.index]);</span>
<span class="line" id="L632">                    <span class="tok-kw">const</span> next_index = self.index + linux_entry.reclen();</span>
<span class="line" id="L633">                    self.index = next_index;</span>
<span class="line" id="L634"></span>
<span class="line" id="L635">                    <span class="tok-kw">const</span> name = mem.sliceTo(<span class="tok-builtin">@ptrCast</span>([*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, &amp;linux_entry.d_name), <span class="tok-number">0</span>);</span>
<span class="line" id="L636"></span>
<span class="line" id="L637">                    <span class="tok-comment">// skip . and .. entries</span>
</span>
<span class="line" id="L638">                    <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;.&quot;</span>) <span class="tok-kw">or</span> mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;..&quot;</span>)) {</span>
<span class="line" id="L639">                        <span class="tok-kw">continue</span> :start_over;</span>
<span class="line" id="L640">                    }</span>
<span class="line" id="L641"></span>
<span class="line" id="L642">                    <span class="tok-kw">const</span> entry_kind = <span class="tok-kw">switch</span> (linux_entry.d_type) {</span>
<span class="line" id="L643">                        linux.DT.BLK =&gt; Entry.Kind.BlockDevice,</span>
<span class="line" id="L644">                        linux.DT.CHR =&gt; Entry.Kind.CharacterDevice,</span>
<span class="line" id="L645">                        linux.DT.DIR =&gt; Entry.Kind.Directory,</span>
<span class="line" id="L646">                        linux.DT.FIFO =&gt; Entry.Kind.NamedPipe,</span>
<span class="line" id="L647">                        linux.DT.LNK =&gt; Entry.Kind.SymLink,</span>
<span class="line" id="L648">                        linux.DT.REG =&gt; Entry.Kind.File,</span>
<span class="line" id="L649">                        linux.DT.SOCK =&gt; Entry.Kind.UnixDomainSocket,</span>
<span class="line" id="L650">                        <span class="tok-kw">else</span> =&gt; Entry.Kind.Unknown,</span>
<span class="line" id="L651">                    };</span>
<span class="line" id="L652">                    <span class="tok-kw">return</span> Entry{</span>
<span class="line" id="L653">                        .name = name,</span>
<span class="line" id="L654">                        .kind = entry_kind,</span>
<span class="line" id="L655">                    };</span>
<span class="line" id="L656">                }</span>
<span class="line" id="L657">            }</span>
<span class="line" id="L658">        },</span>
<span class="line" id="L659">        .windows =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L660">            dir: Dir,</span>
<span class="line" id="L661">            buf: [<span class="tok-number">8192</span>]<span class="tok-type">u8</span> <span class="tok-kw">align</span>(<span class="tok-builtin">@alignOf</span>(os.windows.FILE_BOTH_DIR_INFORMATION)),</span>
<span class="line" id="L662">            index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L663">            end_index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L664">            first_iter: <span class="tok-type">bool</span>,</span>
<span class="line" id="L665">            name_data: [<span class="tok-number">256</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L666"></span>
<span class="line" id="L667">            <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L668"></span>
<span class="line" id="L669">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = IteratorError;</span>
<span class="line" id="L670"></span>
<span class="line" id="L671">            <span class="tok-comment">/// Memory such as file names referenced in this returned entry becomes invalid</span></span>
<span class="line" id="L672">            <span class="tok-comment">/// with subsequent calls to `next`, as well as when this `Dir` is deinitialized.</span></span>
<span class="line" id="L673">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Self) Error!?Entry {</span>
<span class="line" id="L674">                <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L675">                    <span class="tok-kw">const</span> w = os.windows;</span>
<span class="line" id="L676">                    <span class="tok-kw">if</span> (self.index &gt;= self.end_index) {</span>
<span class="line" id="L677">                        <span class="tok-kw">var</span> io: w.IO_STATUS_BLOCK = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L678">                        <span class="tok-kw">const</span> rc = w.ntdll.NtQueryDirectoryFile(</span>
<span class="line" id="L679">                            self.dir.fd,</span>
<span class="line" id="L680">                            <span class="tok-null">null</span>,</span>
<span class="line" id="L681">                            <span class="tok-null">null</span>,</span>
<span class="line" id="L682">                            <span class="tok-null">null</span>,</span>
<span class="line" id="L683">                            &amp;io,</span>
<span class="line" id="L684">                            &amp;self.buf,</span>
<span class="line" id="L685">                            self.buf.len,</span>
<span class="line" id="L686">                            .FileBothDirectoryInformation,</span>
<span class="line" id="L687">                            w.FALSE,</span>
<span class="line" id="L688">                            <span class="tok-null">null</span>,</span>
<span class="line" id="L689">                            <span class="tok-kw">if</span> (self.first_iter) <span class="tok-builtin">@as</span>(w.BOOLEAN, w.TRUE) <span class="tok-kw">else</span> <span class="tok-builtin">@as</span>(w.BOOLEAN, w.FALSE),</span>
<span class="line" id="L690">                        );</span>
<span class="line" id="L691">                        self.first_iter = <span class="tok-null">false</span>;</span>
<span class="line" id="L692">                        <span class="tok-kw">if</span> (io.Information == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L693">                        self.index = <span class="tok-number">0</span>;</span>
<span class="line" id="L694">                        self.end_index = io.Information;</span>
<span class="line" id="L695">                        <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L696">                            .SUCCESS =&gt; {},</span>
<span class="line" id="L697">                            .ACCESS_DENIED =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied, <span class="tok-comment">// Double-check that the Dir was opened with iteration ability</span>
</span>
<span class="line" id="L698"></span>
<span class="line" id="L699">                            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> w.unexpectedStatus(rc),</span>
<span class="line" id="L700">                        }</span>
<span class="line" id="L701">                    }</span>
<span class="line" id="L702"></span>
<span class="line" id="L703">                    <span class="tok-kw">const</span> aligned_ptr = <span class="tok-builtin">@alignCast</span>(<span class="tok-builtin">@alignOf</span>(w.FILE_BOTH_DIR_INFORMATION), &amp;self.buf[self.index]);</span>
<span class="line" id="L704">                    <span class="tok-kw">const</span> dir_info = <span class="tok-builtin">@ptrCast</span>(*w.FILE_BOTH_DIR_INFORMATION, aligned_ptr);</span>
<span class="line" id="L705">                    <span class="tok-kw">if</span> (dir_info.NextEntryOffset != <span class="tok-number">0</span>) {</span>
<span class="line" id="L706">                        self.index += dir_info.NextEntryOffset;</span>
<span class="line" id="L707">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L708">                        self.index = self.buf.len;</span>
<span class="line" id="L709">                    }</span>
<span class="line" id="L710"></span>
<span class="line" id="L711">                    <span class="tok-kw">const</span> name_utf16le = <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u16</span>, &amp;dir_info.FileName)[<span class="tok-number">0</span> .. dir_info.FileNameLength / <span class="tok-number">2</span>];</span>
<span class="line" id="L712"></span>
<span class="line" id="L713">                    <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u16</span>, name_utf16le, &amp;[_]<span class="tok-type">u16</span>{<span class="tok-str">'.'</span>}) <span class="tok-kw">or</span> mem.eql(<span class="tok-type">u16</span>, name_utf16le, &amp;[_]<span class="tok-type">u16</span>{ <span class="tok-str">'.'</span>, <span class="tok-str">'.'</span> }))</span>
<span class="line" id="L714">                        <span class="tok-kw">continue</span>;</span>
<span class="line" id="L715">                    <span class="tok-comment">// Trust that Windows gives us valid UTF-16LE</span>
</span>
<span class="line" id="L716">                    <span class="tok-kw">const</span> name_utf8_len = std.unicode.utf16leToUtf8(self.name_data[<span class="tok-number">0</span>..], name_utf16le) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L717">                    <span class="tok-kw">const</span> name_utf8 = self.name_data[<span class="tok-number">0</span>..name_utf8_len];</span>
<span class="line" id="L718">                    <span class="tok-kw">const</span> kind = blk: {</span>
<span class="line" id="L719">                        <span class="tok-kw">const</span> attrs = dir_info.FileAttributes;</span>
<span class="line" id="L720">                        <span class="tok-kw">if</span> (attrs &amp; w.FILE_ATTRIBUTE_DIRECTORY != <span class="tok-number">0</span>) <span class="tok-kw">break</span> :blk Entry.Kind.Directory;</span>
<span class="line" id="L721">                        <span class="tok-kw">if</span> (attrs &amp; w.FILE_ATTRIBUTE_REPARSE_POINT != <span class="tok-number">0</span>) <span class="tok-kw">break</span> :blk Entry.Kind.SymLink;</span>
<span class="line" id="L722">                        <span class="tok-kw">break</span> :blk Entry.Kind.File;</span>
<span class="line" id="L723">                    };</span>
<span class="line" id="L724">                    <span class="tok-kw">return</span> Entry{</span>
<span class="line" id="L725">                        .name = name_utf8,</span>
<span class="line" id="L726">                        .kind = kind,</span>
<span class="line" id="L727">                    };</span>
<span class="line" id="L728">                }</span>
<span class="line" id="L729">            }</span>
<span class="line" id="L730">        },</span>
<span class="line" id="L731">        .wasi =&gt; <span class="tok-kw">struct</span> {</span>
<span class="line" id="L732">            dir: Dir,</span>
<span class="line" id="L733">            buf: [<span class="tok-number">8192</span>]<span class="tok-type">u8</span>, <span class="tok-comment">// TODO align(@alignOf(os.wasi.dirent_t)),</span>
</span>
<span class="line" id="L734">            cookie: <span class="tok-type">u64</span>,</span>
<span class="line" id="L735">            index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L736">            end_index: <span class="tok-type">usize</span>,</span>
<span class="line" id="L737"></span>
<span class="line" id="L738">            <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L739"></span>
<span class="line" id="L740">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Error = IteratorError;</span>
<span class="line" id="L741"></span>
<span class="line" id="L742">            <span class="tok-comment">/// Memory such as file names referenced in this returned entry becomes invalid</span></span>
<span class="line" id="L743">            <span class="tok-comment">/// with subsequent calls to `next`, as well as when this `Dir` is deinitialized.</span></span>
<span class="line" id="L744">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Self) Error!?Entry {</span>
<span class="line" id="L745">                <span class="tok-kw">return</span> self.nextWasi() <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L746">                    <span class="tok-comment">// To be consistent across platforms, iteration ends if the directory being iterated is deleted during iteration.</span>
</span>
<span class="line" id="L747">                    <span class="tok-comment">// This matches the behavior of non-Linux UNIX platforms.</span>
</span>
<span class="line" id="L748">                    <span class="tok-kw">error</span>.DirNotFound =&gt; <span class="tok-null">null</span>,</span>
<span class="line" id="L749">                    <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L750">                };</span>
<span class="line" id="L751">            }</span>
<span class="line" id="L752"></span>
<span class="line" id="L753">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ErrorWasi = <span class="tok-kw">error</span>{DirNotFound} || IteratorError;</span>
<span class="line" id="L754"></span>
<span class="line" id="L755">            <span class="tok-comment">/// Implementation of `next` that can return platform-dependent errors depending on the host platform.</span></span>
<span class="line" id="L756">            <span class="tok-comment">/// When the host platform is Linux, `error.DirNotFound` can be returned if the directory being</span></span>
<span class="line" id="L757">            <span class="tok-comment">/// iterated was deleted during iteration.</span></span>
<span class="line" id="L758">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">nextWasi</span>(self: *Self) ErrorWasi!?Entry {</span>
<span class="line" id="L759">                <span class="tok-comment">// We intentinally use fd_readdir even when linked with libc,</span>
</span>
<span class="line" id="L760">                <span class="tok-comment">// since its implementation is exactly the same as below,</span>
</span>
<span class="line" id="L761">                <span class="tok-comment">// and we avoid the code complexity here.</span>
</span>
<span class="line" id="L762">                <span class="tok-kw">const</span> w = os.wasi;</span>
<span class="line" id="L763">                start_over: <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L764">                    <span class="tok-kw">if</span> (self.index &gt;= self.end_index) {</span>
<span class="line" id="L765">                        <span class="tok-kw">var</span> bufused: <span class="tok-type">usize</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L766">                        <span class="tok-kw">switch</span> (w.fd_readdir(self.dir.fd, &amp;self.buf, self.buf.len, self.cookie, &amp;bufused)) {</span>
<span class="line" id="L767">                            .SUCCESS =&gt; {},</span>
<span class="line" id="L768">                            .BADF =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// Dir is invalid or was opened without iteration ability</span>
</span>
<span class="line" id="L769">                            .FAULT =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L770">                            .NOTDIR =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L771">                            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L772">                            .NOENT =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.DirNotFound, <span class="tok-comment">// The directory being iterated was deleted during iteration.</span>
</span>
<span class="line" id="L773">                            .NOTCAPABLE =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L774">                            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> os.unexpectedErrno(err),</span>
<span class="line" id="L775">                        }</span>
<span class="line" id="L776">                        <span class="tok-kw">if</span> (bufused == <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L777">                        self.index = <span class="tok-number">0</span>;</span>
<span class="line" id="L778">                        self.end_index = bufused;</span>
<span class="line" id="L779">                    }</span>
<span class="line" id="L780">                    <span class="tok-kw">const</span> entry = <span class="tok-builtin">@ptrCast</span>(*<span class="tok-kw">align</span>(<span class="tok-number">1</span>) w.dirent_t, &amp;self.buf[self.index]);</span>
<span class="line" id="L781">                    <span class="tok-kw">const</span> entry_size = <span class="tok-builtin">@sizeOf</span>(w.dirent_t);</span>
<span class="line" id="L782">                    <span class="tok-kw">const</span> name_index = self.index + entry_size;</span>
<span class="line" id="L783">                    <span class="tok-kw">const</span> name = mem.span(self.buf[name_index .. name_index + entry.d_namlen]);</span>
<span class="line" id="L784"></span>
<span class="line" id="L785">                    <span class="tok-kw">const</span> next_index = name_index + entry.d_namlen;</span>
<span class="line" id="L786">                    self.index = next_index;</span>
<span class="line" id="L787">                    self.cookie = entry.d_next;</span>
<span class="line" id="L788"></span>
<span class="line" id="L789">                    <span class="tok-comment">// skip . and .. entries</span>
</span>
<span class="line" id="L790">                    <span class="tok-kw">if</span> (mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;.&quot;</span>) <span class="tok-kw">or</span> mem.eql(<span class="tok-type">u8</span>, name, <span class="tok-str">&quot;..&quot;</span>)) {</span>
<span class="line" id="L791">                        <span class="tok-kw">continue</span> :start_over;</span>
<span class="line" id="L792">                    }</span>
<span class="line" id="L793"></span>
<span class="line" id="L794">                    <span class="tok-kw">const</span> entry_kind = <span class="tok-kw">switch</span> (entry.d_type) {</span>
<span class="line" id="L795">                        .BLOCK_DEVICE =&gt; Entry.Kind.BlockDevice,</span>
<span class="line" id="L796">                        .CHARACTER_DEVICE =&gt; Entry.Kind.CharacterDevice,</span>
<span class="line" id="L797">                        .DIRECTORY =&gt; Entry.Kind.Directory,</span>
<span class="line" id="L798">                        .SYMBOLIC_LINK =&gt; Entry.Kind.SymLink,</span>
<span class="line" id="L799">                        .REGULAR_FILE =&gt; Entry.Kind.File,</span>
<span class="line" id="L800">                        .SOCKET_STREAM, .SOCKET_DGRAM =&gt; Entry.Kind.UnixDomainSocket,</span>
<span class="line" id="L801">                        <span class="tok-kw">else</span> =&gt; Entry.Kind.Unknown,</span>
<span class="line" id="L802">                    };</span>
<span class="line" id="L803">                    <span class="tok-kw">return</span> Entry{</span>
<span class="line" id="L804">                        .name = name,</span>
<span class="line" id="L805">                        .kind = entry_kind,</span>
<span class="line" id="L806">                    };</span>
<span class="line" id="L807">                }</span>
<span class="line" id="L808">            }</span>
<span class="line" id="L809">        },</span>
<span class="line" id="L810">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;unimplemented&quot;</span>),</span>
<span class="line" id="L811">    };</span>
<span class="line" id="L812"></span>
<span class="line" id="L813">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">iterate</span>(self: IterableDir) Iterator {</span>
<span class="line" id="L814">        <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L815">            .macos,</span>
<span class="line" id="L816">            .ios,</span>
<span class="line" id="L817">            .freebsd,</span>
<span class="line" id="L818">            .netbsd,</span>
<span class="line" id="L819">            .dragonfly,</span>
<span class="line" id="L820">            .openbsd,</span>
<span class="line" id="L821">            .solaris,</span>
<span class="line" id="L822">            =&gt; <span class="tok-kw">return</span> Iterator{</span>
<span class="line" id="L823">                .dir = self.dir,</span>
<span class="line" id="L824">                .seek = <span class="tok-number">0</span>,</span>
<span class="line" id="L825">                .index = <span class="tok-number">0</span>,</span>
<span class="line" id="L826">                .end_index = <span class="tok-number">0</span>,</span>
<span class="line" id="L827">                .buf = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L828">                .first_iter = <span class="tok-null">true</span>,</span>
<span class="line" id="L829">            },</span>
<span class="line" id="L830">            .linux, .haiku =&gt; <span class="tok-kw">return</span> Iterator{</span>
<span class="line" id="L831">                .dir = self.dir,</span>
<span class="line" id="L832">                .index = <span class="tok-number">0</span>,</span>
<span class="line" id="L833">                .end_index = <span class="tok-number">0</span>,</span>
<span class="line" id="L834">                .buf = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L835">                .first_iter = <span class="tok-null">true</span>,</span>
<span class="line" id="L836">            },</span>
<span class="line" id="L837">            .windows =&gt; <span class="tok-kw">return</span> Iterator{</span>
<span class="line" id="L838">                .dir = self.dir,</span>
<span class="line" id="L839">                .index = <span class="tok-number">0</span>,</span>
<span class="line" id="L840">                .end_index = <span class="tok-number">0</span>,</span>
<span class="line" id="L841">                .first_iter = <span class="tok-null">true</span>,</span>
<span class="line" id="L842">                .buf = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L843">                .name_data = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L844">            },</span>
<span class="line" id="L845">            .wasi =&gt; <span class="tok-kw">return</span> Iterator{</span>
<span class="line" id="L846">                .dir = self.dir,</span>
<span class="line" id="L847">                .cookie = os.wasi.DIRCOOKIE_START,</span>
<span class="line" id="L848">                .index = <span class="tok-number">0</span>,</span>
<span class="line" id="L849">                .end_index = <span class="tok-number">0</span>,</span>
<span class="line" id="L850">                .buf = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L851">            },</span>
<span class="line" id="L852">            <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;unimplemented&quot;</span>),</span>
<span class="line" id="L853">        }</span>
<span class="line" id="L854">    }</span>
<span class="line" id="L855"></span>
<span class="line" id="L856">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Walker = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L857">        stack: std.ArrayList(StackItem),</span>
<span class="line" id="L858">        name_buffer: std.ArrayList(<span class="tok-type">u8</span>),</span>
<span class="line" id="L859"></span>
<span class="line" id="L860">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WalkerEntry = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L861">            <span class="tok-comment">/// The containing directory. This can be used to operate directly on `basename`</span></span>
<span class="line" id="L862">            <span class="tok-comment">/// rather than `path`, avoiding `error.NameTooLong` for deeply nested paths.</span></span>
<span class="line" id="L863">            <span class="tok-comment">/// The directory remains open until `next` or `deinit` is called.</span></span>
<span class="line" id="L864">            dir: Dir,</span>
<span class="line" id="L865">            basename: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L866">            path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L867">            kind: IterableDir.Entry.Kind,</span>
<span class="line" id="L868">        };</span>
<span class="line" id="L869"></span>
<span class="line" id="L870">        <span class="tok-kw">const</span> StackItem = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L871">            iter: IterableDir.Iterator,</span>
<span class="line" id="L872">            dirname_len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L873">        };</span>
<span class="line" id="L874"></span>
<span class="line" id="L875">        <span class="tok-comment">/// After each call to this function, and on deinit(), the memory returned</span></span>
<span class="line" id="L876">        <span class="tok-comment">/// from this function becomes invalid. A copy must be made in order to keep</span></span>
<span class="line" id="L877">        <span class="tok-comment">/// a reference to the path.</span></span>
<span class="line" id="L878">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Walker) !?WalkerEntry {</span>
<span class="line" id="L879">            <span class="tok-kw">while</span> (self.stack.items.len != <span class="tok-number">0</span>) {</span>
<span class="line" id="L880">                <span class="tok-comment">// `top` and `containing` become invalid after appending to `self.stack`</span>
</span>
<span class="line" id="L881">                <span class="tok-kw">var</span> top = &amp;self.stack.items[self.stack.items.len - <span class="tok-number">1</span>];</span>
<span class="line" id="L882">                <span class="tok-kw">var</span> containing = top;</span>
<span class="line" id="L883">                <span class="tok-kw">var</span> dirname_len = top.dirname_len;</span>
<span class="line" id="L884">                <span class="tok-kw">if</span> (<span class="tok-kw">try</span> top.iter.next()) |base| {</span>
<span class="line" id="L885">                    self.name_buffer.shrinkRetainingCapacity(dirname_len);</span>
<span class="line" id="L886">                    <span class="tok-kw">if</span> (self.name_buffer.items.len != <span class="tok-number">0</span>) {</span>
<span class="line" id="L887">                        <span class="tok-kw">try</span> self.name_buffer.append(path.sep);</span>
<span class="line" id="L888">                        dirname_len += <span class="tok-number">1</span>;</span>
<span class="line" id="L889">                    }</span>
<span class="line" id="L890">                    <span class="tok-kw">try</span> self.name_buffer.appendSlice(base.name);</span>
<span class="line" id="L891">                    <span class="tok-kw">if</span> (base.kind == .Directory) {</span>
<span class="line" id="L892">                        <span class="tok-kw">var</span> new_dir = top.iter.dir.openIterableDir(base.name, .{}) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L893">                            <span class="tok-kw">error</span>.NameTooLong =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// no path sep in base.name</span>
</span>
<span class="line" id="L894">                            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L895">                        };</span>
<span class="line" id="L896">                        {</span>
<span class="line" id="L897">                            <span class="tok-kw">errdefer</span> new_dir.close();</span>
<span class="line" id="L898">                            <span class="tok-kw">try</span> self.stack.append(StackItem{</span>
<span class="line" id="L899">                                .iter = new_dir.iterate(),</span>
<span class="line" id="L900">                                .dirname_len = self.name_buffer.items.len,</span>
<span class="line" id="L901">                            });</span>
<span class="line" id="L902">                            top = &amp;self.stack.items[self.stack.items.len - <span class="tok-number">1</span>];</span>
<span class="line" id="L903">                            containing = &amp;self.stack.items[self.stack.items.len - <span class="tok-number">2</span>];</span>
<span class="line" id="L904">                        }</span>
<span class="line" id="L905">                    }</span>
<span class="line" id="L906">                    <span class="tok-kw">return</span> WalkerEntry{</span>
<span class="line" id="L907">                        .dir = containing.iter.dir,</span>
<span class="line" id="L908">                        .basename = self.name_buffer.items[dirname_len..],</span>
<span class="line" id="L909">                        .path = self.name_buffer.items,</span>
<span class="line" id="L910">                        .kind = base.kind,</span>
<span class="line" id="L911">                    };</span>
<span class="line" id="L912">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L913">                    <span class="tok-kw">var</span> item = self.stack.pop();</span>
<span class="line" id="L914">                    <span class="tok-kw">if</span> (self.stack.items.len != <span class="tok-number">0</span>) {</span>
<span class="line" id="L915">                        item.iter.dir.close();</span>
<span class="line" id="L916">                    }</span>
<span class="line" id="L917">                }</span>
<span class="line" id="L918">            }</span>
<span class="line" id="L919">            <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L920">        }</span>
<span class="line" id="L921"></span>
<span class="line" id="L922">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Walker) <span class="tok-type">void</span> {</span>
<span class="line" id="L923">            <span class="tok-comment">// Close any remaining directories except the initial one (which is always at index 0)</span>
</span>
<span class="line" id="L924">            <span class="tok-kw">if</span> (self.stack.items.len &gt; <span class="tok-number">1</span>) {</span>
<span class="line" id="L925">                <span class="tok-kw">for</span> (self.stack.items[<span class="tok-number">1</span>..]) |*item| {</span>
<span class="line" id="L926">                    item.iter.dir.close();</span>
<span class="line" id="L927">                }</span>
<span class="line" id="L928">            }</span>
<span class="line" id="L929">            self.stack.deinit();</span>
<span class="line" id="L930">            self.name_buffer.deinit();</span>
<span class="line" id="L931">        }</span>
<span class="line" id="L932">    };</span>
<span class="line" id="L933"></span>
<span class="line" id="L934">    <span class="tok-comment">/// Recursively iterates over a directory.</span></span>
<span class="line" id="L935">    <span class="tok-comment">/// Must call `Walker.deinit` when done.</span></span>
<span class="line" id="L936">    <span class="tok-comment">/// The order of returned file system entries is undefined.</span></span>
<span class="line" id="L937">    <span class="tok-comment">/// `self` will not be closed after walking it.</span></span>
<span class="line" id="L938">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">walk</span>(self: IterableDir, allocator: Allocator) !Walker {</span>
<span class="line" id="L939">        <span class="tok-kw">var</span> name_buffer = std.ArrayList(<span class="tok-type">u8</span>).init(allocator);</span>
<span class="line" id="L940">        <span class="tok-kw">errdefer</span> name_buffer.deinit();</span>
<span class="line" id="L941"></span>
<span class="line" id="L942">        <span class="tok-kw">var</span> stack = std.ArrayList(Walker.StackItem).init(allocator);</span>
<span class="line" id="L943">        <span class="tok-kw">errdefer</span> stack.deinit();</span>
<span class="line" id="L944"></span>
<span class="line" id="L945">        <span class="tok-kw">try</span> stack.append(Walker.StackItem{</span>
<span class="line" id="L946">            .iter = self.iterate(),</span>
<span class="line" id="L947">            .dirname_len = <span class="tok-number">0</span>,</span>
<span class="line" id="L948">        });</span>
<span class="line" id="L949"></span>
<span class="line" id="L950">        <span class="tok-kw">return</span> Walker{</span>
<span class="line" id="L951">            .stack = stack,</span>
<span class="line" id="L952">            .name_buffer = name_buffer,</span>
<span class="line" id="L953">        };</span>
<span class="line" id="L954">    }</span>
<span class="line" id="L955"></span>
<span class="line" id="L956">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">close</span>(self: *IterableDir) <span class="tok-type">void</span> {</span>
<span class="line" id="L957">        self.dir.close();</span>
<span class="line" id="L958">        self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L959">    }</span>
<span class="line" id="L960"></span>
<span class="line" id="L961">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ChmodError = File.ChmodError;</span>
<span class="line" id="L962"></span>
<span class="line" id="L963">    <span class="tok-comment">/// Changes the mode of the directory.</span></span>
<span class="line" id="L964">    <span class="tok-comment">/// The process must have the correct privileges in order to do this</span></span>
<span class="line" id="L965">    <span class="tok-comment">/// successfully, or must have the effective user ID matching the owner</span></span>
<span class="line" id="L966">    <span class="tok-comment">/// of the directory.</span></span>
<span class="line" id="L967">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">chmod</span>(self: IterableDir, new_mode: File.Mode) ChmodError!<span class="tok-type">void</span> {</span>
<span class="line" id="L968">        <span class="tok-kw">const</span> file: File = .{</span>
<span class="line" id="L969">            .handle = self.dir.fd,</span>
<span class="line" id="L970">            .capable_io_mode = .blocking,</span>
<span class="line" id="L971">        };</span>
<span class="line" id="L972">        <span class="tok-kw">try</span> file.chmod(new_mode);</span>
<span class="line" id="L973">    }</span>
<span class="line" id="L974"></span>
<span class="line" id="L975">    <span class="tok-comment">/// Changes the owner and group of the directory.</span></span>
<span class="line" id="L976">    <span class="tok-comment">/// The process must have the correct privileges in order to do this</span></span>
<span class="line" id="L977">    <span class="tok-comment">/// successfully. The group may be changed by the owner of the directory to</span></span>
<span class="line" id="L978">    <span class="tok-comment">/// any group of which the owner is a member. If the</span></span>
<span class="line" id="L979">    <span class="tok-comment">/// owner or group is specified as `null`, the ID is not changed.</span></span>
<span class="line" id="L980">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">chown</span>(self: IterableDir, owner: ?File.Uid, group: ?File.Gid) ChownError!<span class="tok-type">void</span> {</span>
<span class="line" id="L981">        <span class="tok-kw">const</span> file: File = .{</span>
<span class="line" id="L982">            .handle = self.dir.fd,</span>
<span class="line" id="L983">            .capable_io_mode = .blocking,</span>
<span class="line" id="L984">        };</span>
<span class="line" id="L985">        <span class="tok-kw">try</span> file.chown(owner, group);</span>
<span class="line" id="L986">    }</span>
<span class="line" id="L987"></span>
<span class="line" id="L988">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ChownError = File.ChownError;</span>
<span class="line" id="L989">};</span>
<span class="line" id="L990"></span>
<span class="line" id="L991"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Dir = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L992">    fd: os.fd_t,</span>
<span class="line" id="L993"></span>
<span class="line" id="L994">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> iterate = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;only 'IterableDir' can be iterated; 'IterableDir' can be obtained with 'openIterableDir'&quot;</span>);</span>
<span class="line" id="L995">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> walk = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;only 'IterableDir' can be walked; 'IterableDir' can be obtained with 'openIterableDir'&quot;</span>);</span>
<span class="line" id="L996">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> chmod = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;only 'IterableDir' can have its mode changed; 'IterableDir' can be obtained with 'openIterableDir'&quot;</span>);</span>
<span class="line" id="L997">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> chown = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;only 'IterableDir' can have its owner changed; 'IterableDir' can be obtained with 'openIterableDir'&quot;</span>);</span>
<span class="line" id="L998"></span>
<span class="line" id="L999">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OpenError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L1000">        FileNotFound,</span>
<span class="line" id="L1001">        NotDir,</span>
<span class="line" id="L1002">        InvalidHandle,</span>
<span class="line" id="L1003">        AccessDenied,</span>
<span class="line" id="L1004">        SymLinkLoop,</span>
<span class="line" id="L1005">        ProcessFdQuotaExceeded,</span>
<span class="line" id="L1006">        NameTooLong,</span>
<span class="line" id="L1007">        SystemFdQuotaExceeded,</span>
<span class="line" id="L1008">        NoDevice,</span>
<span class="line" id="L1009">        SystemResources,</span>
<span class="line" id="L1010">        InvalidUtf8,</span>
<span class="line" id="L1011">        BadPathName,</span>
<span class="line" id="L1012">        DeviceBusy,</span>
<span class="line" id="L1013">    } || os.UnexpectedError;</span>
<span class="line" id="L1014"></span>
<span class="line" id="L1015">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">close</span>(self: *Dir) <span class="tok-type">void</span> {</span>
<span class="line" id="L1016">        <span class="tok-kw">if</span> (need_async_thread) {</span>
<span class="line" id="L1017">            std.event.Loop.instance.?.close(self.fd);</span>
<span class="line" id="L1018">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1019">            os.close(self.fd);</span>
<span class="line" id="L1020">        }</span>
<span class="line" id="L1021">        self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1022">    }</span>
<span class="line" id="L1023"></span>
<span class="line" id="L1024">    <span class="tok-comment">/// Opens a file for reading or writing, without attempting to create a new file.</span></span>
<span class="line" id="L1025">    <span class="tok-comment">/// To create a new file, see `createFile`.</span></span>
<span class="line" id="L1026">    <span class="tok-comment">/// Call `File.close` to release the resource.</span></span>
<span class="line" id="L1027">    <span class="tok-comment">/// Asserts that the path parameter has no null bytes.</span></span>
<span class="line" id="L1028">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openFile</span>(self: Dir, sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: File.OpenFlags) File.OpenError!File {</span>
<span class="line" id="L1029">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1030">            <span class="tok-kw">const</span> path_w = <span class="tok-kw">try</span> os.windows.sliceToPrefixedFileW(sub_path);</span>
<span class="line" id="L1031">            <span class="tok-kw">return</span> self.openFileW(path_w.span(), flags);</span>
<span class="line" id="L1032">        }</span>
<span class="line" id="L1033">        <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L1034">            <span class="tok-kw">return</span> self.openFileWasi(sub_path, flags);</span>
<span class="line" id="L1035">        }</span>
<span class="line" id="L1036">        <span class="tok-kw">const</span> path_c = <span class="tok-kw">try</span> os.toPosixPath(sub_path);</span>
<span class="line" id="L1037">        <span class="tok-kw">return</span> self.openFileZ(&amp;path_c, flags);</span>
<span class="line" id="L1038">    }</span>
<span class="line" id="L1039"></span>
<span class="line" id="L1040">    <span class="tok-comment">/// Same as `openFile` but WASI only.</span></span>
<span class="line" id="L1041">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openFileWasi</span>(self: Dir, sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: File.OpenFlags) File.OpenError!File {</span>
<span class="line" id="L1042">        <span class="tok-kw">const</span> w = os.wasi;</span>
<span class="line" id="L1043">        <span class="tok-kw">var</span> fdflags: w.fdflags_t = <span class="tok-number">0x0</span>;</span>
<span class="line" id="L1044">        <span class="tok-kw">var</span> base: w.rights_t = <span class="tok-number">0x0</span>;</span>
<span class="line" id="L1045">        <span class="tok-kw">if</span> (flags.isRead()) {</span>
<span class="line" id="L1046">            base |= w.RIGHT.FD_READ | w.RIGHT.FD_TELL | w.RIGHT.FD_SEEK | w.RIGHT.FD_FILESTAT_GET;</span>
<span class="line" id="L1047">        }</span>
<span class="line" id="L1048">        <span class="tok-kw">if</span> (flags.isWrite()) {</span>
<span class="line" id="L1049">            fdflags |= w.FDFLAG.APPEND;</span>
<span class="line" id="L1050">            base |= w.RIGHT.FD_WRITE |</span>
<span class="line" id="L1051">                w.RIGHT.FD_TELL |</span>
<span class="line" id="L1052">                w.RIGHT.FD_SEEK |</span>
<span class="line" id="L1053">                w.RIGHT.FD_DATASYNC |</span>
<span class="line" id="L1054">                w.RIGHT.FD_FDSTAT_SET_FLAGS |</span>
<span class="line" id="L1055">                w.RIGHT.FD_SYNC |</span>
<span class="line" id="L1056">                w.RIGHT.FD_ALLOCATE |</span>
<span class="line" id="L1057">                w.RIGHT.FD_ADVISE |</span>
<span class="line" id="L1058">                w.RIGHT.FD_FILESTAT_SET_TIMES |</span>
<span class="line" id="L1059">                w.RIGHT.FD_FILESTAT_SET_SIZE;</span>
<span class="line" id="L1060">        }</span>
<span class="line" id="L1061">        <span class="tok-kw">if</span> (self.fd == os.wasi.AT.FDCWD <span class="tok-kw">or</span> path.isAbsolute(sub_path)) {</span>
<span class="line" id="L1062">            <span class="tok-comment">// Resolve absolute or CWD-relative paths to a path within a Preopen</span>
</span>
<span class="line" id="L1063">            <span class="tok-kw">var</span> resolved_path_buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1064">            <span class="tok-kw">const</span> resolved_path = <span class="tok-kw">try</span> os.resolvePathWasi(sub_path, &amp;resolved_path_buf);</span>
<span class="line" id="L1065">            <span class="tok-kw">const</span> fd = <span class="tok-kw">try</span> os.openatWasi(resolved_path.dir_fd, resolved_path.relative_path, <span class="tok-number">0x0</span>, <span class="tok-number">0x0</span>, fdflags, base, <span class="tok-number">0x0</span>);</span>
<span class="line" id="L1066">            <span class="tok-kw">return</span> File{ .handle = fd };</span>
<span class="line" id="L1067">        }</span>
<span class="line" id="L1068">        <span class="tok-kw">const</span> fd = <span class="tok-kw">try</span> os.openatWasi(self.fd, sub_path, <span class="tok-number">0x0</span>, <span class="tok-number">0x0</span>, fdflags, base, <span class="tok-number">0x0</span>);</span>
<span class="line" id="L1069">        <span class="tok-kw">return</span> File{ .handle = fd };</span>
<span class="line" id="L1070">    }</span>
<span class="line" id="L1071"></span>
<span class="line" id="L1072">    <span class="tok-comment">/// Same as `openFile` but the path parameter is null-terminated.</span></span>
<span class="line" id="L1073">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openFileZ</span>(self: Dir, sub_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: File.OpenFlags) File.OpenError!File {</span>
<span class="line" id="L1074">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1075">            <span class="tok-kw">const</span> path_w = <span class="tok-kw">try</span> os.windows.cStrToPrefixedFileW(sub_path);</span>
<span class="line" id="L1076">            <span class="tok-kw">return</span> self.openFileW(path_w.span(), flags);</span>
<span class="line" id="L1077">        }</span>
<span class="line" id="L1078"></span>
<span class="line" id="L1079">        <span class="tok-kw">var</span> os_flags: <span class="tok-type">u32</span> = os.O.CLOEXEC;</span>
<span class="line" id="L1080">        <span class="tok-comment">// Use the O locking flags if the os supports them to acquire the lock</span>
</span>
<span class="line" id="L1081">        <span class="tok-comment">// atomically.</span>
</span>
<span class="line" id="L1082">        <span class="tok-kw">const</span> has_flock_open_flags = <span class="tok-builtin">@hasDecl</span>(os.O, <span class="tok-str">&quot;EXLOCK&quot;</span>);</span>
<span class="line" id="L1083">        <span class="tok-kw">if</span> (has_flock_open_flags) {</span>
<span class="line" id="L1084">            <span class="tok-comment">// Note that the O.NONBLOCK flag is removed after the openat() call</span>
</span>
<span class="line" id="L1085">            <span class="tok-comment">// is successful.</span>
</span>
<span class="line" id="L1086">            <span class="tok-kw">const</span> nonblocking_lock_flag: <span class="tok-type">u32</span> = <span class="tok-kw">if</span> (flags.lock_nonblocking)</span>
<span class="line" id="L1087">                os.O.NONBLOCK</span>
<span class="line" id="L1088">            <span class="tok-kw">else</span></span>
<span class="line" id="L1089">                <span class="tok-number">0</span>;</span>
<span class="line" id="L1090">            os_flags |= <span class="tok-kw">switch</span> (flags.lock) {</span>
<span class="line" id="L1091">                .None =&gt; <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L1092">                .Shared =&gt; os.O.SHLOCK | nonblocking_lock_flag,</span>
<span class="line" id="L1093">                .Exclusive =&gt; os.O.EXLOCK | nonblocking_lock_flag,</span>
<span class="line" id="L1094">            };</span>
<span class="line" id="L1095">        }</span>
<span class="line" id="L1096">        <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(os.O, <span class="tok-str">&quot;LARGEFILE&quot;</span>)) {</span>
<span class="line" id="L1097">            os_flags |= os.O.LARGEFILE;</span>
<span class="line" id="L1098">        }</span>
<span class="line" id="L1099">        <span class="tok-kw">if</span> (!flags.allow_ctty) {</span>
<span class="line" id="L1100">            os_flags |= os.O.NOCTTY;</span>
<span class="line" id="L1101">        }</span>
<span class="line" id="L1102">        os_flags |= <span class="tok-kw">switch</span> (flags.mode) {</span>
<span class="line" id="L1103">            .read_only =&gt; <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, os.O.RDONLY),</span>
<span class="line" id="L1104">            .write_only =&gt; <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, os.O.WRONLY),</span>
<span class="line" id="L1105">            .read_write =&gt; <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, os.O.RDWR),</span>
<span class="line" id="L1106">        };</span>
<span class="line" id="L1107">        <span class="tok-kw">const</span> fd = <span class="tok-kw">if</span> (flags.intended_io_mode != .blocking)</span>
<span class="line" id="L1108">            <span class="tok-kw">try</span> std.event.Loop.instance.?.openatZ(self.fd, sub_path, os_flags, <span class="tok-number">0</span>)</span>
<span class="line" id="L1109">        <span class="tok-kw">else</span></span>
<span class="line" id="L1110">            <span class="tok-kw">try</span> os.openatZ(self.fd, sub_path, os_flags, <span class="tok-number">0</span>);</span>
<span class="line" id="L1111">        <span class="tok-kw">errdefer</span> os.close(fd);</span>
<span class="line" id="L1112"></span>
<span class="line" id="L1113">        <span class="tok-comment">// WASI doesn't have os.flock so we intetinally check OS prior to the inner if block</span>
</span>
<span class="line" id="L1114">        <span class="tok-comment">// since it is not compiltime-known and we need to avoid undefined symbol in Wasm.</span>
</span>
<span class="line" id="L1115">        <span class="tok-kw">if</span> (builtin.target.os.tag != .wasi) {</span>
<span class="line" id="L1116">            <span class="tok-kw">if</span> (!has_flock_open_flags <span class="tok-kw">and</span> flags.lock != .None) {</span>
<span class="line" id="L1117">                <span class="tok-comment">// TODO: integrate async I/O</span>
</span>
<span class="line" id="L1118">                <span class="tok-kw">const</span> lock_nonblocking = <span class="tok-kw">if</span> (flags.lock_nonblocking) os.LOCK.NB <span class="tok-kw">else</span> <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1119">                <span class="tok-kw">try</span> os.flock(fd, <span class="tok-kw">switch</span> (flags.lock) {</span>
<span class="line" id="L1120">                    .None =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1121">                    .Shared =&gt; os.LOCK.SH | lock_nonblocking,</span>
<span class="line" id="L1122">                    .Exclusive =&gt; os.LOCK.EX | lock_nonblocking,</span>
<span class="line" id="L1123">                });</span>
<span class="line" id="L1124">            }</span>
<span class="line" id="L1125">        }</span>
<span class="line" id="L1126"></span>
<span class="line" id="L1127">        <span class="tok-kw">if</span> (has_flock_open_flags <span class="tok-kw">and</span> flags.lock_nonblocking) {</span>
<span class="line" id="L1128">            <span class="tok-kw">var</span> fl_flags = os.fcntl(fd, os.F.GETFL, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1129">                <span class="tok-kw">error</span>.FileBusy =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1130">                <span class="tok-kw">error</span>.Locked =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1131">                <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1132">                <span class="tok-kw">error</span>.DeadLock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1133">                <span class="tok-kw">error</span>.LockedRegionLimitExceeded =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1134">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1135">            };</span>
<span class="line" id="L1136">            fl_flags &amp;= ~<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, os.O.NONBLOCK);</span>
<span class="line" id="L1137">            _ = os.fcntl(fd, os.F.SETFL, fl_flags) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1138">                <span class="tok-kw">error</span>.FileBusy =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1139">                <span class="tok-kw">error</span>.Locked =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1140">                <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1141">                <span class="tok-kw">error</span>.DeadLock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1142">                <span class="tok-kw">error</span>.LockedRegionLimitExceeded =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1143">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1144">            };</span>
<span class="line" id="L1145">        }</span>
<span class="line" id="L1146"></span>
<span class="line" id="L1147">        <span class="tok-kw">return</span> File{</span>
<span class="line" id="L1148">            .handle = fd,</span>
<span class="line" id="L1149">            .capable_io_mode = .blocking,</span>
<span class="line" id="L1150">            .intended_io_mode = flags.intended_io_mode,</span>
<span class="line" id="L1151">        };</span>
<span class="line" id="L1152">    }</span>
<span class="line" id="L1153"></span>
<span class="line" id="L1154">    <span class="tok-comment">/// Same as `openFile` but Windows-only and the path parameter is</span></span>
<span class="line" id="L1155">    <span class="tok-comment">/// [WTF-16](https://simonsapin.github.io/wtf-8/#potentially-ill-formed-utf-16) encoded.</span></span>
<span class="line" id="L1156">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openFileW</span>(self: Dir, sub_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, flags: File.OpenFlags) File.OpenError!File {</span>
<span class="line" id="L1157">        <span class="tok-kw">const</span> w = os.windows;</span>
<span class="line" id="L1158">        <span class="tok-kw">const</span> file: File = .{</span>
<span class="line" id="L1159">            .handle = <span class="tok-kw">try</span> w.OpenFile(sub_path_w, .{</span>
<span class="line" id="L1160">                .dir = self.fd,</span>
<span class="line" id="L1161">                .access_mask = w.SYNCHRONIZE |</span>
<span class="line" id="L1162">                    (<span class="tok-kw">if</span> (flags.isRead()) <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, w.GENERIC_READ) <span class="tok-kw">else</span> <span class="tok-number">0</span>) |</span>
<span class="line" id="L1163">                    (<span class="tok-kw">if</span> (flags.isWrite()) <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, w.GENERIC_WRITE) <span class="tok-kw">else</span> <span class="tok-number">0</span>),</span>
<span class="line" id="L1164">                .creation = w.FILE_OPEN,</span>
<span class="line" id="L1165">                .io_mode = flags.intended_io_mode,</span>
<span class="line" id="L1166">            }),</span>
<span class="line" id="L1167">            .capable_io_mode = std.io.default_mode,</span>
<span class="line" id="L1168">            .intended_io_mode = flags.intended_io_mode,</span>
<span class="line" id="L1169">        };</span>
<span class="line" id="L1170">        <span class="tok-kw">var</span> io: w.IO_STATUS_BLOCK = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1171">        <span class="tok-kw">const</span> range_off: w.LARGE_INTEGER = <span class="tok-number">0</span>;</span>
<span class="line" id="L1172">        <span class="tok-kw">const</span> range_len: w.LARGE_INTEGER = <span class="tok-number">1</span>;</span>
<span class="line" id="L1173">        <span class="tok-kw">const</span> exclusive = <span class="tok-kw">switch</span> (flags.lock) {</span>
<span class="line" id="L1174">            .None =&gt; <span class="tok-kw">return</span> file,</span>
<span class="line" id="L1175">            .Shared =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1176">            .Exclusive =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1177">        };</span>
<span class="line" id="L1178">        <span class="tok-kw">try</span> w.LockFile(</span>
<span class="line" id="L1179">            file.handle,</span>
<span class="line" id="L1180">            <span class="tok-null">null</span>,</span>
<span class="line" id="L1181">            <span class="tok-null">null</span>,</span>
<span class="line" id="L1182">            <span class="tok-null">null</span>,</span>
<span class="line" id="L1183">            &amp;io,</span>
<span class="line" id="L1184">            &amp;range_off,</span>
<span class="line" id="L1185">            &amp;range_len,</span>
<span class="line" id="L1186">            <span class="tok-null">null</span>,</span>
<span class="line" id="L1187">            <span class="tok-builtin">@boolToInt</span>(flags.lock_nonblocking),</span>
<span class="line" id="L1188">            <span class="tok-builtin">@boolToInt</span>(exclusive),</span>
<span class="line" id="L1189">        );</span>
<span class="line" id="L1190">        <span class="tok-kw">return</span> file;</span>
<span class="line" id="L1191">    }</span>
<span class="line" id="L1192"></span>
<span class="line" id="L1193">    <span class="tok-comment">/// Creates, opens, or overwrites a file with write access.</span></span>
<span class="line" id="L1194">    <span class="tok-comment">/// Call `File.close` on the result when done.</span></span>
<span class="line" id="L1195">    <span class="tok-comment">/// Asserts that the path parameter has no null bytes.</span></span>
<span class="line" id="L1196">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createFile</span>(self: Dir, sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: File.CreateFlags) File.OpenError!File {</span>
<span class="line" id="L1197">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1198">            <span class="tok-kw">const</span> path_w = <span class="tok-kw">try</span> os.windows.sliceToPrefixedFileW(sub_path);</span>
<span class="line" id="L1199">            <span class="tok-kw">return</span> self.createFileW(path_w.span(), flags);</span>
<span class="line" id="L1200">        }</span>
<span class="line" id="L1201">        <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L1202">            <span class="tok-kw">return</span> self.createFileWasi(sub_path, flags);</span>
<span class="line" id="L1203">        }</span>
<span class="line" id="L1204">        <span class="tok-kw">const</span> path_c = <span class="tok-kw">try</span> os.toPosixPath(sub_path);</span>
<span class="line" id="L1205">        <span class="tok-kw">return</span> self.createFileZ(&amp;path_c, flags);</span>
<span class="line" id="L1206">    }</span>
<span class="line" id="L1207"></span>
<span class="line" id="L1208">    <span class="tok-comment">/// Same as `createFile` but WASI only.</span></span>
<span class="line" id="L1209">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createFileWasi</span>(self: Dir, sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: File.CreateFlags) File.OpenError!File {</span>
<span class="line" id="L1210">        <span class="tok-kw">const</span> w = os.wasi;</span>
<span class="line" id="L1211">        <span class="tok-kw">var</span> oflags = w.O.CREAT;</span>
<span class="line" id="L1212">        <span class="tok-kw">var</span> base: w.rights_t = w.RIGHT.FD_WRITE |</span>
<span class="line" id="L1213">            w.RIGHT.FD_DATASYNC |</span>
<span class="line" id="L1214">            w.RIGHT.FD_SEEK |</span>
<span class="line" id="L1215">            w.RIGHT.FD_TELL |</span>
<span class="line" id="L1216">            w.RIGHT.FD_FDSTAT_SET_FLAGS |</span>
<span class="line" id="L1217">            w.RIGHT.FD_SYNC |</span>
<span class="line" id="L1218">            w.RIGHT.FD_ALLOCATE |</span>
<span class="line" id="L1219">            w.RIGHT.FD_ADVISE |</span>
<span class="line" id="L1220">            w.RIGHT.FD_FILESTAT_SET_TIMES |</span>
<span class="line" id="L1221">            w.RIGHT.FD_FILESTAT_SET_SIZE |</span>
<span class="line" id="L1222">            w.RIGHT.FD_FILESTAT_GET;</span>
<span class="line" id="L1223">        <span class="tok-kw">if</span> (flags.read) {</span>
<span class="line" id="L1224">            base |= w.RIGHT.FD_READ;</span>
<span class="line" id="L1225">        }</span>
<span class="line" id="L1226">        <span class="tok-kw">if</span> (flags.truncate) {</span>
<span class="line" id="L1227">            oflags |= w.O.TRUNC;</span>
<span class="line" id="L1228">        }</span>
<span class="line" id="L1229">        <span class="tok-kw">if</span> (flags.exclusive) {</span>
<span class="line" id="L1230">            oflags |= w.O.EXCL;</span>
<span class="line" id="L1231">        }</span>
<span class="line" id="L1232">        <span class="tok-kw">if</span> (self.fd == os.wasi.AT.FDCWD <span class="tok-kw">or</span> path.isAbsolute(sub_path)) {</span>
<span class="line" id="L1233">            <span class="tok-comment">// Resolve absolute or CWD-relative paths to a path within a Preopen</span>
</span>
<span class="line" id="L1234">            <span class="tok-kw">var</span> resolved_path_buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1235">            <span class="tok-kw">const</span> resolved_path = <span class="tok-kw">try</span> os.resolvePathWasi(sub_path, &amp;resolved_path_buf);</span>
<span class="line" id="L1236">            <span class="tok-kw">const</span> fd = <span class="tok-kw">try</span> os.openatWasi(resolved_path.dir_fd, resolved_path.relative_path, <span class="tok-number">0x0</span>, oflags, <span class="tok-number">0x0</span>, base, <span class="tok-number">0x0</span>);</span>
<span class="line" id="L1237">            <span class="tok-kw">return</span> File{ .handle = fd };</span>
<span class="line" id="L1238">        }</span>
<span class="line" id="L1239">        <span class="tok-kw">const</span> fd = <span class="tok-kw">try</span> os.openatWasi(self.fd, sub_path, <span class="tok-number">0x0</span>, oflags, <span class="tok-number">0x0</span>, base, <span class="tok-number">0x0</span>);</span>
<span class="line" id="L1240">        <span class="tok-kw">return</span> File{ .handle = fd };</span>
<span class="line" id="L1241">    }</span>
<span class="line" id="L1242"></span>
<span class="line" id="L1243">    <span class="tok-comment">/// Same as `createFile` but the path parameter is null-terminated.</span></span>
<span class="line" id="L1244">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createFileZ</span>(self: Dir, sub_path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: File.CreateFlags) File.OpenError!File {</span>
<span class="line" id="L1245">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1246">            <span class="tok-kw">const</span> path_w = <span class="tok-kw">try</span> os.windows.cStrToPrefixedFileW(sub_path_c);</span>
<span class="line" id="L1247">            <span class="tok-kw">return</span> self.createFileW(path_w.span(), flags);</span>
<span class="line" id="L1248">        }</span>
<span class="line" id="L1249"></span>
<span class="line" id="L1250">        <span class="tok-comment">// Use the O locking flags if the os supports them to acquire the lock</span>
</span>
<span class="line" id="L1251">        <span class="tok-comment">// atomically.</span>
</span>
<span class="line" id="L1252">        <span class="tok-kw">const</span> has_flock_open_flags = <span class="tok-builtin">@hasDecl</span>(os.O, <span class="tok-str">&quot;EXLOCK&quot;</span>);</span>
<span class="line" id="L1253">        <span class="tok-comment">// Note that the O.NONBLOCK flag is removed after the openat() call</span>
</span>
<span class="line" id="L1254">        <span class="tok-comment">// is successful.</span>
</span>
<span class="line" id="L1255">        <span class="tok-kw">const</span> nonblocking_lock_flag: <span class="tok-type">u32</span> = <span class="tok-kw">if</span> (has_flock_open_flags <span class="tok-kw">and</span> flags.lock_nonblocking)</span>
<span class="line" id="L1256">            os.O.NONBLOCK</span>
<span class="line" id="L1257">        <span class="tok-kw">else</span></span>
<span class="line" id="L1258">            <span class="tok-number">0</span>;</span>
<span class="line" id="L1259">        <span class="tok-kw">const</span> lock_flag: <span class="tok-type">u32</span> = <span class="tok-kw">if</span> (has_flock_open_flags) <span class="tok-kw">switch</span> (flags.lock) {</span>
<span class="line" id="L1260">            .None =&gt; <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, <span class="tok-number">0</span>),</span>
<span class="line" id="L1261">            .Shared =&gt; os.O.SHLOCK | nonblocking_lock_flag,</span>
<span class="line" id="L1262">            .Exclusive =&gt; os.O.EXLOCK | nonblocking_lock_flag,</span>
<span class="line" id="L1263">        } <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1264"></span>
<span class="line" id="L1265">        <span class="tok-kw">const</span> O_LARGEFILE = <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(os.O, <span class="tok-str">&quot;LARGEFILE&quot;</span>)) os.O.LARGEFILE <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1266">        <span class="tok-kw">const</span> os_flags = lock_flag | O_LARGEFILE | os.O.CREAT | os.O.CLOEXEC |</span>
<span class="line" id="L1267">            (<span class="tok-kw">if</span> (flags.truncate) <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, os.O.TRUNC) <span class="tok-kw">else</span> <span class="tok-number">0</span>) |</span>
<span class="line" id="L1268">            (<span class="tok-kw">if</span> (flags.read) <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, os.O.RDWR) <span class="tok-kw">else</span> os.O.WRONLY) |</span>
<span class="line" id="L1269">            (<span class="tok-kw">if</span> (flags.exclusive) <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, os.O.EXCL) <span class="tok-kw">else</span> <span class="tok-number">0</span>);</span>
<span class="line" id="L1270">        <span class="tok-kw">const</span> fd = <span class="tok-kw">if</span> (flags.intended_io_mode != .blocking)</span>
<span class="line" id="L1271">            <span class="tok-kw">try</span> std.event.Loop.instance.?.openatZ(self.fd, sub_path_c, os_flags, flags.mode)</span>
<span class="line" id="L1272">        <span class="tok-kw">else</span></span>
<span class="line" id="L1273">            <span class="tok-kw">try</span> os.openatZ(self.fd, sub_path_c, os_flags, flags.mode);</span>
<span class="line" id="L1274">        <span class="tok-kw">errdefer</span> os.close(fd);</span>
<span class="line" id="L1275"></span>
<span class="line" id="L1276">        <span class="tok-comment">// WASI doesn't have os.flock so we intetinally check OS prior to the inner if block</span>
</span>
<span class="line" id="L1277">        <span class="tok-comment">// since it is not compiltime-known and we need to avoid undefined symbol in Wasm.</span>
</span>
<span class="line" id="L1278">        <span class="tok-kw">if</span> (builtin.target.os.tag != .wasi) {</span>
<span class="line" id="L1279">            <span class="tok-kw">if</span> (!has_flock_open_flags <span class="tok-kw">and</span> flags.lock != .None) {</span>
<span class="line" id="L1280">                <span class="tok-comment">// TODO: integrate async I/O</span>
</span>
<span class="line" id="L1281">                <span class="tok-kw">const</span> lock_nonblocking = <span class="tok-kw">if</span> (flags.lock_nonblocking) os.LOCK.NB <span class="tok-kw">else</span> <span class="tok-builtin">@as</span>(<span class="tok-type">i32</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L1282">                <span class="tok-kw">try</span> os.flock(fd, <span class="tok-kw">switch</span> (flags.lock) {</span>
<span class="line" id="L1283">                    .None =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1284">                    .Shared =&gt; os.LOCK.SH | lock_nonblocking,</span>
<span class="line" id="L1285">                    .Exclusive =&gt; os.LOCK.EX | lock_nonblocking,</span>
<span class="line" id="L1286">                });</span>
<span class="line" id="L1287">            }</span>
<span class="line" id="L1288">        }</span>
<span class="line" id="L1289"></span>
<span class="line" id="L1290">        <span class="tok-kw">if</span> (has_flock_open_flags <span class="tok-kw">and</span> flags.lock_nonblocking) {</span>
<span class="line" id="L1291">            <span class="tok-kw">var</span> fl_flags = os.fcntl(fd, os.F.GETFL, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1292">                <span class="tok-kw">error</span>.FileBusy =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1293">                <span class="tok-kw">error</span>.Locked =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1294">                <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1295">                <span class="tok-kw">error</span>.DeadLock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1296">                <span class="tok-kw">error</span>.LockedRegionLimitExceeded =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1297">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1298">            };</span>
<span class="line" id="L1299">            fl_flags &amp;= ~<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, os.O.NONBLOCK);</span>
<span class="line" id="L1300">            _ = os.fcntl(fd, os.F.SETFL, fl_flags) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1301">                <span class="tok-kw">error</span>.FileBusy =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1302">                <span class="tok-kw">error</span>.Locked =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1303">                <span class="tok-kw">error</span>.PermissionDenied =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1304">                <span class="tok-kw">error</span>.DeadLock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1305">                <span class="tok-kw">error</span>.LockedRegionLimitExceeded =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1306">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1307">            };</span>
<span class="line" id="L1308">        }</span>
<span class="line" id="L1309"></span>
<span class="line" id="L1310">        <span class="tok-kw">return</span> File{</span>
<span class="line" id="L1311">            .handle = fd,</span>
<span class="line" id="L1312">            .capable_io_mode = .blocking,</span>
<span class="line" id="L1313">            .intended_io_mode = flags.intended_io_mode,</span>
<span class="line" id="L1314">        };</span>
<span class="line" id="L1315">    }</span>
<span class="line" id="L1316"></span>
<span class="line" id="L1317">    <span class="tok-comment">/// Same as `createFile` but Windows-only and the path parameter is</span></span>
<span class="line" id="L1318">    <span class="tok-comment">/// [WTF-16](https://simonsapin.github.io/wtf-8/#potentially-ill-formed-utf-16) encoded.</span></span>
<span class="line" id="L1319">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createFileW</span>(self: Dir, sub_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, flags: File.CreateFlags) File.OpenError!File {</span>
<span class="line" id="L1320">        <span class="tok-kw">const</span> w = os.windows;</span>
<span class="line" id="L1321">        <span class="tok-kw">const</span> read_flag = <span class="tok-kw">if</span> (flags.read) <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, w.GENERIC_READ) <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1322">        <span class="tok-kw">const</span> file: File = .{</span>
<span class="line" id="L1323">            .handle = <span class="tok-kw">try</span> os.windows.OpenFile(sub_path_w, .{</span>
<span class="line" id="L1324">                .dir = self.fd,</span>
<span class="line" id="L1325">                .access_mask = w.SYNCHRONIZE | w.GENERIC_WRITE | read_flag,</span>
<span class="line" id="L1326">                .creation = <span class="tok-kw">if</span> (flags.exclusive)</span>
<span class="line" id="L1327">                    <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, w.FILE_CREATE)</span>
<span class="line" id="L1328">                <span class="tok-kw">else</span> <span class="tok-kw">if</span> (flags.truncate)</span>
<span class="line" id="L1329">                    <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, w.FILE_OVERWRITE_IF)</span>
<span class="line" id="L1330">                <span class="tok-kw">else</span></span>
<span class="line" id="L1331">                    <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, w.FILE_OPEN_IF),</span>
<span class="line" id="L1332">                .io_mode = flags.intended_io_mode,</span>
<span class="line" id="L1333">            }),</span>
<span class="line" id="L1334">            .capable_io_mode = std.io.default_mode,</span>
<span class="line" id="L1335">            .intended_io_mode = flags.intended_io_mode,</span>
<span class="line" id="L1336">        };</span>
<span class="line" id="L1337">        <span class="tok-kw">var</span> io: w.IO_STATUS_BLOCK = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1338">        <span class="tok-kw">const</span> range_off: w.LARGE_INTEGER = <span class="tok-number">0</span>;</span>
<span class="line" id="L1339">        <span class="tok-kw">const</span> range_len: w.LARGE_INTEGER = <span class="tok-number">1</span>;</span>
<span class="line" id="L1340">        <span class="tok-kw">const</span> exclusive = <span class="tok-kw">switch</span> (flags.lock) {</span>
<span class="line" id="L1341">            .None =&gt; <span class="tok-kw">return</span> file,</span>
<span class="line" id="L1342">            .Shared =&gt; <span class="tok-null">false</span>,</span>
<span class="line" id="L1343">            .Exclusive =&gt; <span class="tok-null">true</span>,</span>
<span class="line" id="L1344">        };</span>
<span class="line" id="L1345">        <span class="tok-kw">try</span> w.LockFile(</span>
<span class="line" id="L1346">            file.handle,</span>
<span class="line" id="L1347">            <span class="tok-null">null</span>,</span>
<span class="line" id="L1348">            <span class="tok-null">null</span>,</span>
<span class="line" id="L1349">            <span class="tok-null">null</span>,</span>
<span class="line" id="L1350">            &amp;io,</span>
<span class="line" id="L1351">            &amp;range_off,</span>
<span class="line" id="L1352">            &amp;range_len,</span>
<span class="line" id="L1353">            <span class="tok-null">null</span>,</span>
<span class="line" id="L1354">            <span class="tok-builtin">@boolToInt</span>(flags.lock_nonblocking),</span>
<span class="line" id="L1355">            <span class="tok-builtin">@boolToInt</span>(exclusive),</span>
<span class="line" id="L1356">        );</span>
<span class="line" id="L1357">        <span class="tok-kw">return</span> file;</span>
<span class="line" id="L1358">    }</span>
<span class="line" id="L1359"></span>
<span class="line" id="L1360">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">makeDir</span>(self: Dir, sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1361">        <span class="tok-kw">try</span> os.mkdirat(self.fd, sub_path, default_new_dir_mode);</span>
<span class="line" id="L1362">    }</span>
<span class="line" id="L1363"></span>
<span class="line" id="L1364">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">makeDirZ</span>(self: Dir, sub_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1365">        <span class="tok-kw">try</span> os.mkdiratZ(self.fd, sub_path, default_new_dir_mode);</span>
<span class="line" id="L1366">    }</span>
<span class="line" id="L1367"></span>
<span class="line" id="L1368">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">makeDirW</span>(self: Dir, sub_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1369">        <span class="tok-kw">try</span> os.mkdiratW(self.fd, sub_path, default_new_dir_mode);</span>
<span class="line" id="L1370">    }</span>
<span class="line" id="L1371"></span>
<span class="line" id="L1372">    <span class="tok-comment">/// Calls makeDir recursively to make an entire path. Returns success if the path</span></span>
<span class="line" id="L1373">    <span class="tok-comment">/// already exists and is a directory.</span></span>
<span class="line" id="L1374">    <span class="tok-comment">/// This function is not atomic, and if it returns an error, the file system may</span></span>
<span class="line" id="L1375">    <span class="tok-comment">/// have been modified regardless.</span></span>
<span class="line" id="L1376">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">makePath</span>(self: Dir, sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1377">        <span class="tok-kw">var</span> end_index: <span class="tok-type">usize</span> = sub_path.len;</span>
<span class="line" id="L1378">        <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1379">            self.makeDir(sub_path[<span class="tok-number">0</span>..end_index]) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1380">                <span class="tok-kw">error</span>.PathAlreadyExists =&gt; {</span>
<span class="line" id="L1381">                    <span class="tok-comment">// TODO stat the file and return an error if it's not a directory</span>
</span>
<span class="line" id="L1382">                    <span class="tok-comment">// this is important because otherwise a dangling symlink</span>
</span>
<span class="line" id="L1383">                    <span class="tok-comment">// could cause an infinite loop</span>
</span>
<span class="line" id="L1384">                    <span class="tok-kw">if</span> (end_index == sub_path.len) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1385">                },</span>
<span class="line" id="L1386">                <span class="tok-kw">error</span>.FileNotFound =&gt; {</span>
<span class="line" id="L1387">                    <span class="tok-comment">// march end_index backward until next path component</span>
</span>
<span class="line" id="L1388">                    <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1389">                        <span class="tok-kw">if</span> (end_index == <span class="tok-number">0</span>) <span class="tok-kw">return</span> err;</span>
<span class="line" id="L1390">                        end_index -= <span class="tok-number">1</span>;</span>
<span class="line" id="L1391">                        <span class="tok-kw">if</span> (path.isSep(sub_path[end_index])) <span class="tok-kw">break</span>;</span>
<span class="line" id="L1392">                    }</span>
<span class="line" id="L1393">                    <span class="tok-kw">continue</span>;</span>
<span class="line" id="L1394">                },</span>
<span class="line" id="L1395">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> err,</span>
<span class="line" id="L1396">            };</span>
<span class="line" id="L1397">            <span class="tok-kw">if</span> (end_index == sub_path.len) <span class="tok-kw">return</span>;</span>
<span class="line" id="L1398">            <span class="tok-comment">// march end_index forward until next path component</span>
</span>
<span class="line" id="L1399">            <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L1400">                end_index += <span class="tok-number">1</span>;</span>
<span class="line" id="L1401">                <span class="tok-kw">if</span> (end_index == sub_path.len <span class="tok-kw">or</span> path.isSep(sub_path[end_index])) <span class="tok-kw">break</span>;</span>
<span class="line" id="L1402">            }</span>
<span class="line" id="L1403">        }</span>
<span class="line" id="L1404">    }</span>
<span class="line" id="L1405"></span>
<span class="line" id="L1406">    <span class="tok-comment">/// This function performs `makePath`, followed by `openDir`.</span></span>
<span class="line" id="L1407">    <span class="tok-comment">/// If supported by the OS, this operation is atomic. It is not atomic on</span></span>
<span class="line" id="L1408">    <span class="tok-comment">/// all operating systems.</span></span>
<span class="line" id="L1409">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">makeOpenPath</span>(self: Dir, sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, open_dir_options: OpenDirOptions) !Dir {</span>
<span class="line" id="L1410">        <span class="tok-comment">// TODO improve this implementation on Windows; we can avoid 1 call to NtClose</span>
</span>
<span class="line" id="L1411">        <span class="tok-kw">try</span> self.makePath(sub_path);</span>
<span class="line" id="L1412">        <span class="tok-kw">return</span> self.openDir(sub_path, open_dir_options);</span>
<span class="line" id="L1413">    }</span>
<span class="line" id="L1414"></span>
<span class="line" id="L1415">    <span class="tok-comment">/// This function performs `makePath`, followed by `openIterableDir`.</span></span>
<span class="line" id="L1416">    <span class="tok-comment">/// If supported by the OS, this operation is atomic. It is not atomic on</span></span>
<span class="line" id="L1417">    <span class="tok-comment">/// all operating systems.</span></span>
<span class="line" id="L1418">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">makeOpenPathIterable</span>(self: Dir, sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, open_dir_options: OpenDirOptions) !IterableDir {</span>
<span class="line" id="L1419">        <span class="tok-comment">// TODO improve this implementation on Windows; we can avoid 1 call to NtClose</span>
</span>
<span class="line" id="L1420">        <span class="tok-kw">try</span> self.makePath(sub_path);</span>
<span class="line" id="L1421">        <span class="tok-kw">return</span> self.openIterableDir(sub_path, open_dir_options);</span>
<span class="line" id="L1422">    }</span>
<span class="line" id="L1423"></span>
<span class="line" id="L1424">    <span class="tok-comment">///  This function returns the canonicalized absolute pathname of</span></span>
<span class="line" id="L1425">    <span class="tok-comment">/// `pathname` relative to this `Dir`. If `pathname` is absolute, ignores this</span></span>
<span class="line" id="L1426">    <span class="tok-comment">/// `Dir` handle and returns the canonicalized absolute pathname of `pathname`</span></span>
<span class="line" id="L1427">    <span class="tok-comment">/// argument.</span></span>
<span class="line" id="L1428">    <span class="tok-comment">/// This function is not universally supported by all platforms.</span></span>
<span class="line" id="L1429">    <span class="tok-comment">/// Currently supported hosts are: Linux, macOS, and Windows.</span></span>
<span class="line" id="L1430">    <span class="tok-comment">/// See also `Dir.realpathZ`, `Dir.realpathW`, and `Dir.realpathAlloc`.</span></span>
<span class="line" id="L1431">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">realpath</span>(self: Dir, pathname: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, out_buffer: []<span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1432">        <span class="tok-kw">if</span> (builtin.os.tag == .wasi) {</span>
<span class="line" id="L1433">            <span class="tok-kw">if</span> (self.fd == os.wasi.AT.FDCWD <span class="tok-kw">or</span> path.isAbsolute(pathname)) {</span>
<span class="line" id="L1434">                <span class="tok-kw">var</span> buffer: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1435">                <span class="tok-kw">const</span> out_path = <span class="tok-kw">try</span> os.realpath(pathname, &amp;buffer);</span>
<span class="line" id="L1436">                <span class="tok-kw">if</span> (out_path.len &gt; out_buffer.len) {</span>
<span class="line" id="L1437">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L1438">                }</span>
<span class="line" id="L1439">                mem.copy(<span class="tok-type">u8</span>, out_buffer, out_path);</span>
<span class="line" id="L1440">                <span class="tok-kw">return</span> out_buffer[<span class="tok-number">0</span>..out_path.len];</span>
<span class="line" id="L1441">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1442">                <span class="tok-comment">// Unfortunately, we have no ability to look up the path for an fd_t</span>
</span>
<span class="line" id="L1443">                <span class="tok-comment">// on WASI, so we have to give up here.</span>
</span>
<span class="line" id="L1444">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidHandle;</span>
<span class="line" id="L1445">            }</span>
<span class="line" id="L1446">        }</span>
<span class="line" id="L1447">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1448">            <span class="tok-kw">const</span> pathname_w = <span class="tok-kw">try</span> os.windows.sliceToPrefixedFileW(pathname);</span>
<span class="line" id="L1449">            <span class="tok-kw">return</span> self.realpathW(pathname_w.span(), out_buffer);</span>
<span class="line" id="L1450">        }</span>
<span class="line" id="L1451">        <span class="tok-kw">const</span> pathname_c = <span class="tok-kw">try</span> os.toPosixPath(pathname);</span>
<span class="line" id="L1452">        <span class="tok-kw">return</span> self.realpathZ(&amp;pathname_c, out_buffer);</span>
<span class="line" id="L1453">    }</span>
<span class="line" id="L1454"></span>
<span class="line" id="L1455">    <span class="tok-comment">/// Same as `Dir.realpath` except `pathname` is null-terminated.</span></span>
<span class="line" id="L1456">    <span class="tok-comment">/// See also `Dir.realpath`, `realpathZ`.</span></span>
<span class="line" id="L1457">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">realpathZ</span>(self: Dir, pathname: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, out_buffer: []<span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1458">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1459">            <span class="tok-kw">const</span> pathname_w = <span class="tok-kw">try</span> os.windows.cStrToPrefixedFileW(pathname);</span>
<span class="line" id="L1460">            <span class="tok-kw">return</span> self.realpathW(pathname_w.span(), out_buffer);</span>
<span class="line" id="L1461">        }</span>
<span class="line" id="L1462"></span>
<span class="line" id="L1463">        <span class="tok-kw">const</span> flags = <span class="tok-kw">if</span> (builtin.os.tag == .linux) os.O.PATH | os.O.NONBLOCK | os.O.CLOEXEC <span class="tok-kw">else</span> os.O.NONBLOCK | os.O.CLOEXEC;</span>
<span class="line" id="L1464">        <span class="tok-kw">const</span> fd = os.openatZ(self.fd, pathname, flags, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1465">            <span class="tok-kw">error</span>.FileLocksNotSupported =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1466">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1467">        };</span>
<span class="line" id="L1468">        <span class="tok-kw">defer</span> os.close(fd);</span>
<span class="line" id="L1469"></span>
<span class="line" id="L1470">        <span class="tok-comment">// Use of MAX_PATH_BYTES here is valid as the realpath function does not</span>
</span>
<span class="line" id="L1471">        <span class="tok-comment">// have a variant that takes an arbitrary-size buffer.</span>
</span>
<span class="line" id="L1472">        <span class="tok-comment">// TODO(#4812): Consider reimplementing realpath or using the POSIX.1-2008</span>
</span>
<span class="line" id="L1473">        <span class="tok-comment">// NULL out parameter (GNU's canonicalize_file_name) to handle overelong</span>
</span>
<span class="line" id="L1474">        <span class="tok-comment">// paths. musl supports passing NULL but restricts the output to PATH_MAX</span>
</span>
<span class="line" id="L1475">        <span class="tok-comment">// anyway.</span>
</span>
<span class="line" id="L1476">        <span class="tok-kw">var</span> buffer: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1477">        <span class="tok-kw">const</span> out_path = <span class="tok-kw">try</span> os.getFdPath(fd, &amp;buffer);</span>
<span class="line" id="L1478"></span>
<span class="line" id="L1479">        <span class="tok-kw">if</span> (out_path.len &gt; out_buffer.len) {</span>
<span class="line" id="L1480">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L1481">        }</span>
<span class="line" id="L1482"></span>
<span class="line" id="L1483">        mem.copy(<span class="tok-type">u8</span>, out_buffer, out_path);</span>
<span class="line" id="L1484"></span>
<span class="line" id="L1485">        <span class="tok-kw">return</span> out_buffer[<span class="tok-number">0</span>..out_path.len];</span>
<span class="line" id="L1486">    }</span>
<span class="line" id="L1487"></span>
<span class="line" id="L1488">    <span class="tok-comment">/// Windows-only. Same as `Dir.realpath` except `pathname` is WTF16 encoded.</span></span>
<span class="line" id="L1489">    <span class="tok-comment">/// See also `Dir.realpath`, `realpathW`.</span></span>
<span class="line" id="L1490">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">realpathW</span>(self: Dir, pathname: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, out_buffer: []<span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1491">        <span class="tok-kw">const</span> w = os.windows;</span>
<span class="line" id="L1492"></span>
<span class="line" id="L1493">        <span class="tok-kw">const</span> access_mask = w.GENERIC_READ | w.SYNCHRONIZE;</span>
<span class="line" id="L1494">        <span class="tok-kw">const</span> share_access = w.FILE_SHARE_READ;</span>
<span class="line" id="L1495">        <span class="tok-kw">const</span> creation = w.FILE_OPEN;</span>
<span class="line" id="L1496">        <span class="tok-kw">const</span> h_file = blk: {</span>
<span class="line" id="L1497">            <span class="tok-kw">const</span> res = w.OpenFile(pathname, .{</span>
<span class="line" id="L1498">                .dir = self.fd,</span>
<span class="line" id="L1499">                .access_mask = access_mask,</span>
<span class="line" id="L1500">                .share_access = share_access,</span>
<span class="line" id="L1501">                .creation = creation,</span>
<span class="line" id="L1502">                .io_mode = .blocking,</span>
<span class="line" id="L1503">            }) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1504">                <span class="tok-kw">error</span>.IsDir =&gt; <span class="tok-kw">break</span> :blk w.OpenFile(pathname, .{</span>
<span class="line" id="L1505">                    .dir = self.fd,</span>
<span class="line" id="L1506">                    .access_mask = access_mask,</span>
<span class="line" id="L1507">                    .share_access = share_access,</span>
<span class="line" id="L1508">                    .creation = creation,</span>
<span class="line" id="L1509">                    .io_mode = .blocking,</span>
<span class="line" id="L1510">                    .filter = .dir_only,</span>
<span class="line" id="L1511">                }) <span class="tok-kw">catch</span> |er| <span class="tok-kw">switch</span> (er) {</span>
<span class="line" id="L1512">                    <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1513">                    <span class="tok-kw">else</span> =&gt; |e2| <span class="tok-kw">return</span> e2,</span>
<span class="line" id="L1514">                },</span>
<span class="line" id="L1515">                <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1516">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1517">            };</span>
<span class="line" id="L1518">            <span class="tok-kw">break</span> :blk res;</span>
<span class="line" id="L1519">        };</span>
<span class="line" id="L1520">        <span class="tok-kw">defer</span> w.CloseHandle(h_file);</span>
<span class="line" id="L1521"></span>
<span class="line" id="L1522">        <span class="tok-comment">// Use of MAX_PATH_BYTES here is valid as the realpath function does not</span>
</span>
<span class="line" id="L1523">        <span class="tok-comment">// have a variant that takes an arbitrary-size buffer.</span>
</span>
<span class="line" id="L1524">        <span class="tok-comment">// TODO(#4812): Consider reimplementing realpath or using the POSIX.1-2008</span>
</span>
<span class="line" id="L1525">        <span class="tok-comment">// NULL out parameter (GNU's canonicalize_file_name) to handle overelong</span>
</span>
<span class="line" id="L1526">        <span class="tok-comment">// paths. musl supports passing NULL but restricts the output to PATH_MAX</span>
</span>
<span class="line" id="L1527">        <span class="tok-comment">// anyway.</span>
</span>
<span class="line" id="L1528">        <span class="tok-kw">var</span> buffer: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1529">        <span class="tok-kw">const</span> out_path = <span class="tok-kw">try</span> os.getFdPath(h_file, &amp;buffer);</span>
<span class="line" id="L1530"></span>
<span class="line" id="L1531">        <span class="tok-kw">if</span> (out_path.len &gt; out_buffer.len) {</span>
<span class="line" id="L1532">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L1533">        }</span>
<span class="line" id="L1534"></span>
<span class="line" id="L1535">        mem.copy(<span class="tok-type">u8</span>, out_buffer, out_path);</span>
<span class="line" id="L1536"></span>
<span class="line" id="L1537">        <span class="tok-kw">return</span> out_buffer[<span class="tok-number">0</span>..out_path.len];</span>
<span class="line" id="L1538">    }</span>
<span class="line" id="L1539"></span>
<span class="line" id="L1540">    <span class="tok-comment">/// Same as `Dir.realpath` except caller must free the returned memory.</span></span>
<span class="line" id="L1541">    <span class="tok-comment">/// See also `Dir.realpath`.</span></span>
<span class="line" id="L1542">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">realpathAlloc</span>(self: Dir, allocator: Allocator, pathname: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1543">        <span class="tok-comment">// Use of MAX_PATH_BYTES here is valid as the realpath function does not</span>
</span>
<span class="line" id="L1544">        <span class="tok-comment">// have a variant that takes an arbitrary-size buffer.</span>
</span>
<span class="line" id="L1545">        <span class="tok-comment">// TODO(#4812): Consider reimplementing realpath or using the POSIX.1-2008</span>
</span>
<span class="line" id="L1546">        <span class="tok-comment">// NULL out parameter (GNU's canonicalize_file_name) to handle overelong</span>
</span>
<span class="line" id="L1547">        <span class="tok-comment">// paths. musl supports passing NULL but restricts the output to PATH_MAX</span>
</span>
<span class="line" id="L1548">        <span class="tok-comment">// anyway.</span>
</span>
<span class="line" id="L1549">        <span class="tok-kw">var</span> buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1550">        <span class="tok-kw">return</span> allocator.dupe(<span class="tok-type">u8</span>, <span class="tok-kw">try</span> self.realpath(pathname, buf[<span class="tok-number">0</span>..]));</span>
<span class="line" id="L1551">    }</span>
<span class="line" id="L1552"></span>
<span class="line" id="L1553">    <span class="tok-comment">/// Changes the current working directory to the open directory handle.</span></span>
<span class="line" id="L1554">    <span class="tok-comment">/// This modifies global state and can have surprising effects in multi-</span></span>
<span class="line" id="L1555">    <span class="tok-comment">/// threaded applications. Most applications and especially libraries should</span></span>
<span class="line" id="L1556">    <span class="tok-comment">/// not call this function as a general rule, however it can have use cases</span></span>
<span class="line" id="L1557">    <span class="tok-comment">/// in, for example, implementing a shell, or child process execution.</span></span>
<span class="line" id="L1558">    <span class="tok-comment">/// Not all targets support this. For example, WASI does not have the concept</span></span>
<span class="line" id="L1559">    <span class="tok-comment">/// of a current working directory.</span></span>
<span class="line" id="L1560">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setAsCwd</span>(self: Dir) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1561">        <span class="tok-kw">if</span> (builtin.os.tag == .wasi) {</span>
<span class="line" id="L1562">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;changing cwd is not currently possible in WASI&quot;</span>);</span>
<span class="line" id="L1563">        }</span>
<span class="line" id="L1564">        <span class="tok-kw">try</span> os.fchdir(self.fd);</span>
<span class="line" id="L1565">    }</span>
<span class="line" id="L1566"></span>
<span class="line" id="L1567">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> OpenDirOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L1568">        <span class="tok-comment">/// `true` means the opened directory can be used as the `Dir` parameter</span></span>
<span class="line" id="L1569">        <span class="tok-comment">/// for functions which operate based on an open directory handle. When `false`,</span></span>
<span class="line" id="L1570">        <span class="tok-comment">/// such operations are Illegal Behavior.</span></span>
<span class="line" id="L1571">        access_sub_paths: <span class="tok-type">bool</span> = <span class="tok-null">true</span>,</span>
<span class="line" id="L1572"></span>
<span class="line" id="L1573">        <span class="tok-comment">/// `true` means it won't dereference the symlinks.</span></span>
<span class="line" id="L1574">        no_follow: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L1575">    };</span>
<span class="line" id="L1576"></span>
<span class="line" id="L1577">    <span class="tok-comment">/// Opens a directory at the given path. The directory is a system resource that remains</span></span>
<span class="line" id="L1578">    <span class="tok-comment">/// open until `close` is called on the result.</span></span>
<span class="line" id="L1579">    <span class="tok-comment">///</span></span>
<span class="line" id="L1580">    <span class="tok-comment">/// Asserts that the path parameter has no null bytes.</span></span>
<span class="line" id="L1581">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openDir</span>(self: Dir, sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: OpenDirOptions) OpenError!Dir {</span>
<span class="line" id="L1582">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1583">            <span class="tok-kw">const</span> sub_path_w = <span class="tok-kw">try</span> os.windows.sliceToPrefixedFileW(sub_path);</span>
<span class="line" id="L1584">            <span class="tok-kw">return</span> self.openDirW(sub_path_w.span().ptr, args, <span class="tok-null">false</span>);</span>
<span class="line" id="L1585">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L1586">            <span class="tok-kw">return</span> self.openDirWasi(sub_path, args);</span>
<span class="line" id="L1587">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1588">            <span class="tok-kw">const</span> sub_path_c = <span class="tok-kw">try</span> os.toPosixPath(sub_path);</span>
<span class="line" id="L1589">            <span class="tok-kw">return</span> self.openDirZ(&amp;sub_path_c, args, <span class="tok-null">false</span>);</span>
<span class="line" id="L1590">        }</span>
<span class="line" id="L1591">    }</span>
<span class="line" id="L1592"></span>
<span class="line" id="L1593">    <span class="tok-comment">/// Opens an iterable directory at the given path. The directory is a system resource that remains</span></span>
<span class="line" id="L1594">    <span class="tok-comment">/// open until `close` is called on the result.</span></span>
<span class="line" id="L1595">    <span class="tok-comment">///</span></span>
<span class="line" id="L1596">    <span class="tok-comment">/// Asserts that the path parameter has no null bytes.</span></span>
<span class="line" id="L1597">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openIterableDir</span>(self: Dir, sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: OpenDirOptions) OpenError!IterableDir {</span>
<span class="line" id="L1598">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1599">            <span class="tok-kw">const</span> sub_path_w = <span class="tok-kw">try</span> os.windows.sliceToPrefixedFileW(sub_path);</span>
<span class="line" id="L1600">            <span class="tok-kw">return</span> IterableDir{ .dir = <span class="tok-kw">try</span> self.openDirW(sub_path_w.span().ptr, args, <span class="tok-null">true</span>) };</span>
<span class="line" id="L1601">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L1602">            <span class="tok-kw">return</span> IterableDir{ .dir = <span class="tok-kw">try</span> self.openDirWasi(sub_path, args) };</span>
<span class="line" id="L1603">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1604">            <span class="tok-kw">const</span> sub_path_c = <span class="tok-kw">try</span> os.toPosixPath(sub_path);</span>
<span class="line" id="L1605">            <span class="tok-kw">return</span> IterableDir{ .dir = <span class="tok-kw">try</span> self.openDirZ(&amp;sub_path_c, args, <span class="tok-null">true</span>) };</span>
<span class="line" id="L1606">        }</span>
<span class="line" id="L1607">    }</span>
<span class="line" id="L1608"></span>
<span class="line" id="L1609">    <span class="tok-comment">/// Same as `openDir` except only WASI.</span></span>
<span class="line" id="L1610">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openDirWasi</span>(self: Dir, sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: OpenDirOptions) OpenError!Dir {</span>
<span class="line" id="L1611">        <span class="tok-kw">const</span> w = os.wasi;</span>
<span class="line" id="L1612">        <span class="tok-kw">var</span> base: w.rights_t = w.RIGHT.FD_FILESTAT_GET | w.RIGHT.FD_FDSTAT_SET_FLAGS | w.RIGHT.FD_FILESTAT_SET_TIMES;</span>
<span class="line" id="L1613">        <span class="tok-kw">if</span> (args.access_sub_paths) {</span>
<span class="line" id="L1614">            base |= w.RIGHT.FD_READDIR |</span>
<span class="line" id="L1615">                w.RIGHT.PATH_CREATE_DIRECTORY |</span>
<span class="line" id="L1616">                w.RIGHT.PATH_CREATE_FILE |</span>
<span class="line" id="L1617">                w.RIGHT.PATH_LINK_SOURCE |</span>
<span class="line" id="L1618">                w.RIGHT.PATH_LINK_TARGET |</span>
<span class="line" id="L1619">                w.RIGHT.PATH_OPEN |</span>
<span class="line" id="L1620">                w.RIGHT.PATH_READLINK |</span>
<span class="line" id="L1621">                w.RIGHT.PATH_RENAME_SOURCE |</span>
<span class="line" id="L1622">                w.RIGHT.PATH_RENAME_TARGET |</span>
<span class="line" id="L1623">                w.RIGHT.PATH_FILESTAT_GET |</span>
<span class="line" id="L1624">                w.RIGHT.PATH_FILESTAT_SET_SIZE |</span>
<span class="line" id="L1625">                w.RIGHT.PATH_FILESTAT_SET_TIMES |</span>
<span class="line" id="L1626">                w.RIGHT.PATH_SYMLINK |</span>
<span class="line" id="L1627">                w.RIGHT.PATH_REMOVE_DIRECTORY |</span>
<span class="line" id="L1628">                w.RIGHT.PATH_UNLINK_FILE;</span>
<span class="line" id="L1629">        }</span>
<span class="line" id="L1630">        <span class="tok-kw">const</span> symlink_flags: w.lookupflags_t = <span class="tok-kw">if</span> (args.no_follow) <span class="tok-number">0x0</span> <span class="tok-kw">else</span> w.LOOKUP_SYMLINK_FOLLOW;</span>
<span class="line" id="L1631">        <span class="tok-comment">// TODO do we really need all the rights here?</span>
</span>
<span class="line" id="L1632">        <span class="tok-kw">const</span> inheriting: w.rights_t = w.RIGHT.ALL ^ w.RIGHT.SOCK_SHUTDOWN;</span>
<span class="line" id="L1633"></span>
<span class="line" id="L1634">        <span class="tok-kw">const</span> result = blk: {</span>
<span class="line" id="L1635">            <span class="tok-kw">if</span> (self.fd == os.wasi.AT.FDCWD <span class="tok-kw">or</span> path.isAbsolute(sub_path)) {</span>
<span class="line" id="L1636">                <span class="tok-comment">// Resolve absolute or CWD-relative paths to a path within a Preopen</span>
</span>
<span class="line" id="L1637">                <span class="tok-kw">var</span> resolved_path_buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1638">                <span class="tok-kw">const</span> resolved_path = <span class="tok-kw">try</span> os.resolvePathWasi(sub_path, &amp;resolved_path_buf);</span>
<span class="line" id="L1639">                <span class="tok-kw">break</span> :blk os.openatWasi(resolved_path.dir_fd, resolved_path.relative_path, symlink_flags, w.O.DIRECTORY, <span class="tok-number">0x0</span>, base, inheriting);</span>
<span class="line" id="L1640">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1641">                <span class="tok-kw">break</span> :blk os.openatWasi(self.fd, sub_path, symlink_flags, w.O.DIRECTORY, <span class="tok-number">0x0</span>, base, inheriting);</span>
<span class="line" id="L1642">            }</span>
<span class="line" id="L1643">        };</span>
<span class="line" id="L1644">        <span class="tok-kw">const</span> fd = result <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1645">            <span class="tok-kw">error</span>.FileTooBig =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// can't happen for directories</span>
</span>
<span class="line" id="L1646">            <span class="tok-kw">error</span>.IsDir =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// we're providing O.DIRECTORY</span>
</span>
<span class="line" id="L1647">            <span class="tok-kw">error</span>.NoSpaceLeft =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// not providing O.CREAT</span>
</span>
<span class="line" id="L1648">            <span class="tok-kw">error</span>.PathAlreadyExists =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// not providing O.CREAT</span>
</span>
<span class="line" id="L1649">            <span class="tok-kw">error</span>.FileLocksNotSupported =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// locking folders is not supported</span>
</span>
<span class="line" id="L1650">            <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// can't happen for directories</span>
</span>
<span class="line" id="L1651">            <span class="tok-kw">error</span>.FileBusy =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// can't happen for directories</span>
</span>
<span class="line" id="L1652">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1653">        };</span>
<span class="line" id="L1654">        <span class="tok-kw">return</span> Dir{ .fd = fd };</span>
<span class="line" id="L1655">    }</span>
<span class="line" id="L1656"></span>
<span class="line" id="L1657">    <span class="tok-comment">/// Same as `openDir` except the parameter is null-terminated.</span></span>
<span class="line" id="L1658">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openDirZ</span>(self: Dir, sub_path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, args: OpenDirOptions, iterable: <span class="tok-type">bool</span>) OpenError!Dir {</span>
<span class="line" id="L1659">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1660">            <span class="tok-kw">const</span> sub_path_w = <span class="tok-kw">try</span> os.windows.cStrToPrefixedFileW(sub_path_c);</span>
<span class="line" id="L1661">            <span class="tok-kw">return</span> self.openDirW(sub_path_w.span().ptr, args, iterable);</span>
<span class="line" id="L1662">        }</span>
<span class="line" id="L1663">        <span class="tok-kw">const</span> symlink_flags: <span class="tok-type">u32</span> = <span class="tok-kw">if</span> (args.no_follow) os.O.NOFOLLOW <span class="tok-kw">else</span> <span class="tok-number">0x0</span>;</span>
<span class="line" id="L1664">        <span class="tok-kw">if</span> (!iterable) {</span>
<span class="line" id="L1665">            <span class="tok-kw">const</span> O_PATH = <span class="tok-kw">if</span> (<span class="tok-builtin">@hasDecl</span>(os.O, <span class="tok-str">&quot;PATH&quot;</span>)) os.O.PATH <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L1666">            <span class="tok-kw">return</span> self.openDirFlagsZ(sub_path_c, os.O.DIRECTORY | os.O.RDONLY | os.O.CLOEXEC | O_PATH | symlink_flags);</span>
<span class="line" id="L1667">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1668">            <span class="tok-kw">return</span> self.openDirFlagsZ(sub_path_c, os.O.DIRECTORY | os.O.RDONLY | os.O.CLOEXEC | symlink_flags);</span>
<span class="line" id="L1669">        }</span>
<span class="line" id="L1670">    }</span>
<span class="line" id="L1671"></span>
<span class="line" id="L1672">    <span class="tok-comment">/// Same as `openDir` except the path parameter is WTF-16 encoded, NT-prefixed.</span></span>
<span class="line" id="L1673">    <span class="tok-comment">/// This function asserts the target OS is Windows.</span></span>
<span class="line" id="L1674">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openDirW</span>(self: Dir, sub_path_w: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, args: OpenDirOptions, iterable: <span class="tok-type">bool</span>) OpenError!Dir {</span>
<span class="line" id="L1675">        <span class="tok-kw">const</span> w = os.windows;</span>
<span class="line" id="L1676">        <span class="tok-comment">// TODO remove some of these flags if args.access_sub_paths is false</span>
</span>
<span class="line" id="L1677">        <span class="tok-kw">const</span> base_flags = w.STANDARD_RIGHTS_READ | w.FILE_READ_ATTRIBUTES | w.FILE_READ_EA |</span>
<span class="line" id="L1678">            w.SYNCHRONIZE | w.FILE_TRAVERSE;</span>
<span class="line" id="L1679">        <span class="tok-kw">const</span> flags: <span class="tok-type">u32</span> = <span class="tok-kw">if</span> (iterable) base_flags | w.FILE_LIST_DIRECTORY <span class="tok-kw">else</span> base_flags;</span>
<span class="line" id="L1680">        <span class="tok-kw">var</span> dir = <span class="tok-kw">try</span> self.openDirAccessMaskW(sub_path_w, flags, args.no_follow);</span>
<span class="line" id="L1681">        <span class="tok-kw">return</span> dir;</span>
<span class="line" id="L1682">    }</span>
<span class="line" id="L1683"></span>
<span class="line" id="L1684">    <span class="tok-comment">/// `flags` must contain `os.O.DIRECTORY`.</span></span>
<span class="line" id="L1685">    <span class="tok-kw">fn</span> <span class="tok-fn">openDirFlagsZ</span>(self: Dir, sub_path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: <span class="tok-type">u32</span>) OpenError!Dir {</span>
<span class="line" id="L1686">        <span class="tok-kw">const</span> result = <span class="tok-kw">if</span> (need_async_thread)</span>
<span class="line" id="L1687">            std.event.Loop.instance.?.openatZ(self.fd, sub_path_c, flags, <span class="tok-number">0</span>)</span>
<span class="line" id="L1688">        <span class="tok-kw">else</span></span>
<span class="line" id="L1689">            os.openatZ(self.fd, sub_path_c, flags, <span class="tok-number">0</span>);</span>
<span class="line" id="L1690">        <span class="tok-kw">const</span> fd = result <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1691">            <span class="tok-kw">error</span>.FileTooBig =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// can't happen for directories</span>
</span>
<span class="line" id="L1692">            <span class="tok-kw">error</span>.IsDir =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// we're providing O.DIRECTORY</span>
</span>
<span class="line" id="L1693">            <span class="tok-kw">error</span>.NoSpaceLeft =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// not providing O.CREAT</span>
</span>
<span class="line" id="L1694">            <span class="tok-kw">error</span>.PathAlreadyExists =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// not providing O.CREAT</span>
</span>
<span class="line" id="L1695">            <span class="tok-kw">error</span>.FileLocksNotSupported =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// locking folders is not supported</span>
</span>
<span class="line" id="L1696">            <span class="tok-kw">error</span>.WouldBlock =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// can't happen for directories</span>
</span>
<span class="line" id="L1697">            <span class="tok-kw">error</span>.FileBusy =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// can't happen for directories</span>
</span>
<span class="line" id="L1698">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1699">        };</span>
<span class="line" id="L1700">        <span class="tok-kw">return</span> Dir{ .fd = fd };</span>
<span class="line" id="L1701">    }</span>
<span class="line" id="L1702"></span>
<span class="line" id="L1703">    <span class="tok-kw">fn</span> <span class="tok-fn">openDirAccessMaskW</span>(self: Dir, sub_path_w: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, access_mask: <span class="tok-type">u32</span>, no_follow: <span class="tok-type">bool</span>) OpenError!Dir {</span>
<span class="line" id="L1704">        <span class="tok-kw">const</span> w = os.windows;</span>
<span class="line" id="L1705"></span>
<span class="line" id="L1706">        <span class="tok-kw">var</span> result = Dir{</span>
<span class="line" id="L1707">            .fd = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L1708">        };</span>
<span class="line" id="L1709"></span>
<span class="line" id="L1710">        <span class="tok-kw">const</span> path_len_bytes = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, mem.sliceTo(sub_path_w, <span class="tok-number">0</span>).len * <span class="tok-number">2</span>);</span>
<span class="line" id="L1711">        <span class="tok-kw">var</span> nt_name = w.UNICODE_STRING{</span>
<span class="line" id="L1712">            .Length = path_len_bytes,</span>
<span class="line" id="L1713">            .MaximumLength = path_len_bytes,</span>
<span class="line" id="L1714">            .Buffer = <span class="tok-builtin">@intToPtr</span>([*]<span class="tok-type">u16</span>, <span class="tok-builtin">@ptrToInt</span>(sub_path_w)),</span>
<span class="line" id="L1715">        };</span>
<span class="line" id="L1716">        <span class="tok-kw">var</span> attr = w.OBJECT_ATTRIBUTES{</span>
<span class="line" id="L1717">            .Length = <span class="tok-builtin">@sizeOf</span>(w.OBJECT_ATTRIBUTES),</span>
<span class="line" id="L1718">            .RootDirectory = <span class="tok-kw">if</span> (path.isAbsoluteWindowsW(sub_path_w)) <span class="tok-null">null</span> <span class="tok-kw">else</span> self.fd,</span>
<span class="line" id="L1719">            .Attributes = <span class="tok-number">0</span>, <span class="tok-comment">// Note we do not use OBJ_CASE_INSENSITIVE here.</span>
</span>
<span class="line" id="L1720">            .ObjectName = &amp;nt_name,</span>
<span class="line" id="L1721">            .SecurityDescriptor = <span class="tok-null">null</span>,</span>
<span class="line" id="L1722">            .SecurityQualityOfService = <span class="tok-null">null</span>,</span>
<span class="line" id="L1723">        };</span>
<span class="line" id="L1724">        <span class="tok-kw">const</span> open_reparse_point: w.DWORD = <span class="tok-kw">if</span> (no_follow) w.FILE_OPEN_REPARSE_POINT <span class="tok-kw">else</span> <span class="tok-number">0x0</span>;</span>
<span class="line" id="L1725">        <span class="tok-kw">var</span> io: w.IO_STATUS_BLOCK = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L1726">        <span class="tok-kw">const</span> rc = w.ntdll.NtCreateFile(</span>
<span class="line" id="L1727">            &amp;result.fd,</span>
<span class="line" id="L1728">            access_mask,</span>
<span class="line" id="L1729">            &amp;attr,</span>
<span class="line" id="L1730">            &amp;io,</span>
<span class="line" id="L1731">            <span class="tok-null">null</span>,</span>
<span class="line" id="L1732">            <span class="tok-number">0</span>,</span>
<span class="line" id="L1733">            w.FILE_SHARE_READ | w.FILE_SHARE_WRITE,</span>
<span class="line" id="L1734">            w.FILE_OPEN,</span>
<span class="line" id="L1735">            w.FILE_DIRECTORY_FILE | w.FILE_SYNCHRONOUS_IO_NONALERT | w.FILE_OPEN_FOR_BACKUP_INTENT | open_reparse_point,</span>
<span class="line" id="L1736">            <span class="tok-null">null</span>,</span>
<span class="line" id="L1737">            <span class="tok-number">0</span>,</span>
<span class="line" id="L1738">        );</span>
<span class="line" id="L1739">        <span class="tok-kw">switch</span> (rc) {</span>
<span class="line" id="L1740">            .SUCCESS =&gt; <span class="tok-kw">return</span> result,</span>
<span class="line" id="L1741">            .OBJECT_NAME_INVALID =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1742">            .OBJECT_NAME_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L1743">            .OBJECT_PATH_NOT_FOUND =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound,</span>
<span class="line" id="L1744">            .NOT_A_DIRECTORY =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L1745">            .INVALID_PARAMETER =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L1746">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> w.unexpectedStatus(rc),</span>
<span class="line" id="L1747">        }</span>
<span class="line" id="L1748">    }</span>
<span class="line" id="L1749"></span>
<span class="line" id="L1750">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DeleteFileError = os.UnlinkError;</span>
<span class="line" id="L1751"></span>
<span class="line" id="L1752">    <span class="tok-comment">/// Delete a file name and possibly the file it refers to, based on an open directory handle.</span></span>
<span class="line" id="L1753">    <span class="tok-comment">/// Asserts that the path parameter has no null bytes.</span></span>
<span class="line" id="L1754">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deleteFile</span>(self: Dir, sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) DeleteFileError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1755">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1756">            <span class="tok-kw">const</span> sub_path_w = <span class="tok-kw">try</span> os.windows.sliceToPrefixedFileW(sub_path);</span>
<span class="line" id="L1757">            <span class="tok-kw">return</span> self.deleteFileW(sub_path_w.span());</span>
<span class="line" id="L1758">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L1759">            os.unlinkat(self.fd, sub_path, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1760">                <span class="tok-kw">error</span>.DirNotEmpty =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// not passing AT.REMOVEDIR</span>
</span>
<span class="line" id="L1761">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1762">            };</span>
<span class="line" id="L1763">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1764">            <span class="tok-kw">const</span> sub_path_c = <span class="tok-kw">try</span> os.toPosixPath(sub_path);</span>
<span class="line" id="L1765">            <span class="tok-kw">return</span> self.deleteFileZ(&amp;sub_path_c);</span>
<span class="line" id="L1766">        }</span>
<span class="line" id="L1767">    }</span>
<span class="line" id="L1768"></span>
<span class="line" id="L1769">    <span class="tok-comment">/// Same as `deleteFile` except the parameter is null-terminated.</span></span>
<span class="line" id="L1770">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deleteFileZ</span>(self: Dir, sub_path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) DeleteFileError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1771">        os.unlinkatZ(self.fd, sub_path_c, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1772">            <span class="tok-kw">error</span>.DirNotEmpty =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// not passing AT.REMOVEDIR</span>
</span>
<span class="line" id="L1773">            <span class="tok-kw">error</span>.AccessDenied =&gt; |e| <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L1774">                <span class="tok-comment">// non-Linux POSIX systems return EPERM when trying to delete a directory, so</span>
</span>
<span class="line" id="L1775">                <span class="tok-comment">// we need to handle that case specifically and translate the error</span>
</span>
<span class="line" id="L1776">                .macos, .ios, .freebsd, .netbsd, .dragonfly, .openbsd, .solaris =&gt; {</span>
<span class="line" id="L1777">                    <span class="tok-comment">// Don't follow symlinks to match unlinkat (which acts on symlinks rather than follows them)</span>
</span>
<span class="line" id="L1778">                    <span class="tok-kw">const</span> fstat = os.fstatatZ(self.fd, sub_path_c, os.AT.SYMLINK_NOFOLLOW) <span class="tok-kw">catch</span> <span class="tok-kw">return</span> e;</span>
<span class="line" id="L1779">                    <span class="tok-kw">const</span> is_dir = fstat.mode &amp; os.S.IFMT == os.S.IFDIR;</span>
<span class="line" id="L1780">                    <span class="tok-kw">return</span> <span class="tok-kw">if</span> (is_dir) <span class="tok-kw">error</span>.IsDir <span class="tok-kw">else</span> e;</span>
<span class="line" id="L1781">                },</span>
<span class="line" id="L1782">                <span class="tok-kw">else</span> =&gt; <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1783">            },</span>
<span class="line" id="L1784">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1785">        };</span>
<span class="line" id="L1786">    }</span>
<span class="line" id="L1787"></span>
<span class="line" id="L1788">    <span class="tok-comment">/// Same as `deleteFile` except the parameter is WTF-16 encoded.</span></span>
<span class="line" id="L1789">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deleteFileW</span>(self: Dir, sub_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>) DeleteFileError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1790">        os.unlinkatW(self.fd, sub_path_w, <span class="tok-number">0</span>) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1791">            <span class="tok-kw">error</span>.DirNotEmpty =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// not passing AT.REMOVEDIR</span>
</span>
<span class="line" id="L1792">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1793">        };</span>
<span class="line" id="L1794">    }</span>
<span class="line" id="L1795"></span>
<span class="line" id="L1796">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DeleteDirError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L1797">        DirNotEmpty,</span>
<span class="line" id="L1798">        FileNotFound,</span>
<span class="line" id="L1799">        AccessDenied,</span>
<span class="line" id="L1800">        FileBusy,</span>
<span class="line" id="L1801">        FileSystem,</span>
<span class="line" id="L1802">        SymLinkLoop,</span>
<span class="line" id="L1803">        NameTooLong,</span>
<span class="line" id="L1804">        NotDir,</span>
<span class="line" id="L1805">        SystemResources,</span>
<span class="line" id="L1806">        ReadOnlyFileSystem,</span>
<span class="line" id="L1807">        InvalidUtf8,</span>
<span class="line" id="L1808">        BadPathName,</span>
<span class="line" id="L1809">        Unexpected,</span>
<span class="line" id="L1810">    };</span>
<span class="line" id="L1811"></span>
<span class="line" id="L1812">    <span class="tok-comment">/// Returns `error.DirNotEmpty` if the directory is not empty.</span></span>
<span class="line" id="L1813">    <span class="tok-comment">/// To delete a directory recursively, see `deleteTree`.</span></span>
<span class="line" id="L1814">    <span class="tok-comment">/// Asserts that the path parameter has no null bytes.</span></span>
<span class="line" id="L1815">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deleteDir</span>(self: Dir, sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) DeleteDirError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1816">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1817">            <span class="tok-kw">const</span> sub_path_w = <span class="tok-kw">try</span> os.windows.sliceToPrefixedFileW(sub_path);</span>
<span class="line" id="L1818">            <span class="tok-kw">return</span> self.deleteDirW(sub_path_w.span());</span>
<span class="line" id="L1819">        } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L1820">            os.unlinkat(self.fd, sub_path, os.AT.REMOVEDIR) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1821">                <span class="tok-kw">error</span>.IsDir =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// not possible since we pass AT.REMOVEDIR</span>
</span>
<span class="line" id="L1822">                <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1823">            };</span>
<span class="line" id="L1824">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L1825">            <span class="tok-kw">const</span> sub_path_c = <span class="tok-kw">try</span> os.toPosixPath(sub_path);</span>
<span class="line" id="L1826">            <span class="tok-kw">return</span> self.deleteDirZ(&amp;sub_path_c);</span>
<span class="line" id="L1827">        }</span>
<span class="line" id="L1828">    }</span>
<span class="line" id="L1829"></span>
<span class="line" id="L1830">    <span class="tok-comment">/// Same as `deleteDir` except the parameter is null-terminated.</span></span>
<span class="line" id="L1831">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deleteDirZ</span>(self: Dir, sub_path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) DeleteDirError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1832">        os.unlinkatZ(self.fd, sub_path_c, os.AT.REMOVEDIR) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1833">            <span class="tok-kw">error</span>.IsDir =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// not possible since we pass AT.REMOVEDIR</span>
</span>
<span class="line" id="L1834">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1835">        };</span>
<span class="line" id="L1836">    }</span>
<span class="line" id="L1837"></span>
<span class="line" id="L1838">    <span class="tok-comment">/// Same as `deleteDir` except the parameter is UTF16LE, NT prefixed.</span></span>
<span class="line" id="L1839">    <span class="tok-comment">/// This function is Windows-only.</span></span>
<span class="line" id="L1840">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deleteDirW</span>(self: Dir, sub_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>) DeleteDirError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1841">        os.unlinkatW(self.fd, sub_path_w, os.AT.REMOVEDIR) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L1842">            <span class="tok-kw">error</span>.IsDir =&gt; <span class="tok-kw">unreachable</span>, <span class="tok-comment">// not possible since we pass AT.REMOVEDIR</span>
</span>
<span class="line" id="L1843">            <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L1844">        };</span>
<span class="line" id="L1845">    }</span>
<span class="line" id="L1846"></span>
<span class="line" id="L1847">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RenameError = os.RenameError;</span>
<span class="line" id="L1848"></span>
<span class="line" id="L1849">    <span class="tok-comment">/// Change the name or location of a file or directory.</span></span>
<span class="line" id="L1850">    <span class="tok-comment">/// If new_sub_path already exists, it will be replaced.</span></span>
<span class="line" id="L1851">    <span class="tok-comment">/// Renaming a file over an existing directory or a directory</span></span>
<span class="line" id="L1852">    <span class="tok-comment">/// over an existing file will fail with `error.IsDir` or `error.NotDir`</span></span>
<span class="line" id="L1853">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">rename</span>(self: Dir, old_sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, new_sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) RenameError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1854">        <span class="tok-kw">return</span> os.renameat(self.fd, old_sub_path, self.fd, new_sub_path);</span>
<span class="line" id="L1855">    }</span>
<span class="line" id="L1856"></span>
<span class="line" id="L1857">    <span class="tok-comment">/// Same as `rename` except the parameters are null-terminated.</span></span>
<span class="line" id="L1858">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">renameZ</span>(self: Dir, old_sub_path_z: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, new_sub_path_z: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) RenameError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1859">        <span class="tok-kw">return</span> os.renameatZ(self.fd, old_sub_path_z, self.fd, new_sub_path_z);</span>
<span class="line" id="L1860">    }</span>
<span class="line" id="L1861"></span>
<span class="line" id="L1862">    <span class="tok-comment">/// Same as `rename` except the parameters are UTF16LE, NT prefixed.</span></span>
<span class="line" id="L1863">    <span class="tok-comment">/// This function is Windows-only.</span></span>
<span class="line" id="L1864">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">renameW</span>(self: Dir, old_sub_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, new_sub_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>) RenameError!<span class="tok-type">void</span> {</span>
<span class="line" id="L1865">        <span class="tok-kw">return</span> os.renameatW(self.fd, old_sub_path_w, self.fd, new_sub_path_w);</span>
<span class="line" id="L1866">    }</span>
<span class="line" id="L1867"></span>
<span class="line" id="L1868">    <span class="tok-comment">/// Creates a symbolic link named `sym_link_path` which contains the string `target_path`.</span></span>
<span class="line" id="L1869">    <span class="tok-comment">/// A symbolic link (also known as a soft link) may point to an existing file or to a nonexistent</span></span>
<span class="line" id="L1870">    <span class="tok-comment">/// one; the latter case is known as a dangling link.</span></span>
<span class="line" id="L1871">    <span class="tok-comment">/// If `sym_link_path` exists, it will not be overwritten.</span></span>
<span class="line" id="L1872">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">symLink</span>(</span>
<span class="line" id="L1873">        self: Dir,</span>
<span class="line" id="L1874">        target_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1875">        sym_link_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1876">        flags: SymLinkFlags,</span>
<span class="line" id="L1877">    ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1878">        <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L1879">            <span class="tok-kw">return</span> self.symLinkWasi(target_path, sym_link_path, flags);</span>
<span class="line" id="L1880">        }</span>
<span class="line" id="L1881">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1882">            <span class="tok-kw">const</span> target_path_w = <span class="tok-kw">try</span> os.windows.sliceToPrefixedFileW(target_path);</span>
<span class="line" id="L1883">            <span class="tok-kw">const</span> sym_link_path_w = <span class="tok-kw">try</span> os.windows.sliceToPrefixedFileW(sym_link_path);</span>
<span class="line" id="L1884">            <span class="tok-kw">return</span> self.symLinkW(target_path_w.span(), sym_link_path_w.span(), flags);</span>
<span class="line" id="L1885">        }</span>
<span class="line" id="L1886">        <span class="tok-kw">const</span> target_path_c = <span class="tok-kw">try</span> os.toPosixPath(target_path);</span>
<span class="line" id="L1887">        <span class="tok-kw">const</span> sym_link_path_c = <span class="tok-kw">try</span> os.toPosixPath(sym_link_path);</span>
<span class="line" id="L1888">        <span class="tok-kw">return</span> self.symLinkZ(&amp;target_path_c, &amp;sym_link_path_c, flags);</span>
<span class="line" id="L1889">    }</span>
<span class="line" id="L1890"></span>
<span class="line" id="L1891">    <span class="tok-comment">/// WASI-only. Same as `symLink` except targeting WASI.</span></span>
<span class="line" id="L1892">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">symLinkWasi</span>(</span>
<span class="line" id="L1893">        self: Dir,</span>
<span class="line" id="L1894">        target_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1895">        sym_link_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1896">        _: SymLinkFlags,</span>
<span class="line" id="L1897">    ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1898">        <span class="tok-kw">return</span> os.symlinkat(target_path, self.fd, sym_link_path);</span>
<span class="line" id="L1899">    }</span>
<span class="line" id="L1900"></span>
<span class="line" id="L1901">    <span class="tok-comment">/// Same as `symLink`, except the pathname parameters are null-terminated.</span></span>
<span class="line" id="L1902">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">symLinkZ</span>(</span>
<span class="line" id="L1903">        self: Dir,</span>
<span class="line" id="L1904">        target_path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1905">        sym_link_path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1906">        flags: SymLinkFlags,</span>
<span class="line" id="L1907">    ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1908">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1909">            <span class="tok-kw">const</span> target_path_w = <span class="tok-kw">try</span> os.windows.cStrToPrefixedFileW(target_path_c);</span>
<span class="line" id="L1910">            <span class="tok-kw">const</span> sym_link_path_w = <span class="tok-kw">try</span> os.windows.cStrToPrefixedFileW(sym_link_path_c);</span>
<span class="line" id="L1911">            <span class="tok-kw">return</span> self.symLinkW(target_path_w.span(), sym_link_path_w.span(), flags);</span>
<span class="line" id="L1912">        }</span>
<span class="line" id="L1913">        <span class="tok-kw">return</span> os.symlinkatZ(target_path_c, self.fd, sym_link_path_c);</span>
<span class="line" id="L1914">    }</span>
<span class="line" id="L1915"></span>
<span class="line" id="L1916">    <span class="tok-comment">/// Windows-only. Same as `symLink` except the pathname parameters</span></span>
<span class="line" id="L1917">    <span class="tok-comment">/// are null-terminated, WTF16 encoded.</span></span>
<span class="line" id="L1918">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">symLinkW</span>(</span>
<span class="line" id="L1919">        self: Dir,</span>
<span class="line" id="L1920">        target_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>,</span>
<span class="line" id="L1921">        sym_link_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>,</span>
<span class="line" id="L1922">        flags: SymLinkFlags,</span>
<span class="line" id="L1923">    ) !<span class="tok-type">void</span> {</span>
<span class="line" id="L1924">        <span class="tok-kw">return</span> os.windows.CreateSymbolicLink(self.fd, sym_link_path_w, target_path_w, flags.is_directory);</span>
<span class="line" id="L1925">    }</span>
<span class="line" id="L1926"></span>
<span class="line" id="L1927">    <span class="tok-comment">/// Read value of a symbolic link.</span></span>
<span class="line" id="L1928">    <span class="tok-comment">/// The return value is a slice of `buffer`, from index `0`.</span></span>
<span class="line" id="L1929">    <span class="tok-comment">/// Asserts that the path parameter has no null bytes.</span></span>
<span class="line" id="L1930">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readLink</span>(self: Dir, sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, buffer: []<span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1931">        <span class="tok-kw">if</span> (builtin.os.tag == .wasi <span class="tok-kw">and</span> !builtin.link_libc) {</span>
<span class="line" id="L1932">            <span class="tok-kw">return</span> self.readLinkWasi(sub_path, buffer);</span>
<span class="line" id="L1933">        }</span>
<span class="line" id="L1934">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1935">            <span class="tok-kw">const</span> sub_path_w = <span class="tok-kw">try</span> os.windows.sliceToPrefixedFileW(sub_path);</span>
<span class="line" id="L1936">            <span class="tok-kw">return</span> self.readLinkW(sub_path_w.span(), buffer);</span>
<span class="line" id="L1937">        }</span>
<span class="line" id="L1938">        <span class="tok-kw">const</span> sub_path_c = <span class="tok-kw">try</span> os.toPosixPath(sub_path);</span>
<span class="line" id="L1939">        <span class="tok-kw">return</span> self.readLinkZ(&amp;sub_path_c, buffer);</span>
<span class="line" id="L1940">    }</span>
<span class="line" id="L1941"></span>
<span class="line" id="L1942">    <span class="tok-comment">/// WASI-only. Same as `readLink` except targeting WASI.</span></span>
<span class="line" id="L1943">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readLinkWasi</span>(self: Dir, sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, buffer: []<span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1944">        <span class="tok-kw">return</span> os.readlinkat(self.fd, sub_path, buffer);</span>
<span class="line" id="L1945">    }</span>
<span class="line" id="L1946"></span>
<span class="line" id="L1947">    <span class="tok-comment">/// Same as `readLink`, except the `pathname` parameter is null-terminated.</span></span>
<span class="line" id="L1948">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readLinkZ</span>(self: Dir, sub_path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, buffer: []<span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1949">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L1950">            <span class="tok-kw">const</span> sub_path_w = <span class="tok-kw">try</span> os.windows.cStrToPrefixedFileW(sub_path_c);</span>
<span class="line" id="L1951">            <span class="tok-kw">return</span> self.readLinkW(sub_path_w.span(), buffer);</span>
<span class="line" id="L1952">        }</span>
<span class="line" id="L1953">        <span class="tok-kw">return</span> os.readlinkatZ(self.fd, sub_path_c, buffer);</span>
<span class="line" id="L1954">    }</span>
<span class="line" id="L1955"></span>
<span class="line" id="L1956">    <span class="tok-comment">/// Windows-only. Same as `readLink` except the pathname parameter</span></span>
<span class="line" id="L1957">    <span class="tok-comment">/// is null-terminated, WTF16 encoded.</span></span>
<span class="line" id="L1958">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readLinkW</span>(self: Dir, sub_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, buffer: []<span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1959">        <span class="tok-kw">return</span> os.windows.ReadLink(self.fd, sub_path_w, buffer);</span>
<span class="line" id="L1960">    }</span>
<span class="line" id="L1961"></span>
<span class="line" id="L1962">    <span class="tok-comment">/// Read all of file contents using a preallocated buffer.</span></span>
<span class="line" id="L1963">    <span class="tok-comment">/// The returned slice has the same pointer as `buffer`. If the length matches `buffer.len`</span></span>
<span class="line" id="L1964">    <span class="tok-comment">/// the situation is ambiguous. It could either mean that the entire file was read, and</span></span>
<span class="line" id="L1965">    <span class="tok-comment">/// it exactly fits the buffer, or it could mean the buffer was not big enough for the</span></span>
<span class="line" id="L1966">    <span class="tok-comment">/// entire file.</span></span>
<span class="line" id="L1967">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readFile</span>(self: Dir, file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, buffer: []<span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1968">        <span class="tok-kw">var</span> file = <span class="tok-kw">try</span> self.openFile(file_path, .{});</span>
<span class="line" id="L1969">        <span class="tok-kw">defer</span> file.close();</span>
<span class="line" id="L1970"></span>
<span class="line" id="L1971">        <span class="tok-kw">const</span> end_index = <span class="tok-kw">try</span> file.readAll(buffer);</span>
<span class="line" id="L1972">        <span class="tok-kw">return</span> buffer[<span class="tok-number">0</span>..end_index];</span>
<span class="line" id="L1973">    }</span>
<span class="line" id="L1974"></span>
<span class="line" id="L1975">    <span class="tok-comment">/// On success, caller owns returned buffer.</span></span>
<span class="line" id="L1976">    <span class="tok-comment">/// If the file is larger than `max_bytes`, returns `error.FileTooBig`.</span></span>
<span class="line" id="L1977">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readFileAlloc</span>(self: Dir, allocator: mem.Allocator, file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, max_bytes: <span class="tok-type">usize</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L1978">        <span class="tok-kw">return</span> self.readFileAllocOptions(allocator, file_path, max_bytes, <span class="tok-null">null</span>, <span class="tok-builtin">@alignOf</span>(<span class="tok-type">u8</span>), <span class="tok-null">null</span>);</span>
<span class="line" id="L1979">    }</span>
<span class="line" id="L1980"></span>
<span class="line" id="L1981">    <span class="tok-comment">/// On success, caller owns returned buffer.</span></span>
<span class="line" id="L1982">    <span class="tok-comment">/// If the file is larger than `max_bytes`, returns `error.FileTooBig`.</span></span>
<span class="line" id="L1983">    <span class="tok-comment">/// If `size_hint` is specified the initial buffer size is calculated using</span></span>
<span class="line" id="L1984">    <span class="tok-comment">/// that value, otherwise the effective file size is used instead.</span></span>
<span class="line" id="L1985">    <span class="tok-comment">/// Allows specifying alignment and a sentinel value.</span></span>
<span class="line" id="L1986">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readFileAllocOptions</span>(</span>
<span class="line" id="L1987">        self: Dir,</span>
<span class="line" id="L1988">        allocator: mem.Allocator,</span>
<span class="line" id="L1989">        file_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L1990">        max_bytes: <span class="tok-type">usize</span>,</span>
<span class="line" id="L1991">        size_hint: ?<span class="tok-type">usize</span>,</span>
<span class="line" id="L1992">        <span class="tok-kw">comptime</span> alignment: <span class="tok-type">u29</span>,</span>
<span class="line" id="L1993">        <span class="tok-kw">comptime</span> optional_sentinel: ?<span class="tok-type">u8</span>,</span>
<span class="line" id="L1994">    ) !(<span class="tok-kw">if</span> (optional_sentinel) |s| [:s]<span class="tok-kw">align</span>(alignment) <span class="tok-type">u8</span> <span class="tok-kw">else</span> []<span class="tok-kw">align</span>(alignment) <span class="tok-type">u8</span>) {</span>
<span class="line" id="L1995">        <span class="tok-kw">var</span> file = <span class="tok-kw">try</span> self.openFile(file_path, .{});</span>
<span class="line" id="L1996">        <span class="tok-kw">defer</span> file.close();</span>
<span class="line" id="L1997"></span>
<span class="line" id="L1998">        <span class="tok-comment">// If the file size doesn't fit a usize it'll be certainly greater than</span>
</span>
<span class="line" id="L1999">        <span class="tok-comment">// `max_bytes`</span>
</span>
<span class="line" id="L2000">        <span class="tok-kw">const</span> stat_size = size_hint <span class="tok-kw">orelse</span> math.cast(<span class="tok-type">usize</span>, <span class="tok-kw">try</span> file.getEndPos()) <span class="tok-kw">orelse</span></span>
<span class="line" id="L2001">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooBig;</span>
<span class="line" id="L2002"></span>
<span class="line" id="L2003">        <span class="tok-kw">return</span> file.readToEndAllocOptions(allocator, max_bytes, stat_size, alignment, optional_sentinel);</span>
<span class="line" id="L2004">    }</span>
<span class="line" id="L2005"></span>
<span class="line" id="L2006">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DeleteTreeError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L2007">        InvalidHandle,</span>
<span class="line" id="L2008">        AccessDenied,</span>
<span class="line" id="L2009">        FileTooBig,</span>
<span class="line" id="L2010">        SymLinkLoop,</span>
<span class="line" id="L2011">        ProcessFdQuotaExceeded,</span>
<span class="line" id="L2012">        NameTooLong,</span>
<span class="line" id="L2013">        SystemFdQuotaExceeded,</span>
<span class="line" id="L2014">        NoDevice,</span>
<span class="line" id="L2015">        SystemResources,</span>
<span class="line" id="L2016">        ReadOnlyFileSystem,</span>
<span class="line" id="L2017">        FileSystem,</span>
<span class="line" id="L2018">        FileBusy,</span>
<span class="line" id="L2019">        DeviceBusy,</span>
<span class="line" id="L2020"></span>
<span class="line" id="L2021">        <span class="tok-comment">/// One of the path components was not a directory.</span></span>
<span class="line" id="L2022">        <span class="tok-comment">/// This error is unreachable if `sub_path` does not contain a path separator.</span></span>
<span class="line" id="L2023">        NotDir,</span>
<span class="line" id="L2024"></span>
<span class="line" id="L2025">        <span class="tok-comment">/// On Windows, file paths must be valid Unicode.</span></span>
<span class="line" id="L2026">        InvalidUtf8,</span>
<span class="line" id="L2027"></span>
<span class="line" id="L2028">        <span class="tok-comment">/// On Windows, file paths cannot contain these characters:</span></span>
<span class="line" id="L2029">        <span class="tok-comment">/// '/', '*', '?', '&quot;', '&lt;', '&gt;', '|'</span></span>
<span class="line" id="L2030">        BadPathName,</span>
<span class="line" id="L2031">    } || os.UnexpectedError;</span>
<span class="line" id="L2032"></span>
<span class="line" id="L2033">    <span class="tok-comment">/// Whether `full_path` describes a symlink, file, or directory, this function</span></span>
<span class="line" id="L2034">    <span class="tok-comment">/// removes it. If it cannot be removed because it is a non-empty directory,</span></span>
<span class="line" id="L2035">    <span class="tok-comment">/// this function recursively removes its entries and then tries again.</span></span>
<span class="line" id="L2036">    <span class="tok-comment">/// This operation is not atomic on most file systems.</span></span>
<span class="line" id="L2037">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deleteTree</span>(self: Dir, sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) DeleteTreeError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2038">        start_over: <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L2039">            <span class="tok-kw">var</span> got_access_denied = <span class="tok-null">false</span>;</span>
<span class="line" id="L2040"></span>
<span class="line" id="L2041">            <span class="tok-comment">// First, try deleting the item as a file. This way we don't follow sym links.</span>
</span>
<span class="line" id="L2042">            <span class="tok-kw">if</span> (self.deleteFile(sub_path)) {</span>
<span class="line" id="L2043">                <span class="tok-kw">return</span>;</span>
<span class="line" id="L2044">            } <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2045">                <span class="tok-kw">error</span>.FileNotFound =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2046">                <span class="tok-kw">error</span>.IsDir =&gt; {},</span>
<span class="line" id="L2047">                <span class="tok-kw">error</span>.AccessDenied =&gt; got_access_denied = <span class="tok-null">true</span>,</span>
<span class="line" id="L2048"></span>
<span class="line" id="L2049">                <span class="tok-kw">error</span>.InvalidUtf8,</span>
<span class="line" id="L2050">                <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2051">                <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2052">                <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2053">                <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L2054">                <span class="tok-kw">error</span>.NotDir,</span>
<span class="line" id="L2055">                <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L2056">                <span class="tok-kw">error</span>.FileBusy,</span>
<span class="line" id="L2057">                <span class="tok-kw">error</span>.BadPathName,</span>
<span class="line" id="L2058">                <span class="tok-kw">error</span>.Unexpected,</span>
<span class="line" id="L2059">                =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L2060">            }</span>
<span class="line" id="L2061">            <span class="tok-kw">var</span> iterable_dir = self.openIterableDir(sub_path, .{ .no_follow = <span class="tok-null">true</span> }) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2062">                <span class="tok-kw">error</span>.NotDir =&gt; {</span>
<span class="line" id="L2063">                    <span class="tok-kw">if</span> (got_access_denied) {</span>
<span class="line" id="L2064">                        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied;</span>
<span class="line" id="L2065">                    }</span>
<span class="line" id="L2066">                    <span class="tok-kw">continue</span> :start_over;</span>
<span class="line" id="L2067">                },</span>
<span class="line" id="L2068">                <span class="tok-kw">error</span>.FileNotFound =&gt; {</span>
<span class="line" id="L2069">                    <span class="tok-comment">// That's fine, we were trying to remove this directory anyway.</span>
</span>
<span class="line" id="L2070">                    <span class="tok-kw">continue</span> :start_over;</span>
<span class="line" id="L2071">                },</span>
<span class="line" id="L2072"></span>
<span class="line" id="L2073">                <span class="tok-kw">error</span>.InvalidHandle,</span>
<span class="line" id="L2074">                <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2075">                <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2076">                <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L2077">                <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2078">                <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L2079">                <span class="tok-kw">error</span>.NoDevice,</span>
<span class="line" id="L2080">                <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2081">                <span class="tok-kw">error</span>.Unexpected,</span>
<span class="line" id="L2082">                <span class="tok-kw">error</span>.InvalidUtf8,</span>
<span class="line" id="L2083">                <span class="tok-kw">error</span>.BadPathName,</span>
<span class="line" id="L2084">                <span class="tok-kw">error</span>.DeviceBusy,</span>
<span class="line" id="L2085">                =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L2086">            };</span>
<span class="line" id="L2087">            <span class="tok-kw">var</span> cleanup_dir_parent: ?IterableDir = <span class="tok-null">null</span>;</span>
<span class="line" id="L2088">            <span class="tok-kw">defer</span> <span class="tok-kw">if</span> (cleanup_dir_parent) |*d| d.close();</span>
<span class="line" id="L2089"></span>
<span class="line" id="L2090">            <span class="tok-kw">var</span> cleanup_dir = <span class="tok-null">true</span>;</span>
<span class="line" id="L2091">            <span class="tok-kw">defer</span> <span class="tok-kw">if</span> (cleanup_dir) iterable_dir.close();</span>
<span class="line" id="L2092"></span>
<span class="line" id="L2093">            <span class="tok-comment">// Valid use of MAX_PATH_BYTES because dir_name_buf will only</span>
</span>
<span class="line" id="L2094">            <span class="tok-comment">// ever store a single path component that was returned from the</span>
</span>
<span class="line" id="L2095">            <span class="tok-comment">// filesystem.</span>
</span>
<span class="line" id="L2096">            <span class="tok-kw">var</span> dir_name_buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2097">            <span class="tok-kw">var</span> dir_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span> = sub_path;</span>
<span class="line" id="L2098"></span>
<span class="line" id="L2099">            <span class="tok-comment">// Here we must avoid recursion, in order to provide O(1) memory guarantee of this function.</span>
</span>
<span class="line" id="L2100">            <span class="tok-comment">// Go through each entry and if it is not a directory, delete it. If it is a directory,</span>
</span>
<span class="line" id="L2101">            <span class="tok-comment">// open it, and close the original directory. Repeat. Then start the entire operation over.</span>
</span>
<span class="line" id="L2102"></span>
<span class="line" id="L2103">            scan_dir: <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L2104">                <span class="tok-kw">var</span> dir_it = iterable_dir.iterate();</span>
<span class="line" id="L2105">                <span class="tok-kw">while</span> (<span class="tok-kw">try</span> dir_it.next()) |entry| {</span>
<span class="line" id="L2106">                    <span class="tok-kw">if</span> (iterable_dir.dir.deleteFile(entry.name)) {</span>
<span class="line" id="L2107">                        <span class="tok-kw">continue</span>;</span>
<span class="line" id="L2108">                    } <span class="tok-kw">else</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2109">                        <span class="tok-kw">error</span>.FileNotFound =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L2110"></span>
<span class="line" id="L2111">                        <span class="tok-comment">// Impossible because we do not pass any path separators.</span>
</span>
<span class="line" id="L2112">                        <span class="tok-kw">error</span>.NotDir =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2113"></span>
<span class="line" id="L2114">                        <span class="tok-kw">error</span>.IsDir =&gt; {},</span>
<span class="line" id="L2115">                        <span class="tok-kw">error</span>.AccessDenied =&gt; got_access_denied = <span class="tok-null">true</span>,</span>
<span class="line" id="L2116"></span>
<span class="line" id="L2117">                        <span class="tok-kw">error</span>.InvalidUtf8,</span>
<span class="line" id="L2118">                        <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2119">                        <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2120">                        <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2121">                        <span class="tok-kw">error</span>.ReadOnlyFileSystem,</span>
<span class="line" id="L2122">                        <span class="tok-kw">error</span>.FileSystem,</span>
<span class="line" id="L2123">                        <span class="tok-kw">error</span>.FileBusy,</span>
<span class="line" id="L2124">                        <span class="tok-kw">error</span>.BadPathName,</span>
<span class="line" id="L2125">                        <span class="tok-kw">error</span>.Unexpected,</span>
<span class="line" id="L2126">                        =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L2127">                    }</span>
<span class="line" id="L2128"></span>
<span class="line" id="L2129">                    <span class="tok-kw">const</span> new_dir = iterable_dir.dir.openIterableDir(entry.name, .{ .no_follow = <span class="tok-null">true</span> }) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2130">                        <span class="tok-kw">error</span>.NotDir =&gt; {</span>
<span class="line" id="L2131">                            <span class="tok-kw">if</span> (got_access_denied) {</span>
<span class="line" id="L2132">                                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.AccessDenied;</span>
<span class="line" id="L2133">                            }</span>
<span class="line" id="L2134">                            <span class="tok-kw">continue</span> :scan_dir;</span>
<span class="line" id="L2135">                        },</span>
<span class="line" id="L2136">                        <span class="tok-kw">error</span>.FileNotFound =&gt; {</span>
<span class="line" id="L2137">                            <span class="tok-comment">// That's fine, we were trying to remove this directory anyway.</span>
</span>
<span class="line" id="L2138">                            <span class="tok-kw">continue</span> :scan_dir;</span>
<span class="line" id="L2139">                        },</span>
<span class="line" id="L2140"></span>
<span class="line" id="L2141">                        <span class="tok-kw">error</span>.InvalidHandle,</span>
<span class="line" id="L2142">                        <span class="tok-kw">error</span>.AccessDenied,</span>
<span class="line" id="L2143">                        <span class="tok-kw">error</span>.SymLinkLoop,</span>
<span class="line" id="L2144">                        <span class="tok-kw">error</span>.ProcessFdQuotaExceeded,</span>
<span class="line" id="L2145">                        <span class="tok-kw">error</span>.NameTooLong,</span>
<span class="line" id="L2146">                        <span class="tok-kw">error</span>.SystemFdQuotaExceeded,</span>
<span class="line" id="L2147">                        <span class="tok-kw">error</span>.NoDevice,</span>
<span class="line" id="L2148">                        <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2149">                        <span class="tok-kw">error</span>.Unexpected,</span>
<span class="line" id="L2150">                        <span class="tok-kw">error</span>.InvalidUtf8,</span>
<span class="line" id="L2151">                        <span class="tok-kw">error</span>.BadPathName,</span>
<span class="line" id="L2152">                        <span class="tok-kw">error</span>.DeviceBusy,</span>
<span class="line" id="L2153">                        =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L2154">                    };</span>
<span class="line" id="L2155">                    <span class="tok-kw">if</span> (cleanup_dir_parent) |*d| d.close();</span>
<span class="line" id="L2156">                    cleanup_dir_parent = iterable_dir;</span>
<span class="line" id="L2157">                    iterable_dir = new_dir;</span>
<span class="line" id="L2158">                    mem.copy(<span class="tok-type">u8</span>, &amp;dir_name_buf, entry.name);</span>
<span class="line" id="L2159">                    dir_name = dir_name_buf[<span class="tok-number">0</span>..entry.name.len];</span>
<span class="line" id="L2160">                    <span class="tok-kw">continue</span> :scan_dir;</span>
<span class="line" id="L2161">                }</span>
<span class="line" id="L2162">                <span class="tok-comment">// Reached the end of the directory entries, which means we successfully deleted all of them.</span>
</span>
<span class="line" id="L2163">                <span class="tok-comment">// Now to remove the directory itself.</span>
</span>
<span class="line" id="L2164">                iterable_dir.close();</span>
<span class="line" id="L2165">                cleanup_dir = <span class="tok-null">false</span>;</span>
<span class="line" id="L2166"></span>
<span class="line" id="L2167">                <span class="tok-kw">if</span> (cleanup_dir_parent) |d| {</span>
<span class="line" id="L2168">                    d.dir.deleteDir(dir_name) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2169">                        <span class="tok-comment">// These two things can happen due to file system race conditions.</span>
</span>
<span class="line" id="L2170">                        <span class="tok-kw">error</span>.FileNotFound, <span class="tok-kw">error</span>.DirNotEmpty =&gt; <span class="tok-kw">continue</span> :start_over,</span>
<span class="line" id="L2171">                        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L2172">                    };</span>
<span class="line" id="L2173">                    <span class="tok-kw">continue</span> :start_over;</span>
<span class="line" id="L2174">                } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2175">                    self.deleteDir(sub_path) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2176">                        <span class="tok-kw">error</span>.FileNotFound =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2177">                        <span class="tok-kw">error</span>.DirNotEmpty =&gt; <span class="tok-kw">continue</span> :start_over,</span>
<span class="line" id="L2178">                        <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L2179">                    };</span>
<span class="line" id="L2180">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L2181">                }</span>
<span class="line" id="L2182">            }</span>
<span class="line" id="L2183">        }</span>
<span class="line" id="L2184">    }</span>
<span class="line" id="L2185"></span>
<span class="line" id="L2186">    <span class="tok-comment">/// Writes content to the file system, creating a new file if it does not exist, truncating</span></span>
<span class="line" id="L2187">    <span class="tok-comment">/// if it already exists.</span></span>
<span class="line" id="L2188">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeFile</span>(self: Dir, sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, data: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2189">        <span class="tok-kw">var</span> file = <span class="tok-kw">try</span> self.createFile(sub_path, .{});</span>
<span class="line" id="L2190">        <span class="tok-kw">defer</span> file.close();</span>
<span class="line" id="L2191">        <span class="tok-kw">try</span> file.writeAll(data);</span>
<span class="line" id="L2192">    }</span>
<span class="line" id="L2193"></span>
<span class="line" id="L2194">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> AccessError = os.AccessError;</span>
<span class="line" id="L2195"></span>
<span class="line" id="L2196">    <span class="tok-comment">/// Test accessing `path`.</span></span>
<span class="line" id="L2197">    <span class="tok-comment">/// `path` is UTF8-encoded.</span></span>
<span class="line" id="L2198">    <span class="tok-comment">/// Be careful of Time-Of-Check-Time-Of-Use race conditions when using this function.</span></span>
<span class="line" id="L2199">    <span class="tok-comment">/// For example, instead of testing if a file exists and then opening it, just</span></span>
<span class="line" id="L2200">    <span class="tok-comment">/// open it and handle the error for file not found.</span></span>
<span class="line" id="L2201">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">access</span>(self: Dir, sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: File.OpenFlags) AccessError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2202">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2203">            <span class="tok-kw">const</span> sub_path_w = <span class="tok-kw">try</span> os.windows.sliceToPrefixedFileW(sub_path);</span>
<span class="line" id="L2204">            <span class="tok-kw">return</span> self.accessW(sub_path_w.span().ptr, flags);</span>
<span class="line" id="L2205">        }</span>
<span class="line" id="L2206">        <span class="tok-kw">const</span> path_c = <span class="tok-kw">try</span> os.toPosixPath(sub_path);</span>
<span class="line" id="L2207">        <span class="tok-kw">return</span> self.accessZ(&amp;path_c, flags);</span>
<span class="line" id="L2208">    }</span>
<span class="line" id="L2209"></span>
<span class="line" id="L2210">    <span class="tok-comment">/// Same as `access` except the path parameter is null-terminated.</span></span>
<span class="line" id="L2211">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">accessZ</span>(self: Dir, sub_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: File.OpenFlags) AccessError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2212">        <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2213">            <span class="tok-kw">const</span> sub_path_w = <span class="tok-kw">try</span> os.windows.cStrToPrefixedFileW(sub_path);</span>
<span class="line" id="L2214">            <span class="tok-kw">return</span> self.accessW(sub_path_w.span().ptr, flags);</span>
<span class="line" id="L2215">        }</span>
<span class="line" id="L2216">        <span class="tok-kw">const</span> os_mode = <span class="tok-kw">switch</span> (flags.mode) {</span>
<span class="line" id="L2217">            .read_only =&gt; <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, os.F_OK),</span>
<span class="line" id="L2218">            .write_only =&gt; <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, os.W_OK),</span>
<span class="line" id="L2219">            .read_write =&gt; <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, os.R_OK | os.W_OK),</span>
<span class="line" id="L2220">        };</span>
<span class="line" id="L2221">        <span class="tok-kw">const</span> result = <span class="tok-kw">if</span> (need_async_thread <span class="tok-kw">and</span> flags.intended_io_mode != .blocking)</span>
<span class="line" id="L2222">            std.event.Loop.instance.?.faccessatZ(self.fd, sub_path, os_mode, <span class="tok-number">0</span>)</span>
<span class="line" id="L2223">        <span class="tok-kw">else</span></span>
<span class="line" id="L2224">            os.faccessatZ(self.fd, sub_path, os_mode, <span class="tok-number">0</span>);</span>
<span class="line" id="L2225">        <span class="tok-kw">return</span> result;</span>
<span class="line" id="L2226">    }</span>
<span class="line" id="L2227"></span>
<span class="line" id="L2228">    <span class="tok-comment">/// Same as `access` except asserts the target OS is Windows and the path parameter is</span></span>
<span class="line" id="L2229">    <span class="tok-comment">/// * WTF-16 encoded</span></span>
<span class="line" id="L2230">    <span class="tok-comment">/// * null-terminated</span></span>
<span class="line" id="L2231">    <span class="tok-comment">/// * NtDll prefixed</span></span>
<span class="line" id="L2232">    <span class="tok-comment">/// TODO currently this ignores `flags`.</span></span>
<span class="line" id="L2233">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">accessW</span>(self: Dir, sub_path_w: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, flags: File.OpenFlags) AccessError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2234">        _ = flags;</span>
<span class="line" id="L2235">        <span class="tok-kw">return</span> os.faccessatW(self.fd, sub_path_w, <span class="tok-number">0</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L2236">    }</span>
<span class="line" id="L2237"></span>
<span class="line" id="L2238">    <span class="tok-comment">/// Check the file size, mtime, and mode of `source_path` and `dest_path`. If they are equal, does nothing.</span></span>
<span class="line" id="L2239">    <span class="tok-comment">/// Otherwise, atomically copies `source_path` to `dest_path`. The destination file gains the mtime,</span></span>
<span class="line" id="L2240">    <span class="tok-comment">/// atime, and mode of the source file so that the next call to `updateFile` will not need a copy.</span></span>
<span class="line" id="L2241">    <span class="tok-comment">/// Returns the previous status of the file before updating.</span></span>
<span class="line" id="L2242">    <span class="tok-comment">/// If any of the directories do not exist for dest_path, they are created.</span></span>
<span class="line" id="L2243">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">updateFile</span>(</span>
<span class="line" id="L2244">        source_dir: Dir,</span>
<span class="line" id="L2245">        source_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2246">        dest_dir: Dir,</span>
<span class="line" id="L2247">        dest_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L2248">        options: CopyFileOptions,</span>
<span class="line" id="L2249">    ) !PrevStatus {</span>
<span class="line" id="L2250">        <span class="tok-kw">var</span> src_file = <span class="tok-kw">try</span> source_dir.openFile(source_path, .{});</span>
<span class="line" id="L2251">        <span class="tok-kw">defer</span> src_file.close();</span>
<span class="line" id="L2252"></span>
<span class="line" id="L2253">        <span class="tok-kw">const</span> src_stat = <span class="tok-kw">try</span> src_file.stat();</span>
<span class="line" id="L2254">        <span class="tok-kw">const</span> actual_mode = options.override_mode <span class="tok-kw">orelse</span> src_stat.mode;</span>
<span class="line" id="L2255">        check_dest_stat: {</span>
<span class="line" id="L2256">            <span class="tok-kw">const</span> dest_stat = blk: {</span>
<span class="line" id="L2257">                <span class="tok-kw">var</span> dest_file = dest_dir.openFile(dest_path, .{}) <span class="tok-kw">catch</span> |err| <span class="tok-kw">switch</span> (err) {</span>
<span class="line" id="L2258">                    <span class="tok-kw">error</span>.FileNotFound =&gt; <span class="tok-kw">break</span> :check_dest_stat,</span>
<span class="line" id="L2259">                    <span class="tok-kw">else</span> =&gt; |e| <span class="tok-kw">return</span> e,</span>
<span class="line" id="L2260">                };</span>
<span class="line" id="L2261">                <span class="tok-kw">defer</span> dest_file.close();</span>
<span class="line" id="L2262"></span>
<span class="line" id="L2263">                <span class="tok-kw">break</span> :blk <span class="tok-kw">try</span> dest_file.stat();</span>
<span class="line" id="L2264">            };</span>
<span class="line" id="L2265"></span>
<span class="line" id="L2266">            <span class="tok-kw">if</span> (src_stat.size == dest_stat.size <span class="tok-kw">and</span></span>
<span class="line" id="L2267">                src_stat.mtime == dest_stat.mtime <span class="tok-kw">and</span></span>
<span class="line" id="L2268">                actual_mode == dest_stat.mode)</span>
<span class="line" id="L2269">            {</span>
<span class="line" id="L2270">                <span class="tok-kw">return</span> PrevStatus.fresh;</span>
<span class="line" id="L2271">            }</span>
<span class="line" id="L2272">        }</span>
<span class="line" id="L2273"></span>
<span class="line" id="L2274">        <span class="tok-kw">if</span> (path.dirname(dest_path)) |dirname| {</span>
<span class="line" id="L2275">            <span class="tok-kw">try</span> dest_dir.makePath(dirname);</span>
<span class="line" id="L2276">        }</span>
<span class="line" id="L2277"></span>
<span class="line" id="L2278">        <span class="tok-kw">var</span> atomic_file = <span class="tok-kw">try</span> dest_dir.atomicFile(dest_path, .{ .mode = actual_mode });</span>
<span class="line" id="L2279">        <span class="tok-kw">defer</span> atomic_file.deinit();</span>
<span class="line" id="L2280"></span>
<span class="line" id="L2281">        <span class="tok-kw">try</span> atomic_file.file.writeFileAll(src_file, .{ .in_len = src_stat.size });</span>
<span class="line" id="L2282">        <span class="tok-kw">try</span> atomic_file.file.updateTimes(src_stat.atime, src_stat.mtime);</span>
<span class="line" id="L2283">        <span class="tok-kw">try</span> atomic_file.finish();</span>
<span class="line" id="L2284">        <span class="tok-kw">return</span> PrevStatus.stale;</span>
<span class="line" id="L2285">    }</span>
<span class="line" id="L2286"></span>
<span class="line" id="L2287">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CopyFileError = File.OpenError || File.StatError || AtomicFile.InitError || CopyFileRawError || AtomicFile.FinishError;</span>
<span class="line" id="L2288"></span>
<span class="line" id="L2289">    <span class="tok-comment">/// Guaranteed to be atomic.</span></span>
<span class="line" id="L2290">    <span class="tok-comment">/// On Linux, until https://patchwork.kernel.org/patch/9636735/ is merged and readily available,</span></span>
<span class="line" id="L2291">    <span class="tok-comment">/// there is a possibility of power loss or application termination leaving temporary files present</span></span>
<span class="line" id="L2292">    <span class="tok-comment">/// in the same directory as dest_path.</span></span>
<span class="line" id="L2293">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">copyFile</span>(source_dir: Dir, source_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, dest_dir: Dir, dest_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, options: CopyFileOptions) CopyFileError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2294">        <span class="tok-kw">var</span> in_file = <span class="tok-kw">try</span> source_dir.openFile(source_path, .{});</span>
<span class="line" id="L2295">        <span class="tok-kw">defer</span> in_file.close();</span>
<span class="line" id="L2296"></span>
<span class="line" id="L2297">        <span class="tok-kw">var</span> size: ?<span class="tok-type">u64</span> = <span class="tok-null">null</span>;</span>
<span class="line" id="L2298">        <span class="tok-kw">const</span> mode = options.override_mode <span class="tok-kw">orelse</span> blk: {</span>
<span class="line" id="L2299">            <span class="tok-kw">const</span> st = <span class="tok-kw">try</span> in_file.stat();</span>
<span class="line" id="L2300">            size = st.size;</span>
<span class="line" id="L2301">            <span class="tok-kw">break</span> :blk st.mode;</span>
<span class="line" id="L2302">        };</span>
<span class="line" id="L2303"></span>
<span class="line" id="L2304">        <span class="tok-kw">var</span> atomic_file = <span class="tok-kw">try</span> dest_dir.atomicFile(dest_path, .{ .mode = mode });</span>
<span class="line" id="L2305">        <span class="tok-kw">defer</span> atomic_file.deinit();</span>
<span class="line" id="L2306"></span>
<span class="line" id="L2307">        <span class="tok-kw">try</span> copy_file(in_file.handle, atomic_file.file.handle);</span>
<span class="line" id="L2308">        <span class="tok-kw">try</span> atomic_file.finish();</span>
<span class="line" id="L2309">    }</span>
<span class="line" id="L2310"></span>
<span class="line" id="L2311">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> AtomicFileOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2312">        mode: File.Mode = File.default_mode,</span>
<span class="line" id="L2313">    };</span>
<span class="line" id="L2314"></span>
<span class="line" id="L2315">    <span class="tok-comment">/// Directly access the `.file` field, and then call `AtomicFile.finish`</span></span>
<span class="line" id="L2316">    <span class="tok-comment">/// to atomically replace `dest_path` with contents.</span></span>
<span class="line" id="L2317">    <span class="tok-comment">/// Always call `AtomicFile.deinit` to clean up, regardless of whether `AtomicFile.finish` succeeded.</span></span>
<span class="line" id="L2318">    <span class="tok-comment">/// `dest_path` must remain valid until `AtomicFile.deinit` is called.</span></span>
<span class="line" id="L2319">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">atomicFile</span>(self: Dir, dest_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, options: AtomicFileOptions) !AtomicFile {</span>
<span class="line" id="L2320">        <span class="tok-kw">if</span> (path.dirname(dest_path)) |dirname| {</span>
<span class="line" id="L2321">            <span class="tok-kw">const</span> dir = <span class="tok-kw">try</span> self.openDir(dirname, .{});</span>
<span class="line" id="L2322">            <span class="tok-kw">return</span> AtomicFile.init(path.basename(dest_path), options.mode, dir, <span class="tok-null">true</span>);</span>
<span class="line" id="L2323">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2324">            <span class="tok-kw">return</span> AtomicFile.init(dest_path, options.mode, self, <span class="tok-null">false</span>);</span>
<span class="line" id="L2325">        }</span>
<span class="line" id="L2326">    }</span>
<span class="line" id="L2327"></span>
<span class="line" id="L2328">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Stat = File.Stat;</span>
<span class="line" id="L2329">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> StatError = File.StatError;</span>
<span class="line" id="L2330"></span>
<span class="line" id="L2331">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">stat</span>(self: Dir) StatError!Stat {</span>
<span class="line" id="L2332">        <span class="tok-kw">const</span> file: File = .{</span>
<span class="line" id="L2333">            .handle = self.fd,</span>
<span class="line" id="L2334">            .capable_io_mode = .blocking,</span>
<span class="line" id="L2335">        };</span>
<span class="line" id="L2336">        <span class="tok-kw">return</span> file.stat();</span>
<span class="line" id="L2337">    }</span>
<span class="line" id="L2338"></span>
<span class="line" id="L2339">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> StatFileError = File.OpenError || StatError;</span>
<span class="line" id="L2340"></span>
<span class="line" id="L2341">    <span class="tok-comment">// TODO: improve this to use the fstatat syscall instead of making 2 syscalls here.</span>
</span>
<span class="line" id="L2342">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">statFile</span>(self: Dir, sub_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) StatFileError!File.Stat {</span>
<span class="line" id="L2343">        <span class="tok-kw">var</span> file = <span class="tok-kw">try</span> self.openFile(sub_path, .{});</span>
<span class="line" id="L2344">        <span class="tok-kw">defer</span> file.close();</span>
<span class="line" id="L2345"></span>
<span class="line" id="L2346">        <span class="tok-kw">return</span> file.stat();</span>
<span class="line" id="L2347">    }</span>
<span class="line" id="L2348"></span>
<span class="line" id="L2349">    <span class="tok-kw">const</span> Permissions = File.Permissions;</span>
<span class="line" id="L2350">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SetPermissionsError = File.SetPermissionsError;</span>
<span class="line" id="L2351"></span>
<span class="line" id="L2352">    <span class="tok-comment">/// Sets permissions according to the provided `Permissions` struct.</span></span>
<span class="line" id="L2353">    <span class="tok-comment">/// This method is *NOT* available on WASI</span></span>
<span class="line" id="L2354">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setPermissions</span>(self: Dir, permissions: Permissions) SetPermissionsError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2355">        <span class="tok-kw">const</span> file: File = .{</span>
<span class="line" id="L2356">            .handle = self.fd,</span>
<span class="line" id="L2357">            .capable_io_mode = .blocking,</span>
<span class="line" id="L2358">        };</span>
<span class="line" id="L2359">        <span class="tok-kw">try</span> file.setPermissions(permissions);</span>
<span class="line" id="L2360">    }</span>
<span class="line" id="L2361"></span>
<span class="line" id="L2362">    <span class="tok-kw">const</span> Metadata = File.Metadata;</span>
<span class="line" id="L2363">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MetadataError = File.MetadataError;</span>
<span class="line" id="L2364"></span>
<span class="line" id="L2365">    <span class="tok-comment">/// Returns a `Metadata` struct, representing the permissions on the directory</span></span>
<span class="line" id="L2366">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">metadata</span>(self: Dir) MetadataError!Metadata {</span>
<span class="line" id="L2367">        <span class="tok-kw">const</span> file: File = .{</span>
<span class="line" id="L2368">            .handle = self.fd,</span>
<span class="line" id="L2369">            .capable_io_mode = .blocking,</span>
<span class="line" id="L2370">        };</span>
<span class="line" id="L2371">        <span class="tok-kw">return</span> <span class="tok-kw">try</span> file.metadata();</span>
<span class="line" id="L2372">    }</span>
<span class="line" id="L2373">};</span>
<span class="line" id="L2374"></span>
<span class="line" id="L2375"><span class="tok-comment">/// Returns a handle to the current working directory. It is not opened with iteration capability.</span></span>
<span class="line" id="L2376"><span class="tok-comment">/// Closing the returned `Dir` is checked illegal behavior. Iterating over the result is illegal behavior.</span></span>
<span class="line" id="L2377"><span class="tok-comment">/// On POSIX targets, this function is comptime-callable.</span></span>
<span class="line" id="L2378"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cwd</span>() Dir {</span>
<span class="line" id="L2379">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2380">        <span class="tok-kw">return</span> Dir{ .fd = os.windows.peb().ProcessParameters.CurrentDirectory.Handle };</span>
<span class="line" id="L2381">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L2382">        <span class="tok-kw">return</span> Dir{ .fd = os.AT.FDCWD };</span>
<span class="line" id="L2383">    }</span>
<span class="line" id="L2384">}</span>
<span class="line" id="L2385"></span>
<span class="line" id="L2386"><span class="tok-comment">/// Opens a directory at the given path. The directory is a system resource that remains</span></span>
<span class="line" id="L2387"><span class="tok-comment">/// open until `close` is called on the result.</span></span>
<span class="line" id="L2388"><span class="tok-comment">/// See `openDirAbsoluteZ` for a function that accepts a null-terminated path.</span></span>
<span class="line" id="L2389"><span class="tok-comment">///</span></span>
<span class="line" id="L2390"><span class="tok-comment">/// Asserts that the path parameter has no null bytes.</span></span>
<span class="line" id="L2391"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openDirAbsolute</span>(absolute_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: Dir.OpenDirOptions) File.OpenError!Dir {</span>
<span class="line" id="L2392">    assert(path.isAbsolute(absolute_path));</span>
<span class="line" id="L2393">    <span class="tok-kw">return</span> cwd().openDir(absolute_path, flags);</span>
<span class="line" id="L2394">}</span>
<span class="line" id="L2395"></span>
<span class="line" id="L2396"><span class="tok-comment">/// Same as `openDirAbsolute` but the path parameter is null-terminated.</span></span>
<span class="line" id="L2397"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openDirAbsoluteZ</span>(absolute_path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: Dir.OpenDirOptions) File.OpenError!Dir {</span>
<span class="line" id="L2398">    assert(path.isAbsoluteZ(absolute_path_c));</span>
<span class="line" id="L2399">    <span class="tok-kw">return</span> cwd().openDirZ(absolute_path_c, flags);</span>
<span class="line" id="L2400">}</span>
<span class="line" id="L2401"><span class="tok-comment">/// Same as `openDirAbsolute` but the path parameter is null-terminated.</span></span>
<span class="line" id="L2402"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openDirAbsoluteW</span>(absolute_path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, flags: Dir.OpenDirOptions) File.OpenError!Dir {</span>
<span class="line" id="L2403">    assert(path.isAbsoluteWindowsW(absolute_path_c));</span>
<span class="line" id="L2404">    <span class="tok-kw">return</span> cwd().openDirW(absolute_path_c, flags);</span>
<span class="line" id="L2405">}</span>
<span class="line" id="L2406"></span>
<span class="line" id="L2407"><span class="tok-comment">/// Opens a directory at the given path. The directory is a system resource that remains</span></span>
<span class="line" id="L2408"><span class="tok-comment">/// open until `close` is called on the result.</span></span>
<span class="line" id="L2409"><span class="tok-comment">/// See `openIterableDirAbsoluteZ` for a function that accepts a null-terminated path.</span></span>
<span class="line" id="L2410"><span class="tok-comment">///</span></span>
<span class="line" id="L2411"><span class="tok-comment">/// Asserts that the path parameter has no null bytes.</span></span>
<span class="line" id="L2412"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openIterableDirAbsolute</span>(absolute_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: Dir.OpenDirOptions) File.OpenError!IterableDir {</span>
<span class="line" id="L2413">    assert(path.isAbsolute(absolute_path));</span>
<span class="line" id="L2414">    <span class="tok-kw">return</span> cwd().openIterableDir(absolute_path, flags);</span>
<span class="line" id="L2415">}</span>
<span class="line" id="L2416"></span>
<span class="line" id="L2417"><span class="tok-comment">/// Same as `openIterableDirAbsolute` but the path parameter is null-terminated.</span></span>
<span class="line" id="L2418"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openIterableDirAbsoluteZ</span>(absolute_path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: Dir.OpenDirOptions) File.OpenError!IterableDir {</span>
<span class="line" id="L2419">    assert(path.isAbsoluteZ(absolute_path_c));</span>
<span class="line" id="L2420">    <span class="tok-kw">return</span> IterableDir{ .dir = <span class="tok-kw">try</span> cwd().openDirZ(absolute_path_c, flags, <span class="tok-null">true</span>) };</span>
<span class="line" id="L2421">}</span>
<span class="line" id="L2422"><span class="tok-comment">/// Same as `openIterableDirAbsolute` but the path parameter is null-terminated.</span></span>
<span class="line" id="L2423"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openIterableDirAbsoluteW</span>(absolute_path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, flags: Dir.OpenDirOptions) File.OpenError!IterableDir {</span>
<span class="line" id="L2424">    assert(path.isAbsoluteWindowsW(absolute_path_c));</span>
<span class="line" id="L2425">    <span class="tok-kw">return</span> IterableDir{ .dir = <span class="tok-kw">try</span> cwd().openDirW(absolute_path_c, flags, <span class="tok-null">true</span>) };</span>
<span class="line" id="L2426">}</span>
<span class="line" id="L2427"></span>
<span class="line" id="L2428"><span class="tok-comment">/// Opens a file for reading or writing, without attempting to create a new file, based on an absolute path.</span></span>
<span class="line" id="L2429"><span class="tok-comment">/// Call `File.close` to release the resource.</span></span>
<span class="line" id="L2430"><span class="tok-comment">/// Asserts that the path is absolute. See `Dir.openFile` for a function that</span></span>
<span class="line" id="L2431"><span class="tok-comment">/// operates on both absolute and relative paths.</span></span>
<span class="line" id="L2432"><span class="tok-comment">/// Asserts that the path parameter has no null bytes. See `openFileAbsoluteZ` for a function</span></span>
<span class="line" id="L2433"><span class="tok-comment">/// that accepts a null-terminated path.</span></span>
<span class="line" id="L2434"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openFileAbsolute</span>(absolute_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: File.OpenFlags) File.OpenError!File {</span>
<span class="line" id="L2435">    assert(path.isAbsolute(absolute_path));</span>
<span class="line" id="L2436">    <span class="tok-kw">return</span> cwd().openFile(absolute_path, flags);</span>
<span class="line" id="L2437">}</span>
<span class="line" id="L2438"></span>
<span class="line" id="L2439"><span class="tok-comment">/// Same as `openFileAbsolute` but the path parameter is null-terminated.</span></span>
<span class="line" id="L2440"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openFileAbsoluteZ</span>(absolute_path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: File.OpenFlags) File.OpenError!File {</span>
<span class="line" id="L2441">    assert(path.isAbsoluteZ(absolute_path_c));</span>
<span class="line" id="L2442">    <span class="tok-kw">return</span> cwd().openFileZ(absolute_path_c, flags);</span>
<span class="line" id="L2443">}</span>
<span class="line" id="L2444"></span>
<span class="line" id="L2445"><span class="tok-comment">/// Same as `openFileAbsolute` but the path parameter is WTF-16 encoded.</span></span>
<span class="line" id="L2446"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openFileAbsoluteW</span>(absolute_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, flags: File.OpenFlags) File.OpenError!File {</span>
<span class="line" id="L2447">    assert(path.isAbsoluteWindowsWTF16(absolute_path_w));</span>
<span class="line" id="L2448">    <span class="tok-kw">return</span> cwd().openFileW(absolute_path_w, flags);</span>
<span class="line" id="L2449">}</span>
<span class="line" id="L2450"></span>
<span class="line" id="L2451"><span class="tok-comment">/// Test accessing `path`.</span></span>
<span class="line" id="L2452"><span class="tok-comment">/// `path` is UTF8-encoded.</span></span>
<span class="line" id="L2453"><span class="tok-comment">/// Be careful of Time-Of-Check-Time-Of-Use race conditions when using this function.</span></span>
<span class="line" id="L2454"><span class="tok-comment">/// For example, instead of testing if a file exists and then opening it, just</span></span>
<span class="line" id="L2455"><span class="tok-comment">/// open it and handle the error for file not found.</span></span>
<span class="line" id="L2456"><span class="tok-comment">/// See `accessAbsoluteZ` for a function that accepts a null-terminated path.</span></span>
<span class="line" id="L2457"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">accessAbsolute</span>(absolute_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: File.OpenFlags) Dir.AccessError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2458">    assert(path.isAbsolute(absolute_path));</span>
<span class="line" id="L2459">    <span class="tok-kw">try</span> cwd().access(absolute_path, flags);</span>
<span class="line" id="L2460">}</span>
<span class="line" id="L2461"><span class="tok-comment">/// Same as `accessAbsolute` but the path parameter is null-terminated.</span></span>
<span class="line" id="L2462"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">accessAbsoluteZ</span>(absolute_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: File.OpenFlags) Dir.AccessError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2463">    assert(path.isAbsoluteZ(absolute_path));</span>
<span class="line" id="L2464">    <span class="tok-kw">try</span> cwd().accessZ(absolute_path, flags);</span>
<span class="line" id="L2465">}</span>
<span class="line" id="L2466"><span class="tok-comment">/// Same as `accessAbsolute` but the path parameter is WTF-16 encoded.</span></span>
<span class="line" id="L2467"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">accessAbsoluteW</span>(absolute_path: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-number">16</span>, flags: File.OpenFlags) Dir.AccessError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2468">    assert(path.isAbsoluteWindowsW(absolute_path));</span>
<span class="line" id="L2469">    <span class="tok-kw">try</span> cwd().accessW(absolute_path, flags);</span>
<span class="line" id="L2470">}</span>
<span class="line" id="L2471"></span>
<span class="line" id="L2472"><span class="tok-comment">/// Creates, opens, or overwrites a file with write access, based on an absolute path.</span></span>
<span class="line" id="L2473"><span class="tok-comment">/// Call `File.close` to release the resource.</span></span>
<span class="line" id="L2474"><span class="tok-comment">/// Asserts that the path is absolute. See `Dir.createFile` for a function that</span></span>
<span class="line" id="L2475"><span class="tok-comment">/// operates on both absolute and relative paths.</span></span>
<span class="line" id="L2476"><span class="tok-comment">/// Asserts that the path parameter has no null bytes. See `createFileAbsoluteC` for a function</span></span>
<span class="line" id="L2477"><span class="tok-comment">/// that accepts a null-terminated path.</span></span>
<span class="line" id="L2478"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createFileAbsolute</span>(absolute_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: File.CreateFlags) File.OpenError!File {</span>
<span class="line" id="L2479">    assert(path.isAbsolute(absolute_path));</span>
<span class="line" id="L2480">    <span class="tok-kw">return</span> cwd().createFile(absolute_path, flags);</span>
<span class="line" id="L2481">}</span>
<span class="line" id="L2482"></span>
<span class="line" id="L2483"><span class="tok-comment">/// Same as `createFileAbsolute` but the path parameter is null-terminated.</span></span>
<span class="line" id="L2484"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createFileAbsoluteZ</span>(absolute_path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: File.CreateFlags) File.OpenError!File {</span>
<span class="line" id="L2485">    assert(path.isAbsoluteZ(absolute_path_c));</span>
<span class="line" id="L2486">    <span class="tok-kw">return</span> cwd().createFileZ(absolute_path_c, flags);</span>
<span class="line" id="L2487">}</span>
<span class="line" id="L2488"></span>
<span class="line" id="L2489"><span class="tok-comment">/// Same as `createFileAbsolute` but the path parameter is WTF-16 encoded.</span></span>
<span class="line" id="L2490"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">createFileAbsoluteW</span>(absolute_path_w: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, flags: File.CreateFlags) File.OpenError!File {</span>
<span class="line" id="L2491">    assert(path.isAbsoluteWindowsW(absolute_path_w));</span>
<span class="line" id="L2492">    <span class="tok-kw">return</span> cwd().createFileW(absolute_path_w, flags);</span>
<span class="line" id="L2493">}</span>
<span class="line" id="L2494"></span>
<span class="line" id="L2495"><span class="tok-comment">/// Delete a file name and possibly the file it refers to, based on an absolute path.</span></span>
<span class="line" id="L2496"><span class="tok-comment">/// Asserts that the path is absolute. See `Dir.deleteFile` for a function that</span></span>
<span class="line" id="L2497"><span class="tok-comment">/// operates on both absolute and relative paths.</span></span>
<span class="line" id="L2498"><span class="tok-comment">/// Asserts that the path parameter has no null bytes.</span></span>
<span class="line" id="L2499"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deleteFileAbsolute</span>(absolute_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Dir.DeleteFileError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2500">    assert(path.isAbsolute(absolute_path));</span>
<span class="line" id="L2501">    <span class="tok-kw">return</span> cwd().deleteFile(absolute_path);</span>
<span class="line" id="L2502">}</span>
<span class="line" id="L2503"></span>
<span class="line" id="L2504"><span class="tok-comment">/// Same as `deleteFileAbsolute` except the parameter is null-terminated.</span></span>
<span class="line" id="L2505"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deleteFileAbsoluteZ</span>(absolute_path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Dir.DeleteFileError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2506">    assert(path.isAbsoluteZ(absolute_path_c));</span>
<span class="line" id="L2507">    <span class="tok-kw">return</span> cwd().deleteFileZ(absolute_path_c);</span>
<span class="line" id="L2508">}</span>
<span class="line" id="L2509"></span>
<span class="line" id="L2510"><span class="tok-comment">/// Same as `deleteFileAbsolute` except the parameter is WTF-16 encoded.</span></span>
<span class="line" id="L2511"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deleteFileAbsoluteW</span>(absolute_path_w: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>) Dir.DeleteFileError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2512">    assert(path.isAbsoluteWindowsW(absolute_path_w));</span>
<span class="line" id="L2513">    <span class="tok-kw">return</span> cwd().deleteFileW(absolute_path_w);</span>
<span class="line" id="L2514">}</span>
<span class="line" id="L2515"></span>
<span class="line" id="L2516"><span class="tok-comment">/// Removes a symlink, file, or directory.</span></span>
<span class="line" id="L2517"><span class="tok-comment">/// This is equivalent to `Dir.deleteTree` with the base directory.</span></span>
<span class="line" id="L2518"><span class="tok-comment">/// Asserts that the path is absolute. See `Dir.deleteTree` for a function that</span></span>
<span class="line" id="L2519"><span class="tok-comment">/// operates on both absolute and relative paths.</span></span>
<span class="line" id="L2520"><span class="tok-comment">/// Asserts that the path parameter has no null bytes.</span></span>
<span class="line" id="L2521"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deleteTreeAbsolute</span>(absolute_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2522">    assert(path.isAbsolute(absolute_path));</span>
<span class="line" id="L2523">    <span class="tok-kw">const</span> dirname = path.dirname(absolute_path) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>{</span>
<span class="line" id="L2524">        <span class="tok-comment">/// Attempt to remove the root file system path.</span></span>
<span class="line" id="L2525">        <span class="tok-comment">/// This error is unreachable if `absolute_path` is relative.</span></span>
<span class="line" id="L2526">        CannotDeleteRootDirectory,</span>
<span class="line" id="L2527">    }.CannotDeleteRootDirectory;</span>
<span class="line" id="L2528"></span>
<span class="line" id="L2529">    <span class="tok-kw">var</span> dir = <span class="tok-kw">try</span> cwd().openDir(dirname, .{});</span>
<span class="line" id="L2530">    <span class="tok-kw">defer</span> dir.close();</span>
<span class="line" id="L2531"></span>
<span class="line" id="L2532">    <span class="tok-kw">return</span> dir.deleteTree(path.basename(absolute_path));</span>
<span class="line" id="L2533">}</span>
<span class="line" id="L2534"></span>
<span class="line" id="L2535"><span class="tok-comment">/// Same as `Dir.readLink`, except it asserts the path is absolute.</span></span>
<span class="line" id="L2536"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readLinkAbsolute</span>(pathname: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, buffer: *[MAX_PATH_BYTES]<span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L2537">    assert(path.isAbsolute(pathname));</span>
<span class="line" id="L2538">    <span class="tok-kw">return</span> os.readlink(pathname, buffer);</span>
<span class="line" id="L2539">}</span>
<span class="line" id="L2540"></span>
<span class="line" id="L2541"><span class="tok-comment">/// Windows-only. Same as `readlinkW`, except the path parameter is null-terminated, WTF16</span></span>
<span class="line" id="L2542"><span class="tok-comment">/// encoded.</span></span>
<span class="line" id="L2543"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readlinkAbsoluteW</span>(pathname_w: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, buffer: *[MAX_PATH_BYTES]<span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L2544">    assert(path.isAbsoluteWindowsW(pathname_w));</span>
<span class="line" id="L2545">    <span class="tok-kw">return</span> os.readlinkW(pathname_w, buffer);</span>
<span class="line" id="L2546">}</span>
<span class="line" id="L2547"></span>
<span class="line" id="L2548"><span class="tok-comment">/// Same as `readLink`, except the path parameter is null-terminated.</span></span>
<span class="line" id="L2549"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">readLinkAbsoluteZ</span>(pathname_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, buffer: *[MAX_PATH_BYTES]<span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L2550">    assert(path.isAbsoluteZ(pathname_c));</span>
<span class="line" id="L2551">    <span class="tok-kw">return</span> os.readlinkZ(pathname_c, buffer);</span>
<span class="line" id="L2552">}</span>
<span class="line" id="L2553"></span>
<span class="line" id="L2554"><span class="tok-comment">/// Use with `Dir.symLink` and `symLinkAbsolute` to specify whether the symlink</span></span>
<span class="line" id="L2555"><span class="tok-comment">/// will point to a file or a directory. This value is ignored on all hosts</span></span>
<span class="line" id="L2556"><span class="tok-comment">/// except Windows where creating symlinks to different resource types, requires</span></span>
<span class="line" id="L2557"><span class="tok-comment">/// different flags. By default, `symLinkAbsolute` is assumed to point to a file.</span></span>
<span class="line" id="L2558"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SymLinkFlags = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L2559">    is_directory: <span class="tok-type">bool</span> = <span class="tok-null">false</span>,</span>
<span class="line" id="L2560">};</span>
<span class="line" id="L2561"></span>
<span class="line" id="L2562"><span class="tok-comment">/// Creates a symbolic link named `sym_link_path` which contains the string `target_path`.</span></span>
<span class="line" id="L2563"><span class="tok-comment">/// A symbolic link (also known as a soft link) may point to an existing file or to a nonexistent</span></span>
<span class="line" id="L2564"><span class="tok-comment">/// one; the latter case is known as a dangling link.</span></span>
<span class="line" id="L2565"><span class="tok-comment">/// If `sym_link_path` exists, it will not be overwritten.</span></span>
<span class="line" id="L2566"><span class="tok-comment">/// See also `symLinkAbsoluteZ` and `symLinkAbsoluteW`.</span></span>
<span class="line" id="L2567"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">symLinkAbsolute</span>(target_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, sym_link_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: SymLinkFlags) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2568">    assert(path.isAbsolute(target_path));</span>
<span class="line" id="L2569">    assert(path.isAbsolute(sym_link_path));</span>
<span class="line" id="L2570">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2571">        <span class="tok-kw">const</span> target_path_w = <span class="tok-kw">try</span> os.windows.sliceToPrefixedFileW(target_path);</span>
<span class="line" id="L2572">        <span class="tok-kw">const</span> sym_link_path_w = <span class="tok-kw">try</span> os.windows.sliceToPrefixedFileW(sym_link_path);</span>
<span class="line" id="L2573">        <span class="tok-kw">return</span> os.windows.CreateSymbolicLink(<span class="tok-null">null</span>, sym_link_path_w.span(), target_path_w.span(), flags.is_directory);</span>
<span class="line" id="L2574">    }</span>
<span class="line" id="L2575">    <span class="tok-kw">return</span> os.symlink(target_path, sym_link_path);</span>
<span class="line" id="L2576">}</span>
<span class="line" id="L2577"></span>
<span class="line" id="L2578"><span class="tok-comment">/// Windows-only. Same as `symLinkAbsolute` except the parameters are null-terminated, WTF16 encoded.</span></span>
<span class="line" id="L2579"><span class="tok-comment">/// Note that this function will by default try creating a symbolic link to a file. If you would</span></span>
<span class="line" id="L2580"><span class="tok-comment">/// like to create a symbolic link to a directory, specify this with `SymLinkFlags{ .is_directory = true }`.</span></span>
<span class="line" id="L2581"><span class="tok-comment">/// See also `symLinkAbsolute`, `symLinkAbsoluteZ`.</span></span>
<span class="line" id="L2582"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">symLinkAbsoluteW</span>(target_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, sym_link_path_w: []<span class="tok-kw">const</span> <span class="tok-type">u16</span>, flags: SymLinkFlags) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2583">    assert(path.isAbsoluteWindowsWTF16(target_path_w));</span>
<span class="line" id="L2584">    assert(path.isAbsoluteWindowsWTF16(sym_link_path_w));</span>
<span class="line" id="L2585">    <span class="tok-kw">return</span> os.windows.CreateSymbolicLink(<span class="tok-null">null</span>, sym_link_path_w, target_path_w, flags.is_directory);</span>
<span class="line" id="L2586">}</span>
<span class="line" id="L2587"></span>
<span class="line" id="L2588"><span class="tok-comment">/// Same as `symLinkAbsolute` except the parameters are null-terminated pointers.</span></span>
<span class="line" id="L2589"><span class="tok-comment">/// See also `symLinkAbsolute`.</span></span>
<span class="line" id="L2590"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">symLinkAbsoluteZ</span>(target_path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, sym_link_path_c: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, flags: SymLinkFlags) !<span class="tok-type">void</span> {</span>
<span class="line" id="L2591">    assert(path.isAbsoluteZ(target_path_c));</span>
<span class="line" id="L2592">    assert(path.isAbsoluteZ(sym_link_path_c));</span>
<span class="line" id="L2593">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2594">        <span class="tok-kw">const</span> target_path_w = <span class="tok-kw">try</span> os.windows.cStrToWin32PrefixedFileW(target_path_c);</span>
<span class="line" id="L2595">        <span class="tok-kw">const</span> sym_link_path_w = <span class="tok-kw">try</span> os.windows.cStrToWin32PrefixedFileW(sym_link_path_c);</span>
<span class="line" id="L2596">        <span class="tok-kw">return</span> os.windows.CreateSymbolicLink(sym_link_path_w.span(), target_path_w.span(), flags.is_directory);</span>
<span class="line" id="L2597">    }</span>
<span class="line" id="L2598">    <span class="tok-kw">return</span> os.symlinkZ(target_path_c, sym_link_path_c);</span>
<span class="line" id="L2599">}</span>
<span class="line" id="L2600"></span>
<span class="line" id="L2601"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> OpenSelfExeError = <span class="tok-kw">error</span>{</span>
<span class="line" id="L2602">    SharingViolation,</span>
<span class="line" id="L2603">    PathAlreadyExists,</span>
<span class="line" id="L2604">    FileNotFound,</span>
<span class="line" id="L2605">    AccessDenied,</span>
<span class="line" id="L2606">    PipeBusy,</span>
<span class="line" id="L2607">    NameTooLong,</span>
<span class="line" id="L2608">    <span class="tok-comment">/// On Windows, file paths must be valid Unicode.</span></span>
<span class="line" id="L2609">    InvalidUtf8,</span>
<span class="line" id="L2610">    <span class="tok-comment">/// On Windows, file paths cannot contain these characters:</span></span>
<span class="line" id="L2611">    <span class="tok-comment">/// '/', '*', '?', '&quot;', '&lt;', '&gt;', '|'</span></span>
<span class="line" id="L2612">    BadPathName,</span>
<span class="line" id="L2613">    Unexpected,</span>
<span class="line" id="L2614">} || os.OpenError || SelfExePathError || os.FlockError;</span>
<span class="line" id="L2615"></span>
<span class="line" id="L2616"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">openSelfExe</span>(flags: File.OpenFlags) OpenSelfExeError!File {</span>
<span class="line" id="L2617">    <span class="tok-kw">if</span> (builtin.os.tag == .linux) {</span>
<span class="line" id="L2618">        <span class="tok-kw">return</span> openFileAbsoluteZ(<span class="tok-str">&quot;/proc/self/exe&quot;</span>, flags);</span>
<span class="line" id="L2619">    }</span>
<span class="line" id="L2620">    <span class="tok-kw">if</span> (builtin.os.tag == .windows) {</span>
<span class="line" id="L2621">        <span class="tok-kw">const</span> wide_slice = selfExePathW();</span>
<span class="line" id="L2622">        <span class="tok-kw">const</span> prefixed_path_w = <span class="tok-kw">try</span> os.windows.wToPrefixedFileW(wide_slice);</span>
<span class="line" id="L2623">        <span class="tok-kw">return</span> cwd().openFileW(prefixed_path_w.span(), flags);</span>
<span class="line" id="L2624">    }</span>
<span class="line" id="L2625">    <span class="tok-comment">// Use of MAX_PATH_BYTES here is valid as the resulting path is immediately</span>
</span>
<span class="line" id="L2626">    <span class="tok-comment">// opened with no modification.</span>
</span>
<span class="line" id="L2627">    <span class="tok-kw">var</span> buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2628">    <span class="tok-kw">const</span> self_exe_path = <span class="tok-kw">try</span> selfExePath(&amp;buf);</span>
<span class="line" id="L2629">    buf[self_exe_path.len] = <span class="tok-number">0</span>;</span>
<span class="line" id="L2630">    <span class="tok-kw">return</span> openFileAbsoluteZ(buf[<span class="tok-number">0</span>..self_exe_path.len :<span class="tok-number">0</span>].ptr, flags);</span>
<span class="line" id="L2631">}</span>
<span class="line" id="L2632"></span>
<span class="line" id="L2633"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SelfExePathError = os.ReadLinkError || os.SysCtlError || os.RealPathError;</span>
<span class="line" id="L2634"></span>
<span class="line" id="L2635"><span class="tok-comment">/// `selfExePath` except allocates the result on the heap.</span></span>
<span class="line" id="L2636"><span class="tok-comment">/// Caller owns returned memory.</span></span>
<span class="line" id="L2637"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">selfExePathAlloc</span>(allocator: Allocator) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L2638">    <span class="tok-comment">// Use of MAX_PATH_BYTES here is justified as, at least on one tested Linux</span>
</span>
<span class="line" id="L2639">    <span class="tok-comment">// system, readlink will completely fail to return a result larger than</span>
</span>
<span class="line" id="L2640">    <span class="tok-comment">// PATH_MAX even if given a sufficiently large buffer. This makes it</span>
</span>
<span class="line" id="L2641">    <span class="tok-comment">// fundamentally impossible to get the selfExePath of a program running in</span>
</span>
<span class="line" id="L2642">    <span class="tok-comment">// a very deeply nested directory chain in this way.</span>
</span>
<span class="line" id="L2643">    <span class="tok-comment">// TODO(#4812): Investigate other systems and whether it is possible to get</span>
</span>
<span class="line" id="L2644">    <span class="tok-comment">// this path by trying larger and larger buffers until one succeeds.</span>
</span>
<span class="line" id="L2645">    <span class="tok-kw">var</span> buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2646">    <span class="tok-kw">return</span> allocator.dupe(<span class="tok-type">u8</span>, <span class="tok-kw">try</span> selfExePath(&amp;buf));</span>
<span class="line" id="L2647">}</span>
<span class="line" id="L2648"></span>
<span class="line" id="L2649"><span class="tok-comment">/// Get the path to the current executable.</span></span>
<span class="line" id="L2650"><span class="tok-comment">/// If you only need the directory, use selfExeDirPath.</span></span>
<span class="line" id="L2651"><span class="tok-comment">/// If you only want an open file handle, use openSelfExe.</span></span>
<span class="line" id="L2652"><span class="tok-comment">/// This function may return an error if the current executable</span></span>
<span class="line" id="L2653"><span class="tok-comment">/// was deleted after spawning.</span></span>
<span class="line" id="L2654"><span class="tok-comment">/// Returned value is a slice of out_buffer.</span></span>
<span class="line" id="L2655"><span class="tok-comment">///</span></span>
<span class="line" id="L2656"><span class="tok-comment">/// On Linux, depends on procfs being mounted. If the currently executing binary has</span></span>
<span class="line" id="L2657"><span class="tok-comment">/// been deleted, the file path looks something like `/a/b/c/exe (deleted)`.</span></span>
<span class="line" id="L2658"><span class="tok-comment">/// TODO make the return type of this a null terminated pointer</span></span>
<span class="line" id="L2659"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">selfExePath</span>(out_buffer: []<span class="tok-type">u8</span>) SelfExePathError![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L2660">    <span class="tok-kw">if</span> (is_darwin) {</span>
<span class="line" id="L2661">        <span class="tok-comment">// Note that _NSGetExecutablePath() will return &quot;a path&quot; to</span>
</span>
<span class="line" id="L2662">        <span class="tok-comment">// the executable not a &quot;real path&quot; to the executable.</span>
</span>
<span class="line" id="L2663">        <span class="tok-kw">var</span> symlink_path_buf: [MAX_PATH_BYTES:<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2664">        <span class="tok-kw">var</span> u32_len: <span class="tok-type">u32</span> = MAX_PATH_BYTES + <span class="tok-number">1</span>; <span class="tok-comment">// include the sentinel</span>
</span>
<span class="line" id="L2665">        <span class="tok-kw">const</span> rc = std.c._NSGetExecutablePath(&amp;symlink_path_buf, &amp;u32_len);</span>
<span class="line" id="L2666">        <span class="tok-kw">if</span> (rc != <span class="tok-number">0</span>) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L2667"></span>
<span class="line" id="L2668">        <span class="tok-kw">var</span> real_path_buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2669">        <span class="tok-kw">const</span> real_path = <span class="tok-kw">try</span> std.os.realpathZ(&amp;symlink_path_buf, &amp;real_path_buf);</span>
<span class="line" id="L2670">        <span class="tok-kw">if</span> (real_path.len &gt; out_buffer.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L2671">        std.mem.copy(<span class="tok-type">u8</span>, out_buffer, real_path);</span>
<span class="line" id="L2672">        <span class="tok-kw">return</span> out_buffer[<span class="tok-number">0</span>..real_path.len];</span>
<span class="line" id="L2673">    }</span>
<span class="line" id="L2674">    <span class="tok-kw">switch</span> (builtin.os.tag) {</span>
<span class="line" id="L2675">        .linux =&gt; <span class="tok-kw">return</span> os.readlinkZ(<span class="tok-str">&quot;/proc/self/exe&quot;</span>, out_buffer),</span>
<span class="line" id="L2676">        .solaris =&gt; <span class="tok-kw">return</span> os.readlinkZ(<span class="tok-str">&quot;/proc/self/path/a.out&quot;</span>, out_buffer),</span>
<span class="line" id="L2677">        .freebsd, .dragonfly =&gt; {</span>
<span class="line" id="L2678">            <span class="tok-kw">var</span> mib = [<span class="tok-number">4</span>]<span class="tok-type">c_int</span>{ os.CTL.KERN, os.KERN.PROC, os.KERN.PROC_PATHNAME, -<span class="tok-number">1</span> };</span>
<span class="line" id="L2679">            <span class="tok-kw">var</span> out_len: <span class="tok-type">usize</span> = out_buffer.len;</span>
<span class="line" id="L2680">            <span class="tok-kw">try</span> os.sysctl(&amp;mib, out_buffer.ptr, &amp;out_len, <span class="tok-null">null</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L2681">            <span class="tok-comment">// TODO could this slice from 0 to out_len instead?</span>
</span>
<span class="line" id="L2682">            <span class="tok-kw">return</span> mem.sliceTo(std.meta.assumeSentinel(out_buffer.ptr, <span class="tok-number">0</span>), <span class="tok-number">0</span>);</span>
<span class="line" id="L2683">        },</span>
<span class="line" id="L2684">        .netbsd =&gt; {</span>
<span class="line" id="L2685">            <span class="tok-kw">var</span> mib = [<span class="tok-number">4</span>]<span class="tok-type">c_int</span>{ os.CTL.KERN, os.KERN.PROC_ARGS, -<span class="tok-number">1</span>, os.KERN.PROC_PATHNAME };</span>
<span class="line" id="L2686">            <span class="tok-kw">var</span> out_len: <span class="tok-type">usize</span> = out_buffer.len;</span>
<span class="line" id="L2687">            <span class="tok-kw">try</span> os.sysctl(&amp;mib, out_buffer.ptr, &amp;out_len, <span class="tok-null">null</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L2688">            <span class="tok-comment">// TODO could this slice from 0 to out_len instead?</span>
</span>
<span class="line" id="L2689">            <span class="tok-kw">return</span> mem.sliceTo(std.meta.assumeSentinel(out_buffer.ptr, <span class="tok-number">0</span>), <span class="tok-number">0</span>);</span>
<span class="line" id="L2690">        },</span>
<span class="line" id="L2691">        .openbsd, .haiku =&gt; {</span>
<span class="line" id="L2692">            <span class="tok-comment">// OpenBSD doesn't support getting the path of a running process, so try to guess it</span>
</span>
<span class="line" id="L2693">            <span class="tok-kw">if</span> (os.argv.len == <span class="tok-number">0</span>)</span>
<span class="line" id="L2694">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound;</span>
<span class="line" id="L2695"></span>
<span class="line" id="L2696">            <span class="tok-kw">const</span> argv0 = mem.span(os.argv[<span class="tok-number">0</span>]);</span>
<span class="line" id="L2697">            <span class="tok-kw">if</span> (mem.indexOf(<span class="tok-type">u8</span>, argv0, <span class="tok-str">&quot;/&quot;</span>) != <span class="tok-null">null</span>) {</span>
<span class="line" id="L2698">                <span class="tok-comment">// argv[0] is a path (relative or absolute): use realpath(3) directly</span>
</span>
<span class="line" id="L2699">                <span class="tok-kw">var</span> real_path_buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2700">                <span class="tok-kw">const</span> real_path = <span class="tok-kw">try</span> os.realpathZ(os.argv[<span class="tok-number">0</span>], &amp;real_path_buf);</span>
<span class="line" id="L2701">                <span class="tok-kw">if</span> (real_path.len &gt; out_buffer.len)</span>
<span class="line" id="L2702">                    <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L2703">                mem.copy(<span class="tok-type">u8</span>, out_buffer, real_path);</span>
<span class="line" id="L2704">                <span class="tok-kw">return</span> out_buffer[<span class="tok-number">0</span>..real_path.len];</span>
<span class="line" id="L2705">            } <span class="tok-kw">else</span> <span class="tok-kw">if</span> (argv0.len != <span class="tok-number">0</span>) {</span>
<span class="line" id="L2706">                <span class="tok-comment">// argv[0] is not empty (and not a path): search it inside PATH</span>
</span>
<span class="line" id="L2707">                <span class="tok-kw">const</span> PATH = std.os.getenvZ(<span class="tok-str">&quot;PATH&quot;</span>) <span class="tok-kw">orelse</span> <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound;</span>
<span class="line" id="L2708">                <span class="tok-kw">var</span> path_it = mem.tokenize(<span class="tok-type">u8</span>, PATH, &amp;[_]<span class="tok-type">u8</span>{path.delimiter});</span>
<span class="line" id="L2709">                <span class="tok-kw">while</span> (path_it.next()) |a_path| {</span>
<span class="line" id="L2710">                    <span class="tok-kw">var</span> resolved_path_buf: [MAX_PATH_BYTES - <span class="tok-number">1</span>:<span class="tok-number">0</span>]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2711">                    <span class="tok-kw">const</span> resolved_path = std.fmt.bufPrintZ(&amp;resolved_path_buf, <span class="tok-str">&quot;{s}/{s}&quot;</span>, .{</span>
<span class="line" id="L2712">                        a_path,</span>
<span class="line" id="L2713">                        os.argv[<span class="tok-number">0</span>],</span>
<span class="line" id="L2714">                    }) <span class="tok-kw">catch</span> <span class="tok-kw">continue</span>;</span>
<span class="line" id="L2715"></span>
<span class="line" id="L2716">                    <span class="tok-kw">var</span> real_path_buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2717">                    <span class="tok-kw">if</span> (os.realpathZ(resolved_path, &amp;real_path_buf)) |real_path| {</span>
<span class="line" id="L2718">                        <span class="tok-comment">// found a file, and hope it is the right file</span>
</span>
<span class="line" id="L2719">                        <span class="tok-kw">if</span> (real_path.len &gt; out_buffer.len)</span>
<span class="line" id="L2720">                            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NameTooLong;</span>
<span class="line" id="L2721">                        mem.copy(<span class="tok-type">u8</span>, out_buffer, real_path);</span>
<span class="line" id="L2722">                        <span class="tok-kw">return</span> out_buffer[<span class="tok-number">0</span>..real_path.len];</span>
<span class="line" id="L2723">                    } <span class="tok-kw">else</span> |_| <span class="tok-kw">continue</span>;</span>
<span class="line" id="L2724">                }</span>
<span class="line" id="L2725">            }</span>
<span class="line" id="L2726">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileNotFound;</span>
<span class="line" id="L2727">        },</span>
<span class="line" id="L2728">        .windows =&gt; {</span>
<span class="line" id="L2729">            <span class="tok-kw">const</span> utf16le_slice = selfExePathW();</span>
<span class="line" id="L2730">            <span class="tok-comment">// Trust that Windows gives us valid UTF-16LE.</span>
</span>
<span class="line" id="L2731">            <span class="tok-kw">const</span> end_index = std.unicode.utf16leToUtf8(out_buffer, utf16le_slice) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L2732">            <span class="tok-kw">return</span> out_buffer[<span class="tok-number">0</span>..end_index];</span>
<span class="line" id="L2733">        },</span>
<span class="line" id="L2734">        .wasi =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;std.fs.selfExePath not supported for WASI. Use std.fs.selfExePathAlloc instead.&quot;</span>),</span>
<span class="line" id="L2735">        <span class="tok-kw">else</span> =&gt; <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;std.fs.selfExePath not supported for this target&quot;</span>),</span>
<span class="line" id="L2736">    }</span>
<span class="line" id="L2737">}</span>
<span class="line" id="L2738"></span>
<span class="line" id="L2739"><span class="tok-comment">/// The result is UTF16LE-encoded.</span></span>
<span class="line" id="L2740"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">selfExePathW</span>() [:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span> {</span>
<span class="line" id="L2741">    <span class="tok-kw">const</span> image_path_name = &amp;os.windows.peb().ProcessParameters.ImagePathName;</span>
<span class="line" id="L2742">    <span class="tok-kw">return</span> mem.sliceTo(std.meta.assumeSentinel(image_path_name.Buffer, <span class="tok-number">0</span>), <span class="tok-number">0</span>);</span>
<span class="line" id="L2743">}</span>
<span class="line" id="L2744"></span>
<span class="line" id="L2745"><span class="tok-comment">/// `selfExeDirPath` except allocates the result on the heap.</span></span>
<span class="line" id="L2746"><span class="tok-comment">/// Caller owns returned memory.</span></span>
<span class="line" id="L2747"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">selfExeDirPathAlloc</span>(allocator: Allocator) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L2748">    <span class="tok-comment">// Use of MAX_PATH_BYTES here is justified as, at least on one tested Linux</span>
</span>
<span class="line" id="L2749">    <span class="tok-comment">// system, readlink will completely fail to return a result larger than</span>
</span>
<span class="line" id="L2750">    <span class="tok-comment">// PATH_MAX even if given a sufficiently large buffer. This makes it</span>
</span>
<span class="line" id="L2751">    <span class="tok-comment">// fundamentally impossible to get the selfExeDirPath of a program running</span>
</span>
<span class="line" id="L2752">    <span class="tok-comment">// in a very deeply nested directory chain in this way.</span>
</span>
<span class="line" id="L2753">    <span class="tok-comment">// TODO(#4812): Investigate other systems and whether it is possible to get</span>
</span>
<span class="line" id="L2754">    <span class="tok-comment">// this path by trying larger and larger buffers until one succeeds.</span>
</span>
<span class="line" id="L2755">    <span class="tok-kw">var</span> buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2756">    <span class="tok-kw">return</span> allocator.dupe(<span class="tok-type">u8</span>, <span class="tok-kw">try</span> selfExeDirPath(&amp;buf));</span>
<span class="line" id="L2757">}</span>
<span class="line" id="L2758"></span>
<span class="line" id="L2759"><span class="tok-comment">/// Get the directory path that contains the current executable.</span></span>
<span class="line" id="L2760"><span class="tok-comment">/// Returned value is a slice of out_buffer.</span></span>
<span class="line" id="L2761"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">selfExeDirPath</span>(out_buffer: []<span class="tok-type">u8</span>) SelfExePathError![]<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L2762">    <span class="tok-kw">const</span> self_exe_path = <span class="tok-kw">try</span> selfExePath(out_buffer);</span>
<span class="line" id="L2763">    <span class="tok-comment">// Assume that the OS APIs return absolute paths, and therefore dirname</span>
</span>
<span class="line" id="L2764">    <span class="tok-comment">// will not return null.</span>
</span>
<span class="line" id="L2765">    <span class="tok-kw">return</span> path.dirname(self_exe_path).?;</span>
<span class="line" id="L2766">}</span>
<span class="line" id="L2767"></span>
<span class="line" id="L2768"><span class="tok-comment">/// `realpath`, except caller must free the returned memory.</span></span>
<span class="line" id="L2769"><span class="tok-comment">/// See also `Dir.realpath`.</span></span>
<span class="line" id="L2770"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">realpathAlloc</span>(allocator: Allocator, pathname: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) ![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L2771">    <span class="tok-comment">// Use of MAX_PATH_BYTES here is valid as the realpath function does not</span>
</span>
<span class="line" id="L2772">    <span class="tok-comment">// have a variant that takes an arbitrary-size buffer.</span>
</span>
<span class="line" id="L2773">    <span class="tok-comment">// TODO(#4812): Consider reimplementing realpath or using the POSIX.1-2008</span>
</span>
<span class="line" id="L2774">    <span class="tok-comment">// NULL out parameter (GNU's canonicalize_file_name) to handle overelong</span>
</span>
<span class="line" id="L2775">    <span class="tok-comment">// paths. musl supports passing NULL but restricts the output to PATH_MAX</span>
</span>
<span class="line" id="L2776">    <span class="tok-comment">// anyway.</span>
</span>
<span class="line" id="L2777">    <span class="tok-kw">var</span> buf: [MAX_PATH_BYTES]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L2778">    <span class="tok-kw">return</span> allocator.dupe(<span class="tok-type">u8</span>, <span class="tok-kw">try</span> os.realpath(pathname, &amp;buf));</span>
<span class="line" id="L2779">}</span>
<span class="line" id="L2780"></span>
<span class="line" id="L2781"><span class="tok-kw">const</span> CopyFileRawError = <span class="tok-kw">error</span>{SystemResources} || os.CopyFileRangeError || os.SendFileError;</span>
<span class="line" id="L2782"></span>
<span class="line" id="L2783"><span class="tok-comment">// Transfer all the data between two file descriptors in the most efficient way.</span>
</span>
<span class="line" id="L2784"><span class="tok-comment">// The copy starts at offset 0, the initial offsets are preserved.</span>
</span>
<span class="line" id="L2785"><span class="tok-comment">// No metadata is transferred over.</span>
</span>
<span class="line" id="L2786"><span class="tok-kw">fn</span> <span class="tok-fn">copy_file</span>(fd_in: os.fd_t, fd_out: os.fd_t) CopyFileRawError!<span class="tok-type">void</span> {</span>
<span class="line" id="L2787">    <span class="tok-kw">if</span> (<span class="tok-kw">comptime</span> builtin.target.isDarwin()) {</span>
<span class="line" id="L2788">        <span class="tok-kw">const</span> rc = os.system.fcopyfile(fd_in, fd_out, <span class="tok-null">null</span>, os.system.COPYFILE_DATA);</span>
<span class="line" id="L2789">        <span class="tok-kw">switch</span> (os.errno(rc)) {</span>
<span class="line" id="L2790">            .SUCCESS =&gt; <span class="tok-kw">return</span>,</span>
<span class="line" id="L2791">            .INVAL =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L2792">            .NOMEM =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SystemResources,</span>
<span class="line" id="L2793">            <span class="tok-comment">// The source file is not a directory, symbolic link, or regular file.</span>
</span>
<span class="line" id="L2794">            <span class="tok-comment">// Try with the fallback path before giving up.</span>
</span>
<span class="line" id="L2795">            .OPNOTSUPP =&gt; {},</span>
<span class="line" id="L2796">            <span class="tok-kw">else</span> =&gt; |err| <span class="tok-kw">return</span> os.unexpectedErrno(err),</span>
<span class="line" id="L2797">        }</span>
<span class="line" id="L2798">    }</span>
<span class="line" id="L2799"></span>
<span class="line" id="L2800">    <span class="tok-kw">if</span> (builtin.os.tag == .linux) {</span>
<span class="line" id="L2801">        <span class="tok-comment">// Try copy_file_range first as that works at the FS level and is the</span>
</span>
<span class="line" id="L2802">        <span class="tok-comment">// most efficient method (if available).</span>
</span>
<span class="line" id="L2803">        <span class="tok-kw">var</span> offset: <span class="tok-type">u64</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2804">        cfr_loop: <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L2805">            <span class="tok-comment">// The kernel checks the u64 value `offset+count` for overflow, use</span>
</span>
<span class="line" id="L2806">            <span class="tok-comment">// a 32 bit value so that the syscall won't return EINVAL except for</span>
</span>
<span class="line" id="L2807">            <span class="tok-comment">// impossibly large files (&gt; 2^64-1 - 2^32-1).</span>
</span>
<span class="line" id="L2808">            <span class="tok-kw">const</span> amt = <span class="tok-kw">try</span> os.copy_file_range(fd_in, offset, fd_out, offset, math.maxInt(<span class="tok-type">u32</span>), <span class="tok-number">0</span>);</span>
<span class="line" id="L2809">            <span class="tok-comment">// Terminate when no data was copied</span>
</span>
<span class="line" id="L2810">            <span class="tok-kw">if</span> (amt == <span class="tok-number">0</span>) <span class="tok-kw">break</span> :cfr_loop;</span>
<span class="line" id="L2811">            offset += amt;</span>
<span class="line" id="L2812">        }</span>
<span class="line" id="L2813">        <span class="tok-kw">return</span>;</span>
<span class="line" id="L2814">    }</span>
<span class="line" id="L2815"></span>
<span class="line" id="L2816">    <span class="tok-comment">// Sendfile is a zero-copy mechanism iff the OS supports it, otherwise the</span>
</span>
<span class="line" id="L2817">    <span class="tok-comment">// fallback code will copy the contents chunk by chunk.</span>
</span>
<span class="line" id="L2818">    <span class="tok-kw">const</span> empty_iovec = [<span class="tok-number">0</span>]os.iovec_const{};</span>
<span class="line" id="L2819">    <span class="tok-kw">var</span> offset: <span class="tok-type">u64</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L2820">    sendfile_loop: <span class="tok-kw">while</span> (<span class="tok-null">true</span>) {</span>
<span class="line" id="L2821">        <span class="tok-kw">const</span> amt = <span class="tok-kw">try</span> os.sendfile(fd_out, fd_in, offset, <span class="tok-number">0</span>, &amp;empty_iovec, &amp;empty_iovec, <span class="tok-number">0</span>);</span>
<span class="line" id="L2822">        <span class="tok-comment">// Terminate when no data was copied</span>
</span>
<span class="line" id="L2823">        <span class="tok-kw">if</span> (amt == <span class="tok-number">0</span>) <span class="tok-kw">break</span> :sendfile_loop;</span>
<span class="line" id="L2824">        offset += amt;</span>
<span class="line" id="L2825">    }</span>
<span class="line" id="L2826">}</span>
<span class="line" id="L2827"></span>
<span class="line" id="L2828"><span class="tok-kw">test</span> {</span>
<span class="line" id="L2829">    <span class="tok-kw">if</span> (builtin.os.tag != .wasi) {</span>
<span class="line" id="L2830">        _ = makeDirAbsolute;</span>
<span class="line" id="L2831">        _ = makeDirAbsoluteZ;</span>
<span class="line" id="L2832">        _ = copyFileAbsolute;</span>
<span class="line" id="L2833">        _ = updateFileAbsolute;</span>
<span class="line" id="L2834">    }</span>
<span class="line" id="L2835">    _ = Dir.copyFile;</span>
<span class="line" id="L2836">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;fs/test.zig&quot;</span>);</span>
<span class="line" id="L2837">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;fs/path.zig&quot;</span>);</span>
<span class="line" id="L2838">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;fs/file.zig&quot;</span>);</span>
<span class="line" id="L2839">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;fs/get_app_data_dir.zig&quot;</span>);</span>
<span class="line" id="L2840">    _ = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;fs/watch.zig&quot;</span>);</span>
<span class="line" id="L2841">}</span>
<span class="line" id="L2842"></span>
</code></pre></body>
</html>