pipeline {
  agent {
    kubernetes {
      label 'jenkins-build-golang-pod'
      yamlFile 'KubernetesPod.yaml'
    }
  }
  options {
    skipDefaultCheckout(true)
  }
  environment {
    // get the project path from src
    // PROJECT_PATH = sh(returnStdout: true, script: 'basename ${GIT_URL} .git').trim()
    // get the project path from src/*/...
    // PROJECT_PATH = sh(returnStdout: true, script: 'echo ${GIT_URL#*//} | cut -d '.' -f 1-2').trim()

    // get the date
    NOW = sh(returnStdout: true, script: "date '+%Y%m%d%I%M'").trim()
  }
  parameters { 
    string(name: 'DOCKER_REGISTRY', defaultValue: 'docker.bb-app.cn', description: 'docker registry')
    string(name: 'DOCKER_REPO', defaultValue: 'demo', description: 'docker registry repo kind')
  }
  stages {
    stage('检出代码') {
      steps {
        script {
          checkout([
            $class: 'GitSCM',
            branches: scm.branches,
            doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
            extensions: scm.extensions + [
              [$class: 'CleanCheckout'],
              [$class: 'CloneOption', noTags: false, shallow: false, depth: 0, reference: ''],
              [$class: 'LocalBranch', localBranch: '**']
            ],
            userRemoteConfigs: scm.userRemoteConfigs,
          ]).each { 
            k,v -> env.setProperty(k, v) 
          }
          // get the project name
          env.setProperty("PROJECT_NAME", sh(returnStdout: true, script: 'basename ${GIT_URL} .git').trim())
          // get the git tag 
          env.setProperty("GIT_TAG", sh(returnStdout: true, script: "git tag --contains | head -1").trim())
        }
      }
    }
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
        stage('Docker') {
          steps {
            container('docker') {
              sh 'set'
              sh 'pwd'
              sh 'ls -al'
              echo "now: ${NOW}"
              echo "tag: ${GIT_TAG}"
              echo "project name: ${PROJECT_NAME}"
              echo "docker registry: ${params.DOCKER_REGISTRY}"
              echo "docker repo: ${params.DOCKER_REPO}"
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
          script {
            def name = params.DOCKER_REGISTRY + "/" + params.DOCKER_REPO + "/" + env.PROJECT_NAME
            def tag = env.GIT_TAG
            def commit = env.GIT_COMMIT
            def now = env.NOW

            if (tag.length() == 0) {
              tag = commit[0..7]
            }

            if (env.GIT_BRANCH != "master"){
              tag = tag + "-" + env.GIT_BRANCH
            }

            def build = name + ":" + tag

            def tags = []

            tags.add(tag)
            tags.add(tag + "-" + now)

            def image = docker.build(build)
            
            try {
              docker.withRegistry("https://docker.bb-app.cn", "docker.bb-app.cn") {
                tags.each{
                  it -> image.push(it)
                }

                if (env.GIT_BRANCH == "master"){
                  image.push('latest')
                  tags.add('latest')
                } 
              }
            } finally {
              tags.each{
                  sh "docker rmi  ${it}"
                }
            }
          }
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