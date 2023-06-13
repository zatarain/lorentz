[
	{
		"name": "${CONTAINER}",
		"essential": true,
		"memory": 512,
		"cpu": 256,
		"image": "${IMAGE}:${TAG}",
		"environment": [
			{
				"name": "API_URL",
				"value": "${API_URL}"
			},
			{
				"name": "NODE_ENV",
				"value": "production"
			}
		],
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
