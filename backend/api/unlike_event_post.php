<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle POST request to unlike an event post

    // Assuming the POST request contains 'postID' and 'email'
    $postID = $_POST['postID'] ?? '';
    $email = $_POST['email'] ?? '';

    // Sanitize the inputs (prevent SQL injection)
    $postID = $conn->real_escape_string($postID);
    $email = $conn->real_escape_string($email);

    // Delete the row from the likes table
    $sql = "DELETE FROM likes WHERE postID = '$postID' AND email = '$email'";
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => 200, "message" => "Post unliked successfully"]);
    } else {
        echo json_encode(["status" => 500, "message" => "Error unliking post: " . $conn->error]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only POST requests are allowed."]);
}
?>