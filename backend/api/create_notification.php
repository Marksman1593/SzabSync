<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle POST request to create a new notification

    // Assuming the POST request contains 'title', 'subtitle', 'studentID', 'isRead', and 'isGlobal'
    $title = $_POST['title'] ?? '';
    $subtitle = $_POST['subtitle'] ?? '';
    $studentID = $_POST['studentID'] ?? '';
    $isRead = $_POST['isRead'] ?? 0;
    $isGlobal = $_POST['isGlobal'] ?? 0;
    $createdAt = $_POST['createdAt'] ?? 0; // Current date and time

    // Sanitize the inputs (prevent SQL injection)
    $title = $conn->real_escape_string($title);
    $subtitle = $conn->real_escape_string($subtitle);
    $studentID = $conn->real_escape_string($studentID);
    $isRead = $conn->real_escape_string($isRead);
    $isGlobal = $conn->real_escape_string($isGlobal);

    // Create a row in the notifications table
    $sql = "INSERT INTO notifications (title, subtitle, createdAt, studentID, isRead, isGlobal) VALUES ('$title', '$subtitle', '$createdAt', '$studentID', '$isRead', '$isGlobal')";
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => 200, "message" => "Notification created successfully"]);
    } else {
        echo json_encode(["status" => 500, "message" => "Error creating notification: " . $conn->error]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only POST requests are allowed."]);
}
?>