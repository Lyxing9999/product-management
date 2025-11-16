function successResponse(res, message, data = {}, statusCode = 200) {
  res.status(statusCode).json({
    success: true,
    message,
    data, // this can be product, list of products, etc.
  });
}

function errorResponse(res, message, data = {}, statusCode = 400) {
  res.status(statusCode).json({
    success: false,
    message,
    data,
  });
}

module.exports = { successResponse, errorResponse };
