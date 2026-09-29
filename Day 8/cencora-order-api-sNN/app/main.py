from flask import Flask, jsonify, request

app = Flask(__name__)

@app.get('/health')
def health():
    return jsonify({'status': 'UP', 'service': 'cencora-order-api'})

@app.post('/orders')
def create_order():
    payload = request.get_json(silent=True) or {}
    required = ['orderId', 'customerId', 'medicineCode', 'quantity']
    missing = [x for x in required if x not in payload]
    if missing:
        return jsonify({'status': 'ERROR', 'missing': missing}), 400
    return jsonify({'status': 'ACCEPTED', 'order': payload}), 202

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
