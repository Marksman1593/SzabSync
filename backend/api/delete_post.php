<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle POST request to delete post

    // Assuming the POST request contains 'postID'
    $postID = $_POST['postID'] ?? '';

    // Sanitize the input (prevent SQL injection)
    $postID = $conn->real_escape_string($postID);

    // Delete the post from the database
    $sql = "DELETE FROM posts WHERE id = '$postID'";
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => 200, "message" => "Post deleted successfully!"]);
    } else {
        echo json_encode(["status" => 500, "message" => "Error: " . $conn->error]);
    }
} else {
    echo json_encode(["status" => 405, "message" => "Invalid request method. Only POST requests are allowed."]);
}
?>