// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import {IERC721, IERC721Errors} from "./Interface.sol";
import {IERC721Receiver} from "./IERC721Receiver.sol";
import {IERC721Metadata} from "./IERC721Metadata.sol";
import {Context} from "./Context.sol";
import {Strings} from "./Strings.sol";
import {ERC165} from "./ERC165.sol";
import {IERC165} from "./IERC165.sol";
import {Ownable} from "./Ownable.sol";
import {Counters} from "./Counters.sol";
// import {ERC721URIStorage} from "./ERC721URIStorage.sol";


contract ERC721 is
    Context,
    ERC165,
    IERC721,
    IERC721Metadata,
    IERC721Errors,
    Ownable
    
{
    using Strings for uint256;

    // Token name
    string private _name = "MyToken";

    // Token symbol
    string private _symbol = "MTK";

    address public  contractOwner;

    mapping(uint256 tokenId => address) private _owners;

    mapping(address owner => uint256) private _balances;

    mapping(uint256 tokenId => address) private _tokenApprovals;

    mapping(address owner => mapping(address operator => bool))
        private _operatorApprovals;

    mapping(uint256 => OwnershipStruct[]) public ownershipHistory;

    mapping(address => uint256[]) AllTokenIDsOfAddress;

    // using Counters for Counters.Counter;

    // Counters.Counter public _tokenIdCounter;

    struct OwnershipStruct {
        address currentOwner;
        address previousOwner;
    }

   
    constructor() Ownable(msg.sender) {
contractOwner=msg.sender;
    }

    
    function balanceOf(address owner) public view virtual returns (uint256) {
        if (owner == address(0)) {
            revert ERC721InvalidOwner(address(0));
        }
        return _balances[owner];
    }

    
    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        return _requireOwned(tokenId);
    }

   
    function name() public view virtual returns (string memory) {
        return _name;
    }

    
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

   
    function tokenURI(
        uint256 tokenId
    ) public view virtual returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString()) : "";
    }

   
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

