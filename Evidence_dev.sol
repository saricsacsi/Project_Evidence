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

    // to know an address is a member or not
    mapping (address => bool) public isMember;
  
    // count the records  
    uint256 public numberOfRecord = 0;
    // collect the ether to a multisig
    address public multiSig = 0xCD1d44dBdBFdc24C6E25E53282727557a7142f1D; // test multisig1      
  
    // log if we have a new user/member or if we change the timelimit -- only if the user sent ether to the contract
    event Newuser(uint256 number, address indexed who, uint256 indexed timelimit);
    event LogUpdateTimelimit(address indexed who, uint256 indexed timelimit);    

  struct UserRecord {
      
      bytes32 md5sum; // hash md5sum to check the url sent by the user
      bytes32 _hash; // we get from the server/archivum, its also the name of the object in the storage
      uint256 timelimit; // when we want to hold the datas in the storage
  }

  struct Member {
    UserRecord userrecord;
     }

  mapping(address => Member) members;  
 
 // new user to the list with datas without timelimit. Timelimit default is now.
  function addMember(address user_address, bytes32 md5sum, bytes32 _hash) onlyOwner public returns(bool success) {
    uint256 timelimit = now;
    require (user_address != 0x0 || user_address != myAddress);
        
    members[user_address].userrecord.md5sum = md5sum;
    members[user_address].userrecord._hash = _hash;
    members[user_address].userrecord.timelimit = timelimit;
    isMember[user_address] = true;  
    numberOfRecord++;
    Newuser(numberOfRecord,user_address,timelimit);    
    return true;
  }

 // can get back the datas of the user if we know the address
  function getMember(address user_address) public constant returns(bytes32 md5sum, bytes32 _hash, uint timelimit) {
    return(
    members[user_address].userrecord.md5sum,
    members[user_address].userrecord._hash,
    members[user_address].userrecord.timelimit );
  }  
 // update the timelimit what is depends on the amount of ether

  function updateTimelimit(address user_address, uint timelimit) 
    public
    returns(bool success) 
  {
    require(isMember[user_address]); // check it is a member?
    members[user_address].userrecord.timelimit = timelimit; // set the timelimit
    LogUpdateTimelimit(user_address,timelimit); // log the timelimit changeing
    return true;
  }
 
  function evidenceContract() public {               
  }    

  // buy function calculate the time from the amount , the rate default is 1 ether = 1 month
  function buy(address user_address, uint256 amount) onlyMember internal { 
      
    uint256 timeUnit = amount*rate/ 1 ether;
    uint256 newtimelimit = now.add(timeUnit);

    updateTimelimit(user_address,newtimelimit);       
    multiSig.transfer(this.balance); // better in case any other ether ends up here
    }
  
  // payable funcion what is called when we get ether 
  function () public payable {
    buy(msg.sender, msg.value);
  }
 
  // some more feature in the future what is only the members can do it,
  // or maybe we change and only the record-owner can do it
  modifier onlyMember() {
    require (isMember[msg.sender]);
       _;
  }
 

}