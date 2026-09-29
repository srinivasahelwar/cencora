const http = require("http");

const port = process.env.PORT || 8080;
const version = process.env.APP_VERSION || "1.0.0";
const environment = process.env.APP_ENV || "local";

const orders = [
  {
    id: "order-1001",
    customerId: "cust-01",
    amount: 4500,
    status: "PAID",
    city: "Bengaluru"
  },
  {
    id: "order-1002",
    customerId: "cust-02",
    amount: 2800,
    status: "CREATED",
    city: "Mysuru"
  }
];

const server = http.createServer((request, response) => {
  response.setHeader("Content-Type", "application/json");

  if (request.url === "/health") {
    response.writeHead(200);
    response.end(
      JSON.stringify({
        status: "UP",
        service: "cloud-orders",
        version,
        environment
      })
    );
    return;
  }

  if (request.url === "/api/orders") {
    response.writeHead(200);
    response.end(JSON.stringify(orders));
    return;
  }

  if (request.url === "/") {
    response.writeHead(200);
    response.end(
      JSON.stringify({
        message: "Welcome to Cloud Orders",
        endpoints: ["/health", "/api/orders"],
        version
      })
    );
    return;
  }

  response.writeHead(404);
  response.end(
    JSON.stringify({
      error: "Not Found",
      path: request.url
    })
  );
});

server.listen(port, "0.0.0.0", () => {
  console.log(`Cloud Orders ${version} listening on port ${port}`);
});

module.exports = server;