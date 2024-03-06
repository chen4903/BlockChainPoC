pragma solidity >=0.7.0 <0.9.0;

interface IUniswapAnchoredView {
    event AnchorPriceUpdated(
        string symbol,
        uint256 anchorPrice,
        uint256 oldTimestamp,
        uint256 newTimestamp
    );
    event PriceGuarded(string symbol, uint256 reporter, uint256 anchor);
    event PriceUpdated(string symbol, uint256 price);
    event ReporterInvalidated(address reporter);
    event UniswapWindowUpdated(
        bytes32 indexed symbolHash,
        uint256 oldTimestamp,
        uint256 newTimestamp,
        uint256 oldPrice,
        uint256 newPrice
    );

    function anchorPeriod() external view returns (uint256);

    function ethBaseUnit() external view returns (uint256);

    function expScale() external view returns (uint256);

    function getTokenConfig(uint256 i)
        external
        view
        returns (UniswapConfig.TokenConfig memory);

    function getTokenConfigByCToken(address cToken)
        external
        view
        returns (UniswapConfig.TokenConfig memory);

    function getTokenConfigBySymbol(string memory symbol)
        external
        view
        returns (UniswapConfig.TokenConfig memory);

    function getTokenConfigBySymbolHash(bytes32 symbolHash)
        external
        view
        returns (UniswapConfig.TokenConfig memory);

    function getTokenConfigByUnderlying(address underlying)
        external
        view
        returns (UniswapConfig.TokenConfig memory);

    function getUnderlyingPrice(address cToken) external view returns (uint256);

    function invalidateReporter(bytes memory message, bytes memory signature)
        external;

    function lowerBoundAnchorRatio() external view returns (uint256);

    function maxTokens() external view returns (uint256);

    function newObservations(bytes32)
        external
        view
        returns (uint256 timestamp, uint256 acc);

    function numTokens() external view returns (uint256);

    function oldObservations(bytes32)
        external
        view
        returns (uint256 timestamp, uint256 acc);

    function postPrices(
        bytes[] memory messages,
        bytes[] memory signatures,
        string[] memory symbols
    ) external;

    function price(string memory symbol) external view returns (uint256);

    function priceData() external view returns (address);

    function prices(bytes32) external view returns (uint256);

    function reporter() external view returns (address);

    function reporterInvalidated() external view returns (bool);

    function source(bytes memory message, bytes memory signature)
        external
        pure
        returns (address);

    function upperBoundAnchorRatio() external view returns (uint256);
}

interface UniswapConfig {
    struct TokenConfig {
        address cToken;
        address underlying;
        bytes32 symbolHash;
        uint256 baseUnit;
        uint8 priceSource;
        uint256 fixedPrice;
        address uniswapMarket;
        bool isUniswapReversed;
    }
}

interface IUNI {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    event DelegateChanged(
        address indexed delegator,
        address indexed fromDelegate,
        address indexed toDelegate
    );
    event DelegateVotesChanged(
        address indexed delegate,
        uint256 previousBalance,
        uint256 newBalance
    );
    event MinterChanged(address minter, address newMinter);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    function DELEGATION_TYPEHASH() external view returns (bytes32);

    function DOMAIN_TYPEHASH() external view returns (bytes32);

    function PERMIT_TYPEHASH() external view returns (bytes32);

    function allowance(address account, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 rawAmount)
        external
        returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function checkpoints(address, uint32)
        external
        view
        returns (uint32 fromBlock, uint96 votes);

    function decimals() external view returns (uint8);

    function delegate(address delegatee) external;

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function delegates(address) external view returns (address);

    function getCurrentVotes(address account) external view returns (uint96);

    function getPriorVotes(address account, uint256 blockNumber)
        external
        view
        returns (uint96);

    function minimumTimeBetweenMints() external view returns (uint32);

    function mint(address dst, uint256 rawAmount) external;

    function mintCap() external view returns (uint8);

    function minter() external view returns (address);

    function mintingAllowedAfter() external view returns (uint256);

    function name() external view returns (string memory);

    function nonces(address) external view returns (uint256);

    function numCheckpoints(address) external view returns (uint32);

    function permit(
        address owner,
        address spender,
        uint256 rawAmount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function setMinter(address minter_) external;

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transfer(address dst, uint256 rawAmount) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 rawAmount
    ) external returns (bool);
}

interface IUNIV3Pool {
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );
    event CollectProtocol(
        address indexed sender,
        address indexed recipient,
        uint128 amount0,
        uint128 amount1
    );
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );
    event Initialize(uint160 sqrtPriceX96, int24 tick);
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );
    event SetFeeProtocol(
        uint8 feeProtocol0Old,
        uint8 feeProtocol1Old,
        uint8 feeProtocol0New,
        uint8 feeProtocol1New
    );
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    function factory() external view returns (address);

    function fee() external view returns (uint24);

    function feeGrowthGlobal0X128() external view returns (uint256);

    function feeGrowthGlobal1X128() external view returns (uint256);

    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes memory data
    ) external;

    function increaseObservationCardinalityNext(
        uint16 observationCardinalityNext
    ) external;

    function initialize(uint160 sqrtPriceX96) external;

    function liquidity() external view returns (uint128);

    function maxLiquidityPerTick() external view returns (uint128);

    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes memory data
    ) external returns (uint256 amount0, uint256 amount1);

    function observations(uint256)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );

    function observe(uint32[] memory secondsAgos)
        external
        view
        returns (
            int56[] memory tickCumulatives,
            uint160[] memory secondsPerLiquidityCumulativeX128s
        );

    function positions(bytes32)
        external
        view
        returns (
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    function protocolFees()
        external
        view
        returns (uint128 token0, uint128 token1);

    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );

    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes memory data
    ) external returns (int256 amount0, int256 amount1);

    function tickBitmap(int16) external view returns (uint256);

    function tickSpacing() external view returns (int24);

    function ticks(int24)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    function token0() external view returns (address);

    function token1() external view returns (address);
}

