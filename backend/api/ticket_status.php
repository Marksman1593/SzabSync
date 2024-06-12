<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle POST request to check ticket status

    // Assuming the POST request contains 'eventID' and 'studentID'
    $eventID = $_POST['eventID'] ?? '';
    $studentID = $_POST['studentID'] ?? '';

    // Sanitize the inputs (prevent SQL injection)
    $eventID = $conn->real_escape_string($eventID);
    $studentID = $conn->real_escape_string($studentID);

    // Check if the student has a ticket for the event
    $sql = "SELECT * FROM tickets WHERE eventID = '$eventID' AND studentID = '$studentID'";
    $result = $conn->query($sql);
    if ($result->num_rows > 0) {
        echo json_encode(["status" => 200, "message" => "Student has a ticket for this event"]);
    } else {
        echo json_encode(["status" => 404, "message" => "No ticket found for this student and event"]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only POST requests are allowed."]);
}
?>