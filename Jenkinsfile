pipeline {
  agent {
    kubernetes {
      label 'jenkins-build-golang-pod'
      yamlFile 'KubernetesPod.yaml'
    }
  }
  environment {
    // get the project path from src
    // PROJECT_PATH = sh(returnStdout: true, script: 'basename ${GIT_URL} .git').trim()
    // get the project path from src/*/...
    // PROJECT_PATH = sh(returnStdout: true, script: 'echo ${GIT_URL#*//} | cut -d '.' -f 1-2').trim()
    
    // get the project name
    PROJECT_NAME = sh(returnStdout: true, script: 'basename ${GIT_URL} .git').trim()
  }
  parameters { 
    string(name: 'DOCKER_REGISTRY', defaultValue: 'docker.bb-app.cn', description: 'docker registry') 
  }
  stages {
    stage('环境') {
      parallel {
        stage('Slave') {
          steps {
            sh 'set'
            sh 'pwd'
            sh 'ls -al '
          }
        }
        stage('Golang') {
          steps {
            container('golang') {
              sh 'set'
              sh 'pwd'
              sh 'ls -al'
              sh 'make --version'
              sh 'git version'
              sh 'go env'
            }
          }
        }
      }
    }
    stage('安装依赖包') {
      steps {
        container('golang') {
          sh 'make install-package'
        }
      }
    }
    stage('编译') {
      steps {
        container('golang') {
          sh 'make go-build'
        }
      }
    }
    stage('测试') {
      parallel {
        stage('单元测试'){
          steps {
            container('golang') {
              sh 'make go-test'
            }
          }
        }
        stage('接口测试') {
          steps {
            container('golang') {
              sh 'date'
            }
          }
        }
        stage('集成测试') {
          steps {
            container('golang') {
              sh 'date'
            }
          }
        }
      }
    } 
    stage('Docker') {
      steps {
        container('docker') {
          sh '''
            echo '${params.DOCKER_REGISTRY}'
          '''
          sh 'docker build . --tag ${PROJECT_NAME}:${GIT_COMMIT::7}'
          sh 'docker images'
        }
      }
    }
    stage('部署') {
      steps {
        sh 'date'
      }
    }
  }
}