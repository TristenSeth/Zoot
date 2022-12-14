<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>target/csky.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! This file is auto-generated by tools/update_cpu_features.zig.</span></span>
<span class="line" id="L2"></span>
<span class="line" id="L3"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;../std.zig&quot;</span>);</span>
<span class="line" id="L4"><span class="tok-kw">const</span> CpuFeature = std.Target.Cpu.Feature;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> CpuModel = std.Target.Cpu.Model;</span>
<span class="line" id="L6"></span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Feature = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L8">    @&quot;10e60&quot;,</span>
<span class="line" id="L9">    @&quot;2e3&quot;,</span>
<span class="line" id="L10">    @&quot;3e3r1&quot;,</span>
<span class="line" id="L11">    @&quot;3e3r3&quot;,</span>
<span class="line" id="L12">    @&quot;3e7&quot;,</span>
<span class="line" id="L13">    @&quot;7e10&quot;,</span>
<span class="line" id="L14">    btst16,</span>
<span class="line" id="L15">    doloop,</span>
<span class="line" id="L16">    e1,</span>
<span class="line" id="L17">    e2,</span>
<span class="line" id="L18">    elrw,</span>
<span class="line" id="L19">    fpuv2_df,</span>
<span class="line" id="L20">    fpuv2_sf,</span>
<span class="line" id="L21">    fpuv3_df,</span>
<span class="line" id="L22">    fpuv3_sf,</span>
<span class="line" id="L23">    hard_float,</span>
<span class="line" id="L24">    hard_float_abi,</span>
<span class="line" id="L25">    java,</span>
<span class="line" id="L26">    mp1e2,</span>
<span class="line" id="L27">};</span>
<span class="line" id="L28"></span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> featureSet = CpuFeature.feature_set_fns(Feature).featureSet;</span>
<span class="line" id="L30"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> featureSetHas = CpuFeature.feature_set_fns(Feature).featureSetHas;</span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> featureSetHasAny = CpuFeature.feature_set_fns(Feature).featureSetHasAny;</span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> featureSetHasAll = CpuFeature.feature_set_fns(Feature).featureSetHasAll;</span>
<span class="line" id="L33"></span>
<span class="line" id="L34"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> all_features = blk: {</span>
<span class="line" id="L35">    <span class="tok-kw">const</span> len = <span class="tok-builtin">@typeInfo</span>(Feature).Enum.fields.len;</span>
<span class="line" id="L36">    std.debug.assert(len &lt;= CpuFeature.Set.needed_bit_count);</span>
<span class="line" id="L37">    <span class="tok-kw">var</span> result: [len]CpuFeature = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L38">    result[<span class="tok-builtin">@enumToInt</span>(Feature.@&quot;10e60&quot;)] = .{</span>
<span class="line" id="L39">        .llvm_name = <span class="tok-str">&quot;10e60&quot;</span>,</span>
<span class="line" id="L40">        .description = <span class="tok-str">&quot;Support CSKY 10e60 instructions&quot;</span>,</span>
<span class="line" id="L41">        .dependencies = featureSet(&amp;[_]Feature{</span>
<span class="line" id="L42">            .@&quot;7e10&quot;,</span>
<span class="line" id="L43">        }),</span>
<span class="line" id="L44">    };</span>
<span class="line" id="L45">    result[<span class="tok-builtin">@enumToInt</span>(Feature.@&quot;2e3&quot;)] = .{</span>
<span class="line" id="L46">        .llvm_name = <span class="tok-str">&quot;2e3&quot;</span>,</span>
<span class="line" id="L47">        .description = <span class="tok-str">&quot;Support CSKY 2e3 instructions&quot;</span>,</span>
<span class="line" id="L48">        .dependencies = featureSet(&amp;[_]Feature{</span>
<span class="line" id="L49">            .e2,</span>
<span class="line" id="L50">        }),</span>
<span class="line" id="L51">    };</span>
<span class="line" id="L52">    result[<span class="tok-builtin">@enumToInt</span>(Feature.@&quot;3e3r1&quot;)] = .{</span>
<span class="line" id="L53">        .llvm_name = <span class="tok-str">&quot;3e3r1&quot;</span>,</span>
<span class="line" id="L54">        .description = <span class="tok-str">&quot;Support CSKY 3e3r1 instructions&quot;</span>,</span>
<span class="line" id="L55">        .dependencies = featureSet(&amp;[_]Feature{}),</span>
<span class="line" id="L56">    };</span>
<span class="line" id="L57">    result[<span class="tok-builtin">@enumToInt</span>(Feature.@&quot;3e3r3&quot;)] = .{</span>
<span class="line" id="L58">        .llvm_name = <span class="tok-str">&quot;3e3r3&quot;</span>,</span>
<span class="line" id="L59">        .description = <span class="tok-str">&quot;Support CSKY 3e3r3 instructions&quot;</span>,</span>
<span class="line" id="L60">        .dependencies = featureSet(&amp;[_]Feature{</span>
<span class="line" id="L61">            .doloop,</span>
<span class="line" id="L62">        }),</span>
<span class="line" id="L63">    };</span>
<span class="line" id="L64">    result[<span class="tok-builtin">@enumToInt</span>(Feature.@&quot;3e7&quot;)] = .{</span>
<span class="line" id="L65">        .llvm_name = <span class="tok-str">&quot;3e7&quot;</span>,</span>
<span class="line" id="L66">        .description = <span class="tok-str">&quot;Support CSKY 3e7 instructions&quot;</span>,</span>
<span class="line" id="L67">        .dependencies = featureSet(&amp;[_]Feature{</span>
<span class="line" id="L68">            .@&quot;2e3&quot;,</span>
<span class="line" id="L69">        }),</span>
<span class="line" id="L70">    };</span>
<span class="line" id="L71">    result[<span class="tok-builtin">@enumToInt</span>(Feature.@&quot;7e10&quot;)] = .{</span>
<span class="line" id="L72">        .llvm_name = <span class="tok-str">&quot;7e10&quot;</span>,</span>
<span class="line" id="L73">        .description = <span class="tok-str">&quot;Support CSKY 7e10 instructions&quot;</span>,</span>
<span class="line" id="L74">        .dependencies = featureSet(&amp;[_]Feature{</span>
<span class="line" id="L75">            .@&quot;3e7&quot;,</span>
<span class="line" id="L76">        }),</span>
<span class="line" id="L77">    };</span>
<span class="line" id="L78">    result[<span class="tok-builtin">@enumToInt</span>(Feature.btst16)] = .{</span>
<span class="line" id="L79">        .llvm_name = <span class="tok-str">&quot;btst16&quot;</span>,</span>
<span class="line" id="L80">        .description = <span class="tok-str">&quot;Use the 16-bit btsti instruction&quot;</span>,</span>
<span class="line" id="L81">        .dependencies = featureSet(&amp;[_]Feature{}),</span>
<span class="line" id="L82">    };</span>
<span class="line" id="L83">    result[<span class="tok-builtin">@enumToInt</span>(Feature.doloop)] = .{</span>
<span class="line" id="L84">        .llvm_name = <span class="tok-str">&quot;doloop&quot;</span>,</span>
<span class="line" id="L85">        .description = <span class="tok-str">&quot;Enable doloop instructions&quot;</span>,</span>
<span class="line" id="L86">        .dependencies = featureSet(&amp;[_]Feature{}),</span>
<span class="line" id="L87">    };</span>
<span class="line" id="L88">    result[<span class="tok-builtin">@enumToInt</span>(Feature.e1)] = .{</span>
<span class="line" id="L89">        .llvm_name = <span class="tok-str">&quot;e1&quot;</span>,</span>
<span class="line" id="L90">        .description = <span class="tok-str">&quot;Support CSKY e1 instructions&quot;</span>,</span>
<span class="line" id="L91">        .dependencies = featureSet(&amp;[_]Feature{</span>
<span class="line" id="L92">            .elrw,</span>
<span class="line" id="L93">        }),</span>
<span class="line" id="L94">    };</span>
<span class="line" id="L95">    result[<span class="tok-builtin">@enumToInt</span>(Feature.e2)] = .{</span>
<span class="line" id="L96">        .llvm_name = <span class="tok-str">&quot;e2&quot;</span>,</span>
<span class="line" id="L97">        .description = <span class="tok-str">&quot;Support CSKY e2 instructions&quot;</span>,</span>
<span class="line" id="L98">        .dependencies = featureSet(&amp;[_]Feature{</span>
<span class="line" id="L99">            .e1,</span>
<span class="line" id="L100">        }),</span>
<span class="line" id="L101">    };</span>
<span class="line" id="L102">    result[<span class="tok-builtin">@enumToInt</span>(Feature.elrw)] = .{</span>
<span class="line" id="L103">        .llvm_name = <span class="tok-str">&quot;elrw&quot;</span>,</span>
<span class="line" id="L104">        .description = <span class="tok-str">&quot;Use the extend LRW instruction&quot;</span>,</span>
<span class="line" id="L105">        .dependencies = featureSet(&amp;[_]Feature{}),</span>
<span class="line" id="L106">    };</span>
<span class="line" id="L107">    result[<span class="tok-builtin">@enumToInt</span>(Feature.fpuv2_df)] = .{</span>
<span class="line" id="L108">        .llvm_name = <span class="tok-str">&quot;fpuv2_df&quot;</span>,</span>
<span class="line" id="L109">        .description = <span class="tok-str">&quot;Enable FPUv2 double float instructions&quot;</span>,</span>
<span class="line" id="L110">        .dependencies = featureSet(&amp;[_]Feature{}),</span>
<span class="line" id="L111">    };</span>
<span class="line" id="L112">    result[<span class="tok-builtin">@enumToInt</span>(Feature.fpuv2_sf)] = .{</span>
<span class="line" id="L113">        .llvm_name = <span class="tok-str">&quot;fpuv2_sf&quot;</span>,</span>
<span class="line" id="L114">        .description = <span class="tok-str">&quot;Enable FPUv2 single float instructions&quot;</span>,</span>
<span class="line" id="L115">        .dependencies = featureSet(&amp;[_]Feature{}),</span>
<span class="line" id="L116">    };</span>
<span class="line" id="L117">    result[<span class="tok-builtin">@enumToInt</span>(Feature.fpuv3_df)] = .{</span>
<span class="line" id="L118">        .llvm_name = <span class="tok-str">&quot;fpuv3_df&quot;</span>,</span>
<span class="line" id="L119">        .description = <span class="tok-str">&quot;Enable FPUv3 double float instructions&quot;</span>,</span>
<span class="line" id="L120">        .dependencies = featureSet(&amp;[_]Feature{}),</span>
<span class="line" id="L121">    };</span>
<span class="line" id="L122">    result[<span class="tok-builtin">@enumToInt</span>(Feature.fpuv3_sf)] = .{</span>
<span class="line" id="L123">        .llvm_name = <span class="tok-str">&quot;fpuv3_sf&quot;</span>,</span>
<span class="line" id="L124">        .description = <span class="tok-str">&quot;Enable FPUv3 single float instructions&quot;</span>,</span>
<span class="line" id="L125">        .dependencies = featureSet(&amp;[_]Feature{}),</span>
<span class="line" id="L126">    };</span>
<span class="line" id="L127">    result[<span class="tok-builtin">@enumToInt</span>(Feature.hard_float)] = .{</span>
<span class="line" id="L128">        .llvm_name = <span class="tok-str">&quot;hard-float&quot;</span>,</span>
<span class="line" id="L129">        .description = <span class="tok-str">&quot;Use hard floating point features&quot;</span>,</span>
<span class="line" id="L130">        .dependencies = featureSet(&amp;[_]Feature{}),</span>
<span class="line" id="L131">    };</span>
<span class="line" id="L132">    result[<span class="tok-builtin">@enumToInt</span>(Feature.hard_float_abi)] = .{</span>
<span class="line" id="L133">        .llvm_name = <span class="tok-str">&quot;hard-float-abi&quot;</span>,</span>
<span class="line" id="L134">        .description = <span class="tok-str">&quot;Use hard floating point ABI to pass args&quot;</span>,</span>
<span class="line" id="L135">        .dependencies = featureSet(&amp;[_]Feature{}),</span>
<span class="line" id="L136">    };</span>
<span class="line" id="L137">    result[<span class="tok-builtin">@enumToInt</span>(Feature.java)] = .{</span>
<span class="line" id="L138">        .llvm_name = <span class="tok-str">&quot;java&quot;</span>,</span>
<span class="line" id="L139">        .description = <span class="tok-str">&quot;Enable java instructions&quot;</span>,</span>
<span class="line" id="L140">        .dependencies = featureSet(&amp;[_]Feature{}),</span>
<span class="line" id="L141">    };</span>
<span class="line" id="L142">    result[<span class="tok-builtin">@enumToInt</span>(Feature.mp1e2)] = .{</span>
<span class="line" id="L143">        .llvm_name = <span class="tok-str">&quot;mp1e2&quot;</span>,</span>
<span class="line" id="L144">        .description = <span class="tok-str">&quot;Support CSKY mp1e2 instructions&quot;</span>,</span>
<span class="line" id="L145">        .dependencies = featureSet(&amp;[_]Feature{</span>
<span class="line" id="L146">            .@&quot;3e7&quot;,</span>
<span class="line" id="L147">        }),</span>
<span class="line" id="L148">    };</span>
<span class="line" id="L149">    <span class="tok-kw">const</span> ti = <span class="tok-builtin">@typeInfo</span>(Feature);</span>
<span class="line" id="L150">    <span class="tok-kw">for</span> (result) |*elem, i| {</span>
<span class="line" id="L151">        elem.index = i;</span>
<span class="line" id="L152">        elem.name = ti.Enum.fields[i].name;</span>
<span class="line" id="L153">    }</span>
<span class="line" id="L154">    <span class="tok-kw">break</span> :blk result;</span>
<span class="line" id="L155">};</span>
<span class="line" id="L156"></span>
<span class="line" id="L157"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> cpu = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L158">    <span class="tok-kw">pub</span> <span class="tok-kw">const</span> generic = CpuModel{</span>
<span class="line" id="L159">        .name = <span class="tok-str">&quot;generic&quot;</span>,</span>
<span class="line" id="L160">        .llvm_name = <span class="tok-str">&quot;generic&quot;</span>,</span>
<span class="line" id="L161">        .features = featureSet(&amp;[_]Feature{}),</span>
<span class="line" id="L162">    };</span>
<span class="line" id="L163">};</span>
<span class="line" id="L164"></span>
</code></pre></body>
</html>