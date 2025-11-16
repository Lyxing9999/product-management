const productService = require("../services/product.service");
const { successResponse, errorResponse } = require("../utils/response");
const AppError = require("../utils/error");
const { Parser } = require("json2csv");
const PDFDocument = require("pdfkit");
// GET /products
const getAllProductsController = async (req, res, next) => {
  try {
    const products = await productService.serviceGetAll();
    successResponse(res, "All products retrieved successfully", { products });
  } catch (err) {
    errorResponse(res, err.message, {}, err.statusCode);
  }
};

// GET /products/search
const searchProductsController = async (req, res, next) => {
  try {
    const {
      name,
      minPrice,
      maxPrice,
      minStock,
      maxStock,
      page: pageStr = "1",
      limit: limitStr = "10",
      sortBy,
      sortDirection,
    } = req.query;

    const result = await productService.serviceSearch({
      name,
      minPrice: minPrice ? parseFloat(minPrice) : null,
      maxPrice: maxPrice ? parseFloat(maxPrice) : null,
      minStock: minStock ? parseInt(minStock) : null,
      maxStock: maxStock ? parseInt(maxStock) : null,
      page: parseInt(pageStr),
      limit: parseInt(limitStr),
      sortBy,
      sortDirection,
    });

    successResponse(res, "Products search completed successfully", result);
  } catch (err) {
    errorResponse(res, err.message, {}, err.statusCode || 500);
  }
};
// GET /products/:id
const getProductByIdController = async (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);
    const product = await productService.serviceGetById(id);

    if (!product) {
      throw new AppError("Product not found", 404, "PRODUCT_NOT_FOUND");
    }

    successResponse(res, "Product retrieved successfully", { product });
  } catch (err) {
    errorResponse(res, err.message, {}, err.statusCode || 500);
  }
};

// POST /products
const createProductController = async (req, res, next) => {
  try {
    const product = await productService.serviceCreate(req.body);
    successResponse(res, "Product created successfully", { product }, 201);
  } catch (err) {
    errorResponse(res, err.message, {}, err.statusCode || 500);
  }
};

// PUT /products/:id
const updateProductController = async (req, res, next) => {
  try {
    const updated = await productService.serviceUpdate(
      parseInt(req.params.id, 10),
      req.body
    );

    successResponse(res, "Product updated successfully", { product: updated });
  } catch (err) {
    errorResponse(res, err.message, {}, err.statusCode || 500);
  }
};

// DELETE /products/:id
const deleteProductController = async (req, res, next) => {
  try {
    const product = await productService.serviceDelete(
      parseInt(req.params.id, 10)
    );
    successResponse(res, "Product deleted successfully", { product });
  } catch (err) {
    errorResponse(res, err.message, {}, err.statusCode || 500);
  }
};

const exportProductsCSVController = async (req, res) => {
  try {
    const {
      name,
      minPrice,
      maxPrice,
      minStock,
      maxStock,
      sortBy,
      sortDirection,
    } = req.query;

    // Fetch all products that match filters (ignore pagination)
    const result = await productService.serviceSearch({
      name,
      minPrice: minPrice ? parseFloat(minPrice) : null,
      maxPrice: maxPrice ? parseFloat(maxPrice) : null,
      minStock: minStock ? parseInt(minStock) : null,
      maxStock: maxStock ? parseInt(maxStock) : null,
      page: 1,
      limit: 100000, // Very high limit to get all rows
      sortBy,
      sortDirection,
    });

    const products = result.products;

    if (!products || products.length === 0) {
      return res.status(404).send("No products found to export");
    }

    // Convert JSON to CSV
    const fields = ["PRODUCTID", "PRODUCTNAME", "PRICE", "STOCK"];
    const json2csvParser = new Parser({ fields });
    const csv = json2csvParser.parse(products);

    // Send CSV as attachment
    res.header("Content-Type", "text/csv");
    res.attachment("products.csv");
    res.send(csv);
  } catch (err) {
    console.error(err);
    errorResponse(res, err.message, {}, 500);
  }
};

