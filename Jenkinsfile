podTemplate(yaml: '''
    apiVersion: v1
    kind: Pod
    spec:
      containers:
      - name: git
        image: bitnami/git:latest
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
      steps {
        container('git') {
          git url: 'https://github.com/Sijibomi-stack/embarkStudios.git', branch: 'main',credentialsId: 'Jenkins-github'
        }
      }
    }

    stage('Build Golang Image') {
      steps {
        container('kaniko') {
            /kaniko/executor --context `pwd` --destination adesijibomi/memorycache:1.0
        }
      }
    }

  }
}