interface IcUniToken {
    error AcceptAdminPendingAdminCheck();
    error AddReservesFactorFreshCheck(uint256 actualAddAmount);
    error BorrowCashNotAvailable();
    error BorrowComptrollerRejection(uint256 errorCode);
    error BorrowFreshnessCheck();
    error LiquidateAccrueBorrowInterestFailed(uint256 errorCode);
    error LiquidateAccrueCollateralInterestFailed(uint256 errorCode);
    error LiquidateCloseAmountIsUintMax();
    error LiquidateCloseAmountIsZero();
    error LiquidateCollateralFreshnessCheck();
    error LiquidateComptrollerRejection(uint256 errorCode);
    error LiquidateFreshnessCheck();
    error LiquidateLiquidatorIsBorrower();
    error LiquidateRepayBorrowFreshFailed(uint256 errorCode);
    error LiquidateSeizeComptrollerRejection(uint256 errorCode);
    error LiquidateSeizeLiquidatorIsBorrower();
    error MintComptrollerRejection(uint256 errorCode);
    error MintFreshnessCheck();
    error RedeemComptrollerRejection(uint256 errorCode);
    error RedeemFreshnessCheck();
    error RedeemTransferOutNotPossible();
    error ReduceReservesAdminCheck();
    error ReduceReservesCashNotAvailable();
    error ReduceReservesCashValidation();
    error ReduceReservesFreshCheck();
    error RepayBorrowComptrollerRejection(uint256 errorCode);
    error RepayBorrowFreshnessCheck();
    error SetComptrollerOwnerCheck();
    error SetInterestRateModelFreshCheck();
    error SetInterestRateModelOwnerCheck();
    error SetPendingAdminOwnerCheck();
    error SetReserveFactorAdminCheck();
    error SetReserveFactorBoundsCheck();
    error SetReserveFactorFreshCheck();
    error TransferComptrollerRejection(uint256 errorCode);
    error TransferNotAllowed();
    error TransferNotEnough();
    error TransferTooMuch();
    event AccrueInterest(
        uint256 cashPrior,
        uint256 interestAccumulated,
        uint256 borrowIndex,
        uint256 totalBorrows
    );
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    event Borrow(
        address borrower,
        uint256 borrowAmount,
        uint256 accountBorrows,
        uint256 totalBorrows
    );
    event LiquidateBorrow(
        address liquidator,
        address borrower,
        uint256 repayAmount,
        address cTokenCollateral,
        uint256 seizeTokens
    );
    event Mint(address minter, uint256 mintAmount, uint256 mintTokens);
    event NewAdmin(address oldAdmin, address newAdmin);
    event NewComptroller(address oldComptroller, address newComptroller);
    event NewMarketInterestRateModel(
        address oldInterestRateModel,
        address newInterestRateModel
    );
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);
    event NewReserveFactor(
        uint256 oldReserveFactorMantissa,
        uint256 newReserveFactorMantissa
    );
    event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);
    event RepayBorrow(
        address payer,
        address borrower,
        uint256 repayAmount,
        uint256 accountBorrows,
        uint256 totalBorrows
    );
    event ReservesAdded(
        address benefactor,
        uint256 addAmount,
        uint256 newTotalReserves
    );
    event ReservesReduced(
        address admin,
        uint256 reduceAmount,
        uint256 newTotalReserves
    );
    event Transfer(address indexed from, address indexed to, uint256 amount);

    function NO_ERROR() external view returns (uint256);

    function _acceptAdmin() external returns (uint256);

    function _addReserves(uint256 addAmount) external returns (uint256);

    function _becomeImplementation(bytes memory data) external;

    function _delegateCompLikeTo(address compLikeDelegatee) external;

    function _reduceReserves(uint256 reduceAmount) external returns (uint256);

    function _resignImplementation() external;

    function _setComptroller(address newComptroller) external returns (uint256);

    function _setInterestRateModel(address newInterestRateModel)
        external
        returns (uint256);

    function _setPendingAdmin(address newPendingAdmin)
        external
        returns (uint256);

    function _setReserveFactor(uint256 newReserveFactorMantissa)
        external
        returns (uint256);

    function accrualBlockNumber() external view returns (uint256);

    function accrueInterest() external returns (uint256);

    function admin() external view returns (address);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);

    function balanceOfUnderlying(address owner) external returns (uint256);

    function borrow(uint256 borrowAmount) external returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);

    function borrowBalanceStored(address account)
        external
        view
        returns (uint256);

    function borrowIndex() external view returns (uint256);

    function borrowRatePerBlock() external view returns (uint256);

    function comptroller() external view returns (address);

    function decimals() external view returns (uint8);

    function exchangeRateCurrent() external returns (uint256);

    function exchangeRateStored() external view returns (uint256);

    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );

    function getCash() external view returns (uint256);

    function implementation() external view returns (address);

    function initialize(
        address underlying_,
        address comptroller_,
        address interestRateModel_,
        uint256 initialExchangeRateMantissa_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) external;

    function initialize(
        address comptroller_,
        address interestRateModel_,
        uint256 initialExchangeRateMantissa_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) external;

    function interestRateModel() external view returns (address);

    function isCToken() external view returns (bool);

    function liquidateBorrow(
        address borrower,
        uint256 repayAmount,
        address cTokenCollateral
    ) external returns (uint256);

    function mint(uint256 mintAmount) external returns (uint256);

    function name() external view returns (string memory);

    function pendingAdmin() external view returns (address);

    function protocolSeizeShareMantissa() external view returns (uint256);

    function redeem(uint256 redeemTokens) external returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function repayBorrow(uint256 repayAmount) external returns (uint256);

    function repayBorrowBehalf(address borrower, uint256 repayAmount)
        external
        returns (uint256);

    function reserveFactorMantissa() external view returns (uint256);

    function seize(
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);

    function supplyRatePerBlock() external view returns (uint256);

    function sweepToken(address token) external;

    function symbol() external view returns (string memory);

    function totalBorrows() external view returns (uint256);

    function totalBorrowsCurrent() external returns (uint256);

    function totalReserves() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function transfer(address dst, uint256 amount) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool);

    function underlying() external view returns (address);
}

