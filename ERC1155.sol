pragma solidity ^0.5.0;


interface IERC1155{

function safeMint(uint TokenId, string calldata TokenName,string calldata TokenSymbol,uint Balance)external returns(bool);
function setApprovedForAll(address operator,bool Approved)external;
function BalanceOf(address owner, uint TokenId)external view returns(uint);
function BalanceOfBatch(address[] calldata owner, uint[] calldata TokenId)external view returns(uint[] memory);
function SafeTransfer(address to,uint TokenId,uint ammount) external payable returns(bool);
function SafeTransferFrom(address From,address to,uint TokenId,uint ammount) external payable returns(bool);
function setApproved(address operator,uint TokenId)external  returns(bool);
function setAllowance(address operator,uint TokenId,uint ammount) external returns(bool);
function SafeBatchTransFrom (address[] calldata From,address[] calldata  to,uint[] calldata TokenId, uint[] calldata ammount) external;
function getLimit(address owner,address operator,uint TokenId) external view returns(uint);
function isApprovedforAll(address owner,address operator)external view returns(bool);
function PauseforAll(address owner,address operator)external returns(bool);
function unPauseForAll(address owner,address operator)external returns(bool);
}

contract ERC1155 {
    
    struct Tokens
    {
        uint TokenId;
        string TokenName;
        string TokenSymbol;
        address owner;
        uint Balance;
    }

    event minted(
    uint TokenId,
    string TokenName,
    string TokenSymbol,
    address owner,
    uint Balance
    );

    event Transferd(
        address from,
        address to,
        uint tokenId,
        uint ammount
    );

    event TransferdFrom(
        address operator,
        address from,
        address to,
        uint tokenId,
        uint ammount
    );

    event approved(
        address owner,
        address operator,
        uint TokenId
    );

    event PausedTransfer(
        address owner,
        address operator,
        uint TokenId,
        bool paused
    );

    event PausedAll(
        address owner,
        address operator,
        bool paused
    );


    mapping(uint =>Tokens)public Token;
    mapping(address => mapping(uint => uint)) internal inbalance;
    mapping(address =>mapping(address =>uint)) internal Allowed;
    mapping(address => mapping(address =>bool)) internal AllowedAll;
    mapping(address => mapping(address =>mapping(uint=>uint))) internal limit;
    mapping(address =>mapping(uint =>Tokens)) internal TokenBalance;
    mapping(address =>mapping(address =>uint)) internal paused;
    mapping(address =>mapping(address =>bool)) internal pausedall;


    function safeMint(uint TokenId, string memory TokenName,string memory TokenSymbol,uint Balance)public returns(bool) {
        TokenBalance[msg.sender][TokenId]=Tokens(TokenId,TokenName,TokenSymbol,msg.sender,Balance);
        //Token[TokenId]=Tokens(TokenId,TokenName,TokenSymbol,msg.sender,Balance);
        inbalance[msg.sender][TokenId]=Balance;
        emit minted(TokenId,TokenName,TokenSymbol,msg.sender,Balance);
    }

    function BalanceOf(address owner, uint TokenId)public view returns(uint){ 
        return(TokenBalance[owner][TokenId].Balance);
        //return(owner.Balance);
    }

    function BalanceOfBatch(address[] memory owner, uint[] memory TokenId)public view returns(uint[] memory){
        // return(Token[].Balance);
        uint256[] memory batchBalances;

        for (uint256 i = 0; i < TokenId.length; ++i) {
            batchBalances[i] = BalanceOf(owner[i], TokenId[i]);
        }
        return batchBalances;
    }

    

    function SafeTransfer(address to,uint TokenId,uint ammount) public payable returns(bool){
        require(TokenBalance[msg.sender][TokenId].owner == msg.sender);
        require(ammount <= TokenBalance[msg.sender][TokenId].Balance);
        require(pausedall[msg.sender][to]!=true);
        if(inbalance[to][TokenId] >0){
            TokenBalance[msg.sender][TokenId].Balance -= ammount;
            TokenBalance[to][TokenId].Balance += ammount;
            emit Transferd(msg.sender,to,TokenId,ammount);
            return(true);
        }else{
            TokenBalance[msg.sender][TokenId].Balance -= ammount;
            TokenBalance[to][TokenId]=Tokens(TokenId,Token[TokenId].TokenName,Token[TokenId].TokenSymbol,to,ammount);
            emit Transferd(msg.sender,to,TokenId,ammount);
            return(true);
            
        }

    }

    function SafeTransferFrom(address From,address to,uint TokenId,uint ammount) public payable returns(bool){
        require(TokenBalance[From][TokenId].owner == From);
        require (Allowed[From][msg.sender] == TokenId || AllowedAll[From][msg.sender]==true);
        require(ammount <= TokenBalance[From][TokenId].Balance);
        require(limit[From][msg.sender][TokenId] >= ammount);
        require(pausedall[msg.sender][to]!=true);
        if(inbalance[to][TokenId] >0){
            TokenBalance[From][TokenId].Balance -= ammount;
            TokenBalance[to][TokenId].Balance += ammount;
            emit TransferdFrom(msg.sender,From,to,TokenId,ammount);
            return(true);
        }else{
            TokenBalance[From][TokenId].Balance -= ammount;
            TokenBalance[to][TokenId]=Tokens(TokenId,Token[TokenId].TokenName,Token[TokenId].TokenSymbol,to,ammount);
            emit TransferdFrom(msg.sender,From,to,TokenId,ammount);
            return(true);
        }

    }

    function SafeBatchTransFrom (address[] memory From,address[] memory  to,uint[] memory TokenId, uint[] memory ammount) public {
        for(uint256 i =0;i< From.length;i++){
        SafeTransferFrom(From[i],to[i],TokenId[i],ammount[i]);
        }
    }

    function setApprovedForAll(address operator,bool Approved)public{
            AllowedAll[msg.sender][operator]=Approved;
            // return(approved);
    }

    function setApproved(address operator,uint TokenId)public  returns(bool){
        require(TokenBalance[msg.sender][TokenId].owner == msg.sender);
        Allowed[msg.sender][operator]=TokenId;
        emit approved(msg.sender,operator,TokenId);
        return(true);
    }

    function setAllowance(address operator,uint TokenId,uint ammount) public returns(bool){
        require(TokenBalance[msg.sender][TokenId].owner == msg.sender);
        require(ammount >= Token[TokenId].Balance);
        limit[msg.sender][operator][TokenId]=ammount;
        return(true);
    }

    function isApprovedforAll(address owner,address operator)public view returns(bool){
        return(AllowedAll[owner][operator]);
        
    }

    function getLimit(address owner,address operator,uint TokenId) public view returns(uint){
        return(limit[owner][operator][TokenId]);
    }
    
    // function makePause(address owner,address operator,uint TokenId) public returns(bool){
    //   paused[owner][operator]=TokenId;  
    //   emit PausedTransfer(owner,operator,TokenId,true);
    //     return(true);
    // }

    // function makeUnPause(address owner,address operator,uint TokenId) public returns(bool){
    //     require(paused[owner][operator]!=TokenId);
    //     paused[owner][operator]=TokenId;
    //     emit PausedTransfer(owner,operator,TokenId,false);
    //     return(true);
    // }
    function PauseforAll(address owner,address operator)public returns(bool){
        require(pausedall[owner][operator]==false);
        pausedall[owner][operator] =true;
        emit PausedAll(owner,operator,true);
        return(true);
    }

    function unPauseForAll(address owner,address operator)public returns(bool){
        require(pausedall[owner][operator]==true);
        pausedall[owner][operator] =false;
        emit PausedAll(owner,operator,false);
        return(true);
        }
}