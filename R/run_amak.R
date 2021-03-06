run_amak <- function(maindir=maindir, subdir="AMAK", om_sim_num=NULL){
  setwd(file.path(maindir, "output", subdir))
  unlink(list.files(file.path(maindir, "output", "AMAK"), full.names = TRUE), recursive = TRUE)
  sapply(1:om_sim_num, function(x) dir.create(file.path(maindir, "output", subdir, paste("s", x, sep=""))))

  ctlf <- file.path(maindir, "em_input", "amak.dat")
  datf <- file.path(maindir, "em_input", "amak_data.dat")

  modify_input = "partial"
  for (om_sim in 1:om_sim_num){
    load(file=file.path(maindir, "output", "OM", paste("OM", om_sim, ".RData", sep="")))

    if(modify_input == "all") {

    }

    if(modify_input == "partial") {
      char.lines <- readLines(ctlf)
      char.lines[grep("#SigmaR", char.lines)+1] <- gsub(gsub(" .*$", "", char.lines[grep("#SigmaR", char.lines)+1]), om_input$logR_sd, char.lines[grep("#SigmaR", char.lines)+1]) #Replace the value before 1st space
      #char.lines[grep("#catchability", char.lines)+1] <- gsub(gsub(" .*$", "", char.lines[grep("#catchability", char.lines)+1]), em_input$survey_q$survey1, char.lines[grep("#catchability", char.lines)+1])
      writeLines(char.lines, con=file.path(maindir, "output", subdir, paste("s", om_sim, sep=""), "amak.dat"))

      char.lines <- readLines(datf)
      char.lines[grep("#catch\t", char.lines)+1] <- as.character(paste(em_input$L.obs$fleet1, collapse="\t"))
      char.lines[grep("#catch_cv", char.lines)+1] <- as.character(paste(rep(em_input$cv.L$fleet1, length(em_input$L.obs$fleet1)), collapse="\t"))
      char.lines[grep("#sample_ages_fsh", char.lines)+1] <- as.character(paste(rep(em_input$n.L$fleet1, length(em_input$L.obs$fleet1)), collapse="\t"))
      for (i in 1:nrow(em_input$L.age.obs$fleet1)){
        char.lines[grep("#page_fsh", char.lines)+i]<-as.character(paste(em_input$L.age.obs$fleet1[i,],collapse="\t"))
      }

      for (survey_id in 1:om_input$survey_num){
        temp <- em_input$survey.obs[[survey_id]]
        char.lines[grep("#biom_ind", char.lines)+survey_id]<-as.character(paste(temp, collapse="\t"))

        temp <- em_input$cv.survey[[survey_id]]*em_input$survey.obs[[survey_id]]
        char.lines[grep("#biom_cv", char.lines)+survey_id]<-as.character(paste(temp, collapse="\t"))
        #char.lines[grep("#biom_cv", char.lines)+1] <- as.character(paste(em_input$cv.survey$survey1*em_input$survey.obs$survey1/em_input$survey.obs$survey1, collapse="\t"))

        char.lines[grep("#sample_ages_ind", char.lines)+survey_id] <- as.character(paste(rep(em_input$n.survey[[survey_id]], length(em_input$survey.obs[[survey_id]])), collapse="\t"))
      }

      temp <- do.call(rbind, em_input$survey.age.obs)
      for (i in 1:nrow(temp)){
        char.lines[grep("#page_ind", char.lines)+i]<-as.character(paste(temp[i,],collapse="\t"))
      }

      writeLines(char.lines, con=file.path(maindir, "output", subdir, paste("s", om_sim, sep=""),  "amak_data.dat"))
    }
  }

  for (om_sim in 1:om_sim_num){
    # setwd(file.path(maindir, "output", subdir, paste("s", om_sim, sep="")))
    # system(paste(file.path(maindir, "em_input", "amak.exe"), " amak.dat", sep = ""), show.output.on.console = FALSE)
    #
    setwd(file.path(maindir, "output", subdir, paste("s", om_sim, sep="")))
    file.copy(file.path(maindir, "em_input", "amak.exe"), file.path(maindir,"output", subdir, paste("s", om_sim, sep=""), "amak.exe"), overwrite = T)
    system(paste(file.path(maindir, "output", subdir, paste("s", om_sim, sep=""), "amak.exe"), file.path(maindir, "output", subdir, paste("s", om_sim, sep=""), "amak.dat"), sep = " "), show.output.on.console = FALSE)
    file.remove(file.path(maindir, "output", subdir, paste("s", om_sim, sep=""), "amak.exe"))
  }
}


