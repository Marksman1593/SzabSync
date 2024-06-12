<?php
// Include the database connection file
include '../db_connection.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Handle POST request to upload a file

    // Check if file was uploaded
    if (isset($_FILES['file'])) {
        $file = $_FILES['file'];

        // Generate a unique name for the file
        $fileName = uniqid() . '-' . basename($file['name']);

        // Specify the directory where the file will be saved
        $uploadDir = 'uploads/';
        $filePath = $uploadDir . $fileName;

        // Move the uploaded file to the upload directory
        if (move_uploaded_file($file['tmp_name'], $filePath)) {
            // Return the download URL
            $downloadURL = 'http://' . $_SERVER['HTTP_HOST'] . '/api/' . $filePath;
            echo json_encode(['status' => 200, 'downloadURL' => $downloadURL]);
        } else {
            echo json_encode(['status' => 500, 'message' => 'Error uploading file']);
        }
    } else {
        echo json_encode(['status' => 400, 'message' => 'No file was uploaded']);
    }
} else {
    echo json_encode(['status' => 405, 'message' => 'Invalid request method. Only POST requests are allowed.']);
}
?>