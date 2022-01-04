pragma solidity >=0.5.0;

interface IERC721{
    function safeMint(uint TokenId,string calldata TokenName,string calldata TokenSymbol,uint ethers)external payable returns(bool);
    function getTokenDetails(uint TokenId)external view returns(uint ,string memory,string memory,address,uint);
    function purchase(uint TokenId)external payable returns(bool);
    function BalanceOf(address owner) external view returns(uint);
    function Owner(uint id) external view returns(address);
    function approve(address to,uint TokenId)external returns(bool);
    function Transfer(address payable to,uint TokenId)external payable returns(bool);
    function SafeTransferFrom(address From,address payable To,uint TokenId)external returns(bool);
    function allowance (address owner, address spender) external view returns(uint);
    function setApprovalForAll(address operator,bool approved) external returns(bool);
    function isApprovedforAll(address owner,address operator) external view returns(bool);
    function TokenURI(uint TokenId) external view returns(string memory);
    function makePause(address spender,uint TokenId) external returns(bool);
    function makeUnPause(address spender,uint TokenId) external returns(bool);
}
contract ERC721 {

uint internal TokenCount; 

mapping(uint => address)private _owner;
mapping(uint => Tokens) public Token;
mapping(address => uint) private Balance;
mapping(uint => address) private TokenApprovals;
mapping(address =>mapping(address => uint))public Allowed;
mapping(address =>mapping(address =>bool)) internal AllowedAll;
mapping(address =>mapping(address => bool))public Pause;

struct Tokens{
    uint TokenId;
    string TokenName;
    string TokenSymbol;
    address payable owner;
    uint ethers;
} 

event Transferd(
    address From,
    address To,
    uint TokenId 
    );

event minted(
    uint TokenId,
    string TokenName,
    string TokenSymbol,
    address owner,
    uint ethers
    );

event Approved(
    address owner,
    address apender,
    uint TokenId
    );

event Paused(
    address owner,
    address spender,
    uint    TokenId,
    bool Paused
        
    );

event UnPaused(
    address owner,
    address spender,
    uint TokenId,
    bool Paused
    );

// event   


function safeMint(uint TokenId,string memory TokenName,string memory TokenSymbol,uint ethers)public payable returns(bool){
require(bytes(TokenName).length >0);
require(bytes(TokenSymbol).length>0);
//require(msg.value >0);
Token[TokenId]=Tokens(TokenId,TokenName,TokenSymbol,msg.sender,ethers);
_owner[TokenId]=msg.sender;
Balance[msg.sender] +=1;
emit minted(TokenId,TokenName,TokenSymbol,msg.sender,ethers);
}

function getTokenDetails(uint TokenId)public view returns(uint ,string memory,string memory,address,uint){
return(TokenId,Token[TokenId].TokenName,Token[TokenId].TokenSymbol,Token[TokenId].owner,Token[TokenId].ethers);
}


function purchase(uint TokenId)public payable returns(bool){
    require(msg.value >= Token[TokenId].ethers);
     Balance[Token[TokenId].owner] -= 1;
    Token[TokenId].owner.transfer(msg.value);
    Token[TokenId].owner = msg.sender;
    _owner[TokenId]=msg.sender;
    Balance[msg.sender] +=1;

}

function BalanceOf(address owner) public view returns(uint){
    return(Balance[owner]);
}

function Owner(uint id) public view returns(address){
    return(_owner[id]);
}

function approve(address to,uint TokenId)public returns(bool){
    require(msg.sender == _owner[TokenId]);
    Allowed[msg.sender][to]=TokenId;
    emit Approved(msg.sender,to,TokenId);
}

function Transfer(address payable to,uint TokenId)public payable returns(bool){
    require(msg.sender==Token[TokenId].owner);
    require(msg.value >=Token[TokenId].ethers);
    Token[TokenId].owner = to;
    _owner[TokenId]=to;
    Balance[msg.sender] -= 1;
    Balance[to] +=1;
    emit Transferd(msg.sender,to,TokenId);
}


function SafeTransferFrom(address From,address payable To,uint TokenId)public returns(bool) {
    require(Pause[From][msg.sender]!=true);
    require(TokenId == Allowed[From][msg.sender] || AllowedAll[From][msg.sender] == true);
    //require(From.value >Token[TokenId].ethers);
    Token[TokenId].owner =To;
    //From.purchase(TokenId);
    _owner[TokenId]=To;
    Balance[From] -= 1;
    Balance[To] +=1;
    Allowed[From][msg.sender]=0;
    emit Transferd(From,To,TokenId);

}
function allowance (address owner, address spender) public view returns(uint){
    return Allowed[owner][spender];
}

function setApprovalForAll(address operator,bool approved) public returns(bool){
require(Balance[msg.sender]>1);
AllowedAll[msg.sender][operator] =approved;
}


function isApprovedforAll(address owner,address operator) public view returns(bool){
    return(AllowedAll[owner][operator]);
}

function TokenURI(uint TokenId) public view returns(string memory){
    return string (abi.encodePacked(Token[TokenId].TokenName ,TokenId));
}

function makePause(address spender,uint TokenId) public returns(bool){
    require(Allowed[msg.sender][spender] == TokenId);
    Pause[msg.sender][spender]=true;
    emit Paused(msg.sender,spender,TokenId,true);
}

function makeUnPause(address spender,uint TokenId) public returns(bool){
    require(Allowed[msg.sender][spender] == TokenId);
    Pause[msg.sender][spender]=false;
    emit UnPaused(msg.sender,spender,TokenId,false);
}

}