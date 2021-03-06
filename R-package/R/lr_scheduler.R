
#' @export
FactorScheduler <- function(step, factor_val, stop_factor_lr=1e-8, verbose=TRUE) {
  if(step < 1) stop("Schedule step must be greater or equal than 1 round")
  if(factor_val > 1) stop("Factor must be no more than 1 to make lr reduce")
  function(optimizerEnv){
    num_update <- optimizerEnv$num_update
    count      <- optimizerEnv$count
    lr         <- optimizerEnv$lr
    if (num_update > count + step){
      count <- count + step
      lr    <- lr * factor_val
      if(lr < stop_factor_lr){
        lr <- stop_factor_lr
        if(verbose) cat(paste0("Update[", num_update, 
                               "]: now learning rate arrived at ", lr, 
                               "will not change in the future\n"))
      } else{
        if(verbose) cat(paste0("Update[", num_update, 
                               "]: learning rate is changed to ", lr, "\n"))
      }
      optimizerEnv$lr    <- lr
      optimizerEnv$count <- count      
      
    }
  }
}

#' @export
MultiFactorScheduler <- function(step, factor_val, stop_factor_lr=1e-8, verbose=TRUE) {
  if(!all(step == cummax(step))) stop("Schedule step must be an increasing integer list")
  if(any(step < 1))  stop("Schedule step must be greater or equal than 1 round")
  if(factor_val > 1) stop("Factor must be no more than 1 to make lr reduce")
  function(optimizerEnv){
    if(is.null(optimizerEnv$cur_step_ind)){
      cur_step_ind <- 1
    } else{
      cur_step_ind <- optimizerEnv$cur_step_ind
    }
    num_update <- optimizerEnv$num_update
    lr         <- optimizerEnv$lr
    count      <- optimizerEnv$count
    if(cur_step_ind < length(step)){
      if(num_update > step[cur_step_ind]){
        count <- step[cur_step_ind]
        cur_step_ind <- cur_step_ind + 1
        lr <-  lr * factor_val
        if(lr < stop_factor_lr){
          lr <- stop_factor_lr
          if(verbose) cat(paste0("Update[", num_update, 
                                 "]: now learning rate arrived at ", lr, 
                                 "will not change in the future\n"))
        } else{
          if(verbose) cat(paste0("Update[", num_update, 
                                 "]: learning rate is changed to ", lr, "\n"))
          
        }
        optimizerEnv$lr           <- lr
        optimizerEnv$count        <- count  
        optimizerEnv$cur_step_ind <- cur_step_ind
      }
    }
  }
}
