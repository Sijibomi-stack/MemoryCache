pipeline {
    // install golang 1.14 on Jenkins node
    agent {
            kubernetes {
                     yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: golang
    image: golang:1.20
    command:
    - cat
    tty: true
    resources:
      requests:
        memory: 3Gi
        cpu: "2"
      limits:
        memory: 5Gi
    imagePullPolicy: Always
  - name: docker
    image: docker:latest
    command:
    - cat
    tty: true
    volumeMounts:
      - mountPath: /var/run/docker.sock
        name: docker-sock
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
'''
        }
    }
    stages {
            stage("Checkout the project") {
           steps{
	     container('golang'){
               git branch: 'main', credentialsId: 'Jenkins-github', url: 'https://github.com/Sijibomi-stack/embarkStudios.git'
	       sh 'go version'
           }
        
	}
        stage("build") {
            steps { 
	      container('docker'){
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

