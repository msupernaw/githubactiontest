run_asap <- function(maindir=maindir, subdir="ASAP", om_sim_num=NULL){
  if(!("ASAPplots" %in% installed.packages()[,"Package"])) devtools::install_github("cmlegault/ASAPplots", build_vignettes = TRUE)
  library(ASAPplots)

  setwd(file.path(maindir, "output", subdir))
  unlink(list.files(file.path(maindir, "output", "ASAP"), full.names = TRUE), recursive = TRUE)

  sapply(1:om_sim_num, function(x) dir.create(file.path(maindir, "output", subdir, paste("s", x, sep=""))))

  asap_input <- ReadASAP3DatFile(file.path(maindir, "em_input", "asap3.DAT"))
  modify_input = "partial"

  invisible(lapply(1:om_sim_num, function(om_sim) {
    load(file=file.path(maindir, "output","OM", paste("OM", om_sim, ".RData", sep="")))
    if(modify_input == "all") {
      asap_input$dat$n_years <- par.sim1$nyr
      asap_input$dat$year1 <- sim1$yr[1]
      asap_input$dat$n_ages <- length(par.sim1$ages)
      asap_input$dat$n_fleets <- 1 #needs modification in om
      asap_input$dat$n_fleet_sel_blocks <- 1 #needs modification in om
      asap_input$dat$n_indices <- 1 #needs modification in om
      asap_input$dat$M <- matrix(rep(par.sim1$M.age, times=par.sim1$nyr), nrow=par.sim1$nyr, byrow = T)
      asap_input$dat$fec_opt <- 0 #needs modifcation in asap file
      asap_input$dat$fracyr_spawn <- 0 #needs modifcation in om/asap file (month-1)/12
      asap_input$dat$maturity <- matrix(rep(par.sim1$mat.age*par.sim1$proportion.female, times=par.sim1$nyr), nrow=par.sim1$nyr, byrow = T)
      asap_input$dat$n_WAA_mats <- 1 #needs modification in asap file
      asap_input$dat$WAA_mats[[1]] <- matrix(rep(par.sim1$W.kg, times=par.sim1$nyr), nrow=par.sim1$nyr, byrow = T) #needs modification in asap file (list index)
      asap_input$dat$WAA_pointers <- matrix(c(1,1,1,1,1,1), nrow=6, byrow = T) #needs modification in asap file
    } #incomplement
    if(modify_input == "partial") {
      asap_input$dat$CAA_mats[[1]] <- cbind(em_input$L.age.obs$fleet1, em_input$L.obs$fleet1)
      asap_input$dat$catch_cv <- cbind(rep(em_input$cv.L$fleet1, times=length(em_input$L.obs$fleet1)))
      for (survey_id in 1:om_input$survey_num){
        asap_input$dat$IAA_mats[[survey_id]] <- cbind(om_input$year, em_input$survey.obs[[survey_id]], rep(em_input$cv.survey[[survey_id]], times=length(em_input$survey.obs[[survey_id]])), em_input$survey.age.obs[[survey_id]], rep(em_input$n.survey[[survey_id]], times=length(em_input$survey.obs[[survey_id]])))
      }

      asap_input$dat$catch_Neff <- cbind(rep(em_input$n.L$fleet1, length(em_input$L.obs$fleet1)))
      asap_input$dat$F1_ini <- om_output$f[1]
      asap_input$dat$q_ini <- unlist(em_input$survey_q)*1000
      asap_input$dat$N1_ini <- om_input$N.pr0*1000
      asap_input$dat$recruit_cv <- cbind(rep(sqrt(exp(om_input$logR_sd^2)-1), om_input$nyr))
    }
    WriteASAP3DatFile(fname = file.path(maindir, "output", subdir, paste("s", om_sim, sep=""), "asap3.DAT"), dat.object=asap_input, header.text = "")
  }))

  # for (om_sim in 1:om_sim_num){
  #   load(file=file.path(maindir, "output","OM", paste("OM", om_sim, ".RData", sep="")))
  #   if(modify_input == "all") {
  #     asap_input$dat$n_years <- par.sim1$nyr
  #     asap_input$dat$year1 <- sim1$yr[1]
  #     asap_input$dat$n_ages <- length(par.sim1$ages)
  #     asap_input$dat$n_fleets <- 1 #needs modification in om
  #     asap_input$dat$n_fleet_sel_blocks <- 1 #needs modification in om
  #     asap_input$dat$n_indices <- 1 #needs modification in om
  #     asap_input$dat$M <- matrix(rep(par.sim1$M.age, times=par.sim1$nyr), nrow=par.sim1$nyr, byrow = T)
  #     asap_input$dat$fec_opt <- 0 #needs modifcation in asap file
  #     asap_input$dat$fracyr_spawn <- 0 #needs modifcation in om/asap file (month-1)/12
  #     asap_input$dat$maturity <- matrix(rep(par.sim1$mat.age*par.sim1$proportion.female, times=par.sim1$nyr), nrow=par.sim1$nyr, byrow = T)
  #     asap_input$dat$n_WAA_mats <- 1 #needs modification in asap file
  #     asap_input$dat$WAA_mats[[1]] <- matrix(rep(par.sim1$W.kg, times=par.sim1$nyr), nrow=par.sim1$nyr, byrow = T) #needs modification in asap file (list index)
  #     asap_input$dat$WAA_pointers <- matrix(c(1,1,1,1,1,1), nrow=6, byrow = T) #needs modification in asap file
  #   } #incomplement
  #   if(modify_input == "partial") {
  #     asap_input$dat$CAA_mats[[1]] <- cbind(em_input$L.age.obs$fleet1, em_input$L.obs$fleet1)
  #     asap_input$dat$catch_cv <- cbind(rep(em_input$cv.L$fleet1, times=length(em_input$L.obs$fleet1)))
  #     for (survey_id in 1:om_input$survey_num){
  #       asap_input$dat$IAA_mats[[survey_id]] <- cbind(om_input$yr, em_input$survey.obs[[survey_id]], rep(em_input$cv.survey[[survey_id]], times=length(em_input$survey.obs[[survey_id]])), em_input$survey.age.obs[[survey_id]], rep(em_input$n.survey[[survey_id]], times=length(em_input$survey.obs[[survey_id]])))
  #     }
  #
  #     asap_input$dat$catch_Neff <- cbind(rep(em_input$n.L$fleet1, length(em_input$L.obs$fleet1)))
  #     asap_input$dat$F1_ini <- om_output$f[1]
  #     asap_input$dat$q_ini <- unlist(em_input$survey_q)*1000
  #     asap_input$dat$N1_ini <- om_input$N.pr0*1000
  #     asap_input$dat$recruit_cv <- cbind(rep(sqrt(exp(om_input$logR_sd^2)-1), om_input$nyr))
  #   }
  #   WriteASAP3DatFile(fname = file.path(maindir, "output", subdir, paste("s", om_sim, sep=""), "asap3.DAT"), dat.object=asap_input, header.text = "")
  # }

  invisible(lapply(1:om_sim_num, function(om_sim) {
    # setwd(file.path(maindir, "output", subdir, paste("s", om_sim, sep="")))
    # system(paste(file.path(maindir, "em_input", "ASAP3.exe"), " asap3.DAT", sep = ""), show.output.on.console = FALSE)

    setwd(file.path(maindir, "output", subdir, paste("s", om_sim, sep="")))
    file.copy(file.path(maindir, "em_input", "ASAP3.exe"), file.path(maindir,"output", subdir, paste("s", om_sim, sep=""), "ASAP3.exe"), overwrite = T)
    system(paste(file.path(maindir, "output", subdir, paste("s", om_sim, sep=""), "ASAP3.exe"), file.path(maindir, "output", subdir, paste("s", om_sim, sep=""), "asap3.DAT"), sep = " "), show.output.on.console = FALSE)
    file.remove(file.path(maindir, "output", subdir, paste("s", om_sim, sep=""), "ASAP3.exe"))
  }))

  # for (om_sim in 1:om_sim_num){
  #   setwd(file.path(maindir, "output", subdir, paste("s", om_sim, sep="")))
  #   system(paste(file.path(maindir, "em_input", "ASAP3.exe"), " asap3.DAT", sep = ""), show.output.on.console = FALSE)
  # }
}
