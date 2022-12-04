#' Enrichment function
#'
#' Perform enrichment Analysis of RNA-Seq Data
#'
#' @param dfList Dataframes list
#' @param enrich.databases Vector of EnrichR databases to consult 
#' @param p_adj Double. Adjusted pvalue threshold for the enrichment
#' @param avglogFC Double. Fold change threshold for the enrichment
#' @return A list of enrichment tables for un and downregulated genes in the different enrichrdatabases
#' @examples
#' df1 <- data.frame (Geneid  = c("Mest", "Cdk1", "Pclaf", "Birc5"),
#'                   baseMean = c("13490.22", "10490.21", "8888.33", "750.33"),
#'                    log2FoldChange = c("5.78", "6.78", "7.78", "8.78"), 
#'                    padj = c("2.28-143", "2.18-115", "2.18-45", "0.006"))
#'  df2 <- data.frame (Geneid  = c("Mest", "Cdk1", "Pclaf", "Birc5"),
#'                    baseMean = c("13490.22", "10490.21", "8888.33", "750.33"),
#'                    log2FoldChange = c("5.78", "6.78", "7.78", "8.78"),
#'                    padj = c("2.28-143", "2.18-115", "2.18-45", "0.006"))
#' dfList = list(df1, df2)
#' names(dfList)<-c("df1", "df2")
#' test = Enrichment(dfList)
#' @section Warning:
#' Bla bla bla
#' @family aggregate functions
#' @seealso \code{\link{hello}} for counts data and metadata download, and \code{\link{hello}} for Gene2SProtein analysis
#' @export


Enrichment <- function(dfList ,enrich.databases  = c("GO_Biological_Process_2021",
                                          "GO_Cellular_Component_2021",
                                          "GO_Molecular_Function_2021",
                                          "KEGG_2021_Human",
                                          "MSigDB_Hallmark_2020",
                                          "WikiPathways_2016",
                                          "BioCarta_2016",
                                          "Jensen_TISSUES",
                                          "Jensen_COMPARTMENTS",
                                          "Jensen_DISEASES"), p_adj = 0.05, logFC = 1) {
  
  import::here(enrichR)
  import::here(openxlsx)
  
  dir.create('enrichR/', showWarnings=FALSE, recursive=TRUE)
  enrichr.list <- list()
  # -------------------------
  # enrichment Parameters
  # -------------------------

  for (i in names(dfList)) {
      df_obj <- dfList[[i]]
      signif <- (df_obj[df_obj$padj <= p_adj, ])
  number_of_sig_genes  <- nrow(signif)
  #print(head(signif))
  cat(i, number_of_sig_genes, "significant genes\n")
  neg <- nrow(signif[signif$log2FoldChange < logFC, ])
  
  neg_list <-  rownames(signif[signif$log2FoldChange < logFC, ])
  
  write.table(neg_list, paste('./enrichR/FDRdown_',i,
                              '.txt', sep =''), quote = F, 
              row.names = F, col.names = F)
  
  pos  <- nrow(signif[signif$log2FoldChange > logFC, ])
  pos_list  <- rownames(signif[signif$log2FoldChange > logFC, ])
  write.table(pos_list, paste('./enrichR/FDRup_',i,
                              '.txt', sep =''), quote = F, 
              row.names = F, col.names = F)
  
  cat(i, pos, "positive fold change\n")
  print(pos_list)
  cat(i, neg, "negative fold change\n")
  print(neg_list)
  
  #enrichr.list <- list()
  enrichr.list[[i]] <- lapply(list(pos_list,neg_list),function(x) {
    enrichR::enrichr(genes = x, databases = enrich.databases)
    
  })
  names(enrichr.list[[i]]) <-  c("fdr_up","fdr_down")
  print(enrichr.list[[i]])
  
  
  }

  for (i in names(dfList)) {
     for (j in c("fdr_up","fdr_down")){
       filename = paste("./enrichR/",i,j,".xlsx", sep="")
    
       write.xlsx(x = enrichr.list[[i]][[j]], file = filename)}}

  return(enrichr.list)  }
