# Function to take 2 primer coordinates (e.g. from primer3 hits) and return an amplicon including primer sequences
# First edit: 28/10/17 Andre Zylstra
# l and r_primer_coords should be numeric, genome should be a viral genome read as a SeqFastadna object (seqinr package)

get_amplicon <- function(l_primer_coord=0, r_primer_coord=0, genome='') {
  
  # Note we have to add 1 to the l_primer_coord as the primer3 output is 0 indexed
  l_start <- l_primer_coord +1
  
  # r_primer_coord is the index of the 5` base (in 0 index) so have to adjust for length
  r_end <- r_primer_coord +1
  
  amplicon <- substr(genome[[1]][1], l_start, r_end)

  return <- amplicon
  
}
