# Script to take a viral genome as input, generate appropriate
# Primer3 input files, and call Primer3.
# Imports the Primer3 output as two dataframes of left and right primers
# Exports separate lists of sequences for left/right primers
# Runs oligoscreen & adds information to the existing dataframes
#
# First edits: Andre Zylstra 19/09/17
# Edits to clean up the primer3 output file to make importing to dataframe easy: Andre Zylstra 28/10/17
# Edits to run oligoscreen, read in output: Andre Zylstra 31/10/17


# Library for reading fasta file
library(seqinr)


# read in user specified FASTA file
genome_path <- file.choose()
genome_seq <- read.fasta(file=genome_path, seqtype='DNA', as.string=T, forceDNAtolower=F)
genome_name <- attributes(genome_seq[[1]])$name


# generate Primer3 input file
primer3_input <- readLines("Primer3_input_template.txt", n=-1)

sequence_id <- substr(attributes(genome_seq[[1]])$Annot, start=2, stop=nchar(attributes(genome_seq[[1]])$Annot))
primer3_input[1] <- paste0('SEQUENCE_ID=', sequence_id)

primer3_input[2] <- paste0('SEQUENCE_TEMPLATE=', as.character(genome_seq))

primer3_input_filename <- paste0(genome_name, '_Primer3_input.txt')
write(primer3_input, primer3_input_filename)


# Construct system command and call Primer3
primer3_output <- paste0(genome_name, '_Primer3_output.txt')
primer3_command <- paste0('../primer3-2.3.7/src/primer3_core ', '-format_output ', '-strict_tags ', '-output=', primer3_output, ' ', primer3_input_filename)

system(primer3_command, wait=T)


# Read in primer3 output file, write 2 files (one for left and right primers) with JUST header line and data
messy_primer3_output <- readLines(primer3_output)

first_lprimer_line <- grep('LEFT_PRIMER', messy_primer3_output)[1]
last_lprimer_line <- tail(grep('LEFT_PRIMER', messy_primer3_output), n=1)

first_rprimer_line <- grep('RIGHT_PRIMER', messy_primer3_output)[1]
last_rprimer_line <- tail(grep('RIGHT_PRIMER', messy_primer3_output), n=1)

l_primer_file <- paste0(genome_name, '_Primer3_output_left.txt')
r_primer_file <- paste0(genome_name, '_Primer3_output_right.txt')

write(messy_primer3_output[(first_lprimer_line-1):last_lprimer_line], file=l_primer_file)
write(messy_primer3_output[(first_rprimer_line-1):last_rprimer_line], file=r_primer_file)

rm(messy_primer3_output, first_lprimer_line, first_rprimer_line, last_lprimer_line, last_rprimer_line) #Tidy up a bit


# Read in left and right primer sets as separate dataframes
l_primer_header <- read.table(file=l_primer_file, header=F, sep='', stringsAsFactors=F, nrow=1)
l_primers <- read.table(file=l_primer_file, header=F, sep='', stringsAsFactors=F, skip=1)
l_primers <- cbind(l_primers[,10], l_primers[,3:9], stringsAsFactors=F)
colnames(l_primers) <- c(l_primer_header[8], l_primer_header[1:7])

r_primer_header <- read.table(file=r_primer_file, header=F, sep='', stringsAsFactors=F, nrow=1)
r_primers <- read.table(file=r_primer_file, header=F, sep='', stringsAsFactors=F, skip=1)
r_primers <- cbind(r_primers[,10], r_primers[,3:9], stringsAsFactors=F)
colnames(r_primers) <- c(r_primer_header[8], r_primer_header[1:7])

# Create sequence list files for running RNAstructure program 'oligoscreen' to assess self-complementarity, hairpins etc.
l_primer_list <- NULL
r_primer_list <- NULL

for (i in 1:length(l_primers[,1])) {
   # l_primer_list <- append(l_primer_list, paste0('>', i, '_LEFT_PRIMER'))
  l_primer_list <- append(l_primer_list, l_primers$seq[i])
}

for (i in 1:length(r_primers[,1])) {
  # r_primer_list <- append(r_primer_list, paste0('>', i, '_RIGHT_PRIMER'))
  r_primer_list <- append(r_primer_list, r_primers$seq[i])
}

l_primer_listfile <- paste0(genome_name, '_left_primer_list.txt')
r_primer_listfile <- paste0(genome_name, '_right_primer_list.txt')

write(l_primer_list, l_primer_listfile)
write(r_primer_list, r_primer_listfile)

#############################################################################################################################

# Sorry, this is a messy hack which we'll need to find a good way round eventually.
# It's required to point oligoscreen to the correct thermodynamic parameters
# Just select any file in the .../RNAstructure/data_tables folder in the file select dialog and it SHOULD work ok
Sys.setenv(DATAPATH = dirname(file.choose()))

#############################################################################################################################

# Call oligoscreen
l_primer_oscreen_output <- paste0(genome_name, '_left_oligoscreen.txt')
l_primer_oscreen_cmd <- paste('../oligoscreen', l_primer_listfile, l_primer_oscreen_output, '--DNA -t 314.15', sep=' ')
system(l_primer_oscreen_cmd, wait=T)

r_primer_oscreen_output <- paste0(genome_name, '_right_oligoscreen.txt')
r_primer_oscreen_cmd <- paste('../oligoscreen', r_primer_listfile, r_primer_oscreen_output, '--DNA -t 314.15', sep=' ')
system(r_primer_oscreen_cmd, wait=T)

# import the oligoscreen results to existing dataframes
l_primers <- cbind(l_primers, read.table(l_primer_oscreen_output, header=T)[,2:6], stringsAsFactors=F)
r_primers <- cbind(r_primers, read.table(r_primer_oscreen_output, header=T)[,2:6], stringsAsFactors=F)