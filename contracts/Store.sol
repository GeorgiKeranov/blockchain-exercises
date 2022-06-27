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
    mapping(string => bool) public availableProductsNames;

    // Product id => (client address => product quantity)
    mapping(uint => mapping(address => uint)) public productsPurchases;

    event ProductAdded(string, uint, uint);
    event ProductUpdated(uint, uint);
    event ProductBought(address, uint, uint);

    function addNewProduct(string calldata name, uint quantity, uint price) public onlyOwner {
        require(bytes(name).length != 0 && price > 0);
        require(!availableProductsNames[name], "The product is already in the store!");
        
        uint productId = products.length;

        availableProductsNames[name] = true;
        products.push(Product(productId, name, quantity, price));

        emit ProductAdded(name, quantity, price);
    }

    modifier onlyExistingProduct(uint id) {
        require(id < products.length, "The product is not existing!");
        _;
    }

    function updateProductQuantity(uint id, uint quantity) public onlyOwner onlyExistingProduct(id) {
        products[id].quantity = quantity;
        
        emit ProductUpdated(id, quantity);
    }

    function getProducts() public view returns(Product[] memory) {
        return products;
    }

    function buyProduct(uint id, uint quantity) payable public onlyExistingProduct(id) {
        require(quantity > 0, "Invalid quantity!");

        address clientAddress = msg.sender;
        
        // Check if the user has already bought the product
        require(productsPurchases[id][clientAddress] == 0, "You have already bought this product!");

        Product storage currentProduct = products[id];

        // Check if we have enough quantity from the product
        require(currentProduct.quantity >= quantity, "The product quantity is less than you wanted!");

        uint256 totalPrice = uint256(products[id].price * quantity);
        require(msg.value == totalPrice, "Please send the exact price of the product multiplied by the quantity you want!");

        // Transfer the ether to the owner of the store
        payable(owner).transfer(totalPrice);

        // Add the new purchase to the state
        productsPurchases[id][clientAddress] = quantity;

        // Remove the bought quantity from the product
        currentProduct.quantity -= quantity;

        emit ProductBought(clientAddress, id, quantity);
    }
}
