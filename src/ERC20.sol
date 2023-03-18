// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20{
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor()
    {
        _name = "DREAM";
        _symbol = "DRM";
        _decimals = 18;
        _mint(msg.sender, 100 ether);
    }

    function name() public view returns (string memory){
        return _name;
    }    

    function symbol() public view returns (string memory){
        return _symbol;
    }

    function decimals() public view returns (uint8){
        return _decimals;
    }

    function totalSupply() public view returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256){
        return balances[_owner];
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function transfer(address _to, uint256 _value) external returns (bool success){
        require(_to != address(0), "transfer to the zero address");
        require(balances[msg.sender] >= _value, "Value exceeds balance");

        unchecked {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
        }

        emit Transfer(msg.sender, _to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool success){
        require(_spender != address(0), "approve to the zero address");

        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining){
        return allowances[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) {
        require(_from != address(0), "transfer to the zero address");
        require(_to != address(0), "transfer to the zero address");

        uint256 currentAllowance = allowance(_from, msg.sender);
        if (currentAllowance != type(uint256).max){
            require(currentAllowance >= _value, "insufficient allowance");
            unchecked{
                allowances[_from][msg.sender] -= _value;
            }
        }

        require(balances[_from] >= _value, "value exceeds balance");

        unchecked{
            balances[_from] -= _value;
            balances[_to] += _value;
        }

        emit Transfer(_from, _to, _value);
    }

    function _mint(address _owner, uint256 _value) internal{
        require(_owner != address(0), "mint to the zero address");
        _totalSupply += _value;
        unchecked{
            balances[_owner] += _value;
        }
        emit Transfer(address(0), _owner, _value);
    }

    function _burn(address _owner, uint256 _value) internal{
        require(_owner != address(0), "burn from the zero address");
        require(balances[_owner] >= _value, "burn amount exceeds balance");
        unchecked {
            balances[_owner] -= _value;
            _totalSupply -= _value;
        }

        emit Transfer(_owner, address(0), _value);
    }

}
