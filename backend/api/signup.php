<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle POST request to create a new user

    // Assuming the POST request contains 'email', 'name', 'password', and 'studentID'
    $email = $_POST['email'] ?? '';
    $name = $_POST['name'] ?? '';
    $password = $_POST['password'] ?? '';
    $studentID = $_POST['studentID'] ?? '';

    // Sanitize the input (prevent SQL injection)
    $email = $conn->real_escape_string($email);
    $name = $conn->real_escape_string($name);
    $studentID = $conn->real_escape_string($studentID);

    // Hash the password
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

    // Insert the new user into the database
    $sql = "INSERT INTO students (email, name, password, studentID) VALUES ('$email', '$name', '$hashedPassword', '$studentID')";
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => 200, "message" => "Signup successful!"]);
    } else {
        echo json_encode(["status" => 500, "message" => "Error: " . $conn->error]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only POST requests are allowed."]);
}
?>