const exportProductsPDFController = async (req, res) => {
  try {
    const {
      name,
      minPrice,
      maxPrice,
      minStock,
      maxStock,
      sortBy,
      sortDirection,
    } = req.query;

    // Fetch all products (ignore pagination)
    const result = await productService.serviceSearch({
      name,
      minPrice: minPrice ? parseFloat(minPrice) : null,
      maxPrice: maxPrice ? parseFloat(maxPrice) : null,
      minStock: minStock ? parseInt(minStock) : null,
      maxStock: maxStock ? parseInt(maxStock) : null,
      page: 1,
      limit: 100000,
      sortBy,
      sortDirection,
    });

    const products = result.products;
    if (!products || products.length === 0) {
      return res.status(404).send("No products to export");
    }

    const doc = new PDFDocument({ margin: 50, size: "A4" });

    // Stream PDF to response
    res.setHeader("Content-Disposition", "attachment; filename=products.pdf");
    res.setHeader("Content-Type", "application/pdf");
    doc.pipe(res);

    // PDF Title
    doc
      .fontSize(22)
      .font("Helvetica-Bold")
      .text("Products Report", { align: "center" });
    doc.moveDown(0.5);
    doc
      .fontSize(10)
      .font("Helvetica")
      .text(`Generated on ${new Date().toLocaleString()}`, { align: "center" });
    doc.moveDown(2);

    const colWidths = { id: 60, name: 220, price: 80, stock: 80 };
    const colX = {
      id: 50,
      name: 50 + colWidths.id,
      price: 50 + colWidths.id + colWidths.name,
      stock: 50 + colWidths.id + colWidths.name + colWidths.price,
    };
    const tableWidth =
      colWidths.id + colWidths.name + colWidths.price + colWidths.stock;
    const verticalXs = [50, colX.name, colX.price, colX.stock, 50 + tableWidth];

    let rowY = doc.y;
    let pageNumber = 1;

    // Function to draw table header
    const drawTableHeader = (y) => {
      doc.rect(50, y - 5, tableWidth, 25).fill("#4A5568");
      doc
        .fontSize(11)
        .font("Helvetica-Bold")
        .fillColor("#FFFFFF")
        .text("ID", colX.id + 5, y + 5, { width: colWidths.id })
        .text("Name", colX.name + 5, y + 5, { width: colWidths.name })
        .text("Price", colX.price + 5, y + 5, { width: colWidths.price })
        .text("Stock", colX.stock + 5, y + 5, { width: colWidths.stock });

      // Horizontal line under header
      doc
        .strokeColor("#000000")
        .lineWidth(1)
        .moveTo(50, y + 25)
        .lineTo(50 + tableWidth, y + 25)
        .stroke();
    };

    drawTableHeader(rowY);
    rowY += 30;

    const rowHeight = 20;
    const bottomMargin = 50;

    // Draw table rows
    products.forEach((p, index) => {
      // Check if need a new page
      if (rowY + rowHeight + bottomMargin > doc.page.height) {
        // Footer before new page
        doc
          .fontSize(8)
          .fillColor("#718096")
          .text(`Page ${pageNumber}`, 50, doc.page.height - bottomMargin, {
            align: "center",
          });

        doc.addPage();
        pageNumber++;
        rowY = 50;

        drawTableHeader(rowY);
        rowY += 30;
      }

      // Alternating row color
      if (index % 2 === 0)
        doc.rect(50, rowY - 3, tableWidth, rowHeight).fill("#F7FAFC");

      // Row text
      doc
        .fillColor("#000000")
        .font("Helvetica")
        .fontSize(10)
        .text(p.PRODUCTID, colX.id + 5, rowY, { width: colWidths.id })
        .text(p.PRODUCTNAME, colX.name + 5, rowY, { width: colWidths.name })
        .text(`$${parseFloat(p.PRICE).toFixed(2)}`, colX.price + 5, rowY, {
          width: colWidths.price,
        })
        .text(p.STOCK, colX.stock + 5, rowY, { width: colWidths.stock });

      // Horizontal line
      doc
        .strokeColor("#E2E8F0")
        .lineWidth(0.5)
        .moveTo(50, rowY + rowHeight - 2)
        .lineTo(50 + tableWidth, rowY + rowHeight - 2)
        .stroke();

      rowY += rowHeight;
    });

    // Vertical lines for last page
    verticalXs.forEach((x) => {
      doc
        .moveTo(x, 50)
        .lineTo(x, rowY)
        .strokeColor("#E2E8F0")
        .lineWidth(0.5)
        .stroke();
    });

    // Footer for last page
    doc
      .fontSize(8)
      .fillColor("#718096")
      .text(`Page ${pageNumber}`, 50, doc.page.height - bottomMargin, {
        align: "center",
      });

    doc.end();
  } catch (err) {
    console.error(err);
    errorResponse(res, err.message, {}, 500);
  }
};
module.exports = {
  getAllProductsController,
  searchProductsController,
  getProductByIdController,
  createProductController,
  updateProductController,
  deleteProductController,
  exportProductsCSVController,
  exportProductsPDFController,
};
