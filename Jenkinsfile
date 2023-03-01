
podTemplate(yaml: '''
    apiVersion: v1
    kind: Pod
    spec:
      containers:
      - name: golang
        image: golang:1.20
        command:
        - sleep
        args:
        - 99d
      - name: kaniko
        image: gcr.io/kaniko-project/executor:debug
        command:
        - sleep
        args:
        - 9999999
        volumeMounts:
        - name: kaniko-secret
          mountPath: /kaniko/.docker
      restartPolicy: Never
      volumes:
      - name: kaniko-secret
        secret:
            secretName: dockercred
            items:
            - key: .dockerconfigjson
              path: config.json
''') {
  node(POD_LABEL) {
    stage('Get a Golang project') {
      git url: 'https://github.com/Sijibomi-stack/embarkStudios.git', branch: 'main',credentialsId: 'Jenkins-github'
      container('golang') {
        stage('Build a Maven project') {
          sh '''
          echo pwd
          '''
        }
      }
    }

    stage('Build Java Image') {
      container('kaniko') {
        stage('Build a Go project') {
          sh '''
            /kaniko/executor --context `pwd` --destination adesijibomi/memorycache:1.0
          '''
        }
      }
    }

  }
}
