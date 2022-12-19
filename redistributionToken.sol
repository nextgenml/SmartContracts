// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IDEXV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _createInitialSupply(address account, uint256 amount)
        internal
        virtual
    {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

interface DividendPayingTokenOptionalInterface {
    function withdrawableDividendOf(address _owner, address _rewardToken)
        external
        view
        returns (uint256);

    function withdrawnDividendOf(address _owner, address _rewardToken)
        external
        view
        returns (uint256);

    function accumulativeDividendOf(address _owner, address _rewardToken)
        external
        view
        returns (uint256);
}

interface DividendPayingTokenInterface {
    function dividendOf(address _owner, address _rewardToken)
        external
        view
        returns (uint256);

    function distributeDividends() external payable;

    function withdrawDividend(address _rewardToken) external;

    event DividendsDistributed(address indexed from, uint256 weiAmount);

    event DividendWithdrawn(address indexed to, uint256 weiAmount);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        // deployer wallet
        address msgSender = 0x8B8EBA8654f00E0F5A93491c3870C09b0e27735D;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }

    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
}

interface IDEXV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

}

interface IDEXV2Router02 is IDEXV2Router01 {


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract DividendPayingToken is
    DividendPayingTokenInterface,
    DividendPayingTokenOptionalInterface,
    Ownable
{
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    uint256 internal constant magnitude = 2**128;

    mapping(address => uint256) internal magnifiedDividendPerShare;
    address[] public rewardTokens;
    address public nextRewardToken;
    uint256 public rewardTokenCounter;

    IDEXV2Router02 public immutable DEXV2Router;
    
    mapping(address => mapping(address => int256))
        internal magnifiedDividendCorrections;
    mapping(address => mapping(address => uint256)) internal withdrawnDividends;

    mapping(address => uint256) public holderBalance;
    uint256 public totalBalance;

    mapping(address => uint256) public totalDividendsDistributed;

    constructor() {
        IDEXV2Router02 _DEXV2Router = IDEXV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        ); 
        DEXV2Router = _DEXV2Router;

        // Mainnet

        rewardTokens.push(address(0x4bB4954FC47ce04B62F3493040ff8318E4A72981)); // USDC mainnet: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
        

        nextRewardToken = rewardTokens[0];
    }

    receive() external payable {
        distributeDividends();
    }


    function distributeDividends() public payable override {
        require(totalBalance > 0);
        uint256 initialBalance = IERC20(nextRewardToken).balanceOf(
            address(this)
        );
        buyTokens(msg.value, nextRewardToken);
        uint256 newBalance = IERC20(nextRewardToken)
            .balanceOf(address(this))
            .sub(initialBalance);
        if (newBalance > 0) {
            magnifiedDividendPerShare[
                nextRewardToken
            ] = magnifiedDividendPerShare[nextRewardToken].add(
                (newBalance).mul(magnitude) / totalBalance
            );
            emit DividendsDistributed(msg.sender, newBalance);

            totalDividendsDistributed[
                nextRewardToken
            ] = totalDividendsDistributed[nextRewardToken].add(newBalance);
        }
        rewardTokenCounter = rewardTokenCounter == rewardTokens.length - 1
            ? 0
            : rewardTokenCounter + 1;
        nextRewardToken = rewardTokens[rewardTokenCounter];
    }

