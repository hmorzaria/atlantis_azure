#' Code to manage and run Atlantis simulations using parallel processing 

folder.paths <- here::here(c("atlantis_run_folder_1"))

folder.length <- 1:length(folder.paths)

#run multiple Atlantis simulations 

NumberOfCluster <- detectCores()  #- 1

# Initiate cluster
cl <- makeCluster(NumberOfCluster)
registerDoSNOW(cl)

# Run this for loop for one call of model from each cluster, assuming cluster is already initiated. 
atlantis.scenarios <- foreach(this.index=folder.length, .verbose = TRUE) %dopar% {

   this.folder <- folder.paths[this.index]

  #Get model files from blob storage
  system(paste0("azcopy copy ./",this.folder,"/outputFiles ", "\"https://thisstorageaccount.blob.core.windows.net/atlantis_run_folder_1?SAS keyXXXXXXXX\" --recursive"), wait = TRUE)

system(paste("cd ./", this.folder,";")) 
  
  # run Atlantis scenario
system("sudo chmod +x atlantisrunbash.sh; sudo sh ./atlantisrunbash.sh"), wait = TRUE)
  
  done <- as.data.frame("done")
#use Azcopy to transfer results to blob storage

 system(paste0("azcopy copy "./", this.folder, "/outputFiles" "https://thisstorageaccount.blob.core.windows.net/atlantis_results_folder?SAS keyXXXXXXXX"--recursive"), wait=TRUE)

}

stopCluster(cl)
