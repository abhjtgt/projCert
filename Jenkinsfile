pipeline {
    agent {
        label 'jenslave'
    }

    stages {
        stage('Get Sourcecode') {
            steps {
                echo 'Getting sourcecode from github'
                git credentialsId: 'github-cred', poll: false, url: 'https://github.com/abhjtgt/projCert'
            }
            post {
                success {
                    echo "Sourcecode downloaded. "
                }
            }
        }
        stage('Install Docker on Test server') {
            steps {
                echo 'Installing docker on Test server'
                sh "ansible-playbook -i hosts play_install.yaml"
            }
            post {
                success {
                    echo "Installation successful. "
                }
            }
        }
        stage('Build docker images locally') {
            steps {
                echo 'Building docker images' + env.BUILD_NUMBER
                sh "docker build -t abhjtdk/projcert:${BUILD_NUMBER} ."
                echo 'Tagging the new image to latest'
                sh "docker tag abhjtdk/projcert:${BUILD_NUMBER} abhjtdk/projcert:latest"
            }
            post {
                success {
                    echo "Docker image created successfully. "
                }
            }
        }
        stage('Test image') {
            steps {
                echo 'Running the image locally' 
                sh '''
                    docker run -d --name projcert-${BUILD_NUMBER} -p 8081:80 abhjtdk/projcert:latest
                    sleep 10
                    curl -s 127.0.0.1:8081/index.php | grep title >/dev/null
                    
                    if [ $? -ne 0 ]
                    then
                        echo "Website isn't up"
                    else
                        echo "Website is up"
                    fi
                '''
            }
            post {
                success {
                    echo "Test successful. "
                }
                failure {
                    echo "Test unsuccessful."
                }
                cleanup {
                    echo "Clearing running container. "
                    sh "docker rm --force projcert-${BUILD_NUMBER}"
                }
                
            }
        }
        stage('Upload image to dockerhub') {
            steps {
                echo 'Pushing the image to docker hub. '
                sh '''
                   docker push abhjtdk/projcert:${BUILD_NUMBER}
                   docker push abhjtdk/projcert:latest
                '''
            }
            post {
                success {
                    echo "Docker push successful. "
                }
            }
        }
        stage('Deploy app to Test server') {
            steps {
                echo 'Deploying the app to test server'
                sh '''
                   ansible-playbook -i hosts play_run.yaml --extra-vars "tag=$BUILD_NUMBER"
                '''
            }
            post {
                success {
                    echo "Installation successful. "
                }
            }
        }
        
    }
}
