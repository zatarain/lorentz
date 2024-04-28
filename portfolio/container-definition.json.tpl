{
	"name": "${CONTAINER}",
	"essential": true,
	"memory": 512,
	"cpu": 256,
	"image": "${IMAGE}:${TAG}",
	"environment": ${ENVIRONMENT},
	"secrets": ${SECRETS},
	"portMappings": [
		{
			"containerPort": ${PORT},
			"hostPort": ${PORT}
		}
	],
	"logConfiguration": ${LOGS},
	"linuxParameters": {
		"initProcessEnabled": true
	}
}
