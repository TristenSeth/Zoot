<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>std.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ArrayHashMap = array_hash_map.ArrayHashMap;</span>
<span class="line" id="L2"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ArrayHashMapUnmanaged = array_hash_map.ArrayHashMapUnmanaged;</span>
<span class="line" id="L3"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ArrayList = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;array_list.zig&quot;</span>).ArrayList;</span>
<span class="line" id="L4"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ArrayListAligned = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;array_list.zig&quot;</span>).ArrayListAligned;</span>
<span class="line" id="L5"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ArrayListAlignedUnmanaged = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;array_list.zig&quot;</span>).ArrayListAlignedUnmanaged;</span>
<span class="line" id="L6"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ArrayListUnmanaged = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;array_list.zig&quot;</span>).ArrayListUnmanaged;</span>
<span class="line" id="L7"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AutoArrayHashMap = array_hash_map.AutoArrayHashMap;</span>
<span class="line" id="L8"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AutoArrayHashMapUnmanaged = array_hash_map.AutoArrayHashMapUnmanaged;</span>
<span class="line" id="L9"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AutoHashMap = hash_map.AutoHashMap;</span>
<span class="line" id="L10"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> AutoHashMapUnmanaged = hash_map.AutoHashMapUnmanaged;</span>
<span class="line" id="L11"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BoundedArray = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;bounded_array.zig&quot;</span>).BoundedArray;</span>
<span class="line" id="L12"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BufMap = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;buf_map.zig&quot;</span>).BufMap;</span>
<span class="line" id="L13"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> BufSet = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;buf_set.zig&quot;</span>).BufSet;</span>
<span class="line" id="L14"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ChildProcess = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;child_process.zig&quot;</span>).ChildProcess;</span>
<span class="line" id="L15"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ComptimeStringMap = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;comptime_string_map.zig&quot;</span>).ComptimeStringMap;</span>
<span class="line" id="L16"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DynLib = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;dynamic_library.zig&quot;</span>).DynLib;</span>
<span class="line" id="L17"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DynamicBitSet = bit_set.DynamicBitSet;</span>
<span class="line" id="L18"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> DynamicBitSetUnmanaged = bit_set.DynamicBitSetUnmanaged;</span>
<span class="line" id="L19"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EnumArray = enums.EnumArray;</span>
<span class="line" id="L20"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EnumMap = enums.EnumMap;</span>
<span class="line" id="L21"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> EnumSet = enums.EnumSet;</span>
<span class="line" id="L22"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HashMap = hash_map.HashMap;</span>
<span class="line" id="L23"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> HashMapUnmanaged = hash_map.HashMapUnmanaged;</span>
<span class="line" id="L24"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> MultiArrayList = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;multi_array_list.zig&quot;</span>).MultiArrayList;</span>
<span class="line" id="L25"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PackedIntArray = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;packed_int_array.zig&quot;</span>).PackedIntArray;</span>
<span class="line" id="L26"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PackedIntArrayEndian = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;packed_int_array.zig&quot;</span>).PackedIntArrayEndian;</span>
<span class="line" id="L27"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PackedIntSlice = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;packed_int_array.zig&quot;</span>).PackedIntSlice;</span>
<span class="line" id="L28"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PackedIntSliceEndian = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;packed_int_array.zig&quot;</span>).PackedIntSliceEndian;</span>
<span class="line" id="L29"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PriorityQueue = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;priority_queue.zig&quot;</span>).PriorityQueue;</span>
<span class="line" id="L30"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> PriorityDequeue = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;priority_dequeue.zig&quot;</span>).PriorityDequeue;</span>
<span class="line" id="L31"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Progress = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;Progress.zig&quot;</span>);</span>
<span class="line" id="L32"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SegmentedList = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;segmented_list.zig&quot;</span>).SegmentedList;</span>
<span class="line" id="L33"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SemanticVersion = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;SemanticVersion.zig&quot;</span>);</span>
<span class="line" id="L34"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> SinglyLinkedList = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linked_list.zig&quot;</span>).SinglyLinkedList;</span>
<span class="line" id="L35"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> StaticBitSet = bit_set.StaticBitSet;</span>
<span class="line" id="L36"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> StringHashMap = hash_map.StringHashMap;</span>
<span class="line" id="L37"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> StringHashMapUnmanaged = hash_map.StringHashMapUnmanaged;</span>
<span class="line" id="L38"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> StringArrayHashMap = array_hash_map.StringArrayHashMap;</span>
<span class="line" id="L39"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> StringArrayHashMapUnmanaged = array_hash_map.StringArrayHashMapUnmanaged;</span>
<span class="line" id="L40"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> TailQueue = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;linked_list.zig&quot;</span>).TailQueue;</span>
<span class="line" id="L41"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Target = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;target.zig&quot;</span>).Target;</span>
<span class="line" id="L42"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Thread = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;Thread.zig&quot;</span>);</span>
<span class="line" id="L43"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Treap = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;treap.zig&quot;</span>).Treap;</span>
<span class="line" id="L44"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> Tz = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;tz.zig&quot;</span>).Tz;</span>
<span class="line" id="L45"></span>
<span class="line" id="L46"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> array_hash_map = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;array_hash_map.zig&quot;</span>);</span>
<span class="line" id="L47"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> atomic = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;atomic.zig&quot;</span>);</span>
<span class="line" id="L48"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> base64 = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;base64.zig&quot;</span>);</span>
<span class="line" id="L49"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> bit_set = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;bit_set.zig&quot;</span>);</span>
<span class="line" id="L50"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> build = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;build.zig&quot;</span>);</span>
<span class="line" id="L51"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> builtin = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin.zig&quot;</span>);</span>
<span class="line" id="L52"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> c = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;c.zig&quot;</span>);</span>
<span class="line" id="L53"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> coff = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;coff.zig&quot;</span>);</span>
<span class="line" id="L54"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> compress = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;compress.zig&quot;</span>);</span>
<span class="line" id="L55"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> crypto = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;crypto.zig&quot;</span>);</span>
<span class="line" id="L56"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> cstr = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;cstr.zig&quot;</span>);</span>
<span class="line" id="L57"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> debug = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;debug.zig&quot;</span>);</span>
<span class="line" id="L58"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> dwarf = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;dwarf.zig&quot;</span>);</span>
<span class="line" id="L59"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> elf = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;elf.zig&quot;</span>);</span>
<span class="line" id="L60"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> enums = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;enums.zig&quot;</span>);</span>
<span class="line" id="L61"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> event = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;event.zig&quot;</span>);</span>
<span class="line" id="L62"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> fifo = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;fifo.zig&quot;</span>);</span>
<span class="line" id="L63"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> fmt = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;fmt.zig&quot;</span>);</span>
<span class="line" id="L64"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> fs = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;fs.zig&quot;</span>);</span>
<span class="line" id="L65"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> hash = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;hash.zig&quot;</span>);</span>
<span class="line" id="L66"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> hash_map = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;hash_map.zig&quot;</span>);</span>
<span class="line" id="L67"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> heap = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;heap.zig&quot;</span>);</span>
<span class="line" id="L68"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> http = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;http.zig&quot;</span>);</span>
<span class="line" id="L69"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> io = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;io.zig&quot;</span>);</span>
<span class="line" id="L70"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> json = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;json.zig&quot;</span>);</span>
<span class="line" id="L71"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> leb = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;leb128.zig&quot;</span>);</span>
<span class="line" id="L72"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> log = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;log.zig&quot;</span>);</span>
<span class="line" id="L73"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> macho = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;macho.zig&quot;</span>);</span>
<span class="line" id="L74"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> math = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;math.zig&quot;</span>);</span>
<span class="line" id="L75"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> mem = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;mem.zig&quot;</span>);</span>
<span class="line" id="L76"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> meta = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;meta.zig&quot;</span>);</span>
<span class="line" id="L77"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> net = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;net.zig&quot;</span>);</span>
<span class="line" id="L78"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> os = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;os.zig&quot;</span>);</span>
<span class="line" id="L79"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> once = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;once.zig&quot;</span>).once;</span>
<span class="line" id="L80"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> packed_int_array = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;packed_int_array.zig&quot;</span>);</span>
<span class="line" id="L81"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> pdb = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;pdb.zig&quot;</span>);</span>
<span class="line" id="L82"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> process = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;process.zig&quot;</span>);</span>
<span class="line" id="L83"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> rand = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;rand.zig&quot;</span>);</span>
<span class="line" id="L84"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> sort = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;sort.zig&quot;</span>);</span>
<span class="line" id="L85"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> simd = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;simd.zig&quot;</span>);</span>
<span class="line" id="L86"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> ascii = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;ascii.zig&quot;</span>);</span>
<span class="line" id="L87"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> testing = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;testing.zig&quot;</span>);</span>
<span class="line" id="L88"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> time = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;time.zig&quot;</span>);</span>
<span class="line" id="L89"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> unicode = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;unicode.zig&quot;</span>);</span>
<span class="line" id="L90"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> valgrind = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;valgrind.zig&quot;</span>);</span>
<span class="line" id="L91"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> wasm = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;wasm.zig&quot;</span>);</span>
<span class="line" id="L92"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> x = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;x.zig&quot;</span>);</span>
<span class="line" id="L93"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> zig = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;zig.zig&quot;</span>);</span>
<span class="line" id="L94"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> start = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;start.zig&quot;</span>);</span>
<span class="line" id="L95"></span>
<span class="line" id="L96"><span class="tok-comment">// This forces the start.zig file to be imported, and the comptime logic inside that</span>
</span>
<span class="line" id="L97"><span class="tok-comment">// file decides whether to export any appropriate start symbols, and call main.</span>
</span>
<span class="line" id="L98"><span class="tok-kw">comptime</span> {</span>
<span class="line" id="L99">    _ = start;</span>
<span class="line" id="L100">}</span>
<span class="line" id="L101"></span>
<span class="line" id="L102"><span class="tok-kw">test</span> {</span>
<span class="line" id="L103">    <span class="tok-kw">if</span> (<span class="tok-builtin">@import</span>(<span class="tok-str">&quot;builtin&quot;</span>).os.tag == .windows) {</span>
<span class="line" id="L104">        <span class="tok-comment">// We only test the Windows-relevant stuff to save memory because the CI</span>
</span>
<span class="line" id="L105">        <span class="tok-comment">// server is hitting OOM. TODO revert this after stage2 arrives.</span>
</span>
<span class="line" id="L106">        _ = ChildProcess;</span>
<span class="line" id="L107">        _ = DynLib;</span>
<span class="line" id="L108">        _ = Progress;</span>
<span class="line" id="L109">        _ = Target;</span>
<span class="line" id="L110">        _ = Thread;</span>
<span class="line" id="L111"></span>
<span class="line" id="L112">        _ = atomic;</span>
<span class="line" id="L113">        _ = build;</span>
<span class="line" id="L114">        _ = builtin;</span>
<span class="line" id="L115">        _ = debug;</span>
<span class="line" id="L116">        _ = event;</span>
<span class="line" id="L117">        _ = fs;</span>
<span class="line" id="L118">        _ = heap;</span>
<span class="line" id="L119">        _ = io;</span>
<span class="line" id="L120">        _ = log;</span>
<span class="line" id="L121">        _ = macho;</span>
<span class="line" id="L122">        _ = net;</span>
<span class="line" id="L123">        _ = os;</span>
<span class="line" id="L124">        _ = once;</span>
<span class="line" id="L125">        _ = pdb;</span>
<span class="line" id="L126">        _ = process;</span>
<span class="line" id="L127">        _ = testing;</span>
<span class="line" id="L128">        _ = time;</span>
<span class="line" id="L129">        _ = unicode;</span>
<span class="line" id="L130">        _ = zig;</span>
<span class="line" id="L131">        _ = start;</span>
<span class="line" id="L132">    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L133">        testing.refAllDecls(<span class="tok-builtin">@This</span>());</span>
<span class="line" id="L134">    }</span>
<span class="line" id="L135">}</span>
<span class="line" id="L136"></span>
</code></pre></body>
</html>