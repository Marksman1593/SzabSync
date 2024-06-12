<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle POST request to view all notifications for a student

    // Assuming the POST request contains 'studentID'
    $studentID = $_POST['studentID'] ?? '';

    // Sanitize the inputs (prevent SQL injection)
    $studentID = $conn->real_escape_string($studentID);

    // Select all notifications for the student
    $sql = "SELECT * FROM notifications WHERE studentID = '$studentID' ORDER BY createdAt DESC";
    $result = $conn->query($sql);
    if ($result->num_rows > 0) {
        $notifications = $result->fetch_all(MYSQLI_ASSOC);
        echo json_encode(["status" => 200, "notifications" => $notifications]);
    } else {
        echo json_encode(["status" => 404, "message" => "No notifications found for this student"]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only POST requests are allowed."]);
}
?>