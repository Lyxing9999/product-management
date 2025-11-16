const { poolPromise, sql } = require("../config/db.config");
const AppError = require("../utils/error");

const getAllProducts = async () => {
  const pool = await poolPromise;
  const result = await pool.request().query("SELECT * FROM PRODUCTS");
  return result.recordset;
};
const searchProducts = async ({
  name,
  minPrice,
  maxPrice,
  minStock,
  maxStock,
  page = 1,
  limit = 10,
  sortBy = "PRICE",
  sortDirection = "ASC",
}) => {
  const pool = await poolPromise;
  const request = pool.request();
  const countRequest = pool.request();

  let query = "SELECT * FROM PRODUCTS WHERE 1=1";
  let countQuery = "SELECT COUNT(*) AS total FROM PRODUCTS WHERE 1=1";

  // --- Filters ---
  if (name && name.trim() !== "") {
    query += " AND LOWER(PRODUCTNAME) LIKE LOWER(@name)";
    countQuery += " AND LOWER(PRODUCTNAME) LIKE LOWER(@name)";
    request.input("name", sql.NVarChar(100), `%${name}%`);
    countRequest.input("name", sql.NVarChar(100), `%${name}%`);
  }

  if (minPrice != null) {
    query += " AND PRICE >= @minPrice";
    countQuery += " AND PRICE >= @minPrice";
    request.input("minPrice", sql.Decimal(10, 2), minPrice);
    countRequest.input("minPrice", sql.Decimal(10, 2), minPrice);
  }

  if (maxPrice != null) {
    query += " AND PRICE <= @maxPrice";
    countQuery += " AND PRICE <= @maxPrice";
    request.input("maxPrice", sql.Decimal(10, 2), maxPrice);
    countRequest.input("maxPrice", sql.Decimal(10, 2), maxPrice);
  }

  if (minStock != null) {
    query += " AND STOCK >= @minStock";
    countQuery += " AND STOCK >= @minStock";
    request.input("minStock", sql.Int, minStock);
    countRequest.input("minStock", sql.Int, minStock);
  }

  if (maxStock != null) {
    query += " AND STOCK <= @maxStock";
    countQuery += " AND STOCK <= @maxStock";
    request.input("maxStock", sql.Int, maxStock);
    countRequest.input("maxStock", sql.Int, maxStock);
  }

  // --- Pagination ---
  const offset = (page - 1) * limit;
  request.input("offset", sql.Int, offset);
  request.input("limit", sql.Int, limit);

  // --- Sorting ---
  const safeSortBy = ["PRICE", "STOCK"].includes(sortBy?.toUpperCase())
    ? sortBy.toUpperCase()
    : "PRICE";
  const safeSortDir = sortDirection?.toUpperCase() === "DESC" ? "DESC" : "ASC";
  query += ` ORDER BY ${safeSortBy} ${safeSortDir} OFFSET @offset ROWS FETCH NEXT @limit ROWS ONLY`;

  // --- Execute ---
  const [dataResult, countResult] = await Promise.all([
    request.query(query),
    countRequest.query(countQuery),
  ]);

  const total = countResult.recordset[0].total;
  const totalPages = Math.ceil(total / limit);

  return {
    products: dataResult.recordset,
    total,
    totalPages,
    page,
    limit,
  };
};
const getProductById = async (id) => {
  const pool = await poolPromise;
  const result = await pool
    .request()
    .input("id", sql.Int, id)
    .query("SELECT * FROM PRODUCTS WHERE PRODUCTID = @id");
  return result.recordset[0];
};

const createProduct = async ({ PRODUCTNAME, PRICE, STOCK }) => {
  const pool = await poolPromise;
  const result = await pool
    .request()
    .input("PRODUCTNAME", sql.NVarChar(100), PRODUCTNAME)
    .input("PRICE", sql.Decimal(10, 2), PRICE)
    .input("STOCK", sql.Int, STOCK)
    .query(
      "INSERT INTO PRODUCTS (PRODUCTNAME, PRICE, STOCK) VALUES (@PRODUCTNAME, @PRICE, @STOCK); SELECT SCOPE_IDENTITY() AS PRODUCTID;"
    );
  return result.recordset[0];
};

const updateProduct = async (id, { PRODUCTNAME, PRICE, STOCK }) => {
  const pool = await poolPromise;
  const result = await pool
    .request()
    .input("id", sql.Int, id)
    .input("PRODUCTNAME", sql.NVarChar(100), PRODUCTNAME)
    .input("PRICE", sql.Decimal(10, 2), PRICE)
    .input("STOCK", sql.Int, STOCK)
    .query(
      "UPDATE PRODUCTS SET PRODUCTNAME=@PRODUCTNAME, PRICE=@PRICE, STOCK=@STOCK WHERE PRODUCTID=@id"
    );

  if (result.rowsAffected[0] === 0) {
    throw new AppError("Product not found", 404, "PRODUCT_NOT_FOUND");
  }

  return { PRODUCTID: id };
};

const deleteProduct = async (id) => {
  const pool = await poolPromise;
  const result = await pool
    .request()
    .input("id", sql.Int, id)
    .query("DELETE FROM PRODUCTS WHERE PRODUCTID=@id");

  if (result.rowsAffected[0] === 0) {
    throw new AppError("Product not found", 404, "PRODUCT_NOT_FOUND");
  }

  return { PRODUCTID: id };
};

module.exports = {
  getAllProducts,
  searchProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
};
