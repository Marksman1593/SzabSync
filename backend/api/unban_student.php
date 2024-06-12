<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle POST request to ban a student

    // Assuming the POST request contains 'studentID'
    $studentID = $_POST['studentID'] ?? '';

    // Sanitize the input (prevent SQL injection)
    $studentID = $conn->real_escape_string($studentID);

    // Update the student's status in the database
    $sql = "UPDATE students SET status = 'active' WHERE studentID = '$studentID'";
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => 200, "message" => "Student unbanned successfully!"]);
    } else {
        echo json_encode(["status" => 500, "message" => "Error: " . $conn->error]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only POST requests are allowed."]);
}
?>