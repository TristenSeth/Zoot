<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/uefi/protocols/ip6_protocol.zig - source view</title>
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
<span class="line" id="L5"><span class="tok-kw">const</span> MacAddress = uefi.protocols.MacAddress;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> ManagedNetworkConfigData = uefi.protocols.ManagedNetworkConfigData;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> SimpleNetworkMode = uefi.protocols.SimpleNetworkMode;</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Ip6Protocol = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L10">    _get_mode_data: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> Ip6Protocol, ?*Ip6ModeData, ?*ManagedNetworkConfigData, ?*SimpleNetworkMode) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L11">    _configure: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> Ip6Protocol, ?*<span class="tok-kw">const</span> Ip6ConfigData) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L12">    _groups: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> Ip6Protocol, <span class="tok-type">bool</span>, ?*<span class="tok-kw">const</span> Ip6Address) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L13">    _routes: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> Ip6Protocol, <span class="tok-type">bool</span>, ?*<span class="tok-kw">const</span> Ip6Address, <span class="tok-type">u8</span>, ?*<span class="tok-kw">const</span> Ip6Address) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L14">    _neighbors: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> Ip6Protocol, <span class="tok-type">bool</span>, *<span class="tok-kw">const</span> Ip6Address, ?*<span class="tok-kw">const</span> MacAddress, <span class="tok-type">u32</span>, <span class="tok-type">bool</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L15">    _transmit: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> Ip6Protocol, *Ip6CompletionToken) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L16">    _receive: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> Ip6Protocol, *Ip6CompletionToken) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L17">    _cancel: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> Ip6Protocol, ?*Ip6CompletionToken) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L18">    _poll: <span class="tok-kw">fn</span> (*<span class="tok-kw">const</span> Ip6Protocol) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L19"></span>
<span class="line" id="L20">    <span class="tok-comment">/// Gets the current operational settings for this instance of the EFI IPv6 Protocol driver.</span></span>
<span class="line" id="L21">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getModeData</span>(self: *<span class="tok-kw">const</span> Ip6Protocol, ip6_mode_data: ?*Ip6ModeData, mnp_config_data: ?*ManagedNetworkConfigData, snp_mode_data: ?*SimpleNetworkMode) Status {</span>
<span class="line" id="L22">        <span class="tok-kw">return</span> self._get_mode_data(self, ip6_mode_data, mnp_config_data, snp_mode_data);</span>
<span class="line" id="L23">    }</span>
<span class="line" id="L24"></span>
<span class="line" id="L25">    <span class="tok-comment">/// Assign IPv6 address and other configuration parameter to this EFI IPv6 Protocol driver instance.</span></span>
<span class="line" id="L26">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">configure</span>(self: *<span class="tok-kw">const</span> Ip6Protocol, ip6_config_data: ?*<span class="tok-kw">const</span> Ip6ConfigData) Status {</span>
<span class="line" id="L27">        <span class="tok-kw">return</span> self._configure(self, ip6_config_data);</span>
<span class="line" id="L28">    }</span>
<span class="line" id="L29"></span>
<span class="line" id="L30">    <span class="tok-comment">/// Joins and leaves multicast groups.</span></span>
<span class="line" id="L31">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">groups</span>(self: *<span class="tok-kw">const</span> Ip6Protocol, join_flag: <span class="tok-type">bool</span>, group_address: ?*<span class="tok-kw">const</span> Ip6Address) Status {</span>
<span class="line" id="L32">        <span class="tok-kw">return</span> self._groups(self, join_flag, group_address);</span>
<span class="line" id="L33">    }</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">    <span class="tok-comment">/// Adds and deletes routing table entries.</span></span>
<span class="line" id="L36">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">routes</span>(self: *<span class="tok-kw">const</span> Ip6Protocol, delete_route: <span class="tok-type">bool</span>, destination: ?*<span class="tok-kw">const</span> Ip6Address, prefix_length: <span class="tok-type">u8</span>, gateway_address: ?*<span class="tok-kw">const</span> Ip6Address) Status {</span>
<span class="line" id="L37">        <span class="tok-kw">return</span> self._routes(self, delete_route, destination, prefix_length, gateway_address);</span>
<span class="line" id="L38">    }</span>
<span class="line" id="L39"></span>
<span class="line" id="L40">    <span class="tok-comment">/// Add or delete Neighbor cache entries.</span></span>
<span class="line" id="L41">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">neighbors</span>(self: *<span class="tok-kw">const</span> Ip6Protocol, delete_flag: <span class="tok-type">bool</span>, target_ip6_address: *<span class="tok-kw">const</span> Ip6Address, target_link_address: ?*<span class="tok-kw">const</span> MacAddress, timeout: <span class="tok-type">u32</span>, override: <span class="tok-type">bool</span>) Status {</span>
<span class="line" id="L42">        <span class="tok-kw">return</span> self._neighbors(self, delete_flag, target_ip6_address, target_link_address, timeout, override);</span>
<span class="line" id="L43">    }</span>
<span class="line" id="L44"></span>
<span class="line" id="L45">    <span class="tok-comment">/// Places outgoing data packets into the transmit queue.</span></span>
<span class="line" id="L46">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">transmit</span>(self: *<span class="tok-kw">const</span> Ip6Protocol, token: *Ip6CompletionToken) Status {</span>
<span class="line" id="L47">        <span class="tok-kw">return</span> self._transmit(self, token);</span>
<span class="line" id="L48">    }</span>
<span class="line" id="L49"></span>
<span class="line" id="L50">    <span class="tok-comment">/// Places a receiving request into the receiving queue.</span></span>
<span class="line" id="L51">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">receive</span>(self: *<span class="tok-kw">const</span> Ip6Protocol, token: *Ip6CompletionToken) Status {</span>
<span class="line" id="L52">        <span class="tok-kw">return</span> self._receive(self, token);</span>
<span class="line" id="L53">    }</span>
<span class="line" id="L54"></span>
<span class="line" id="L55">    <span class="tok-comment">/// Abort an asynchronous transmits or receive request.</span></span>
<span class="line" id="L56">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">cancel</span>(self: *<span class="tok-kw">const</span> Ip6Protocol, token: ?*Ip6CompletionToken) Status {</span>
<span class="line" id="L57">        <span class="tok-kw">return</span> self._cancel(self, token);</span>
<span class="line" id="L58">    }</span>
<span class="line" id="L59"></span>
<span class="line" id="L60">    <span class="tok-comment">/// Polls for incoming data packets and processes outgoing data packets.</span></span>
<span class="line" id="L61">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">poll</span>(self: *<span class="tok-kw">const</span> Ip6Protocol) Status {</span>
<span class="line" id="L62">        <span class="tok-kw">return</span> self._poll(self);</span>
<span class="line" id="L63">    }</span>
<span class="line" id="L64"></span>
<span class="line" id="L65">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L66">        .time_low = <span class="tok-number">0x2c8759d5</span>,</span>
<span class="line" id="L67">        .time_mid = <span class="tok-number">0x5c2d</span>,</span>
<span class="line" id="L68">        .time_high_and_version = <span class="tok-number">0x66ef</span>,</span>
<span class="line" id="L69">        .clock_seq_high_and_reserved = <span class="tok-number">0x92</span>,</span>
<span class="line" id="L70">        .clock_seq_low = <span class="tok-number">0x5f</span>,</span>
<span class="line" id="L71">        .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0xb6</span>, <span class="tok-number">0x6c</span>, <span class="tok-number">0x10</span>, <span class="tok-number">0x19</span>, <span class="tok-number">0x57</span>, <span class="tok-number">0xe2</span> },</span>
<span class="line" id="L72">    };</span>
<span class="line" id="L73">};</span>
<span class="line" id="L74"></span>
<span class="line" id="L75"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Ip6ModeData = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L76">    is_started: <span class="tok-type">bool</span>,</span>
<span class="line" id="L77">    max_packet_size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L78">    config_data: Ip6ConfigData,</span>
<span class="line" id="L79">    is_configured: <span class="tok-type">bool</span>,</span>
<span class="line" id="L80">    address_count: <span class="tok-type">u32</span>,</span>
<span class="line" id="L81">    address_list: [*]Ip6AddressInfo,</span>
<span class="line" id="L82">    group_count: <span class="tok-type">u32</span>,</span>
<span class="line" id="L83">    group_table: [*]Ip6Address,</span>
<span class="line" id="L84">    route_count: <span class="tok-type">u32</span>,</span>
<span class="line" id="L85">    route_table: [*]Ip6RouteTable,</span>
<span class="line" id="L86">    neighbor_count: <span class="tok-type">u32</span>,</span>
<span class="line" id="L87">    neighbor_cache: [*]Ip6NeighborCache,</span>
<span class="line" id="L88">    prefix_count: <span class="tok-type">u32</span>,</span>
<span class="line" id="L89">    prefix_table: [*]Ip6AddressInfo,</span>
<span class="line" id="L90">    icmp_type_count: <span class="tok-type">u32</span>,</span>
<span class="line" id="L91">    icmp_type_list: [*]Ip6IcmpType,</span>
<span class="line" id="L92">};</span>
<span class="line" id="L93"></span>
<span class="line" id="L94"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Ip6ConfigData = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L95">    default_protocol: <span class="tok-type">u8</span>,</span>
<span class="line" id="L96">    accept_any_protocol: <span class="tok-type">bool</span>,</span>
<span class="line" id="L97">    accept_icmp_errors: <span class="tok-type">bool</span>,</span>
<span class="line" id="L98">    accept_promiscuous: <span class="tok-type">bool</span>,</span>
<span class="line" id="L99">    destination_address: Ip6Address,</span>
<span class="line" id="L100">    station_address: Ip6Address,</span>
<span class="line" id="L101">    traffic_class: <span class="tok-type">u8</span>,</span>
<span class="line" id="L102">    hop_limit: <span class="tok-type">u8</span>,</span>
<span class="line" id="L103">    flow_label: <span class="tok-type">u32</span>,</span>
<span class="line" id="L104">    receive_timeout: <span class="tok-type">u32</span>,</span>
<span class="line" id="L105">    transmit_timeout: <span class="tok-type">u32</span>,</span>
<span class="line" id="L106">};</span>
<span class="line" id="L107"></span>
<span class="line" id="L108"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Ip6Address = [<span class="tok-number">16</span>]<span class="tok-type">u8</span>;</span>
<span class="line" id="L109"></span>
<span class="line" id="L110"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Ip6AddressInfo = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L111">    address: Ip6Address,</span>
<span class="line" id="L112">    prefix_length: <span class="tok-type">u8</span>,</span>
<span class="line" id="L113">};</span>
<span class="line" id="L114"></span>
<span class="line" id="L115"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Ip6RouteTable = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L116">    gateway: Ip6Address,</span>
<span class="line" id="L117">    destination: Ip6Address,</span>
<span class="line" id="L118">    prefix_length: <span class="tok-type">u8</span>,</span>
<span class="line" id="L119">};</span>
<span class="line" id="L120"></span>
<span class="line" id="L121"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Ip6NeighborState = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L122">    Incomplete,</span>
<span class="line" id="L123">    Reachable,</span>
<span class="line" id="L124">    Stale,</span>
<span class="line" id="L125">    Delay,</span>
<span class="line" id="L126">    Probe,</span>
<span class="line" id="L127">};</span>
<span class="line" id="L128"></span>
<span class="line" id="L129"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Ip6NeighborCache = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L130">    neighbor: Ip6Address,</span>
<span class="line" id="L131">    link_address: MacAddress,</span>
<span class="line" id="L132">    state: Ip6NeighborState,</span>
<span class="line" id="L133">};</span>
<span class="line" id="L134"></span>
<span class="line" id="L135"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Ip6IcmpType = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L136">    <span class="tok-type">type</span>: <span class="tok-type">u8</span>,</span>
<span class="line" id="L137">    code: <span class="tok-type">u8</span>,</span>
<span class="line" id="L138">};</span>
<span class="line" id="L139"></span>
<span class="line" id="L140"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Ip6CompletionToken = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L141">    event: Event,</span>
<span class="line" id="L142">    status: Status,</span>
<span class="line" id="L143">    packet: *<span class="tok-type">anyopaque</span>, <span class="tok-comment">// union TODO</span>
</span>
<span class="line" id="L144">};</span>
<span class="line" id="L145"></span>
</code></pre></body>
</html>