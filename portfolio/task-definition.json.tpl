[
	{
		"name": "${CONTAINER}",
		"essential": true,
		"memory": 512,
		"cpu": 256,
		"image": "${IMAGE}:${TAG}",
		"environment": [],
		"portMappings": [
			{
				"containerPort": ${PORT},
				"hostPort": ${PORT}
			}
		],
		"linuxParameters": {
			"initProcessEnabled": true
		}
	}
]
