# Converting AI correspondence runs into a probabilities matrix

The goal of this section is to take the output from the AI modelling of correspondences and create a single file that can be read in and used to assign ISIC 3.1 codes to ISIC 4 codes based on the estimated probabilties. This is done in two steps: The first is reading through the 100 AI generated versions, cleaning it up and taking the averages. This is done in `Creating_a_single_prob_file.do`.

The second step is to rehape the data created by the previous code. The goal is to have one single row for every possible 4, 3, or 2 digit ISIC 4 combination, where the columns denote potential ISIC 3.1 codes and the probabilities attached to these. This is done in code `Reshape correspondence data.do`.
