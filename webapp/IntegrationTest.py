import unittest
import app from ./webapp
import os

class TestHealthz(unittest.TestCase):

    def test_health_check():
        app = webapp.test_client()
        response = app.get('/healthz')
        assertEqual(response.status_code, 200)

if __name__ == '__main__':
    unittest.main()

