pipeline{
	agent any
	tools {
		maven 'Maven3'
	}
	options {
		// timestamps in console
		timestamps()
		
		// timeout build if stuck for more than 1 hr
		timeout(time: 1, unit: 'HOURS')
		
		// skip default checkout on every step
		skipDefaultCheckout()
		
		// discard build & log rotator configuration
		buildDiscarder(logRotator(daysToKeepStr: '5', numToKeepStr: '2'))
		
		// avoid concurrent builds
		disableConcurrentBuilds()
	}
	stages {
		stage('Build') {
		    steps {
				echo "Build in ${BRANCH_NAME} branch"
				checkout scm
				bat "mvn install -Dmaven.test.skip=true"
		    }
		}
		stage('Unit Testing') {
			when {
				branch "master"
			}
		    steps {
				echo "JUnit test cases in ${BRANCH_NAME}"
				bat "mvn test"
			}
		}
		stage('Sonar Analysis') {
            when {
                branch 'develop' 
            }
            steps {
                withSonarQubeEnv('Test_Sonar') {
                    bat 'mvn sonar:sonar'
                }
            }
        }
		stage('Upload to Artifactory') {
			steps {
				echo "Upload build to artifactory"
				rtMavenDeployer(id: 'deployer', serverId: '123456789@artifactory', releaseRepo: 'CI-Automation-JAVA', snapshotRepo: 'CI-Automation-JAVA')
				rtMavenRun (pom: 'pom.xml', goals: 'clean install -Dmaven.test.skip=true', deployerId: 'deployer')
				rtPublishBuildInfo(serverId: '123456789@artifactory')
			}
		}
		stage('Docker Image') {
			steps {
				echo "Generating docker image in ${BRANCH_NAME}"
				bat "docker build -t dtr.nagarro.com:443/i-harshsharma-${BRANCH_NAME}:${BUILD_NUMBER} --no-cache -f Dockerfile ."
			}
		}
		stage('Containers') {
            parallel {
                stage('PushToDTR') {
                    steps {
                        bat "docker push dtr.nagarro.com:443/i-harshsharma-${BRANCH_NAME}:${BUILD_NUMBER}"
                    }
                }
				stage('PrecontainerCheck') {
                    steps {
                        echo "precontainer check"
						script {
							def containerId = bat(returnStdout: true, script: "@docker container ls -all -q --filter \"name=c-harshsharma-${BRANCH_NAME}\"");
							println "value = ${containerId}"
							if (containerId != null && containerId != ""){
								bat(script: "@docker stop ${containerId}")
								bat(script: "@docker rm ${containerId}")
							} else {
								println "no container exist"
							}
						}
                    }
                }
            }
        }
		stage('Docker deployment') {
            steps {
				echo "deploying docker"
                bat "docker run --name c-harshsharma-${BRANCH_NAME} -d -p 6200:8080 dtr.nagarro.com:443/i-harshsharma-${BRANCH_NAME}:${BUILD_NUMBER}"
            }
        }
		stage('Helm chart Deployment') {
            steps {
				echo "deploying helm chart"
				script {
					def helmLS = bat(returnStdout: true, script: "@helm ls --short | findstr 'harsh-demo-app'");
					println "image exist: ${helmLS}"
					if (helmLS != null && helmLS != "") {
						bat(script: "@helm upgrade harsh-demo-app chart --set image.repository=dtr.nagarro.com:443/i-harshsharma-${BRANCH_NAME} --set image.tag=${BUILD_NUMBER} --set nodeport=30619")
					} else {
						bat(script: "@helm install -n harsh-demo-app chart --set image.repository=dtr.nagarro.com:443/i-harshsharma-${BRANCH_NAME} --set image.tag=${BUILD_NUMBER} --set nodeport=30619")
					}
				}
            }
        }
	}
}
