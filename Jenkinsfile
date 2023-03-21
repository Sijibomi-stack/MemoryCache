def secrets = [
  [
      path: 'secrets/jenkins/github',
          engineVersion: 1,
          secretValues: [
           [envVar: 'PRIVATE_TOKEN', vaultKey: 'private-token'],
           [envVar: 'USERNAME', vaultKey: 'username'],
           [envVar: 'REPO_NAME', vaultKey: 'github-username']
      ]
        ],
  ]
def configuration = [vaultUrl: 'http://10.32.0.18:8200',  vaultCredentialId: 'vault-approle', engineVersion: 1]

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
    PRIVATE_TOKEN = vault path: 'secrets/jenkins/github', key: 'private-token', vaultUrl: 'http://10.32.0.18:8200', credentialsId: 'vault-approle', engineVersion: "1"
    USERNAME = vault path: 'secrets/jenkins/github', key: 'username', vaultUrl: 'http://10.32.0.18:8200', credentialsId: 'vault-approle', engineVersion: "1"
    REPO_NAME = vault path: 'secrets/jenkins/github', key: 'github-username', vaultUrl: 'http://10.32.0.18:8200', credentialsId: 'vault-approle', engineVersion: "1"
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
           sh "echo ${env.PRIVATE_TOKEN}"
        }
      }
    }
     stage('Build Memory Cache Project') {
       steps {
         container('kaniko') {
		    wrap([$class: 'VaultBuildWrapper', configuration: [engineVersion: 1, vaultCredentialId: 'vault-approle', vaultUrl: 'http://10.32.0.18:8200'], vaultSecrets: [[path: 'secrets/jenkins/github', secretValues: [[envVar: 'PRIVATE_TOKEN', vaultKey: 'private-token'], [envVar: 'USERNAME', vaultKey: 'username'], [envVar: 'REPO_NAME', vaultKey: 'github-username']]]]]) {
            sh "/kaniko/executor --context $WORKSPACE --destination ${USERNAME} --label 'image'='latest' --build-arg 'GIT_TOKEN'=${PRIVATE_TOKEN} --build-arg 'GIT_USERNAME'=${REPO_NAME}"
           }
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
		sh "./kubectl delete -n devops-tools deployments.apps memorycache"
		sh "./kubectl delete svc -n devops-tools memorychace-k8ssvc"
                sh "./kubectl create -f ${env.memorycache}"
                }
                }

            }
        }
  }
}

