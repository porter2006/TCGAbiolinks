#' @title Query GDC data
#' @description
#'   Uses GDC API to search for search, it searches for both controlled and
#'   open-acess data.
#'   For GDC data arguments project, data.category, data.type and workflow.type should be used
#'   For the legacy data arguments project, data.category, platform and/or file.extension should be used.
#'   Please, see the vignette for a table with the possibilities.
#' @param project A valid project (see list with TCGAbiolinks:::getGDCprojects()$project_id)]
#' @param data.category A valid project (see list with TCGAbiolinks:::getProjectSummary(project))
#' @param data.type A data type to filter the files to download
#' @param sample.type A sample type to filter the files to download
#' @param barcode A list of barcodes to filter the files to download
#' @param legacy Search in the legacy repository
#' @param file.type To be used in the legacy database for some platforms,
#' to define which file types to be used.
#' @param workflow.type GDC workflow type
#' @param experimental.strategy Filter to experimental stratey. Harmonized: WXS, RNA-Seq, miRNA-Seq, Genotyping Array.
#' Legacy:  WXS, RNA-Seq, miRNA-Seq, Genotyping Array,
#' DNA-Seq, Methylation array, Protein expression array, WXS,CGH array, VALIDATION, Gene expression array,WGS,
#' MSI-Mono-Dinucleotide Assay, miRNA expression array, Mixed strategies, AMPLICON, Exon array,
#' Total RNA-Seq, Capillary sequencing, Bisulfite-Seq
#' @param access Filter by access type. Possible values: controlled, open
#' @param platform Example:
#' \tabular{ll}{
#'CGH- 1x1M_G4447A                   \tab IlluminaGA_RNASeqV2   \cr
#'AgilentG4502A_07                  \tab IlluminaGA_mRNA_DGE    \cr
#'Human1MDuo                        \tab HumanMethylation450    \cr
#'HG-CGH-415K_G4124A                \tab IlluminaGA_miRNASeq    \cr
#'HumanHap550                       \tab IlluminaHiSeq_miRNASeq \cr
#'ABI                               \tab H-miRNA_8x15K  \cr
#'HG-CGH-244A                       \tab SOLiD_DNASeq                \cr
#'IlluminaDNAMethylation_OMA003_CPI \tab IlluminaGA_DNASeq_automated   \cr
#'IlluminaDNAMethylation_OMA002_CPI \tab HG-U133_Plus_2                 \cr
#'HuEx- 1_0-st-v2 \tab Mixed_DNASeq                  \cr
#'H-miRNA_8x15Kv2 \tab IlluminaGA_DNASeq_curated      \cr
#'MDA_RPPA_Core   \tab IlluminaHiSeq_TotalRNASeqV2    \cr
#'HT_HG-U133A     \tab IlluminaHiSeq_DNASeq_automated \cr
#'diagnostic_images                 \tab microsat_i                     \cr
#'IlluminaHiSeq_RNASeq              \tab SOLiD_DNASeq_curated           \cr
#'IlluminaHiSeq_DNASeqC             \tab Mixed_DNASeq_curated           \cr
#'IlluminaGA_RNASeq                 \tab IlluminaGA_DNASeq_Cont_automated  \cr
#'IlluminaGA_DNASeq                 \tab IlluminaHiSeq_WGBS             \cr
#'pathology_reports                 \tab IlluminaHiSeq_DNASeq_Cont_automated\cr
#'Genome_Wide_SNP_6                 \tab bio                            \cr
#'tissue_images                     \tab Mixed_DNASeq_automated         \cr
#'HumanMethylation27                \tab Mixed_DNASeq_Cont_curated      \cr
#'IlluminaHiSeq_RNASeqV2            \tab Mixed_DNASeq_Cont
#'}
#' @export
#' @examples
#' query <- GDCquery(project = "TCGA-ACC",
#'                   data.category = "Copy Number Variation",
#'                   data.type = "Copy Number Segment")
#' query.met <- GDCquery(project = "TCGA-GBM",
#'                       legacy = TRUE,
#'                       data.category = "DNA methylation",
#'                       platform = "Illumina Human Methylation 450")
#' query <- GDCquery(project = "TARGET-AML",
#'                   data.category = "Transcriptome Profiling",
#'                   data.type = "miRNA Expression Quantification",
#'                   workflow.type = "BCGSC miRNA Profiling",
#'                   barcode = c("TARGET-20-PARUDL-03A-01R","TARGET-20-PASRRB-03A-01R"))
#' query <- GDCquery(project = "TCGA-ACC",
#'                   data.category =  "Copy Number Variation",
#'                   data.type = "Masked Copy Number Segment",
#'                   sample.type = c("Primary solid Tumor"))
#' query <- GDCquery(project = "TARGET-AML",
#'                   data.category = "Transcriptome Profiling",
#'                   data.type = "Gene Expression Quantification",
#'                   workflow.type = "HTSeq - Counts",
#'                   barcode = c("TARGET-20-PADZCG-04A-01R","TARGET-20-PARJCR-09A-01R"))
#' query <- GDCquery(project = "TCGA-ACC",
#'                   data.category =  "Copy number variation",
#'                   legacy = TRUE,
#'                   file.type = "hg19.seg",
#'                   barcode = c("TCGA-OR-A5LR-01A-11D-A29H-01"))
#' @return A data frame with the results and the parameters used
#' @importFrom  jsonlite fromJSON
GDCquery <- function(project,
                     data.category,
                     data.type,
                     workflow.type,
                     legacy = FALSE,
                     access,
                     platform,
                     file.type,
                     barcode,
                     experimental.strategy,
                     sample.type){

    # prepare output
    if(missing(sample.type)) {
        sample.type <- NA
    } else if(all(sample.type == FALSE)) {
        sample.type <- NA
    }
    if(missing(data.type)) {
        data.type <- NA
    } else if(data.type == FALSE) {
        data.type <- NA
    }
    if(missing(barcode)) {
        barcode <- NA
    } else if(length(barcode) == 1) {
        if(barcode == FALSE) barcode <- NA
    }
    if(missing(platform)) {
        platform <- NA
    } else if(platform == FALSE) {
        platform <- NA
    }
    if(missing(file.type)) {
        file.type <- NA
    } else if(file.type == FALSE) {
        file.type <- NA
    }
    if(missing(workflow.type)) {
        workflow.type <- NA
    } else if(workflow.type == FALSE) {
        workflow.type <- NA
    }
    if(missing(experimental.strategy)) {
        experimental.strategy <- NA
    } else if(experimental.strategy == FALSE) {
        experimental.strategy <- NA
    }
    if(missing(access)) {
        access <- NA
    } else if(access == FALSE) {
        access <- NA
    }


    # Check arguments
    checkProjectInput(project)
    checkDataCategoriesInput(project, data.category, legacy)

    if(!any(is.na(sample.type))) checkBarcodeDefinition(sample.type)

    if(!legacy & !is.na(platform)) message("Platform information is only available for legacy database. It will be ignored")

    # Get manifest using the API
    baseURL <- ifelse(legacy,"https://gdc-api.nci.nih.gov/legacy/files/?","https://gdc-api.nci.nih.gov/files/?")
    options.pretty <- "pretty=true"
    if(data.category == "Protein expression" & legacy) {
        options.expand <- "expand=cases.samples.portions,cases.project,center,analysis"
    } else if(data.category %in% c("Clinical","Biospecimen")) {
        options.expand <- "expand=cases,cases.project,center,analysis"
    } else {
        options.expand <- "expand=cases.samples.portions.analytes.aliquots,cases.project,center,analysis"
    }
    option.size <- paste0("size=",getNbFiles(project,data.category,legacy))
    option.format <- paste0("format=JSON")
    options.filter <- paste0("filters=",
                             URLencode('{"op":"and","content":[{"op":"in","content":{"field":"cases.project.project_id","value":["'),
                             project,
                             URLencode('"]}},{"op":"in","content":{"field":"files.data_category","value":["'),
                             URLencode(data.category),
                             URLencode('"]}}]}'))
    #message(paste0(baseURL,paste(options.pretty, options.expand, option.size, options.filter, sep = "&")))
    message("Accessing GDC. This might take a while...")
    url <- paste0(baseURL,paste(options.pretty, options.expand,option.size, options.filter, option.format, sep = "&"))
    json  <- tryCatch(
        fromJSON(url, simplifyDataFrame = TRUE),
        error = function(e) {
            fromJSON(content(GET(url), as = "text", encoding = "UTF-8"), simplifyDataFrame = TRUE)
        }
    )

    results <- json$data$hits

    # get barcode of the samples
    # TARGET-20-PANLLX-09A-01R
    #print(results$cases[[1]])
    if(data.category %in% c("Clinical","Biospecimen")) {
        pat <- paste("TCGA-[:alnum:]{2}-[:alnum:]{4}",
                     "TARGET-[:alnum:]{2}-[:alnum:]{6}",sep = "|")
    } else {
        pat <- paste("[:alnum:]{4}-[:alnum:]{2}-[:alnum:]{4}-[:alnum:]{3}-[:alnum:]{2,3}-[:alnum:]{4}-[:alnum:]{2}",
                     "[:alnum:]{6}-[:alnum:]{2}-[:alnum:]{6}-[:alnum:]{3}-[:alnum:]{3}",sep = "|")
    }
    barcodes <- na.omit(unlist(lapply(results$cases,function(x) str_extract(x,pat))))

    results$cases <- barcodes
    results$tissue.definition <- expandBarcodeInfo(barcodes)$tissue.definition

    if(legacy & !is.na(platform)){
        if(!(platform %in% results$platform)) {
            stop("Please set a valid platform argument from the list below:\n  => ", paste(unique(results$platform), collapse = "\n  => "))
        }
        results <- results[tolower(results$platform) %in% tolower(platform),]
    }

    # Filter by sample.type
    if(!any(is.na(sample.type))) results <- results[tolower(results$tissue.definition) %in% tolower(sample.type),]
    # Filter by barcode
    if(!any(is.na(barcode))) results <- results[substr(results$cases,1,str_length(barcode[1])) %in% barcode,]

    # Filter by access
    if(!is.na(access)) results <- results[grepl(access,results$access,ignore.case = TRUE),]

    # Filter by experimental strategy
    if(!is.na(experimental.strategy)) {
        if(all(tolower(experimental.strategy) %in%  tolower(results$experimental_strategy))) {
        results <- results[tolower(results$experimental_strategy) %in% tolower(experimental.strategy),]
        } else {
            message(paste0("The argument experimental_strategy does not match any of the results.\nPossible values:",
                           paste(unique(results$experimental_strategy),collapse = "\n=>")))
        }
    }

    # Filter by data.type
    if(!is.na(data.type)) {
        if(!(tolower(data.type) %in% tolower(results$data_type))) {
            stop("Please set a valid data.type argument from the list below:\n  => ", paste(unique(results$data_type), collapse = "\n  => "))
        }
        results <- results[tolower(results$data_type) %in% tolower(data.type),]
    }

    # Filter by data.type
    if(!is.na(workflow.type)) {
        if(!(workflow.type %in% results$analysis$workflow_type)) {
            stop("Please set a valid data.type argument from the list below:\n  => ", paste(unique(results$analysis$workflow_type), collapse = "\n  => "))
        }
        results <- results[results$analysis$workflow_type %in% workflow.type,]
    }
    # Filter by sample.type
    if(!is.na(file.type)){
        pat <- file.type
        if(file.type == "normalized_results") pat <- "normalized_results"
        if(file.type == "results") pat <- "[^normalized_]results"
        if(file.type == "nocnv_hg18" | file.type == "nocnv_hg18.seg") pat <- "nocnv_hg18"
        if(file.type == "cnv_hg18" | file.type == "hg18.seg") pat <- "[^nocnv_]hg18.seg"
        if(file.type == "nocnv_hg19" | file.type == "nocnv_hg19.seg") pat <- "nocnv_hg19"
        if(file.type == "cnv_hg19" | file.type == "hg19.seg") pat <- "[^nocnv_]hg19.seg"
        results <- results[grepl(pat,results$file_name),]
    }
    # some how there are duplicated files in GDC we should remove them
    # Example of problematic query
    # query.exp <- GDCquery(project = "TCGA-BRCA",
    #                  legacy = TRUE,
    #                  data.category = "Gene expression",
    #                  data.type = "Gene expression quantification",
    #                  platform = "Illumina HiSeq",
    #                  file.type = "results",
    #                  experimental_strategy = "RNA-Seq",
    #                  sample.type = c("Primary solid Tumor","Solid Tissue Normal"))
    #
    if(any(duplicated(results$cases))) {
        message("Warning: There are more than one file for the same case. Please verify query results.")
    }
    #results <- results[!duplicated(results$cases),]
    if(nrow(results) == 0) stop("Sorry, no results were found for this query")



    ret <- data.frame(results=I(list(results)), project = project,
                      data.category = data.category,
                      data.type = data.type,
                      legacy = legacy,
                      access = I(list(access)),
                      experimental.strategy =  I(list(experimental.strategy)),
                      file.type = file.type,
                      platform = I(list(platform)),
                      sample.type = I(list(sample.type)),
                      barcode = I(list(barcode)),
                      workflow.type = workflow.type)
    return(ret)
}

