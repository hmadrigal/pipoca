# Enables http2 analyzer
@load http2

# Enables http2 intel framework extensions
@load http2/intel

# Enables extraction of all files
@load frameworks/files/extract-all-files

# Use JSON for the log files
redef LogAscii::use_json=T

# Ignores checksum check
redef ignore_checksums=T

