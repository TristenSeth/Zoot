<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>build/InstallRawStep.zig - source view</title>
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
<pre><code><span class="line" id="L1"><span class="tok-kw">const</span> std = <span class="tok-builtin">@import</span>(<span class="tok-str">&quot;std&quot;</span>);</span>
<span class="line" id="L2"></span>
<span class="line" id="L3"><span class="tok-kw">const</span> Allocator = std.mem.Allocator;</span>
<span class="line" id="L4"><span class="tok-kw">const</span> ArenaAllocator = std.heap.ArenaAllocator;</span>
<span class="line" id="L5"><span class="tok-kw">const</span> ArrayListUnmanaged = std.ArrayListUnmanaged;</span>
<span class="line" id="L6"><span class="tok-kw">const</span> Builder = std.build.Builder;</span>
<span class="line" id="L7"><span class="tok-kw">const</span> File = std.fs.File;</span>
<span class="line" id="L8"><span class="tok-kw">const</span> InstallDir = std.build.InstallDir;</span>
<span class="line" id="L9"><span class="tok-kw">const</span> LibExeObjStep = std.build.LibExeObjStep;</span>
<span class="line" id="L10"><span class="tok-kw">const</span> Step = std.build.Step;</span>
<span class="line" id="L11"><span class="tok-kw">const</span> elf = std.elf;</span>
<span class="line" id="L12"><span class="tok-kw">const</span> fs = std.fs;</span>
<span class="line" id="L13"><span class="tok-kw">const</span> io = std.io;</span>
<span class="line" id="L14"><span class="tok-kw">const</span> sort = std.sort;</span>
<span class="line" id="L15"></span>
<span class="line" id="L16"><span class="tok-kw">const</span> BinaryElfSection = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L17">    elfOffset: <span class="tok-type">u64</span>,</span>
<span class="line" id="L18">    binaryOffset: <span class="tok-type">u64</span>,</span>
<span class="line" id="L19">    fileSize: <span class="tok-type">usize</span>,</span>
<span class="line" id="L20">    name: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L21">    segment: ?*BinaryElfSegment,</span>
<span class="line" id="L22">};</span>
<span class="line" id="L23"></span>
<span class="line" id="L24"><span class="tok-kw">const</span> BinaryElfSegment = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L25">    physicalAddress: <span class="tok-type">u64</span>,</span>
<span class="line" id="L26">    virtualAddress: <span class="tok-type">u64</span>,</span>
<span class="line" id="L27">    elfOffset: <span class="tok-type">u64</span>,</span>
<span class="line" id="L28">    binaryOffset: <span class="tok-type">u64</span>,</span>
<span class="line" id="L29">    fileSize: <span class="tok-type">usize</span>,</span>
<span class="line" id="L30">    firstSection: ?*BinaryElfSection,</span>
<span class="line" id="L31">};</span>
<span class="line" id="L32"></span>
<span class="line" id="L33"><span class="tok-kw">const</span> BinaryElfOutput = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L34">    segments: ArrayListUnmanaged(*BinaryElfSegment),</span>
<span class="line" id="L35">    sections: ArrayListUnmanaged(*BinaryElfSection),</span>
<span class="line" id="L36">    allocator: Allocator,</span>
<span class="line" id="L37">    shstrtab: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L38"></span>
<span class="line" id="L39">    <span class="tok-kw">const</span> Self = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L40"></span>
<span class="line" id="L41">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">deinit</span>(self: *Self) <span class="tok-type">void</span> {</span>
<span class="line" id="L42">        <span class="tok-kw">if</span> (self.shstrtab) |shstrtab|</span>
<span class="line" id="L43">            self.allocator.free(shstrtab);</span>
<span class="line" id="L44">        self.sections.deinit(self.allocator);</span>
<span class="line" id="L45">        self.segments.deinit(self.allocator);</span>
<span class="line" id="L46">    }</span>
<span class="line" id="L47"></span>
<span class="line" id="L48">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">parse</span>(allocator: Allocator, elf_file: File) !Self {</span>
<span class="line" id="L49">        <span class="tok-kw">var</span> self: Self = .{</span>
<span class="line" id="L50">            .segments = .{},</span>
<span class="line" id="L51">            .sections = .{},</span>
<span class="line" id="L52">            .allocator = allocator,</span>
<span class="line" id="L53">            .shstrtab = <span class="tok-null">null</span>,</span>
<span class="line" id="L54">        };</span>
<span class="line" id="L55">        <span class="tok-kw">errdefer</span> self.sections.deinit(allocator);</span>
<span class="line" id="L56">        <span class="tok-kw">errdefer</span> self.segments.deinit(allocator);</span>
<span class="line" id="L57"></span>
<span class="line" id="L58">        <span class="tok-kw">const</span> elf_hdr = <span class="tok-kw">try</span> std.elf.Header.read(&amp;elf_file);</span>
<span class="line" id="L59"></span>
<span class="line" id="L60">        self.shstrtab = blk: {</span>
<span class="line" id="L61">            <span class="tok-kw">if</span> (elf_hdr.shstrndx &gt;= elf_hdr.shnum) <span class="tok-kw">break</span> :blk <span class="tok-null">null</span>;</span>
<span class="line" id="L62"></span>
<span class="line" id="L63">            <span class="tok-kw">var</span> section_headers = elf_hdr.section_header_iterator(&amp;elf_file);</span>
<span class="line" id="L64"></span>
<span class="line" id="L65">            <span class="tok-kw">var</span> section_counter: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L66">            <span class="tok-kw">while</span> (section_counter &lt; elf_hdr.shstrndx) : (section_counter += <span class="tok-number">1</span>) {</span>
<span class="line" id="L67">                _ = (<span class="tok-kw">try</span> section_headers.next()).?;</span>
<span class="line" id="L68">            }</span>
<span class="line" id="L69"></span>
<span class="line" id="L70">            <span class="tok-kw">const</span> shstrtab_shdr = (<span class="tok-kw">try</span> section_headers.next()).?;</span>
<span class="line" id="L71"></span>
<span class="line" id="L72">            <span class="tok-kw">const</span> buffer = <span class="tok-kw">try</span> allocator.alloc(<span class="tok-type">u8</span>, shstrtab_shdr.sh_size);</span>
<span class="line" id="L73">            <span class="tok-kw">errdefer</span> allocator.free(buffer);</span>
<span class="line" id="L74"></span>
<span class="line" id="L75">            <span class="tok-kw">const</span> num_read = <span class="tok-kw">try</span> elf_file.preadAll(buffer, shstrtab_shdr.sh_offset);</span>
<span class="line" id="L76">            <span class="tok-kw">if</span> (num_read != buffer.len) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.EndOfStream;</span>
<span class="line" id="L77"></span>
<span class="line" id="L78">            <span class="tok-kw">break</span> :blk buffer;</span>
<span class="line" id="L79">        };</span>
<span class="line" id="L80"></span>
<span class="line" id="L81">        <span class="tok-kw">errdefer</span> <span class="tok-kw">if</span> (self.shstrtab) |shstrtab| allocator.free(shstrtab);</span>
<span class="line" id="L82"></span>
<span class="line" id="L83">        <span class="tok-kw">var</span> section_headers = elf_hdr.section_header_iterator(&amp;elf_file);</span>
<span class="line" id="L84">        <span class="tok-kw">while</span> (<span class="tok-kw">try</span> section_headers.next()) |section| {</span>
<span class="line" id="L85">            <span class="tok-kw">if</span> (sectionValidForOutput(section)) {</span>
<span class="line" id="L86">                <span class="tok-kw">const</span> newSection = <span class="tok-kw">try</span> allocator.create(BinaryElfSection);</span>
<span class="line" id="L87"></span>
<span class="line" id="L88">                newSection.binaryOffset = <span class="tok-number">0</span>;</span>
<span class="line" id="L89">                newSection.elfOffset = section.sh_offset;</span>
<span class="line" id="L90">                newSection.fileSize = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, section.sh_size);</span>
<span class="line" id="L91">                newSection.segment = <span class="tok-null">null</span>;</span>
<span class="line" id="L92"></span>
<span class="line" id="L93">                newSection.name = <span class="tok-kw">if</span> (self.shstrtab) |shstrtab|</span>
<span class="line" id="L94">                    std.mem.span(<span class="tok-builtin">@ptrCast</span>([*:<span class="tok-number">0</span>]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, &amp;shstrtab[section.sh_name]))</span>
<span class="line" id="L95">                <span class="tok-kw">else</span></span>
<span class="line" id="L96">                    <span class="tok-null">null</span>;</span>
<span class="line" id="L97"></span>
<span class="line" id="L98">                <span class="tok-kw">try</span> self.sections.append(allocator, newSection);</span>
<span class="line" id="L99">            }</span>
<span class="line" id="L100">        }</span>
<span class="line" id="L101"></span>
<span class="line" id="L102">        <span class="tok-kw">var</span> program_headers = elf_hdr.program_header_iterator(&amp;elf_file);</span>
<span class="line" id="L103">        <span class="tok-kw">while</span> (<span class="tok-kw">try</span> program_headers.next()) |phdr| {</span>
<span class="line" id="L104">            <span class="tok-kw">if</span> (phdr.p_type == elf.PT_LOAD) {</span>
<span class="line" id="L105">                <span class="tok-kw">const</span> newSegment = <span class="tok-kw">try</span> allocator.create(BinaryElfSegment);</span>
<span class="line" id="L106"></span>
<span class="line" id="L107">                newSegment.physicalAddress = <span class="tok-kw">if</span> (phdr.p_paddr != <span class="tok-number">0</span>) phdr.p_paddr <span class="tok-kw">else</span> phdr.p_vaddr;</span>
<span class="line" id="L108">                newSegment.virtualAddress = phdr.p_vaddr;</span>
<span class="line" id="L109">                newSegment.fileSize = <span class="tok-builtin">@intCast</span>(<span class="tok-type">usize</span>, phdr.p_filesz);</span>
<span class="line" id="L110">                newSegment.elfOffset = phdr.p_offset;</span>
<span class="line" id="L111">                newSegment.binaryOffset = <span class="tok-number">0</span>;</span>
<span class="line" id="L112">                newSegment.firstSection = <span class="tok-null">null</span>;</span>
<span class="line" id="L113"></span>
<span class="line" id="L114">                <span class="tok-kw">for</span> (self.sections.items) |section| {</span>
<span class="line" id="L115">                    <span class="tok-kw">if</span> (sectionWithinSegment(section, phdr)) {</span>
<span class="line" id="L116">                        <span class="tok-kw">if</span> (section.segment) |sectionSegment| {</span>
<span class="line" id="L117">                            <span class="tok-kw">if</span> (sectionSegment.elfOffset &gt; newSegment.elfOffset) {</span>
<span class="line" id="L118">                                section.segment = newSegment;</span>
<span class="line" id="L119">                            }</span>
<span class="line" id="L120">                        } <span class="tok-kw">else</span> {</span>
<span class="line" id="L121">                            section.segment = newSegment;</span>
<span class="line" id="L122">                        }</span>
<span class="line" id="L123"></span>
<span class="line" id="L124">                        <span class="tok-kw">if</span> (newSegment.firstSection == <span class="tok-null">null</span>) {</span>
<span class="line" id="L125">                            newSegment.firstSection = section;</span>
<span class="line" id="L126">                        }</span>
<span class="line" id="L127">                    }</span>
<span class="line" id="L128">                }</span>
<span class="line" id="L129"></span>
<span class="line" id="L130">                <span class="tok-kw">try</span> self.segments.append(allocator, newSegment);</span>
<span class="line" id="L131">            }</span>
<span class="line" id="L132">        }</span>
<span class="line" id="L133"></span>
<span class="line" id="L134">        sort.sort(*BinaryElfSegment, self.segments.items, {}, segmentSortCompare);</span>
<span class="line" id="L135"></span>
<span class="line" id="L136">        <span class="tok-kw">for</span> (self.segments.items) |firstSegment, i| {</span>
<span class="line" id="L137">            <span class="tok-kw">if</span> (firstSegment.firstSection) |firstSection| {</span>
<span class="line" id="L138">                <span class="tok-kw">const</span> diff = firstSection.elfOffset - firstSegment.elfOffset;</span>
<span class="line" id="L139"></span>
<span class="line" id="L140">                firstSegment.elfOffset += diff;</span>
<span class="line" id="L141">                firstSegment.fileSize += diff;</span>
<span class="line" id="L142">                firstSegment.physicalAddress += diff;</span>
<span class="line" id="L143"></span>
<span class="line" id="L144">                <span class="tok-kw">const</span> basePhysicalAddress = firstSegment.physicalAddress;</span>
<span class="line" id="L145"></span>
<span class="line" id="L146">                <span class="tok-kw">for</span> (self.segments.items[i + <span class="tok-number">1</span> ..]) |segment| {</span>
<span class="line" id="L147">                    segment.binaryOffset = segment.physicalAddress - basePhysicalAddress;</span>
<span class="line" id="L148">                }</span>
<span class="line" id="L149">                <span class="tok-kw">break</span>;</span>
<span class="line" id="L150">            }</span>
<span class="line" id="L151">        }</span>
<span class="line" id="L152"></span>
<span class="line" id="L153">        <span class="tok-kw">for</span> (self.sections.items) |section| {</span>
<span class="line" id="L154">            <span class="tok-kw">if</span> (section.segment) |segment| {</span>
<span class="line" id="L155">                section.binaryOffset = segment.binaryOffset + (section.elfOffset - segment.elfOffset);</span>
<span class="line" id="L156">            }</span>
<span class="line" id="L157">        }</span>
<span class="line" id="L158"></span>
<span class="line" id="L159">        sort.sort(*BinaryElfSection, self.sections.items, {}, sectionSortCompare);</span>
<span class="line" id="L160"></span>
<span class="line" id="L161">        <span class="tok-kw">return</span> self;</span>
<span class="line" id="L162">    }</span>
<span class="line" id="L163"></span>
<span class="line" id="L164">    <span class="tok-kw">fn</span> <span class="tok-fn">sectionWithinSegment</span>(section: *BinaryElfSection, segment: elf.Elf64_Phdr) <span class="tok-type">bool</span> {</span>
<span class="line" id="L165">        <span class="tok-kw">return</span> segment.p_offset &lt;= section.elfOffset <span class="tok-kw">and</span> (segment.p_offset + segment.p_filesz) &gt;= (section.elfOffset + section.fileSize);</span>
<span class="line" id="L166">    }</span>
<span class="line" id="L167"></span>
<span class="line" id="L168">    <span class="tok-kw">fn</span> <span class="tok-fn">sectionValidForOutput</span>(shdr: <span class="tok-kw">anytype</span>) <span class="tok-type">bool</span> {</span>
<span class="line" id="L169">        <span class="tok-kw">return</span> shdr.sh_size &gt; <span class="tok-number">0</span> <span class="tok-kw">and</span> shdr.sh_type != elf.SHT_NOBITS <span class="tok-kw">and</span></span>
<span class="line" id="L170">            ((shdr.sh_flags &amp; elf.SHF_ALLOC) == elf.SHF_ALLOC);</span>
<span class="line" id="L171">    }</span>
<span class="line" id="L172"></span>
<span class="line" id="L173">    <span class="tok-kw">fn</span> <span class="tok-fn">segmentSortCompare</span>(context: <span class="tok-type">void</span>, left: *BinaryElfSegment, right: *BinaryElfSegment) <span class="tok-type">bool</span> {</span>
<span class="line" id="L174">        _ = context;</span>
<span class="line" id="L175">        <span class="tok-kw">if</span> (left.physicalAddress &lt; right.physicalAddress) {</span>
<span class="line" id="L176">            <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L177">        }</span>
<span class="line" id="L178">        <span class="tok-kw">if</span> (left.physicalAddress &gt; right.physicalAddress) {</span>
<span class="line" id="L179">            <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L180">        }</span>
<span class="line" id="L181">        <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L182">    }</span>
<span class="line" id="L183"></span>
<span class="line" id="L184">    <span class="tok-kw">fn</span> <span class="tok-fn">sectionSortCompare</span>(context: <span class="tok-type">void</span>, left: *BinaryElfSection, right: *BinaryElfSection) <span class="tok-type">bool</span> {</span>
<span class="line" id="L185">        _ = context;</span>
<span class="line" id="L186">        <span class="tok-kw">return</span> left.binaryOffset &lt; right.binaryOffset;</span>
<span class="line" id="L187">    }</span>
<span class="line" id="L188">};</span>
<span class="line" id="L189"></span>
<span class="line" id="L190"><span class="tok-kw">fn</span> <span class="tok-fn">writeBinaryElfSection</span>(elf_file: File, out_file: File, section: *BinaryElfSection) !<span class="tok-type">void</span> {</span>
<span class="line" id="L191">    <span class="tok-kw">try</span> out_file.writeFileAll(elf_file, .{</span>
<span class="line" id="L192">        .in_offset = section.elfOffset,</span>
<span class="line" id="L193">        .in_len = section.fileSize,</span>
<span class="line" id="L194">    });</span>
<span class="line" id="L195">}</span>
<span class="line" id="L196"></span>
<span class="line" id="L197"><span class="tok-kw">const</span> HexWriter = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L198">    prev_addr: ?<span class="tok-type">u32</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L199">    out_file: File,</span>
<span class="line" id="L200"></span>
<span class="line" id="L201">    <span class="tok-comment">/// Max data bytes per line of output</span></span>
<span class="line" id="L202">    <span class="tok-kw">const</span> MAX_PAYLOAD_LEN: <span class="tok-type">u8</span> = <span class="tok-number">16</span>;</span>
<span class="line" id="L203"></span>
<span class="line" id="L204">    <span class="tok-kw">fn</span> <span class="tok-fn">addressParts</span>(address: <span class="tok-type">u16</span>) [<span class="tok-number">2</span>]<span class="tok-type">u8</span> {</span>
<span class="line" id="L205">        <span class="tok-kw">const</span> msb = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, address &gt;&gt; <span class="tok-number">8</span>);</span>
<span class="line" id="L206">        <span class="tok-kw">const</span> lsb = <span class="tok-builtin">@truncate</span>(<span class="tok-type">u8</span>, address);</span>
<span class="line" id="L207">        <span class="tok-kw">return</span> [<span class="tok-number">2</span>]<span class="tok-type">u8</span>{ msb, lsb };</span>
<span class="line" id="L208">    }</span>
<span class="line" id="L209"></span>
<span class="line" id="L210">    <span class="tok-kw">const</span> Record = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L211">        <span class="tok-kw">const</span> Type = <span class="tok-kw">enum</span>(<span class="tok-type">u8</span>) {</span>
<span class="line" id="L212">            Data = <span class="tok-number">0</span>,</span>
<span class="line" id="L213">            EOF = <span class="tok-number">1</span>,</span>
<span class="line" id="L214">            ExtendedSegmentAddress = <span class="tok-number">2</span>,</span>
<span class="line" id="L215">            ExtendedLinearAddress = <span class="tok-number">4</span>,</span>
<span class="line" id="L216">        };</span>
<span class="line" id="L217"></span>
<span class="line" id="L218">        address: <span class="tok-type">u16</span>,</span>
<span class="line" id="L219">        payload: <span class="tok-kw">union</span>(Type) {</span>
<span class="line" id="L220">            Data: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L221">            EOF: <span class="tok-type">void</span>,</span>
<span class="line" id="L222">            ExtendedSegmentAddress: [<span class="tok-number">2</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L223">            ExtendedLinearAddress: [<span class="tok-number">2</span>]<span class="tok-type">u8</span>,</span>
<span class="line" id="L224">        },</span>
<span class="line" id="L225"></span>
<span class="line" id="L226">        <span class="tok-kw">fn</span> <span class="tok-fn">EOF</span>() Record {</span>
<span class="line" id="L227">            <span class="tok-kw">return</span> Record{</span>
<span class="line" id="L228">                .address = <span class="tok-number">0</span>,</span>
<span class="line" id="L229">                .payload = .EOF,</span>
<span class="line" id="L230">            };</span>
<span class="line" id="L231">        }</span>
<span class="line" id="L232"></span>
<span class="line" id="L233">        <span class="tok-kw">fn</span> <span class="tok-fn">Data</span>(address: <span class="tok-type">u32</span>, data: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) Record {</span>
<span class="line" id="L234">            <span class="tok-kw">return</span> Record{</span>
<span class="line" id="L235">                .address = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, address % <span class="tok-number">0x10000</span>),</span>
<span class="line" id="L236">                .payload = .{ .Data = data },</span>
<span class="line" id="L237">            };</span>
<span class="line" id="L238">        }</span>
<span class="line" id="L239"></span>
<span class="line" id="L240">        <span class="tok-kw">fn</span> <span class="tok-fn">Address</span>(address: <span class="tok-type">u32</span>) Record {</span>
<span class="line" id="L241">            std.debug.assert(address &gt; <span class="tok-number">0xFFFF</span>);</span>
<span class="line" id="L242">            <span class="tok-kw">const</span> segment = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u16</span>, address / <span class="tok-number">0x10000</span>);</span>
<span class="line" id="L243">            <span class="tok-kw">if</span> (address &gt; <span class="tok-number">0xFFFFF</span>) {</span>
<span class="line" id="L244">                <span class="tok-kw">return</span> Record{</span>
<span class="line" id="L245">                    .address = <span class="tok-number">0</span>,</span>
<span class="line" id="L246">                    .payload = .{ .ExtendedLinearAddress = addressParts(segment) },</span>
<span class="line" id="L247">                };</span>
<span class="line" id="L248">            } <span class="tok-kw">else</span> {</span>
<span class="line" id="L249">                <span class="tok-kw">return</span> Record{</span>
<span class="line" id="L250">                    .address = <span class="tok-number">0</span>,</span>
<span class="line" id="L251">                    .payload = .{ .ExtendedSegmentAddress = addressParts(segment &lt;&lt; <span class="tok-number">12</span>) },</span>
<span class="line" id="L252">                };</span>
<span class="line" id="L253">            }</span>
<span class="line" id="L254">        }</span>
<span class="line" id="L255"></span>
<span class="line" id="L256">        <span class="tok-kw">fn</span> <span class="tok-fn">getPayloadBytes</span>(self: Record) []<span class="tok-kw">const</span> <span class="tok-type">u8</span> {</span>
<span class="line" id="L257">            <span class="tok-kw">return</span> <span class="tok-kw">switch</span> (self.payload) {</span>
<span class="line" id="L258">                .Data =&gt; |d| d,</span>
<span class="line" id="L259">                .EOF =&gt; <span class="tok-builtin">@as</span>([]<span class="tok-kw">const</span> <span class="tok-type">u8</span>, &amp;.{}),</span>
<span class="line" id="L260">                .ExtendedSegmentAddress, .ExtendedLinearAddress =&gt; |*seg| seg,</span>
<span class="line" id="L261">            };</span>
<span class="line" id="L262">        }</span>
<span class="line" id="L263"></span>
<span class="line" id="L264">        <span class="tok-kw">fn</span> <span class="tok-fn">checksum</span>(self: Record) <span class="tok-type">u8</span> {</span>
<span class="line" id="L265">            <span class="tok-kw">const</span> payload_bytes = self.getPayloadBytes();</span>
<span class="line" id="L266"></span>
<span class="line" id="L267">            <span class="tok-kw">var</span> sum: <span class="tok-type">u8</span> = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, payload_bytes.len);</span>
<span class="line" id="L268">            <span class="tok-kw">const</span> parts = addressParts(self.address);</span>
<span class="line" id="L269">            sum +%= parts[<span class="tok-number">0</span>];</span>
<span class="line" id="L270">            sum +%= parts[<span class="tok-number">1</span>];</span>
<span class="line" id="L271">            sum +%= <span class="tok-builtin">@enumToInt</span>(self.payload);</span>
<span class="line" id="L272">            <span class="tok-kw">for</span> (payload_bytes) |byte| {</span>
<span class="line" id="L273">                sum +%= byte;</span>
<span class="line" id="L274">            }</span>
<span class="line" id="L275">            <span class="tok-kw">return</span> (sum ^ <span class="tok-number">0xFF</span>) +% <span class="tok-number">1</span>;</span>
<span class="line" id="L276">        }</span>
<span class="line" id="L277"></span>
<span class="line" id="L278">        <span class="tok-kw">fn</span> <span class="tok-fn">write</span>(self: Record, file: File) File.WriteError!<span class="tok-type">void</span> {</span>
<span class="line" id="L279">            <span class="tok-kw">const</span> linesep = <span class="tok-str">&quot;\r\n&quot;</span>;</span>
<span class="line" id="L280">            <span class="tok-comment">// colon, (length, address, type, payload, checksum) as hex, CRLF</span>
</span>
<span class="line" id="L281">            <span class="tok-kw">const</span> BUFSIZE = <span class="tok-number">1</span> + (<span class="tok-number">1</span> + <span class="tok-number">2</span> + <span class="tok-number">1</span> + MAX_PAYLOAD_LEN + <span class="tok-number">1</span>) * <span class="tok-number">2</span> + linesep.len;</span>
<span class="line" id="L282">            <span class="tok-kw">var</span> outbuf: [BUFSIZE]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L283">            <span class="tok-kw">const</span> payload_bytes = self.getPayloadBytes();</span>
<span class="line" id="L284">            std.debug.assert(payload_bytes.len &lt;= MAX_PAYLOAD_LEN);</span>
<span class="line" id="L285"></span>
<span class="line" id="L286">            <span class="tok-kw">const</span> line = <span class="tok-kw">try</span> std.fmt.bufPrint(&amp;outbuf, <span class="tok-str">&quot;:{0X:0&gt;2}{1X:0&gt;4}{2X:0&gt;2}{3s}{4X:0&gt;2}&quot;</span> ++ linesep, .{</span>
<span class="line" id="L287">                <span class="tok-builtin">@intCast</span>(<span class="tok-type">u8</span>, payload_bytes.len),</span>
<span class="line" id="L288">                self.address,</span>
<span class="line" id="L289">                <span class="tok-builtin">@enumToInt</span>(self.payload),</span>
<span class="line" id="L290">                std.fmt.fmtSliceHexUpper(payload_bytes),</span>
<span class="line" id="L291">                self.checksum(),</span>
<span class="line" id="L292">            });</span>
<span class="line" id="L293">            <span class="tok-kw">try</span> file.writeAll(line);</span>
<span class="line" id="L294">        }</span>
<span class="line" id="L295">    };</span>
<span class="line" id="L296"></span>
<span class="line" id="L297">    <span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">writeSegment</span>(self: *HexWriter, segment: *<span class="tok-kw">const</span> BinaryElfSegment, elf_file: File) !<span class="tok-type">void</span> {</span>
<span class="line" id="L298">        <span class="tok-kw">var</span> buf: [MAX_PAYLOAD_LEN]<span class="tok-type">u8</span> = <span class="tok-null">undefined</span>;</span>
<span class="line" id="L299">        <span class="tok-kw">var</span> bytes_read: <span class="tok-type">usize</span> = <span class="tok-number">0</span>;</span>
<span class="line" id="L300">        <span class="tok-kw">while</span> (bytes_read &lt; segment.fileSize) {</span>
<span class="line" id="L301">            <span class="tok-kw">const</span> row_address = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, segment.physicalAddress + bytes_read);</span>
<span class="line" id="L302"></span>
<span class="line" id="L303">            <span class="tok-kw">const</span> remaining = segment.fileSize - bytes_read;</span>
<span class="line" id="L304">            <span class="tok-kw">const</span> to_read = <span class="tok-builtin">@minimum</span>(remaining, MAX_PAYLOAD_LEN);</span>
<span class="line" id="L305">            <span class="tok-kw">const</span> did_read = <span class="tok-kw">try</span> elf_file.preadAll(buf[<span class="tok-number">0</span>..to_read], segment.elfOffset + bytes_read);</span>
<span class="line" id="L306">            <span class="tok-kw">if</span> (did_read &lt; to_read) <span class="tok-kw">return</span> <span class="tok-kw">error</span>.UnexpectedEOF;</span>
<span class="line" id="L307"></span>
<span class="line" id="L308">            <span class="tok-kw">try</span> self.writeDataRow(row_address, buf[<span class="tok-number">0</span>..did_read]);</span>
<span class="line" id="L309"></span>
<span class="line" id="L310">            bytes_read += did_read;</span>
<span class="line" id="L311">        }</span>
<span class="line" id="L312">    }</span>
<span class="line" id="L313"></span>
<span class="line" id="L314">    <span class="tok-kw">fn</span> <span class="tok-fn">writeDataRow</span>(self: *HexWriter, address: <span class="tok-type">u32</span>, data: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) File.WriteError!<span class="tok-type">void</span> {</span>
<span class="line" id="L315">        <span class="tok-kw">const</span> record = Record.Data(address, data);</span>
<span class="line" id="L316">        <span class="tok-kw">if</span> (address &gt; <span class="tok-number">0xFFFF</span> <span class="tok-kw">and</span> (self.prev_addr == <span class="tok-null">null</span> <span class="tok-kw">or</span> record.address != self.prev_addr.?)) {</span>
<span class="line" id="L317">            <span class="tok-kw">try</span> Record.Address(address).write(self.out_file);</span>
<span class="line" id="L318">        }</span>
<span class="line" id="L319">        <span class="tok-kw">try</span> record.write(self.out_file);</span>
<span class="line" id="L320">        self.prev_addr = <span class="tok-builtin">@intCast</span>(<span class="tok-type">u32</span>, record.address + data.len);</span>
<span class="line" id="L321">    }</span>
<span class="line" id="L322"></span>
<span class="line" id="L323">    <span class="tok-kw">fn</span> <span class="tok-fn">writeEOF</span>(self: HexWriter) File.WriteError!<span class="tok-type">void</span> {</span>
<span class="line" id="L324">        <span class="tok-kw">try</span> Record.EOF().write(self.out_file);</span>
<span class="line" id="L325">    }</span>
<span class="line" id="L326">};</span>
<span class="line" id="L327"></span>
<span class="line" id="L328"><span class="tok-kw">fn</span> <span class="tok-fn">containsValidAddressRange</span>(segments: []*BinaryElfSegment) <span class="tok-type">bool</span> {</span>
<span class="line" id="L329">    <span class="tok-kw">const</span> max_address = std.math.maxInt(<span class="tok-type">u32</span>);</span>
<span class="line" id="L330">    <span class="tok-kw">for</span> (segments) |segment| {</span>
<span class="line" id="L331">        <span class="tok-kw">if</span> (segment.fileSize &gt; max_address <span class="tok-kw">or</span></span>
<span class="line" id="L332">            segment.physicalAddress &gt; max_address - segment.fileSize) <span class="tok-kw">return</span> <span class="tok-null">false</span>;</span>
<span class="line" id="L333">    }</span>
<span class="line" id="L334">    <span class="tok-kw">return</span> <span class="tok-null">true</span>;</span>
<span class="line" id="L335">}</span>
<span class="line" id="L336"></span>
<span class="line" id="L337"><span class="tok-kw">fn</span> <span class="tok-fn">padFile</span>(f: fs.File, size: ?<span class="tok-type">usize</span>) !<span class="tok-type">void</span> {</span>
<span class="line" id="L338">    <span class="tok-kw">if</span> (size) |pad_size| {</span>
<span class="line" id="L339">        <span class="tok-kw">const</span> current_size = <span class="tok-kw">try</span> f.getEndPos();</span>
<span class="line" id="L340">        <span class="tok-kw">if</span> (current_size &lt; pad_size) {</span>
<span class="line" id="L341">            <span class="tok-kw">try</span> f.seekTo(pad_size - <span class="tok-number">1</span>);</span>
<span class="line" id="L342">            <span class="tok-kw">try</span> f.writer().writeByte(<span class="tok-number">0</span>);</span>
<span class="line" id="L343">        }</span>
<span class="line" id="L344">        <span class="tok-kw">if</span> (current_size &gt; pad_size) {</span>
<span class="line" id="L345">            <span class="tok-kw">return</span> <span class="tok-kw">error</span>.FileTooLarge; <span class="tok-comment">// Maybe this shouldn't be an error?</span>
</span>
<span class="line" id="L346">        }</span>
<span class="line" id="L347">    }</span>
<span class="line" id="L348">}</span>
<span class="line" id="L349"></span>
<span class="line" id="L350"><span class="tok-kw">fn</span> <span class="tok-fn">emitRaw</span>(allocator: Allocator, elf_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, raw_path: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, options: CreateOptions) !<span class="tok-type">void</span> {</span>
<span class="line" id="L351">    <span class="tok-kw">var</span> elf_file = <span class="tok-kw">try</span> fs.cwd().openFile(elf_path, .{});</span>
<span class="line" id="L352">    <span class="tok-kw">defer</span> elf_file.close();</span>
<span class="line" id="L353"></span>
<span class="line" id="L354">    <span class="tok-kw">var</span> out_file = <span class="tok-kw">try</span> fs.cwd().createFile(raw_path, .{});</span>
<span class="line" id="L355">    <span class="tok-kw">defer</span> out_file.close();</span>
<span class="line" id="L356"></span>
<span class="line" id="L357">    <span class="tok-kw">var</span> binary_elf_output = <span class="tok-kw">try</span> BinaryElfOutput.parse(allocator, elf_file);</span>
<span class="line" id="L358">    <span class="tok-kw">defer</span> binary_elf_output.deinit();</span>
<span class="line" id="L359"></span>
<span class="line" id="L360">    <span class="tok-kw">const</span> effective_format = options.format <span class="tok-kw">orelse</span> detectFormat(raw_path);</span>
<span class="line" id="L361"></span>
<span class="line" id="L362">    <span class="tok-kw">if</span> (options.only_section_name) |target_name| {</span>
<span class="line" id="L363">        <span class="tok-kw">switch</span> (effective_format) {</span>
<span class="line" id="L364">            <span class="tok-comment">// Hex format can only write segments/phdrs, sections not supported yet</span>
</span>
<span class="line" id="L365">            .hex =&gt; <span class="tok-kw">return</span> <span class="tok-kw">error</span>.NotYetImplemented,</span>
<span class="line" id="L366">            .bin =&gt; {</span>
<span class="line" id="L367">                <span class="tok-kw">for</span> (binary_elf_output.sections.items) |section| {</span>
<span class="line" id="L368">                    <span class="tok-kw">if</span> (section.name) |curr_name| {</span>
<span class="line" id="L369">                        <span class="tok-kw">if</span> (!std.mem.eql(<span class="tok-type">u8</span>, curr_name, target_name))</span>
<span class="line" id="L370">                            <span class="tok-kw">continue</span>;</span>
<span class="line" id="L371">                    } <span class="tok-kw">else</span> {</span>
<span class="line" id="L372">                        <span class="tok-kw">continue</span>;</span>
<span class="line" id="L373">                    }</span>
<span class="line" id="L374"></span>
<span class="line" id="L375">                    <span class="tok-kw">try</span> writeBinaryElfSection(elf_file, out_file, section);</span>
<span class="line" id="L376">                    <span class="tok-kw">try</span> padFile(out_file, options.pad_to_size);</span>
<span class="line" id="L377">                    <span class="tok-kw">return</span>;</span>
<span class="line" id="L378">                }</span>
<span class="line" id="L379">            },</span>
<span class="line" id="L380">        }</span>
<span class="line" id="L381"></span>
<span class="line" id="L382">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.SectionNotFound;</span>
<span class="line" id="L383">    }</span>
<span class="line" id="L384"></span>
<span class="line" id="L385">    <span class="tok-kw">switch</span> (effective_format) {</span>
<span class="line" id="L386">        .bin =&gt; {</span>
<span class="line" id="L387">            <span class="tok-kw">for</span> (binary_elf_output.sections.items) |section| {</span>
<span class="line" id="L388">                <span class="tok-kw">try</span> out_file.seekTo(section.binaryOffset);</span>
<span class="line" id="L389">                <span class="tok-kw">try</span> writeBinaryElfSection(elf_file, out_file, section);</span>
<span class="line" id="L390">            }</span>
<span class="line" id="L391">            <span class="tok-kw">try</span> padFile(out_file, options.pad_to_size);</span>
<span class="line" id="L392">        },</span>
<span class="line" id="L393">        .hex =&gt; {</span>
<span class="line" id="L394">            <span class="tok-kw">if</span> (binary_elf_output.segments.items.len == <span class="tok-number">0</span>) <span class="tok-kw">return</span>;</span>
<span class="line" id="L395">            <span class="tok-kw">if</span> (!containsValidAddressRange(binary_elf_output.segments.items)) {</span>
<span class="line" id="L396">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidHexfileAddressRange;</span>
<span class="line" id="L397">            }</span>
<span class="line" id="L398"></span>
<span class="line" id="L399">            <span class="tok-kw">var</span> hex_writer = HexWriter{ .out_file = out_file };</span>
<span class="line" id="L400">            <span class="tok-kw">for</span> (binary_elf_output.sections.items) |section| {</span>
<span class="line" id="L401">                <span class="tok-kw">if</span> (section.segment) |segment| {</span>
<span class="line" id="L402">                    <span class="tok-kw">try</span> hex_writer.writeSegment(segment, elf_file);</span>
<span class="line" id="L403">                }</span>
<span class="line" id="L404">            }</span>
<span class="line" id="L405">            <span class="tok-kw">if</span> (options.pad_to_size) |_| {</span>
<span class="line" id="L406">                <span class="tok-comment">// Padding to a size in hex files isn't applicable</span>
</span>
<span class="line" id="L407">                <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidArgument;</span>
<span class="line" id="L408">            }</span>
<span class="line" id="L409">            <span class="tok-kw">try</span> hex_writer.writeEOF();</span>
<span class="line" id="L410">        },</span>
<span class="line" id="L411">    }</span>
<span class="line" id="L412">}</span>
<span class="line" id="L413"></span>
<span class="line" id="L414"><span class="tok-kw">const</span> InstallRawStep = <span class="tok-builtin">@This</span>();</span>
<span class="line" id="L415"></span>
<span class="line" id="L416"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> base_id = .install_raw;</span>
<span class="line" id="L417"></span>
<span class="line" id="L418"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> RawFormat = <span class="tok-kw">enum</span> {</span>
<span class="line" id="L419">    bin,</span>
<span class="line" id="L420">    hex,</span>
<span class="line" id="L421">};</span>
<span class="line" id="L422"></span>
<span class="line" id="L423">step: Step,</span>
<span class="line" id="L424">builder: *Builder,</span>
<span class="line" id="L425">artifact: *LibExeObjStep,</span>
<span class="line" id="L426">dest_dir: InstallDir,</span>
<span class="line" id="L427">dest_filename: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>,</span>
<span class="line" id="L428">options: CreateOptions,</span>
<span class="line" id="L429">output_file: std.build.GeneratedFile,</span>
<span class="line" id="L430"></span>
<span class="line" id="L431"><span class="tok-kw">fn</span> <span class="tok-fn">detectFormat</span>(filename: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>) RawFormat {</span>
<span class="line" id="L432">    <span class="tok-kw">if</span> (std.mem.endsWith(<span class="tok-type">u8</span>, filename, <span class="tok-str">&quot;.hex&quot;</span>) <span class="tok-kw">or</span> std.mem.endsWith(<span class="tok-type">u8</span>, filename, <span class="tok-str">&quot;.ihex&quot;</span>)) {</span>
<span class="line" id="L433">        <span class="tok-kw">return</span> .hex;</span>
<span class="line" id="L434">    }</span>
<span class="line" id="L435">    <span class="tok-kw">return</span> .bin;</span>
<span class="line" id="L436">}</span>
<span class="line" id="L437"></span>
<span class="line" id="L438"><span class="tok-kw">pub</span> <span class="tok-kw">const</span> CreateOptions = <span class="tok-kw">struct</span> {</span>
<span class="line" id="L439">    format: ?RawFormat = <span class="tok-null">null</span>,</span>
<span class="line" id="L440">    dest_dir: ?InstallDir = <span class="tok-null">null</span>,</span>
<span class="line" id="L441">    only_section_name: ?[]<span class="tok-kw">const</span> <span class="tok-type">u8</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L442">    pad_to_size: ?<span class="tok-type">usize</span> = <span class="tok-null">null</span>,</span>
<span class="line" id="L443">};</span>
<span class="line" id="L444"></span>
<span class="line" id="L445"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">create</span>(builder: *Builder, artifact: *LibExeObjStep, dest_filename: []<span class="tok-kw">const</span> <span class="tok-type">u8</span>, options: CreateOptions) *InstallRawStep {</span>
<span class="line" id="L446">    <span class="tok-kw">const</span> self = builder.allocator.create(InstallRawStep) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L447">    self.* = InstallRawStep{</span>
<span class="line" id="L448">        .step = Step.init(.install_raw, builder.fmt(<span class="tok-str">&quot;install raw binary {s}&quot;</span>, .{artifact.step.name}), builder.allocator, make),</span>
<span class="line" id="L449">        .builder = builder,</span>
<span class="line" id="L450">        .artifact = artifact,</span>
<span class="line" id="L451">        .dest_dir = <span class="tok-kw">if</span> (options.dest_dir) |d| d <span class="tok-kw">else</span> <span class="tok-kw">switch</span> (artifact.kind) {</span>
<span class="line" id="L452">            .obj =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L453">            .@&quot;test&quot; =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L454">            .exe, .test_exe =&gt; .bin,</span>
<span class="line" id="L455">            .lib =&gt; <span class="tok-kw">unreachable</span>,</span>
<span class="line" id="L456">        },</span>
<span class="line" id="L457">        .dest_filename = dest_filename,</span>
<span class="line" id="L458">        .options = options,</span>
<span class="line" id="L459">        .output_file = std.build.GeneratedFile{ .step = &amp;self.step },</span>
<span class="line" id="L460">    };</span>
<span class="line" id="L461">    self.step.dependOn(&amp;artifact.step);</span>
<span class="line" id="L462"></span>
<span class="line" id="L463">    builder.pushInstalledFile(self.dest_dir, dest_filename);</span>
<span class="line" id="L464">    <span class="tok-kw">return</span> self;</span>
<span class="line" id="L465">}</span>
<span class="line" id="L466"></span>
<span class="line" id="L467"><span class="tok-kw">pub</span> <span class="tok-kw">fn</span> <span class="tok-fn">getOutputSource</span>(self: *<span class="tok-kw">const</span> InstallRawStep) std.build.FileSource {</span>
<span class="line" id="L468">    <span class="tok-kw">return</span> std.build.FileSource{ .generated = &amp;self.output_file };</span>
<span class="line" id="L469">}</span>
<span class="line" id="L470"></span>
<span class="line" id="L471"><span class="tok-kw">fn</span> <span class="tok-fn">make</span>(step: *Step) !<span class="tok-type">void</span> {</span>
<span class="line" id="L472">    <span class="tok-kw">const</span> self = <span class="tok-builtin">@fieldParentPtr</span>(InstallRawStep, <span class="tok-str">&quot;step&quot;</span>, step);</span>
<span class="line" id="L473">    <span class="tok-kw">const</span> builder = self.builder;</span>
<span class="line" id="L474"></span>
<span class="line" id="L475">    <span class="tok-kw">if</span> (self.artifact.target.getObjectFormat() != .elf) {</span>
<span class="line" id="L476">        std.debug.print(<span class="tok-str">&quot;InstallRawStep only works with ELF format.\n&quot;</span>, .{});</span>
<span class="line" id="L477">        <span class="tok-kw">return</span> <span class="tok-kw">error</span>.InvalidObjectFormat;</span>
<span class="line" id="L478">    }</span>
<span class="line" id="L479"></span>
<span class="line" id="L480">    <span class="tok-kw">const</span> full_src_path = self.artifact.getOutputSource().getPath(builder);</span>
<span class="line" id="L481">    <span class="tok-kw">const</span> full_dest_path = builder.getInstallPath(self.dest_dir, self.dest_filename);</span>
<span class="line" id="L482"></span>
<span class="line" id="L483">    fs.cwd().makePath(builder.getInstallPath(self.dest_dir, <span class="tok-str">&quot;&quot;</span>)) <span class="tok-kw">catch</span> <span class="tok-kw">unreachable</span>;</span>
<span class="line" id="L484">    <span class="tok-kw">try</span> emitRaw(builder.allocator, full_src_path, full_dest_path, self.options);</span>
<span class="line" id="L485">    self.output_file.path = full_dest_path;</span>
<span class="line" id="L486">}</span>
<span class="line" id="L487"></span>
<span class="line" id="L488"><span class="tok-kw">test</span> {</span>
<span class="line" id="L489">    std.testing.refAllDecls(InstallRawStep);</span>
<span class="line" id="L490">}</span>
<span class="line" id="L491"></span>
<span class="line" id="L492"><span class="tok-kw">test</span> <span class="tok-str">&quot;Detect format from filename&quot;</span> {</span>
<span class="line" id="L493">    <span class="tok-kw">try</span> std.testing.expectEqual(RawFormat.hex, detectFormat(<span class="tok-str">&quot;foo.hex&quot;</span>));</span>
<span class="line" id="L494">    <span class="tok-kw">try</span> std.testing.expectEqual(RawFormat.hex, detectFormat(<span class="tok-str">&quot;foo.ihex&quot;</span>));</span>
<span class="line" id="L495">    <span class="tok-kw">try</span> std.testing.expectEqual(RawFormat.bin, detectFormat(<span class="tok-str">&quot;foo.bin&quot;</span>));</span>
<span class="line" id="L496">    <span class="tok-kw">try</span> std.testing.expectEqual(RawFormat.bin, detectFormat(<span class="tok-str">&quot;foo.bar&quot;</span>));</span>
<span class="line" id="L497">    <span class="tok-kw">try</span> std.testing.expectEqual(RawFormat.bin, detectFormat(<span class="tok-str">&quot;a&quot;</span>));</span>
<span class="line" id="L498">}</span>
<span class="line" id="L499"></span>
<span class="line" id="L500"><span class="tok-kw">test</span> <span class="tok-str">&quot;containsValidAddressRange&quot;</span> {</span>
<span class="line" id="L501">    <span class="tok-kw">var</span> segment = BinaryElfSegment{</span>
<span class="line" id="L502">        .physicalAddress = <span class="tok-number">0</span>,</span>
<span class="line" id="L503">        .virtualAddress = <span class="tok-number">0</span>,</span>
<span class="line" id="L504">        .elfOffset = <span class="tok-number">0</span>,</span>
<span class="line" id="L505">        .binaryOffset = <span class="tok-number">0</span>,</span>
<span class="line" id="L506">        .fileSize = <span class="tok-number">0</span>,</span>
<span class="line" id="L507">        .firstSection = <span class="tok-null">null</span>,</span>
<span class="line" id="L508">    };</span>
<span class="line" id="L509">    <span class="tok-kw">var</span> buf: [<span class="tok-number">1</span>]*BinaryElfSegment = .{&amp;segment};</span>
<span class="line" id="L510"></span>
<span class="line" id="L511">    <span class="tok-comment">// segment too big</span>
</span>
<span class="line" id="L512">    segment.fileSize = std.math.maxInt(<span class="tok-type">u32</span>) + <span class="tok-number">1</span>;</span>
<span class="line" id="L513">    <span class="tok-kw">try</span> std.testing.expect(!containsValidAddressRange(&amp;buf));</span>
<span class="line" id="L514"></span>
<span class="line" id="L515">    <span class="tok-comment">// start address too big</span>
</span>
<span class="line" id="L516">    segment.physicalAddress = std.math.maxInt(<span class="tok-type">u32</span>) + <span class="tok-number">1</span>;</span>
<span class="line" id="L517">    segment.fileSize = <span class="tok-number">2</span>;</span>
<span class="line" id="L518">    <span class="tok-kw">try</span> std.testing.expect(!containsValidAddressRange(&amp;buf));</span>
<span class="line" id="L519"></span>
<span class="line" id="L520">    <span class="tok-comment">// max address too big</span>
</span>
<span class="line" id="L521">    segment.physicalAddress = std.math.maxInt(<span class="tok-type">u32</span>) - <span class="tok-number">1</span>;</span>
<span class="line" id="L522">    segment.fileSize = <span class="tok-number">2</span>;</span>
<span class="line" id="L523">    <span class="tok-kw">try</span> std.testing.expect(!containsValidAddressRange(&amp;buf));</span>
<span class="line" id="L524"></span>
<span class="line" id="L525">    <span class="tok-comment">// is ok</span>
</span>
<span class="line" id="L526">    segment.physicalAddress = std.math.maxInt(<span class="tok-type">u32</span>) - <span class="tok-number">1</span>;</span>
<span class="line" id="L527">    segment.fileSize = <span class="tok-number">1</span>;</span>
<span class="line" id="L528">    <span class="tok-kw">try</span> std.testing.expect(containsValidAddressRange(&amp;buf));</span>
<span class="line" id="L529">}</span>
<span class="line" id="L530"></span>
</code></pre></body>
</html>