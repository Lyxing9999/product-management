const express = require("express");
const router = express.Router();
const productController = require("../controllers/product.controller");

// RESTful routes
router.get("/", productController.getAllProductsController); // GET /products
router.get("/search", productController.searchProductsController); // GET /products/search
router.get("/:id", productController.getProductByIdController); // GET /products/1
router.post("/", productController.createProductController); // POST /products
router.put("/:id", productController.updateProductController); // PUT /products/1
router.delete("/:id", productController.deleteProductController); // DELETE /products/1
router.get("/export/csv", productController.exportProductsCSVController);
router.get("/export/pdf", productController.exportProductsPDFController);
module.exports = router;
