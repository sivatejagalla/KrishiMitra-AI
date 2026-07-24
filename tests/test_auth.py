def test_user_registration_and_login(client):
    """Test user registration, login, and fetching authenticated user profile."""
    user_payload = {
        "email": "testuser@agrolith.ai",
        "password": "secretpassword123",
        "full_name": "Test Farmer"
    }

    # 1. Register User
    reg_response = client.post("/api/v1/auth/register", json=user_payload)
    assert reg_response.status_code == 201
    user_data = reg_response.json()
    assert user_data["email"] == "testuser@agrolith.ai"
    assert user_data["full_name"] == "Test Farmer"
    assert "id" in user_data

    # 2. Register Duplicate User should fail with 409
    dup_response = client.post("/api/v1/auth/register", json=user_payload)
    assert dup_response.status_code == 409

    # 3. Login User
    login_payload = {
        "email": "testuser@agrolith.ai",
        "password": "secretpassword123"
    }
    login_response = client.post("/api/v1/auth/login", json=login_payload)
    assert login_response.status_code == 200
    token_data = login_response.json()
    assert "access_token" in token_data
    assert token_data["token_type"] == "bearer"

    # 4. Get Current User profile using Bearer Token
    token = token_data["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    me_response = client.get("/api/v1/auth/me", headers=headers)
    assert me_response.status_code == 200
    me_data = me_response.json()
    assert me_data["email"] == "testuser@agrolith.ai"
    assert me_data["full_name"] == "Test Farmer"


def test_invalid_login(client):
    """Test login with incorrect password fails with 401."""
    login_payload = {
        "email": "testuser@agrolith.ai",
        "password": "wrongpassword"
    }
    response = client.post("/api/v1/auth/login", json=login_payload)
    assert response.status_code == 401