expandBarcodeInfo <- function(barcode){
    if(all(grepl("TARGET",barcode))) {
        ret <- DataFrame(barcode = barcode,
                         code = substr(barcode, 8, 9),
                         case.unique.id = substr(barcode, 11, 16),
                         tissue.code = substr(barcode, 18, 19),
                         nucleic.acid.code = substr(barcode, 24, 24))
        ret <- merge(ret,getBarcodeDefinition(), by = "tissue.code", sort = FALSE)
        ret <- ret[match(barcode,ret$barcode),]
    }
    if(all(grepl("TCGA",barcode))) {
        ret <- data.frame(barcode = barcode,
                          patient = substr(barcode, 1, 12),
                          sample = substr(barcode, 1, 16),
                          tissue.code = substr(barcode, 14, 15))
        ret <- merge(ret,getBarcodeDefinition(), by = "tissue.code", sort = FALSE)
        ret <- ret[match(barcode,ret$barcode),]
    }
    return(ret)
}


getBarcodeDefinition <- function(type = "TCGA"){
    if(type == "TCGA"){
        tissue.code <- c('01','02','03','04','05','06','07','08','09','10','11',
                         '12','13','14','20','40','50','60','61')
        shortLetterCode <- c("TP","TR","TB","TRBM","TAP","TM","TAM","THOC",
                             "TBM","NB","NT","NBC","NEBV","NBM","CELLC","TRB",
                             "CELL","XP","XCL")

        tissue.definition <- c("Primary solid Tumor",
                               "Recurrent Solid Tumor",
                               "Primary Blood Derived Cancer - Peripheral Blood",
                               "Recurrent Blood Derived Cancer - Bone Marrow",
                               "Additional - New Primary",
                               "Metastatic",
                               "Additional Metastatic",
                               "Human Tumor Original Cells",
                               "Primary Blood Derived Cancer - Bone Marrow",
                               "Blood Derived Normal",
                               "Solid Tissue Normal",
                               "Buccal Cell Normal",
                               "EBV Immortalized Normal",
                               "Bone Marrow Normal",
                               "Control Analyte",
                               "Recurrent Blood Derived Cancer - Peripheral Blood",
                               "Cell Lines",
                               "Primary Xenograft Tissue",
                               "Cell Line Derived Xenograft Tissue")
        aux <- data.frame(tissue.code = tissue.code,shortLetterCode,tissue.definition)
    } else {
        tissue.code <- c('01','02','03','04','05','06','07','08','09','10','11',
                         '12','13','14','15','16','17','20','40','41','42','50','60','61','99')

        tissue.definition <- c("Primary solid Tumor", # 01
                               "Recurrent Solid Tumor", # 02
                               "Primary Blood Derived Cancer - Peripheral Blood", # 03
                               "Recurrent Blood Derived Cancer - Bone Marrow", # 04
                               "Additional - New Primary", # 05
                               "Metastatic", # 06
                               "Additional Metastatic", # 07
                               "Tissue disease-specific post-adjuvant therapy", # 08
                               "Primary Blood Derived Cancer - Bone Marrow", # 09
                               "Blood Derived Normal", # 10
                               "Solid Tissue Normal",  # 11
                               "Buccal Cell Normal",   # 12
                               "EBV Immortalized Normal", # 13
                               "Bone Marrow Normal", # 14
                               "Fibroblasts from Bone Marrow Normal", # 15
                               "Mononuclear Cells from Bone Marrow Normal", # 16
                               "Lymphatic Tissue Normal (including centroblasts)", # 17
                               "Control Analyte", # 20
                               "Recurrent Blood Derived Cancer - Peripheral Blood", # 40
                               "Blood Derived Cancer- Bone Marrow, Post-treatment", # 41
                               "Blood Derived Cancer- Peripheral Blood, Post-treatment", # 42
                               "Cell line from patient tumor", # 50
                               "Xenograft from patient not grown as intermediate on plastic tissue culture dish", # 60
                               "Xenograft grown in mice from established cell lines", #61
                               "Granulocytes after a Ficoll separation") # 99
        aux <- DataFrame(tissue.code = tissue.code,tissue.definition)

    }
    return(aux)
}

