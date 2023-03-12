def secrets = [
  [
      path: 'secrets/jenkins/github',
          engineVersion: 1,
          secretValues: [
           [envVar: 'PRIVATE_TOKEN', vaultKey: 'private-token']
      ]
        ]
  ]
def configuration = [vaultUrl: 'http://10.32.0.22:8200',  vaultCredentialId: 'vault-approle', engineVersion: 1]



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
           git url: 'https://github.com/Sijibomi-stack/embarkStudios.git', branch: 'main', credentialsId: 'Jenkins-github'
        }
      }
    }
     stage('Vault') {
       steps {
         withVault([configuration: configuration, vaultSecrets: secrets]) {
           sh '''
              set -x
              export TOKEN=$(sh "echo ${env.PRIVATE_TOKEN}")
              '''
        }
      }
    }
     stage('Build Golang Project') {
       steps {
         container('kaniko') {
           sh "/kaniko/executor --context $WORKSPACE --destination $IMAGE_NAME:$IMAGE_TAG"
        }
      }
    }
     stage('Apply Kubernetes files') {
       steps{
         script{
          withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: 'kubernetes-admin@kubernetes', credentialsId: 'Kubernetes-Jenkins', namespace: '', restrictKubeConfigAccess: false, serverUrl: 'https://192.168.56.2:6443') {
           sh 'curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.26.0/bin/linux/amd64/kubectl"'
           sh 'chmod u+x ./kubectl'
	   configFileProvider([configFile(fileId: '62b36d3c-a2ca-46c4-a92c-e1109283a1cc', variable: 'memorycache')]) {
           sh 'envsubst < ${WORKSPACE}/memorycache.yaml | kubectl apply -f -'
	   }
          }
        }
      }
    }
  }
}
