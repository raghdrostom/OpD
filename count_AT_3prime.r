# Function to assess AT content in 6 3`-terminal nts in a sequence
# First edit: 11/11/17 Andre Zylstra
# Depends on stringr package. 'primer' argument should be a string

count_AT_3prime <- function(primer='') {
    
    # pick FINAL 6 nts
    primer_tail <- substr(primer, nchar(primer)-5, nchar(primer))
    
    # count and return sum of As and Ts
    return <- str_count(primer_tail, 'A') + str_count(primer_tail, 'T')

}