
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}
 pragma solidity ^0.6.12;
        
        contract Owned {
            address public owner;
            address public newOwner;
        
            event OwnershipTransferred(address indexed _from, address indexed _to);
        
            constructor() public {
                owner = msg.sender;
            }
        
            modifier onlyOwner {
                require(msg.sender == owner);
                _;
            }
        
            function transferOwnership(address _newOwner) public onlyOwner {
                newOwner = _newOwner;
            }
            function acceptOwnership() public {
                require(msg.sender == newOwner);
                emit OwnershipTransferred(owner, newOwner);
                owner = newOwner;
                newOwner = address(0);
            }
        }
        
        interface  ERC20Interface {
            function totalSupply() external   view returns (uint);
            function balanceOf(address tokenOwner)  external  view returns (uint balance);
            function allowance(address tokenOwner, address spender) external  view returns (uint remaining);
            function transfer(address to, uint tokens) external  returns (bool success);
            function approve(address spender, uint tokens) external  returns (bool success);
            function transferFrom(address from, address to, uint tokens) external  returns (bool success);
        
            event Transfer(address indexed from, address indexed to, uint tokens);
            event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
        }



        interface ERC721  {
           
            event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

            event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);


            event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);


            function balanceOf(address _owner) external view returns (uint256);


            function ownerOf(uint256 _tokenId) external view returns (address);

            function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;

            function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

         
            function transferFrom(address _from, address _to, uint256 _tokenId) external payable;


            function approve(address _approved, uint256 _tokenId) external payable;

          
            function setApprovalForAll(address _operator, bool _approved) external;

  
            function getApproved(uint256 _tokenId) external view returns (address);

          
            function isApprovedForAll(address _owner, address _operator) external view returns (bool);
        }
        interface ERC721Metadata /* is ERC721 */ {
            function name() external pure returns (string memory  _name);
            function symbol() external pure returns (string memory _symbol);
            function tokenURI(uint256 _tokenId) external view returns (string memory );
        }
        interface ERC721Enumerable /* is ERC721 */ {
            function totalSupply() external view returns (uint256);
            function tokenByIndex(uint256 _index) external view returns (uint256);
            function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
        }
        interface ERC165 {
          
            function supportsInterface(bytes4 interfaceID) external view returns (bool);
        }

        interface ERC721TokenReceiver {
           
            function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns(bytes4);
         }
         
        contract Arche721 is ERC721,ERC721TokenReceiver, ERC721Metadata,ERC165 ,ERC721Enumerable, Owned{
            using SafeMath for uint;
            event E_Create_Brand(string  brand,address owner);
            event E_Transfer_Brand_Ownership(string  brand,address _from, address _to);
            struct Arche_721_Token_Data
            {
                address owner;
                uint256 token_id;
                string brand;
                string friendly_name;
                string brief;
                //string slogan;
                string url;
                string data_hash;
                address approve_to;
                bool exist;
                
            }
            struct User_Brand
            {
                address owner;
                address owner_transfer;
                string brand;
                bool exist;
            }
            uint256 m_Total_Supply=0;
            mapping(uint256=>uint256) public m_Token_Index;
            
            mapping(string => User_Brand) public m_Brands;
            
            mapping(address=>uint256) public m_Balance;
            mapping(uint256 => Arche_721_Token_Data ) public m_Tokens;
            
            mapping(address => mapping(uint256 => uint256)) private m_Indexed_Balance;
            mapping(uint256=>uint256) private m_TokenID_Index_of_Owner;
            
            
            address public m_Address_of_Arche_Token=address(0);
            address public m_Address_of_Token_Collecter=address(0);
            uint256 public m_Arche_Amount_Per_Deal=0;
            uint256 public m_Arche_Amount_Per_URL=0;
            uint256 public m_Arche_Amount_Per_Brief=0;
            
            function Set_Token_Collecter(address addr) public onlyOwner
            {
                m_Address_of_Token_Collecter=addr;
            }
            function Set_Arche_Address(address addr) public onlyOwner
            {
                m_Address_of_Arche_Token=addr;
            }
            function Set_Arche_Amount_Per_Deal(uint256 amount) public onlyOwner
            {
                m_Arche_Amount_Per_Deal=amount;
            }
            function Set_Arche_Amount_Per_URL(uint256 amount) public onlyOwner
            {
                m_Arche_Amount_Per_URL=amount;
            }
            function Set_Arche_Amount_Per_Brief(uint256 amount) public onlyOwner
            {
                m_Arche_Amount_Per_Brief=amount;
            }
            function Collect_Arche(address p_addr, uint p_amount)private
            {
                bool sys_res=false;
                sys_res=ERC20Interface(m_Address_of_Arche_Token).transferFrom(p_addr, address(this),p_amount);
                if(sys_res ==false)
                {
                    //if failed revert transaction;
                    revert();
                }
                ERC20Interface(m_Address_of_Arche_Token).transfer(m_Address_of_Token_Collecter,p_amount);
            }
                    
            function Transfer_Index_of_Owner_Brfore_Transfer_Owner( address from, address to ,uint256 token_id) private
            {
                if(from !=address(0))
                {
                    
                require(m_Tokens[token_id].owner==from);
                require(m_Balance[from]>0);
                uint256 t_index_of_owner= m_TokenID_Index_of_Owner[token_id];
                m_Indexed_Balance[from][t_index_of_owner]=m_Indexed_Balance[from][m_Balance[from]-1];
                delete m_Indexed_Balance[from][m_Balance[from]-1];
                }
                
                
                uint256 t_index_of_receiver= m_Balance[to];
                m_Indexed_Balance[to][t_index_of_receiver]=token_id;
                
                m_TokenID_Index_of_Owner[token_id]=t_index_of_receiver;
                
            }
            
            constructor() public 
            {
               
            }
            function name() external pure override returns (string memory  _name)
            {
                return "ARCHE";
            }
            function symbol() external pure override returns (string memory _symbol)
            {
                return "ARCHE";
            }
            function tokenURI(uint256 _tokenId) external view override returns (string memory url)
            {
                return m_Tokens[_tokenId].url;
            }
            function totalSupply() external view override returns (uint256)
            {
                return m_Total_Supply;
            }
            function tokenByIndex(uint256 _index) external view override returns (uint256)
            {
                return m_Token_Index[_index];
            }
            function tokenOfOwnerByIndex(address _owner, uint256 _index) external view override returns (uint256)
            {
                return  m_Indexed_Balance[_owner][_index];
            }
            
            
            
            function Create_Brand(string memory brand) public onlyOwner
            {
                require( m_Brands[brand].exist==false,"Already Exists");
                User_Brand memory ub = User_Brand(address(msg.sender),address(0), brand,true);
               
                m_Brands[brand]=ub;
                
                emit E_Create_Brand(brand,msg.sender);
            }
            function Get_Brand_Owner(string memory brand) public view returns (address)
            {
                
                return m_Brands[brand].owner;
            }
            function Transfer_Brand_Ownership(string memory brand, address to ) public
            {
                require(msg.sender==m_Brands[brand].owner,"NOT BELONGS TO YOU");
                m_Brands[brand].owner_transfer=to;
            }
            function Accept_Brand_Ownership(string memory brand ) public
            {
                require(msg.sender==m_Brands[brand].owner_transfer,"NOT BELONGS TO YOU");
                emit E_Transfer_Brand_Ownership(brand,m_Brands[brand].owner,msg.sender);
                
                m_Brands[brand].owner=msg.sender;
                m_Brands[brand].owner_transfer=address(0);
            }
            
            function New_Token(uint256 token_id,string memory brand, string memory friendly_name,string memory url,string memory hash ) private returns (Arche_721_Token_Data memory)
            {
                 Arche_721_Token_Data memory atd= Arche_721_Token_Data(msg.sender,token_id,brand,friendly_name,"",url,hash,address(0),true);
                 //Arche_721_Token_Data memory atd;
                 return atd;
            }
            function Mint_Token(uint256 token_id,string memory brand, string memory friendly_name,string memory url,string memory hash ) public 
            {
                require(m_Tokens[token_id].exist==false,"TokenID Exists");
                require(m_Brands[brand].exist==true,"Brand Not Exist");
                require(m_Brands[brand].owner==msg.sender,"Brand Not Available");
                Arche_721_Token_Data memory atd= New_Token(token_id,brand,friendly_name,url,hash);
                m_Tokens[token_id]=atd;
                
                
                Transfer_Index_of_Owner_Brfore_Transfer_Owner(address(0),msg.sender,token_id);
                
                m_Balance[msg.sender]=m_Balance[msg.sender].add(1);
                
                m_Token_Index[m_Total_Supply]=token_id;
                m_Total_Supply=m_Total_Supply.add(1);
                
                
                
                emit Transfer( address(0), msg.sender, token_id);
            }
            function Update_URL(uint256 token_id,string memory url) public 
            {
                require(m_Tokens[token_id].exist==true,"TokenID NOT Exist");
                require(m_Tokens[token_id].owner==msg.sender,"Token NOT Available");
                m_Tokens[token_id].url=url;
                
                Collect_Arche(msg.sender,m_Arche_Amount_Per_URL);
               
            }
            function Update_Brief(uint256 token_id,string memory brief) public 
            {
                require(m_Tokens[token_id].exist==true,"TokenID NOT Exist");
                require(m_Tokens[token_id].owner==msg.sender,"Token NOT Available");
                m_Tokens[token_id].brief=brief;
                

                Collect_Arche(msg.sender,m_Arche_Amount_Per_Brief);
                
            }
            
            function isContract(address account) internal view returns (bool) {
                uint256 size;
                assembly {
                    size := extcodesize(account)
                }
                return size > 0;
            }
            function balanceOf(address _owner) external override view returns (uint256)
            {
                return (m_Balance[_owner]);
            }


            function ownerOf(uint256 _tokenId) external override view returns (address)
            {
                return (m_Tokens[_tokenId].owner);
            }
            
                     
            function transferFrom(address _from, address _to, uint256 _tokenId) public  override payable{
                require(m_Tokens[_tokenId].owner==_from);
                require(m_Tokens[_tokenId].exist==true,"TokenID NOT Exist");
                require(m_Balance[_from]>0,"OVERDRAW");
                if(_from==msg.sender)
                {
                }
                else
                {
                    require(m_Tokens[_tokenId].approve_to==msg.sender);
                }
                
                
                Transfer_Index_of_Owner_Brfore_Transfer_Owner(_from,_to,_tokenId);
                
                
                m_Tokens[_tokenId].owner=_to;
                m_Tokens[_tokenId].approve_to=address(0);
                m_Balance[_from]=m_Balance[_from].sub(1);
                m_Balance[_to]=m_Balance[_to].add(1);
                
                emit Transfer( _from, _to, _tokenId);
            }

            function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external override payable
            {
                transferFrom(_from,_to,_tokenId);
                if(isContract(_to))
                {
                 bytes4 res=ERC721TokenReceiver(_to).onERC721Received(msg.sender,_from,_tokenId,data);   
                 require (res==bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")), "TARGET CONTRACT CAN NOT RECEIVE THIS TOKEN" );
                }
            }

            function safeTransferFrom(address _from, address _to, uint256 _tokenId) external override payable{
                transferFrom(_from,_to,_tokenId);
                bytes memory t_bytes;
                if(isContract(_to))
                {
                 bytes4 res =ERC721TokenReceiver(_to).onERC721Received(msg.sender,_from,_tokenId,t_bytes); 
                 require (res==bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")), "TARGET CONTRACT CAN NOT RECEIVE THIS TOKEN" );
                }
            }




            function approve(address _approved, uint256 _tokenId) external override payable
            {
                require(m_Tokens[_tokenId].exist==true,"TokenID NOT Exist");
                require(m_Tokens[_tokenId].owner==msg.sender);
                m_Tokens[_tokenId].approve_to=_approved;   
                
                emit Approval(msg.sender,_approved,_tokenId);
            }

          
            function setApprovalForAll(address _operator, bool _approved) external override
            {
             
            }

  
            function getApproved(uint256 _tokenId) external override view returns (address)
            {
                return(m_Tokens[_tokenId].approve_to);
            }

          
            function isApprovedForAll(address _owner, address _operator) external override view returns (bool)
            {
                return(true);
            }
            function supportsInterface(bytes4 interfaceID) external override view returns (bool)
            {
                return (true);
            }
            function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external override returns(bytes4){
                   return  bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
            }
            function Call_Function(address addr,uint256 value ,bytes memory data) public  onlyOwner {
              addr.call{value:value}(data);
            }
         }
            
         
          