pragma solidity ^0.4.16;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }
  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner(){
    require(msg.sender == owner);
    _;
  }
  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract evidenceContract is Ownable{  
    using SafeMath for uint256;   

    uint256  public rate = 2629743;  // how much time we give for 1 ether , 2629743 = 1 month  
    address public myAddress = this;

    // address - number - bool
    mapping (address => userrecord[]) public contens;

    mapping (address => bool) public isMember;
  

    bool timeactive = false; 
    // count the records  
    uint256 public numberOfRecord = 0;
    uint256 public numberOfMembers =0;
    // collect the ether to a multisig
    address public multiSig = 0xCD1d44dBdBFdc24C6E25E53282727557a7142f1D; // test multisig1      
  
    // log if we have a new user/member or if we change the timelimit -- only if the user sent ether to the contract
    event NewMember(uint256 numberofmembers, address indexed who);
    event NewRecord(address user_address, uint256 _number, bool valid, bytes32 md5sum, bytes32 _hash, uint256 timelimit);
    event LogUpdateTimelimit(address indexed who, uint256 _number, uint256 indexed timelimit);    

  struct userrecord {
      
      bool valid;
      bytes32 md5sum; // hash md5sum to check the url sent by the user
      bytes32 _hash; // we get from the server/archivum, its also the name of the object in the storage
      uint256 timelimit; // when we want to hold the datas in the storage
  }

  
 
 
 // new user to the list with datas without timelimit. Timelimit default is now.
  function addMember(address user_address) onlyOwner public returns(bool success) {
    //require (timeactive);
    require (user_address != 0x0 || user_address != myAddress);    
    isMember[user_address] = true;  
    numberOfMembers++;
    NewMember(numberOfMembers,user_address);    
    return true;
  }

  // some more feature in the future what is only the members can do it,
  // or maybe we change and only the record-owner can do it
  modifier onlyMember() {
    require (isMember[msg.sender]);
       _;
  }

 function settimeactive() public returns(bool _timeactive){
    return( timeactive = true);
  }  


 // can get back the datas of the user if we know the address
  function getMember(address user_address) 
  public constant 
  returns(address _user_address, uint256 _index, bool _valid, bytes32 md5sum, bytes32 _hash, uint256 timelimit) {
  uint256 number;
 

  for (number = 0; number < contens[user_address].length; number++) {
    return(
     user_address,number,
     contens[user_address][number].valid,
     contens[user_address][number].md5sum,
     contens[user_address][number]._hash,
     contens[user_address][number].timelimit );      
    }      
    
  }  


  function newRecord(address user_address, bytes32 _md5sum, bytes32 _hash)
         onlyOwner public returns(bool success) { 

    require(isMember[user_address]);
   
    contens[user_address][0].valid = false;
    contens[user_address][0].md5sum = _md5sum;
    contens[user_address][0]._hash = _hash;
    contens[user_address][0].timelimit = now;
         
   
    NewRecord(user_address,contens[user_address].length, contens[user_address][0].valid,
    contens[user_address][0].md5sum,contens[user_address][0]._hash,contens[user_address][0].timelimit);
  
    return true;
   }    



 // update the timelimit what is depends on the amount of ether

  function updateTimelimit(address user_address, uint256 _number, uint256 _timelimit) 
    public
    returns(bool success) 
  {
    require(isMember[user_address]); // check it is a member?
    contens[user_address][_number].timelimit = _timelimit; // set the timelimit
    LogUpdateTimelimit(user_address, _number,_timelimit); // log the timelimit changeing
    return true;
  }
 
  function evidenceContract() public {               
  }   

   // payable funcion what is called when we get ether 
  function () public payable {
    buy(msg.sender, msg.value);
  } 

  // buy function calculate the time from the amount , the rate default is 1 ether = 1 month
  function buy(address user_address, uint256 amount) onlyMember internal { 
      
    uint256 timeUnit = amount*rate/ 1 ether;
    uint256 newtimelimit = now.add(timeUnit);
    uint256 number;

    
    for (number = 0; number < contens[user_address].length; number++) {
      if (!contens[user_address][number].valid) {
          contens[user_address][number].valid = true;
          updateTimelimit(user_address,number,newtimelimit);
          LogUpdateTimelimit(user_address,number,newtimelimit);             
      }      

    multiSig.transfer(this.balance); // better in case any other ether ends up here
  }

}
}