<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>os/linux/bpf/btf.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../../../std.zig&quot;</span>);</span>
<span class="line" id="L2"></span>
<span class="line" id="L3"><span class="tok-kw">const</span> magic = <span class="tok-number">0xeb9f</span>;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> version = <span class="tok-number">1</span>;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ext = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;btf_ext.zig&quot;</span>);</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-comment">/// All offsets are in bytes relative to the end of this header</span></span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Header = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L10">    magic: <span class="tok-type">u16</span>,</span>
<span class="line" id="L11">    version: <span class="tok-type">u8</span>,</span>
<span class="line" id="L12">    flags: <span class="tok-type">u8</span>,</span>
<span class="line" id="L13">    hdr_len: <span class="tok-type">u32</span>,</span>
<span class="line" id="L14"></span>
<span class="line" id="L15">    <span class="tok-comment">/// offset of type section</span></span>
<span class="line" id="L16">    type_off: <span class="tok-type">u32</span>,</span>
<span class="line" id="L17"></span>
<span class="line" id="L18">    <span class="tok-comment">/// length of type section</span></span>
<span class="line" id="L19">    type_len: <span class="tok-type">u32</span>,</span>
<span class="line" id="L20"></span>
<span class="line" id="L21">    <span class="tok-comment">/// offset of string section</span></span>
<span class="line" id="L22">    str_off: <span class="tok-type">u32</span>,</span>
<span class="line" id="L23"></span>
<span class="line" id="L24">    <span class="tok-comment">/// length of string section</span></span>
<span class="line" id="L25">    str_len: <span class="tok-type">u32</span>,</span>
<span class="line" id="L26">};</span>
<span class="line" id="L27"></span>
<span class="line" id="L28"><span class="tok-comment">/// Max number of type identifiers</span></span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> max_type = <span class="tok-number">0xfffff</span>;</span>
<span class="line" id="L30"></span>
<span class="line" id="L31"><span class="tok-comment">/// Max offset into string section</span></span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> max_name_offset = <span class="tok-number">0xffffff</span>;</span>
<span class="line" id="L33"></span>
<span class="line" id="L34"><span class="tok-comment">/// Max number of struct/union/enum member of func args</span></span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> max_vlen = <span class="tok-number">0xffff</span>;</span>
<span class="line" id="L36"></span>
<span class="line" id="L37"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Type = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L38">    name_off: <span class="tok-type">u32</span>,</span>
<span class="line" id="L39">    info: <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L40">        <span class="tok-comment">/// number of struct's members</span></span>
<span class="line" id="L41">        vlen: <span class="tok-type">u16</span>,</span>
<span class="line" id="L42"></span>
<span class="line" id="L43">        unused_1: <span class="tok-type">u8</span>,</span>
<span class="line" id="L44">        kind: Kind,</span>
<span class="line" id="L45">        unused_2: <span class="tok-type">u3</span>,</span>
<span class="line" id="L46"></span>
<span class="line" id="L47">        <span class="tok-comment">/// used by Struct, Union, and Fwd</span></span>
<span class="line" id="L48">        kind_flag: <span class="tok-type">bool</span>,</span>
<span class="line" id="L49">    },</span>
<span class="line" id="L50"></span>
<span class="line" id="L51">    <span class="tok-comment">/// size is used by Int, Enum, Struct, Union, and DataSec, it tells the size</span></span>
<span class="line" id="L52">    <span class="tok-comment">/// of the type it is describing</span></span>
<span class="line" id="L53">    <span class="tok-comment">///</span></span>
<span class="line" id="L54">    <span class="tok-comment">/// type is used by Ptr, Typedef, Volatile, Const, Restrict, Func,</span></span>
<span class="line" id="L55">    <span class="tok-comment">/// FuncProto, and Var. It is a type_id referring to another type</span></span>
<span class="line" id="L56">    size_type: <span class="tok-kw">union</span> { size: <span class="tok-type">u32</span>, typ: <span class="tok-type">u32</span> },</span>
<span class="line" id="L57">};</span>
<span class="line" id="L58"></span>
<span class="line" id="L59"><span class="tok-comment">/// For some kinds, Type is immediately followed by extra data</span></span>
<span class="line" id="L60"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Kind = <span class="tok-kw">enum</span>(<span class="tok-type">u4</span>) {</span>
<span class="line" id="L61">    unknown,</span>
<span class="line" id="L62">    int,</span>
<span class="line" id="L63">    ptr,</span>
<span class="line" id="L64">    array,</span>
<span class="line" id="L65">    structure,</span>
<span class="line" id="L66">    kind_union,</span>
<span class="line" id="L67">    enumeration,</span>
<span class="line" id="L68">    fwd,</span>
<span class="line" id="L69">    typedef,</span>
<span class="line" id="L70">    kind_volatile,</span>
<span class="line" id="L71">    constant,</span>
<span class="line" id="L72">    restrict,</span>
<span class="line" id="L73">    func,</span>
<span class="line" id="L74">    funcProto,</span>
<span class="line" id="L75">    variable,</span>
<span class="line" id="L76">    dataSec,</span>
<span class="line" id="L77">};</span>
<span class="line" id="L78"></span>
<span class="line" id="L79"><span class="tok-comment">/// Int kind is followed by this struct</span></span>
<span class="line" id="L80"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> IntInfo = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L81">    bits: <span class="tok-type">u8</span>,</span>
<span class="line" id="L82">    unused: <span class="tok-type">u8</span>,</span>
<span class="line" id="L83">    offset: <span class="tok-type">u8</span>,</span>
<span class="line" id="L84">    encoding: <span class="tok-kw">enum</span>(<span class="tok-type">u4</span>) {</span>
<span class="line" id="L85">        signed = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">0</span>,</span>
<span class="line" id="L86">        char = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">1</span>,</span>
<span class="line" id="L87">        boolean = <span class="tok-number">1</span> &lt;&lt; <span class="tok-number">2</span>,</span>
<span class="line" id="L88">    },</span>
<span class="line" id="L89">};</span>
<span class="line" id="L90"></span>
<span class="line" id="L91"><span class="tok-kw">test</span> <span class="tok-str">&quot;IntInfo is 32 bits&quot;</span> {</span>
<span class="line" id="L92">    <span class="tok-kw">try</span> std.testing.expectEqual(<span class="tok-builtin">@bitSizeOf</span>(IntInfo), <span class="tok-number">32</span>);</span>
<span class="line" id="L93">}</span>
<span class="line" id="L94"></span>
<span class="line" id="L95"><span class="tok-comment">/// Enum kind is followed by this struct</span></span>
<span class="line" id="L96"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Enum = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L97">    name_off: <span class="tok-type">u32</span>,</span>
<span class="line" id="L98">    val: <span class="tok-type">i32</span>,</span>
<span class="line" id="L99">};</span>
<span class="line" id="L100"></span>
<span class="line" id="L101"><span class="tok-comment">/// Array kind is followd by this struct</span></span>
<span class="line" id="L102"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Array = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L103">    typ: <span class="tok-type">u32</span>,</span>
<span class="line" id="L104">    index_type: <span class="tok-type">u32</span>,</span>
<span class="line" id="L105">    nelems: <span class="tok-type">u32</span>,</span>
<span class="line" id="L106">};</span>
<span class="line" id="L107"></span>
<span class="line" id="L108"><span class="tok-comment">/// Struct and Union kinds are followed by multiple Member structs. The exact</span></span>
<span class="line" id="L109"><span class="tok-comment">/// number is stored in vlen</span></span>
<span class="line" id="L110"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Member = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L111">    name_off: <span class="tok-type">u32</span>,</span>
<span class="line" id="L112">    typ: <span class="tok-type">u32</span>,</span>
<span class="line" id="L113"></span>
<span class="line" id="L114">    <span class="tok-comment">/// if the kind_flag is set, offset contains both member bitfield size and</span></span>
<span class="line" id="L115">    <span class="tok-comment">/// bit offset, the bitfield size is set for bitfield members. If the type</span></span>
<span class="line" id="L116">    <span class="tok-comment">/// info kind_flag is not set, the offset contains only bit offset</span></span>
<span class="line" id="L117">    offset: <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L118">        bit: <span class="tok-type">u24</span>,</span>
<span class="line" id="L119">        bitfield_size: <span class="tok-type">u8</span>,</span>
<span class="line" id="L120">    },</span>
<span class="line" id="L121">};</span>
<span class="line" id="L122"></span>
<span class="line" id="L123"><span class="tok-comment">/// FuncProto is followed by multiple Params, the exact number is stored in vlen</span></span>
<span class="line" id="L124"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Param = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L125">    name_off: <span class="tok-type">u32</span>,</span>
<span class="line" id="L126">    typ: <span class="tok-type">u32</span>,</span>
<span class="line" id="L127">};</span>
<span class="line" id="L128"></span>
<span class="line" id="L129"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VarLinkage = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L130">    static,</span>
<span class="line" id="L131">    global_allocated,</span>
<span class="line" id="L132">    global_extern,</span>
<span class="line" id="L133">};</span>
<span class="line" id="L134"></span>
<span class="line" id="L135"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> FuncLinkage = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L136">    static,</span>
<span class="line" id="L137">    global,</span>
<span class="line" id="L138">    external,</span>
<span class="line" id="L139">};</span>
<span class="line" id="L140"></span>
<span class="line" id="L141"><span class="tok-comment">/// Var kind is followd by a single Var struct to describe additional</span></span>
<span class="line" id="L142"><span class="tok-comment">/// information related to the variable such as its linkage</span></span>
<span class="line" id="L143"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Var = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L144">    linkage: <span class="tok-type">u32</span>,</span>
<span class="line" id="L145">};</span>
<span class="line" id="L146"></span>
<span class="line" id="L147"><span class="tok-comment">/// Datasec kind is followed by multible VarSecInfo to describe all Var kind</span></span>
<span class="line" id="L148"><span class="tok-comment">/// types it contains along with it's in-section offset as well as size.</span></span>
<span class="line" id="L149"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> VarSecInfo = <span class="tok-kw">packed</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L150">    typ: <span class="tok-type">u32</span>,</span>
<span class="line" id="L151">    offset: <span class="tok-type">u32</span>,</span>
<span class="line" id="L152">    size: <span class="tok-type">u32</span>,</span>
<span class="line" id="L153">};</span>
<span class="line" id="L154"></span>
</code></pre></body>
</html>