<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle POST request to create a post and its attachments

    // Assuming the POST request contains 'eventID', 'textContent', 'createdAt', and 'attachments'
    $eventID = $_POST['eventID'] ?? '';
    $textContent = $_POST['textContent'] ?? '';
    $createdAt = $_POST['createdAt'] ?? '';
    $attachments = $_POST['attachments'] ?? [];

    // Sanitize the inputs (prevent SQL injection)
    $eventID = $conn->real_escape_string($eventID);
    $textContent = $conn->real_escape_string($textContent);
    $createdAt = $conn->real_escape_string($createdAt);

    // Create the post in the database
    $sql = "INSERT INTO posts (eventID, textContent, likesCount, createdAt) VALUES ('$eventID', '$textContent', 0, '$createdAt')";
    if ($conn->query($sql) === TRUE) {
        $postID = $conn->insert_id;

        // Create the attachments in the database
        foreach ($attachments as $attachment) {
            $contentURL = $conn->real_escape_string($attachment['contentURL']);
            $type = $conn->real_escape_string($attachment['type']);

            $sql = "INSERT INTO attachments (postID, contentURL, type) VALUES ('$postID', '$contentURL', '$type')";
            if ($conn->query($sql) !== TRUE) {
                echo json_encode(["status" => 500, "message" => "Error creating attachment: " . $conn->error]);
                exit;
            }
        }

        echo json_encode(["status" => 200, "message" => "Post and attachments created successfully"]);
    } else {
        echo json_encode(["status" => 500, "message" => "Error creating post: " . $conn->error]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only POST requests are allowed."]);
}
?>