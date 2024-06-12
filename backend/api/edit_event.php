<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle POST request to edit event

    // Assuming the POST request contains 'eventID', 'category', 'title', 'description', 'venue', 'bannerURL', 'status', 'createdAt', and 'event_dates'
    $eventID = $_POST['eventID'] ?? '';
    $category = $_POST['category'] ?? '';
    $title = $_POST['title'] ?? '';
    $description = $_POST['description'] ?? '';
    $venue = $_POST['venue'] ?? '';
    $bannerURL = $_POST['bannerURL'] ?? '';
    $status = $_POST['status'] ?? '';
    $createdAt = $_POST['createdAt'] ?? '';
    $event_dates = $_POST['event_dates'] ?? '';

    // Sanitize the input (prevent SQL injection)
    $eventID = $conn->real_escape_string($eventID);
    $category = $conn->real_escape_string($category);
    $title = $conn->real_escape_string($title);
    $description = $conn->real_escape_string($description);
    $venue = $conn->real_escape_string($venue);
    $bannerURL = $conn->real_escape_string($bannerURL);
    $status = $conn->real_escape_string($status);
    $createdAt = $conn->real_escape_string($createdAt);

    // Update the event in the database
    $sql = "UPDATE events SET category = '$category', title = '$title', description = '$description', venue = '$venue', bannerURL = '$bannerURL', status = '$status', createdAt = '$createdAt' WHERE id = '$eventID'";
    if ($conn->query($sql) === TRUE) {
        // Delete the existing event dates
        $sql = "DELETE FROM event_dates WHERE eventID = '$eventID'";
        $conn->query($sql);

        // Insert the new event dates into the database
        foreach ($event_dates as $date) {
            $date = $conn->real_escape_string($date);
            $sql = "INSERT INTO event_dates (eventID, date) VALUES ('$eventID', '$date')";
            $conn->query($sql);
        }

        echo json_encode(["status" => 200, "message" => "Event updated successfully!"]);
    } else {
        echo json_encode(["status" => 500, "message" => "Error: " . $conn->error]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only POST requests are allowed."]);
}
?>