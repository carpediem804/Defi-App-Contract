//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./interfaces/IFactory.sol";
import "./interfaces/IExchange.sol";
contract Exchange is ERC20 {

    IERC20 token;
    IFactory factory;

    constructor (address _token) ERC20("Taehong Uniswap V2","TS-V2"){
        //name_ 과 symbol  겹처도 상관없다 
        token = IERC20(_token);

        // factory추가 
        factory = IFactory(msg.sender);
    }

    function addLiquidity(uint256 _maxTokens) public payable{
       // parameter는 frontend 슬리피지 포함된 값 
       uint256 totalLiquidity = totalSupply();
       if(totalLiquidity > 0){
        //유동성 있을 때 
        uint256 ethReserve = address(this).balance - msg.value;
        uint256 tokenReserve = token.balanceOf(address(this));

        uint256 tokenAmount = msg.value * tokenReserve / ethReserve;
        require(_maxTokens >= tokenAmount);
        token.transferFrom(msg.sender, address(this), tokenAmount);
        //내가 가지고 있는 토큰을 , 이 컨트렉트 주소가, amount만큼 가져간다.
        uint256 liqudityMinted = totalLiquidity * msg.value/ethReserve;

        _mint(msg.sender, liqudityMinted);//이게 LP토큰이다

       }else{
        //유동성이 없을때 처음 넣는거 
        uint256 tokenAmount = _maxTokens;
        uint256 initalLiquidity = address(this).balance; // 공급 입력한 초기 이더리움 개수 이미 넘어왔으니 
        _mint(msg.sender, initalLiquidity); //이게 LP토큰이다
        token.transferFrom(msg.sender, address(this), tokenAmount);
        //내가 가지고 있는 토큰을 , 이 컨트렉트 주소가, amount만큼 가져간다
       }
    }

    function removeLiquidity(uint256 _lpTokenAmount) public {
        uint256 totalLiqudity = totalSupply();
        uint256 ethAmount = _lpTokenAmount * address(this).balance/totalLiqudity;
        uint256 tokenAmount = _lpTokenAmount * token.balanceOf(address(this)) / totalLiqudity;
        //msg.sender 는 요청한 사람 
        _burn(msg.sender,_lpTokenAmount);
        payable(msg.sender).transfer(ethAmount);
        token.transfer(msg.sender, tokenAmount);
    }

    // function addLiquidity(uint256 _tokenAmount) public payable{
    //     // 유동성 공급을 할때 contract에서 토큰을 받기위해선 payable필요
    //     token.transferFrom(msg.sender, address(this), _tokenAmount);
    //     //내가 가지고 있는 토큰을 , 이 컨트렉트 주소가, amount만큼 가져간다
    // }

    //유통성 제거 
    //exchange contract 에 들어있는 eth를 나에게 전송한다 
    //exchange contract가 가지고 있는 erc20을 나에게 전송 

    //swap 
    //eth -> erc20
    function ethToTokenSwap(uint256 _minTokens) public payable{
        //_minTokens 프론트에서 입력한 값 
        // 슬리피지 그거 임 
        // uint256 outputAmount = getOutputAmountWithFee(msg.value,address(this).balance - msg.value,token.balanceOf(address(this)));

        // require(outputAmount >= _minTokens , "Inffucient outputAmount");
        // // 빼는 이유는 payable인 함수이면 이더리움이 넘어온 상태라서 address(this).balance에 이미 추가 되어 있다.  
        // IERC20(token).transfer(msg.sender, outputAmount);
        ethToToken(_minTokens,msg.sender);
    }

    function ethToTokenTransfer(uint256 _minTokens,address _receiver) public payable{
        ethToToken(_minTokens,_receiver);
    }

    function ethToToken(uint256 _minTokens,address _receiver) private {
       
        uint256 outputAmount = getOutputAmountWithFee(msg.value,address(this).balance - msg.value,token.balanceOf(address(this)));

        require(outputAmount >= _minTokens , "Inffucient outputAmount");
      
        IERC20(token).transfer(_receiver, outputAmount);

    }

     // erc20->eth 
    function tokenToEthSwap(uint256 _tokenSold, uint256 _minEth) public payable{
        // 몇개의 토큰을 판매하고 몇개의 토큰을 얻을수 있는지 
         //_minTokens 프론트에서 입력한 값 
        // 슬리피지 그거 임 
       
        uint256 outputAmount = getOutputAmountWithFee(_tokenSold,token.balanceOf(address(this)),address(this).balance);
        //계산하고 
        require(outputAmount >= _minEth , "Inffucient outputAmount");

        // 요청 사람주소에서 token을 나한테 전송하고 
        IERC20(token).transferFrom(msg.sender, address(this), _tokenSold);
        // 요청 사람에게 eth 전송 
        payable(msg.sender).transfer(outputAmount);

    }

     // erc20->eth->erc20 
    function tokenToTokenSwap(uint256 _tokenSold, uint256 _minTokenBought, address _tokenAddress) public payable{
        
        //min token bought => swap 시 erc20의 최소 개수 프론트에서 입력 

        address toTokenExchangeAddress = factory.getExchangeAddress(_tokenAddress);  
       
        //스왑할때 사용할 eth의 개수 
        uint256 ethOutputAmount = getOutputAmountWithFee(_tokenSold,token.balanceOf(address(this)),address(this).balance);
        //계산하고 
        
        require(ethOutputAmount >= _minTokenBought , "Inffucient outputAmount");

        // 요청 사람주소에서 token을 나한테 전송하고 
        IERC20(token).transferFrom(msg.sender, address(this), _tokenSold);
        
        //새로운 인터페이스 정의 후 swap 
        IExchange(toTokenExchangeAddress).ethToTokenTransfer{value:ethOutputAmount}(_minTokenBought,msg.sender);
    


    }

    function getPrice(uint256 inputReserve, uint256 outputReserve) public pure returns (uint256){
        uint256 numerator = inputReserve;
        uint256 denominator = outputReserve;
        return numerator/denominator;
    }

    function getOutputAmount(uint256 inputAmount,uint256 inputReserve, uint256 outputReserve ) public pure returns(uint256){
        uint256 numerator = outputReserve * inputAmount;
        uint256 denominator = inputReserve + inputAmount;
        return numerator/denominator;
    }

    function getOutputAmountWithFee(uint256 inputAmount,uint256 inputReserve, uint256 outputReserve ) public pure returns(uint256){
        uint256 inputAmountWithFee = inputAmount*99;
        uint256 numerator = outputReserve * inputAmountWithFee;
        uint256 denominator = inputReserve*100 + inputAmountWithFee;
        return numerator/denominator;
    }
}

