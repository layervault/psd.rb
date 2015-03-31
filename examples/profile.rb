require 'memory_profiler'
require 'psd'

file = ARGV[0] || 'examples/images/example.psd'

report = MemoryProfiler.report do
  psd = PSD.new(file)
  psd.parse!

  psd.tree.to_png
end

report.pretty_print