    function buyTokens(uint256 bnbAmountInWei, address rewardToken) internal {
        // generate the DEX pair path of weth -> eth
        address[] memory path = new address[](2);
        path[0] = DEXV2Router.WETH();
        path[1] = rewardToken;

        // make the swap
        DEXV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: bnbAmountInWei
        }(
            0, // accept any amount of Ethereum
            path,
            address(this),
            block.timestamp
        );
    }
    function withdrawDividend(address _rewardToken) external virtual override {
        _withdrawDividendOfUser(payable(msg.sender), _rewardToken);
    }

    function _withdrawDividendOfUser(address payable user, address _rewardToken)
        internal
        returns (uint256)
    {
        uint256 _withdrawableDividend = withdrawableDividendOf(
            user,
            _rewardToken
        );
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user][_rewardToken] = withdrawnDividends[user][
                _rewardToken
            ].add(_withdrawableDividend);
            emit DividendWithdrawn(user, _withdrawableDividend);
            IERC20(_rewardToken).transfer(user, _withdrawableDividend);
            return _withdrawableDividend;
        }

        return 0;
    }

    function dividendOf(address _owner, address _rewardToken)
        external
        view
        override
        returns (uint256)
    {
        return withdrawableDividendOf(_owner, _rewardToken);
    }

    function withdrawableDividendOf(address _owner, address _rewardToken)
        public
        view
        override
        returns (uint256)
    {
        return
            accumulativeDividendOf(_owner, _rewardToken).sub(
                withdrawnDividends[_owner][_rewardToken]
            );
    }

    function withdrawnDividendOf(address _owner, address _rewardToken)
        external
        view
        override
        returns (uint256)
    {
        return withdrawnDividends[_owner][_rewardToken];
    }

    function accumulativeDividendOf(address _owner, address _rewardToken)
        public
        view
        override
        returns (uint256)
    {
        return
            magnifiedDividendPerShare[_rewardToken]
                .mul(holderBalance[_owner])
                .toInt256Safe()
                .add(magnifiedDividendCorrections[_rewardToken][_owner])
                .toUint256Safe() / magnitude;
    }

    function _increase(address account, uint256 value) internal {
        for (uint256 i; i < rewardTokens.length; i++) {
            magnifiedDividendCorrections[rewardTokens[i]][
                account
            ] = magnifiedDividendCorrections[rewardTokens[i]][account].sub(
                (magnifiedDividendPerShare[rewardTokens[i]].mul(value))
                    .toInt256Safe()
            );
        }
    }

    function _reduce(address account, uint256 value) internal {
        for (uint256 i; i < rewardTokens.length; i++) {
            magnifiedDividendCorrections[rewardTokens[i]][
                account
            ] = magnifiedDividendCorrections[rewardTokens[i]][account].add(
                (magnifiedDividendPerShare[rewardTokens[i]].mul(value))
                    .toInt256Safe()
            );
        }
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = holderBalance[account];
        holderBalance[account] = newBalance;
        if (newBalance > currentBalance) {
            uint256 increaseAmount = newBalance.sub(currentBalance);
            _increase(account, increaseAmount);
            totalBalance += increaseAmount;
        } else if (newBalance < currentBalance) {
            uint256 reduceAmount = currentBalance.sub(newBalance);
            _reduce(account, reduceAmount);
            totalBalance -= reduceAmount;
        }
    }
}

