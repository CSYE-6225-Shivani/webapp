import unittest
from webapp import app
import os

class TestHealthz(unittest.TestCase):

    def test_health_check(self):
        client = app.test_client()
        response = client.get('/healthz')
        self.assertEqual(response.status_code, 200)
        print("Received response code: ", response.status_code, " from /healthz endpoint!")
        print("=========TEST PASSED!==========")

if __name__ == '__main__':
    unittest.main()

