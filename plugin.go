package main

import (
	"strings"
	"fmt"
	"os/exec"
)

type (
	Config struct {
		Key   			string
		Name    		string
		Host  			string
		Token 			string

		Version    		string
		Sources    		string
		Timeout   		string
		Inclusions    	string
		Exclusions  	string
		Level 			string
		showProfiling 	string
	}
	Plugin struct {
		Config Config
	}
)

func (p Plugin) Exec() error {
	args := []string{
		"/sonar-scanner/SonarScanner.MSBuild.dll",
		"begin",
		 "/k:" + strings.Replace(p.Config.Key, "/", ":", -1),
		 "/d:sonar.host.url=" + p.Config.Host,
		 "/d:sonar.login=" + p.Config.Token,
		 "/d:sonar.projectVersion=" + p.Config.Version,
	}
	args2 :=[]string{
		"/sonar-scanner/SonarScanner.MSBuild.dll",
		"end",
		"/d:sonar.login=" + p.Config.Token,
	}

	
	startProcess := exec.Command("dotnet", args...)
	dotNetBuild := exec.Command("dotnet", "build")
	endProcess := exec.Command("dotnet", args2...)
	outputStartProcess, errStartProcess := startProcess.CombinedOutput()
	outputDotNetBuild, errDotNetBuild := dotNetBuild.CombinedOutput()
	outputEndProcess, errEndProcess := endProcess.CombinedOutput()
	fmt.Printf("===> Start Process Sonar Scanner MSBuild: %s\n", string(outputStartProcess))
	fmt.Printf("===> Compile Application: %s\n", string(outputDotNetBuild))
	fmt.Printf("===> Publish Results to Sonar Server: %s\n", string(outputEndProcess))

	if errStartProcess != nil {
		return errStartProcess
	}

	if errDotNetBuild != nil {
		return errDotNetBuild
	}

	if errEndProcess != nil {
		return errEndProcess
	}

	return nil
}