// function mintNFT(address recipient,string memory tokenURL) public onlyOwner returns(uint256){
//     uint256 newItemId=_tokenIdCounter.current();
//     // _setTokenURI(newItemId, tokenURL);
//         _safeMint(recipient, newItemId);
//         AllTokenIDsOfAddress[recipient].push(newItemId);
//         saveToOwnershipHistory(newItemId, msg.sender, recipient);
//         _tokenIdCounter.increment();
//     return newItemId;
// }

   

    function saveToOwnershipHistory(
        uint256 tokenId,
        address currentOwner,
        address newOwner
    ) public returns (bool) {
        OwnershipStruct memory owner = OwnershipStruct(currentOwner, newOwner);
        ownershipHistory[tokenId].push(owner);
        return true;
    }

    function getOwnerShipHistory(
        uint256 tokenID
    ) public view returns (OwnershipStruct[] memory) {
        return ownershipHistory[tokenID];
    }

    function getAllTokenIDsOfAddress(
        address addr
    ) public view returns (uint256[] memory) {
        return AllTokenIDsOfAddress[addr];
    }

    
    function approve(address to, uint256 tokenId) public virtual {
        _approve(to, tokenId, _msgSender());
    }

   
    function getApproved(
        uint256 tokenId
    ) public view virtual returns (address) {
        _requireOwned(tokenId);

        return _getApproved(tokenId);
    }

   
    function setApprovalForAll(address operator, bool approved) public virtual {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

   
    function isApprovedForAll(
        address owner,
        address operator
    ) public view virtual returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
       
        address previousOwner = _update(to, tokenId, _msgSender());
        saveToOwnershipHistory(tokenId, from, to);

        if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
    }

    function buyNFT(
        address payable seller,
        uint256 tokenId,
        uint256 price
    ) public payable virtual {
        if (msg.sender == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }

        require(
            msg.sender.balance >= price && msg.value > 0,
            "insuficient balance"
        );

        address previousOwner = _update(msg.sender, tokenId, seller);
        saveToOwnershipHistory(tokenId, seller, msg.sender);
        seller.transfer(msg.value);
        if (previousOwner != seller) {
            revert ERC721IncorrectOwner(seller, tokenId, previousOwner);
        }
    }

    function transferAuctionNFT(
        address payable seller,
        address buyer,
        address owner,
        uint256 tokenId
    ) public payable virtual {
        if (buyer == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        require( owner==contractOwner,"You are not the owner of the contract");
        address previousOwner = _update(buyer, tokenId, seller);
        saveToOwnershipHistory(tokenId, seller, buyer);
        seller.transfer(msg.value);
        if (previousOwner != seller) {
            revert ERC721IncorrectOwner(seller, tokenId, previousOwner);
        }
    }

   
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        safeTransferFrom(from, to, tokenId, "");
    }

   
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual {
        transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }

    
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

   
    function _getApproved(
        uint256 tokenId
    ) internal view virtual returns (address) {
        return _tokenApprovals[tokenId];
    }

   
    function _isAuthorized(
        address owner,
        address spender,
        uint256 tokenId
    ) internal view virtual returns (bool) {
        return
            spender != address(0) &&
            (owner == spender ||
                isApprovedForAll(owner, spender) ||
                _getApproved(tokenId) == spender);
    }

   
    function _checkAuthorized(
        address owner,
        address spender,
        uint256 tokenId
    ) internal view virtual {
        if (!_isAuthorized(owner, spender, tokenId)) {
            if (owner == address(0)) {
                revert ERC721NonexistentToken(tokenId);
            } else {
                revert ERC721InsufficientApproval(spender, tokenId);
            }
        }
    }

   
    function _increaseBalance(address account, uint128 value) internal virtual {
        unchecked {
            _balances[account] += value;
        }
    }

   
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal virtual returns (address) {
        address from = _ownerOf(tokenId);

        if (auth != address(0)) {
            _checkAuthorized(from, auth, tokenId);
        }

        if (from != address(0)) {
            _approve(address(0), tokenId, address(0), false);

            unchecked {
                _balances[from] -= 1;
            }
        }

        if (to != address(0)) {
            unchecked {
                _balances[to] += 1;
            }
        }

        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        return from;
    }

   
    function _mint(address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner != address(0)) {
            revert ERC721InvalidSender(address(0));
        }
    }

   
    function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }

   
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        _checkOnERC721Received(address(0), to, tokenId, data);
    }

   
    function _burn(uint256 tokenId) internal {
        address previousOwner = _update(address(0), tokenId, address(0));
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
    }

   
    function _transfer(address from, address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        } else if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
    }

   
    function _safeTransfer(address from, address to, uint256 tokenId) internal {
        _safeTransfer(from, to, tokenId, "");
    }

   
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }

   
    function _approve(address to, uint256 tokenId, address auth) internal {
        _approve(to, tokenId, auth, true);
    }

   
    function _approve(
        address to,
        uint256 tokenId,
        address auth,
        bool emitEvent
    ) internal virtual {
        if (emitEvent || auth != address(0)) {
            address owner = _requireOwned(tokenId);

            if (
                auth != address(0) &&
                owner != auth &&
                !isApprovedForAll(owner, auth)
            ) {
                revert ERC721InvalidApprover(auth);
            }

            if (emitEvent) {
                emit Approval(owner, to, tokenId);
            }
        }

        _tokenApprovals[tokenId] = to;
    }

    
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        if (operator == address(0)) {
            revert ERC721InvalidOperator(operator);
        }
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

   
    function _requireOwned(uint256 tokenId) public view returns (address) {
        address owner = _ownerOf(tokenId);
        if (owner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        return owner;
    }

    
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private {
        if (to.code.length > 0) {
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    data
                )
            returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721InvalidReceiver(to);
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }
// }








// contract auctionContract  {
    uint256 public bidCount = 0;
    mapping(uint256 => address payable) public bidMakerAddress;
    mapping(uint256 => uint256) public bidsCountMapping;

    function makebid(
        address payable bidMaker,
        uint256 bid
    ) public payable returns (bool) {
        require(
            msg.sender.balance >= bid && msg.value >= bid * 1 ether,
            "you have not enough balance"
        );
        bidMakerAddress[bidCount] = bidMaker;
        bidsCountMapping[bidCount] = bid;
        bidCount = bidCount + 1;
        return true;
    }

    function returnAmount(
        address payable receiver,
        uint256 amount
    ) internal {
        require(address(this).balance >= amount, "Insufficient contract balance");
        receiver.transfer(amount * 1 ether);
    }

    function sendNFT(
        uint256 tokenID,
        address payable seller,
        address owner
    ) public {
        uint256 highestBid = 0;
        uint256 addressNum;
        for (uint256 i = 0; i < bidCount; i++) {
            if (bidsCountMapping[i] > highestBid) {
                highestBid = bidsCountMapping[i];
                addressNum = i;
            }
        }
        address finalAddress = bidMakerAddress[addressNum];
        transferAuctionNFT(seller, finalAddress, owner, tokenID);

        for (uint256 i = 0; i < bidCount; i++) {
            if (bidMakerAddress[i] != bidMakerAddress[addressNum]) {
                returnAmount(bidMakerAddress[i], bidsCountMapping[i]);
            } else {
                returnAmount(seller, bidsCountMapping[i]);
            }
        }
        bidCount=0;
    }

}