interface IComptroller {
    event ActionPaused(string action, bool pauseState);
    event ActionPaused(address cToken, string action, bool pauseState);
    event CompAccruedAdjusted(
        address indexed user,
        uint256 oldCompAccrued,
        uint256 newCompAccrued
    );
    event CompBorrowSpeedUpdated(address indexed cToken, uint256 newSpeed);
    event CompGranted(address recipient, uint256 amount);
    event CompReceivableUpdated(
        address indexed user,
        uint256 oldCompReceivable,
        uint256 newCompReceivable
    );
    event CompSupplySpeedUpdated(address indexed cToken, uint256 newSpeed);
    event ContributorCompSpeedUpdated(
        address indexed contributor,
        uint256 newSpeed
    );
    event DistributedBorrowerComp(
        address indexed cToken,
        address indexed borrower,
        uint256 compDelta,
        uint256 compBorrowIndex
    );
    event DistributedSupplierComp(
        address indexed cToken,
        address indexed supplier,
        uint256 compDelta,
        uint256 compSupplyIndex
    );
    event Failure(uint256 error, uint256 info, uint256 detail);
    event MarketEntered(address cToken, address account);
    event MarketExited(address cToken, address account);
    event MarketListed(address cToken);
    event NewBorrowCap(address indexed cToken, uint256 newBorrowCap);
    event NewBorrowCapGuardian(
        address oldBorrowCapGuardian,
        address newBorrowCapGuardian
    );
    event NewCloseFactor(
        uint256 oldCloseFactorMantissa,
        uint256 newCloseFactorMantissa
    );
    event NewCollateralFactor(
        address cToken,
        uint256 oldCollateralFactorMantissa,
        uint256 newCollateralFactorMantissa
    );
    event NewLiquidationIncentive(
        uint256 oldLiquidationIncentiveMantissa,
        uint256 newLiquidationIncentiveMantissa
    );
    event NewPauseGuardian(address oldPauseGuardian, address newPauseGuardian);
    event NewPriceOracle(address oldPriceOracle, address newPriceOracle);

    function _become(address unitroller) external;

    function _borrowGuardianPaused() external view returns (bool);

    function _grantComp(address recipient, uint256 amount) external;

    function _mintGuardianPaused() external view returns (bool);

    function _setBorrowCapGuardian(address newBorrowCapGuardian) external;

    function _setBorrowPaused(address cToken, bool state)
        external
        returns (bool);

    function _setCloseFactor(uint256 newCloseFactorMantissa)
        external
        returns (uint256);

    function _setCollateralFactor(
        address cToken,
        uint256 newCollateralFactorMantissa
    ) external returns (uint256);

    function _setCompSpeeds(
        address[] memory cTokens,
        uint256[] memory supplySpeeds,
        uint256[] memory borrowSpeeds
    ) external;

    function _setContributorCompSpeed(address contributor, uint256 compSpeed)
        external;

    function _setLiquidationIncentive(uint256 newLiquidationIncentiveMantissa)
        external
        returns (uint256);

    function _setMarketBorrowCaps(
        address[] memory cTokens,
        uint256[] memory newBorrowCaps
    ) external;

    function _setMintPaused(address cToken, bool state) external returns (bool);

    function _setPauseGuardian(address newPauseGuardian)
        external
        returns (uint256);

    function _setPriceOracle(address newOracle) external returns (uint256);

    function _setSeizePaused(bool state) external returns (bool);

    function _setTransferPaused(bool state) external returns (bool);

    function _supportMarket(address cToken) external returns (uint256);

    function accountAssets(address, uint256) external view returns (address);

    function admin() external view returns (address);

    function allMarkets(uint256) external view returns (address);

