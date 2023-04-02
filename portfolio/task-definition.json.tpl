[
	{
		"name": "worker",
		"essential": true,
		"memory": 512,
		"cpu": 256,
		"image": "${IMAGENAME}:latest",
		"environment": [],
		"portMappings": [
			{
				"containerPort": 3000,
				"hostPort": 3000
			}
		]
	}
]