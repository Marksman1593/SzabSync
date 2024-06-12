<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle POST request to fetch data

    // Initialize response array
    $response = array();

    // Get total number of students
    $result = $conn->query("SELECT COUNT(*) as total FROM students");
    $response['total_students'] = $result->fetch_assoc()['total'];

    // Get total number of tickets
    $result = $conn->query("SELECT COUNT(*) as total FROM tickets");
    $response['total_tickets'] = $result->fetch_assoc()['total'];

    // Get total number of events
    $result = $conn->query("SELECT COUNT(*) as total FROM events");
    $response['total_events'] = $result->fetch_assoc()['total'];

    // Get total number of 'active' events
    $result = $conn->query("SELECT COUNT(*) as total FROM events WHERE status = 'active'");
    $response['total_active_events'] = $result->fetch_assoc()['total'];

    // Return success response
    echo json_encode(["status" => 200, "message" => "Data fetched successfully!", "data" => $response]);
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only POST requests are allowed."]);
}
?>