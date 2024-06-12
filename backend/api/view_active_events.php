<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Handle GET request to view all active events

    // Fetch the active events from the database
    $sql = "SELECT * FROM events WHERE status = 'active'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $events = [];
        while($row = $result->fetch_assoc()) {
            $events[] = $row;
        }
        echo json_encode(["status" => 200, "message" => "Active events found", "events" => $events]);
    } else {
        echo json_encode(["status" => 200, "message" => "No active events found"]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only GET requests are allowed."]);
}
?>