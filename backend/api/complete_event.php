<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle POST request to mark an event as complete

    // Assuming the POST request contains 'eventID'
    $eventID = $_POST['eventID'] ?? '';

    // Sanitize the input (prevent SQL injection)
    $eventID = $conn->real_escape_string($eventID);

    // Update the event's status in the database
    $sql = "UPDATE events SET status = 'complete' WHERE id = '$eventID'";
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => 200, "message" => "Event marked as complete successfully!"]);
    } else {
        echo json_encode(["status" => 500, "message" => "Error: " . $conn->error]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only POST requests are allowed."]);
}
?>