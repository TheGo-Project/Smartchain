var account = eth.accounts[0];
var password = "123456789"; 

personal.unlockAccount(account, password, 3600);

miner.setEtherbase(account);

miner.start();
