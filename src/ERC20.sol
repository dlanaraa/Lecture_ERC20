// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20{
    mapping(address => uint256) private balances; //address르ㄹ key로, uint를 value로 갖는 balance
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

    //전송이 성공하는 일이 없을 것 -> 무조건 실패인 줄 알 거니까 -> 못알아들음
    //evm에서 지역변수나 storage를 초기화하지 않으면 쓰레기값 들어가는데 evm은 초기화 하지 않으면 default가 0임
    function transfer(address _to, uint256 _value) external returns (bool success){ //zero address로 보내면 안됨! -> to가 zero addressdlswl ghkrdls / 토큰 소각 / burn이랑 transfer를 구분 못함? -> 못알아들음 ㅋ
        require(_to != address(0), "transfer to the zero address");
        require(balances[msg.sender] >= _value, "Value exceeds balance");

        unchecked {
            balances[msg.sender] -= _value; // 취약점 -> value에 얼마나 큰 값이 들어올지 모름 -> -를 이용해서 integer undeflow 발생 -> 8버전 이후에는 revert되는데 그 이전 버전에서는 그냥 실행시켜버림 -> check할지 안할지 해주는 키워드 -> checked/unchecked / unchecked 사용 -> 이미 require로 검사를 한 번 했기 때문에 require하고 unchecked를 해서 gas fee를 줄임
            balances[_to] += _value;
        }

        emit Transfer(msg.sender, _to, _value); //transfer할 때 event 찍는 이유 : 이걸 안해도 transaction이 보이니까 토큰이 전송됐다는 사실은 알 수 있지만 이것을 하지 않으면 컨트랙트가 다른 컨트랙트를 호출할 때 그냥 트랜잭셔능ㄴ 컨트랙트에 어떤 함수를 넣어서 호출했는지 보이는데 internal은 trace를 해봐야지 트랜잭션을 확인할 수 있음 -> event를 안찍어주면 contract를 호출한 것은ㅇ ㅏㄹ 수 있는데 다른 컴트랙트를 통해 internal해서 / internal transaction이 언제 발생한지 모르니까 모든 트랜잭션을 trace해서 이게 호출됐는지 확인해야 함 / 중요한 설정 값 바꿨을 때 이런 사실을 쉽게 알기 위해서..?
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

        uint256 currentAllowance = allowance(_from, msg.sender); //msg.sender가 from한테 돈을 보낼 수 있는 권한이 있는지?
        if (currentAllowance != type(uint256).max){
            require(currentAllowance >= _value, "insufficient allowance");
            unchecked{     //나는 5원만 보내게 했는데 이걸 안하면 5원씩 계속 보내서 잔고를 Burning시킬 수 있음
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

    function _mint(address _owner, uint256 _value) internal{ //내가 토큰을 얼마나 발행하겠다! / internal 함수라 owner함수인지 확인하지 않아도 됨
        require(_owner != address(0), "mint to the zero address");
        _totalSupply += _value;
        unchecked{
            balances[_owner] += _value;
        }
        emit Transfer(address(0), _owner, _value);
    }

    function _burn(address _owner, uint256 _value) internal{ //내가 누군가의 토큰을 아예 태워버리겠다!
        require(_owner != address(0), "burn from the zero address");
        require(balances[_owner] >= _value, "burn amount exceeds balance");
        unchecked {
            balances[_owner] -= _value;
            _totalSupply -= _value;
        }

        emit Transfer(_owner, address(0), _value);
    }

}