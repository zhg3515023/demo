node {
    agent any
    environment {
        HARBOR_CREDS = credentials('jenkins-harbor-creds')
        GIT_TAG = sh(returnStdout: true,script: 'git describe --tags --always').trim()
    }
    parameters {
        string(name: 'HARBOR_HOST', defaultValue: '172.18.30.107', description: 'harbor仓库地址')
        string(name: 'DOCKER_IMAGE', defaultValue: 'test_habor/pipeline-demo', description: 'docker镜像名')
        string(name: 'APP_NAME', defaultValue: 'pipeline-demo', description: 'k8s中标签名')
        string(name: 'K8S_NAMESPACE', defaultValue: 'demo', description: 'k8s的namespace名称')
    }
    stages {
        stage('Maven Build') {
            when { expression { env.GIT_TAG != null } }
            agent {
                docker {
                    image 'maven:3-jdk-8-alpine'
                    args '-v $HOME/.m2:/root/.m2'
                }
            }
            steps {
                sh 'mvn clean package -Dfile.encoding=UTF-8 -DskipTests=true'
                stash includes: 'target/*.jar', name: 'app'
            }

        }
        stage('Docker Build') {
            when { 
                allOf {
                    expression { env.GIT_TAG != null }
                }
            }
            agent any
            steps {
                unstash 'app'
                sh "docker login -u ${HARBOR_CREDS_USR} -p ${HARBOR_CREDS_PSW} ${params.HARBOR_HOST}"
                sh "docker build --build-arg JAR_FILE=`ls target/*.jar |cut -d '/' -f2` -t ${params.HARBOR_HOST}/${params.DOCKER_IMAGE}:${GIT_TAG} ."
                sh "docker push ${params.HARBOR_HOST}/${params.DOCKER_IMAGE}:${GIT_TAG}"
                sh "docker rmi ${params.HARBOR_HOST}/${params.DOCKER_IMAGE}:${GIT_TAG}"
            }
            
        }
        stage('Deploy') {
            when { 
                allOf {
                    expression { env.GIT_TAG != null }
                }
            }
            agent {
                docker {
                    image 'lwolf/helm-kubectl-docker'
                }
            }
            steps {
                sh "sed -e 's#{IMAGE_URL}#${params.HARBOR_HOST}/${params.DOCKER_IMAGE}#g;s#{IMAGE_TAG}#${GIT_TAG}#g;s#{APP_NAME}#${params.APP_NAME}#g;s#{SPRING_PROFILE}#k8s-test#g' k8s-deployment.tpl > k8s-deployment.yml"
                sh "kubectl apply -f k8s-deployment.yml --namespace=${params.K8S_NAMESPACE}"
            }
            
        }
        
    }
}
