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



contract evidenceContract is Ownable{     

    uint256  public rate;   // how much time we give for 1 wei or ether     
    address public myAddress = this;

    event Newuser(uint id, address indexed who, uint256 indexed timelimit);

  struct UserRecord {
      address user_address;
      bytes32 md5sum; // hash md5sum to check the url sent by the user
      bytes32 _hash; // we get from the server/archivum, its also the name of the object in the storage
      //uint256 timestamp; // when we get the datas
      uint256 timelimit; // when we want to hold the datas in the storage
  }

  struct Member {
    UserRecord userrecord;
  }

  mapping(uint => Member) members;

  function addMember(uint id, address user_address, bytes32 md5sum, bytes32 _hash, uint timelimit) onlyOwner public returns(bool success) {
    members[id].userrecord.user_address = user_address;
    members[id].userrecord.md5sum = md5sum;
    members[id].userrecord._hash = _hash;
    members[id].userrecord.timelimit = timelimit;

    Newuser(id, user_address,timelimit);

    
    return true;
  }

  function getMember(uint id) public constant returns(address user_address, bytes32 md5sum, bytes32 _hash, uint timelimit) {
    return(members[id].userrecord.user_address,
    members[id].userrecord.md5sum,
    members[id].userrecord._hash,
    members[id].userrecord.timelimit );
  }   


  function evidenceContract() public {             
    }      

}