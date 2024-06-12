<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle POST request to add category

    // Assuming the POST request contains 'name', 'iconData', and 'status'
    $name = $_POST['name'] ?? '';
    $iconData = $_POST['iconData'] ?? '';
    $status = $_POST['status'] ?? '';

    // Sanitize the input (prevent SQL injection)
    $name = $conn->real_escape_string($name);
    $iconData = $conn->real_escape_string($iconData);
    $status = $conn->real_escape_string($status);

    // Insert the category into the database
    $sql = "INSERT INTO categories (name, iconData, status) VALUES ('$name', '$iconData', '$status')";
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => 200, "message" => "Category added successfully!"]);
    } else {
        echo json_encode(["status" => 500, "message" => "Error: " . $conn->error]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only POST requests are allowed."]);
}
?>