    function borrowAllowed(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external returns (uint256);

    function borrowCapGuardian() external view returns (address);

    function borrowCaps(address) external view returns (uint256);

    function borrowGuardianPaused(address) external view returns (bool);

    function borrowVerify(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external;

    function checkMembership(address account, address cToken)
        external
        view
        returns (bool);

    function claimComp(address holder, address[] memory cTokens) external;

    function claimComp(
        address[] memory holders,
        address[] memory cTokens,
        bool borrowers,
        bool suppliers
    ) external;

    function claimComp(address holder) external;

    function closeFactorMantissa() external view returns (uint256);

    function compAccrued(address) external view returns (uint256);

    function compBorrowSpeeds(address) external view returns (uint256);

    function compBorrowState(address)
        external
        view
        returns (uint224 index, uint32 block);

    function compBorrowerIndex(address, address)
        external
        view
        returns (uint256);

    function compContributorSpeeds(address) external view returns (uint256);

    function compInitialIndex() external view returns (uint224);

    function compRate() external view returns (uint256);

    function compReceivable(address) external view returns (uint256);

    function compSpeeds(address) external view returns (uint256);

    function compSupplierIndex(address, address)
        external
        view
        returns (uint256);

    function compSupplySpeeds(address) external view returns (uint256);

    function compSupplyState(address)
        external
        view
        returns (uint224 index, uint32 block);

    function comptrollerImplementation() external view returns (address);

    function enterMarkets(address[] memory cTokens)
        external
        returns (uint256[] memory);

    function exitMarket(address cTokenAddress) external returns (uint256);

    function fixBadAccruals(
        address[] memory affectedUsers,
        uint256[] memory amounts
    ) external;

    function getAccountLiquidity(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function getAllMarkets() external view returns (address[] memory);

    function getAssetsIn(address account)
        external
        view
        returns (address[] memory);

    function getBlockNumber() external view returns (uint256);

    function getCompAddress() external view returns (address);

    function getHypotheticalAccountLiquidity(
        address account,
        address cTokenModify,
        uint256 redeemTokens,
        uint256 borrowAmount
    )
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function isComptroller() external view returns (bool);

    function isDeprecated(address cToken) external view returns (bool);

    function lastContributorBlock(address) external view returns (uint256);

    function liquidateBorrowAllowed(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);

    function liquidateBorrowVerify(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 actualRepayAmount,
        uint256 seizeTokens
    ) external;

    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint256 actualRepayAmount
    ) external view returns (uint256, uint256);

    function liquidationIncentiveMantissa() external view returns (uint256);

    function markets(address)
        external
        view
        returns (
            bool isListed,
            uint256 collateralFactorMantissa,
            bool isComped
        );

    function maxAssets() external view returns (uint256);

    function mintAllowed(
        address cToken,
        address minter,
        uint256 mintAmount
    ) external returns (uint256);

    function mintGuardianPaused(address) external view returns (bool);

    function mintVerify(
        address cToken,
        address minter,
        uint256 actualMintAmount,
        uint256 mintTokens
    ) external;

    function oracle() external view returns (address);

    function pauseGuardian() external view returns (address);

    function pendingAdmin() external view returns (address);

    function pendingComptrollerImplementation() external view returns (address);

    function proposal65FixExecuted() external view returns (bool);

    function redeemAllowed(
        address cToken,
        address redeemer,
        uint256 redeemTokens
    ) external returns (uint256);

    function redeemVerify(
        address cToken,
        address redeemer,
        uint256 redeemAmount,
        uint256 redeemTokens
    ) external;

    function repayBorrowAllowed(
        address cToken,
        address payer,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);

    function repayBorrowVerify(
        address cToken,
        address payer,
        address borrower,
        uint256 actualRepayAmount,
        uint256 borrowerIndex
    ) external;

    function seizeAllowed(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);

    function seizeGuardianPaused() external view returns (bool);

    function seizeVerify(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external;

    function transferAllowed(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external returns (uint256);

    function transferGuardianPaused() external view returns (bool);

    function transferVerify(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external;

    function updateContributorRewards(address contributor) external;
}

interface ICompoundcUSDC {
    function name() external view returns (string memory);

    function approve(address spender, uint256 amount) external returns (bool);

    function repayBorrow(uint256 repayAmount) external returns (uint256);

    function reserveFactorMantissa() external view returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);

    function totalSupply() external view returns (uint256);

    function exchangeRateStored() external view returns (uint256);

    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool);

    function repayBorrowBehalf(address borrower, uint256 repayAmount)
        external
        returns (uint256);

    function pendingAdmin() external view returns (address);

    function decimals() external view returns (uint256);

    function balanceOfUnderlying(address owner) external returns (uint256);

    function getCash() external view returns (uint256);

    function _setComptroller(address newComptroller) external returns (uint256);

    function totalBorrows() external view returns (uint256);

    function comptroller() external view returns (address);

    function _reduceReserves(uint256 reduceAmount) external returns (uint256);

    function initialExchangeRateMantissa() external view returns (uint256);

    function accrualBlockNumber() external view returns (uint256);

    function underlying() external view returns (address);

    function balanceOf(address owner) external view returns (uint256);

    function totalBorrowsCurrent() external returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function totalReserves() external view returns (uint256);

    function symbol() external view returns (string memory);

    function borrowBalanceStored(address account)
        external
        view
        returns (uint256);

    function mint(uint256 mintAmount) external returns (uint256);

    function accrueInterest() external returns (uint256);

    function transfer(address dst, uint256 amount) external returns (bool);

    function borrowIndex() external view returns (uint256);

    function supplyRatePerBlock() external view returns (uint256);

    function seize(
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);

    function _setPendingAdmin(address newPendingAdmin)
        external
        returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );

    function borrow(uint256 borrowAmount) external returns (uint256);

    function redeem(uint256 redeemTokens) external returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function _acceptAdmin() external returns (uint256);

    function _setInterestRateModel(address newInterestRateModel)
        external
        returns (uint256);

    function interestRateModel() external view returns (address);

    function liquidateBorrow(
        address borrower,
        uint256 repayAmount,
        address cTokenCollateral
    ) external returns (uint256);

    function admin() external view returns (address);

    function borrowRatePerBlock() external view returns (uint256);

    function _setReserveFactor(uint256 newReserveFactorMantissa)
        external
        returns (uint256);

    function isCToken() external view returns (bool);

    event AccrueInterest(
        uint256 interestAccumulated,
        uint256 borrowIndex,
        uint256 totalBorrows
    );
    event Mint(address minter, uint256 mintAmount, uint256 mintTokens);
    event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);
    event Borrow(
        address borrower,
        uint256 borrowAmount,
        uint256 accountBorrows,
        uint256 totalBorrows
    );
    event RepayBorrow(
        address payer,
        address borrower,
        uint256 repayAmount,
        uint256 accountBorrows,
        uint256 totalBorrows
    );
    event LiquidateBorrow(
        address liquidator,
        address borrower,
        uint256 repayAmount,
        address cTokenCollateral,
        uint256 seizeTokens
    );
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);
    event NewAdmin(address oldAdmin, address newAdmin);
    event NewComptroller(address oldComptroller, address newComptroller);
    event NewMarketInterestRateModel(
        address oldInterestRateModel,
        address newInterestRateModel
    );
    event NewReserveFactor(
        uint256 oldReserveFactorMantissa,
        uint256 newReserveFactorMantissa
    );
    event ReservesReduced(
        address admin,
        uint256 reduceAmount,
        uint256 newTotalReserves
    );
    event Failure(uint256 error, uint256 info, uint256 detail);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
}

