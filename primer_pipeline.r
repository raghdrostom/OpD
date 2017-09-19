# Script to take a viral genome as input, generate appropriate
# Primer3 input files, and call Primer3.
#
# First edits: Andre Zylstra 19/09/17

# Library for reading fasta file
library(seqinr)

# read in user specified FASTA file
genome_path <- file.choose()
genome_string <- read.fasta(file=genome_path, seqtype='DNA', as.string=T, forceDNAtolower=F)

# generate Primer3 input file
primer3_input <- readLines("Primer3_input_template.txt", n=-1)

sequence_id <- substr(attributes(genome_string[[1]])$Annot, start=2, stop=nchar(attributes(genome_string[[1]])$Annot))
primer3_input[1] <- paste0('SEQUENCE_ID=', sequence_id)

primer3_input[2] <- paste0('SEQUENCE_TEMPLATE=', as.character(genome_string))

primer3_input_filename <- paste0(attributes(genome_string[[1]])$name, '_Primer3_input.txt')
writeLines(primer3_input, primer3_input_filename)

# Construct system command and call Primer3
primer3_output <- paste0(attributes(genome_string[[1]])$name, '_Primer3_output.txt')
primer3_command <- paste0('../primer3-2.3.7/src/primer3_core ', '-format_output ', '-strict_tags ', '-output=', primer3_output, ' ', primer3_input_filename)

system(primer3_command, wait=T)
