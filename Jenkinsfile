pipeline {
    agent {
        kubernetes {
            yaml '''
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              - name: builder
                image: sheayun/jenkins-agent-jdk-17
                command:
                - cat
                tty: true
            '''
        }
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
    }
}
