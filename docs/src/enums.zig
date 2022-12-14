<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>enums.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-comment">//! This module contains utilities and data structures for working with enums.</span></span>
<span class="line" id="L2"></span>
<span class="line" id="L3"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std.zig&quot;</span>);</span>
<span class="line" id="L4"><span class="tok-kw">const</span> assert = std.debug.assert;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> testing = std.testing;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> EnumField = std.builtin.Type.EnumField;</span>
<span class="line" id="L7"></span>
<span class="line" id="L8"><span class="tok-comment">/// Returns a struct with a field matching each unique named enum element.</span></span>
<span class="line" id="L9"><span class="tok-comment">/// If the enum is extern and has multiple names for the same value, only</span></span>
<span class="line" id="L10"><span class="tok-comment">/// the first name is used.  Each field is of type Data and has the provided</span></span>
<span class="line" id="L11"><span class="tok-comment">/// default, which may be undefined.</span></span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">EnumFieldStruct</span>(<span class="tok-kw">comptime</span> E: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> Data: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> field_default: ?Data) <span class="tok-type">type</span> {</span>
<span class="line" id="L13">    <span class="tok-kw">const</span> StructField = std.builtin.Type.StructField;</span>
<span class="line" id="L14">    <span class="tok-kw">var</span> fields: []<span class="tok-kw">const</span> StructField = &amp;[_]StructField{};</span>
<span class="line" id="L15">    <span class="tok-kw">for</span> (std.meta.fields(E)) |field| {</span>
<span class="line" id="L16">        fields = fields ++ &amp;[_]StructField{.{</span>
<span class="line" id="L17">            .name = field.name,</span>
<span class="line" id="L18">            .field_type = Data,</span>
<span class="line" id="L19">            .default_value = <span class="tok-kw">if</span> (field_default) |d| &amp;d <span class="tok-kw">else</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L20">            .is_comptime = <span class="tok-null">false</span>,</span>
<span class="line" id="L21">            .alignment = <span class="tok-kw">if</span> (<span class="tok-builtin">@sizeOf</span>(Data) &gt; <span class="tok-number">0</span>) <span class="tok-builtin">@alignOf</span>(Data) <span class="tok-kw">else</span> <span class="tok-number">0</span>,</span>
<span class="line" id="L22">        }};</span>
<span class="line" id="L23">    }</span>
<span class="line" id="L24">    <span class="tok-kw">return</span> <span class="tok-builtin">@Type</span>(.{ .Struct = .{</span>
<span class="line" id="L25">        .layout = .Auto,</span>
<span class="line" id="L26">        .fields = fields,</span>
<span class="line" id="L27">        .decls = &amp;.{},</span>
<span class="line" id="L28">        .is_tuple = <span class="tok-null">false</span>,</span>
<span class="line" id="L29">    } });</span>
<span class="line" id="L30">}</span>
<span class="line" id="L31"></span>
<span class="line" id="L32"><span class="tok-comment">/// Looks up the supplied fields in the given enum type.</span></span>
<span class="line" id="L33"><span class="tok-comment">/// Uses only the field names, field values are ignored.</span></span>
<span class="line" id="L34"><span class="tok-comment">/// The result array is in the same order as the input.</span></span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">valuesFromFields</span>(<span class="tok-kw">comptime</span> E: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> fields: []<span class="tok-kw">const</span> EnumField) []<span class="tok-kw">const</span> E {</span>
<span class="line" id="L36">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L37">        <span class="tok-kw">var</span> result: [fields.len]E = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L38">        <span class="tok-kw">for</span> (fields) |f, i| {</span>
<span class="line" id="L39">            result[i] = <span class="tok-builtin">@field</span>(E, f.name);</span>
<span class="line" id="L40">        }</span>
<span class="line" id="L41">        <span class="tok-kw">return</span> &amp;result;</span>
<span class="line" id="L42">    }</span>
<span class="line" id="L43">}</span>
<span class="line" id="L44"></span>
<span class="line" id="L45"><span class="tok-comment">/// Returns the set of all named values in the given enum, in</span></span>
<span class="line" id="L46"><span class="tok-comment">/// declaration order.</span></span>
<span class="line" id="L47"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">values</span>(<span class="tok-kw">comptime</span> E: <span class="tok-type">type</span>) []<span class="tok-kw">const</span> E {</span>
<span class="line" id="L48">    <span class="tok-kw">return</span> <span class="tok-kw">comptime</span> valuesFromFields(E, <span class="tok-builtin">@typeInfo</span>(E).Enum.fields);</span>
<span class="line" id="L49">}</span>
<span class="line" id="L50"></span>
<span class="line" id="L51"><span class="tok-comment">/// Determines the length of a direct-mapped enum array, indexed by</span></span>
<span class="line" id="L52"><span class="tok-comment">/// @intCast(usize, @enumToInt(enum_value)).</span></span>
<span class="line" id="L53"><span class="tok-comment">/// If the enum is non-exhaustive, the resulting length will only be enough</span></span>
<span class="line" id="L54"><span class="tok-comment">/// to hold all explicit fields.</span></span>
<span class="line" id="L55"><span class="tok-comment">/// If the enum contains any fields with values that cannot be represented</span></span>
<span class="line" id="L56"><span class="tok-comment">/// by usize, a compile error is issued.  The max_unused_slots parameter limits</span></span>
<span class="line" id="L57"><span class="tok-comment">/// the total number of items which have no matching enum key (holes in the enum</span></span>
<span class="line" id="L58"><span class="tok-comment">/// numbering).  So for example, if an enum has values 1, 2, 5, and 6, max_unused_slots</span></span>
<span class="line" id="L59"><span class="tok-comment">/// must be at least 3, to allow unused slots 0, 3, and 4.</span></span>
<span class="line" id="L60"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">directEnumArrayLen</span>(<span class="tok-kw">comptime</span> E: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> max_unused_slots: <span class="tok-type">comptime_int</span>) <span class="tok-type">comptime_int</span> {</span>
<span class="line" id="L61">    <span class="tok-kw">var</span> max_value: <span class="tok-type">comptime_int</span> = -<span class="tok-number">1</span>;</span>
<span class="line" id="L62">    <span class="tok-kw">const</span> max_usize: <span class="tok-type">comptime_int</span> = ~<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>);</span>
<span class="line" id="L63">    <span class="tok-kw">const</span> fields = std.meta.fields(E);</span>
<span class="line" id="L64">    <span class="tok-kw">for</span> (fields) |f| {</span>
<span class="line" id="L65">        <span class="tok-kw">if</span> (f.value &lt; <span class="tok-number">0</span>) {</span>
<span class="line" id="L66">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot create a direct enum array for &quot;</span> ++ <span class="tok-builtin">@typeName</span>(E) ++ <span class="tok-str">&quot;, field .&quot;</span> ++ f.name ++ <span class="tok-str">&quot; has a negative value.&quot;</span>);</span>
<span class="line" id="L67">        }</span>
<span class="line" id="L68">        <span class="tok-kw">if</span> (f.value &gt; max_value) {</span>
<span class="line" id="L69">            <span class="tok-kw">if</span> (f.value &gt; max_usize) {</span>
<span class="line" id="L70">                <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot create a direct enum array for &quot;</span> ++ <span class="tok-builtin">@typeName</span>(E) ++ <span class="tok-str">&quot;, field .&quot;</span> ++ f.name ++ <span class="tok-str">&quot; is larger than the max value of usize.&quot;</span>);</span>
<span class="line" id="L71">            }</span>
<span class="line" id="L72">            max_value = f.value;</span>
<span class="line" id="L73">        }</span>
<span class="line" id="L74">    }</span>
<span class="line" id="L75"></span>
<span class="line" id="L76">    <span class="tok-kw">const</span> unused_slots = max_value + <span class="tok-number">1</span> - fields.len;</span>
<span class="line" id="L77">    <span class="tok-kw">if</span> (unused_slots &gt; max_unused_slots) {</span>
<span class="line" id="L78">        <span class="tok-kw">const</span> unused_str = std.fmt.comptimePrint(<span class="tok-str">&quot;{d}&quot;</span>, .{unused_slots});</span>
<span class="line" id="L79">        <span class="tok-kw">const</span> allowed_str = std.fmt.comptimePrint(<span class="tok-str">&quot;{d}&quot;</span>, .{max_unused_slots});</span>
<span class="line" id="L80">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot create a direct enum array for &quot;</span> ++ <span class="tok-builtin">@typeName</span>(E) ++ <span class="tok-str">&quot;. It would have &quot;</span> ++ unused_str ++ <span class="tok-str">&quot; unused slots, but only &quot;</span> ++ allowed_str ++ <span class="tok-str">&quot; are allowed.&quot;</span>);</span>
<span class="line" id="L81">    }</span>
<span class="line" id="L82"></span>
<span class="line" id="L83">    <span class="tok-kw">return</span> max_value + <span class="tok-number">1</span>;</span>
<span class="line" id="L84">}</span>
<span class="line" id="L85"></span>
<span class="line" id="L86"><span class="tok-comment">/// Initializes an array of Data which can be indexed by</span></span>
<span class="line" id="L87"><span class="tok-comment">/// @intCast(usize, @enumToInt(enum_value)).</span></span>
<span class="line" id="L88"><span class="tok-comment">/// If the enum is non-exhaustive, the resulting array will only be large enough</span></span>
<span class="line" id="L89"><span class="tok-comment">/// to hold all explicit fields.</span></span>
<span class="line" id="L90"><span class="tok-comment">/// If the enum contains any fields with values that cannot be represented</span></span>
<span class="line" id="L91"><span class="tok-comment">/// by usize, a compile error is issued.  The max_unused_slots parameter limits</span></span>
<span class="line" id="L92"><span class="tok-comment">/// the total number of items which have no matching enum key (holes in the enum</span></span>
<span class="line" id="L93"><span class="tok-comment">/// numbering).  So for example, if an enum has values 1, 2, 5, and 6, max_unused_slots</span></span>
<span class="line" id="L94"><span class="tok-comment">/// must be at least 3, to allow unused slots 0, 3, and 4.</span></span>
<span class="line" id="L95"><span class="tok-comment">/// The init_values parameter must be a struct with field names that match the enum values.</span></span>
<span class="line" id="L96"><span class="tok-comment">/// If the enum has multiple fields with the same value, the name of the first one must</span></span>
<span class="line" id="L97"><span class="tok-comment">/// be used.</span></span>
<span class="line" id="L98"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">directEnumArray</span>(</span>
<span class="line" id="L99">    <span class="tok-kw">comptime</span> E: <span class="tok-type">type</span>,</span>
<span class="line" id="L100">    <span class="tok-kw">comptime</span> Data: <span class="tok-type">type</span>,</span>
<span class="line" id="L101">    <span class="tok-kw">comptime</span> max_unused_slots: <span class="tok-type">comptime_int</span>,</span>
<span class="line" id="L102">    init_values: EnumFieldStruct(E, Data, <span class="tok-null">null</span>),</span>
<span class="line" id="L103">) [directEnumArrayLen(E, max_unused_slots)]Data {</span>
<span class="line" id="L104">    <span class="tok-kw">return</span> directEnumArrayDefault(E, Data, <span class="tok-null">null</span>, max_unused_slots, init_values);</span>
<span class="line" id="L105">}</span>
<span class="line" id="L106"></span>
<span class="line" id="L107"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.enums.directEnumArray&quot;</span> {</span>
<span class="line" id="L108">    <span class="tok-kw">const</span> E = <span class="tok-kw">enum</span>(<span class="tok-type">i4</span>) { a = <span class="tok-number">4</span>, b = <span class="tok-number">6</span>, c = <span class="tok-number">2</span> };</span>
<span class="line" id="L109">    <span class="tok-kw">var</span> runtime_false: <span class="tok-type">bool</span> = <span class="tok-null">false</span>;</span>
<span class="line" id="L110">    <span class="tok-kw">const</span> array = directEnumArray(E, <span class="tok-type">bool</span>, <span class="tok-number">4</span>, .{</span>
<span class="line" id="L111">        .a = <span class="tok-null">true</span>,</span>
<span class="line" id="L112">        .b = runtime_false,</span>
<span class="line" id="L113">        .c = <span class="tok-null">true</span>,</span>
<span class="line" id="L114">    });</span>
<span class="line" id="L115"></span>
<span class="line" id="L116">    <span class="tok-kw">try</span> testing.expectEqual([<span class="tok-number">7</span>]<span class="tok-type">bool</span>, <span class="tok-builtin">@TypeOf</span>(array));</span>
<span class="line" id="L117">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">true</span>, array[<span class="tok-number">4</span>]);</span>
<span class="line" id="L118">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">false</span>, array[<span class="tok-number">6</span>]);</span>
<span class="line" id="L119">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">true</span>, array[<span class="tok-number">2</span>]);</span>
<span class="line" id="L120">}</span>
<span class="line" id="L121"></span>
<span class="line" id="L122"><span class="tok-comment">/// Initializes an array of Data which can be indexed by</span></span>
<span class="line" id="L123"><span class="tok-comment">/// @intCast(usize, @enumToInt(enum_value)).  The enum must be exhaustive.</span></span>
<span class="line" id="L124"><span class="tok-comment">/// If the enum contains any fields with values that cannot be represented</span></span>
<span class="line" id="L125"><span class="tok-comment">/// by usize, a compile error is issued.  The max_unused_slots parameter limits</span></span>
<span class="line" id="L126"><span class="tok-comment">/// the total number of items which have no matching enum key (holes in the enum</span></span>
<span class="line" id="L127"><span class="tok-comment">/// numbering).  So for example, if an enum has values 1, 2, 5, and 6, max_unused_slots</span></span>
<span class="line" id="L128"><span class="tok-comment">/// must be at least 3, to allow unused slots 0, 3, and 4.</span></span>
<span class="line" id="L129"><span class="tok-comment">/// The init_values parameter must be a struct with field names that match the enum values.</span></span>
<span class="line" id="L130"><span class="tok-comment">/// If the enum has multiple fields with the same value, the name of the first one must</span></span>
<span class="line" id="L131"><span class="tok-comment">/// be used.</span></span>
<span class="line" id="L132"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">directEnumArrayDefault</span>(</span>
<span class="line" id="L133">    <span class="tok-kw">comptime</span> E: <span class="tok-type">type</span>,</span>
<span class="line" id="L134">    <span class="tok-kw">comptime</span> Data: <span class="tok-type">type</span>,</span>
<span class="line" id="L135">    <span class="tok-kw">comptime</span> default: ?Data,</span>
<span class="line" id="L136">    <span class="tok-kw">comptime</span> max_unused_slots: <span class="tok-type">comptime_int</span>,</span>
<span class="line" id="L137">    init_values: EnumFieldStruct(E, Data, default),</span>
<span class="line" id="L138">) [directEnumArrayLen(E, max_unused_slots)]Data {</span>
<span class="line" id="L139">    <span class="tok-kw">const</span> len = <span class="tok-kw">comptime</span> directEnumArrayLen(E, max_unused_slots);</span>
<span class="line" id="L140">    <span class="tok-kw">var</span> result: [len]Data = <span class="tok-kw">if</span> (default) |d| [_]Data{d} ** len <span class="tok-kw">else</span> <span class="tok-null">undefined</span>;</span>
<span class="line" id="L141">    <span class="tok-kw">inline</span> <span class="tok-kw">for</span> (<span class="tok-builtin">@typeInfo</span>(<span class="tok-builtin">@TypeOf</span>(init_values)).Struct.fields) |f| {</span>
<span class="line" id="L142">        <span class="tok-kw">const</span> enum_value = <span class="tok-builtin">@field</span>(E, f.name);</span>
<span class="line" id="L143">        <span class="tok-kw">const</span> index = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@enumToInt</span>(enum_value));</span>
<span class="line" id="L144">        result[index] = <span class="tok-builtin">@field</span>(init_values, f.name);</span>
<span class="line" id="L145">    }</span>
<span class="line" id="L146">    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L147">}</span>
<span class="line" id="L148"></span>
<span class="line" id="L149"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.enums.directEnumArrayDefault&quot;</span> {</span>
<span class="line" id="L150">    <span class="tok-kw">const</span> E = <span class="tok-kw">enum</span>(<span class="tok-type">i4</span>) { a = <span class="tok-number">4</span>, b = <span class="tok-number">6</span>, c = <span class="tok-number">2</span> };</span>
<span class="line" id="L151">    <span class="tok-kw">var</span> runtime_false: <span class="tok-type">bool</span> = <span class="tok-null">false</span>;</span>
<span class="line" id="L152">    <span class="tok-kw">const</span> array = directEnumArrayDefault(E, <span class="tok-type">bool</span>, <span class="tok-null">false</span>, <span class="tok-number">4</span>, .{</span>
<span class="line" id="L153">        .a = <span class="tok-null">true</span>,</span>
<span class="line" id="L154">        .b = runtime_false,</span>
<span class="line" id="L155">    });</span>
<span class="line" id="L156"></span>
<span class="line" id="L157">    <span class="tok-kw">try</span> testing.expectEqual([<span class="tok-number">7</span>]<span class="tok-type">bool</span>, <span class="tok-builtin">@TypeOf</span>(array));</span>
<span class="line" id="L158">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">true</span>, array[<span class="tok-number">4</span>]);</span>
<span class="line" id="L159">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">false</span>, array[<span class="tok-number">6</span>]);</span>
<span class="line" id="L160">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-null">false</span>, array[<span class="tok-number">2</span>]);</span>
<span class="line" id="L161">}</span>
<span class="line" id="L162"></span>
<span class="line" id="L163"><span class="tok-comment">/// Cast an enum literal, value, or string to the enum value of type E</span></span>
<span class="line" id="L164"><span class="tok-comment">/// with the same name.</span></span>
<span class="line" id="L165"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">nameCast</span>(<span class="tok-kw">comptime</span> E: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> value: <span class="tok-kw">anytype</span>) E {</span>
<span class="line" id="L166">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L167">        <span class="tok-kw">const</span> V = <span class="tok-builtin">@TypeOf</span>(value);</span>
<span class="line" id="L168">        <span class="tok-kw">if</span> (V == E) <span class="tok-kw">return</span> value;</span>
<span class="line" id="L169">        <span class="tok-kw">var</span> name: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-kw">switch</span> (<span class="tok-builtin">@typeInfo</span>(V)) {</span>
<span class="line" id="L170">            .EnumLiteral, .Enum =&gt; <span class="tok-builtin">@tagName</span>(value),</span>
<span class="line" id="L171">            .Pointer =&gt; <span class="tok-kw">if</span> (std.meta.trait.isZigString(V)) value <span class="tok-kw">else</span> <span class="tok-null">null</span>,</span>
<span class="line" id="L172">            <span class="tok-kw">else</span> =&gt; <span class="tok-null">null</span>,</span>
<span class="line" id="L173">        };</span>
<span class="line" id="L174">        <span class="tok-kw">if</span> (name) |n| {</span>
<span class="line" id="L175">            <span class="tok-kw">if</span> (<span class="tok-builtin">@hasField</span>(E, n)) {</span>
<span class="line" id="L176">                <span class="tok-kw">return</span> <span class="tok-builtin">@field</span>(E, n);</span>
<span class="line" id="L177">            }</span>
<span class="line" id="L178">            <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Enum &quot;</span> ++ <span class="tok-builtin">@typeName</span>(E) ++ <span class="tok-str">&quot; has no field named &quot;</span> ++ n);</span>
<span class="line" id="L179">        }</span>
<span class="line" id="L180">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot cast from &quot;</span> ++ <span class="tok-builtin">@typeName</span>(<span class="tok-builtin">@TypeOf</span>(value)) ++ <span class="tok-str">&quot; to &quot;</span> ++ <span class="tok-builtin">@typeName</span>(E));</span>
<span class="line" id="L181">    }</span>
<span class="line" id="L182">}</span>
<span class="line" id="L183"></span>
<span class="line" id="L184"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.enums.nameCast&quot;</span> {</span>
<span class="line" id="L185">    <span class="tok-kw">const</span> A = <span class="tok-kw">enum</span>(<span class="tok-type">u1</span>) { a = <span class="tok-number">0</span>, b = <span class="tok-number">1</span> };</span>
<span class="line" id="L186">    <span class="tok-kw">const</span> B = <span class="tok-kw">enum</span>(<span class="tok-type">u1</span>) { a = <span class="tok-number">1</span>, b = <span class="tok-number">0</span> };</span>
<span class="line" id="L187">    <span class="tok-kw">try</span> testing.expectEqual(A.a, nameCast(A, .a));</span>
<span class="line" id="L188">    <span class="tok-kw">try</span> testing.expectEqual(A.a, nameCast(A, A.a));</span>
<span class="line" id="L189">    <span class="tok-kw">try</span> testing.expectEqual(A.a, nameCast(A, B.a));</span>
<span class="line" id="L190">    <span class="tok-kw">try</span> testing.expectEqual(A.a, nameCast(A, <span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L191">    <span class="tok-kw">try</span> testing.expectEqual(A.a, nameCast(A, <span class="tok-builtin">@as</span>(*<span class="tok-kw">const</span> [<span class="tok-number">1</span>]<span class="tok-type">u8</span>, <span class="tok-str">&quot;a&quot;</span>)));</span>
<span class="line" id="L192">    <span class="tok-kw">try</span> testing.expectEqual(A.a, nameCast(A, <span class="tok-builtin">@as</span>([:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-str">&quot;a&quot;</span>)));</span>
<span class="line" id="L193">    <span class="tok-kw">try</span> testing.expectEqual(A.a, nameCast(A, <span class="tok-builtin">@as</span>([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, <span class="tok-str">&quot;a&quot;</span>)));</span>
<span class="line" id="L194"></span>
<span class="line" id="L195">    <span class="tok-kw">try</span> testing.expectEqual(B.a, nameCast(B, .a));</span>
<span class="line" id="L196">    <span class="tok-kw">try</span> testing.expectEqual(B.a, nameCast(B, A.a));</span>
<span class="line" id="L197">    <span class="tok-kw">try</span> testing.expectEqual(B.a, nameCast(B, B.a));</span>
<span class="line" id="L198">    <span class="tok-kw">try</span> testing.expectEqual(B.a, nameCast(B, <span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L199"></span>
<span class="line" id="L200">    <span class="tok-kw">try</span> testing.expectEqual(B.b, nameCast(B, .b));</span>
<span class="line" id="L201">    <span class="tok-kw">try</span> testing.expectEqual(B.b, nameCast(B, A.b));</span>
<span class="line" id="L202">    <span class="tok-kw">try</span> testing.expectEqual(B.b, nameCast(B, B.b));</span>
<span class="line" id="L203">    <span class="tok-kw">try</span> testing.expectEqual(B.b, nameCast(B, <span class="tok-str">&quot;b&quot;</span>));</span>
<span class="line" id="L204">}</span>
<span class="line" id="L205"></span>
<span class="line" id="L206"><span class="tok-comment">/// A set of enum elements, backed by a bitfield.  If the enum</span></span>
<span class="line" id="L207"><span class="tok-comment">/// is not dense, a mapping will be constructed from enum values</span></span>
<span class="line" id="L208"><span class="tok-comment">/// to dense indices.  This type does no dynamic allocation and</span></span>
<span class="line" id="L209"><span class="tok-comment">/// can be copied by value.</span></span>
<span class="line" id="L210"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">EnumSet</span>(<span class="tok-kw">comptime</span> E: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L211">    <span class="tok-kw">const</span> mixin = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L212">        <span class="tok-kw">fn</span> <span class="tok-fn">EnumSetExt</span>(<span class="tok-kw">comptime</span> Self: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L213">            <span class="tok-kw">const</span> Indexer = Self.Indexer;</span>
<span class="line" id="L214">            <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L215">                <span class="tok-comment">/// Initializes the set using a struct of bools</span></span>
<span class="line" id="L216">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(init_values: EnumFieldStruct(E, <span class="tok-type">bool</span>, <span class="tok-null">false</span>)) Self {</span>
<span class="line" id="L217">                    <span class="tok-kw">var</span> result = Self{};</span>
<span class="line" id="L218">                    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L219">                    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; Self.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L220">                        <span class="tok-kw">const</span> key = <span class="tok-kw">comptime</span> Indexer.keyForIndex(i);</span>
<span class="line" id="L221">                        <span class="tok-kw">const</span> tag = <span class="tok-kw">comptime</span> <span class="tok-builtin">@tagName</span>(key);</span>
<span class="line" id="L222">                        <span class="tok-kw">if</span> (<span class="tok-builtin">@field</span>(init_values, tag)) {</span>
<span class="line" id="L223">                            result.bits.set(i);</span>
<span class="line" id="L224">                        }</span>
<span class="line" id="L225">                    }</span>
<span class="line" id="L226">                    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L227">                }</span>
<span class="line" id="L228">            };</span>
<span class="line" id="L229">        }</span>
<span class="line" id="L230">    };</span>
<span class="line" id="L231">    <span class="tok-kw">return</span> IndexedSet(EnumIndexer(E), mixin.EnumSetExt);</span>
<span class="line" id="L232">}</span>
<span class="line" id="L233"></span>
<span class="line" id="L234"><span class="tok-comment">/// A map keyed by an enum, backed by a bitfield and a dense array.</span></span>
<span class="line" id="L235"><span class="tok-comment">/// If the enum is not dense, a mapping will be constructed from</span></span>
<span class="line" id="L236"><span class="tok-comment">/// enum values to dense indices.  This type does no dynamic</span></span>
<span class="line" id="L237"><span class="tok-comment">/// allocation and can be copied by value.</span></span>
<span class="line" id="L238"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">EnumMap</span>(<span class="tok-kw">comptime</span> E: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> V: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L239">    <span class="tok-kw">const</span> mixin = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L240">        <span class="tok-kw">fn</span> <span class="tok-fn">EnumMapExt</span>(<span class="tok-kw">comptime</span> Self: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L241">            <span class="tok-kw">const</span> Indexer = Self.Indexer;</span>
<span class="line" id="L242">            <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L243">                <span class="tok-comment">/// Initializes the map using a sparse struct of optionals</span></span>
<span class="line" id="L244">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(init_values: EnumFieldStruct(E, ?V, <span class="tok-builtin">@as</span>(?V, <span class="tok-null">null</span>))) Self {</span>
<span class="line" id="L245">                    <span class="tok-kw">var</span> result = Self{};</span>
<span class="line" id="L246">                    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L247">                    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; Self.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L248">                        <span class="tok-kw">const</span> key = <span class="tok-kw">comptime</span> Indexer.keyForIndex(i);</span>
<span class="line" id="L249">                        <span class="tok-kw">const</span> tag = <span class="tok-kw">comptime</span> <span class="tok-builtin">@tagName</span>(key);</span>
<span class="line" id="L250">                        <span class="tok-kw">if</span> (<span class="tok-builtin">@field</span>(init_values, tag)) |*v| {</span>
<span class="line" id="L251">                            result.bits.set(i);</span>
<span class="line" id="L252">                            result.values[i] = v.*;</span>
<span class="line" id="L253">                        }</span>
<span class="line" id="L254">                    }</span>
<span class="line" id="L255">                    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L256">                }</span>
<span class="line" id="L257">                <span class="tok-comment">/// Initializes a full mapping with all keys set to value.</span></span>
<span class="line" id="L258">                <span class="tok-comment">/// Consider using EnumArray instead if the map will remain full.</span></span>
<span class="line" id="L259">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initFull</span>(value: V) Self {</span>
<span class="line" id="L260">                    <span class="tok-kw">var</span> result = Self{</span>
<span class="line" id="L261">                        .bits = Self.BitSet.initFull(),</span>
<span class="line" id="L262">                        .values = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L263">                    };</span>
<span class="line" id="L264">                    std.mem.set(V, &amp;result.values, value);</span>
<span class="line" id="L265">                    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L266">                }</span>
<span class="line" id="L267">                <span class="tok-comment">/// Initializes a full mapping with supplied values.</span></span>
<span class="line" id="L268">                <span class="tok-comment">/// Consider using EnumArray instead if the map will remain full.</span></span>
<span class="line" id="L269">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initFullWith</span>(init_values: EnumFieldStruct(E, V, <span class="tok-builtin">@as</span>(?V, <span class="tok-null">null</span>))) Self {</span>
<span class="line" id="L270">                    <span class="tok-kw">return</span> initFullWithDefault(<span class="tok-builtin">@as</span>(?V, <span class="tok-null">null</span>), init_values);</span>
<span class="line" id="L271">                }</span>
<span class="line" id="L272">                <span class="tok-comment">/// Initializes a full mapping with a provided default.</span></span>
<span class="line" id="L273">                <span class="tok-comment">/// Consider using EnumArray instead if the map will remain full.</span></span>
<span class="line" id="L274">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initFullWithDefault</span>(<span class="tok-kw">comptime</span> default: ?V, init_values: EnumFieldStruct(E, V, default)) Self {</span>
<span class="line" id="L275">                    <span class="tok-kw">var</span> result = Self{</span>
<span class="line" id="L276">                        .bits = Self.BitSet.initFull(),</span>
<span class="line" id="L277">                        .values = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L278">                    };</span>
<span class="line" id="L279">                    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L280">                    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; Self.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L281">                        <span class="tok-kw">const</span> key = <span class="tok-kw">comptime</span> Indexer.keyForIndex(i);</span>
<span class="line" id="L282">                        <span class="tok-kw">const</span> tag = <span class="tok-kw">comptime</span> <span class="tok-builtin">@tagName</span>(key);</span>
<span class="line" id="L283">                        result.values[i] = <span class="tok-builtin">@field</span>(init_values, tag);</span>
<span class="line" id="L284">                    }</span>
<span class="line" id="L285">                    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L286">                }</span>
<span class="line" id="L287">            };</span>
<span class="line" id="L288">        }</span>
<span class="line" id="L289">    };</span>
<span class="line" id="L290">    <span class="tok-kw">return</span> IndexedMap(EnumIndexer(E), V, mixin.EnumMapExt);</span>
<span class="line" id="L291">}</span>
<span class="line" id="L292"></span>
<span class="line" id="L293"><span class="tok-comment">/// An array keyed by an enum, backed by a dense array.</span></span>
<span class="line" id="L294"><span class="tok-comment">/// If the enum is not dense, a mapping will be constructed from</span></span>
<span class="line" id="L295"><span class="tok-comment">/// enum values to dense indices.  This type does no dynamic</span></span>
<span class="line" id="L296"><span class="tok-comment">/// allocation and can be copied by value.</span></span>
<span class="line" id="L297"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">EnumArray</span>(<span class="tok-kw">comptime</span> E: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> V: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L298">    <span class="tok-kw">const</span> mixin = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L299">        <span class="tok-kw">fn</span> <span class="tok-fn">EnumArrayExt</span>(<span class="tok-kw">comptime</span> Self: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L300">            <span class="tok-kw">const</span> Indexer = Self.Indexer;</span>
<span class="line" id="L301">            <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L302">                <span class="tok-comment">/// Initializes all values in the enum array</span></span>
<span class="line" id="L303">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">init</span>(init_values: EnumFieldStruct(E, V, <span class="tok-builtin">@as</span>(?V, <span class="tok-null">null</span>))) Self {</span>
<span class="line" id="L304">                    <span class="tok-kw">return</span> initDefault(<span class="tok-builtin">@as</span>(?V, <span class="tok-null">null</span>), init_values);</span>
<span class="line" id="L305">                }</span>
<span class="line" id="L306"></span>
<span class="line" id="L307">                <span class="tok-comment">/// Initializes values in the enum array, with the specified default.</span></span>
<span class="line" id="L308">                <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initDefault</span>(<span class="tok-kw">comptime</span> default: ?V, init_values: EnumFieldStruct(E, V, default)) Self {</span>
<span class="line" id="L309">                    <span class="tok-kw">var</span> result = Self{ .values = <span class="tok-null">undefined</span> };</span>
<span class="line" id="L310">                    <span class="tok-kw">comptime</span> <span class="tok-kw">var</span> i: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L311">                    <span class="tok-kw">inline</span> <span class="tok-kw">while</span> (i &lt; Self.len) : (i += <span class="tok-number">1</span>) {</span>
<span class="line" id="L312">                        <span class="tok-kw">const</span> key = <span class="tok-kw">comptime</span> Indexer.keyForIndex(i);</span>
<span class="line" id="L313">                        <span class="tok-kw">const</span> tag = <span class="tok-builtin">@tagName</span>(key);</span>
<span class="line" id="L314">                        result.values[i] = <span class="tok-builtin">@field</span>(init_values, tag);</span>
<span class="line" id="L315">                    }</span>
<span class="line" id="L316">                    <span class="tok-kw">return</span> result;</span>
<span class="line" id="L317">                }</span>
<span class="line" id="L318">            };</span>
<span class="line" id="L319">        }</span>
<span class="line" id="L320">    };</span>
<span class="line" id="L321">    <span class="tok-kw">return</span> IndexedArray(EnumIndexer(E), V, mixin.EnumArrayExt);</span>
<span class="line" id="L322">}</span>
<span class="line" id="L323"></span>
<span class="line" id="L324"><span class="tok-comment">/// Pass this function as the Ext parameter to Indexed* if you</span></span>
<span class="line" id="L325"><span class="tok-comment">/// do not want to attach any extensions.  This parameter was</span></span>
<span class="line" id="L326"><span class="tok-comment">/// originally an optional, but optional generic functions</span></span>
<span class="line" id="L327"><span class="tok-comment">/// seem to be broken at the moment.</span></span>
<span class="line" id="L328"><span class="tok-comment">/// TODO: Once #8169 is fixed, consider switching this param</span></span>
<span class="line" id="L329"><span class="tok-comment">/// back to an optional.</span></span>
<span class="line" id="L330"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">NoExtension</span>(<span class="tok-kw">comptime</span> Self: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L331">    _ = Self;</span>
<span class="line" id="L332">    <span class="tok-kw">return</span> NoExt;</span>
<span class="line" id="L333">}</span>
<span class="line" id="L334"><span class="tok-kw">const</span> NoExt = <span class="tok-kw">struct</span> {};</span>
<span class="line" id="L335"></span>
<span class="line" id="L336"><span class="tok-comment">/// A set type with an Indexer mapping from keys to indices.</span></span>
<span class="line" id="L337"><span class="tok-comment">/// Presence or absence is stored as a dense bitfield.  This</span></span>
<span class="line" id="L338"><span class="tok-comment">/// type does no allocation and can be copied by value.</span></span>
<span class="line" id="L339"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">IndexedSet</span>(<span class="tok-kw">comptime</span> I: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> Ext: <span class="tok-kw">fn</span> (<span class="tok-type">type</span>) <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L340">    <span class="tok-kw">comptime</span> ensureIndexer(I);</span>
<span class="line" id="L341">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L342">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L343"></span>
<span class="line" id="L344">        <span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> Ext(Self);</span>
<span class="line" id="L345"></span>
<span class="line" id="L346">        <span class="tok-comment">/// The indexing rules for converting between keys and indices.</span></span>
<span class="line" id="L347">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Indexer = I;</span>
<span class="line" id="L348">        <span class="tok-comment">/// The element type for this set.</span></span>
<span class="line" id="L349">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Key = Indexer.Key;</span>
<span class="line" id="L350"></span>
<span class="line" id="L351">        <span class="tok-kw">const</span> BitSet = std.StaticBitSet(Indexer.count);</span>
<span class="line" id="L352"></span>
<span class="line" id="L353">        <span class="tok-comment">/// The maximum number of items in this set.</span></span>
<span class="line" id="L354">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> len = Indexer.count;</span>
<span class="line" id="L355"></span>
<span class="line" id="L356">        bits: BitSet = BitSet.initEmpty(),</span>
<span class="line" id="L357"></span>
<span class="line" id="L358">        <span class="tok-comment">/// Returns a set containing all possible keys.</span></span>
<span class="line" id="L359">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initFull</span>() Self {</span>
<span class="line" id="L360">            <span class="tok-kw">return</span> .{ .bits = BitSet.initFull() };</span>
<span class="line" id="L361">        }</span>
<span class="line" id="L362"></span>
<span class="line" id="L363">        <span class="tok-comment">/// Returns the number of keys in the set.</span></span>
<span class="line" id="L364">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">count</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L365">            <span class="tok-kw">return</span> self.bits.count();</span>
<span class="line" id="L366">        }</span>
<span class="line" id="L367"></span>
<span class="line" id="L368">        <span class="tok-comment">/// Checks if a key is in the set.</span></span>
<span class="line" id="L369">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">contains</span>(self: Self, key: Key) <span class="tok-type">bool</span> {</span>
<span class="line" id="L370">            <span class="tok-kw">return</span> self.bits.isSet(Indexer.indexOf(key));</span>
<span class="line" id="L371">        }</span>
<span class="line" id="L372"></span>
<span class="line" id="L373">        <span class="tok-comment">/// Puts a key in the set.</span></span>
<span class="line" id="L374">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">insert</span>(self: *Self, key: Key) <span class="tok-type">void</span> {</span>
<span class="line" id="L375">            self.bits.set(Indexer.indexOf(key));</span>
<span class="line" id="L376">        }</span>
<span class="line" id="L377"></span>
<span class="line" id="L378">        <span class="tok-comment">/// Removes a key from the set.</span></span>
<span class="line" id="L379">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">remove</span>(self: *Self, key: Key) <span class="tok-type">void</span> {</span>
<span class="line" id="L380">            self.bits.unset(Indexer.indexOf(key));</span>
<span class="line" id="L381">        }</span>
<span class="line" id="L382"></span>
<span class="line" id="L383">        <span class="tok-comment">/// Changes the presence of a key in the set to match the passed bool.</span></span>
<span class="line" id="L384">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setPresent</span>(self: *Self, key: Key, present: <span class="tok-type">bool</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L385">            self.bits.setValue(Indexer.indexOf(key), present);</span>
<span class="line" id="L386">        }</span>
<span class="line" id="L387"></span>
<span class="line" id="L388">        <span class="tok-comment">/// Toggles the presence of a key in the set.  If the key is in</span></span>
<span class="line" id="L389">        <span class="tok-comment">/// the set, removes it.  Otherwise adds it.</span></span>
<span class="line" id="L390">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toggle</span>(self: *Self, key: Key) <span class="tok-type">void</span> {</span>
<span class="line" id="L391">            self.bits.toggle(Indexer.indexOf(key));</span>
<span class="line" id="L392">        }</span>
<span class="line" id="L393"></span>
<span class="line" id="L394">        <span class="tok-comment">/// Toggles the presence of all keys in the passed set.</span></span>
<span class="line" id="L395">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toggleSet</span>(self: *Self, other: Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L396">            self.bits.toggleSet(other.bits);</span>
<span class="line" id="L397">        }</span>
<span class="line" id="L398"></span>
<span class="line" id="L399">        <span class="tok-comment">/// Toggles all possible keys in the set.</span></span>
<span class="line" id="L400">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">toggleAll</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L401">            self.bits.toggleAll();</span>
<span class="line" id="L402">        }</span>
<span class="line" id="L403"></span>
<span class="line" id="L404">        <span class="tok-comment">/// Adds all keys in the passed set to this set.</span></span>
<span class="line" id="L405">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setUnion</span>(self: *Self, other: Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L406">            self.bits.setUnion(other.bits);</span>
<span class="line" id="L407">        }</span>
<span class="line" id="L408"></span>
<span class="line" id="L409">        <span class="tok-comment">/// Removes all keys which are not in the passed set.</span></span>
<span class="line" id="L410">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">setIntersection</span>(self: *Self, other: Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L411">            self.bits.setIntersection(other.bits);</span>
<span class="line" id="L412">        }</span>
<span class="line" id="L413"></span>
<span class="line" id="L414">        <span class="tok-comment">/// Returns an iterator over this set, which iterates in</span></span>
<span class="line" id="L415">        <span class="tok-comment">/// index order.  Modifications to the set during iteration</span></span>
<span class="line" id="L416">        <span class="tok-comment">/// may or may not be observed by the iterator, but will</span></span>
<span class="line" id="L417">        <span class="tok-comment">/// not invalidate it.</span></span>
<span class="line" id="L418">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">iterator</span>(self: *Self) Iterator {</span>
<span class="line" id="L419">            <span class="tok-kw">return</span> .{ .inner = self.bits.iterator(.{}) };</span>
<span class="line" id="L420">        }</span>
<span class="line" id="L421"></span>
<span class="line" id="L422">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Iterator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L423">            inner: BitSet.Iterator(.{}),</span>
<span class="line" id="L424"></span>
<span class="line" id="L425">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Iterator) ?Key {</span>
<span class="line" id="L426">                <span class="tok-kw">return</span> <span class="tok-kw">if</span> (self.inner.next()) |index|</span>
<span class="line" id="L427">                    Indexer.keyForIndex(index)</span>
<span class="line" id="L428">                <span class="tok-kw">else</span></span>
<span class="line" id="L429">                    <span class="tok-null">null</span>;</span>
<span class="line" id="L430">            }</span>
<span class="line" id="L431">        };</span>
<span class="line" id="L432">    };</span>
<span class="line" id="L433">}</span>
<span class="line" id="L434"></span>
<span class="line" id="L435"><span class="tok-comment">/// A map from keys to values, using an index lookup.  Uses a</span></span>
<span class="line" id="L436"><span class="tok-comment">/// bitfield to track presence and a dense array of values.</span></span>
<span class="line" id="L437"><span class="tok-comment">/// This type does no allocation and can be copied by value.</span></span>
<span class="line" id="L438"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">IndexedMap</span>(<span class="tok-kw">comptime</span> I: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> V: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> Ext: <span class="tok-kw">fn</span> (<span class="tok-type">type</span>) <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L439">    <span class="tok-kw">comptime</span> ensureIndexer(I);</span>
<span class="line" id="L440">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L441">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L442"></span>
<span class="line" id="L443">        <span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> Ext(Self);</span>
<span class="line" id="L444"></span>
<span class="line" id="L445">        <span class="tok-comment">/// The index mapping for this map</span></span>
<span class="line" id="L446">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Indexer = I;</span>
<span class="line" id="L447">        <span class="tok-comment">/// The key type used to index this map</span></span>
<span class="line" id="L448">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Key = Indexer.Key;</span>
<span class="line" id="L449">        <span class="tok-comment">/// The value type stored in this map</span></span>
<span class="line" id="L450">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Value = V;</span>
<span class="line" id="L451">        <span class="tok-comment">/// The number of possible keys in the map</span></span>
<span class="line" id="L452">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> len = Indexer.count;</span>
<span class="line" id="L453"></span>
<span class="line" id="L454">        <span class="tok-kw">const</span> BitSet = std.StaticBitSet(Indexer.count);</span>
<span class="line" id="L455"></span>
<span class="line" id="L456">        <span class="tok-comment">/// Bits determining whether items are in the map</span></span>
<span class="line" id="L457">        bits: BitSet = BitSet.initEmpty(),</span>
<span class="line" id="L458">        <span class="tok-comment">/// Values of items in the map.  If the associated</span></span>
<span class="line" id="L459">        <span class="tok-comment">/// bit is zero, the value is undefined.</span></span>
<span class="line" id="L460">        values: [Indexer.count]Value = <span class="tok-null">undefined</span>,</span>
<span class="line" id="L461"></span>
<span class="line" id="L462">        <span class="tok-comment">/// The number of items in the map.</span></span>
<span class="line" id="L463">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">count</span>(self: Self) <span class="tok-type">usize</span> {</span>
<span class="line" id="L464">            <span class="tok-kw">return</span> self.bits.count();</span>
<span class="line" id="L465">        }</span>
<span class="line" id="L466"></span>
<span class="line" id="L467">        <span class="tok-comment">/// Checks if the map contains an item.</span></span>
<span class="line" id="L468">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">contains</span>(self: Self, key: Key) <span class="tok-type">bool</span> {</span>
<span class="line" id="L469">            <span class="tok-kw">return</span> self.bits.isSet(Indexer.indexOf(key));</span>
<span class="line" id="L470">        }</span>
<span class="line" id="L471"></span>
<span class="line" id="L472">        <span class="tok-comment">/// Gets the value associated with a key.</span></span>
<span class="line" id="L473">        <span class="tok-comment">/// If the key is not in the map, returns null.</span></span>
<span class="line" id="L474">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get</span>(self: Self, key: Key) ?Value {</span>
<span class="line" id="L475">            <span class="tok-kw">const</span> index = Indexer.indexOf(key);</span>
<span class="line" id="L476">            <span class="tok-kw">return</span> <span class="tok-kw">if</span> (self.bits.isSet(index)) self.values[index] <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L477">        }</span>
<span class="line" id="L478"></span>
<span class="line" id="L479">        <span class="tok-comment">/// Gets the value associated with a key, which must</span></span>
<span class="line" id="L480">        <span class="tok-comment">/// exist in the map.</span></span>
<span class="line" id="L481">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getAssertContains</span>(self: Self, key: Key) Value {</span>
<span class="line" id="L482">            <span class="tok-kw">const</span> index = Indexer.indexOf(key);</span>
<span class="line" id="L483">            assert(self.bits.isSet(index));</span>
<span class="line" id="L484">            <span class="tok-kw">return</span> self.values[index];</span>
<span class="line" id="L485">        }</span>
<span class="line" id="L486"></span>
<span class="line" id="L487">        <span class="tok-comment">/// Gets the address of the value associated with a key.</span></span>
<span class="line" id="L488">        <span class="tok-comment">/// If the key is not in the map, returns null.</span></span>
<span class="line" id="L489">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPtr</span>(self: *Self, key: Key) ?*Value {</span>
<span class="line" id="L490">            <span class="tok-kw">const</span> index = Indexer.indexOf(key);</span>
<span class="line" id="L491">            <span class="tok-kw">return</span> <span class="tok-kw">if</span> (self.bits.isSet(index)) &amp;self.values[index] <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L492">        }</span>
<span class="line" id="L493"></span>
<span class="line" id="L494">        <span class="tok-comment">/// Gets the address of the const value associated with a key.</span></span>
<span class="line" id="L495">        <span class="tok-comment">/// If the key is not in the map, returns null.</span></span>
<span class="line" id="L496">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPtrConst</span>(self: *<span class="tok-kw">const</span> Self, key: Key) ?*<span class="tok-kw">const</span> Value {</span>
<span class="line" id="L497">            <span class="tok-kw">const</span> index = Indexer.indexOf(key);</span>
<span class="line" id="L498">            <span class="tok-kw">return</span> <span class="tok-kw">if</span> (self.bits.isSet(index)) &amp;self.values[index] <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L499">        }</span>
<span class="line" id="L500"></span>
<span class="line" id="L501">        <span class="tok-comment">/// Gets the address of the value associated with a key.</span></span>
<span class="line" id="L502">        <span class="tok-comment">/// The key must be present in the map.</span></span>
<span class="line" id="L503">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPtrAssertContains</span>(self: *Self, key: Key) *Value {</span>
<span class="line" id="L504">            <span class="tok-kw">const</span> index = Indexer.indexOf(key);</span>
<span class="line" id="L505">            assert(self.bits.isSet(index));</span>
<span class="line" id="L506">            <span class="tok-kw">return</span> &amp;self.values[index];</span>
<span class="line" id="L507">        }</span>
<span class="line" id="L508"></span>
<span class="line" id="L509">        <span class="tok-comment">/// Adds the key to the map with the supplied value.</span></span>
<span class="line" id="L510">        <span class="tok-comment">/// If the key is already in the map, overwrites the value.</span></span>
<span class="line" id="L511">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">put</span>(self: *Self, key: Key, value: Value) <span class="tok-type">void</span> {</span>
<span class="line" id="L512">            <span class="tok-kw">const</span> index = Indexer.indexOf(key);</span>
<span class="line" id="L513">            self.bits.set(index);</span>
<span class="line" id="L514">            self.values[index] = value;</span>
<span class="line" id="L515">        }</span>
<span class="line" id="L516"></span>
<span class="line" id="L517">        <span class="tok-comment">/// Adds the key to the map with an undefined value.</span></span>
<span class="line" id="L518">        <span class="tok-comment">/// If the key is already in the map, the value becomes undefined.</span></span>
<span class="line" id="L519">        <span class="tok-comment">/// A pointer to the value is returned, which should be</span></span>
<span class="line" id="L520">        <span class="tok-comment">/// used to initialize the value.</span></span>
<span class="line" id="L521">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">putUninitialized</span>(self: *Self, key: Key) *Value {</span>
<span class="line" id="L522">            <span class="tok-kw">const</span> index = Indexer.indexOf(key);</span>
<span class="line" id="L523">            self.bits.set(index);</span>
<span class="line" id="L524">            self.values[index] = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L525">            <span class="tok-kw">return</span> &amp;self.values[index];</span>
<span class="line" id="L526">        }</span>
<span class="line" id="L527"></span>
<span class="line" id="L528">        <span class="tok-comment">/// Sets the value associated with the key in the map,</span></span>
<span class="line" id="L529">        <span class="tok-comment">/// and returns the old value.  If the key was not in</span></span>
<span class="line" id="L530">        <span class="tok-comment">/// the map, returns null.</span></span>
<span class="line" id="L531">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchPut</span>(self: *Self, key: Key, value: Value) ?Value {</span>
<span class="line" id="L532">            <span class="tok-kw">const</span> index = Indexer.indexOf(key);</span>
<span class="line" id="L533">            <span class="tok-kw">const</span> result: ?Value = <span class="tok-kw">if</span> (self.bits.isSet(index)) self.values[index] <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L534">            self.bits.set(index);</span>
<span class="line" id="L535">            self.values[index] = value;</span>
<span class="line" id="L536">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L537">        }</span>
<span class="line" id="L538"></span>
<span class="line" id="L539">        <span class="tok-comment">/// Removes a key from the map.  If the key was not in the map,</span></span>
<span class="line" id="L540">        <span class="tok-comment">/// does nothing.</span></span>
<span class="line" id="L541">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">remove</span>(self: *Self, key: Key) <span class="tok-type">void</span> {</span>
<span class="line" id="L542">            <span class="tok-kw">const</span> index = Indexer.indexOf(key);</span>
<span class="line" id="L543">            self.bits.unset(index);</span>
<span class="line" id="L544">            self.values[index] = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L545">        }</span>
<span class="line" id="L546"></span>
<span class="line" id="L547">        <span class="tok-comment">/// Removes a key from the map, and returns the old value.</span></span>
<span class="line" id="L548">        <span class="tok-comment">/// If the key was not in the map, returns null.</span></span>
<span class="line" id="L549">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">fetchRemove</span>(self: *Self, key: Key) ?Value {</span>
<span class="line" id="L550">            <span class="tok-kw">const</span> index = Indexer.indexOf(key);</span>
<span class="line" id="L551">            <span class="tok-kw">const</span> result: ?Value = <span class="tok-kw">if</span> (self.bits.isSet(index)) self.values[index] <span class="tok-kw">else</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L552">            self.bits.unset(index);</span>
<span class="line" id="L553">            self.values[index] = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L554">            <span class="tok-kw">return</span> result;</span>
<span class="line" id="L555">        }</span>
<span class="line" id="L556"></span>
<span class="line" id="L557">        <span class="tok-comment">/// Returns an iterator over the map, which visits items in index order.</span></span>
<span class="line" id="L558">        <span class="tok-comment">/// Modifications to the underlying map may or may not be observed by</span></span>
<span class="line" id="L559">        <span class="tok-comment">/// the iterator, but will not invalidate it.</span></span>
<span class="line" id="L560">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">iterator</span>(self: *Self) Iterator {</span>
<span class="line" id="L561">            <span class="tok-kw">return</span> .{</span>
<span class="line" id="L562">                .inner = self.bits.iterator(.{}),</span>
<span class="line" id="L563">                .values = &amp;self.values,</span>
<span class="line" id="L564">            };</span>
<span class="line" id="L565">        }</span>
<span class="line" id="L566"></span>
<span class="line" id="L567">        <span class="tok-comment">/// An entry in the map.</span></span>
<span class="line" id="L568">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Entry = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L569">            <span class="tok-comment">/// The key associated with this entry.</span></span>
<span class="line" id="L570">            <span class="tok-comment">/// Modifying this key will not change the map.</span></span>
<span class="line" id="L571">            key: Key,</span>
<span class="line" id="L572"></span>
<span class="line" id="L573">            <span class="tok-comment">/// A pointer to the value in the map associated</span></span>
<span class="line" id="L574">            <span class="tok-comment">/// with this key.  Modifications through this</span></span>
<span class="line" id="L575">            <span class="tok-comment">/// pointer will modify the underlying data.</span></span>
<span class="line" id="L576">            value: *Value,</span>
<span class="line" id="L577">        };</span>
<span class="line" id="L578"></span>
<span class="line" id="L579">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Iterator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L580">            inner: BitSet.Iterator(.{}),</span>
<span class="line" id="L581">            values: *[Indexer.count]Value,</span>
<span class="line" id="L582"></span>
<span class="line" id="L583">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Iterator) ?Entry {</span>
<span class="line" id="L584">                <span class="tok-kw">return</span> <span class="tok-kw">if</span> (self.inner.next()) |index|</span>
<span class="line" id="L585">                    Entry{</span>
<span class="line" id="L586">                        .key = Indexer.keyForIndex(index),</span>
<span class="line" id="L587">                        .value = &amp;self.values[index],</span>
<span class="line" id="L588">                    }</span>
<span class="line" id="L589">                <span class="tok-kw">else</span></span>
<span class="line" id="L590">                    <span class="tok-null">null</span>;</span>
<span class="line" id="L591">            }</span>
<span class="line" id="L592">        };</span>
<span class="line" id="L593">    };</span>
<span class="line" id="L594">}</span>
<span class="line" id="L595"></span>
<span class="line" id="L596"><span class="tok-comment">/// A dense array of values, using an indexed lookup.</span></span>
<span class="line" id="L597"><span class="tok-comment">/// This type does no allocation and can be copied by value.</span></span>
<span class="line" id="L598"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">IndexedArray</span>(<span class="tok-kw">comptime</span> I: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> V: <span class="tok-type">type</span>, <span class="tok-kw">comptime</span> Ext: <span class="tok-kw">fn</span> (<span class="tok-type">type</span>) <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L599">    <span class="tok-kw">comptime</span> ensureIndexer(I);</span>
<span class="line" id="L600">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L601">        <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L602"></span>
<span class="line" id="L603">        <span class="tok-kw">pub</span> <span class="tok-kw">usingnamespace</span> Ext(Self);</span>
<span class="line" id="L604"></span>
<span class="line" id="L605">        <span class="tok-comment">/// The index mapping for this map</span></span>
<span class="line" id="L606">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Indexer = I;</span>
<span class="line" id="L607">        <span class="tok-comment">/// The key type used to index this map</span></span>
<span class="line" id="L608">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Key = Indexer.Key;</span>
<span class="line" id="L609">        <span class="tok-comment">/// The value type stored in this map</span></span>
<span class="line" id="L610">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Value = V;</span>
<span class="line" id="L611">        <span class="tok-comment">/// The number of possible keys in the map</span></span>
<span class="line" id="L612">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> len = Indexer.count;</span>
<span class="line" id="L613"></span>
<span class="line" id="L614">        values: [Indexer.count]Value,</span>
<span class="line" id="L615"></span>
<span class="line" id="L616">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initUndefined</span>() Self {</span>
<span class="line" id="L617">            <span class="tok-kw">return</span> Self{ .values = <span class="tok-null">undefined</span> };</span>
<span class="line" id="L618">        }</span>
<span class="line" id="L619"></span>
<span class="line" id="L620">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">initFill</span>(v: Value) Self {</span>
<span class="line" id="L621">            <span class="tok-kw">var</span> self: Self = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L622">            std.mem.set(Value, &amp;self.values, v);</span>
<span class="line" id="L623">            <span class="tok-kw">return</span> self;</span>
<span class="line" id="L624">        }</span>
<span class="line" id="L625"></span>
<span class="line" id="L626">        <span class="tok-comment">/// Returns the value in the array associated with a key.</span></span>
<span class="line" id="L627">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">get</span>(self: Self, key: Key) Value {</span>
<span class="line" id="L628">            <span class="tok-kw">return</span> self.values[Indexer.indexOf(key)];</span>
<span class="line" id="L629">        }</span>
<span class="line" id="L630"></span>
<span class="line" id="L631">        <span class="tok-comment">/// Returns a pointer to the slot in the array associated with a key.</span></span>
<span class="line" id="L632">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPtr</span>(self: *Self, key: Key) *Value {</span>
<span class="line" id="L633">            <span class="tok-kw">return</span> &amp;self.values[Indexer.indexOf(key)];</span>
<span class="line" id="L634">        }</span>
<span class="line" id="L635"></span>
<span class="line" id="L636">        <span class="tok-comment">/// Returns a const pointer to the slot in the array associated with a key.</span></span>
<span class="line" id="L637">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getPtrConst</span>(self: *<span class="tok-kw">const</span> Self, key: Key) *<span class="tok-kw">const</span> Value {</span>
<span class="line" id="L638">            <span class="tok-kw">return</span> &amp;self.values[Indexer.indexOf(key)];</span>
<span class="line" id="L639">        }</span>
<span class="line" id="L640"></span>
<span class="line" id="L641">        <span class="tok-comment">/// Sets the value in the slot associated with a key.</span></span>
<span class="line" id="L642">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">set</span>(self: *Self, key: Key, value: Value) <span class="tok-type">void</span> {</span>
<span class="line" id="L643">            self.values[Indexer.indexOf(key)] = value;</span>
<span class="line" id="L644">        }</span>
<span class="line" id="L645"></span>
<span class="line" id="L646">        <span class="tok-comment">/// Iterates over the items in the array, in index order.</span></span>
<span class="line" id="L647">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">iterator</span>(self: *Self) Iterator {</span>
<span class="line" id="L648">            <span class="tok-kw">return</span> .{</span>
<span class="line" id="L649">                .values = &amp;self.values,</span>
<span class="line" id="L650">            };</span>
<span class="line" id="L651">        }</span>
<span class="line" id="L652"></span>
<span class="line" id="L653">        <span class="tok-comment">/// An entry in the array.</span></span>
<span class="line" id="L654">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Entry = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L655">            <span class="tok-comment">/// The key associated with this entry.</span></span>
<span class="line" id="L656">            <span class="tok-comment">/// Modifying this key will not change the array.</span></span>
<span class="line" id="L657">            key: Key,</span>
<span class="line" id="L658"></span>
<span class="line" id="L659">            <span class="tok-comment">/// A pointer to the value in the array associated</span></span>
<span class="line" id="L660">            <span class="tok-comment">/// with this key.  Modifications through this</span></span>
<span class="line" id="L661">            <span class="tok-comment">/// pointer will modify the underlying data.</span></span>
<span class="line" id="L662">            value: *Value,</span>
<span class="line" id="L663">        };</span>
<span class="line" id="L664"></span>
<span class="line" id="L665">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Iterator = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L666">            index: <span class="tok-type">usize</span> = <span class="tok-number">0</span>,</span>
<span class="line" id="L667">            values: *[Indexer.count]Value,</span>
<span class="line" id="L668"></span>
<span class="line" id="L669">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">next</span>(self: *Iterator) ?Entry {</span>
<span class="line" id="L670">                <span class="tok-kw">const</span> index = self.index;</span>
<span class="line" id="L671">                <span class="tok-kw">if</span> (index &lt; Indexer.count) {</span>
<span class="line" id="L672">                    self.index += <span class="tok-number">1</span>;</span>
<span class="line" id="L673">                    <span class="tok-kw">return</span> Entry{</span>
<span class="line" id="L674">                        .key = Indexer.keyForIndex(index),</span>
<span class="line" id="L675">                        .value = &amp;self.values[index],</span>
<span class="line" id="L676">                    };</span>
<span class="line" id="L677">                }</span>
<span class="line" id="L678">                <span class="tok-kw">return</span> <span class="tok-null">null</span>;</span>
<span class="line" id="L679">            }</span>
<span class="line" id="L680">        };</span>
<span class="line" id="L681">    };</span>
<span class="line" id="L682">}</span>
<span class="line" id="L683"></span>
<span class="line" id="L684"><span class="tok-comment">/// Verifies that a type is a valid Indexer, providing a helpful</span></span>
<span class="line" id="L685"><span class="tok-comment">/// compile error if not.  An Indexer maps a comptime known set</span></span>
<span class="line" id="L686"><span class="tok-comment">/// of keys to a dense set of zero-based indices.</span></span>
<span class="line" id="L687"><span class="tok-comment">/// The indexer interface must look like this:</span></span>
<span class="line" id="L688"><span class="tok-comment">/// ```</span></span>
<span class="line" id="L689"><span class="tok-comment">/// struct {</span></span>
<span class="line" id="L690"><span class="tok-comment">///     /// The key type which this indexer converts to indices</span></span>
<span class="line" id="L691"><span class="tok-comment">///     pub const Key: type,</span></span>
<span class="line" id="L692"><span class="tok-comment">///     /// The number of indexes in the dense mapping</span></span>
<span class="line" id="L693"><span class="tok-comment">///     pub const count: usize,</span></span>
<span class="line" id="L694"><span class="tok-comment">///     /// Converts from a key to an index</span></span>
<span class="line" id="L695"><span class="tok-comment">///     pub fn indexOf(Key) usize;</span></span>
<span class="line" id="L696"><span class="tok-comment">///     /// Converts from an index to a key</span></span>
<span class="line" id="L697"><span class="tok-comment">///     pub fn keyForIndex(usize) Key;</span></span>
<span class="line" id="L698"><span class="tok-comment">/// }</span></span>
<span class="line" id="L699"><span class="tok-comment">/// ```</span></span>
<span class="line" id="L700"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">ensureIndexer</span>(<span class="tok-kw">comptime</span> T: <span class="tok-type">type</span>) <span class="tok-type">void</span> {</span>
<span class="line" id="L701">    <span class="tok-kw">comptime</span> {</span>
<span class="line" id="L702">        <span class="tok-kw">if</span> (!<span class="tok-builtin">@hasDecl</span>(T, <span class="tok-str">&quot;Key&quot;</span>)) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Indexer must have decl Key: type.&quot;</span>);</span>
<span class="line" id="L703">        <span class="tok-kw">if</span> (<span class="tok-builtin">@TypeOf</span>(T.Key) != <span class="tok-type">type</span>) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Indexer.Key must be a type.&quot;</span>);</span>
<span class="line" id="L704">        <span class="tok-kw">if</span> (!<span class="tok-builtin">@hasDecl</span>(T, <span class="tok-str">&quot;count&quot;</span>)) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Indexer must have decl count: usize.&quot;</span>);</span>
<span class="line" id="L705">        <span class="tok-kw">if</span> (<span class="tok-builtin">@TypeOf</span>(T.count) != <span class="tok-type">usize</span>) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Indexer.count must be a usize.&quot;</span>);</span>
<span class="line" id="L706">        <span class="tok-kw">if</span> (!<span class="tok-builtin">@hasDecl</span>(T, <span class="tok-str">&quot;indexOf&quot;</span>)) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Indexer.indexOf must be a fn(Key)usize.&quot;</span>);</span>
<span class="line" id="L707">        <span class="tok-kw">if</span> (<span class="tok-builtin">@TypeOf</span>(T.indexOf) != <span class="tok-kw">fn</span> (T.Key) <span class="tok-type">usize</span>) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Indexer must have decl indexOf: fn(Key)usize.&quot;</span>);</span>
<span class="line" id="L708">        <span class="tok-kw">if</span> (!<span class="tok-builtin">@hasDecl</span>(T, <span class="tok-str">&quot;keyForIndex&quot;</span>)) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Indexer must have decl keyForIndex: fn(usize)Key.&quot;</span>);</span>
<span class="line" id="L709">        <span class="tok-kw">if</span> (<span class="tok-builtin">@TypeOf</span>(T.keyForIndex) != <span class="tok-kw">fn</span> (<span class="tok-type">usize</span>) T.Key) <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Indexer.keyForIndex must be a fn(usize)Key.&quot;</span>);</span>
<span class="line" id="L710">    }</span>
<span class="line" id="L711">}</span>
<span class="line" id="L712"></span>
<span class="line" id="L713"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.enums.ensureIndexer&quot;</span> {</span>
<span class="line" id="L714">    ensureIndexer(<span class="tok-kw">struct</span> {</span>
<span class="line" id="L715">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Key = <span class="tok-type">u32</span>;</span>
<span class="line" id="L716">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> count: <span class="tok-type">usize</span> = <span class="tok-number">8</span>;</span>
<span class="line" id="L717">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">indexOf</span>(k: Key) <span class="tok-type">usize</span> {</span>
<span class="line" id="L718">            <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, k);</span>
<span class="line" id="L719">        }</span>
<span class="line" id="L720">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">keyForIndex</span>(index: <span class="tok-type">usize</span>) Key {</span>
<span class="line" id="L721">            <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(Key, index);</span>
<span class="line" id="L722">        }</span>
<span class="line" id="L723">    });</span>
<span class="line" id="L724">}</span>
<span class="line" id="L725"></span>
<span class="line" id="L726"><span class="tok-kw">fn</span> <span class="tok-fn">ascByValue</span>(ctx: <span class="tok-type">void</span>, <span class="tok-kw">comptime</span> a: EnumField, <span class="tok-kw">comptime</span> b: EnumField) <span class="tok-type">bool</span> {</span>
<span class="line" id="L727">    _ = ctx;</span>
<span class="line" id="L728">    <span class="tok-kw">return</span> a.value &lt; b.value;</span>
<span class="line" id="L729">}</span>
<span class="line" id="L730"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">EnumIndexer</span>(<span class="tok-kw">comptime</span> E: <span class="tok-type">type</span>) <span class="tok-type">type</span> {</span>
<span class="line" id="L731">    <span class="tok-kw">if</span> (!<span class="tok-builtin">@typeInfo</span>(E).Enum.is_exhaustive) {</span>
<span class="line" id="L732">        <span class="tok-builtin">@compileError</span>(<span class="tok-str">&quot;Cannot create an enum indexer for a non-exhaustive enum.&quot;</span>);</span>
<span class="line" id="L733">    }</span>
<span class="line" id="L734"></span>
<span class="line" id="L735">    <span class="tok-kw">const</span> const_fields = std.meta.fields(E);</span>
<span class="line" id="L736">    <span class="tok-kw">var</span> fields = const_fields[<span class="tok-number">0</span>..const_fields.len].*;</span>
<span class="line" id="L737">    <span class="tok-kw">if</span> (fields.len == <span class="tok-number">0</span>) {</span>
<span class="line" id="L738">        <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L739">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Key = E;</span>
<span class="line" id="L740">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> count: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L741">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">indexOf</span>(e: E) <span class="tok-type">usize</span> {</span>
<span class="line" id="L742">                _ = e;</span>
<span class="line" id="L743">                <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L744">            }</span>
<span class="line" id="L745">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">keyForIndex</span>(i: <span class="tok-type">usize</span>) E {</span>
<span class="line" id="L746">                _ = i;</span>
<span class="line" id="L747">                <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L748">            }</span>
<span class="line" id="L749">        };</span>
<span class="line" id="L750">    }</span>
<span class="line" id="L751">    std.sort.sort(EnumField, &amp;fields, {}, ascByValue);</span>
<span class="line" id="L752">    <span class="tok-kw">const</span> min = fields[<span class="tok-number">0</span>].value;</span>
<span class="line" id="L753">    <span class="tok-kw">const</span> max = fields[fields.len - <span class="tok-number">1</span>].value;</span>
<span class="line" id="L754">    <span class="tok-kw">const</span> fields_len = fields.len;</span>
<span class="line" id="L755">    <span class="tok-kw">if</span> (max - min == fields.len - <span class="tok-number">1</span>) {</span>
<span class="line" id="L756">        <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L757">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Key = E;</span>
<span class="line" id="L758">            <span class="tok-kw">pub</span> <span class="tok-kw">const</span> count = fields_len;</span>
<span class="line" id="L759">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">indexOf</span>(e: E) <span class="tok-type">usize</span> {</span>
<span class="line" id="L760">                <span class="tok-kw">return</span> <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, <span class="tok-builtin">@enumToInt</span>(e) - min);</span>
<span class="line" id="L761">            }</span>
<span class="line" id="L762">            <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">keyForIndex</span>(i: <span class="tok-type">usize</span>) E {</span>
<span class="line" id="L763">                <span class="tok-comment">// TODO fix addition semantics.  This calculation</span>
</span>
<span class="line" id="L764">                <span class="tok-comment">// gives up some safety to avoid artificially limiting</span>
</span>
<span class="line" id="L765">                <span class="tok-comment">// the range of signed enum values to max_isize.</span>
</span>
<span class="line" id="L766">                <span class="tok-kw">const</span> enum_value = <span class="tok-kw">if</span> (min &lt; <span class="tok-number">0</span>) <span class="tok-builtin">@bitCast</span>(<span class="tok-type">isize</span>, i) +% min <span class="tok-kw">else</span> i + min;</span>
<span class="line" id="L767">                <span class="tok-kw">return</span> <span class="tok-builtin">@intToEnum</span>(E, <span class="tok-builtin">@intCast</span>(std.meta.Tag(E), enum_value));</span>
<span class="line" id="L768">            }</span>
<span class="line" id="L769">        };</span>
<span class="line" id="L770">    }</span>
<span class="line" id="L771"></span>
<span class="line" id="L772">    <span class="tok-kw">const</span> keys = valuesFromFields(E, &amp;fields);</span>
<span class="line" id="L773"></span>
<span class="line" id="L774">    <span class="tok-kw">return</span> <span class="tok-kw">struct</span> {</span>
<span class="line" id="L775">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> Key = E;</span>
<span class="line" id="L776">        <span class="tok-kw">pub</span> <span class="tok-kw">const</span> count = fields_len;</span>
<span class="line" id="L777">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">indexOf</span>(e: E) <span class="tok-type">usize</span> {</span>
<span class="line" id="L778">            <span class="tok-kw">for</span> (keys) |k, i| {</span>
<span class="line" id="L779">                <span class="tok-kw">if</span> (k == e) <span class="tok-kw">return</span> i;</span>
<span class="line" id="L780">            }</span>
<span class="line" id="L781">            <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L782">        }</span>
<span class="line" id="L783">        <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">keyForIndex</span>(i: <span class="tok-type">usize</span>) E {</span>
<span class="line" id="L784">            <span class="tok-kw">return</span> keys[i];</span>
<span class="line" id="L785">        }</span>
<span class="line" id="L786">    };</span>
<span class="line" id="L787">}</span>
<span class="line" id="L788"></span>
<span class="line" id="L789"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.enums.EnumIndexer dense zeroed&quot;</span> {</span>
<span class="line" id="L790">    <span class="tok-kw">const</span> E = <span class="tok-kw">enum</span>(<span class="tok-type">u2</span>) { b = <span class="tok-number">1</span>, a = <span class="tok-number">0</span>, c = <span class="tok-number">2</span> };</span>
<span class="line" id="L791">    <span class="tok-kw">const</span> Indexer = EnumIndexer(E);</span>
<span class="line" id="L792">    ensureIndexer(Indexer);</span>
<span class="line" id="L793">    <span class="tok-kw">try</span> testing.expectEqual(E, Indexer.Key);</span>
<span class="line" id="L794">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>), Indexer.count);</span>
<span class="line" id="L795"></span>
<span class="line" id="L796">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), Indexer.indexOf(.a));</span>
<span class="line" id="L797">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>), Indexer.indexOf(.b));</span>
<span class="line" id="L798">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">2</span>), Indexer.indexOf(.c));</span>
<span class="line" id="L799"></span>
<span class="line" id="L800">    <span class="tok-kw">try</span> testing.expectEqual(E.a, Indexer.keyForIndex(<span class="tok-number">0</span>));</span>
<span class="line" id="L801">    <span class="tok-kw">try</span> testing.expectEqual(E.b, Indexer.keyForIndex(<span class="tok-number">1</span>));</span>
<span class="line" id="L802">    <span class="tok-kw">try</span> testing.expectEqual(E.c, Indexer.keyForIndex(<span class="tok-number">2</span>));</span>
<span class="line" id="L803">}</span>
<span class="line" id="L804"></span>
<span class="line" id="L805"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.enums.EnumIndexer dense positive&quot;</span> {</span>
<span class="line" id="L806">    <span class="tok-kw">const</span> E = <span class="tok-kw">enum</span>(<span class="tok-type">u4</span>) { c = <span class="tok-number">6</span>, a = <span class="tok-number">4</span>, b = <span class="tok-number">5</span> };</span>
<span class="line" id="L807">    <span class="tok-kw">const</span> Indexer = EnumIndexer(E);</span>
<span class="line" id="L808">    ensureIndexer(Indexer);</span>
<span class="line" id="L809">    <span class="tok-kw">try</span> testing.expectEqual(E, Indexer.Key);</span>
<span class="line" id="L810">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>), Indexer.count);</span>
<span class="line" id="L811"></span>
<span class="line" id="L812">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), Indexer.indexOf(.a));</span>
<span class="line" id="L813">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>), Indexer.indexOf(.b));</span>
<span class="line" id="L814">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">2</span>), Indexer.indexOf(.c));</span>
<span class="line" id="L815"></span>
<span class="line" id="L816">    <span class="tok-kw">try</span> testing.expectEqual(E.a, Indexer.keyForIndex(<span class="tok-number">0</span>));</span>
<span class="line" id="L817">    <span class="tok-kw">try</span> testing.expectEqual(E.b, Indexer.keyForIndex(<span class="tok-number">1</span>));</span>
<span class="line" id="L818">    <span class="tok-kw">try</span> testing.expectEqual(E.c, Indexer.keyForIndex(<span class="tok-number">2</span>));</span>
<span class="line" id="L819">}</span>
<span class="line" id="L820"></span>
<span class="line" id="L821"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.enums.EnumIndexer dense negative&quot;</span> {</span>
<span class="line" id="L822">    <span class="tok-kw">const</span> E = <span class="tok-kw">enum</span>(<span class="tok-type">i4</span>) { a = -<span class="tok-number">6</span>, c = -<span class="tok-number">4</span>, b = -<span class="tok-number">5</span> };</span>
<span class="line" id="L823">    <span class="tok-kw">const</span> Indexer = EnumIndexer(E);</span>
<span class="line" id="L824">    ensureIndexer(Indexer);</span>
<span class="line" id="L825">    <span class="tok-kw">try</span> testing.expectEqual(E, Indexer.Key);</span>
<span class="line" id="L826">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>), Indexer.count);</span>
<span class="line" id="L827"></span>
<span class="line" id="L828">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), Indexer.indexOf(.a));</span>
<span class="line" id="L829">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>), Indexer.indexOf(.b));</span>
<span class="line" id="L830">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">2</span>), Indexer.indexOf(.c));</span>
<span class="line" id="L831"></span>
<span class="line" id="L832">    <span class="tok-kw">try</span> testing.expectEqual(E.a, Indexer.keyForIndex(<span class="tok-number">0</span>));</span>
<span class="line" id="L833">    <span class="tok-kw">try</span> testing.expectEqual(E.b, Indexer.keyForIndex(<span class="tok-number">1</span>));</span>
<span class="line" id="L834">    <span class="tok-kw">try</span> testing.expectEqual(E.c, Indexer.keyForIndex(<span class="tok-number">2</span>));</span>
<span class="line" id="L835">}</span>
<span class="line" id="L836"></span>
<span class="line" id="L837"><span class="tok-kw">test</span> <span class="tok-str">&quot;std.enums.EnumIndexer sparse&quot;</span> {</span>
<span class="line" id="L838">    <span class="tok-kw">const</span> E = <span class="tok-kw">enum</span>(<span class="tok-type">i4</span>) { a = -<span class="tok-number">2</span>, c = <span class="tok-number">6</span>, b = <span class="tok-number">4</span> };</span>
<span class="line" id="L839">    <span class="tok-kw">const</span> Indexer = EnumIndexer(E);</span>
<span class="line" id="L840">    ensureIndexer(Indexer);</span>
<span class="line" id="L841">    <span class="tok-kw">try</span> testing.expectEqual(E, Indexer.Key);</span>
<span class="line" id="L842">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">3</span>), Indexer.count);</span>
<span class="line" id="L843"></span>
<span class="line" id="L844">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">0</span>), Indexer.indexOf(.a));</span>
<span class="line" id="L845">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">1</span>), Indexer.indexOf(.b));</span>
<span class="line" id="L846">    <span class="tok-kw">try</span> testing.expectEqual(<span class="tok-builtin">@as</span>(<span class="tok-type">usize</span>, <span class="tok-number">2</span>), Indexer.indexOf(.c));</span>
<span class="line" id="L847"></span>
<span class="line" id="L848">    <span class="tok-kw">try</span> testing.expectEqual(E.a, Indexer.keyForIndex(<span class="tok-number">0</span>));</span>
<span class="line" id="L849">    <span class="tok-kw">try</span> testing.expectEqual(E.b, Indexer.keyForIndex(<span class="tok-number">1</span>));</span>
<span class="line" id="L850">    <span class="tok-kw">try</span> testing.expectEqual(E.c, Indexer.keyForIndex(<span class="tok-number">2</span>));</span>
<span class="line" id="L851">}</span>
<span class="line" id="L852"></span>
</code></pre></body>
</html>