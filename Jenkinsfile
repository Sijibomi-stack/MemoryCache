def secrets = [
  [
      path: 'secrets/jenkins/github',
          engineVersion: 1,
          secretValues: [
           [envVar: 'PRIVATE_TOKEN', vaultKey: 'private-token'],
	   [envVar: 'USERNAME', vaultKey: 'username'],
           [envVar: 'IMAGE_NAME', vaultKey: 'imagename']
      ]
        ]
  ]
def configuration = [vaultUrl: 'http://10.32.0.1:8200',  vaultCredentialId: 'vault-approle', engineVersion: 1]



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
            image: "gcr.io/kaniko-project/executor:debug"
            env:
                - name: GIT_USERNAME
                  valueFrom:
                    secretKeyRef:
                      name: git
                      key: username
                - name: GIT_TOKEN
                  valueFrom:
                    secretKeyRef:
                      name: git
                      key: password
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
    TOKEN="${env.PRIVATE_TOKEN}"
  }
  stages {
     stage('Get a Golang project') {
       steps {
         container('git') {
           git url: 'https://github.com/Sijibomi-stack/embarkStudios.git', branch: 'feature', credentialsId: 'Jenkins-github'
        }
      }
    }
     stage('Test Vault Connection') {
       steps {
         withVault([configuration: configuration, vaultSecrets: secrets]) {
           sh '''
              export 'TOKEN=$(sh "echo ${env.PRIVATE_TOKEN}")'
              echo "${TOKEN}"
              '''
        }
      }
    }
     stage('Build Memory Cache Project') {
       steps {
         container('kaniko') {
           sh '''
	      /kaniko/executor --context $WORKSPACE --destination $IMAGE_NAME:$IMAGE_TAG --build-arg 'GIT_TOKEN="${GIT_TOKEN}"'
	      '''
        }
      }
    }
     stage ('load Deployment Yaml File') {
           steps {
             configFileProvider([configFile(fileId: '62b36d3c-a2ca-46c4-a92c-e1109283a1cc', variable: 'memorycache')]) {
              sh "cat ${env.memorycache}"
               }
           }
        }
        stage ('Deploy') {
           steps {
               withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: 'kubernetes-admin@kubernetes', credentialsId: 'Jenkins-github', namespace: 'devops-tools', restrictKubeConfigAccess: false, serverUrl: '') {
                sh 'curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.26.0/bin/linux/amd64/kubectl"'
                sh 'chmod u+x ./kubectl'
                configFileProvider([configFile(fileId: '62b36d3c-a2ca-46c4-a92c-e1109283a1cc', variable: 'memorycache')]) {
                sh "./kubectl create -f ${env.memorycache}"
                }
                }

            }
        }
  }
}

