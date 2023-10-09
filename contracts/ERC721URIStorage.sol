// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import {ERC721} from "./ERC721.sol"; 
import {Strings} from "../ERC721AllFiles/Strings.sol"; 
// import {IERC4906} from "../../../interfaces/IERC4906.sol";
import {IERC165} from "../ERC721AllFiles/IERC165.sol";
import {Counters} from "../ERC721AllFiles/Counters.sol";    

/**
 * @dev ERC721 token with storage based token URI management.
 */
 
 contract ERC721URIStorage is  ERC721 {
    using Counters for Counters.Counter;

    Counters.Counter public  _tokenIdCounter;
     event MetadataUpdate(uint256 _tokenId);

    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);
    using Strings for uint256;


function mintNFT(address recipient,string memory tokenURL) public returns(uint256){
    uint256 newItemId=_tokenIdCounter.current();
    _setTokenURI(newItemId, tokenURL);
        _safeMint(recipient, newItemId);
        AllTokenIDsOfAddress[recipient].push(newItemId);
        saveToOwnershipHistory(newItemId, msg.sender, recipient);
        _tokenIdCounter.increment();
    return newItemId;
}

    // Interface ID as defined in ERC-4906. This does not correspond to a traditional interface ID as ERC-4906 only
    // defines events and does not include any external function.
    bytes4 private constant ERC4906_INTERFACE_ID = bytes4(0x49064906);

    // Optional mapping for token URIs
    mapping(uint256 tokenId => string) public  _tokenURIs;

    /**
     * @dev See {IERC165-supportsInterface}
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == ERC4906_INTERFACE_ID || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireOwned(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via string.concat).
        if (bytes(_tokenURI).length > 0) {
            return string.concat(base, _tokenURI);
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Emits {MetadataUpdate}.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) public  virtual {
        _tokenURIs[tokenId] = _tokenURI;
        emit MetadataUpdate(tokenId);
    }
}