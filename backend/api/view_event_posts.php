<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle POST request to view all posts for a single event

    // Assuming the POST request contains 'eventID'
    $eventID = $_POST['eventID'] ?? '';

    // Sanitize the input (prevent SQL injection)
    $eventID = $conn->real_escape_string($eventID);

    // Fetch the posts from the database
    $sql = "SELECT * FROM posts WHERE eventID = '$eventID'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $posts = [];
        while($row = $result->fetch_assoc()) {
            $posts[] = $row;
        }
        echo json_encode(["status" => 200, "message" => "Posts found", "posts" => $posts]);
    } else {
        echo json_encode(["status" => 404, "message" => "No posts found for this event"]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only POST requests are allowed."]);
}
?>