interface IVault {
    struct BatchSwapStep {
        bytes32 poolId;
        uint256 assetInIndex;
        uint256 assetOutIndex;
        uint256 amount;
        bytes userData;
    }

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address recipient;
        bool toInternalBalance;
    }

    struct ExitPoolRequest {
        address[] assets;
        uint256[] minAmountsOut;
        bytes userData;
        bool toInternalBalance;
    }

    struct JoinPoolRequest {
        address[] assets;
        uint256[] maxAmountsIn;
        bytes userData;
        bool fromInternalBalance;
    }

    struct PoolBalanceOp {
        uint8 kind;
        bytes32 poolId;
        address token;
        uint256 amount;
    }

    struct UserBalanceOp {
        uint8 kind;
        address asset;
        uint256 amount;
        address sender;
        address recipient;
    }

    struct SingleSwap {
        bytes32 poolId;
        uint8 kind;
        address assetIn;
        address assetOut;
        uint256 amount;
        bytes userData;
    }
}

interface IUSDT {
    function approve(address _spender, uint256 _value) external;

    function balanceOf(address owner) external view returns (uint256);

    function transfer(address _to, uint256 _value) external;
}

interface ICEXISWAP {
    function initialize(
        string memory name,
        string memory ticker,
        address _treasuryWallet,
        address _communityWallet,
        address _admin,
        address _strategy
    ) external;

    function upgradeToAndCall(
        address newImplementation,
        bytes memory data
    ) external payable;
}

interface IDEXRouter {
    function update(
        address fcb,
        address bnb,
        address busd,
        address router
    ) external;

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) external;
}

interface IBalancerVault {
    enum SwapKind {
        GIVEN_IN,
        GIVEN_OUT
    }

    struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        address assetIn;
        address assetOut;
        uint256 amount;
        bytes userData;
    }

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }

    function swap(
        SingleSwap memory singleSwap,
        FundManagement memory funds,
        uint256 limit,
        uint256 deadline
    ) external payable returns (uint256 amountCalculated);

    struct BatchSwapStep {
        bytes32 poolId;
        uint256 assetInIndex;
        uint256 assetOutIndex;
        uint256 amount;
        bytes userData;
    }

    function batchSwap(
        SwapKind kind,
        BatchSwapStep[] memory swaps,
        address[] memory assets,
        FundManagement memory funds,
        int256[] memory limits,
        uint256 deadline
    ) external;

    struct JoinPoolRequest {
        address[] asset;
        uint256[] maxAmountsIn;
        bytes userData;
        bool fromInternalBalance;
    }

    struct ExitPoolRequest {
        address[] asset;
        uint256[] minAmountsOut;
        bytes userData;
        bool toInternalBalance;
    }

    function joinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        JoinPoolRequest memory request
    ) external payable;

    function exitPool(
        bytes32 poolId,
        address sender,
        address payable recipient,
        ExitPoolRequest memory request
    ) external payable;

    function flashLoan(
        address recipient,
        address[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external;

    function getPoolTokens(bytes32 poolId)
        external
        view
        returns (IERC20[] memory tokens, uint256[] memory balances, uint256 lastChangeBlock);
}

interface IDPPOracle {
    function flashLoan(uint256 baseAmount, uint256 quoteAmount, address _assetTo, bytes calldata data) external;
}

interface IUniswapV2Pair {
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IUniswapV2Router {
    function WETH() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function factory() external view returns (address);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountsIn(uint256 amountOut, address[] memory path) external view returns (uint256[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] memory path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external;

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    receive() external payable;
}

interface IERC20 {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function allowance(address owner, address spender)
  external
  view
  returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);
  function withdraw(uint256 wad) external;
  function deposit(uint256 wad) external returns (bool);
  function owner() external view returns (address);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

interface IWETH is IERC20Metadata {
    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    receive() external payable;
    fallback() external payable;
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}

interface IProxyFactory {
    function createProxy(address masterCopy, bytes calldata data) external returns (address payable proxy);
}

interface IStorageContract {
    function withdraw(address from, address to, uint256 amount) external;
}

interface IGetFlashloan {
    function flashLoan(uint256 baseAmount, uint256 quoteAmount, address assetTo, bytes calldata data) external;
    function _BASE_TOKEN_() external view returns (address);
}

interface IUni_Router_V2 {
    function WETH() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function factory() external view returns (address);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountsIn(uint256 amountOut, address[] memory path) external view returns (uint256[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] memory path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) external;

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] memory path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    // receive () external payable;
}

interface IUni_Pair_V2 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function MINIMUM_LIQUIDITY() external view returns (uint256);

    function PERMIT_TYPEHASH() external view returns (bytes32);

    function allowance(address, address) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function balanceOf(address) external view returns (uint256);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function decimals() external view returns (uint8);

    function factory() external view returns (address);

    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);

    function initialize(address _token0, address _token1) external;

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function name() external view returns (string memory);

    function nonces(address) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function skim(address to) external;

    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes memory data) external;

    function symbol() external view returns (string memory);

    function sync() external;

    function token0() external view returns (address);

    function token1() external view returns (address);

    function totalSupply() external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface IDVM{
  // 没有returns(bool)!!!!!!!!!!!!!!!!!!!!!!
  function flashLoan(uint256,uint256,address,bytes memory) external;
}

interface IQuixotic {
    function fillSellOrder(
        address seller,
        address contractAddress,
        uint256 tokenId,
        uint256 startTime,
        uint256 expiration,
        uint256 price,
        uint256 quantity,
        uint256 createdAtBlockNumber,
        address paymentERC20,
        bytes memory signature,
        address buyer
    ) external payable;
}

interface IMEVBOT{
  function pancakeCall(address, uint256, uint256, bytes memory) external;
}

interface IWBNB{
    function balanceOf(address) external view returns (uint256);
}
interface IBUSD{
    function balanceOf(address) external view returns (uint256);
}
interface IUSDC{
    function balanceOf(address) external view returns (uint256);
}
interface IBTCB{
    function balanceOf(address) external view returns (uint256);
}
interface IETH{
    function balanceOf(address) external view returns (uint256);
}

interface IOHM{
  function balanceOf(address) external view returns (uint256);
}

interface IBondFixedExpiryTeller{
  function redeem(address, uint256) external;
}




