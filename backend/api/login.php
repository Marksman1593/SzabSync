<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle POST request to check user credentials

    // Assuming the POST request contains 'email' and 'password'
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';

    // Sanitize the input (prevent SQL injection)
    $email = $conn->real_escape_string($email);

    // Fetch the user's details from the database
    $sql = "SELECT * FROM students WHERE email = '$email'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $hashedPassword = $row['password'];

        // Verify the entered password with the hashed password
        if (password_verify($password, $hashedPassword)) {
            // Remove password from the user details
            unset($row['password']);
            echo json_encode(["status" => 200, "message" => "Login successful!", "account" => $row]);
        } else {
            echo json_encode(["status" => 401, "message" => "Invalid password"]);
        }
    } else {
        echo json_encode(["status" => 404, "message" => "User not found"]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only POST requests are allowed."]);
}
?>