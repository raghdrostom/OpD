"""
Laura 4th October 2017

The goal of this script is to read in the output from primer3, and create a fasta file of primer sequences that can be read into primer-lint.

"""


#path to the primer3 outputfile with primer list
primerfile = open('Primer3_Zika_output.txt')



L_headerlist = []
L_seqlist = []
R_headerlist = []
R_seqlist = []

#lines 0-8 are just information at the top of the primer3 output
# lines 9-5130 are LEFT_PRIMER
for line in primerfile.readlines()[9:]:
    if len(line.split()) > 8:
        if line.split()[1] == "LEFT_PRIMER":
            L_header = '>'+line.split()[0]+'_'+line.split()[1]
            L_headerlist.append(L_header)
            L_sequence = line.split()[9]
            L_seqlist.append(L_sequence)
        if line.split()[1] == "RIGHT_PRIMER":
            R_header = '>'+line.split()[0]+'_'+line.split()[1]
            R_headerlist.append(R_header)
            R_sequence = line.split()[9]
            R_seqlist.append(R_sequence)



#now write these headers and sequences to the open fastafile
#name the outputfile
fasta = open('Primer3_Zika_output_LEFT.fasta','w')

for i in range(len(L_seqlist)):
    fasta.write(L_headerlist[i] + "\n" +L_seqlist[i] + "\n")

fasta.close()



## Now I very terribly repeat these loops for the right primers 
# primerfile = open('Primer3_Zika_output.txt')

# for line in primerfile.readlines()[5133:9279]:
#     R_header = '>'+line.split()[0]+'_'+line.split()[1]
#     R_headerlist.append(R_header)
#     R_sequence = line.split()[9]
#     R_seqlist.append(R_sequence)

fasta = open('Primer3_Zika_output_RIGHT.fasta','w')

for i in range(len(R_seqlist)):
    fasta.write(R_headerlist[i] + "\n" +R_seqlist[i] + "\n")

fasta.close()

