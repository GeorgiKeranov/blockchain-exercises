// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "./Ownable.sol";

contract Store is Ownable {
    struct Product {
        string name;
        uint quantity;
        uint price;
    }

    Product[] public products;
    mapping(string => bool) public availableProducts;

    function addNewProduct(string calldata name, uint quantity, uint price) public onlyOwner {
        require(!availableProducts[name], "The product is already in the store!");
        
        availableProducts[name] = true;
        products.push(Product(name, quantity, price));
    }

    function updateProductQuantity(uint index, uint quantity) public onlyOwner {
        require(index < products.length, "The product is not existing!");

        products[index].quantity = quantity;
    }
}