contract DividendTracker is DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(address key) private view returns (uint256) {
        return tokenHoldersMap.values[key];
    }

    function getIndexOfKey(address key) private view returns (int256) {
        if (!tokenHoldersMap.inserted[key]) {
            return -1;
        }
        return int256(tokenHoldersMap.indexOf[key]);
    }

    function getKeyAtIndex(uint256 index) private view returns (address) {
        return tokenHoldersMap.keys[index];
    }

    function size() private view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function set(address key, uint256 val) private {
        if (tokenHoldersMap.inserted[key]) {
            tokenHoldersMap.values[key] = val;
        } else {
            tokenHoldersMap.inserted[key] = true;
            tokenHoldersMap.values[key] = val;
            tokenHoldersMap.indexOf[key] = tokenHoldersMap.keys.length;
            tokenHoldersMap.keys.push(key);
        }
    }

    function remove(address key) private {
        if (!tokenHoldersMap.inserted[key]) {
            return;
        }

        delete tokenHoldersMap.inserted[key];
        delete tokenHoldersMap.values[key];

        uint256 index = tokenHoldersMap.indexOf[key];
        uint256 lastIndex = tokenHoldersMap.keys.length - 1;
        address lastKey = tokenHoldersMap.keys[lastIndex];

        tokenHoldersMap.indexOf[lastKey] = index;
        delete tokenHoldersMap.indexOf[key];

        tokenHoldersMap.keys[index] = lastKey;
        tokenHoldersMap.keys.pop();
    }

    Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping(address => bool) public excludedFromDividends;

    mapping(address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public immutable minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event IncludeInDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(
        address indexed account,
        uint256 amount,
        bool indexed automatic
    );

    constructor() {
        claimWait = 1200;
        minimumTokenBalanceForDividends = 1000 * (10**18);
    }

    function excludeFromDividends(address account) external onlyOwner {
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        remove(account);

        emit ExcludeFromDividends(account);
    }

    function includeInDividends(address account) external onlyOwner {
        require(excludedFromDividends[account]);
        excludedFromDividends[account] = false;

        emit IncludeInDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(
            newClaimWait >= 1200 && newClaimWait <= 86400,
            "Dividend_Tracker: claimWait must be updated to between 1 and 24 hours"
        );
        require(
            newClaimWait != claimWait,
            "Dividend_Tracker: Cannot update claimWait to same value"
        );
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp) {
            return false;
        }

        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance)
        external
        onlyOwner
    {
        if (excludedFromDividends[account]) {
            return;
        }

        if (newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            set(account, newBalance);
        } else {
            _setBalance(account, 0);
            remove(account);
        }

        processAccount(account, true);
    }

    function process(uint256 gas)
        external
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

        if (numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }

            address account = tokenHoldersMap.keys[_lastProcessedIndex];

            if (canAutoClaim(lastClaimTimes[account])) {
                if (processAccount(payable(account), true)) {
                    claims++;
                }
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }
            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;

        return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic)
        public
        onlyOwner
        returns (bool)
    {
        uint256 amount;
        bool paid;
        for (uint256 i; i < rewardTokens.length; i++) {
            amount = _withdrawDividendOfUser(account, rewardTokens[i]);
            if (amount > 0) {
                lastClaimTimes[account] = block.timestamp;
                emit Claim(account, amount, automatic);
                paid = true;
            }
        }
        return paid;
    }
}