#' @title Searches TCGA open-access data providing also latest version of the files.
#' @description
#'    This function has been replace by GDCquery
#' @param tumor Disease Examples:
#' \tabular{lllll}{
#'OV   \tab BRCA \tab CESC \tab ESCA \tab PCPG\cr
#'LUSC \tab LGG  \tab SKCM \tab KICH \tab CHOL\cr
#'GBM  \tab UCEC \tab PRAD \tab PAAD \tab THYM\cr
#'KIRC \tab THCA \tab SARC \tab LAML \tab TGCT\cr
#'COAD \tab KIRP \tab HNSC \tab ACC  \tab UVM \cr
#'READ \tab BLCA \tab DLBC \tab UCS  \tab FPPP\cr
#'LUAD \tab LIHC \tab STAD \tab MESO \tab CNTL
#'}
#' @param platform Example:
#' \tabular{ll}{
#'CGH- 1x1M_G4447A                   \tab IlluminaGA_RNASeqV2   \cr
#'AgilentG4502A_07                  \tab IlluminaGA_mRNA_DGE    \cr
#'Human1MDuo                        \tab HumanMethylation450    \cr
#'HG-CGH-415K_G4124A                \tab IlluminaGA_miRNASeq    \cr
#'HumanHap550                       \tab IlluminaHiSeq_miRNASeq \cr
#'ABI                               \tab H-miRNA_8x15K  \cr
#'HG-CGH-244A                       \tab SOLiD_DNASeq                \cr
#'IlluminaDNAMethylation_OMA003_CPI \tab IlluminaGA_DNASeq_automated   \cr
#'IlluminaDNAMethylation_OMA002_CPI \tab HG-U133_Plus_2                 \cr
#'HuEx- 1_0-st-v2 \tab Mixed_DNASeq                  \cr
#'H-miRNA_8x15Kv2 \tab IlluminaGA_DNASeq_curated      \cr
#'MDA_RPPA_Core   \tab IlluminaHiSeq_TotalRNASeqV2    \cr
#'HT_HG-U133A     \tab IlluminaHiSeq_DNASeq_automated \cr
#'diagnostic_images                 \tab microsat_i                     \cr
#'IlluminaHiSeq_RNASeq              \tab SOLiD_DNASeq_curated           \cr
#'IlluminaHiSeq_DNASeqC             \tab Mixed_DNASeq_curated           \cr
#'IlluminaGA_RNASeq                 \tab IlluminaGA_DNASeq_Cont_automated  \cr
#'IlluminaGA_DNASeq                 \tab IlluminaHiSeq_WGBS             \cr
#'pathology_reports                 \tab IlluminaHiSeq_DNASeq_Cont_automated\cr
#'Genome_Wide_SNP_6                 \tab bio                            \cr
#'tissue_images                     \tab Mixed_DNASeq_automated         \cr
#'HumanMethylation27                \tab Mixed_DNASeq_Cont_curated      \cr
#'IlluminaHiSeq_RNASeqV2            \tab Mixed_DNASeq_Cont
#'}
#' @param level '1' '2' '3'
#' @param center center name
#' @param samples List of samples. Ex:c('TCGA-04-06','TCGA-61-1743-01A-01D-0649-04')
#' @param version List of vector with tumor/plaform/version to get old samples,
#' @examples
#' \dontrun{
#' query <- TCGAquery(tumor = "gbm")
#' }
#' @export
#' @return A dataframe with the results of the query
#'        (lastest version of the files)
#' @family data functions
TCGAquery <- function(tumor = NULL,
                      platform = NULL,
                      samples = NULL,
                      center = NULL,
                      level = NULL,
                      version = NULL) {
    stop("TCGA data moved from DCC server to GDC server. \n Please use the function GDCquery")
}



