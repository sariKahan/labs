// SPDX-License-Identifier: MIT
pragma solidity >=0.5.11;

import "@labs/tokens/Erc20.sol";
import "./Aave.sol";

contract Lending {

    uint public constant WAD = 1e18;
    //sum of the people borrow
    uint256 public totalBorrowed;

    //count Dai earn
    uint256 public totalReserve;

    //sum of the people get Dai
    uint256 public totalDeposit;

    //?
    uint256 public maxLTV = 4; // 1 = 20%

    //?
    uint256 public ethTreasury;

    //sum of eth that user put to coraterall
    uint256 public totalCollateral;

    //value of bond compared to eth - all bond = 0.02 eth
    uint256 public baseRate = 20000000000000000;

    // ?
    uint256 fixedAnnuBorrowrate = 300000000000000000;

    Erc20 BondToken;
    // Aave public aave;

    mapping(address => uint256) private usersCollateral;
    mapping(address => uint256) private usrsBorrowd;

    IERC20 public constant dai = IERC20(0x77FDe93fEe5fe272dC17d799cb61447431E6Eba2);
    Ipool public constant aave = Ipool(0x685b86a6659a1CbcfE168304386e1b54C543Ce16);
    IWETHGateway public constant fantomGateway = IWETHGateway(0xd2B0C9778d088Fc79C28Da719bC02158E64796bD);

    constructor() {
        BondToken = new Erc20("Bond DAI", "bDAI");
        // aave = new Aave();
    }

    function addCollateral() external payable {
        require(msg.value > 0, "the value is 0");
        usersCollateral[msg.sender] += msg.value;
        totalCollateral += msg.value;
        aave.depositFTMToAave(uint(msg.value));
        fantomGateway.depositETH{value: amount}(address(aave), address(this), 0);
    }

    

    function addDaiLiquidity(uint amount) external{
        require(amount != 0,"the amount is zero");
        dai.transferFrom(msg.sender,address(this),amount);
        totalDeposit += amount;
        uint countBond = amount * WAD / ratioBetweenDaiAndBond();
        BondToken.mint(msg.sender,countBond);
        dai.approve(address(aave), amount);
        aave.deposit(address(dai), amount, address(this), 0);
    }

    function withdrawDaiLiquiduty(uint amount) external{
        require(amount <= BondToken.balanceOf(msg.sender) ,"not enough bonds! ");
        uint countDai = amount * ratioBetweenDaiAndBond() / WAD;
        bondToken.burn(msg.sender , amount);
        totalDeposit -= countDai;
        aave.withdraw(address(dai), amount, msg.sender);
    }

    function ratioBetweenDaiAndBond(uint amount) public{
        if(BondToken.totalSupply() == 0){
            return WAD;
        }
        uint countDai = totalDeposit + totalReserve;
        return countDai * WAD / BondToken.totalSupply();
    }

}   