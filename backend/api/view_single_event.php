<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Handle GET request to view a single event

    // Assuming the GET request contains 'id'
    $id = $_GET['id'] ?? '';

    // Sanitize the input (prevent SQL injection)
    $id = $conn->real_escape_string($id);

    // Fetch the event from the database
    $sql = "SELECT * FROM events WHERE id = '$id'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $event = $result->fetch_assoc();
        echo json_encode(["status" => 200, "message" => "Event found", "event" => $event]);
    } else {
        echo json_encode(["status" => 404, "message" => "No event found with this id"]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only GET requests are allowed."]);
}
?>