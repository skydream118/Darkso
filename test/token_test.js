const DARKSO = artifacts.require("DARKSO");
const { assert } = require('chai');
const truffleAssert = require('truffle-assertions');
const time = require("./time");

contract("DARKSO", async accounts => {

	it("initial supply", async () => {
        // wait until devtoken is deplyoed, store the results inside devToken
        // the result is a client to the Smart contract api
        darkso = await DARKSO.deployed();
        // call our totalSUpply function
        let supply = await darkso.totalSupply();

        // Assert that the supply matches what we set in migration
        assert.equal(supply.toNumber(), 40*10**12, "Initial supply was not the same as in migration");

    });

	it("transfer token from openWallet to another", async() => {
    	darkso = await DARKSO.deployed();
        
		let devWallets = await darkso.get_devwallets();

		let initial_balance = await darkso.balanceOf(accounts[1]);

	    await darkso.transfer(accounts[1], 100, {from: devWallets[0]});

	    let after_balance = await darkso.balanceOf(accounts[1]);

	    assert.equal(after_balance - initial_balance, 100, "Token transfer Amount is not correct.");
    	
    });

    it("transfer token from lockwallet to another is disabled", async() => {
    	darkso = await DARKSO.deployed();

		let devWallets = await darkso.get_devwallets();
    	try{
	        await darkso.transfer(accounts[1], 100, {from: devWallets[1]});
    	}catch(e){
    		assert.ok(e);
    	}
    });
    it("start presale when presale available and buy token", async() => {
    	
		
    	darkso = await DARKSO.deployed();
    	
   		await darkso.startPresale(5*10**12, (new Date().getTime()/1000).toFixed(0), 2500,2000*10**6);
    	await darkso.setRate(3000);
    	
    	await darkso.Buy_Tokens({from : accounts[1],value: web3.utils.toWei('0.5','ether')});

    	console.log("Get Token Amount : " + darkso.balanceOf(accounts[1]));
    });

    it("presale for token with bigger than limit is failed", async() => {
    	darkso = await DARKSO.deployed();
    	//await darkso.startPresale(5*10**12,new Date().getTime(),2500,2000*10*6);
    	//await darkso.setRate(3000);

 		try {
    		await darkso.Buy_Tokens({from : accounts[1],value: web3.utils.toWei('1','ether')});

    	}catch(error){

            assert.ok(error);
            
        }
    	
    });


    it("start presale then new presale isnot available", async() => {
    	darkso = await DARKSO.deployed();
    	//await darkso.startPresale(5*10**12, (new Date().getTime()/1000).toFixed(0), 2500,2000*10**6);
    	//await darkso.setRate(3000);

    	//await increase(time.duration.days(1));
 		
 		try {
    		await darkso.Buy_Tokens({from : accounts[1],value: web3.utils.toWei('0.5','ether')});
    	}catch(error){
            assert.ok(error);
        }

    });


    it("withdraw lockwallet token to the openwallet", async() => {
    	darkso = await DARKSO.deployed();
    	let blocktime = await darkso.getblocktime();
//    	await increase(time.duration.days(32));
		
		let aftertime = blocktime.toNumber() + time.duration.days(31);

    	let devWallets = await darkso.get_devwallets();
     	let balancebefore = await darkso.balanceOf(devWallets[0]);
    	console.log("before openwallet amount : " + balancebefore);
    	
    	await darkso.withdrawToken_test(aftertime);
    	
    	let balanceafter = await darkso.balanceOf(devWallets[0]);
    	console.log("after openwallet amount : " + balanceafter);
    });    
});