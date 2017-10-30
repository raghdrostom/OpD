# Script to take a viral genome as input, generate appropriate
# Primer3 input files, and call Primer3.
# Imports the Primer3 output as two dataframes of left and right primers
#
# First edits: Andre Zylstra 19/09/17
# Edits to clean up the primer3 output file to make importing to dataframe easy: Andre Zylstra 28/10/17


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


# Read in primer3 output file, write 2 files (one for left and right primers) with JUST header line and data
messy_pr3_output <- readLines(primer3_output)

first_lprimer_line <- grep('LEFT_PRIMER', messy_pr3_output)[1]
last_lprimer_line <- tail(grep('LEFT_PRIMER', messy_pr3_output), n=1)

first_rprimer_line <- grep('RIGHT_PRIMER', messy_pr3_output)[1]
last_rprimer_line <- tail(grep('RIGHT_PRIMER', messy_pr3_output), n=1)

l_primer_file <- paste0(attributes(genome_string[[1]])$name, '_Primer3_output_left.txt')
r_primer_file <- paste0(attributes(genome_string[[1]])$name, '_Primer3_output_right.txt')

write(messy_pr3_output[(first_lprimer_line-1):last_lprimer_line], file=l_primer_file)
write(messy_pr3_output[(first_rprimer_line-1):last_rprimer_line], file=r_primer_file)

rm(messy_pr3_output, first_lprimer_line, first_rprimer_line, last_lprimer_line, last_rprimer_line) #Tidy up a bit


# Read in left and right primer sets as separate dataframes
l_primer_names <- read.table(file=l_primer_file, header=F, sep='', stringsAsFactors=F, nrow=1)
l_primers <- read.table(file=l_primer_file, header=F, sep='', stringsAsFactors=F, skip=1)
l_primers <- l_primers[,3:length(l_primers[1,])]
colnames(l_primers) <- l_primer_names

r_primer_names <- read.table(file=r_primer_file, header=F, sep='', stringsAsFactors=F, nrow=1)
r_primers <- read.table(file=r_primer_file, header=F, sep='', stringsAsFactors=F, skip=1)
r_primers <- r_primers[,3:length(r_primers[1,])]
colnames(r_primers) <- r_primer_names
