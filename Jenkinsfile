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
		stage('checkout') {
			steps {
				echo "1. checkout in master branch"
				checkout scm
			}
		}
		stage('Build') {
			steps {
				echo "2. Build in master branch"
				bat "mvn install"
			}
		}
		stage('Unit Testing') {
			steps {
				echo "3. JUnit test cases in master"
				bat "mvn test"
			}
		}
		stage('Sonar Analysis') {
			steps {
				withSonarQubeEnv('Test_Sonar') {
					echo "4. Sonar scanner in master branch"
					bat "mvn sonar:sonar"
				}
			}
		}
	}
}
