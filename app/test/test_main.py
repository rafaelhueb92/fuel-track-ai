import unittest
from unittest.mock import patch, MagicMock
import json
from app import app  # Assuming your Flask app is in a file named app.py

class TestFuelConsumptionApp(unittest.TestCase):

    @patch('app.dynamodb.resource')
    def test_save_fuel_consumption_success(self, mock_dynamodb):
        # Mock DynamoDB response
        mock_table = MagicMock()
        mock_dynamodb.return_value.Table.return_value = mock_table
        
        mock_table.put_item.return_value = {
            'ResponseMetadata': {'HTTPStatusCode': 200}
        }

        # Simulate a successful POST request
        with app.test_client() as client:
            response = client.post('/save_fuel_consumption', 
                                   json={'fuel_consumption': 10.5, 'timestamp': '2025-02-25T12:00:00Z'},
                                   headers={'Authorization': 'Bearer test_token'})
            
            self.assertEqual(response.status_code, 200)
            self.assertIn('message', json.loads(response.data))

    @patch('app.dynamodb.resource')
    def test_save_fuel_consumption_missing_token(self, mock_dynamodb):
        # Simulate missing token scenario
        with app.test_client() as client:
            response = client.post('/save_fuel_consumption', 
                                   json={'fuel_consumption': 10.5},
                                   headers={})
            
            self.assertEqual(response.status_code, 401)
            self.assertIn('error', json.loads(response.data))

    @patch('app.dynamodb.resource')
    def test_save_fuel_consumption_missing_data(self, mock_dynamodb):
        # Mock DynamoDB response
        mock_table = MagicMock()
        mock_dynamodb.return_value.Table.return_value = mock_table
        
        with app.test_client() as client:
            response = client.post('/save_fuel_consumption', 
                                   json={},
                                   headers={'Authorization': 'Bearer test_token'})
            
            self.assertEqual(response.status_code, 400)
            self.assertIn('error', json.loads(response.data))

    @patch('app.dynamodb.resource')
    def test_detect_anomalies_success(self, mock_dynamodb):
        # Mock DynamoDB query response
        mock_table = MagicMock()
        mock_dynamodb.return_value.Table.return_value = mock_table
        
        mock_table.query.return_value = {
            'Items': [{'car_id': '123', 'fuel_consumption': 10.5, 'timestamp': '2025-02-25T12:00:00Z'}]
        }

        # Simulate a successful GET request
        with app.test_client() as client:
            response = client.get('/detect_anomalies', headers={'Authorization': 'Bearer test_token'})
            
            self.assertEqual(response.status_code, 200)
            self.assertIn('anomalies', json.loads(response.data))

    @patch('app.dynamodb.resource')
    def test_get_consumption_success(self, mock_dynamodb):
        # Mock DynamoDB query response
        mock_table = MagicMock()
        mock_dynamodb.return_value.Table.return_value = mock_table
        
        mock_table.query.return_value = {
            'Items': [{'car_id': '123', 'fuel_consumption': 10.5, 'timestamp': '2025-02-25T12:00:00Z'}]
        }

        # Simulate a successful GET request
        with app.test_client() as client:
            response = client.get('/get_consumption', headers={'Authorization': 'Bearer test_token'})
            
            self.assertEqual(response.status_code, 200)
            self.assertIn('fuel_consumption_data', json.loads(response.data))

    @patch('app.dynamodb.resource')
    def test_get_consumption_no_data(self, mock_dynamodb):
        # Mock DynamoDB query response with no data
        mock_table = MagicMock()
        mock_dynamodb.return_value.Table.return_value = mock_table
        
        mock_table.query.return_value = {'Items': []}

        # Simulate a GET request with no data found
        with app.test_client() as client:
            response = client.get('/get_consumption', headers={'Authorization': 'Bearer test_token'})
            
            self.assertEqual(response.status_code, 404)
            self.assertIn('error', json.loads(response.data))

    @patch('app.dynamodb.resource')
    def test_save_fuel_consumption_error(self, mock_dynamodb):
        # Mock an error from DynamoDB
        mock_table = MagicMock()
        mock_dynamodb.return_value.Table.return_value = mock_table
        
        mock_table.put_item.side_effect = Exception("DynamoDB error")

        # Simulate a POST request that raises an exception
        with app.test_client() as client:
            response = client.post('/save_fuel_consumption', 
                                   json={'fuel_consumption': 10.5, 'timestamp': '2025-02-25T12:00:00Z'},
                                   headers={'Authorization': 'Bearer test_token'})
            
            self.assertEqual(response.status_code, 500)
            self.assertIn('error', json.loads(response.data))


if __name__ == '__main__':
    unittest.main()
