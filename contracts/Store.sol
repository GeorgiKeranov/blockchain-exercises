// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "./Ownable.sol";

contract Store is Ownable {
    struct Product {
        uint id;
        string name;
        uint quantity;
        uint price;
    }

    Product[] public products;
    mapping(string => bool) public availableProducts;

    function addNewProduct(string calldata name, uint quantity, uint price) public onlyOwner {
        require(name.length && price > 0)
        require(!availableProducts[name], "The product is already in the store!");
        
        availableProducts[name] = true;
        products.push(Product(products.length, name, quantity, price));
    }

    function updateProductQuantity(uint id, uint quantity) public onlyOwner {
        require(id < products.length, "The product is not existing!");

        products[id].quantity = quantity;
    }

    function getProducts() public view returns(Product[] memory) {
        return products;
    }
}
