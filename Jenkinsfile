pipeline {
    agent {
        kubernetes {
            yaml'''
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              - name: jnlp
                image: leeye51456/jnlp-agent-sample
                env:
                - name: DOCKER_HOST
                  value: "tcp://localhost:2375"
              - name: dind
                image: leeye51456/dind
                command:
                - /usr/local/bin/dockerd-entrypoint.sh
                env:
                - name: DOCKER_TLS_CERTDIR
                  value: ""
                securityContext:
                  privileged: true
              - name: builder
                image: leeye51456/jenkins-agent-jdk-17
                command:
                - cat
                tty: true
            '''
        }
    }

    environment {
        REGISTRY_URI = 'registry-service.registry.svc.cluster.local:30100'
        REGISTRY_TAG = '1.0'
    }

    stages {
        stage("Checkout") {
            steps {
                checkout scm
            }
        }

        stage("Compile") {
            steps {
                script {
                    container('builder') {
                        sh "./gradlew compileJava"
                    }
                }
            }
        }

        stage("Unit Test") {
            steps {
                script {
                    container('builder') {
                        sh "./gradlew test"
                        publishHTML(target: [
                            reportDir: 'build/reports/tests/test',
                            reportFiles: 'index.html',
                            reportName: 'JUnit Report'
                        ])
                    }
                }
            }
        }

        stage("Code Coverage") {
            steps {
                script {
                    container('builder') {
                        sh "./gradlew jacocoTestReport"
                        publishHTML(target: [
                            reportDir: 'build/reports/jacoco/test/html',
                            reportFiles: 'index.html',
                            reportName: 'JaCoCo Report'
                        ])
                        sh "./gradlew jacocoTestCoverageVerification"
                    }
                }
            }
        }

        stage("Static Analysis") {
            steps {
                script {
                    container('builder') {
                        sh "./gradlew checkstyleMain"
                        publishHTML(target: [
                            reportDir: 'build/reports/checkstyle',
                            reportFiles: 'main.html',
                            reportName: 'Checkstyle Report'
                        ])
                    }
                }
            }
        }

        stage("Package") {
            steps {
                script {
                    container('builder') {
                        sh "./gradlew build"
                    }
                }
            }
        }

        stage("Docker Build") {
            steps {
                script {
                    dockerImage = docker.build "calculator"
                }
            }
        }

        stage("Docker Push") {
            steps {
                script {
                    docker.withRegistry("https://${REGISTRY_URI}") {
                        dockerImage.push("${REGISTRY_TAG}")
                    }
                }
            }
        }

        stage("Deploy to Staging") {
            steps {
                sh "docker run -d --rm -p 8765:8080 --name calculator \
                    ${REGISTRY_URI}/calculator:${REGISTRY_TAG}"
            }
        }

        stage("Acceptance Test") {
            steps {
                container('builder') {
                    sleep 30
                    sh "./gradlew acceptanceTest -Dcalculator.url=http://localhost:8765"
                    publishHTML(target: [
                        reportDir: 'build/reports/tests/acceptanceTest',
                        reportFiles: 'index.html',
                        reportName: 'Acceptance Test Report'
                    ])
                }
            }
        }
    }

    post {
        always {
            sh "docker stop calculator"
        }
    }
}
