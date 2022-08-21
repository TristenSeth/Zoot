<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/uefi/tables/runtime_services.zig - source view</title>
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
<span class="line" id="L3"><span class="tok-kw">const</span> TableHeader = uefi.tables.TableHeader;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> Time = uefi.Time;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> TimeCapabilities = uefi.TimeCapabilities;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> Status = uefi.Status;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> MemoryDescriptor = uefi.tables.MemoryDescriptor;</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-comment">/// Runtime services are provided by the firmware before and after exitBootServices has been called.</span></span>
<span class="line" id="L10"><span class="tok-comment">///</span></span>
<span class="line" id="L11"><span class="tok-comment">/// As the runtime_services table may grow with new UEFI versions, it is important to check hdr.header_size.</span></span>
<span class="line" id="L12"><span class="tok-comment">///</span></span>
<span class="line" id="L13"><span class="tok-comment">/// Some functions may not be supported. Check the RuntimeServicesSupported variable using getVariable.</span></span>
<span class="line" id="L14"><span class="tok-comment">/// getVariable is one of the functions that may not be supported.</span></span>
<span class="line" id="L15"><span class="tok-comment">///</span></span>
<span class="line" id="L16"><span class="tok-comment">/// Some functions may not be called while other functions are running.</span></span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RuntimeServices = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L18">    hdr: TableHeader,</span>
<span class="line" id="L19"></span>
<span class="line" id="L20">    <span class="tok-comment">/// Returns the current time and date information, and the time-keeping capabilities of the hardware platform.</span></span>
<span class="line" id="L21">    getTime: <span class="tok-kw">fn</span> (time: *uefi.Time, capabilities: ?*TimeCapabilities) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L22"></span>
<span class="line" id="L23">    <span class="tok-comment">/// Sets the current local time and date information</span></span>
<span class="line" id="L24">    setTime: <span class="tok-kw">fn</span> (time: *uefi.Time) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L25"></span>
<span class="line" id="L26">    <span class="tok-comment">/// Returns the current wakeup alarm clock setting</span></span>
<span class="line" id="L27">    getWakeupTime: <span class="tok-kw">fn</span> (enabled: *<span class="tok-type">bool</span>, pending: *<span class="tok-type">bool</span>, time: *uefi.Time) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L28"></span>
<span class="line" id="L29">    <span class="tok-comment">/// Sets the system wakeup alarm clock time</span></span>
<span class="line" id="L30">    setWakeupTime: <span class="tok-kw">fn</span> (enable: *<span class="tok-type">bool</span>, time: ?*uefi.Time) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L31"></span>
<span class="line" id="L32">    <span class="tok-comment">/// Changes the runtime addressing mode of EFI firmware from physical to virtual.</span></span>
<span class="line" id="L33">    setVirtualAddressMap: <span class="tok-kw">fn</span> (mmap_size: <span class="tok-type">usize</span>, descriptor_size: <span class="tok-type">usize</span>, descriptor_version: <span class="tok-type">u32</span>, virtual_map: [*]MemoryDescriptor) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L34"></span>
<span class="line" id="L35">    <span class="tok-comment">/// Determines the new virtual address that is to be used on subsequent memory accesses.</span></span>
<span class="line" id="L36">    convertPointer: <span class="tok-kw">fn</span> (debug_disposition: <span class="tok-type">usize</span>, address: **<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L37"></span>
<span class="line" id="L38">    <span class="tok-comment">/// Returns the value of a variable.</span></span>
<span class="line" id="L39">    getVariable: <span class="tok-kw">fn</span> (var_name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, vendor_guid: *<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, attributes: ?*<span class="tok-type">u32</span>, data_size: *<span class="tok-type">usize</span>, data: ?*<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L40"></span>
<span class="line" id="L41">    <span class="tok-comment">/// Enumerates the current variable names.</span></span>
<span class="line" id="L42">    getNextVariableName: <span class="tok-kw">fn</span> (var_name_size: *<span class="tok-type">usize</span>, var_name: [*:<span class="tok-number">0</span>]<span class="tok-type">u16</span>, vendor_guid: *<span class="tok-kw">align</span>(<span class="tok-number">8</span>) Guid) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L43"></span>
<span class="line" id="L44">    <span class="tok-comment">/// Sets the value of a variable.</span></span>
<span class="line" id="L45">    setVariable: <span class="tok-kw">fn</span> (var_name: [*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u16</span>, vendor_guid: *<span class="tok-kw">align</span>(<span class="tok-number">8</span>) <span class="tok-kw">const</span> Guid, attributes: <span class="tok-type">u32</span>, data_size: <span class="tok-type">usize</span>, data: *<span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">    <span class="tok-comment">/// Return the next high 32 bits of the platform's monotonic counter</span></span>
<span class="line" id="L48">    getNextHighMonotonicCount: <span class="tok-kw">fn</span> (high_count: *<span class="tok-type">u32</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L49"></span>
<span class="line" id="L50">    <span class="tok-comment">/// Resets the entire platform.</span></span>
<span class="line" id="L51">    resetSystem: <span class="tok-kw">fn</span> (reset_type: ResetType, reset_status: Status, data_size: <span class="tok-type">usize</span>, reset_data: ?*<span class="tok-kw">const</span> <span class="tok-type">anyopaque</span>) <span class="tok-kw">callconv</span>(.C) <span class="tok-type">noreturn</span>,</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">    <span class="tok-comment">/// Passes capsules to the firmware with both virtual and physical mapping.</span></span>
<span class="line" id="L54">    <span class="tok-comment">/// Depending on the intended consumption, the firmware may process the capsule immediately.</span></span>
<span class="line" id="L55">    <span class="tok-comment">/// If the payload should persist across a system reset, the reset value returned from</span></span>
<span class="line" id="L56">    <span class="tok-comment">/// `queryCapsuleCapabilities` must be passed into resetSystem and will cause the capsule</span></span>
<span class="line" id="L57">    <span class="tok-comment">/// to be processed by the firmware as part of the reset process.</span></span>
<span class="line" id="L58">    updateCapsule: <span class="tok-kw">fn</span> (capsule_header_array: **CapsuleHeader, capsule_count: <span class="tok-type">usize</span>, scatter_gather_list: EfiPhysicalAddress) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L59"></span>
<span class="line" id="L60">    <span class="tok-comment">/// Returns if the capsule can be supported via `updateCapsule`</span></span>
<span class="line" id="L61">    queryCapsuleCapabilities: <span class="tok-kw">fn</span> (capsule_header_array: **CapsuleHeader, capsule_count: <span class="tok-type">usize</span>, maximum_capsule_size: *<span class="tok-type">usize</span>, resetType: ResetType) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">    <span class="tok-comment">/// Returns information about the EFI variables</span></span>
<span class="line" id="L64">    queryVariableInfo: <span class="tok-kw">fn</span> (attributes: *<span class="tok-type">u32</span>, maximum_variable_storage_size: *<span class="tok-type">u64</span>, remaining_variable_storage_size: *<span class="tok-type">u64</span>, maximum_variable_size: *<span class="tok-type">u64</span>) <span class="tok-kw">callconv</span>(.C) Status,</span>
<span class="line" id="L65"></span>
<span class="line" id="L66">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> signature: <span class="tok-type">u64</span> = <span class="tok-number">0x56524553544e5552</span>;</span>
<span class="line" id="L67">};</span>
<span class="line" id="L68"></span>
<span class="line" id="L69"><span class="tok-kw">const</span> EfiPhysicalAddress = <span class="tok-type">u64</span>;</span>
<span class="line" id="L70"></span>
<span class="line" id="L71"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CapsuleHeader = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L72">    capsuleGuid: Guid <span class="tok-kw">align</span>(<span class="tok-number">8</span>),</span>
<span class="line" id="L73">    headerSize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L74">    flags: <span class="tok-type">u32</span>,</span>
<span class="line" id="L75">    capsuleImageSize: <span class="tok-type">u32</span>,</span>
<span class="line" id="L76">};</span>
<span class="line" id="L77"></span>
<span class="line" id="L78"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> UefiCapsuleBlockDescriptor = <span class="tok-kw">extern</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L79">    length: <span class="tok-type">u64</span>,</span>
<span class="line" id="L80">    address: <span class="tok-kw">union</span> {</span>
<span class="line" id="L81">        dataBlock: EfiPhysicalAddress,</span>
<span class="line" id="L82">        continuationPointer: EfiPhysicalAddress,</span>
<span class="line" id="L83">    },</span>
<span class="line" id="L84">};</span>
<span class="line" id="L85"></span>
<span class="line" id="L86"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ResetType = <span class="tok-kw">enum</span>(<span class="tok-type">u32</span>) {</span>
<span class="line" id="L87">    ResetCold,</span>
<span class="line" id="L88">    ResetWarm,</span>
<span class="line" id="L89">    ResetShutdown,</span>
<span class="line" id="L90">    ResetPlatformSpecific,</span>
<span class="line" id="L91">};</span>
<span class="line" id="L92"></span>
<span class="line" id="L93"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> global_variable <span class="tok-kw">align</span>(<span class="tok-number">8</span>) = Guid{</span>
<span class="line" id="L94">    .time_low = <span class="tok-number">0x8be4df61</span>,</span>
<span class="line" id="L95">    .time_mid = <span class="tok-number">0x93ca</span>,</span>
<span class="line" id="L96">    .time_high_and_version = <span class="tok-number">0x11d2</span>,</span>
<span class="line" id="L97">    .clock_seq_high_and_reserved = <span class="tok-number">0xaa</span>,</span>
<span class="line" id="L98">    .clock_seq_low = <span class="tok-number">0x0d</span>,</span>
<span class="line" id="L99">    .node = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x00</span>, <span class="tok-number">0xe0</span>, <span class="tok-number">0x98</span>, <span class="tok-number">0x03</span>, <span class="tok-number">0x2b</span>, <span class="tok-number">0x8c</span> },</span>
<span class="line" id="L100">};</span>
<span class="line" id="L101"></span>
</code></pre></body>
</html>