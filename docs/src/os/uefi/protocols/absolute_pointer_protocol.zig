<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/uefi/protocols/absolute_pointer_protocol.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> uefi = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>).os.uefi;</span>
<span class="line" id="L2"><span class="tok-kw">const</span> Event = uefi.Event;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> Guid = uefi.Guid;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Status = uefi.Status;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-comment">/// Protocol for touchscreens</span></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AbsolutePointerProtocol = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L8">    _reset: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> AbsolutePointerProtocol, <span class="tok-type">bool</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L9">    _get_state: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> AbsolutePointerProtocol, *AbsolutePointerState) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L10">    wait_for_input: Event,</span>
<span class="line" id="L11">    mode: *AbsolutePointerMode,</span>
<span class="line" id="L12"></span>
<span class="line" id="L13">    <span class="tok-comment">/// Resets the pointer device hardware.</span></span>
<span class="line" id="L14">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reset</span>(self: *<span class="tok-kw">const</span> AbsolutePointerProtocol, verify: <span class="tok-type">bool</span>) Status {</span>
<span class="line" id="L15">        <span class="tok-kw">return</span> self._reset(self, verify);</span>
<span class="line" id="L16">    }</span>
<span class="line" id="L17"></span>
<span class="line" id="L18">    <span class="tok-comment">/// Retrieves the current state of a pointer device.</span></span>
<span class="line" id="L19">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getState</span>(self: *<span class="tok-kw">const</span> AbsolutePointerProtocol, state: *AbsolutePointerState) Status {</span>
<span class="line" id="L20">        <span class="tok-kw">return</span> self._get_state(self, state);</span>
<span class="line" id="L21">    }</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L24">        .time_low = <span class="tok-number">0x8d59d32b</span>,</span>
<span class="line" id="L25">        .time_mid = <span class="tok-number">0xc655</span>,</span>
<span class="line" id="L26">        .time_high_and_version = <span class="tok-number">0x4ae9</span>,</span>
<span class="line" id="L27">        .clock_seq_high_and_reserved = <span class="tok-number">0x9b</span>,</span>
<span class="line" id="L28">        .clock_seq_low = <span class="tok-number">0x15</span>,</span>
<span class="line" id="L29">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0xf2</span>, <span class="tok-number">0x59</span>, <span class="tok-number">0x04</span>, <span class="tok-number">0x99</span>, <span class="tok-number">0x2a</span>, <span class="tok-number">0x43</span> },</span>
<span class="line" id="L30">    };</span>
<span class="line" id="L31">};</span>
<span class="line" id="L32"></span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AbsolutePointerMode = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L34">    absolute_min_x: <span class="tok-type">u64</span>,</span>
<span class="line" id="L35">    absolute_min_y: <span class="tok-type">u64</span>,</span>
<span class="line" id="L36">    absolute_min_z: <span class="tok-type">u64</span>,</span>
<span class="line" id="L37">    absolute_max_x: <span class="tok-type">u64</span>,</span>
<span class="line" id="L38">    absolute_max_y: <span class="tok-type">u64</span>,</span>
<span class="line" id="L39">    absolute_max_z: <span class="tok-type">u64</span>,</span>
<span class="line" id="L40">    attributes: <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L41">        supports_alt_active: <span class="tok-type">bool</span>,</span>
<span class="line" id="L42">        supports_pressure_as_z: <span class="tok-type">bool</span>,</span>
<span class="line" id="L43">        _pad: <span class="tok-type">u30</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L44">    },</span>
<span class="line" id="L45">};</span>
<span class="line" id="L46"></span>
<span class="line" id="L47"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AbsolutePointerState = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L48">    current_x: <span class="tok-type">u64</span>,</span>
<span class="line" id="L49">    current_y: <span class="tok-type">u64</span>,</span>
<span class="line" id="L50">    current_z: <span class="tok-type">u64</span>,</span>
<span class="line" id="L51">    active_buttons: <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L52">        touch_active: <span class="tok-type">bool</span>,</span>
<span class="line" id="L53">        alt_active: <span class="tok-type">bool</span>,</span>
<span class="line" id="L54">        _pad: <span class="tok-type">u30</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L55">    },</span>
<span class="line" id="L56">};</span>
<span class="line" id="L57"></span>
</code></pre></body>
</html>