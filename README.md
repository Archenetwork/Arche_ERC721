# ArcheFi  ERC721 ver Core Contract
## introduction
The Project ArcheFi provides a convenient OPTION platform. An Option Ticket may be created by ANY address ANONYMOUSLY. The tickets are established by ArcheFI's contract-factory as an independent contract.Interactions With Option Contract are decentralized (except statistical Data of Created Options).   

## Functions/Interfaces
Here are 2 Contracts,Main-Contract and Factory-Contract.
### Main Contract

| Function Name | Brief Introduction |
| --- | --- |
|Set_Arche_Address(address addr) | Set Arche token address (DEPLOYMENT ONLY) |
|Set_Arche_Amount_Per_Deal(uint256 amount) | Set the fee (token amount) of one deal (DEPLOYMENT ONLY) |
|Set_Token_Collecter(address addr) | Set the collector addresss, any fee will be send to the address (DEPLOYMENT ONLY)|
|Set_System_Reward_Address(address addr) |Set Address of ERC20 Token For Option Reward  (DEPLOYMENT ONLY)|
|Set_Factory_Lib(address addr) | Set Address of Factory contract (DEPLOYMENT ONLY) |
|Create(address token_head,address token_tail,address sys_reward_addr,uint256 sys_reward)  | Create an Option Ticket from Factory Contract |
    
### Factory-Contract

| Function Name | Brief Introduction |
| --- | --- |
| Set_DSwap_Main_Address(address addr)   | Set Address of EMain Contract (DEPLOYMENT ONLY) |
| Set_Initializing_Params(string memory head_type,string memory tail_type,uint256 total_amount_head ,uint256 total_amount_tail ,uint256 future_block_offset,string memory slogan)| Option Creator Set parameters of Option .<ul>  <li> "head_type" and "tail_type" must be one of {["ERC20" , "ERC721"]} . </li> <li> "total_amount_head" and "total_amount_tail" means amount or tokenid,it depands on the param  "head_type" and "tail_type".  </li> <li>   "future_block_offset" indicates how many blocks until the dell will close.  </li> <ul>  |
| Claim_For_Head() |Option deal creator address claim for the option (HEAD side)|
| Deposit_For_Tail(address referer)| Any address pay ERC20/ERC721 of the option  (TAIL side)|
| Claim_For_Delivery() | When the future is closed ,invoke this function to clain token(s) |
| Withdraw_Head() | If there is no rival, send tokens back and obliterate this deal |
