FROM tomcat:alpine
MAINTAINER harshsharma
#wget -O /usr/local/tomcat/webapps/demosampleapplication-1.0.0-SNAPSHOT.war http://localhost:8082/artifactory/CI-Automation-JAVA/com/nagarro/devops-tools/devops/demosampleapplication/1.0.0-SNAPSHOT/demosampleapplication-1.0.0-20200909.093336-1.war
COPY ./target/devopssampleapplication.war /usr/local/tomcat/webapps/
EXPOSE 8080
CMD /usr/local/tomcat/bin/catalina.sh run