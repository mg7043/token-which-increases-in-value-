
pragma solidity ^0.8.0;

contract ExampleToken {
    string public name = "ExampleToken";
    string public symbol = "EXT";
    uint8 public decimals = 18;
    uint256 public totalSupply = 100000000 * 10**uint256(decimals);
    uint256 public buyFee = 5; // Buy fee is 5% (500 basis points)
    uint256 public sellFee = 9; // Sell fee is 9% (900 basis points)
    uint256 public constant PRICE_PRECISION = 10**6;
    
    // Internal variables
    uint256 private constant MAX_BPS = 10000; // 100%
    uint256 private _totalSupply;
    uint256 private _tokenPrice;
    uint256 private _totalFees;
    address private owner;
    
    // Track user balances and allowances
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Events for transfer, approval, buy and sell
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Buy(address indexed buyer, uint256 value, uint256 fee);
    event Sell(address indexed seller, uint256 value, uint256 fee);
    
    constructor() 
    {
        _totalSupply = totalSupply;
        _tokenPrice = PRICE_PRECISION;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
        _totalFees = 0;
        owner = msg.sender;
    }
    
    function transfer(address to, uint256 value) public returns (bool) 
    {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) 
    {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public returns (bool) 
    {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Insufficient allowance");
        balanceOf[from] -= value;
        allowance[from][msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
        return true;
    }

    function buy() public payable returns (bool) 
    {
        require(msg.value > 0, "Value must be greater than zero");
        uint256 value = (msg.value * PRICE_PRECISION) / _tokenPrice;
        uint256 fee = (value * buyFee) / MAX_BPS;
        uint256 actualValue = value - fee;
        require(_totalSupply + actualValue <= totalSupply, "Buy would exceed maximum supply");
        balanceOf[msg.sender] += actualValue;
        _totalSupply += actualValue;
        _totalFees += fee;
        _tokenPrice = (_totalSupply * PRICE_PRECISION) / (totalSupply - _totalFees);
        payable(address(this)).transfer(msg.value);
        emit Transfer(address(this), msg.sender, actualValue);
        emit Buy(msg.sender, actualValue, fee);
        return true;
    }

     function getBuyFee() public view returns (uint256) 
     {
      return buyFee;
     }

     function setBuyFee(uint256 fee) public 
     {
     require(fee <= MAX_BPS, "Fee cannot exceed 100%");
     buyFee = fee;
     }

     function getSellFee() public view returns (uint256) 
     {
       return sellFee;
     }

     function setSellFee(uint256 fee) public 
     {
      require(fee <= MAX_BPS, "Fee cannot exceed 100%");
      sellFee = fee;
     }

      function getTokenPrice() public view returns (uint256) 
      {
        return _tokenPrice;
      }

     function getTotalFees() public view returns (uint256) 
     {
       return _totalFees;
     }

      function withdrawFees() public 
      {
       require(msg.sender == owner, "Only the owner can withdraw fees");
       uint256 totalFees = _totalFees;
       _totalFees = 0;
       uint256 price = PRICE_PRECISION; // get the value of PRICE_PRECISION
       payable(owner).transfer(totalFees * _tokenPrice / price);
}


}
