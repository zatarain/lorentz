[
	{
		"name": "${CONTAINER}",
		"essential": true,
		"memory": 512,
		"cpu": 256,
		"image": "${IMAGE}:latest",
		"environment": [],
		"portMappings": [
			{
				"containerPort": 3000,
				"hostPort": 3000
			}
		]
	}
]