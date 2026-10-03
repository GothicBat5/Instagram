
<?php
    if ($_SERVER["REQUEST_METHOD"] == "POST") 
    {
        $action = $_POST["action"] ?? "";

        if ($action == "login") 
        {
            header("Location: next.php");
            exit;
        }

        if ($action == "signin") 
        {
            header("Location: signin.php");
            exit;
        }
    }
?>

<html>
<head>
    <title>My Things | Login</title>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }

        body {
            background: linear-gradient(135deg, #141e30, #243b55);
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .login-box {
            background-color: white;
            width: 350px;
            padding: 35px;
            border-radius: 15px;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }

        .login-box h1 {
            margin-bottom: 10px;
            color: #243b55;
        }

        .login-box p {
            color: #777;
            margin-bottom: 25px;
            font-size: 14px;
        }

        .login-box input {
            width: 100%;
            padding: 12px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 8px;
            outline: none;
            font-size: 14px;
        }

        .login-box input:focus {
            border-color: #243b55;
        }

        .login-box button {
            width: 100%;
            padding: 12px;
            margin-top: 10px;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            cursor: pointer;
            transition: 0.3s;
        }

        .login-btn {
            background-color: #243b55;
            color: white;
        }

        .login-btn:hover {
            background-color: #141e30;
        }

        .signin-btn {
            background-color: #e9eef5;
            color: #243b55;
        }

        .signin-btn:hover {
            background-color: #d5dfec;
        }

        .footer {
            margin-top: 20px;
            font-size: 12px;
            color: #999;
        }
    </style>
</head>

<body>

    <div class="login-box">
        <h1>Welcome!</h1>
        <p>Log in to continue to My Things.</p>

        <form method="POST" action="">
            <input
                type="text"
                name="username"
                placeholder="Username"
                required
            >

            <input
                type="password"
                name="password"
                placeholder="Password"
                required
            >

            <button
                type="submit"
                name="action"
                value="login"
                class="login-btn"
            >
                Log In
            </button>

            <button
                type="submit"
                name="action"
                value="signin"
                class="signin-btn"
            >
                Sign In
            </button>
        </form>
    </div>

</body>
</html>
