<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle POST request to edit category

    // Assuming the POST request contains 'id', 'name', 'iconData', and 'status'
    $id = $_POST['id'] ?? '';
    $name = $_POST['name'] ?? '';
    $iconData = $_POST['iconData'] ?? '';
    $status = $_POST['status'] ?? '';

    // Sanitize the input (prevent SQL injection)
    $id = $conn->real_escape_string($id);
    $name = $conn->real_escape_string($name);
    $iconData = $conn->real_escape_string($iconData);
    $status = $conn->real_escape_string($status);

    // Update the category in the database
    $sql = "UPDATE categories SET name = '$name', iconData = '$iconData', status = '$status' WHERE id = $id";
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => 200, "message" => "Category updated successfully!"]);
    } else {
        echo json_encode(["status" => 500, "message" => "Error: " . $conn->error]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only POST requests are allowed."]);
}
?>