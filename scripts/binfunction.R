# Bin size is 4 minutes
# Total bins is enough bins to fit up to 29649 (the max) seconds of data

fillBins <- function (x,
                      BINSIZE=(4 * 60),
                      TOTALBINS=(30000 / BINSIZE) - 1)
{
  x_bins <- matrix(data=0, nrow = length(x$data), ncol=TOTALBINS);
  for (i in 1:length(x$data)) {
    BINNUMBER <- 1;
    AMOUNT_IN_CURRENT_BIN <- 0; # Number of readings in current bin
    for (j in 1:length(x$data[[i]])) {
      # Extract next data point tmp=(TIME, VALUE)
      tmp <- unlist(x$data[[i]][j]);
      
      currTime <- tmp[1]; # The time stamp of the current data point
      
      # If the time stamp is not in the current bin, shift to next bin
      if (currTime > (BINNUMBER * BINSIZE) && AMOUNT_IN_CURRENT_BIN > 0)
      {
        # Divide to average.
        x_bins[i,BINNUMBER] <- x_bins[i,BINNUMBER] / AMOUNT_IN_CURRENT_BIN;
        AMOUNT_IN_CURRENT_BIN <- 0;
        BINNUMBER <- BINNUMBER +1;
      }
      
      # Shift over to next  time interval that fits in a bin
      while (currTime > BINNUMBER * BINSIZE)
      {
        # Fill the bin with previous bin value
        x_bins[i,BINNUMBER] <- x_bins[i,BINNUMBER-1];
        BINNUMBER <- BINNUMBER + 1;
      }
      
      # Add the value to the bin
      x_bins[i,BINNUMBER] <- x_bins[i,BINNUMBER] + tmp[2];
      AMOUNT_IN_CURRENT_BIN <- AMOUNT_IN_CURRENT_BIN + 1;
    }
    # Off-by-one fix, the last value will never divide, so include here.
    x_bins[i,BINNUMBER] <- x_bins[i,BINNUMBER] / AMOUNT_IN_CURRENT_BIN;
  }
  return (x_bins);
}
