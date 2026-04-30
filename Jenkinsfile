pipeline{
    agent any
    stages{
        stage("code"){
            steps{
                echo "This is clonning the code"
                git url:"https://github.com/Gurleenkaur-16/3-Tier-NodeJS-End-To-End-Project.git",branch:"main"
            }
        }
        stage("build"){
            steps{
                echo "This is building the code"
                sh "docker build -t 3-tier ."
            }
        }
        stage("push to dockerhub"){
            steps{
                echo "pushing code to dockerhub"
                withCredentials([usernamePassword(credentialsId:"dockerhubCred",passwordVariable:"dockerhubPass",usernameVariable:"dockerhubUser")]){
                    sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPass} "
                    sh "docker tag 3-tier ${env.dockerhubUser}/3-tier"
                    sh "docker push ${env.dockerhubUser}/3-tier "
                }
            }
        }
        stage("deploy"){
            steps{
                echo "This is deploying code"
                sh "docker compose down && docker compose up --build -d"
            }
        }
    }
}
