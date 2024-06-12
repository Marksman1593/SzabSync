<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Handle GET request to view all events for a specific category

    // Assuming the GET request contains 'category'
    $category = $_GET['category'] ?? '';

    // Sanitize the input (prevent SQL injection)
    $category = $conn->real_escape_string($category);

    // Fetch the events from the database
    $sql = "SELECT * FROM events WHERE category = '$category'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $events = [];
        while($row = $result->fetch_assoc()) {
            $events[] = $row;
        }
        echo json_encode(["status" => 200, "message" => "Events found", "events" => $events]);
    } else {
        echo json_encode(["status" => 404, "message" => "No events found for this category"]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only GET requests are allowed."]);
}
?>