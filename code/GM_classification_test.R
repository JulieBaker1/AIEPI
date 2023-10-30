## debug the error in the code
setwd("D:/postgraduate/GBC/AIEPI/")
data = read.csv("./data/patient_GM_score_23GM_100genes.csv",row.names = 1)
gene_module_classification = GM_classification(data)
