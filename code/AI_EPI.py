import multiprocessing
# input: adata
# output adata_sampled

def downsampling(df,group,n):
    def get_num(x):
        if(len(x)>n):
            sampled_x = x.sample(n,random_state = 2022).reset_index(drop=True)
        else:
            sampled_x = x
        return(sampled_x) 
    weighted_sample = df.groupby(group).apply(get_num)  
    return(weighted_sample) 

# input: adata
# output regional genes
def HighlyRegionalGenes(adata,gene_number):
    adata_obj = adata.copy()
    data = adata_obj.X
    connectivities = adata_obj.obsp['connectivities']
    #adata_obj.raw = adata_obj
    # 先过滤一部分表达量都为0的基因
    def score_cal(igene):
        x_scale = sc.pp.scale(data[:,igene], zero_center=True, max_value=10)
        score_igene = (x_scale.transpose() @ connectivities @ x_scale)[0][0]
        #print(score_igene)
        return(score_igene)

    cores = multiprocessing.cpu_count()
    pool = multiprocessing.Pool(processes=cores)

    score = pool.map(score_cal,range(len(adata_obj.var_names.values)))
    pool.close()
    pool.join()

    #score = [score_cal(igene) for igene in range(10)] 
    score = pd.Series(score,index = adata_obj.var_names.values)

    score = score.sort_values(ascending = False)
    gene_HRG = pd.DataFrame(score.index.values[range(gene_number)])
    return(gene_HRG)


