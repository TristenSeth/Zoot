<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/uefi/protocols/udp6_protocol.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> Guid = uefi.Guid;</span>
<span class="line" id="L3"><span class="tok-kw">const</span> Event = uefi.Event;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Status = uefi.Status;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> Time = uefi.Time;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> Ip6ModeData = uefi.protocols.Ip6ModeData;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> Ip6Address = uefi.protocols.Ip6Address;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> ManagedNetworkConfigData = uefi.protocols.ManagedNetworkConfigData;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> SimpleNetworkMode = uefi.protocols.SimpleNetworkMode;</span>
<span class="line" id="L10"></span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Udp6Protocol = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L12">    _get_mode_data: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> Udp6Protocol, ?*Udp6ConfigData, ?*Ip6ModeData, ?*ManagedNetworkConfigData, ?*SimpleNetworkMode) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L13">    _configure: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> Udp6Protocol, ?*<span class="tok-kw">const</span> Udp6ConfigData) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L14">    _groups: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> Udp6Protocol, <span class="tok-type">bool</span>, ?*<span class="tok-kw">const</span> Ip6Address) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L15">    _transmit: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> Udp6Protocol, *Udp6CompletionToken) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L16">    _receive: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> Udp6Protocol, *Udp6CompletionToken) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L17">    _cancel: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> Udp6Protocol, ?*Udp6CompletionToken) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L18">    _poll: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> Udp6Protocol) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L19"></span>
<span class="line" id="L20">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getModeData</span>(self: *<span class="tok-kw">const</span> Udp6Protocol, udp6_config_data: ?*Udp6ConfigData, ip6_mode_data: ?*Ip6ModeData, mnp_config_data: ?*ManagedNetworkConfigData, snp_mode_data: ?*SimpleNetworkMode) Status {</span>
<span class="line" id="L21">        <span class="tok-kw">return</span> self._get_mode_data(self, udp6_config_data, ip6_mode_data, mnp_config_data, snp_mode_data);</span>
<span class="line" id="L22">    }</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">configure</span>(self: *<span class="tok-kw">const</span> Udp6Protocol, udp6_config_data: ?*<span class="tok-kw">const</span> Udp6ConfigData) Status {</span>
<span class="line" id="L25">        <span class="tok-kw">return</span> self._configure(self, udp6_config_data);</span>
<span class="line" id="L26">    }</span>
<span class="line" id="L27"></span>
<span class="line" id="L28">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">groups</span>(self: *<span class="tok-kw">const</span> Udp6Protocol, join_flag: <span class="tok-type">bool</span>, multicast_address: ?*<span class="tok-kw">const</span> Ip6Address) Status {</span>
<span class="line" id="L29">        <span class="tok-kw">return</span> self._groups(self, join_flag, multicast_address);</span>
<span class="line" id="L30">    }</span>
<span class="line" id="L31"></span>
<span class="line" id="L32">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">transmit</span>(self: *<span class="tok-kw">const</span> Udp6Protocol, token: *Udp6CompletionToken) Status {</span>
<span class="line" id="L33">        <span class="tok-kw">return</span> self._transmit(self, token);</span>
<span class="line" id="L34">    }</span>
<span class="line" id="L35"></span>
<span class="line" id="L36">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">receive</span>(self: *<span class="tok-kw">const</span> Udp6Protocol, token: *Udp6CompletionToken) Status {</span>
<span class="line" id="L37">        <span class="tok-kw">return</span> self._receive(self, token);</span>
<span class="line" id="L38">    }</span>
<span class="line" id="L39"></span>
<span class="line" id="L40">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cancel</span>(self: *<span class="tok-kw">const</span> Udp6Protocol, token: ?*Udp6CompletionToken) Status {</span>
<span class="line" id="L41">        <span class="tok-kw">return</span> self._cancel(self, token);</span>
<span class="line" id="L42">    }</span>
<span class="line" id="L43"></span>
<span class="line" id="L44">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">poll</span>(self: *<span class="tok-kw">const</span> Udp6Protocol) Status {</span>
<span class="line" id="L45">        <span class="tok-kw">return</span> self._poll(self);</span>
<span class="line" id="L46">    }</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = uefi.Guid{</span>
<span class="line" id="L49">        .time_low = <span class="tok-number">0x4f948815</span>,</span>
<span class="line" id="L50">        .time_mid = <span class="tok-number">0xb4b9</span>,</span>
<span class="line" id="L51">        .time_high_and_version = <span class="tok-number">0x43cb</span>,</span>
<span class="line" id="L52">        .clock_seq_high_and_reserved = <span class="tok-number">0x8a</span>,</span>
<span class="line" id="L53">        .clock_seq_low = <span class="tok-number">0x33</span>,</span>
<span class="line" id="L54">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x90</span>, <span class="tok-number">0xe0</span>, <span class="tok-number">0x60</span>, <span class="tok-number">0xb3</span>, <span class="tok-number">0x49</span>, <span class="tok-number">0x55</span> },</span>
<span class="line" id="L55">    };</span>
<span class="line" id="L56">};</span>
<span class="line" id="L57"></span>
<span class="line" id="L58"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Udp6ConfigData = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L59">    accept_promiscuous: <span class="tok-type">bool</span>,</span>
<span class="line" id="L60">    accept_any_port: <span class="tok-type">bool</span>,</span>
<span class="line" id="L61">    allow_duplicate_port: <span class="tok-type">bool</span>,</span>
<span class="line" id="L62">    traffic_class: <span class="tok-type">u8</span>,</span>
<span class="line" id="L63">    hop_limit: <span class="tok-type">u8</span>,</span>
<span class="line" id="L64">    receive_timeout: <span class="tok-type">u32</span>,</span>
<span class="line" id="L65">    transmit_timeout: <span class="tok-type">u32</span>,</span>
<span class="line" id="L66">    station_address: Ip6Address,</span>
<span class="line" id="L67">    station_port: <span class="tok-type">u16</span>,</span>
<span class="line" id="L68">    remote_address: Ip6Address,</span>
<span class="line" id="L69">    remote_port: <span class="tok-type">u16</span>,</span>
<span class="line" id="L70">};</span>
<span class="line" id="L71"></span>
<span class="line" id="L72"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Udp6CompletionToken = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L73">    event: Event,</span>
<span class="line" id="L74">    Status: <span class="tok-type">usize</span>,</span>
<span class="line" id="L75">    packet: <span class="tok-kw">extern</span> <span class="tok-kw">union</span> {</span>
<span class="line" id="L76">        RxData: *Udp6ReceiveData,</span>
<span class="line" id="L77">        TxData: *Udp6TransmitData,</span>
<span class="line" id="L78">    },</span>
<span class="line" id="L79">};</span>
<span class="line" id="L80"></span>
<span class="line" id="L81"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Udp6ReceiveData = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L82">    timestamp: Time,</span>
<span class="line" id="L83">    recycle_signal: Event,</span>
<span class="line" id="L84">    udp6_session: Udp6SessionData,</span>
<span class="line" id="L85">    data_length: <span class="tok-type">u32</span>,</span>
<span class="line" id="L86">    fragment_count: <span class="tok-type">u32</span>,</span>
<span class="line" id="L87"></span>
<span class="line" id="L88">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getFragments</span>(self: *Udp6ReceiveData) []Udp6FragmentData {</span>
<span class="line" id="L89">        <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>([*]Udp6FragmentData, <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, self) + <span class="tok-builtin">@sizeOf</span>(Udp6ReceiveData))[<span class="tok-number">0</span>..self.fragment_count];</span>
<span class="line" id="L90">    }</span>
<span class="line" id="L91">};</span>
<span class="line" id="L92"></span>
<span class="line" id="L93"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Udp6TransmitData = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L94">    udp6_session_data: ?*Udp6SessionData,</span>
<span class="line" id="L95">    data_length: <span class="tok-type">u32</span>,</span>
<span class="line" id="L96">    fragment_count: <span class="tok-type">u32</span>,</span>
<span class="line" id="L97"></span>
<span class="line" id="L98">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getFragments</span>(self: *Udp6TransmitData) []Udp6FragmentData {</span>
<span class="line" id="L99">        <span class="tok-kw">return</span> <span class="tok-builtin">@ptrCast</span>([*]Udp6FragmentData, <span class="tok-builtin">@ptrCast</span>([*]<span class="tok-type">u8</span>, self) + <span class="tok-builtin">@sizeOf</span>(Udp6TransmitData))[<span class="tok-number">0</span>..self.fragment_count];</span>
<span class="line" id="L100">    }</span>
<span class="line" id="L101">};</span>
<span class="line" id="L102"></span>
<span class="line" id="L103"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Udp6SessionData = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L104">    source_address: Ip6Address,</span>
<span class="line" id="L105">    source_port: <span class="tok-type">u16</span>,</span>
<span class="line" id="L106">    destination_address: Ip6Address,</span>
<span class="line" id="L107">    destination_port: <span class="tok-type">u16</span>,</span>
<span class="line" id="L108">};</span>
<span class="line" id="L109"></span>
<span class="line" id="L110"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Udp6FragmentData = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L111">    fragment_length: <span class="tok-type">u32</span>,</span>
<span class="line" id="L112">    fragment_buffer: [*]<span class="tok-type">u8</span>,</span>
<span class="line" id="L113">};</span>
<span class="line" id="L114"></span>
</code></pre></body>
</html>