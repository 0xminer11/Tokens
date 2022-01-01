pragma solidity ^0.5.0;

contract ERC20{
string name;
string symbol;
uint decimal;
uint totalsupply;
mapping(address =>uint)public Balance;
mapping(address => mapping(address=>uint))allowed;

event transfer(
    address from,
    address to,
    uint tokens
);

event allow(
    address owner,
    address spender,
    uint token
);
event increasedallowance(
    address owner,
    address spender,
    uint increasetokens
);
event Decreaseallowance(
address owner,
address spender,
uint decreasetokens
);


constructor() public{ 
name="RapidInnovationCoin";
symbol="RIC";
decimal=2;
totalsupply=10000;
Balance[msg.sender]=totalsupply;
}

//Get Token name
function getName() public view returns(string memory){
    return(name);
}
// Get Token Symbol
function getSymbol() public view returns(string memory){
    return(symbol);
}

// Get Token Decimal
function getDecimal() public view returns(uint){
    return(decimal);
}

//get Total Supply
function getTotalSupply() public view returns(uint){
    return(totalsupply - Balance[msg.sender]);
}

//Get Balance of Accounts
function BalanceOf(address from) public view returns(uint){
    return(Balance[from]);
}

//Approve allowance for account
function approve(address spender,uint tokens) public returns(bool){
    require(Balance[msg.sender]>=tokens);
    allowed[msg.sender][spender]=tokens;
    emit allow(msg.sender,spender,tokens);
}
//Transfer tokens to other account
function Transfer(address to,uint tokens) public returns(bool){
    require(Balance[msg.sender]>=tokens);
    Balance[msg.sender] -= tokens;
    Balance[to] += tokens;
    emit transfer(msg.sender,to,tokens);
    return true;
}
//Transfer from one account to your account
function TransferFrom(address from,address to,uint tokens) public returns(bool){
    
    if(from == msg.sender){
    require(Balance[from]>=tokens);
    Balance[from] -= tokens;
    Balance[to] += tokens;
    emit transfer(msg.sender,to,tokens);
    return true;
    }else{
    require(allowed[from][msg.sender] >= tokens);
    allowed[from][msg.sender] -= tokens;
    Balance[from] -= tokens;
    Balance[to] += tokens;
    emit transfer(msg.sender,to,tokens);
    return true;
    }
}

//Get Allowance Tokens 
function Allowance(address owner,address spender)public view returns(uint){
    return allowed[owner][spender];
}

// Increase Allowance tokens
function IncreaseAllowance(address spender,uint tokens)public returns(bool){
    //require(allowed[msg.sender][spender]);
    require (Balance[msg.sender]>=tokens);
    allowed[msg.sender][spender] += tokens; 
    emit increasedallowance(msg.sender,spender,tokens);
    return true;
}

// Decrease Allowance tokens
function DecreasesAllowance(address spender,uint tokens)public returns(bool){
    require(Balance[spender]<=tokens);
    allowed[msg.sender][spender] -= tokens; 
    emit Decreaseallowance(msg.sender,spender,tokens);
}
}