async function fetchUserProfile(accessToken) {
    try {
        const response = await fetch('https://graph.microsoft.com/v1.0/me', {
            headers: {
                Authorization: `Bearer ${accessToken}`,
            },
        });

        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }

        const userProfile = await response.json();
        console.log('User Profile:', userProfile);
    } catch (err) {
        console.error('Error fetching user profile:', err);
    }
}


// Replace with the access token you just received
fetchUserProfile('EwB4A8l6BAAUbDba3x2OMJElkF7gJ4z/VbCPEz0AARb/jq8V2D7w3mcUbVsdhsDch4v4iwS5UZ/2tPZjw00WrHmiMl0xrUc8N+YcE1+UIrGANccAiLNPskICM72zFr0ajs25QsLKVJoVQbJug+NrXkElvOiuS4zg24C/SDzsF7eIElRvb7oroRmOmVGBK+RjrbydLTEDbWJjzK47ZoHuiydnOXKL0MC6tv4wH3vD568slWQoxhth3SBnSeBPllPoMOnDQNVsMlhakcpVfrG8s1nKoJE1998leQgzOUAQSg1W4s8VcNZF/axhJu80gjUzEam5uCf9ECksdawnJn6dsxWx8JOIWDsDYHQ1RCcRRjLLNQZpj0cDpMFf6Z++aFoQZgAAEBEr++Fk0fYnqKmmQp63M7NAAmnZg5n8O5+GGWnqTnrKyoVDJwPxKE1fZLIWuDVQhlVM5fzIcaK7cX7Ic11L0tjx3vz+jeghN5eBkpyDKoePUanyv8eOKVuJ6W2C9TeG2SwSio5X9FF0aXgzWf6z6lE9LgPBfrqKPzIcng7KMZ5M6sI7NWuJ0+vrFjHC0jUJ71M9jh4va5NYOw/a6BJjuSwlqBiU1pDGONNt0lHPqV1e0llDgnNmjTeOT0OmMvUAcgwF2zY7fPLe1/ZZLSYjTKp+P86ucMzuyFkGUVNSwmgL4ZWeDfZMHQbmFyvw6p4nDt5oFTjmRcBCmm4QcHeE6LZKc6orz54mUue1p323pfhqMkh2cbIybeAp6/1KJH8tfM4X7SQPHthSZAIAaBx2tZ0k+5ZQdwy5HJDz3JL150z4xKB2nrTo4H5V1cEADz+p/YbELA4rYgyae+lnDjdEZ3WtYon3tWKJxaS8wP119uKOz1Jt8PY0sASNWu0JRR5ATqktcf9wN1jdzHnIYHlqRYQa3//YoA7bvEKVkdNQ+2LKAouWDY4KiKuxUL7TQLafbPxPBOkd1AIPu5JCKve30e5Oelw1nLaGTL9ne65aalXGDXsCsQj03THSsPGcGX4FDeg9bbFnoarbASY7tY2ffdYJSZc5Z7dk71AV9b1blneuLXfGBkOIDvKp0tNEKqplUVVlBHJ/YF2D7GQmRoe3vUiJU6HLyFUa7ucleYirpNk/SaTUkawak9KPsDnaxeknJNbWh+01PllTuhUNJNaHCDEquHsC');
