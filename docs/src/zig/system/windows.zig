<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>zig/system/windows.zig - source view</title>
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
<span class="line" id="L2"></span>
<span class="line" id="L3"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> WindowsVersion = std.Target.Os.WindowsVersion;</span>
<span class="line" id="L4"></span>
<span class="line" id="L5"><span class="tok-comment">/// Returns the highest known WindowsVersion deduced from reported runtime information.</span></span>
<span class="line" id="L6"><span class="tok-comment">/// Discards information about in-between versions we don't differentiate.</span></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">detectRuntimeVersion</span>() WindowsVersion {</span>
<span class="line" id="L8">    <span class="tok-kw">var</span> version_info: std.os.windows.RTL_OSVERSIONINFOW = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L9">    version_info.dwOSVersionInfoSize = <span class="tok-builtin">@sizeOf</span>(<span class="tok-builtin">@TypeOf</span>(version_info));</span>
<span class="line" id="L10"></span>
<span class="line" id="L11">    <span class="tok-kw">switch</span> (std.os.windows.ntdll.RtlGetVersion(&amp;version_info)) {</span>
<span class="line" id="L12">        .SUCCESS =&gt; {},</span>
<span class="line" id="L13">        <span class="tok-kw">else</span> =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L14">    }</span>
<span class="line" id="L15"></span>
<span class="line" id="L16">    <span class="tok-comment">// Starting from the system infos build a NTDDI-like version</span>
</span>
<span class="line" id="L17">    <span class="tok-comment">// constant whose format is:</span>
</span>
<span class="line" id="L18">    <span class="tok-comment">//   B0 B1 B2 B3</span>
</span>
<span class="line" id="L19">    <span class="tok-comment">//   `---` `` ``--&gt; Sub-version (Starting from Windows 10 onwards)</span>
</span>
<span class="line" id="L20">    <span class="tok-comment">//     \    `--&gt; Service pack (Always zero in the constants defined)</span>
</span>
<span class="line" id="L21">    <span class="tok-comment">//      `--&gt; OS version (Major &amp; minor)</span>
</span>
<span class="line" id="L22">    <span class="tok-kw">const</span> os_ver: <span class="tok-type">u16</span> = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, version_info.dwMajorVersion &amp; <span class="tok-number">0xff</span>) &lt;&lt; <span class="tok-number">8</span> |</span>
<span class="line" id="L23">        <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, version_info.dwMinorVersion &amp; <span class="tok-number">0xff</span>);</span>
<span class="line" id="L24">    <span class="tok-kw">const</span> sp_ver: <span class="tok-type">u8</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L25">    <span class="tok-kw">const</span> sub_ver: <span class="tok-type">u8</span> = <span class="tok-kw">if</span> (os_ver &gt;= <span class="tok-number">0x0A00</span>) subver: {</span>
<span class="line" id="L26">        <span class="tok-comment">// There's no other way to obtain this info beside</span>
</span>
<span class="line" id="L27">        <span class="tok-comment">// checking the build number against a known set of</span>
</span>
<span class="line" id="L28">        <span class="tok-comment">// values</span>
</span>
<span class="line" id="L29">        <span class="tok-kw">var</span> last_idx: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L30">        <span class="tok-kw">for</span> (WindowsVersion.known_win10_build_numbers) |build, i| {</span>
<span class="line" id="L31">            <span class="tok-kw">if</span> (version_info.dwBuildNumber &gt;= build)</span>
<span class="line" id="L32">                last_idx = i;</span>
<span class="line" id="L33">        }</span>
<span class="line" id="L34">        <span class="tok-kw">break</span> :subver <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, last_idx);</span>
<span class="line" id="L35">    } <span class="tok-kw">else</span> <span class="tok-number">0</span>;</span>
<span class="line" id="L36"></span>
<span class="line" id="L37">    <span class="tok-kw">const</span> version: <span class="tok-type">u32</span> = <span class="tok-builtin">@as</span>(<span class="tok-type">u32</span>, os_ver) &lt;&lt; <span class="tok-number">16</span> | <span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, sp_ver) &lt;&lt; <span class="tok-number">8</span> | sub_ver;</span>
<span class="line" id="L38"></span>
<span class="line" id="L39">    <span class="tok-kw">return</span> <span class="tok-builtin">@intToEnum</span>(WindowsVersion, version);</span>
<span class="line" id="L40">}</span>
<span class="line" id="L41"></span>
</code></pre></body>
</html>