function average(data) {
    var sum = data.reduce(function(sum, value){
      return sum + parseInt(value, 10);
    }, 0);
  
    var avg = sum / data.length;
    return avg;
  }
  
  var numBlocks = 2016;
  var currentBlock = eth.blockNumber;
  var existingBlocks = currentBlock + 1;
  var blocks = [];
  
  if (existingBlocks < numBlocks) {
    console.log("The chain is not yet " + numBlocks + " blocks long. Checking statistics for " + existingBlocks + " existing blocks instead.");
    numBlocks = existingBlocks;
  }
  
  for (i = 0; i < numBlocks; i++) {
      blocks.push(currentBlock - i);
  }
  
  var difficulties = [];
  for (i = 0; i < blocks.length; i++) {
      difficulties.push(eth.getBlock(blocks[i]).difficulty)
  }
  
  var difficultyAvg = average(difficulties);
  
  var squareDiffs = difficulties.map(function(value){
    var diff = parseInt(value, 10) - difficultyAvg;
    var sqr = diff * diff;
    return sqr;
  });
  
  var variance = average(squareDiffs)
  
  var stdDev = Math.sqrt(variance)
  
  console.log("Difficulty statistics for last " + numBlocks + " blocks:");
  console.log("Variance: " + variance);
  console.log("Standard Deviation: " + stdDev + "\n");