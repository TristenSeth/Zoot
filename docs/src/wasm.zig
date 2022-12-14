<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>wasm.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">///! Contains all constants and types representing the wasm</span></span>
<span class="line" id="L2"><span class="tok-comment">///! binary format, as specified by:</span></span>
<span class="line" id="L3"><span class="tok-comment">///! https://webassembly.github.io/spec/core/</span></span>
<span class="line" id="L4"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std.zig&quot;</span>);</span>
<span class="line" id="L5"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-comment">// TODO: Add support for multi-byte ops (e.g. table operations)</span>
</span>
<span class="line" id="L8"></span>
<span class="line" id="L9"><span class="tok-comment">/// Wasm instruction opcodes</span></span>
<span class="line" id="L10"><span class="tok-comment">///</span></span>
<span class="line" id="L11"><span class="tok-comment">/// All instructions are defined as per spec:</span></span>
<span class="line" id="L12"><span class="tok-comment">/// https://webassembly.github.io/spec/core/appendix/index-instructions.html</span></span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Opcode = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L14">    @&quot;unreachable&quot; = <span class="tok-number">0x00</span>,</span>
<span class="line" id="L15">    nop = <span class="tok-number">0x01</span>,</span>
<span class="line" id="L16">    block = <span class="tok-number">0x02</span>,</span>
<span class="line" id="L17">    loop = <span class="tok-number">0x03</span>,</span>
<span class="line" id="L18">    @&quot;if&quot; = <span class="tok-number">0x04</span>,</span>
<span class="line" id="L19">    @&quot;else&quot; = <span class="tok-number">0x05</span>,</span>
<span class="line" id="L20">    end = <span class="tok-number">0x0B</span>,</span>
<span class="line" id="L21">    br = <span class="tok-number">0x0C</span>,</span>
<span class="line" id="L22">    br_if = <span class="tok-number">0x0D</span>,</span>
<span class="line" id="L23">    br_table = <span class="tok-number">0x0E</span>,</span>
<span class="line" id="L24">    @&quot;return&quot; = <span class="tok-number">0x0F</span>,</span>
<span class="line" id="L25">    call = <span class="tok-number">0x10</span>,</span>
<span class="line" id="L26">    call_indirect = <span class="tok-number">0x11</span>,</span>
<span class="line" id="L27">    drop = <span class="tok-number">0x1A</span>,</span>
<span class="line" id="L28">    select = <span class="tok-number">0x1B</span>,</span>
<span class="line" id="L29">    local_get = <span class="tok-number">0x20</span>,</span>
<span class="line" id="L30">    local_set = <span class="tok-number">0x21</span>,</span>
<span class="line" id="L31">    local_tee = <span class="tok-number">0x22</span>,</span>
<span class="line" id="L32">    global_get = <span class="tok-number">0x23</span>,</span>
<span class="line" id="L33">    global_set = <span class="tok-number">0x24</span>,</span>
<span class="line" id="L34">    i32_load = <span class="tok-number">0x28</span>,</span>
<span class="line" id="L35">    i64_load = <span class="tok-number">0x29</span>,</span>
<span class="line" id="L36">    f32_load = <span class="tok-number">0x2A</span>,</span>
<span class="line" id="L37">    f64_load = <span class="tok-number">0x2B</span>,</span>
<span class="line" id="L38">    i32_load8_s = <span class="tok-number">0x2C</span>,</span>
<span class="line" id="L39">    i32_load8_u = <span class="tok-number">0x2D</span>,</span>
<span class="line" id="L40">    i32_load16_s = <span class="tok-number">0x2E</span>,</span>
<span class="line" id="L41">    i32_load16_u = <span class="tok-number">0x2F</span>,</span>
<span class="line" id="L42">    i64_load8_s = <span class="tok-number">0x30</span>,</span>
<span class="line" id="L43">    i64_load8_u = <span class="tok-number">0x31</span>,</span>
<span class="line" id="L44">    i64_load16_s = <span class="tok-number">0x32</span>,</span>
<span class="line" id="L45">    i64_load16_u = <span class="tok-number">0x33</span>,</span>
<span class="line" id="L46">    i64_load32_s = <span class="tok-number">0x34</span>,</span>
<span class="line" id="L47">    i64_load32_u = <span class="tok-number">0x35</span>,</span>
<span class="line" id="L48">    i32_store = <span class="tok-number">0x36</span>,</span>
<span class="line" id="L49">    i64_store = <span class="tok-number">0x37</span>,</span>
<span class="line" id="L50">    f32_store = <span class="tok-number">0x38</span>,</span>
<span class="line" id="L51">    f64_store = <span class="tok-number">0x39</span>,</span>
<span class="line" id="L52">    i32_store8 = <span class="tok-number">0x3A</span>,</span>
<span class="line" id="L53">    i32_store16 = <span class="tok-number">0x3B</span>,</span>
<span class="line" id="L54">    i64_store8 = <span class="tok-number">0x3C</span>,</span>
<span class="line" id="L55">    i64_store16 = <span class="tok-number">0x3D</span>,</span>
<span class="line" id="L56">    i64_store32 = <span class="tok-number">0x3E</span>,</span>
<span class="line" id="L57">    memory_size = <span class="tok-number">0x3F</span>,</span>
<span class="line" id="L58">    memory_grow = <span class="tok-number">0x40</span>,</span>
<span class="line" id="L59">    i32_const = <span class="tok-number">0x41</span>,</span>
<span class="line" id="L60">    i64_const = <span class="tok-number">0x42</span>,</span>
<span class="line" id="L61">    f32_const = <span class="tok-number">0x43</span>,</span>
<span class="line" id="L62">    f64_const = <span class="tok-number">0x44</span>,</span>
<span class="line" id="L63">    i32_eqz = <span class="tok-number">0x45</span>,</span>
<span class="line" id="L64">    i32_eq = <span class="tok-number">0x46</span>,</span>
<span class="line" id="L65">    i32_ne = <span class="tok-number">0x47</span>,</span>
<span class="line" id="L66">    i32_lt_s = <span class="tok-number">0x48</span>,</span>
<span class="line" id="L67">    i32_lt_u = <span class="tok-number">0x49</span>,</span>
<span class="line" id="L68">    i32_gt_s = <span class="tok-number">0x4A</span>,</span>
<span class="line" id="L69">    i32_gt_u = <span class="tok-number">0x4B</span>,</span>
<span class="line" id="L70">    i32_le_s = <span class="tok-number">0x4C</span>,</span>
<span class="line" id="L71">    i32_le_u = <span class="tok-number">0x4D</span>,</span>
<span class="line" id="L72">    i32_ge_s = <span class="tok-number">0x4E</span>,</span>
<span class="line" id="L73">    i32_ge_u = <span class="tok-number">0x4F</span>,</span>
<span class="line" id="L74">    i64_eqz = <span class="tok-number">0x50</span>,</span>
<span class="line" id="L75">    i64_eq = <span class="tok-number">0x51</span>,</span>
<span class="line" id="L76">    i64_ne = <span class="tok-number">0x52</span>,</span>
<span class="line" id="L77">    i64_lt_s = <span class="tok-number">0x53</span>,</span>
<span class="line" id="L78">    i64_lt_u = <span class="tok-number">0x54</span>,</span>
<span class="line" id="L79">    i64_gt_s = <span class="tok-number">0x55</span>,</span>
<span class="line" id="L80">    i64_gt_u = <span class="tok-number">0x56</span>,</span>
<span class="line" id="L81">    i64_le_s = <span class="tok-number">0x57</span>,</span>
<span class="line" id="L82">    i64_le_u = <span class="tok-number">0x58</span>,</span>
<span class="line" id="L83">    i64_ge_s = <span class="tok-number">0x59</span>,</span>
<span class="line" id="L84">    i64_ge_u = <span class="tok-number">0x5A</span>,</span>
<span class="line" id="L85">    f32_eq = <span class="tok-number">0x5B</span>,</span>
<span class="line" id="L86">    f32_ne = <span class="tok-number">0x5C</span>,</span>
<span class="line" id="L87">    f32_lt = <span class="tok-number">0x5D</span>,</span>
<span class="line" id="L88">    f32_gt = <span class="tok-number">0x5E</span>,</span>
<span class="line" id="L89">    f32_le = <span class="tok-number">0x5F</span>,</span>
<span class="line" id="L90">    f32_ge = <span class="tok-number">0x60</span>,</span>
<span class="line" id="L91">    f64_eq = <span class="tok-number">0x61</span>,</span>
<span class="line" id="L92">    f64_ne = <span class="tok-number">0x62</span>,</span>
<span class="line" id="L93">    f64_lt = <span class="tok-number">0x63</span>,</span>
<span class="line" id="L94">    f64_gt = <span class="tok-number">0x64</span>,</span>
<span class="line" id="L95">    f64_le = <span class="tok-number">0x65</span>,</span>
<span class="line" id="L96">    f64_ge = <span class="tok-number">0x66</span>,</span>
<span class="line" id="L97">    i32_clz = <span class="tok-number">0x67</span>,</span>
<span class="line" id="L98">    i32_ctz = <span class="tok-number">0x68</span>,</span>
<span class="line" id="L99">    i32_popcnt = <span class="tok-number">0x69</span>,</span>
<span class="line" id="L100">    i32_add = <span class="tok-number">0x6A</span>,</span>
<span class="line" id="L101">    i32_sub = <span class="tok-number">0x6B</span>,</span>
<span class="line" id="L102">    i32_mul = <span class="tok-number">0x6C</span>,</span>
<span class="line" id="L103">    i32_div_s = <span class="tok-number">0x6D</span>,</span>
<span class="line" id="L104">    i32_div_u = <span class="tok-number">0x6E</span>,</span>
<span class="line" id="L105">    i32_rem_s = <span class="tok-number">0x6F</span>,</span>
<span class="line" id="L106">    i32_rem_u = <span class="tok-number">0x70</span>,</span>
<span class="line" id="L107">    i32_and = <span class="tok-number">0x71</span>,</span>
<span class="line" id="L108">    i32_or = <span class="tok-number">0x72</span>,</span>
<span class="line" id="L109">    i32_xor = <span class="tok-number">0x73</span>,</span>
<span class="line" id="L110">    i32_shl = <span class="tok-number">0x74</span>,</span>
<span class="line" id="L111">    i32_shr_s = <span class="tok-number">0x75</span>,</span>
<span class="line" id="L112">    i32_shr_u = <span class="tok-number">0x76</span>,</span>
<span class="line" id="L113">    i32_rotl = <span class="tok-number">0x77</span>,</span>
<span class="line" id="L114">    i32_rotr = <span class="tok-number">0x78</span>,</span>
<span class="line" id="L115">    i64_clz = <span class="tok-number">0x79</span>,</span>
<span class="line" id="L116">    i64_ctz = <span class="tok-number">0x7A</span>,</span>
<span class="line" id="L117">    i64_popcnt = <span class="tok-number">0x7B</span>,</span>
<span class="line" id="L118">    i64_add = <span class="tok-number">0x7C</span>,</span>
<span class="line" id="L119">    i64_sub = <span class="tok-number">0x7D</span>,</span>
<span class="line" id="L120">    i64_mul = <span class="tok-number">0x7E</span>,</span>
<span class="line" id="L121">    i64_div_s = <span class="tok-number">0x7F</span>,</span>
<span class="line" id="L122">    i64_div_u = <span class="tok-number">0x80</span>,</span>
<span class="line" id="L123">    i64_rem_s = <span class="tok-number">0x81</span>,</span>
<span class="line" id="L124">    i64_rem_u = <span class="tok-number">0x82</span>,</span>
<span class="line" id="L125">    i64_and = <span class="tok-number">0x83</span>,</span>
<span class="line" id="L126">    i64_or = <span class="tok-number">0x84</span>,</span>
<span class="line" id="L127">    i64_xor = <span class="tok-number">0x85</span>,</span>
<span class="line" id="L128">    i64_shl = <span class="tok-number">0x86</span>,</span>
<span class="line" id="L129">    i64_shr_s = <span class="tok-number">0x87</span>,</span>
<span class="line" id="L130">    i64_shr_u = <span class="tok-number">0x88</span>,</span>
<span class="line" id="L131">    i64_rotl = <span class="tok-number">0x89</span>,</span>
<span class="line" id="L132">    i64_rotr = <span class="tok-number">0x8A</span>,</span>
<span class="line" id="L133">    f32_abs = <span class="tok-number">0x8B</span>,</span>
<span class="line" id="L134">    f32_neg = <span class="tok-number">0x8C</span>,</span>
<span class="line" id="L135">    f32_ceil = <span class="tok-number">0x8D</span>,</span>
<span class="line" id="L136">    f32_floor = <span class="tok-number">0x8E</span>,</span>
<span class="line" id="L137">    f32_trunc = <span class="tok-number">0x8F</span>,</span>
<span class="line" id="L138">    f32_nearest = <span class="tok-number">0x90</span>,</span>
<span class="line" id="L139">    f32_sqrt = <span class="tok-number">0x91</span>,</span>
<span class="line" id="L140">    f32_add = <span class="tok-number">0x92</span>,</span>
<span class="line" id="L141">    f32_sub = <span class="tok-number">0x93</span>,</span>
<span class="line" id="L142">    f32_mul = <span class="tok-number">0x94</span>,</span>
<span class="line" id="L143">    f32_div = <span class="tok-number">0x95</span>,</span>
<span class="line" id="L144">    f32_min = <span class="tok-number">0x96</span>,</span>
<span class="line" id="L145">    f32_max = <span class="tok-number">0x97</span>,</span>
<span class="line" id="L146">    f32_copysign = <span class="tok-number">0x98</span>,</span>
<span class="line" id="L147">    f64_abs = <span class="tok-number">0x99</span>,</span>
<span class="line" id="L148">    f64_neg = <span class="tok-number">0x9A</span>,</span>
<span class="line" id="L149">    f64_ceil = <span class="tok-number">0x9B</span>,</span>
<span class="line" id="L150">    f64_floor = <span class="tok-number">0x9C</span>,</span>
<span class="line" id="L151">    f64_trunc = <span class="tok-number">0x9D</span>,</span>
<span class="line" id="L152">    f64_nearest = <span class="tok-number">0x9E</span>,</span>
<span class="line" id="L153">    f64_sqrt = <span class="tok-number">0x9F</span>,</span>
<span class="line" id="L154">    f64_add = <span class="tok-number">0xA0</span>,</span>
<span class="line" id="L155">    f64_sub = <span class="tok-number">0xA1</span>,</span>
<span class="line" id="L156">    f64_mul = <span class="tok-number">0xA2</span>,</span>
<span class="line" id="L157">    f64_div = <span class="tok-number">0xA3</span>,</span>
<span class="line" id="L158">    f64_min = <span class="tok-number">0xA4</span>,</span>
<span class="line" id="L159">    f64_max = <span class="tok-number">0xA5</span>,</span>
<span class="line" id="L160">    f64_copysign = <span class="tok-number">0xA6</span>,</span>
<span class="line" id="L161">    i32_wrap_i64 = <span class="tok-number">0xA7</span>,</span>
<span class="line" id="L162">    i32_trunc_f32_s = <span class="tok-number">0xA8</span>,</span>
<span class="line" id="L163">    i32_trunc_f32_u = <span class="tok-number">0xA9</span>,</span>
<span class="line" id="L164">    i32_trunc_f64_s = <span class="tok-number">0xAA</span>,</span>
<span class="line" id="L165">    i32_trunc_f64_u = <span class="tok-number">0xAB</span>,</span>
<span class="line" id="L166">    i64_extend_i32_s = <span class="tok-number">0xAC</span>,</span>
<span class="line" id="L167">    i64_extend_i32_u = <span class="tok-number">0xAD</span>,</span>
<span class="line" id="L168">    i64_trunc_f32_s = <span class="tok-number">0xAE</span>,</span>
<span class="line" id="L169">    i64_trunc_f32_u = <span class="tok-number">0xAF</span>,</span>
<span class="line" id="L170">    i64_trunc_f64_s = <span class="tok-number">0xB0</span>,</span>
<span class="line" id="L171">    i64_trunc_f64_u = <span class="tok-number">0xB1</span>,</span>
<span class="line" id="L172">    f32_convert_i32_s = <span class="tok-number">0xB2</span>,</span>
<span class="line" id="L173">    f32_convert_i32_u = <span class="tok-number">0xB3</span>,</span>
<span class="line" id="L174">    f32_convert_i64_s = <span class="tok-number">0xB4</span>,</span>
<span class="line" id="L175">    f32_convert_i64_u = <span class="tok-number">0xB5</span>,</span>
<span class="line" id="L176">    f32_demote_f64 = <span class="tok-number">0xB6</span>,</span>
<span class="line" id="L177">    f64_convert_i32_s = <span class="tok-number">0xB7</span>,</span>
<span class="line" id="L178">    f64_convert_i32_u = <span class="tok-number">0xB8</span>,</span>
<span class="line" id="L179">    f64_convert_i64_s = <span class="tok-number">0xB9</span>,</span>
<span class="line" id="L180">    f64_convert_i64_u = <span class="tok-number">0xBA</span>,</span>
<span class="line" id="L181">    f64_promote_f32 = <span class="tok-number">0xBB</span>,</span>
<span class="line" id="L182">    i32_reinterpret_f32 = <span class="tok-number">0xBC</span>,</span>
<span class="line" id="L183">    i64_reinterpret_f64 = <span class="tok-number">0xBD</span>,</span>
<span class="line" id="L184">    f32_reinterpret_i32 = <span class="tok-number">0xBE</span>,</span>
<span class="line" id="L185">    f64_reinterpret_i64 = <span class="tok-number">0xBF</span>,</span>
<span class="line" id="L186">    i32_extend8_s = <span class="tok-number">0xC0</span>,</span>
<span class="line" id="L187">    i32_extend16_s = <span class="tok-number">0xC1</span>,</span>
<span class="line" id="L188">    i64_extend8_s = <span class="tok-number">0xC2</span>,</span>
<span class="line" id="L189">    i64_extend16_s = <span class="tok-number">0xC3</span>,</span>
<span class="line" id="L190">    i64_extend32_s = <span class="tok-number">0xC4</span>,</span>
<span class="line" id="L191">    _,</span>
<span class="line" id="L192">};</span>
<span class="line" id="L193"></span>
<span class="line" id="L194"><span class="tok-comment">/// Returns the integer value of an `Opcode`. Used by the Zig compiler</span></span>
<span class="line" id="L195"><span class="tok-comment">/// to write instructions to the wasm binary file</span></span>
<span class="line" id="L196"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">opcode</span>(op: Opcode) <span class="tok-type">u8</span> {</span>
<span class="line" id="L197">    <span class="tok-kw">return</span> <span class="tok-builtin">@enumToInt</span>(op);</span>
<span class="line" id="L198">}</span>
<span class="line" id="L199"></span>
<span class="line" id="L200"><span class="tok-kw">test</span> <span class="tok-str">&quot;Wasm - opcodes&quot;</span> {</span>
<span class="line" id="L201">    <span class="tok-comment">// Ensure our opcodes values remain intact as certain values are skipped due to them being reserved</span>
</span>
<span class="line" id="L202">    <span class="tok-kw">const</span> i32_const = opcode(.i32_const);</span>
<span class="line" id="L203">    <span class="tok-kw">const</span> end = opcode(.end);</span>
<span class="line" id="L204">    <span class="tok-kw">const</span> drop = opcode(.drop);</span>
<span class="line" id="L205">    <span class="tok-kw">const</span> local_get = opcode(.local_get);</span>
<span class="line" id="L206">    <span class="tok-kw">const</span> i64_extend32_s = opcode(.i64_extend32_s);</span>
<span class="line" id="L207"></span>
<span class="line" id="L208">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, <span class="tok-number">0x41</span>), i32_const);</span>
<span class="line" id="L209">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, <span class="tok-number">0x0B</span>), end);</span>
<span class="line" id="L210">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, <span class="tok-number">0x1A</span>), drop);</span>
<span class="line" id="L211">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, <span class="tok-number">0x20</span>), local_get);</span>
<span class="line" id="L212">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u16</span>, <span class="tok-number">0xC4</span>), i64_extend32_s);</span>
<span class="line" id="L213">}</span>
<span class="line" id="L214"></span>
<span class="line" id="L215"><span class="tok-comment">/// Opcodes that require a prefix `0xFC`</span></span>
<span class="line" id="L216"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PrefixedOpcode = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L217">    i32_trunc_sat_f32_s = <span class="tok-number">0x00</span>,</span>
<span class="line" id="L218">    i32_trunc_sat_f32_u = <span class="tok-number">0x01</span>,</span>
<span class="line" id="L219">    i32_trunc_sat_f64_s = <span class="tok-number">0x02</span>,</span>
<span class="line" id="L220">    i32_trunc_sat_f64_u = <span class="tok-number">0x03</span>,</span>
<span class="line" id="L221">    i64_trunc_sat_f32_s = <span class="tok-number">0x04</span>,</span>
<span class="line" id="L222">    i64_trunc_sat_f32_u = <span class="tok-number">0x05</span>,</span>
<span class="line" id="L223">    i64_trunc_sat_f64_s = <span class="tok-number">0x06</span>,</span>
<span class="line" id="L224">    i64_trunc_sat_f64_u = <span class="tok-number">0x07</span>,</span>
<span class="line" id="L225">    memory_init = <span class="tok-number">0x08</span>,</span>
<span class="line" id="L226">    data_drop = <span class="tok-number">0x09</span>,</span>
<span class="line" id="L227">    memory_copy = <span class="tok-number">0x0A</span>,</span>
<span class="line" id="L228">    memory_fill = <span class="tok-number">0x0B</span>,</span>
<span class="line" id="L229">    table_init = <span class="tok-number">0x0C</span>,</span>
<span class="line" id="L230">    elem_drop = <span class="tok-number">0x0D</span>,</span>
<span class="line" id="L231">    table_copy = <span class="tok-number">0x0E</span>,</span>
<span class="line" id="L232">    table_grow = <span class="tok-number">0x0F</span>,</span>
<span class="line" id="L233">    table_size = <span class="tok-number">0x10</span>,</span>
<span class="line" id="L234">    table_fill = <span class="tok-number">0x11</span>,</span>
<span class="line" id="L235">};</span>
<span class="line" id="L236"></span>
<span class="line" id="L237"><span class="tok-comment">/// Enum representing all Wasm value types as per spec:</span></span>
<span class="line" id="L238"><span class="tok-comment">/// https://webassembly.github.io/spec/core/binary/types.html</span></span>
<span class="line" id="L239"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Valtype = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L240">    <span class="tok-type">i32</span> = <span class="tok-number">0x7F</span>,</span>
<span class="line" id="L241">    <span class="tok-type">i64</span> = <span class="tok-number">0x7E</span>,</span>
<span class="line" id="L242">    <span class="tok-type">f32</span> = <span class="tok-number">0x7D</span>,</span>
<span class="line" id="L243">    <span class="tok-type">f64</span> = <span class="tok-number">0x7C</span>,</span>
<span class="line" id="L244">};</span>
<span class="line" id="L245"></span>
<span class="line" id="L246"><span class="tok-comment">/// Returns the integer value of a `Valtype`</span></span>
<span class="line" id="L247"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">valtype</span>(value: Valtype) <span class="tok-type">u8</span> {</span>
<span class="line" id="L248">    <span class="tok-kw">return</span> <span class="tok-builtin">@enumToInt</span>(value);</span>
<span class="line" id="L249">}</span>
<span class="line" id="L250"></span>
<span class="line" id="L251"><span class="tok-comment">/// Reference types, where the funcref references to a function regardless of its type</span></span>
<span class="line" id="L252"><span class="tok-comment">/// and ref references an object from the embedder.</span></span>
<span class="line" id="L253"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RefType = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L254">    funcref = <span class="tok-number">0x70</span>,</span>
<span class="line" id="L255">    externref = <span class="tok-number">0x6F</span>,</span>
<span class="line" id="L256">};</span>
<span class="line" id="L257"></span>
<span class="line" id="L258"><span class="tok-comment">/// Returns the integer value of a `Reftype`</span></span>
<span class="line" id="L259"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">reftype</span>(value: RefType) <span class="tok-type">u8</span> {</span>
<span class="line" id="L260">    <span class="tok-kw">return</span> <span class="tok-builtin">@enumToInt</span>(value);</span>
<span class="line" id="L261">}</span>
<span class="line" id="L262"></span>
<span class="line" id="L263"><span class="tok-kw">test</span> <span class="tok-str">&quot;Wasm - valtypes&quot;</span> {</span>
<span class="line" id="L264">    <span class="tok-kw">const</span> _i32 = valtype(.<span class="tok-type">i32</span>);</span>
<span class="line" id="L265">    <span class="tok-kw">const</span> _i64 = valtype(.<span class="tok-type">i64</span>);</span>
<span class="line" id="L266">    <span class="tok-kw">const</span> _f32 = valtype(.<span class="tok-type">f32</span>);</span>
<span class="line" id="L267">    <span class="tok-kw">const</span> _f64 = valtype(.<span class="tok-type">f64</span>);</span>
<span class="line" id="L268"></span>
<span class="line" id="L269">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">0x7F</span>), _i32);</span>
<span class="line" id="L270">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">0x7E</span>), _i64);</span>
<span class="line" id="L271">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">0x7D</span>), _f32);</span>
<span class="line" id="L272">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">u8</span>, <span class="tok-number">0x7C</span>), _f64);</span>
<span class="line" id="L273">}</span>
<span class="line" id="L274"></span>
<span class="line" id="L275"><span class="tok-comment">/// Limits classify the size range of resizeable storage associated with memory types and table types.</span></span>
<span class="line" id="L276"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Limits = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L277">    min: <span class="tok-type">u32</span>,</span>
<span class="line" id="L278">    max: ?<span class="tok-type">u32</span>,</span>
<span class="line" id="L279">};</span>
<span class="line" id="L280"></span>
<span class="line" id="L281"><span class="tok-comment">/// Initialization expressions are used to set the initial value on an object</span></span>
<span class="line" id="L282"><span class="tok-comment">/// when a wasm module is being loaded.</span></span>
<span class="line" id="L283"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> InitExpression = <span class="tok-kw">union</span>(<span class="tok-kw">enum</span>) {</span>
<span class="line" id="L284">    i32_const: <span class="tok-type">i32</span>,</span>
<span class="line" id="L285">    i64_const: <span class="tok-type">i64</span>,</span>
<span class="line" id="L286">    f32_const: <span class="tok-type">f32</span>,</span>
<span class="line" id="L287">    f64_const: <span class="tok-type">f64</span>,</span>
<span class="line" id="L288">    global_get: <span class="tok-type">u32</span>,</span>
<span class="line" id="L289">};</span>
<span class="line" id="L290"></span>
<span class="line" id="L291"><span class="tok-comment">/// Represents a function entry, holding the index to its type</span></span>
<span class="line" id="L292"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Func = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L293">    type_index: <span class="tok-type">u32</span>,</span>
<span class="line" id="L294">};</span>
<span class="line" id="L295"></span>
<span class="line" id="L296"><span class="tok-comment">/// Tables are used to hold pointers to opaque objects.</span></span>
<span class="line" id="L297"><span class="tok-comment">/// This can either by any function, or an object from the host.</span></span>
<span class="line" id="L298"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Table = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L299">    limits: Limits,</span>
<span class="line" id="L300">    reftype: RefType,</span>
<span class="line" id="L301">};</span>
<span class="line" id="L302"></span>
<span class="line" id="L303"><span class="tok-comment">/// Describes the layout of the memory where `min` represents</span></span>
<span class="line" id="L304"><span class="tok-comment">/// the minimal amount of pages, and the optional `max` represents</span></span>
<span class="line" id="L305"><span class="tok-comment">/// the max pages. When `null` will allow the host to determine the</span></span>
<span class="line" id="L306"><span class="tok-comment">/// amount of pages.</span></span>
<span class="line" id="L307"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Memory = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L308">    limits: Limits,</span>
<span class="line" id="L309">};</span>
<span class="line" id="L310"></span>
<span class="line" id="L311"><span class="tok-comment">/// Represents the type of a `Global` or an imported global.</span></span>
<span class="line" id="L312"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> GlobalType = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L313">    valtype: Valtype,</span>
<span class="line" id="L314">    mutable: <span class="tok-type">bool</span>,</span>
<span class="line" id="L315">};</span>
<span class="line" id="L316"></span>
<span class="line" id="L317"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Global = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L318">    global_type: GlobalType,</span>
<span class="line" id="L319">    init: InitExpression,</span>
<span class="line" id="L320">};</span>
<span class="line" id="L321"></span>
<span class="line" id="L322"><span class="tok-comment">/// Notates an object to be exported from wasm</span></span>
<span class="line" id="L323"><span class="tok-comment">/// to the host.</span></span>
<span class="line" id="L324"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Export = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L325">    name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L326">    kind: ExternalKind,</span>
<span class="line" id="L327">    index: <span class="tok-type">u32</span>,</span>
<span class="line" id="L328">};</span>
<span class="line" id="L329"></span>
<span class="line" id="L330"><span class="tok-comment">/// Element describes the layout of the table that can</span></span>
<span class="line" id="L331"><span class="tok-comment">/// be found at `table_index`</span></span>
<span class="line" id="L332"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Element = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L333">    table_index: <span class="tok-type">u32</span>,</span>
<span class="line" id="L334">    offset: InitExpression,</span>
<span class="line" id="L335">    func_indexes: []<span class="tok-kw">const</span> <span class="tok-type">u32</span>,</span>
<span class="line" id="L336">};</span>
<span class="line" id="L337"></span>
<span class="line" id="L338"><span class="tok-comment">/// Imports are used to import objects from the host</span></span>
<span class="line" id="L339"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Import = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L340">    module_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L341">    name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L342">    kind: Kind,</span>
<span class="line" id="L343"></span>
<span class="line" id="L344">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Kind = <span class="tok-kw">union</span>(ExternalKind) {</span>
<span class="line" id="L345">        function: <span class="tok-type">u32</span>,</span>
<span class="line" id="L346">        table: Table,</span>
<span class="line" id="L347">        memory: Limits,</span>
<span class="line" id="L348">        global: GlobalType,</span>
<span class="line" id="L349">    };</span>
<span class="line" id="L350">};</span>
<span class="line" id="L351"></span>
<span class="line" id="L352"><span class="tok-comment">/// `Type` represents a function signature type containing both</span></span>
<span class="line" id="L353"><span class="tok-comment">/// a slice of parameters as well as a slice of return values.</span></span>
<span class="line" id="L354"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Type = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L355">    params: []<span class="tok-kw">const</span> Valtype,</span>
<span class="line" id="L356">    returns: []<span class="tok-kw">const</span> Valtype,</span>
<span class="line" id="L357"></span>
<span class="line" id="L358">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">format</span>(self: Type, <span class="tok-kw">comptime</span> fmt: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, opt: std.fmt.FormatOptions, writer: <span class="tok-kw">anytype</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L359">        _ = fmt;</span>
<span class="line" id="L360">        _ = opt;</span>
<span class="line" id="L361">        <span class="tok-kw">try</span> writer.writeByte(<span class="tok-str">'('</span>);</span>
<span class="line" id="L362">        <span class="tok-kw">for</span> (self.params) |param, i| {</span>
<span class="line" id="L363">            <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;{s}&quot;</span>, .{<span class="tok-builtin">@tagName</span>(param)});</span>
<span class="line" id="L364">            <span class="tok-kw">if</span> (i + <span class="tok-number">1</span> != self.params.len) {</span>
<span class="line" id="L365">                <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;, &quot;</span>);</span>
<span class="line" id="L366">            }</span>
<span class="line" id="L367">        }</span>
<span class="line" id="L368">        <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;) -&gt; &quot;</span>);</span>
<span class="line" id="L369">        <span class="tok-kw">if</span> (self.returns.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L370">            <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;nil&quot;</span>);</span>
<span class="line" id="L371">        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L372">            <span class="tok-kw">for</span> (self.returns) |return_ty, i| {</span>
<span class="line" id="L373">                <span class="tok-kw">try</span> writer.print(<span class="tok-str">&quot;{s}&quot;</span>, .{<span class="tok-builtin">@tagName</span>(return_ty)});</span>
<span class="line" id="L374">                <span class="tok-kw">if</span> (i + <span class="tok-number">1</span> != self.returns.len) {</span>
<span class="line" id="L375">                    <span class="tok-kw">try</span> writer.writeAll(<span class="tok-str">&quot;, &quot;</span>);</span>
<span class="line" id="L376">                }</span>
<span class="line" id="L377">            }</span>
<span class="line" id="L378">        }</span>
<span class="line" id="L379">    }</span>
<span class="line" id="L380"></span>
<span class="line" id="L381">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eql</span>(self: Type, other: Type) <span class="tok-type">bool</span> {</span>
<span class="line" id="L382">        <span class="tok-kw">return</span> std.mem.eql(Valtype, self.params, other.params) <span class="tok-kw">and</span></span>
<span class="line" id="L383">            std.mem.eql(Valtype, self.returns, other.returns);</span>
<span class="line" id="L384">    }</span>
<span class="line" id="L385"></span>
<span class="line" id="L386">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Type, gpa: std.mem.Allocator) <span class="tok-type">void</span> {</span>
<span class="line" id="L387">        gpa.free(self.params);</span>
<span class="line" id="L388">        gpa.free(self.returns);</span>
<span class="line" id="L389">        self.* = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L390">    }</span>
<span class="line" id="L391">};</span>
<span class="line" id="L392"></span>
<span class="line" id="L393"><span class="tok-comment">/// Wasm module sections as per spec:</span></span>
<span class="line" id="L394"><span class="tok-comment">/// https://webassembly.github.io/spec/core/binary/modules.html</span></span>
<span class="line" id="L395"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Section = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L396">    custom,</span>
<span class="line" id="L397">    <span class="tok-type">type</span>,</span>
<span class="line" id="L398">    import,</span>
<span class="line" id="L399">    function,</span>
<span class="line" id="L400">    table,</span>
<span class="line" id="L401">    memory,</span>
<span class="line" id="L402">    global,</span>
<span class="line" id="L403">    @&quot;export&quot;,</span>
<span class="line" id="L404">    start,</span>
<span class="line" id="L405">    element,</span>
<span class="line" id="L406">    code,</span>
<span class="line" id="L407">    data,</span>
<span class="line" id="L408">    data_count,</span>
<span class="line" id="L409">    _,</span>
<span class="line" id="L410">};</span>
<span class="line" id="L411"></span>
<span class="line" id="L412"><span class="tok-comment">/// Returns the integer value of a given `Section`</span></span>
<span class="line" id="L413"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">section</span>(val: Section) <span class="tok-type">u8</span> {</span>
<span class="line" id="L414">    <span class="tok-kw">return</span> <span class="tok-builtin">@enumToInt</span>(val);</span>
<span class="line" id="L415">}</span>
<span class="line" id="L416"></span>
<span class="line" id="L417"><span class="tok-comment">/// The kind of the type when importing or exporting to/from the host environment</span></span>
<span class="line" id="L418"><span class="tok-comment">/// https://webassembly.github.io/spec/core/syntax/modules.html</span></span>
<span class="line" id="L419"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ExternalKind = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L420">    function,</span>
<span class="line" id="L421">    table,</span>
<span class="line" id="L422">    memory,</span>
<span class="line" id="L423">    global,</span>
<span class="line" id="L424">};</span>
<span class="line" id="L425"></span>
<span class="line" id="L426"><span class="tok-comment">/// Returns the integer value of a given `ExternalKind`</span></span>
<span class="line" id="L427"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">externalKind</span>(val: ExternalKind) <span class="tok-type">u8</span> {</span>
<span class="line" id="L428">    <span class="tok-kw">return</span> <span class="tok-builtin">@enumToInt</span>(val);</span>
<span class="line" id="L429">}</span>
<span class="line" id="L430"></span>
<span class="line" id="L431"><span class="tok-comment">/// Defines the enum values for each subsection id for the &quot;Names&quot; custom section</span></span>
<span class="line" id="L432"><span class="tok-comment">/// as described by:</span></span>
<span class="line" id="L433"><span class="tok-comment">/// https://webassembly.github.io/spec/core/appendix/custom.html?highlight=name#name-section</span></span>
<span class="line" id="L434"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> NameSubsection = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L435">    module,</span>
<span class="line" id="L436">    function,</span>
<span class="line" id="L437">    local,</span>
<span class="line" id="L438">    label,</span>
<span class="line" id="L439">    <span class="tok-type">type</span>,</span>
<span class="line" id="L440">    table,</span>
<span class="line" id="L441">    memory,</span>
<span class="line" id="L442">    global,</span>
<span class="line" id="L443">    elem_segment,</span>
<span class="line" id="L444">    data_segment,</span>
<span class="line" id="L445">};</span>
<span class="line" id="L446"></span>
<span class="line" id="L447"><span class="tok-comment">// type constants</span>
</span>
<span class="line" id="L448"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> element_type: <span class="tok-type">u8</span> = <span class="tok-number">0x70</span>;</span>
<span class="line" id="L449"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> function_type: <span class="tok-type">u8</span> = <span class="tok-number">0x60</span>;</span>
<span class="line" id="L450"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> result_type: <span class="tok-type">u8</span> = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L451"></span>
<span class="line" id="L452"><span class="tok-comment">/// Represents a block which will not return a value</span></span>
<span class="line" id="L453"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> block_empty: <span class="tok-type">u8</span> = <span class="tok-number">0x40</span>;</span>
<span class="line" id="L454"></span>
<span class="line" id="L455"><span class="tok-comment">// binary constants</span>
</span>
<span class="line" id="L456"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> magic = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x00</span>, <span class="tok-number">0x61</span>, <span class="tok-number">0x73</span>, <span class="tok-number">0x6D</span> }; <span class="tok-comment">// \0asm</span>
</span>
<span class="line" id="L457"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> version = [_]<span class="tok-type">u8</span>{ <span class="tok-number">0x01</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span>, <span class="tok-number">0x00</span> }; <span class="tok-comment">// version 1 (MVP)</span>
</span>
<span class="line" id="L458"></span>
<span class="line" id="L459"><span class="tok-comment">// Each wasm page size is 64kB</span>
</span>
<span class="line" id="L460"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> page_size = <span class="tok-number">64</span> * <span class="tok-number">1024</span>;</span>
<span class="line" id="L461"></span>
</code></pre></body>
</html>