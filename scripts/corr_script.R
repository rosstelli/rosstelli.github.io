

getCorr <- function (x)
{
  len <- length(x[,1]);
  x_p <- matrix(data=0, nrow = len, ncol=len);
  x_r <- matrix(data=1, nrow = len, ncol=len);
  for (i in 1:(len-1)) {
    for (j in (i+1):len){
      tmp<-rcorr(x[i,], x[j,], type="spearman");
      x_p[i,j] <- tmp$P[1,2];
      x_p[j,i] <- tmp$P[1,2];
      x_r[i,j] <- tmp$r[1,2];
      x_r[j,i] <- tmp$r[1,2];
    }
  }
  return (list(x_p, x_r));
}


outputGraphJSON <- function (x,
                        filename="output.json",
                        threshold=0.8,          # Threshold for connections
                        # If it is greater than this threshold, then the two
                        # nodes are connected
                        
                        NoUnconnectedNodes=FALSE, # DO NOT SET TO TRUE.
                        
                        data=NULL #optional to include the data in the json file
                        )
{
  # Create a matrix of links where TRUE connects two if they are highly correlated
  x_links <- matrix(data=unlist(x[2]), nrow=sqrt(length(unlist(x[2])))) > threshold;
  x_links[is.na(x_links)] <- FALSE;
  
  len <- length(x_links[,1]);
  first <- TRUE;
  output <- "{\n \"nodes\":[";
  for (i in 1:len) {
    if (length(x_links[i,x_links[i,] == TRUE]) < 1 && NoUnconnectedNodes) {
      # Do Nothing
    } else if (first) {
      tmp <- gsub(" ", "", paste("{\"name\":\"Node",toString(i),"\""));
      output <- paste(output, "\n ", tmp);
      first<-FALSE;
      if (!is.null(data)) {
        output <- paste(output, ", \"data\":[", toString(data[i,]), "]");
      }
      output <- paste (output, "}");
    } else {
      tmp <- gsub(" ", "", paste("{\"name\":\"Node",toString(i),"\""));
      output <- paste(output, ",\n ", tmp);
      if (!is.null(data)) {
        output <- paste(output, ", \"data\":[", toString(data[i,]), "]");
      }
      output <- paste (output, "}");
    }
  }
  output <- paste (output, "\n ],\n \"links\":[\n");
  #print(output);
  first <- TRUE;
  for (i in 1:(len-1)) {
    for (j in (i+1):len) {
      if (x_links[i,j] && first) {
        output <- paste(output, " {\"source\":",(i-1),", \"target\":", (j-1), "}");
        first <- FALSE;
      } else if (x_links[i,j]) {
        output <- paste(output, ",\n  {\"source\":",(i-1),", \"target\":", (j-1), "}");
      }
    }
  }
  
  output <- paste(output, "\n ]\n}");
  write(output, file=filename);
}

outputEdgesJSON <- function (x,
                             filename="output.json",
                             threshold=0.8,          # Threshold for connections
                             # If it is greater than this threshold, then the two
                             # nodes are connected
                             
                             NoUnconnectedNodes=FALSE, # Removes nodes not connected
                             # to any other nodes if TRUE.
                             
                             name=NULL #optional to include the data in the json file
)
{
  # Create a matrix of links where TRUE connects two if they are highly correlated
  x_links <- matrix(data=unlist(x[2]), nrow=sqrt(length(unlist(x[2])))) > threshold;
  x_links[is.na(x_links)] <- FALSE;
  len <- length(x_links[,1]);
  
  first <- TRUE;
  output <- "[";
  for (i in 1:len) {
    if (length(x_links[i,x_links[i,] == TRUE]) <= 1 && NoUnconnectedNodes) {}
    else if (first) {
      output <- paste(output, "\n  {\"name\":\"", name[i], "\",\"imports\":[", sep="");
      list <- gsub(", ", "\", \"", toString(name[ x_links[i,] ]));
      list <-  paste("\"", list, "\"", sep="");
      output <- paste(output, list, "]}", sep="");
      first <- FALSE;
    } else {
      output <- paste(output, ",\n  {\"name\":\"", name[i], "\",\"imports\":[", sep="");
      list <- gsub(", ", "\", \"", toString(name[ x_links[i,] ]));
      list <-  paste("\"", list, "\"", sep="");
      output <- paste(output, list, "]}", sep="");
    }
      
    
  }
  
  
  output <- paste(output, "\n]", sep="");
  write(output, file=filename);
}