interface CheatCodes {
  // This allows us to getRecordedLogs()
  struct Log {bytes32[] topics; bytes data;}
  // Set block.timestamp (newTimestamp)
  function warp(uint256) external;
  // Set block.height (newHeight)
  function roll(uint256) external;
  // Set block.basefee (newBasefee)
  function fee(uint256) external;
  // Set block.coinbase (who)
  function coinbase(address) external;
  // Loads a storage slot from an address (who, slot)
  function load(address,bytes32) external returns (bytes32);
  // Stores a value to an address' storage slot, (who, slot, value)
  function store(address,bytes32,bytes32) external;
  // Signs data, (privateKey, digest) => (v, r, s)
  function sign(uint256,bytes32) external returns (uint8,bytes32,bytes32);
  // Gets address for a given private key, (privateKey) => (address)
  function addr(uint256) external returns (address);
  // Derive a private key from a provided mnenomic string (or mnenomic file path) at the derivation path m/44'/60'/0'/0/{index}
  function deriveKey(string calldata, uint32) external returns (uint256);
  // Derive a private key from a provided mnenomic string (or mnenomic file path) at the derivation path {path}{index}
  function deriveKey(string calldata, string calldata, uint32) external returns (uint256);
  // Performs a foreign function call via terminal, (stringInputs) => (result)
  function ffi(string[] calldata) external returns (bytes memory);
  // Set environment variables, (name, value)
  function setEnv(string calldata, string calldata) external;
  // Read environment variables, (name) => (value)
  function envBool(string calldata) external returns (bool);
  function envUint(string calldata) external returns (uint256);
  function envInt(string calldata) external returns (int256);
  function envAddress(string calldata) external returns (address);
  function envBytes32(string calldata) external returns (bytes32);
  function envString(string calldata) external returns (string memory);
  function envBytes(string calldata) external returns (bytes memory);
  // Read environment variables as arrays, (name, delim) => (value[])
  function envBool(string calldata, string calldata) external returns (bool[] memory);
  function envUint(string calldata, string calldata) external returns (uint256[] memory);
  function envInt(string calldata, string calldata) external returns (int256[] memory);
  function envAddress(string calldata, string calldata) external returns (address[] memory);
  function envBytes32(string calldata, string calldata) external returns (bytes32[] memory);
  function envString(string calldata, string calldata) external returns (string[] memory);
  function envBytes(string calldata, string calldata) external returns (bytes[] memory);
  // Sets the *next* call's msg.sender to be the input address
  function prank(address) external;
  // Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called
  function startPrank(address) external;
  // Sets the *next* call's msg.sender to be the input address, and the tx.origin to be the second input
  function prank(address,address) external;
  // Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called, and the tx.origin to be the second input
  function startPrank(address,address) external;
  // Resets subsequent calls' msg.sender to be `address(this)`
  function stopPrank() external;
  // Sets an address' balance, (who, newBalance)
  function deal(address, uint256) external;
  // Sets an address' code, (who, newCode)
  function etch(address, bytes calldata) external;
  // Expects an error on next call
  function expectRevert() external;
  function expectRevert(bytes calldata) external;
  function expectRevert(bytes4) external;
  // Record all storage reads and writes
  function record() external;
  // Gets all accessed reads and write slot from a recording session, for a given address
  function accesses(address) external returns (bytes32[] memory reads, bytes32[] memory writes);
  // Record all the transaction logs
  function recordLogs() external;
  // Gets all the recorded logs
  function getRecordedLogs() external returns (Log[] memory);
  // Prepare an expected log with (bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData).
  // Call this function, then emit an event, then call a function. Internally after the call, we check if
  // logs were emitted in the expected order with the expected topics and data (as specified by the booleans).
  // Second form also checks supplied address against emitting contract.
  function expectEmit(bool,bool,bool,bool) external;
  function expectEmit(bool,bool,bool,bool,address) external;
  // Mocks a call to an address, returning specified data.
  // Calldata can either be strict or a partial match, e.g. if you only
  // pass a Solidity selector to the expected calldata, then the entire Solidity
  // function will be mocked.
  function mockCall(address,bytes calldata,bytes calldata) external;
  // Mocks a call to an address with a specific msg.value, returning specified data.
  // Calldata match takes precedence over msg.value in case of ambiguity.
  function mockCall(address,uint256,bytes calldata,bytes calldata) external;
  // Clears all mocked calls
  function clearMockedCalls() external;
  // Expect a call to an address with the specified calldata.
  // Calldata can either be strict or a partial match
  function expectCall(address,bytes calldata) external;
  // Expect a call to an address with the specified msg.value and calldata
  function expectCall(address,uint256,bytes calldata) external;
  // Gets the code from an artifact file. Takes in the relative path to the json file
  function getCode(string calldata) external returns (bytes memory);
  // Labels an address in call traces
  function label(address, string calldata) external;
  // If the condition is false, discard this run's fuzz inputs and generate new ones
  function assume(bool) external;
  // Set nonce for an account
  function setNonce(address,uint64) external;
  // Get nonce for an account
  function getNonce(address) external returns(uint64);
  // Set block.chainid (newChainId)
  function chainId(uint256) external;
  // Using the address that calls the test contract, has the next call (at this call depth only) create a transaction that can later be signed and sent onchain
  function broadcast() external;
  // Has the next call (at this call depth only) create a transaction with the address provided as the sender that can later be signed and sent onchain
  function broadcast(address) external;
  // Using the address that calls the test contract, has the all subsequent calls (at this call depth only) create transactions that can later be signed and sent onchain
  function startBroadcast() external;
  // Has the all subsequent calls (at this call depth only) create transactions that can later be signed and sent onchain
  function startBroadcast(address) external;
  // Stops collecting onchain transactions
  function stopBroadcast() external;
  // Reads the entire content of file to string. Path is relative to the project root. (path) => (data)
  function readFile(string calldata) external returns (string memory);
  // Reads next line of file to string, (path) => (line)
  function readLine(string calldata) external returns (string memory);
  // Writes data to file, creating a file if it does not exist, and entirely replacing its contents if it does.
  // Path is relative to the project root. (path, data) => ()
  function writeFile(string calldata, string calldata) external;
  // Writes line to file, creating a file if it does not exist.
  // Path is relative to the project root. (path, data) => ()
  function writeLine(string calldata, string calldata) external;
  // Closes file for reading, resetting the offset and allowing to read it from beginning with readLine.
  // Path is relative to the project root. (path) => ()
  function closeFile(string calldata) external;
  // Removes file. This cheatcode will revert in the following situations, but is not limited to just these cases:
  // - Path points to a directory.
  // - The file doesn't exist.
  // - The user lacks permissions to remove the file.
  // Path is relative to the project root. (path) => ()
  function removeFile(string calldata) external;

