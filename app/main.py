import os
import boto3
import json
import logging
from flask import Flask, request, jsonify
from datetime import datetime
from prometheus_client import start_http_server, Counter, Histogram
from sklearn.ensemble import IsolationForest
import pandas as pd
import jwt
from jwt import ExpiredSignatureError, InvalidTokenError

# Initialize Flask app
app = Flask(__name__)

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# DynamoDB Client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('tb_fuel_control')

# Prometheus Metrics
REQUESTS = Counter('flask_requests_total', 'Total number of requests', ['method', 'endpoint'])
ERRORS = Counter('flask_errors_total', 'Total number of errors', ['method', 'endpoint'])
LATENCY = Histogram('flask_request_latency_seconds', 'Histogram of request latencies', ['method', 'endpoint'])

# Anomaly detection model (for simplicity, we're using a basic Isolation Forest model)
anomaly_detector = IsolationForest(contamination=0.05)

# Function to get the car_id from the Cognito token
def get_car_id_from_token():
    token = request.headers.get('Authorization').split(" ")[1]  # Extract token
    
    # Decode the token (this is just a placeholder logic)
    try:
        decoded_token = jwt.decode(token, options={"verify_signature": False})  # Disable signature verification for simplicity
        car_id = decoded_token.get('car_id')
        
        if not car_id:
            return None
        
        return car_id
    except (ExpiredSignatureError, InvalidTokenError) as e:
        logger.error(f"Token validation failed: {e}")
        return None

# Endpoint to save fuel consumption data
@app.route('/save_fuel_consumption', methods=['POST'])
@LATENCY.time()  # Track request latency
def save_fuel_consumption():
    # Count request
    REQUESTS.labels(method='POST', endpoint='/save_fuel_consumption').inc()

    try:
        # Extract car_id from Cognito token
        car_id = get_car_id_from_token()
        
        if car_id is None:
            return jsonify({"error": "Unauthorized or Invalid Token"}), 401
        
        # Get the fuel consumption data from the request
        data = request.json
        fuel_consumption = data.get('fuel_consumption')
        timestamp = data.get('timestamp', datetime.now().isoformat())
        
        if fuel_consumption is None:
            return jsonify({"error": "fuel_consumption is required"}), 400
        
        # Store in DynamoDB
        response = table.put_item(
            Item={
                'car_id': car_id,
                'timestamp': timestamp,
                'fuel_consumption': fuel_consumption
            }
        )
        
        return jsonify({"message": "Fuel consumption data saved successfully"}), 200
    except Exception as e:
        logger.error(f"Error saving fuel consumption: {e}")
        ERRORS.labels(method='POST', endpoint='/save_fuel_consumption').inc()
        return jsonify({"error": "An error occurred while saving data"}), 500

# Endpoint to detect anomalies in fuel consumption using ML
@app.route('/detect_anomalies', methods=['GET'])
@LATENCY.time()  # Track request latency
def detect_anomalies():
    # Count request
    REQUESTS.labels(method='GET', endpoint='/detect_anomalies').inc()

    try:
        # Extract car_id from Cognito token
        car_id = get_car_id_from_token()

        if car_id is None:
            return jsonify({"error": "Unauthorized or Invalid Token"}), 401

        # Query DynamoDB to get the fuel consumption data for the car_id
        response = table.query(
            KeyConditionExpression="car_id = :car_id",
            ExpressionAttributeValues={":car_id": car_id}
        )
        
        # Check if we have data
        if 'Items' not in response or len(response['Items']) == 0:
            return jsonify({"error": "No data found for this car_id"}), 404
        
        # Prepare data for anomaly detection (e.g., using fuel_consumption and timestamp)
        data = response['Items']
        df = pd.DataFrame(data)
        
        # Assuming fuel_consumption is numerical and we want to detect anomalies in it
        consumption_data = df[['fuel_consumption']].values
        
        # Train anomaly detection model and predict
        anomaly_predictions = anomaly_detector.fit_predict(consumption_data)
        
        # Add anomaly results to the dataframe
        df['anomaly'] = anomaly_predictions
        
        # Return anomalies (if any)
        anomalies = df[df['anomaly'] == -1]
        
        return jsonify({
            "anomalies": anomalies.to_dict(orient="records")
        }), 200
    except Exception as e:
        logger.error(f"Error detecting anomalies: {e}")
        ERRORS.labels(method='GET', endpoint='/detect_anomalies').inc()
        return jsonify({"error": "An error occurred while detecting anomalies"}), 500

# Endpoint to get fuel consumption data for a specific car_id
@app.route('/get_consumption', methods=['GET'])
@LATENCY.time()  # Track request latency
def get_consumption():
    # Count request
    REQUESTS.labels(method='GET', endpoint='/get_consumption').inc()

    try:
        # Extract car_id from Cognito token
        car_id = get_car_id_from_token()

        if car_id is None:
            return jsonify({"error": "Unauthorized or Invalid Token"}), 401

        # Query DynamoDB to get the fuel consumption data for the car_id
        response = table.query(
            KeyConditionExpression="car_id = :car_id",
            ExpressionAttributeValues={":car_id": car_id}
        )
        
        # Check if we have data
        if 'Items' not in response or len(response['Items']) == 0:
            return jsonify({"error": "No consumption data found for this car_id"}), 404
        
        # Return the consumption data (fuel_consumption and timestamp)
        fuel_data = [{"timestamp": item["timestamp"], "fuel_consumption": item["fuel_consumption"]} for item in response['Items']]
        
        return jsonify({
            "car_id": car_id,
            "fuel_consumption_data": fuel_data
        }), 200
    except Exception as e:
        logger.error(f"Error fetching fuel consumption: {e}")
        ERRORS.labels(method='GET', endpoint='/get_consumption').inc()
        return jsonify({"error": "An error occurred while fetching data"}), 500

# Start Prometheus HTTP server to expose metrics
if __name__ == '__main__':
    # Start Prometheus metrics server on port 8000
    start_http_server(8000)

    # Run the Flask app
    app.run(debug=True, host='0.0.0.0', port=5000)
