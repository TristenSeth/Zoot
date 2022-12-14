<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/wasi.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">// wasi_snapshot_preview1 spec available (in witx format) here:</span>
</span>
<span class="line" id="L2"><span class="tok-comment">// * typenames -- https://github.com/WebAssembly/WASI/blob/master/phases/snapshot/witx/typenames.witx</span>
</span>
<span class="line" id="L3"><span class="tok-comment">// * module -- https://github.com/WebAssembly/WASI/blob/master/phases/snapshot/witx/wasi_snapshot_preview1.witx</span>
</span>
<span class="line" id="L4"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L5"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">comptime</span> {</span>
<span class="line" id="L8">    assert(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">i8</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L9">    assert(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u8</span>) == <span class="tok-number">1</span>);</span>
<span class="line" id="L10">    assert(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">i16</span>) == <span class="tok-number">2</span>);</span>
<span class="line" id="L11">    assert(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u16</span>) == <span class="tok-number">2</span>);</span>
<span class="line" id="L12">    assert(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">i32</span>) == <span class="tok-number">4</span>);</span>
<span class="line" id="L13">    assert(<span class="tok-builtin">@alignOf</span>(<span class="tok-type">u32</span>) == <span class="tok-number">4</span>);</span>
<span class="line" id="L14">    <span class="tok-comment">// assert(@alignOf(i64) == 8);</span>
</span>
<span class="line" id="L15">    <span class="tok-comment">// assert(@alignOf(u64) == 8);</span>
</span>
<span class="line" id="L16">}</span>
<span class="line" id="L17"></span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> F_OK = <span class="tok-number">0</span>;</span>
<span class="line" id="L19"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> X_OK = <span class="tok-number">1</span>;</span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> W_OK = <span class="tok-number">2</span>;</span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> R_OK = <span class="tok-number">4</span>;</span>
<span class="line" id="L22"></span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> iovec_t = std.os.iovec;</span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ciovec_t = std.os.iovec_const;</span>
<span class="line" id="L25"></span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">args_get</span>(argv: [*][*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, argv_buf: [*]<span class="tok-type">u8</span>) errno_t;</span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">args_sizes_get</span>(argc: *<span class="tok-type">usize</span>, argv_buf_size: *<span class="tok-type">usize</span>) errno_t;</span>
<span class="line" id="L28"></span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">clock_res_get</span>(clock_id: clockid_t, resolution: *timestamp_t) errno_t;</span>
<span class="line" id="L30"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">clock_time_get</span>(clock_id: clockid_t, precision: timestamp_t, timestamp: *timestamp_t) errno_t;</span>
<span class="line" id="L31"></span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">environ_get</span>(environ: [*][*:<span class="tok-number">0</span>]<span class="tok-type">u8</span>, environ_buf: [*]<span class="tok-type">u8</span>) errno_t;</span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">environ_sizes_get</span>(environ_count: *<span class="tok-type">usize</span>, environ_buf_size: *<span class="tok-type">usize</span>) errno_t;</span>
<span class="line" id="L34"></span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_advise</span>(fd: fd_t, offset: filesize_t, len: filesize_t, advice: advice_t) errno_t;</span>
<span class="line" id="L36"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_allocate</span>(fd: fd_t, offset: filesize_t, len: filesize_t) errno_t;</span>
<span class="line" id="L37"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_close</span>(fd: fd_t) errno_t;</span>
<span class="line" id="L38"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_datasync</span>(fd: fd_t) errno_t;</span>
<span class="line" id="L39"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_pread</span>(fd: fd_t, iovs: [*]<span class="tok-kw">const</span> iovec_t, iovs_len: <span class="tok-type">usize</span>, offset: filesize_t, nread: *<span class="tok-type">usize</span>) errno_t;</span>
<span class="line" id="L40"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_pwrite</span>(fd: fd_t, iovs: [*]<span class="tok-kw">const</span> ciovec_t, iovs_len: <span class="tok-type">usize</span>, offset: filesize_t, nwritten: *<span class="tok-type">usize</span>) errno_t;</span>
<span class="line" id="L41"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_read</span>(fd: fd_t, iovs: [*]<span class="tok-kw">const</span> iovec_t, iovs_len: <span class="tok-type">usize</span>, nread: *<span class="tok-type">usize</span>) errno_t;</span>
<span class="line" id="L42"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_readdir</span>(fd: fd_t, buf: [*]<span class="tok-type">u8</span>, buf_len: <span class="tok-type">usize</span>, cookie: dircookie_t, bufused: *<span class="tok-type">usize</span>) errno_t;</span>
<span class="line" id="L43"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_renumber</span>(from: fd_t, to: fd_t) errno_t;</span>
<span class="line" id="L44"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_seek</span>(fd: fd_t, offset: filedelta_t, whence: whence_t, newoffset: *filesize_t) errno_t;</span>
<span class="line" id="L45"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_sync</span>(fd: fd_t) errno_t;</span>
<span class="line" id="L46"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_tell</span>(fd: fd_t, newoffset: *filesize_t) errno_t;</span>
<span class="line" id="L47"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_write</span>(fd: fd_t, iovs: [*]<span class="tok-kw">const</span> ciovec_t, iovs_len: <span class="tok-type">usize</span>, nwritten: *<span class="tok-type">usize</span>) errno_t;</span>
<span class="line" id="L48"></span>
<span class="line" id="L49"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_fdstat_get</span>(fd: fd_t, buf: *fdstat_t) errno_t;</span>
<span class="line" id="L50"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_fdstat_set_flags</span>(fd: fd_t, flags: fdflags_t) errno_t;</span>
<span class="line" id="L51"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_fdstat_set_rights</span>(fd: fd_t, fs_rights_base: rights_t, fs_rights_inheriting: rights_t) errno_t;</span>
<span class="line" id="L52"></span>
<span class="line" id="L53"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_filestat_get</span>(fd: fd_t, buf: *filestat_t) errno_t;</span>
<span class="line" id="L54"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_filestat_set_size</span>(fd: fd_t, st_size: filesize_t) errno_t;</span>
<span class="line" id="L55"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_filestat_set_times</span>(fd: fd_t, st_atim: timestamp_t, st_mtim: timestamp_t, fstflags: fstflags_t) errno_t;</span>
<span class="line" id="L56"></span>
<span class="line" id="L57"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_prestat_get</span>(fd: fd_t, buf: *prestat_t) errno_t;</span>
<span class="line" id="L58"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">fd_prestat_dir_name</span>(fd: fd_t, path: [*]<span class="tok-type">u8</span>, path_len: <span class="tok-type">usize</span>) errno_t;</span>
<span class="line" id="L59"></span>
<span class="line" id="L60"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">path_create_directory</span>(fd: fd_t, path: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, path_len: <span class="tok-type">usize</span>) errno_t;</span>
<span class="line" id="L61"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">path_filestat_get</span>(fd: fd_t, flags: lookupflags_t, path: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, path_len: <span class="tok-type">usize</span>, buf: *filestat_t) errno_t;</span>
<span class="line" id="L62"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">path_filestat_set_times</span>(fd: fd_t, flags: lookupflags_t, path: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, path_len: <span class="tok-type">usize</span>, st_atim: timestamp_t, st_mtim: timestamp_t, fstflags: fstflags_t) errno_t;</span>
<span class="line" id="L63"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">path_link</span>(old_fd: fd_t, old_flags: lookupflags_t, old_path: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, old_path_len: <span class="tok-type">usize</span>, new_fd: fd_t, new_path: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, new_path_len: <span class="tok-type">usize</span>) errno_t;</span>
<span class="line" id="L64"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">path_open</span>(dirfd: fd_t, dirflags: lookupflags_t, path: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, path_len: <span class="tok-type">usize</span>, oflags: oflags_t, fs_rights_base: rights_t, fs_rights_inheriting: rights_t, fs_flags: fdflags_t, fd: *fd_t) errno_t;</span>
<span class="line" id="L65"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">path_readlink</span>(fd: fd_t, path: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, path_len: <span class="tok-type">usize</span>, buf: [*]<span class="tok-type">u8</span>, buf_len: <span class="tok-type">usize</span>, bufused: *<span class="tok-type">usize</span>) errno_t;</span>
<span class="line" id="L66"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">path_remove_directory</span>(fd: fd_t, path: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, path_len: <span class="tok-type">usize</span>) errno_t;</span>
<span class="line" id="L67"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">path_rename</span>(old_fd: fd_t, old_path: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, old_path_len: <span class="tok-type">usize</span>, new_fd: fd_t, new_path: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, new_path_len: <span class="tok-type">usize</span>) errno_t;</span>
<span class="line" id="L68"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">path_symlink</span>(old_path: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, old_path_len: <span class="tok-type">usize</span>, fd: fd_t, new_path: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, new_path_len: <span class="tok-type">usize</span>) errno_t;</span>
<span class="line" id="L69"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">path_unlink_file</span>(fd: fd_t, path: [*]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, path_len: <span class="tok-type">usize</span>) errno_t;</span>
<span class="line" id="L70"></span>
<span class="line" id="L71"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">poll_oneoff</span>(in: *<span class="tok-kw">const</span> subscription_t, out: *event_t, nsubscriptions: <span class="tok-type">usize</span>, nevents: *<span class="tok-type">usize</span>) errno_t;</span>
<span class="line" id="L72"></span>
<span class="line" id="L73"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">proc_exit</span>(rval: exitcode_t) <span class="tok-type">noreturn</span>;</span>
<span class="line" id="L74"></span>
<span class="line" id="L75"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">random_get</span>(buf: [*]<span class="tok-type">u8</span>, buf_len: <span class="tok-type">usize</span>) errno_t;</span>
<span class="line" id="L76"></span>
<span class="line" id="L77"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sched_yield</span>() errno_t;</span>
<span class="line" id="L78"></span>
<span class="line" id="L79"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sock_recv</span>(sock: fd_t, ri_data: *<span class="tok-kw">const</span> iovec_t, ri_data_len: <span class="tok-type">usize</span>, ri_flags: riflags_t, ro_datalen: *<span class="tok-type">usize</span>, ro_flags: *roflags_t) errno_t;</span>
<span class="line" id="L80"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sock_send</span>(sock: fd_t, si_data: *<span class="tok-kw">const</span> ciovec_t, si_data_len: <span class="tok-type">usize</span>, si_flags: siflags_t, so_datalen: *<span class="tok-type">usize</span>) errno_t;</span>
<span class="line" id="L81"><span class="tok-kw">pub</span> <span class="tok-kw">extern</span> <span class="tok-str">&quot;wasi_snapshot_preview1&quot;</span> <span class="tok-kw">fn</span> <span class="tok-fn">sock_shutdown</span>(sock: fd_t, how: sdflags_t) errno_t;</span>
<span class="line" id="L82"></span>
<span class="line" id="L83"><span class="tok-comment">/// Get the errno from a syscall return value, or 0 for no error.</span></span>
<span class="line" id="L84"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getErrno</span>(r: errno_t) errno_t {</span>
<span class="line" id="L85">    <span class="tok-kw">return</span> r;</span>
<span class="line" id="L86">}</span>
<span class="line" id="L87"></span>
<span class="line" id="L88"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STDIN_FILENO = <span class="tok-number">0</span>;</span>
<span class="line" id="L89"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STDOUT_FILENO = <span class="tok-number">1</span>;</span>
<span class="line" id="L90"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> STDERR_FILENO = <span class="tok-number">2</span>;</span>
<span class="line" id="L91"></span>
<span class="line" id="L92"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> mode_t = <span class="tok-type">u32</span>;</span>
<span class="line" id="L93"></span>
<span class="line" id="L94"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> time_t = <span class="tok-type">i64</span>; <span class="tok-comment">// match https://github.com/CraneStation/wasi-libc</span>
</span>
<span class="line" id="L95"></span>
<span class="line" id="L96"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> timespec = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L97">    tv_sec: time_t,</span>
<span class="line" id="L98">    tv_nsec: <span class="tok-type">isize</span>,</span>
<span class="line" id="L99"></span>
<span class="line" id="L100">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromTimestamp</span>(tm: timestamp_t) timespec {</span>
<span class="line" id="L101">        <span class="tok-kw">const</span> tv_sec: timestamp_t = tm / <span class="tok-number">1_000_000_000</span>;</span>
<span class="line" id="L102">        <span class="tok-kw">const</span> tv_nsec = tm - tv_sec * <span class="tok-number">1_000_000_000</span>;</span>
<span class="line" id="L103">        <span class="tok-kw">return</span> timespec{</span>
<span class="line" id="L104">            .tv_sec = <span class="tok-builtin">@intCast</span>(time_t, tv_sec),</span>
<span class="line" id="L105">            .tv_nsec = <span class="tok-builtin">@intCast</span>(<span class="tok-type">isize</span>, tv_nsec),</span>
<span class="line" id="L106">        };</span>
<span class="line" id="L107">    }</span>
<span class="line" id="L108"></span>
<span class="line" id="L109">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toTimestamp</span>(ts: timespec) timestamp_t {</span>
<span class="line" id="L110">        <span class="tok-kw">const</span> tm = <span class="tok-builtin">@intCast</span>(timestamp_t, ts.tv_sec * <span class="tok-number">1_000_000_000</span>) + <span class="tok-builtin">@intCast</span>(timestamp_t, ts.tv_nsec);</span>
<span class="line" id="L111">        <span class="tok-kw">return</span> tm;</span>
<span class="line" id="L112">    }</span>
<span class="line" id="L113">};</span>
<span class="line" id="L114"></span>
<span class="line" id="L115"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Stat = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L116">    dev: device_t,</span>
<span class="line" id="L117">    ino: inode_t,</span>
<span class="line" id="L118">    mode: mode_t,</span>
<span class="line" id="L119">    filetype: filetype_t,</span>
<span class="line" id="L120">    nlink: linkcount_t,</span>
<span class="line" id="L121">    size: filesize_t,</span>
<span class="line" id="L122">    atim: timespec,</span>
<span class="line" id="L123">    mtim: timespec,</span>
<span class="line" id="L124">    ctim: timespec,</span>
<span class="line" id="L125"></span>
<span class="line" id="L126">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L127"></span>
<span class="line" id="L128">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fromFilestat</span>(stat: filestat_t) Self {</span>
<span class="line" id="L129">        <span class="tok-kw">return</span> Self{</span>
<span class="line" id="L130">            .dev = stat.dev,</span>
<span class="line" id="L131">            .ino = stat.ino,</span>
<span class="line" id="L132">            .mode = <span class="tok-number">0</span>,</span>
<span class="line" id="L133">            .filetype = stat.filetype,</span>
<span class="line" id="L134">            .nlink = stat.nlink,</span>
<span class="line" id="L135">            .size = stat.size,</span>
<span class="line" id="L136">            .atim = stat.atime(),</span>
<span class="line" id="L137">            .mtim = stat.mtime(),</span>
<span class="line" id="L138">            .ctim = stat.ctime(),</span>
<span class="line" id="L139">        };</span>
<span class="line" id="L140">    }</span>
<span class="line" id="L141"></span>
<span class="line" id="L142">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">atime</span>(self: Self) timespec {</span>
<span class="line" id="L143">        <span class="tok-kw">return</span> self.atim;</span>
<span class="line" id="L144">    }</span>
<span class="line" id="L145"></span>
<span class="line" id="L146">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mtime</span>(self: Self) timespec {</span>
<span class="line" id="L147">        <span class="tok-kw">return</span> self.mtim;</span>
<span class="line" id="L148">    }</span>
<span class="line" id="L149"></span>
<span class="line" id="L150">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ctime</span>(self: Self) timespec {</span>
<span class="line" id="L151">        <span class="tok-kw">return</span> self.ctim;</span>
<span class="line" id="L152">    }</span>
<span class="line" id="L153">};</span>
<span class="line" id="L154"></span>
<span class="line" id="L155"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IOV_MAX = <span class="tok-number">1024</span>;</span>
<span class="line" id="L156"></span>
<span class="line" id="L157"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AT = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L158">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REMOVEDIR: <span class="tok-type">u32</span> = <span class="tok-number">0x4</span>;</span>
<span class="line" id="L159">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FDCWD: fd_t = -<span class="tok-number">2</span>;</span>
<span class="line" id="L160">};</span>
<span class="line" id="L161"></span>
<span class="line" id="L162"><span class="tok-comment">// As defined in the wasi_snapshot_preview1 spec file:</span>
</span>
<span class="line" id="L163"><span class="tok-comment">// https://github.com/WebAssembly/WASI/blob/master/phases/snapshot/witx/typenames.witx</span>
</span>
<span class="line" id="L164"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> advice_t = <span class="tok-type">u8</span>;</span>
<span class="line" id="L165"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ADVICE_NORMAL: advice_t = <span class="tok-number">0</span>;</span>
<span class="line" id="L166"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ADVICE_SEQUENTIAL: advice_t = <span class="tok-number">1</span>;</span>
<span class="line" id="L167"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ADVICE_RANDOM: advice_t = <span class="tok-number">2</span>;</span>
<span class="line" id="L168"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ADVICE_WILLNEED: advice_t = <span class="tok-number">3</span>;</span>
<span class="line" id="L169"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ADVICE_DONTNEED: advice_t = <span class="tok-number">4</span>;</span>
<span class="line" id="L170"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ADVICE_NOREUSE: advice_t = <span class="tok-number">5</span>;</span>
<span class="line" id="L171"></span>
<span class="line" id="L172"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> clockid_t = <span class="tok-type">u32</span>;</span>
<span class="line" id="L173"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CLOCK = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L174">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> REALTIME: clockid_t = <span class="tok-number">0</span>;</span>
<span class="line" id="L175">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> MONOTONIC: clockid_t = <span class="tok-number">1</span>;</span>
<span class="line" id="L176">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PROCESS_CPUTIME_ID: clockid_t = <span class="tok-number">2</span>;</span>
<span class="line" id="L177">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> THREAD_CPUTIME_ID: clockid_t = <span class="tok-number">3</span>;</span>
<span class="line" id="L178">};</span>
<span class="line" id="L179"></span>
<span class="line" id="L180"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> device_t = <span class="tok-type">u64</span>;</span>
<span class="line" id="L181"></span>
<span class="line" id="L182"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> dircookie_t = <span class="tok-type">u64</span>;</span>
<span class="line" id="L183"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DIRCOOKIE_START: dircookie_t = <span class="tok-number">0</span>;</span>
<span class="line" id="L184"></span>
<span class="line" id="L185"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> dirnamlen_t = <span class="tok-type">u32</span>;</span>
<span class="line" id="L186"></span>
<span class="line" id="L187"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> dirent_t = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L188">    d_next: dircookie_t,</span>
<span class="line" id="L189">    d_ino: inode_t,</span>
<span class="line" id="L190">    d_namlen: dirnamlen_t,</span>
<span class="line" id="L191">    d_type: filetype_t,</span>
<span class="line" id="L192">};</span>
<span class="line" id="L193"></span>
<span class="line" id="L194"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> errno_t = <span class="tok-kw">enum</span>(<span class="tok-type">u16</span>) {</span>
<span class="line" id="L195">    SUCCESS = <span class="tok-number">0</span>,</span>
<span class="line" id="L196">    @&quot;2BIG&quot; = <span class="tok-number">1</span>,</span>
<span class="line" id="L197">    ACCES = <span class="tok-number">2</span>,</span>
<span class="line" id="L198">    ADDRINUSE = <span class="tok-number">3</span>,</span>
<span class="line" id="L199">    ADDRNOTAVAIL = <span class="tok-number">4</span>,</span>
<span class="line" id="L200">    AFNOSUPPORT = <span class="tok-number">5</span>,</span>
<span class="line" id="L201">    <span class="tok-comment">/// This is also the error code used for `WOULDBLOCK`.</span></span>
<span class="line" id="L202">    AGAIN = <span class="tok-number">6</span>,</span>
<span class="line" id="L203">    ALREADY = <span class="tok-number">7</span>,</span>
<span class="line" id="L204">    BADF = <span class="tok-number">8</span>,</span>
<span class="line" id="L205">    BADMSG = <span class="tok-number">9</span>,</span>
<span class="line" id="L206">    BUSY = <span class="tok-number">10</span>,</span>
<span class="line" id="L207">    CANCELED = <span class="tok-number">11</span>,</span>
<span class="line" id="L208">    CHILD = <span class="tok-number">12</span>,</span>
<span class="line" id="L209">    CONNABORTED = <span class="tok-number">13</span>,</span>
<span class="line" id="L210">    CONNREFUSED = <span class="tok-number">14</span>,</span>
<span class="line" id="L211">    CONNRESET = <span class="tok-number">15</span>,</span>
<span class="line" id="L212">    DEADLK = <span class="tok-number">16</span>,</span>
<span class="line" id="L213">    DESTADDRREQ = <span class="tok-number">17</span>,</span>
<span class="line" id="L214">    DOM = <span class="tok-number">18</span>,</span>
<span class="line" id="L215">    DQUOT = <span class="tok-number">19</span>,</span>
<span class="line" id="L216">    EXIST = <span class="tok-number">20</span>,</span>
<span class="line" id="L217">    FAULT = <span class="tok-number">21</span>,</span>
<span class="line" id="L218">    FBIG = <span class="tok-number">22</span>,</span>
<span class="line" id="L219">    HOSTUNREACH = <span class="tok-number">23</span>,</span>
<span class="line" id="L220">    IDRM = <span class="tok-number">24</span>,</span>
<span class="line" id="L221">    ILSEQ = <span class="tok-number">25</span>,</span>
<span class="line" id="L222">    INPROGRESS = <span class="tok-number">26</span>,</span>
<span class="line" id="L223">    INTR = <span class="tok-number">27</span>,</span>
<span class="line" id="L224">    INVAL = <span class="tok-number">28</span>,</span>
<span class="line" id="L225">    IO = <span class="tok-number">29</span>,</span>
<span class="line" id="L226">    ISCONN = <span class="tok-number">30</span>,</span>
<span class="line" id="L227">    ISDIR = <span class="tok-number">31</span>,</span>
<span class="line" id="L228">    LOOP = <span class="tok-number">32</span>,</span>
<span class="line" id="L229">    MFILE = <span class="tok-number">33</span>,</span>
<span class="line" id="L230">    MLINK = <span class="tok-number">34</span>,</span>
<span class="line" id="L231">    MSGSIZE = <span class="tok-number">35</span>,</span>
<span class="line" id="L232">    MULTIHOP = <span class="tok-number">36</span>,</span>
<span class="line" id="L233">    NAMETOOLONG = <span class="tok-number">37</span>,</span>
<span class="line" id="L234">    NETDOWN = <span class="tok-number">38</span>,</span>
<span class="line" id="L235">    NETRESET = <span class="tok-number">39</span>,</span>
<span class="line" id="L236">    NETUNREACH = <span class="tok-number">40</span>,</span>
<span class="line" id="L237">    NFILE = <span class="tok-number">41</span>,</span>
<span class="line" id="L238">    NOBUFS = <span class="tok-number">42</span>,</span>
<span class="line" id="L239">    NODEV = <span class="tok-number">43</span>,</span>
<span class="line" id="L240">    NOENT = <span class="tok-number">44</span>,</span>
<span class="line" id="L241">    NOEXEC = <span class="tok-number">45</span>,</span>
<span class="line" id="L242">    NOLCK = <span class="tok-number">46</span>,</span>
<span class="line" id="L243">    NOLINK = <span class="tok-number">47</span>,</span>
<span class="line" id="L244">    NOMEM = <span class="tok-number">48</span>,</span>
<span class="line" id="L245">    NOMSG = <span class="tok-number">49</span>,</span>
<span class="line" id="L246">    NOPROTOOPT = <span class="tok-number">50</span>,</span>
<span class="line" id="L247">    NOSPC = <span class="tok-number">51</span>,</span>
<span class="line" id="L248">    NOSYS = <span class="tok-number">52</span>,</span>
<span class="line" id="L249">    NOTCONN = <span class="tok-number">53</span>,</span>
<span class="line" id="L250">    NOTDIR = <span class="tok-number">54</span>,</span>
<span class="line" id="L251">    NOTEMPTY = <span class="tok-number">55</span>,</span>
<span class="line" id="L252">    NOTRECOVERABLE = <span class="tok-number">56</span>,</span>
<span class="line" id="L253">    NOTSOCK = <span class="tok-number">57</span>,</span>
<span class="line" id="L254">    <span class="tok-comment">/// This is also the code used for `NOTSUP`.</span></span>
<span class="line" id="L255">    OPNOTSUPP = <span class="tok-number">58</span>,</span>
<span class="line" id="L256">    NOTTY = <span class="tok-number">59</span>,</span>
<span class="line" id="L257">    NXIO = <span class="tok-number">60</span>,</span>
<span class="line" id="L258">    OVERFLOW = <span class="tok-number">61</span>,</span>
<span class="line" id="L259">    OWNERDEAD = <span class="tok-number">62</span>,</span>
<span class="line" id="L260">    PERM = <span class="tok-number">63</span>,</span>
<span class="line" id="L261">    PIPE = <span class="tok-number">64</span>,</span>
<span class="line" id="L262">    PROTO = <span class="tok-number">65</span>,</span>
<span class="line" id="L263">    PROTONOSUPPORT = <span class="tok-number">66</span>,</span>
<span class="line" id="L264">    PROTOTYPE = <span class="tok-number">67</span>,</span>
<span class="line" id="L265">    RANGE = <span class="tok-number">68</span>,</span>
<span class="line" id="L266">    ROFS = <span class="tok-number">69</span>,</span>
<span class="line" id="L267">    SPIPE = <span class="tok-number">70</span>,</span>
<span class="line" id="L268">    SRCH = <span class="tok-number">71</span>,</span>
<span class="line" id="L269">    STALE = <span class="tok-number">72</span>,</span>
<span class="line" id="L270">    TIMEDOUT = <span class="tok-number">73</span>,</span>
<span class="line" id="L271">    TXTBSY = <span class="tok-number">74</span>,</span>
<span class="line" id="L272">    XDEV = <span class="tok-number">75</span>,</span>
<span class="line" id="L273">    NOTCAPABLE = <span class="tok-number">76</span>,</span>
<span class="line" id="L274">    _,</span>
<span class="line" id="L275">};</span>
<span class="line" id="L276"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> E = errno_t;</span>
<span class="line" id="L277"></span>
<span class="line" id="L278"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> event_t = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L279">    userdata: userdata_t,</span>
<span class="line" id="L280">    @&quot;error&quot;: errno_t,</span>
<span class="line" id="L281">    @&quot;type&quot;: eventtype_t,</span>
<span class="line" id="L282">    fd_readwrite: eventfdreadwrite_t,</span>
<span class="line" id="L283">};</span>
<span class="line" id="L284"></span>
<span class="line" id="L285"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> eventfdreadwrite_t = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L286">    nbytes: filesize_t,</span>
<span class="line" id="L287">    flags: eventrwflags_t,</span>
<span class="line" id="L288">};</span>
<span class="line" id="L289"></span>
<span class="line" id="L290"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> eventrwflags_t = <span class="tok-type">u16</span>;</span>
<span class="line" id="L291"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EVENT_FD_READWRITE_HANGUP: eventrwflags_t = <span class="tok-number">0x0001</span>;</span>
<span class="line" id="L292"></span>
<span class="line" id="L293"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> eventtype_t = <span class="tok-type">u8</span>;</span>
<span class="line" id="L294"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EVENTTYPE_CLOCK: eventtype_t = <span class="tok-number">0</span>;</span>
<span class="line" id="L295"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EVENTTYPE_FD_READ: eventtype_t = <span class="tok-number">1</span>;</span>
<span class="line" id="L296"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EVENTTYPE_FD_WRITE: eventtype_t = <span class="tok-number">2</span>;</span>
<span class="line" id="L297"></span>
<span class="line" id="L298"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> exitcode_t = <span class="tok-type">u32</span>;</span>
<span class="line" id="L299"></span>
<span class="line" id="L300"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> fd_t = <span class="tok-type">i32</span>;</span>
<span class="line" id="L301"></span>
<span class="line" id="L302"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> fdflags_t = <span class="tok-type">u16</span>;</span>
<span class="line" id="L303"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FDFLAG = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L304">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> APPEND: fdflags_t = <span class="tok-number">0x0001</span>;</span>
<span class="line" id="L305">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DSYNC: fdflags_t = <span class="tok-number">0x0002</span>;</span>
<span class="line" id="L306">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NONBLOCK: fdflags_t = <span class="tok-number">0x0004</span>;</span>
<span class="line" id="L307">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RSYNC: fdflags_t = <span class="tok-number">0x0008</span>;</span>
<span class="line" id="L308">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SYNC: fdflags_t = <span class="tok-number">0x0010</span>;</span>
<span class="line" id="L309">};</span>
<span class="line" id="L310"></span>
<span class="line" id="L311"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> fdstat_t = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L312">    fs_filetype: filetype_t,</span>
<span class="line" id="L313">    fs_flags: fdflags_t,</span>
<span class="line" id="L314">    fs_rights_base: rights_t,</span>
<span class="line" id="L315">    fs_rights_inheriting: rights_t,</span>
<span class="line" id="L316">};</span>
<span class="line" id="L317"></span>
<span class="line" id="L318"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> filedelta_t = <span class="tok-type">i64</span>;</span>
<span class="line" id="L319"></span>
<span class="line" id="L320"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> filesize_t = <span class="tok-type">u64</span>;</span>
<span class="line" id="L321"></span>
<span class="line" id="L322"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> filestat_t = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L323">    dev: device_t,</span>
<span class="line" id="L324">    ino: inode_t,</span>
<span class="line" id="L325">    filetype: filetype_t,</span>
<span class="line" id="L326">    nlink: linkcount_t,</span>
<span class="line" id="L327">    size: filesize_t,</span>
<span class="line" id="L328">    atim: timestamp_t,</span>
<span class="line" id="L329">    mtim: timestamp_t,</span>
<span class="line" id="L330">    ctim: timestamp_t,</span>
<span class="line" id="L331"></span>
<span class="line" id="L332">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">atime</span>(self: filestat_t) timespec {</span>
<span class="line" id="L333">        <span class="tok-kw">return</span> timespec.fromTimestamp(self.atim);</span>
<span class="line" id="L334">    }</span>
<span class="line" id="L335"></span>
<span class="line" id="L336">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">mtime</span>(self: filestat_t) timespec {</span>
<span class="line" id="L337">        <span class="tok-kw">return</span> timespec.fromTimestamp(self.mtim);</span>
<span class="line" id="L338">    }</span>
<span class="line" id="L339"></span>
<span class="line" id="L340">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ctime</span>(self: filestat_t) timespec {</span>
<span class="line" id="L341">        <span class="tok-kw">return</span> timespec.fromTimestamp(self.ctim);</span>
<span class="line" id="L342">    }</span>
<span class="line" id="L343">};</span>
<span class="line" id="L344"></span>
<span class="line" id="L345"><span class="tok-comment">/// Also known as `FILETYPE`.</span></span>
<span class="line" id="L346"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> filetype_t = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L347">    UNKNOWN,</span>
<span class="line" id="L348">    BLOCK_DEVICE,</span>
<span class="line" id="L349">    CHARACTER_DEVICE,</span>
<span class="line" id="L350">    DIRECTORY,</span>
<span class="line" id="L351">    REGULAR_FILE,</span>
<span class="line" id="L352">    SOCKET_DGRAM,</span>
<span class="line" id="L353">    SOCKET_STREAM,</span>
<span class="line" id="L354">    SYMBOLIC_LINK,</span>
<span class="line" id="L355">    _,</span>
<span class="line" id="L356">};</span>
<span class="line" id="L357"></span>
<span class="line" id="L358"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> fstflags_t = <span class="tok-type">u16</span>;</span>
<span class="line" id="L359"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILESTAT_SET_ATIM: fstflags_t = <span class="tok-number">0x0001</span>;</span>
<span class="line" id="L360"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILESTAT_SET_ATIM_NOW: fstflags_t = <span class="tok-number">0x0002</span>;</span>
<span class="line" id="L361"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILESTAT_SET_MTIM: fstflags_t = <span class="tok-number">0x0004</span>;</span>
<span class="line" id="L362"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FILESTAT_SET_MTIM_NOW: fstflags_t = <span class="tok-number">0x0008</span>;</span>
<span class="line" id="L363"></span>
<span class="line" id="L364"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> inode_t = <span class="tok-type">u64</span>;</span>
<span class="line" id="L365"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ino_t = inode_t;</span>
<span class="line" id="L366"></span>
<span class="line" id="L367"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> linkcount_t = <span class="tok-type">u64</span>;</span>
<span class="line" id="L368"></span>
<span class="line" id="L369"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> lookupflags_t = <span class="tok-type">u32</span>;</span>
<span class="line" id="L370"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LOOKUP_SYMLINK_FOLLOW: lookupflags_t = <span class="tok-number">0x00000001</span>;</span>
<span class="line" id="L371"></span>
<span class="line" id="L372"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> oflags_t = <span class="tok-type">u16</span>;</span>
<span class="line" id="L373"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> O = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L374">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> CREAT: oflags_t = <span class="tok-number">0x0001</span>;</span>
<span class="line" id="L375">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> DIRECTORY: oflags_t = <span class="tok-number">0x0002</span>;</span>
<span class="line" id="L376">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EXCL: oflags_t = <span class="tok-number">0x0004</span>;</span>
<span class="line" id="L377">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> TRUNC: oflags_t = <span class="tok-number">0x0008</span>;</span>
<span class="line" id="L378">};</span>
<span class="line" id="L379"></span>
<span class="line" id="L380"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> preopentype_t = <span class="tok-type">u8</span>;</span>
<span class="line" id="L381"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PREOPENTYPE_DIR: preopentype_t = <span class="tok-number">0</span>;</span>
<span class="line" id="L382"></span>
<span class="line" id="L383"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> prestat_t = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L384">    pr_type: preopentype_t,</span>
<span class="line" id="L385">    u: prestat_u_t,</span>
<span class="line" id="L386">};</span>
<span class="line" id="L387"></span>
<span class="line" id="L388"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> prestat_dir_t = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L389">    pr_name_len: <span class="tok-type">usize</span>,</span>
<span class="line" id="L390">};</span>
<span class="line" id="L391"></span>
<span class="line" id="L392"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> prestat_u_t = <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L393">    dir: prestat_dir_t,</span>
<span class="line" id="L394">};</span>
<span class="line" id="L395"></span>
<span class="line" id="L396"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> riflags_t = <span class="tok-type">u16</span>;</span>
<span class="line" id="L397"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> roflags_t = <span class="tok-type">u16</span>;</span>
<span class="line" id="L398"></span>
<span class="line" id="L399"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCK = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L400">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECV_PEEK: riflags_t = <span class="tok-number">0x0001</span>;</span>
<span class="line" id="L401">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECV_WAITALL: riflags_t = <span class="tok-number">0x0002</span>;</span>
<span class="line" id="L402"></span>
<span class="line" id="L403">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RECV_DATA_TRUNCATED: roflags_t = <span class="tok-number">0x0001</span>;</span>
<span class="line" id="L404">};</span>
<span class="line" id="L405"></span>
<span class="line" id="L406"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> rights_t = <span class="tok-type">u64</span>;</span>
<span class="line" id="L407"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RIGHT = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L408">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_DATASYNC: rights_t = <span class="tok-number">0x0000000000000001</span>;</span>
<span class="line" id="L409">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_READ: rights_t = <span class="tok-number">0x0000000000000002</span>;</span>
<span class="line" id="L410">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_SEEK: rights_t = <span class="tok-number">0x0000000000000004</span>;</span>
<span class="line" id="L411">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_FDSTAT_SET_FLAGS: rights_t = <span class="tok-number">0x0000000000000008</span>;</span>
<span class="line" id="L412">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_SYNC: rights_t = <span class="tok-number">0x0000000000000010</span>;</span>
<span class="line" id="L413">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_TELL: rights_t = <span class="tok-number">0x0000000000000020</span>;</span>
<span class="line" id="L414">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_WRITE: rights_t = <span class="tok-number">0x0000000000000040</span>;</span>
<span class="line" id="L415">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_ADVISE: rights_t = <span class="tok-number">0x0000000000000080</span>;</span>
<span class="line" id="L416">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_ALLOCATE: rights_t = <span class="tok-number">0x0000000000000100</span>;</span>
<span class="line" id="L417">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PATH_CREATE_DIRECTORY: rights_t = <span class="tok-number">0x0000000000000200</span>;</span>
<span class="line" id="L418">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PATH_CREATE_FILE: rights_t = <span class="tok-number">0x0000000000000400</span>;</span>
<span class="line" id="L419">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PATH_LINK_SOURCE: rights_t = <span class="tok-number">0x0000000000000800</span>;</span>
<span class="line" id="L420">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PATH_LINK_TARGET: rights_t = <span class="tok-number">0x0000000000001000</span>;</span>
<span class="line" id="L421">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PATH_OPEN: rights_t = <span class="tok-number">0x0000000000002000</span>;</span>
<span class="line" id="L422">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_READDIR: rights_t = <span class="tok-number">0x0000000000004000</span>;</span>
<span class="line" id="L423">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PATH_READLINK: rights_t = <span class="tok-number">0x0000000000008000</span>;</span>
<span class="line" id="L424">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PATH_RENAME_SOURCE: rights_t = <span class="tok-number">0x0000000000010000</span>;</span>
<span class="line" id="L425">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PATH_RENAME_TARGET: rights_t = <span class="tok-number">0x0000000000020000</span>;</span>
<span class="line" id="L426">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PATH_FILESTAT_GET: rights_t = <span class="tok-number">0x0000000000040000</span>;</span>
<span class="line" id="L427">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PATH_FILESTAT_SET_SIZE: rights_t = <span class="tok-number">0x0000000000080000</span>;</span>
<span class="line" id="L428">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PATH_FILESTAT_SET_TIMES: rights_t = <span class="tok-number">0x0000000000100000</span>;</span>
<span class="line" id="L429">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_FILESTAT_GET: rights_t = <span class="tok-number">0x0000000000200000</span>;</span>
<span class="line" id="L430">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_FILESTAT_SET_SIZE: rights_t = <span class="tok-number">0x0000000000400000</span>;</span>
<span class="line" id="L431">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> FD_FILESTAT_SET_TIMES: rights_t = <span class="tok-number">0x0000000000800000</span>;</span>
<span class="line" id="L432">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PATH_SYMLINK: rights_t = <span class="tok-number">0x0000000001000000</span>;</span>
<span class="line" id="L433">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PATH_REMOVE_DIRECTORY: rights_t = <span class="tok-number">0x0000000002000000</span>;</span>
<span class="line" id="L434">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> PATH_UNLINK_FILE: rights_t = <span class="tok-number">0x0000000004000000</span>;</span>
<span class="line" id="L435">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> POLL_FD_READWRITE: rights_t = <span class="tok-number">0x0000000008000000</span>;</span>
<span class="line" id="L436">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SOCK_SHUTDOWN: rights_t = <span class="tok-number">0x0000000010000000</span>;</span>
<span class="line" id="L437">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> ALL: rights_t = FD_DATASYNC |</span>
<span class="line" id="L438">        FD_READ |</span>
<span class="line" id="L439">        FD_SEEK |</span>
<span class="line" id="L440">        FD_FDSTAT_SET_FLAGS |</span>
<span class="line" id="L441">        FD_SYNC |</span>
<span class="line" id="L442">        FD_TELL |</span>
<span class="line" id="L443">        FD_WRITE |</span>
<span class="line" id="L444">        FD_ADVISE |</span>
<span class="line" id="L445">        FD_ALLOCATE |</span>
<span class="line" id="L446">        PATH_CREATE_DIRECTORY |</span>
<span class="line" id="L447">        PATH_CREATE_FILE |</span>
<span class="line" id="L448">        PATH_LINK_SOURCE |</span>
<span class="line" id="L449">        PATH_LINK_TARGET |</span>
<span class="line" id="L450">        PATH_OPEN |</span>
<span class="line" id="L451">        FD_READDIR |</span>
<span class="line" id="L452">        PATH_READLINK |</span>
<span class="line" id="L453">        PATH_RENAME_SOURCE |</span>
<span class="line" id="L454">        PATH_RENAME_TARGET |</span>
<span class="line" id="L455">        PATH_FILESTAT_GET |</span>
<span class="line" id="L456">        PATH_FILESTAT_SET_SIZE |</span>
<span class="line" id="L457">        PATH_FILESTAT_SET_TIMES |</span>
<span class="line" id="L458">        FD_FILESTAT_GET |</span>
<span class="line" id="L459">        FD_FILESTAT_SET_SIZE |</span>
<span class="line" id="L460">        FD_FILESTAT_SET_TIMES |</span>
<span class="line" id="L461">        PATH_SYMLINK |</span>
<span class="line" id="L462">        PATH_REMOVE_DIRECTORY |</span>
<span class="line" id="L463">        PATH_UNLINK_FILE |</span>
<span class="line" id="L464">        POLL_FD_READWRITE |</span>
<span class="line" id="L465">        SOCK_SHUTDOWN;</span>
<span class="line" id="L466">};</span>
<span class="line" id="L467"></span>
<span class="line" id="L468"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sdflags_t = <span class="tok-type">u8</span>;</span>
<span class="line" id="L469"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SHUT = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L470">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> RD: sdflags_t = <span class="tok-number">0x01</span>;</span>
<span class="line" id="L471">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> WR: sdflags_t = <span class="tok-number">0x02</span>;</span>
<span class="line" id="L472">};</span>
<span class="line" id="L473"></span>
<span class="line" id="L474"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> siflags_t = <span class="tok-type">u16</span>;</span>
<span class="line" id="L475"></span>
<span class="line" id="L476"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> signal_t = <span class="tok-type">u8</span>;</span>
<span class="line" id="L477"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGNONE: signal_t = <span class="tok-number">0</span>;</span>
<span class="line" id="L478"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGHUP: signal_t = <span class="tok-number">1</span>;</span>
<span class="line" id="L479"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGINT: signal_t = <span class="tok-number">2</span>;</span>
<span class="line" id="L480"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGQUIT: signal_t = <span class="tok-number">3</span>;</span>
<span class="line" id="L481"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGILL: signal_t = <span class="tok-number">4</span>;</span>
<span class="line" id="L482"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGTRAP: signal_t = <span class="tok-number">5</span>;</span>
<span class="line" id="L483"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGABRT: signal_t = <span class="tok-number">6</span>;</span>
<span class="line" id="L484"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGBUS: signal_t = <span class="tok-number">7</span>;</span>
<span class="line" id="L485"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGFPE: signal_t = <span class="tok-number">8</span>;</span>
<span class="line" id="L486"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGKILL: signal_t = <span class="tok-number">9</span>;</span>
<span class="line" id="L487"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGUSR1: signal_t = <span class="tok-number">10</span>;</span>
<span class="line" id="L488"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGSEGV: signal_t = <span class="tok-number">11</span>;</span>
<span class="line" id="L489"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGUSR2: signal_t = <span class="tok-number">12</span>;</span>
<span class="line" id="L490"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGPIPE: signal_t = <span class="tok-number">13</span>;</span>
<span class="line" id="L491"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGALRM: signal_t = <span class="tok-number">14</span>;</span>
<span class="line" id="L492"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGTERM: signal_t = <span class="tok-number">15</span>;</span>
<span class="line" id="L493"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGCHLD: signal_t = <span class="tok-number">16</span>;</span>
<span class="line" id="L494"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGCONT: signal_t = <span class="tok-number">17</span>;</span>
<span class="line" id="L495"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGSTOP: signal_t = <span class="tok-number">18</span>;</span>
<span class="line" id="L496"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGTSTP: signal_t = <span class="tok-number">19</span>;</span>
<span class="line" id="L497"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGTTIN: signal_t = <span class="tok-number">20</span>;</span>
<span class="line" id="L498"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGTTOU: signal_t = <span class="tok-number">21</span>;</span>
<span class="line" id="L499"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGURG: signal_t = <span class="tok-number">22</span>;</span>
<span class="line" id="L500"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGXCPU: signal_t = <span class="tok-number">23</span>;</span>
<span class="line" id="L501"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGXFSZ: signal_t = <span class="tok-number">24</span>;</span>
<span class="line" id="L502"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGVTALRM: signal_t = <span class="tok-number">25</span>;</span>
<span class="line" id="L503"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGPROF: signal_t = <span class="tok-number">26</span>;</span>
<span class="line" id="L504"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGWINCH: signal_t = <span class="tok-number">27</span>;</span>
<span class="line" id="L505"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGPOLL: signal_t = <span class="tok-number">28</span>;</span>
<span class="line" id="L506"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGPWR: signal_t = <span class="tok-number">29</span>;</span>
<span class="line" id="L507"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SIGSYS: signal_t = <span class="tok-number">30</span>;</span>
<span class="line" id="L508"></span>
<span class="line" id="L509"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> subclockflags_t = <span class="tok-type">u16</span>;</span>
<span class="line" id="L510"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SUBSCRIPTION_CLOCK_ABSTIME: subclockflags_t = <span class="tok-number">0x0001</span>;</span>
<span class="line" id="L511"></span>
<span class="line" id="L512"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> subscription_t = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L513">    userdata: userdata_t,</span>
<span class="line" id="L514">    u: subscription_u_t,</span>
<span class="line" id="L515">};</span>
<span class="line" id="L516"></span>
<span class="line" id="L517"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> subscription_clock_t = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L518">    id: clockid_t,</span>
<span class="line" id="L519">    timeout: timestamp_t,</span>
<span class="line" id="L520">    precision: timestamp_t,</span>
<span class="line" id="L521">    flags: subclockflags_t,</span>
<span class="line" id="L522">};</span>
<span class="line" id="L523"></span>
<span class="line" id="L524"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> subscription_fd_readwrite_t = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L525">    fd: fd_t,</span>
<span class="line" id="L526">};</span>
<span class="line" id="L527"></span>
<span class="line" id="L528"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> subscription_u_t = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L529">    tag: eventtype_t,</span>
<span class="line" id="L530">    u: subscription_u_u_t,</span>
<span class="line" id="L531">};</span>
<span class="line" id="L532"></span>
<span class="line" id="L533"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> subscription_u_u_t = <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L534">    clock: subscription_clock_t,</span>
<span class="line" id="L535">    fd_read: subscription_fd_readwrite_t,</span>
<span class="line" id="L536">    fd_write: subscription_fd_readwrite_t,</span>
<span class="line" id="L537">};</span>
<span class="line" id="L538"></span>
<span class="line" id="L539"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> timestamp_t = <span class="tok-type">u64</span>;</span>
<span class="line" id="L540"></span>
<span class="line" id="L541"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> userdata_t = <span class="tok-type">u64</span>;</span>
<span class="line" id="L542"></span>
<span class="line" id="L543"><span class="tok-comment">/// Also known as `WHENCE`.</span></span>
<span class="line" id="L544"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> whence_t = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) { SET, CUR, END };</span>
<span class="line" id="L545"></span>
<span class="line" id="L546"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> S = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L547">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IEXEC = <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;TODO audit this&quot;</span>);</span>
<span class="line" id="L548">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFBLK = <span class="tok-number">0x6000</span>;</span>
<span class="line" id="L549">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFCHR = <span class="tok-number">0x2000</span>;</span>
<span class="line" id="L550">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFDIR = <span class="tok-number">0x4000</span>;</span>
<span class="line" id="L551">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFIFO = <span class="tok-number">0xc000</span>;</span>
<span class="line" id="L552">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFLNK = <span class="tok-number">0xa000</span>;</span>
<span class="line" id="L553">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFMT = IFBLK | IFCHR | IFDIR | IFIFO | IFLNK | IFREG | IFSOCK;</span>
<span class="line" id="L554">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFREG = <span class="tok-number">0x8000</span>;</span>
<span class="line" id="L555">    <span class="tok-comment">// There's no concept of UNIX domain socket but we define this value here in order to line with other OSes.</span>
</span>
<span class="line" id="L556">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> IFSOCK = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L557">};</span>
<span class="line" id="L558"></span>
<span class="line" id="L559"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> LOCK = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L560">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> SH = <span class="tok-number">0x1</span>;</span>
<span class="line" id="L561">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> EX = <span class="tok-number">0x2</span>;</span>
<span class="line" id="L562">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> NB = <span class="tok-number">0x4</span>;</span>
<span class="line" id="L563">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> UN = <span class="tok-number">0x8</span>;</span>
<span class="line" id="L564">};</span>
<span class="line" id="L565"></span>
</code></pre></body>
</html>