#' @title Retrieve open access maf files from GDC server
#' @description
#'   GDCquery_Maf uses the following guide to download maf files
#'   https://gdc-docs.nci.nih.gov/Data/Release_Notes/Data_Release_Notes/
#' @param tumor a valid tumor
#' @param save.csv Write maf file into a csv document
#' @param directory Directory/Folder where the data will downloaded. Default: GDCdata
#' @export
#' @importFrom data.table fread
#' @import readr stringr
#' @importFrom downloader download
#' @importFrom R.utils gunzip
#' @importFrom tools md5sum
#' @examples
#' acc.maf <- GDCquery_Maf("ACC")
#' @return A data frame with the maf file information
GDCquery_Maf <- function(tumor, save.csv= FALSE, directory = "GDCdata"){
    root <- "https://gdc-api.nci.nih.gov/data/"
    maf <- fread("https://gdc-docs.nci.nih.gov/Data/Release_Notes/Manifests/GDC_open_MAFs_manifest.txt",
                 data.table = FALSE, verbose = FALSE, showProgress = FALSE)
    maf$tumor <- unlist(lapply(maf$filename, function(x){unlist(str_split(x,"\\."))[2]}))


    # Check input
    if (missing(tumor)) stop(paste0("Please, set tumor argument. Possible values:\n => ",
                                    paste(sort(maf$tumor),collapse = "\n => ")))

    if (!any(grepl(tumor,maf$tumor))) stop(paste0("Please, set a valid tumor argument. Possible values:\n => ",
                                                  paste(sort(maf$tumor),collapse = "\n => ")))

    #  Info to user
    message("============================================================================")
    message(" For more information about MAF data please read the following GDC manual:")
    message(" GDC manual: https://gdc-docs.nci.nih.gov/Data/PDF/Data_UG.pdf")
    message("============================================================================")

    query <- GDCquery(paste0("TCGA-",tumor), data.category = "Simple Nucleotide Variation", data.type = "Masked Somatic Mutation")
    GDCdownload(query, directory = directory, method = "api")

    file <- unique(file.path(directory,
                             query$project,
                             ifelse(query$legacy,"legacy","harmonized"),
                             gsub(" ","_", query$results[[1]]$data_category),
                             gsub(" ","_",query$results[[1]]$data_type),
                             query$results[[1]]$file_id,
                             query$results[[1]]$file_name))
    # Is there a better way??
    ret <- read_tsv(file,
                    comment = "#",
                    col_types = cols(
                        Entrez_Gene_Id = col_integer(),
                        Start_Position = col_integer(),
                        End_Position = col_integer(),
                        t_depth = col_integer(),
                        t_ref_count = col_integer(),
                        t_alt_count = col_integer(),
                        n_depth = col_integer(),
                        ALLELE_NUM = col_integer(),
                        TRANSCRIPT_STRAND = col_integer(),
                        PICK = col_integer(),
                        TSL = col_integer(),
                        HGVS_OFFSET = col_integer(),
                        MINIMISED = col_integer()))
    if(ncol(ret) == 1) ret <- read_csv(file,
                                       comment = "#",
                                       col_types = cols(
                                           Entrez_Gene_Id = col_integer(),
                                           Start_Position = col_integer(),
                                           End_Position = col_integer(),
                                           t_depth = col_integer(),
                                           t_ref_count = col_integer(),
                                           t_alt_count = col_integer(),
                                           n_depth = col_integer(),
                                           ALLELE_NUM = col_integer(),
                                           TRANSCRIPT_STRAND = col_integer(),
                                           PICK = col_integer(),
                                           TSL = col_integer(),
                                           HGVS_OFFSET = col_integer(),
                                           MINIMISED = col_integer()))

    if(save.csv) {
        fout <- paste0(query$project,"_maf.csv")
        write_csv(ret, fout)
        message(paste0("File created: ", fout))
    }
    return(ret)
}

#' @title Get last maf file for the tumor
#' @description
#'    This function has been replaced. Use GDCquery_maf
#' @param tumor tumor type to filter the search
#' @param center Center name to filter the search
#' @param archive.name Archive name to filter the search
#' @examples
#' \dontrun{
#'  query <- TCGAquery_maf(tumor = 'lgg')
#' }
#' @export
#' @return list of samples for a tumor
TCGAquery_maf <- function(tumor = NULL, center = NULL, archive.name = NULL){
    stop("TCGA data has moved from DCC server to GDC server. Please use GDCquery_Maf function")
}
