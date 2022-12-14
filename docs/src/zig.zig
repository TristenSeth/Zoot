<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>zig.zig - source view</title>
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
<span class="line" id="L2"><span class="tok-kw">const</span> tokenizer = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;zig/tokenizer.zig&quot;</span>);</span>
<span class="line" id="L3"><span class="tok-kw">const</span> fmt = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;zig/fmt.zig&quot;</span>);</span>
<span class="line" id="L4"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L5"></span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Token = tokenizer.Token;</span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Tokenizer = tokenizer.Tokenizer;</span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> fmtId = fmt.fmtId;</span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> fmtEscapes = fmt.fmtEscapes;</span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> isValidId = fmt.isValidId;</span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> parse = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;zig/parse.zig&quot;</span>).parse;</span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> string_literal = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;zig/string_literal.zig&quot;</span>);</span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Ast = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;zig/Ast.zig&quot;</span>);</span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> system = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;zig/system.zig&quot;</span>);</span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CrossTarget = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;zig/CrossTarget.zig&quot;</span>);</span>
<span class="line" id="L16"></span>
<span class="line" id="L17"><span class="tok-comment">// Character literal parsing</span>
</span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ParsedCharLiteral = string_literal.ParsedCharLiteral;</span>
<span class="line" id="L19"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> parseCharLiteral = string_literal.parseCharLiteral;</span>
<span class="line" id="L20"></span>
<span class="line" id="L21"><span class="tok-comment">// Files needed by translate-c.</span>
</span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> c_builtins = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;zig/c_builtins.zig&quot;</span>);</span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> c_translation = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;zig/c_translation.zig&quot;</span>);</span>
<span class="line" id="L24"></span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SrcHash = [<span class="tok-number">16</span>]<span class="tok-type">u8</span>;</span>
<span class="line" id="L26"></span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashSrc</span>(src: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) SrcHash {</span>
<span class="line" id="L28">    <span class="tok-kw">var</span> out: SrcHash = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L29">    std.crypto.hash.Blake3.hash(src, &amp;out, .{});</span>
<span class="line" id="L30">    <span class="tok-kw">return</span> out;</span>
<span class="line" id="L31">}</span>
<span class="line" id="L32"></span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">srcHashEql</span>(a: SrcHash, b: SrcHash) <span class="tok-type">bool</span> {</span>
<span class="line" id="L34">    <span class="tok-kw">return</span> <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u128</span>, a) == <span class="tok-builtin">@bitCast</span>(<span class="tok-type">u128</span>, b);</span>
<span class="line" id="L35">}</span>
<span class="line" id="L36"></span>
<span class="line" id="L37"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">hashName</span>(parent_hash: SrcHash, sep: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) SrcHash {</span>
<span class="line" id="L38">    <span class="tok-kw">var</span> out: SrcHash = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L39">    <span class="tok-kw">var</span> hasher = std.crypto.hash.Blake3.init(.{});</span>
<span class="line" id="L40">    hasher.update(&amp;parent_hash);</span>
<span class="line" id="L41">    hasher.update(sep);</span>
<span class="line" id="L42">    hasher.update(name);</span>
<span class="line" id="L43">    hasher.final(&amp;out);</span>
<span class="line" id="L44">    <span class="tok-kw">return</span> out;</span>
<span class="line" id="L45">}</span>
<span class="line" id="L46"></span>
<span class="line" id="L47"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Loc = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L48">    line: <span class="tok-type">usize</span>,</span>
<span class="line" id="L49">    column: <span class="tok-type">usize</span>,</span>
<span class="line" id="L50">    <span class="tok-comment">/// Does not include the trailing newline.</span></span>
<span class="line" id="L51">    source_line: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L52"></span>
<span class="line" id="L53">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">eql</span>(a: Loc, b: Loc) <span class="tok-type">bool</span> {</span>
<span class="line" id="L54">        <span class="tok-kw">return</span> a.line == b.line <span class="tok-kw">and</span> a.column == b.column <span class="tok-kw">and</span> std.mem.eql(<span class="tok-type">u8</span>, a.source_line, b.source_line);</span>
<span class="line" id="L55">    }</span>
<span class="line" id="L56">};</span>
<span class="line" id="L57"></span>
<span class="line" id="L58"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">findLineColumn</span>(source: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, byte_offset: <span class="tok-type">usize</span>) Loc {</span>
<span class="line" id="L59">    <span class="tok-kw">var</span> line: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L60">    <span class="tok-kw">var</span> column: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L61">    <span class="tok-kw">var</span> line_start: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L62">    <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L63">    <span class="tok-kw">while</span> (i &lt; byte_offset) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L64">        <span class="tok-kw">switch</span> (source[i]) {</span>
<span class="line" id="L65">            <span class="tok-str">'\n'</span> =&gt; {</span>
<span class="line" id="L66">                line += <span class="tok-number">1</span>;</span>
<span class="line" id="L67">                column = <span class="tok-number">0</span>;</span>
<span class="line" id="L68">                line_start = i + <span class="tok-number">1</span>;</span>
<span class="line" id="L69">            },</span>
<span class="line" id="L70">            <span class="tok-kw">else</span> =&gt; {</span>
<span class="line" id="L71">                column += <span class="tok-number">1</span>;</span>
<span class="line" id="L72">            },</span>
<span class="line" id="L73">        }</span>
<span class="line" id="L74">    }</span>
<span class="line" id="L75">    <span class="tok-kw">while</span> (i &lt; source.len <span class="tok-kw">and</span> source[i] != <span class="tok-str">'\n'</span>) {</span>
<span class="line" id="L76">        i += <span class="tok-number">1</span>;</span>
<span class="line" id="L77">    }</span>
<span class="line" id="L78">    <span class="tok-kw">return</span> .{</span>
<span class="line" id="L79">        .line = line,</span>
<span class="line" id="L80">        .column = column,</span>
<span class="line" id="L81">        .source_line = source[line_start..i],</span>
<span class="line" id="L82">    };</span>
<span class="line" id="L83">}</span>
<span class="line" id="L84"></span>
<span class="line" id="L85"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">lineDelta</span>(source: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, start: <span class="tok-type">usize</span>, end: <span class="tok-type">usize</span>) <span class="tok-type">isize</span> {</span>
<span class="line" id="L86">    <span class="tok-kw">var</span> line: <span class="tok-type">isize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L87">    <span class="tok-kw">if</span> (end &gt;= start) {</span>
<span class="line" id="L88">        <span class="tok-kw">for</span> (source[start..end]) |byte| <span class="tok-kw">switch</span> (byte) {</span>
<span class="line" id="L89">            <span class="tok-str">'\n'</span> =&gt; line += <span class="tok-number">1</span>,</span>
<span class="line" id="L90">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L91">        };</span>
<span class="line" id="L92">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L93">        <span class="tok-kw">for</span> (source[end..start]) |byte| <span class="tok-kw">switch</span> (byte) {</span>
<span class="line" id="L94">            <span class="tok-str">'\n'</span> =&gt; line -= <span class="tok-number">1</span>,</span>
<span class="line" id="L95">            <span class="tok-kw">else</span> =&gt; <span class="tok-kw">continue</span>,</span>
<span class="line" id="L96">        };</span>
<span class="line" id="L97">    }</span>
<span class="line" id="L98">    <span class="tok-kw">return</span> line;</span>
<span class="line" id="L99">}</span>
<span class="line" id="L100"></span>
<span class="line" id="L101"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BinNameOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L102">    root_name: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L103">    target: std.Target,</span>
<span class="line" id="L104">    output_mode: std.builtin.OutputMode,</span>
<span class="line" id="L105">    link_mode: ?std.builtin.LinkMode = <span class="tok-null">null</span>,</span>
<span class="line" id="L106">    version: ?std.builtin.Version = <span class="tok-null">null</span>,</span>
<span class="line" id="L107">};</span>
<span class="line" id="L108"></span>
<span class="line" id="L109"><span class="tok-comment">/// Returns the standard file system basename of a binary generated by the Zig compiler.</span></span>
<span class="line" id="L110"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">binNameAlloc</span>(allocator: std.mem.Allocator, options: BinNameOptions) <span class="tok-kw">error</span>{OutOfMemory}![]<span class="tok-type">u8</span> {</span>
<span class="line" id="L111">    <span class="tok-kw">const</span> root_name = options.root_name;</span>
<span class="line" id="L112">    <span class="tok-kw">const</span> target = options.target;</span>
<span class="line" id="L113">    <span class="tok-kw">switch</span> (target.ofmt) {</span>
<span class="line" id="L114">        .coff =&gt; <span class="tok-kw">switch</span> (options.output_mode) {</span>
<span class="line" id="L115">            .Exe =&gt; <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}{s}&quot;</span>, .{ root_name, target.exeFileExt() }),</span>
<span class="line" id="L116">            .Lib =&gt; {</span>
<span class="line" id="L117">                <span class="tok-kw">const</span> suffix = <span class="tok-kw">switch</span> (options.link_mode <span class="tok-kw">orelse</span> .Static) {</span>
<span class="line" id="L118">                    .Static =&gt; <span class="tok-str">&quot;.lib&quot;</span>,</span>
<span class="line" id="L119">                    .Dynamic =&gt; <span class="tok-str">&quot;.dll&quot;</span>,</span>
<span class="line" id="L120">                };</span>
<span class="line" id="L121">                <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}{s}&quot;</span>, .{ root_name, suffix });</span>
<span class="line" id="L122">            },</span>
<span class="line" id="L123">            .Obj =&gt; <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}.obj&quot;</span>, .{root_name}),</span>
<span class="line" id="L124">        },</span>
<span class="line" id="L125">        .elf =&gt; <span class="tok-kw">switch</span> (options.output_mode) {</span>
<span class="line" id="L126">            .Exe =&gt; <span class="tok-kw">return</span> allocator.dupe(<span class="tok-type">u8</span>, root_name),</span>
<span class="line" id="L127">            .Lib =&gt; {</span>
<span class="line" id="L128">                <span class="tok-kw">switch</span> (options.link_mode <span class="tok-kw">orelse</span> .Static) {</span>
<span class="line" id="L129">                    .Static =&gt; <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}{s}.a&quot;</span>, .{</span>
<span class="line" id="L130">                        target.libPrefix(), root_name,</span>
<span class="line" id="L131">                    }),</span>
<span class="line" id="L132">                    .Dynamic =&gt; {</span>
<span class="line" id="L133">                        <span class="tok-kw">if</span> (options.version) |ver| {</span>
<span class="line" id="L134">                            <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}{s}.so.{d}.{d}.{d}&quot;</span>, .{</span>
<span class="line" id="L135">                                target.libPrefix(), root_name, ver.major, ver.minor, ver.patch,</span>
<span class="line" id="L136">                            });</span>
<span class="line" id="L137">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L138">                            <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}{s}.so&quot;</span>, .{</span>
<span class="line" id="L139">                                target.libPrefix(), root_name,</span>
<span class="line" id="L140">                            });</span>
<span class="line" id="L141">                        }</span>
<span class="line" id="L142">                    },</span>
<span class="line" id="L143">                }</span>
<span class="line" id="L144">            },</span>
<span class="line" id="L145">            .Obj =&gt; <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}.o&quot;</span>, .{root_name}),</span>
<span class="line" id="L146">        },</span>
<span class="line" id="L147">        .macho =&gt; <span class="tok-kw">switch</span> (options.output_mode) {</span>
<span class="line" id="L148">            .Exe =&gt; <span class="tok-kw">return</span> allocator.dupe(<span class="tok-type">u8</span>, root_name),</span>
<span class="line" id="L149">            .Lib =&gt; {</span>
<span class="line" id="L150">                <span class="tok-kw">switch</span> (options.link_mode <span class="tok-kw">orelse</span> .Static) {</span>
<span class="line" id="L151">                    .Static =&gt; <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}{s}.a&quot;</span>, .{</span>
<span class="line" id="L152">                        target.libPrefix(), root_name,</span>
<span class="line" id="L153">                    }),</span>
<span class="line" id="L154">                    .Dynamic =&gt; {</span>
<span class="line" id="L155">                        <span class="tok-kw">if</span> (options.version) |ver| {</span>
<span class="line" id="L156">                            <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}{s}.{d}.{d}.{d}.dylib&quot;</span>, .{</span>
<span class="line" id="L157">                                target.libPrefix(), root_name, ver.major, ver.minor, ver.patch,</span>
<span class="line" id="L158">                            });</span>
<span class="line" id="L159">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L160">                            <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}{s}.dylib&quot;</span>, .{</span>
<span class="line" id="L161">                                target.libPrefix(), root_name,</span>
<span class="line" id="L162">                            });</span>
<span class="line" id="L163">                        }</span>
<span class="line" id="L164">                    },</span>
<span class="line" id="L165">                }</span>
<span class="line" id="L166">            },</span>
<span class="line" id="L167">            .Obj =&gt; <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}.o&quot;</span>, .{root_name}),</span>
<span class="line" id="L168">        },</span>
<span class="line" id="L169">        .wasm =&gt; <span class="tok-kw">switch</span> (options.output_mode) {</span>
<span class="line" id="L170">            .Exe =&gt; <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}{s}&quot;</span>, .{ root_name, target.exeFileExt() }),</span>
<span class="line" id="L171">            .Lib =&gt; {</span>
<span class="line" id="L172">                <span class="tok-kw">switch</span> (options.link_mode <span class="tok-kw">orelse</span> .Static) {</span>
<span class="line" id="L173">                    .Static =&gt; <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}{s}.a&quot;</span>, .{</span>
<span class="line" id="L174">                        target.libPrefix(), root_name,</span>
<span class="line" id="L175">                    }),</span>
<span class="line" id="L176">                    .Dynamic =&gt; <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}.wasm&quot;</span>, .{root_name}),</span>
<span class="line" id="L177">                }</span>
<span class="line" id="L178">            },</span>
<span class="line" id="L179">            .Obj =&gt; <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}.o&quot;</span>, .{root_name}),</span>
<span class="line" id="L180">        },</span>
<span class="line" id="L181">        .c =&gt; <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}.c&quot;</span>, .{root_name}),</span>
<span class="line" id="L182">        .spirv =&gt; <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}.spv&quot;</span>, .{root_name}),</span>
<span class="line" id="L183">        .hex =&gt; <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}.ihex&quot;</span>, .{root_name}),</span>
<span class="line" id="L184">        .raw =&gt; <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}.bin&quot;</span>, .{root_name}),</span>
<span class="line" id="L185">        .plan9 =&gt; <span class="tok-kw">switch</span> (options.output_mode) {</span>
<span class="line" id="L186">            .Exe =&gt; <span class="tok-kw">return</span> allocator.dupe(<span class="tok-type">u8</span>, root_name),</span>
<span class="line" id="L187">            .Obj =&gt; <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}{s}&quot;</span>, .{</span>
<span class="line" id="L188">                root_name, target.ofmt.fileExt(target.cpu.arch),</span>
<span class="line" id="L189">            }),</span>
<span class="line" id="L190">            .Lib =&gt; <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}{s}.a&quot;</span>, .{</span>
<span class="line" id="L191">                target.libPrefix(), root_name,</span>
<span class="line" id="L192">            }),</span>
<span class="line" id="L193">        },</span>
<span class="line" id="L194">        .nvptx =&gt; <span class="tok-kw">return</span> std.fmt.allocPrint(allocator, <span class="tok-str">&quot;{s}&quot;</span>, .{root_name}),</span>
<span class="line" id="L195">    }</span>
<span class="line" id="L196">}</span>
<span class="line" id="L197"></span>
<span class="line" id="L198"><span class="tok-kw">test</span> {</span>
<span class="line" id="L199">    <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>).testing.refAllDecls(<span class="tok-builtin">@This</span>());</span>
<span class="line" id="L200">}</span>
<span class="line" id="L201"></span>
</code></pre></body>
</html>