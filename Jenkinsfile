pipeline {
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        metadata:
          labels:
            app: memorycache
        spec:
          containers:
          - name: git
            image: bitnami/git:latest
            command:
            - cat
            tty: true
          - name: kaniko
            image: gcr.io/kaniko-project/executor:debug
            command:
            - cat
            tty: true
            volumeMounts:
            - name: kaniko-secret
              mountPath: /kaniko/.docker
          volumes:
          - name: kaniko-secret
            secret:
              secretName: dockercred
              items:
                - key: .dockerconfigjson
                  path: config.json
      '''
    }      
  }
  
  environment{
    DOCKERHUB_USERNAME = "adesijibomi"
    APP_NAME = "memorycache"
    IMAGE_NAME = "${DOCKERHUB_USERNAME}" + "/" + "${APP_NAME}"
    IMAGE_TAG = "${BUILD_NUMBER}"
  }
  stages {
     stage('Get a Golang project') {
	   steps {
		 container('git') {
           git url: 'https://github.com/Sijibomi-stack/embarkStudios.git', branch: 'main',credentialsId: 'Jenkins-github'
        }
      }
    }
     stage('Build Java Image') {
	   steps {
         container('kaniko') {
            /kaniko/executor --context $WORKSPACE --destination $IMAGE_NAME:$IMAGE_TAG"
        }
      }
    }
  }
}
