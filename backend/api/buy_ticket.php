<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle POST request to buy a ticket

    // Assuming the POST request contains 'eventID' and 'studentID'
    $eventID = $_POST['eventID'] ?? '';
    $studentID = $_POST['studentID'] ?? '';
    $createdAt = $_POST['createdAt'] ?? ''; // Current date and time

    // Sanitize the inputs (prevent SQL injection)
    $eventID = $conn->real_escape_string($eventID);
    $studentID = $conn->real_escape_string($studentID);

    // Create a row in the tickets table
    $sql = "INSERT INTO tickets (eventID, studentID, createdAt) VALUES ('$eventID', '$studentID', '$createdAt')";
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => 200, "message" => "Ticket bought successfully"]);
    } else {
        echo json_encode(["status" => 500, "message" => "Error buying ticket: " . $conn->error]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only POST requests are allowed."]);
}
?>