# AIEPI
Atlas-level Integrated Epithelial Program Identification

Malignant epithelial cells are the most heterogeneous cell type with almost every patient forming a separate cluster. Here, we present a method, AI-EPI (Atlas-level Integrated Epithelial Program Identification), which identify patient-shared and patient-specific gene modules (GM) simultaneously and efficiently.The
method mainly contains two steps:

-   gene module identification
-   gene module classification

![workflow.png](inst/workflow.png)

Installation
------------

the package can be installed directly from the github.

```
git clone Juliebaker1/AIEPI
cd AIEPI
pip install requirement.txt
```

Quick start
-----------

Here, we provide an example data of [GBC_epithelial](http://lifeome.net/software/hrg/GBC_epithelial.h5ad) 
from 10X Genomics. Users can download it and run following scripts to understand the workflow of AIEPI.

Step1:gene program identification
------------------

For malignant epithelial cell number vary among patients, we sample the same cell number from every patient so that they are equally weighted.

```
epithelial_downsample_adata = sampling(epithelial_adata)

```

AI-EPI identifies gene modules by consensus non-negative matrix factorization (cNMF). You can select a appropriate pragram number by the curve of stability and error at each choice of K.
```
gene_program = GM_identification(epithelial_downsample_adata) (# output the default error and stability curve)
cnmf_obj.k_selection_plot(close_fig=False)
```

![Epithelial.k_selection.png](inst/Epithelial.k_selection.png)


Step2:gene program classification
-------------

In the second step, we distinguish the patient-shared GM from the patient-specific GM by a permutation test p-value.  

```
GM_classification_result = GM_classification(epithelial_downsample_adata)
```

![IQR.png](inst/IQR.png)

Downstream analysis
-------------------------------------------------
The patient-shared gene module can be used to cluster malignant epithelial cells. Besides, you can define the state of each cell by the GM with highest GM score.

```
epithelial_adata = cell_state_identification(epithelial_adata)
```

![clustering.png](inst/clustering.png =100X100)

