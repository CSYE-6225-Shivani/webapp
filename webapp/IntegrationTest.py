import unittest
from webapp import app
import os

class TestHealthz(unittest.TestCase):

    def test_health_check(self):
        app = webapp.test_client()
        response = app.get('/healthz')
        self.assertEqual(response.status_code, 200)

if __name__ == '__main__':
    unittest.main()

