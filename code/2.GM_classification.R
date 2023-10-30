GM_classification <- function(celltype_info,premutation_time = 500){
  ## niormalize the score 
  program_num = ncol(celltype_info)
  K = ncol(celltype_info)
  program_score = matrix(0,nrow = K,ncol = premutation_time+1)
  colnames(celltype_info) = paste0("score_GM",1:program_num)
  
  for(iGM in 1:K){
    score_temp = celltype_info[,paste0('score_GM',iGM)]
    celltype_info[,paste0('score_GM',iGM)] = (score_temp-min(score_temp))/(max(score_temp)-min(score_temp))
  }
  orig.ident = lapply(rownames(celltype_info),
                      FUN = function(i){
                        data_split = unlist(strsplit(i,split = "_"))
                        name = paste(data_split[1:(length(data_split)-1)],collapse = '_')
                        #name = do.call(data_split[paste,args = data_split[1:(length(data_split)-1)]])
                        return(name)
                      })
  orig.ident = unlist(orig.ident)
  celltype_info$orig.ident = orig.ident
  celltype_info = as.data.frame(celltype_info)
  celltype_info$barcode = rownames(celltype_info)
  for(isample_time in 1:(premutation_time+1)){
    if(isample_time==(premutation_time+1)){
      celltype_info$orig.ident_new = celltype_info$orig.ident
    }else{
      celltype_info$orig.ident_new = sample(celltype_info$orig.ident,length(celltype_info$orig.ident))
    }
    
    # 计算得分
    GM_index = c(1:program_num)
    sample_score = array(0,dim = c(length(unique(celltype_info$orig.ident_new)),ncol(celltype_info)-3),dimnames = list(unique(celltype_info$orig.ident_new),paste0("score_GM",GM_index)))
    for(iGM in paste0("score_GM",GM_index)){
      data_analysis = celltype_info[,c(iGM,"orig.ident_new")]
      colnames(data_analysis) = c("GM","orig.ident_new")
      data.table::score_summary = setDT(data_analysis)[,list(Mean=mean(GM), Max=max(GM), Min=min(GM), Median=as.numeric(median(GM)), Std=sd(GM)), by=orig.ident_new]
      score_summary = as.data.frame(score_summary)
      rownames(score_summary) = score_summary[,"orig.ident_new"]
      sample_score[rownames(score_summary),iGM] = score_summary[,"Mean"]
    }
    sample_score = as.data.frame(sample_score)
    #colnames(sample_score) = c("score_GM1_E2F","score_GM2_G2M","score_GM3_Metal","score_GM4_Glandular","score_GM5_cEMT","score_GM6_Interferon","score_GM7_Hypoxia","score_GM8_P53")
    sample_score$NewSample.ID = rownames(sample_score)
    
    # 先把得分归一化一下到0-1的范围，减去最小值，除以范围，再计算IQR
    myfun = function(i){
      i = (i-min(i))/(max(i)-min(i))
    }
    
    for(i in 1:program_num){
      sample_score[,i] = myfun(sample_score[,i])
    }
    
    program_score[,isample_time] = apply(sample_score[,1:program_num],MARGIN = 2,FUN = IQR)
    
  }
  rownames(program_score) = paste0("score_GM",c(1:K))
  program_score = as.data.frame(program_score)
  score_pvalue = c()
  for(iGM in 1:K){
    gene_module = paste0("score_GM",iGM)
    score_pvalue[iGM] = sum(program_score[gene_module,1:premutation_time]>program_score[gene_module,(premutation_time+1)])/premutation_time
  }
  names(score_pvalue) =  paste0("score_GM",1:K)
  score_pvalue = sort(score_pvalue)
  patient_shares = names(score_pvalue[score_pvalue<=0.05])
  patient_shares = gsub("score_GM","",patient_shares)
  patient_shares = as.numeric(patient_shares)
  write.csv(score_pvalue,paste0("pvalue_score_",program_num,".csv"))  
  write.csv(patient_shares,paste0("pvalue_patient_shared_state_",program_num,".csv")) 
}

