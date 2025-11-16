const validateProduct = ({ PRODUCTNAME, PRICE, STOCK }) => {
  if (!PRODUCTNAME || PRODUCTNAME.trim() === "")
    throw new Error("Product name is required");
  if (PRICE <= 0) throw new Error("Price must be positive");
  if (STOCK < 0) throw new Error("Stock cannot be negative");
};

module.exports = validateProduct;
