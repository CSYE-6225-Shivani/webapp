import unittest
from webapp import app

class TestHealthz(unittest.TestCase):

    def test_health_check(self):
        client = app.test_client()
        response = client.get('/healthz') # Send GET request /healthz endpoint from webapp
        self.assertEqual(response.status_code, 200) # Check if it received 200 in response
        print("Received response code: ", response.status_code, " from /healthz endpoint!")
        print("=========TEST PASSED!==========")

if __name__ == '__main__':
    unittest.main()