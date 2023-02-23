# EEG-connectivity-multicenters-pipeline
A pipeline for large-scale assessments of dementia EEG connectivity across multicentric settings
The current pipeline is aimed at the harmonization of hd-EEG datasets and
dementia classification. This pipeline handles data from recording to machine learning
classification based on multi-metric measures of source space connectivity. A user interface is thoroughly detailed in: Sainz-Ballesteros AS, Perez J, Moguilner S, Ibanez A, Prado, P. A pipeline for large-scale assessments of dementia EEG connectivity across multicentric settings. In H Lemaître and R Whelan (Eds.) Methods for analyzing large neuroimaging datasets. Neuromethods series. NY: Springer Nature

## Which scripts to run
The pipeline depends on several scripts and functions which are called on the main script ("runMainPipeline.m"). As such, users are recommended to modify and run the runMainPipeline.m script, which in turn will reccur to the other scripts and functions of the pipeline, found and ordered in this repository in their corresponding sub-folders: Preprocessing, Normalization, Connectivity, Source Analysis and Classifier. As such, users must have the entire repository downloaded in their desktop.

Users must first necessarily have their data organized according to the BIDS-EEG structure for running the code.
