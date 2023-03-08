pragma solidity ^0.8.0;

contract IncreasingToken {

    string public name;

    string public symbol;

    uint8 public decimals;

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    uint256 public price;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialSupply, uint256 _initialPrice) {

        name = _name;

        symbol = _symbol;

        decimals = _decimals;

        totalSupply = _initialSupply * 10 ** uint256(decimals);

        balanceOf[msg.sender] = totalSupply;

        price = _initialPrice;

        emit Transfer(address(0), msg.sender, totalSupply);

    }

    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(_to != address(0), "Invalid address");

        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        uint256 fee = _value / 100; // 1% transaction fee

        uint256 newValue = _value - fee;

        uint256 increaseAmount = price * newValue / totalSupply;

        price += increaseAmount;

        balanceOf[msg.sender] -= _value;

        balanceOf[_to] += newValue;

        balanceOf[address(this)] += fee;

        emit Transfer(msg.sender, _to, newValue);

        emit Transfer(msg.sender, address(this), fee);

        return true;

    }

    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_to != address(0), "Invalid address");

        require(_value <= balanceOf[_from], "Insufficient balance");

        require(_value <= allowance[_from][msg.sender], "Insufficient allowance");

        uint256 fee = _value / 100; // 1% transaction fee

        uint256 newValue = _value - fee;

        uint256 increaseAmount = price * newValue / totalSupply;

        price += increaseAmount;

        balanceOf[_from] -= _value;

        balanceOf[_to] += newValue;

        balanceOf[address(this)] += fee;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, newValue);

        emit Transfer(_from, address(this), fee);

        emit Approval(_from, msg.sender, allowance[_from][msg.sender]);

        return true;

    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}
