# Function to assess GC content in 6 5`-terminal nts in a sequence
# First edit: 11/11/17 Andre Zylstra
# Depends on stringr package. 'primer' argument should be a string

count_GC_5prime <- function(primer='') {
    
    # pick FIRST 6 nts
    primer_head <- substr(primer, 1, 6)
    
    # count and return sum of Gs and Cs
    return <- str_count(primer_head, 'G') + str_count(primer_head, 'G')
    
}