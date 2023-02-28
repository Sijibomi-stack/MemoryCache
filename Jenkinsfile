pipeline {
    // install golang 1.14 on Jenkins node
    agent {
            kubernetes {
                     yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: memorycacheapp
    image: alpine
    command:
    - sleep
    args:
    - infinity
'''
        }
    }

    tools {
        go 'go1.20'
    }
    environment {
        GO114MODULE = 'on'
        CGO_ENABLED = 0
        GOPATH = "${JENKINS_HOME}/jobs/${JOB_NAME}/builds/${BUILD_ID}"
        DOCKERHUB_CREDENTIALS = credentials('Jenkins-docker')
    }
    stages {
            stage("Checkout the project") {
           steps{
               git branch: 'main', credentialsId: 'Jenkins-github', url: 'https://github.com/Sijibomi-stack/embarkStudios.git'
           }
        }
        stage("build") {
            steps { 
	        script {
	      
                echo 'BUILD EXECUTION STARTED'
                sh 'go version'
                sh 'docker build . -t Sijibomi-stack/embarkStudios'
		}
            }
        }
        stage('Login') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
           }
       }
        stage('Push') {
            steps {
                sh 'docker push Sijibomi-stack/embarkStudios'
           }
       }
    }
    post {
    always {
      sh 'docker logout'
    }
  }
}

