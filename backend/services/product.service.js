const {
  getAllProducts,
  searchProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
} = require("../models/product.model");
const { AppError } = require("../utils/error");
const validateProduct = require("../utils/validate");

const serviceGetAll = async () => getAllProducts();
const serviceSearch = async (data) => searchProducts(data);
const serviceGetById = async (id) => getProductById(id);
const serviceCreate = async (data) => {
  validateProduct(data);
  return createProduct(data);
};

const serviceUpdate = async (id, data) => {
  validateProduct(data);
  return updateProduct(id, data);
};

const serviceDelete = async (id) => {
  const product = await getProductById(id);
  if (!product) throw new AppError("Product not found", 404);
  return deleteProduct(id);
};

module.exports = {
  serviceGetAll,
  serviceSearch,
  serviceGetById,
  serviceCreate,
  serviceUpdate,
  serviceDelete,
};
