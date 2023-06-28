[
	{
		"name": "${CONTAINER}",
		"essential": true,
		"memory": 1024,
		"cpu": 512,
		"image": "${IMAGE}:${TAG}",
		"environment": ${ENVIRONMENT},
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