contract XYZ is ERC20, Ownable {
    using SafeMath for uint256;

    address payable public MarketWallet =
      payable ( 0x709d90C5757b438d2296a9F24b710045ED7B114c );
    address payable public creatorWallet =
        payable ( 0xF57434c0Ec4283B381a6f4ba80d00E92Cd467d90 );
    address payable public wheelWallet =
        payable ( 0x3db0aDaF12370ae1155f5861692B991397093fFf );
    address[] public MarketTokens;

    IDEXV2Router02 public immutable DEXV2Router;
    address public immutable DEXV2Pair;

    bool private swapping;

    DividendTracker public dividendTracker;

    uint256 public maxTransactionAmount;
    uint256 public swapTokensAtAmount;
    uint256 public maxWallet;

    uint256 public tradingActiveBlock = 0; // 0 means trading is not active

    bool public limitsInEffect = true;
    bool public tradingActive = false;
    bool public swapEnabled = false;

    uint256 public constant feeDivisor = 1000;

    uint256 public totalSellFees;
    uint256 public rewardsSellFee;
    uint256 public liquiditySellFee;
    uint256 public marketingSellFee;
    uint256 public CreatorSellFee;
    uint256 public wheelSellFee;
    uint256 public burnSellFee;

    uint256 public totalBuyFees;
    uint256 public rewardsBuyFee;
    uint256 public liquidityBuyFee;
    uint256 public marketingBuyFee;
    uint256 public CreatorBuyFee;
    uint256 public wheelBuyFee;
    uint256 public burnBuyFee;

    uint256 public tokensForRewards;
    uint256 public tokensForLiquidity;
    uint256 public tokensForMarketWallet;

    uint256 public gasForProcessing = 0;
    uint256 public MaxBurn;
    uint256 public Burned;

    uint256 public lpWithdrawRequestTimestamp;
    uint256 public lpWithdrawRequestDuration = 3 days;
    bool public lpWithdrawRequestPending;
    uint256 public lpPercToWithDraw;

    // exlcude from fees and max transaction amount
    mapping(address => bool) private _isExcludedFromFees;

    mapping(address => bool) public _isExcludedMaxTransactionAmount;

    // store addresses that an automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping(address => bool) public automatedMarketMakerPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludedMaxTransactionAmount(
        address indexed account,
        bool isExcluded
    );

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);


    event GasForProcessingUpdated(
        uint256 indexed newValue,
        uint256 indexed oldValue
    );

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );


    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );

    // change names here before deployment
    constructor() ERC20("XYZ", "XYZ") {
        uint256 totalSupply = 1 * 1e9 * 1e18;

        MaxBurn = (730 days) * (1 ether);

        maxTransactionAmount = (totalSupply * 10) / 1000;
        swapTokensAtAmount = (totalSupply * 5) / 10000;
        maxWallet = (totalSupply * 10) / 1000;

        liquidityBuyFee = 50;
        rewardsBuyFee = 40;
        marketingBuyFee = 20;
        wheelBuyFee = 20;
        burnBuyFee = 10;
        CreatorBuyFee = 10;
        totalBuyFees =
            rewardsBuyFee +
            liquidityBuyFee +
            marketingBuyFee +
            wheelBuyFee +
            burnBuyFee+
            CreatorBuyFee;

        liquiditySellFee = 50;
        rewardsSellFee = 40;
        marketingSellFee = 20;
        wheelSellFee = 20;
        burnSellFee = 10;
        CreatorSellFee = 10;

        totalSellFees =
            rewardsSellFee +
            liquiditySellFee +
            marketingSellFee +
            wheelSellFee +
            burnSellFee+
            CreatorSellFee;

        MarketTokens.push(0x4bB4954FC47ce04B62F3493040ff8318E4A72981); // USDC - 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48

        dividendTracker = new DividendTracker();

        IDEXV2Router02 _DEXV2Router = IDEXV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        ); //0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D

        // Create a DEX pair for this new token
        address _DEXV2Pair = IDEXV2Factory(_DEXV2Router.factory()).createPair(
            address(this),
            _DEXV2Router.WETH()
        );

        DEXV2Router = _DEXV2Router;
        DEXV2Pair = _DEXV2Pair;

        _setAutomatedMarketMakerPair(_DEXV2Pair, true);

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(address(_DEXV2Router));
        dividendTracker.excludeFromDividends(address(0xdead));

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);
        excludeFromMaxTransaction(owner(), true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(address(dividendTracker), true);
        excludeFromMaxTransaction(address(_DEXV2Router), true);
        excludeFromMaxTransaction(address(0xdead), true);

        _createInitialSupply(address(owner()), totalSupply);
    }

    receive() external payable {}

    // excludes wallets and contracts from dividends (such as CEX hotwallets, etc.)
    function excludeFromDividends(address account) external onlyOwner {
        dividendTracker.excludeFromDividends(account);
    }

    // removes exclusion on wallets and contracts from dividends (such as CEX hotwallets, etc.)
    function includeInDividends(address account) external onlyOwner {
        dividendTracker.includeInDividends(account);
    }

    // once enabled, can never be turned off
    function enableTrading() external onlyOwner {
        require(!tradingActive, "Cannot re-enable trading");
        tradingActive = true;
        swapEnabled = true;
        tradingActiveBlock = block.number;
    }

    // only use to disable contract sales if absolutely necessary (emergency use only)
    function updateSwapEnabled(bool enabled) external onlyOwner {
        swapEnabled = enabled;
    }

    function updateMaxTxnAmount(uint256 newNum) external onlyOwner {
        require(
            newNum > ((totalSupply() * 1) / 1000) / 1e18,
            "Cannot set maxTransactionAmount lower than 0.1%"
        );
        maxTransactionAmount = newNum * (10**18);
    }

    function updateMaxWalletAmount(uint256 newNum) external onlyOwner {
        require(
            newNum > ((totalSupply() * 1) / 100) / 1e18,
            "Cannot set maxWallet lower than 1%"
        );
        maxWallet = newNum * (10**18);
    }

    function updateBuyFees(
        uint256 _rewardsFee,
        uint256 _liquidityFee,
        uint256 _marketFee,
        uint256 _wheelFee,
        uint256 _burnFee,
        uint256 _creatorFee
    ) external onlyOwner {
        rewardsBuyFee = _rewardsFee;
        liquidityBuyFee = _liquidityFee;
        marketingBuyFee = _marketFee;
        wheelBuyFee = _wheelFee;
        CreatorBuyFee = _creatorFee;
        burnBuyFee = _burnFee;
        totalBuyFees =
            rewardsBuyFee +
            liquidityBuyFee +
            marketingBuyFee +
            CreatorBuyFee +
            burnBuyFee+
            wheelBuyFee;
        require(totalBuyFees <= 150, "Must keep fees at 15% or less");
    }

    function updateSellFees(
        uint256 _rewardsFee,
        uint256 _liquidityFee,
        uint256 _marketFee,
        uint256 _wheelFee,
        uint256 _burnFee,
        uint256 _creatorFee
    ) external onlyOwner {
        rewardsSellFee = _rewardsFee;
        liquiditySellFee = _liquidityFee;
        marketingSellFee = _marketFee;
        wheelSellFee = _wheelFee;
        CreatorSellFee = _creatorFee;
        burnSellFee = _burnFee;
        totalSellFees =
            rewardsSellFee +
            liquiditySellFee +
            marketingSellFee +
            CreatorSellFee +
            burnSellFee+
            wheelSellFee;
        require(totalSellFees <= 150, "Must keep fees at 15% or less");
    }

    function excludeFromMaxTransaction(address updAds, bool isEx)
        public
        onlyOwner
    {
        _isExcludedMaxTransactionAmount[updAds] = isEx;
        emit ExcludedMaxTransactionAmount(updAds, isEx);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value)
        external
        onlyOwner
    {
        require(
            pair != DEXV2Pair,
            "The DEXSwap pair cannot be removed from automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;

        excludeFromMaxTransaction(pair, value);

        if (value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateGasForProcessing(uint256 newValue) external onlyOwner {
        require(
            newValue >= 200000 && newValue <= 500000,
            " gasForProcessing must be between 200,000 and 500,000"
        );
        require(
            newValue != gasForProcessing,
            "Cannot update gasForProcessing to same value"
        );
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns (uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed(address rewardToken)
        external
        view
        returns (uint256)
    {
        return dividendTracker.totalDividendsDistributed(rewardToken);
    }

    function isExcludedFromFees(address account) external view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account, address rewardToken)
        external
        view
        returns (uint256)
    {
        return dividendTracker.withdrawableDividendOf(account, rewardToken);
    }

    function dividendTokenBalanceOf(address account)
        external
        view
        returns (uint256)
    {
        return dividendTracker.holderBalance(account);
    }

    function processDividendTracker(uint256 gas) external {
        (
            uint256 iterations,
            uint256 claims,
            uint256 lastProcessedIndex
        ) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(
            iterations,
            claims,
            lastProcessedIndex,
            false,
            gas,
            tx.origin
        );
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function getNumberOfDividends() external view returns (uint256) {
        return dividendTracker.totalBalance();
    }

    function removeLimits() external onlyOwner returns (bool) {
        limitsInEffect = false;
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (!tradingActive) {
            require(
                _isExcludedFromFees[from] || _isExcludedFromFees[to],
                "Trading is not active yet."
            );
        }

        if (limitsInEffect) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !swapping
            ) {
                //when buy
                if (
                    automatedMarketMakerPairs[from] &&
                    !_isExcludedMaxTransactionAmount[to]
                ) {
                    require(
                        amount <= maxTransactionAmount,
                        "Buy transfer amount exceeds the maxTransactionAmount."
                    );
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Unable to exceed Max Wallet"
                    );
                }
                //when sell
                else if (
                    automatedMarketMakerPairs[to] &&
                    !_isExcludedMaxTransactionAmount[from]
                ) {
                    require(
                        amount <= maxTransactionAmount,
                        "Sell transfer amount exceeds the maxTransactionAmount."
                    );
                } else if (!_isExcludedMaxTransactionAmount[to]) {
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Unable to exceed Max Wallet"
                    );
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (
            canSwap &&
            swapEnabled &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            swapping = true;
            swapBack();
            swapping = false;
        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        uint256 wheelToken;
        uint256 creatorToken;
        uint256 burnToken;

        if(Burned  >= MaxBurn){
            burnBuyFee = 0;
            burnSellFee = 0;
        }

        // no taxes on transfers (non buys/sells)
        if (takeFee) {
            // on sell
            if (automatedMarketMakerPairs[to] && totalSellFees > 0) {
                fees = amount.mul(totalSellFees).div(feeDivisor);
                tokensForRewards += (fees * rewardsSellFee) / totalSellFees;
                tokensForLiquidity += (fees * liquiditySellFee) / totalSellFees;
                tokensForMarketWallet +=
                    (fees * marketingSellFee) /
                    totalSellFees;
                wheelToken = (fees * wheelSellFee) / totalSellFees;
                creatorToken = (fees * CreatorSellFee) / totalSellFees;
                burnToken = (fees * burnSellFee) / totalSellFees;

            }
            // on buy
            else if (automatedMarketMakerPairs[from] && totalBuyFees > 0) {
                fees = amount.mul(totalBuyFees).div(feeDivisor);
                tokensForRewards += (fees * rewardsBuyFee) / totalBuyFees;
                tokensForLiquidity += (fees * liquidityBuyFee) / totalBuyFees;
                tokensForMarketWallet +=
                    (fees * marketingBuyFee) /
                    totalBuyFees;
                wheelToken = (fees * wheelBuyFee) / totalBuyFees;
                creatorToken = (fees * CreatorBuyFee) / totalBuyFees;
                burnToken = (fees * burnBuyFee) / totalBuyFees;
            }

            if (fees > 0) {
                super._transfer(
                    from,
                    address(this),
                    fees - (wheelToken + creatorToken)
                );
                if (wheelToken > 0) {
                    super._transfer(from, wheelWallet, wheelToken);
                }
                if (creatorToken > 0) {
                    super._transfer(from, creatorWallet, creatorToken);
                }
                if (burnToken > 0) {
                    super._transfer(from, address(0xdead), burnToken);
                }
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);

        dividendTracker.setBalance(payable(from), balanceOf(from));
        dividendTracker.setBalance(payable(to), balanceOf(to));

        if (!swapping && gasForProcessing > 0) {
            uint256 gas = gasForProcessing;

            try dividendTracker.process(gas) returns (
                uint256 iterations,
                uint256 claims,
                uint256 lastProcessedIndex
            ) {
                emit ProcessedDividendTracker(
                    iterations,
                    claims,
                    lastProcessedIndex,
                    true,
                    gas,
                    tx.origin
                );
            } catch {}
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the DEX pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = DEXV2Router.WETH();

        _approve(address(this), address(DEXV2Router), tokenAmount);

        // make the swap
        DEXV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(DEXV2Router), tokenAmount);

        // add the liquidity
        DEXV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0xdead),
            block.timestamp
        );
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForLiquidity +
            tokensForRewards +
            tokensForMarketWallet;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }

        // Halve the amount of liquidity tokens
        uint256 liquidityTokens = (contractBalance * tokensForLiquidity) /
            totalTokensToSwap /
            2;
        uint256 amountToSwapForETH = contractBalance.sub(liquidityTokens);

        uint256 initialETHBalance = address(this).balance;

        swapTokensForEth(amountToSwapForETH);

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);

        uint256 ethForRewards = ethBalance.mul(tokensForRewards).div(
            totalTokensToSwap - (tokensForLiquidity / 2)
        );
        uint256 ethForMarketwallet = ethBalance.mul(tokensForMarketWallet).div(
            totalTokensToSwap - (tokensForLiquidity / 2)
        );

        uint256 ethForLiquidity = ethBalance -
            (ethForRewards + ethForMarketwallet);

        tokensForLiquidity = 0;
        tokensForRewards = 0;
        tokensForMarketWallet = 0;

        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            addLiquidity(liquidityTokens, ethForLiquidity);
            emit SwapAndLiquify(
                amountToSwapForETH,
                ethForLiquidity,
                tokensForLiquidity
            );
        }

        (bool success, ) = address(dividendTracker).call{value: ethForRewards}(
            ""
        );
        uint256 Eachtoken = ethForMarketwallet / MarketTokens.length;
        for (uint256 index = 0; index < MarketTokens.length; index++) {
            SwapTokensToMarketWallet(Eachtoken, MarketTokens[index]);
        }
    }

    function SwapTokensToMarketWallet(
        uint256 bnbAmountInWei,
        address rewardToken
    ) internal {
        // generate the DEX pair path of weth -> eth
        address[] memory path = new address[](2);
        path[0] = DEXV2Router.WETH();
        path[1] = rewardToken;

        // make the swap
        DEXV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: bnbAmountInWei
        }(
            0, // accept any amount of Ethereum
            path,
            MarketWallet,
            block.timestamp
        );
    }

    function addMarketWalletToken(address token) external onlyOwner {
        require(MarketTokens.length < 9);
        require(token != address(0) || token != address(0xdead));
        MarketTokens.push(token);
    }

    function setMinTokenSwap(uint256 _amount) external onlyOwner{
        require(_amount <= (totalSupply()/100));
        swapTokensAtAmount = _amount;
    }

    function removeMarketWalletToken(address token) external onlyOwner {
        require(MarketTokens.length > 0);
        require(token != address(0) || token != address(0xdead));
        for (uint256 index = 0; index < MarketTokens.length; index++) {
            if (token == MarketTokens[index]) {
                address temp = MarketTokens[MarketTokens.length - 1];
                MarketTokens[index] = temp;
                MarketTokens.pop();
            }
        }
    }

    function withdrawStuckEth() external onlyOwner {
        (bool success, ) = address(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "failed to withdraw");
    }

    function nextAvailableLpWithdrawDate() public view returns (uint256) {
        if (lpWithdrawRequestPending) {
            return lpWithdrawRequestTimestamp + lpWithdrawRequestDuration;
        } else {
            return 0; // 0 means no open requests
        }
    }

    function withdrawRequestedLP() external onlyOwner {
        require(
            block.timestamp >= nextAvailableLpWithdrawDate() &&
                nextAvailableLpWithdrawDate() > 0,
            "Must request and wait."
        );
        lpWithdrawRequestTimestamp = 0;
        lpWithdrawRequestPending = false;

        uint256 amtToWithdraw = (IERC20(address(DEXV2Pair)).balanceOf(
            address(this)
        ) * lpPercToWithDraw) / 100;

        lpPercToWithDraw = 0;

        IERC20(DEXV2Pair).transfer(msg.sender, amtToWithdraw);
    }
}