  function toString(address)        external returns(string memory);
  function toString(bytes calldata) external returns(string memory);
  function toString(bytes32)        external returns(string memory);
  function toString(bool)           external returns(string memory);
  function toString(uint256)        external returns(string memory);
  function toString(int256)         external returns(string memory);
  // Snapshot the current state of the evm.
  // Returns the id of the snapshot that was created.
  // To revert a snapshot use `revertTo`
  function snapshot() external returns(uint256);
  // Revert the state of the evm to a previous snapshot
  // Takes the snapshot id to revert to.
  // This deletes the snapshot and all snapshots taken after the given snapshot id.
  function revertTo(uint256) external returns(bool);
  // Creates a new fork with the given endpoint and block and returns the identifier of the fork
  function createFork(string calldata,uint256) external returns(uint256);
  // Creates a new fork with the given endpoint and the _latest_ block and returns the identifier of the fork
  function createFork(string calldata) external returns(uint256);
  // Creates _and_ also selects a new fork with the given endpoint and block and returns the identifier of the fork
  function createSelectFork(string calldata,uint256) external returns(uint256);
  // Creates _and_ also selects a new fork with the given endpoint and the latest block and returns the identifier of the fork
  function createSelectFork(string calldata) external returns(uint256);
  // Takes a fork identifier created by `createFork` and sets the corresponding forked state as active.
  function selectFork(uint256) external;
  /// Returns the currently active fork
  /// Reverts if no fork is currently active
  function activeFork() external returns(uint256);
  // Updates the currently active fork to given block number
  // This is similar to `roll` but for the currently active fork
  function rollFork(uint256) external;
  // Updates the given fork to given block number
  function rollFork(uint256 forkId, uint256 blockNumber) external;
  /// Returns the RPC url for the given alias
  function rpcUrl(string calldata) external returns(string memory);
  /// Returns all rpc urls and their aliases `[alias, url][]`
  function rpcUrls() external returns(string[2][] memory);
}
interface Curve{
    function flash(address recipient, uint256 amount0, uint256 amount1, bytes calldata data) external;
    function viewDeposit(uint256 _deposit) external view returns (uint256, uint256[] memory);
    function deposit(uint256 _deposit, uint256 _deadline) external returns (uint256, uint256[] memory);
    function withdraw(uint256 _curvesToBurn, uint256 _deadline) external;
}
interface Uni_Router_V3 {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to
    ) external payable returns (uint256 amountOut);

    function exactInputSingle(
        ExactInputSingleParams memory params
    ) external payable returns (uint256 amountOut);

    function exactOutputSingle(
        ExactOutputSingleParams calldata params
        ) external payable returns (uint256 amountIn);
}

interface IEGDFinance{
  function claimAllReward() external;
  function bond(address) external;
  function stake(uint) external;
  function getEGDPrice() external returns(uint256);
}



interface IPancakePair {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function name() external pure returns (string memory);

  function symbol() external pure returns (string memory);

  function decimals() external pure returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function allowance(address owner, address spender)
  external
  view
  returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function PERMIT_TYPEHASH() external pure returns (bytes32);

  function nonces(address owner) external view returns (uint256);

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  event Mint(address indexed sender, uint256 amount0, uint256 amount1);
  event Burn(
    address indexed sender,
    uint256 amount0,
    uint256 amount1,
    address indexed to
  );
  event Swap(
    address indexed sender,
    uint256 amount0In,
    uint256 amount1In,
    uint256 amount0Out,
    uint256 amount1Out,
    address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint256);

  function factory() external view returns (address);

  function token0() external view returns (address);

  function token1() external view returns (address);

  function getReserves()
  external
  view
  returns (
    uint112 reserve0,
    uint112 reserve1,
    uint32 blockTimestampLast
  );

  function price0CumulativeLast() external view returns (uint256);

  function price1CumulativeLast() external view returns (uint256);

  function kLast() external view returns (uint256);

  function mint(address to) external returns (uint256 liquidity);

  function burn(address to) external returns (uint256 amount0, uint256 amount1);

  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;

  function skim(address to) external;

  function sync() external;

  function initialize(address, address) external;
}

interface IPancakeRouter {
  function WETH() external view returns (address);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
  external
  returns (
    uint256 amountA,
    uint256 amountB,
    uint256 liquidity
  );

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

  function factory() external view returns (address);

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountIn);

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountOut);

  function getAmountsIn(uint256 amountOut, address[] memory path)
  external
  view
  returns (uint256[] memory amounts);

  function getAmountsOut(uint256 amountIn, address[] memory path)
  external
  view
  returns (uint256[] memory amounts);

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) external pure returns (uint256 amountB);

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountToken, uint256 amountETH);

  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountETH);

  function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountToken, uint256 amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountETH);

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountA, uint256 amountB);

  function swapETHForExactTokens(
    uint256 amountOut,
    address[] memory path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] memory path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] memory path,
    address to,
    uint256 deadline
  ) external payable;

  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] memory path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] memory path,
    address to,
    uint256 deadline
  ) external;

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] memory path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] memory path,
    address to,
    uint256 deadline
  ) external;

  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] memory path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] memory path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory);

  receive() external payable;
}

interface ICirculateBUSD{
    function startTrading(address, uint256, address) external;
}
interface IBUSDC {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function _decimals() external view returns (uint8);

    function _name() external view returns (string memory);

    function _symbol() external view returns (string memory);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function burn(uint256 amount) external returns (bool);

    function decimals() external view returns (uint8);

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool);

    function getOwner() external view returns (address);

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool);

    function mint(uint256 amount) external returns (bool);

    function name() external view returns (string memory);

    function owner() external view returns (address);

    function renounceOwnership() external;

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transferOwnership(address newOwner) external;
}

interface IBSCUSD {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function _decimals() external view returns (uint8);

    function _name() external view returns (string memory);

    function _symbol() external view returns (string memory);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function burn(uint256 amount) external returns (bool);

    function decimals() external view returns (uint8);

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool);

    function getOwner() external view returns (address);

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool);

    function mint(uint256 amount) external returns (bool);

    function name() external view returns (string memory);

    function owner() external view returns (address);

    function renounceOwnership() external;

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transferOwnership(address newOwner) external;
}


interface MEVBot{
    function pancakeCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

interface IEGD_Finance {
    function bond(address invitor) external;
    function stake(uint256 amount) external;
    function calculateAll(address addr) external view returns (uint256);
    function claimAllReward() external;
    function getEGDPrice() external view returns (uint256);
}
