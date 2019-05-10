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
	args2 := []string{
		"/sonar-scanner/SonarScanner.MSBuild.dll",
		"begin",
		 "/k:" + strings.Replace(p.Config.Key, "/", ":", -1),
		 "/d:sonar.host.url=" + p.Config.Host,
		 "/d:sonar.login=" + p.Config.Token,
		 //"/d:sonar.sources=" + p.Config.Sources,
	}
	args3 :=[]string{
		"/sonar-scanner/SonarScanner.MSBuild.dll",
		"end",
		"/d:sonar.login=" + p.Config.Token,
	}
	startProcess := exec.Command("dotnet", args2...)
	dotNetBuild := exec.Command("dotnet build")
	endProcess := exec.Command("dotnet", args3...)
	outputStartProcess, errStartProcess := startProcess.CombinedOutput()
	outputDotNetBuild, errDotNetBuild := dotNetBuild.CombinedOutput()
	outputEndProcess, errEndProcess := endProcess.CombinedOutput()
	fmt.Printf(string(outputStartProcess))
	fmt.Printf(string(outputDotNetBuild))
	fmt.Printf(string(outputEndProcess))

	if errStartProcess != nil {
		return errStartProcess
	}

	if errDotNetBuild != nil {
		return errDotNetBuild
	}

	if errEndProcess != nil {
		return errEndProcess
	}


	// args := []string{
	// 	"-Dsonar.projectKey=" + strings.Replace(p.Config.Key, "/", ":", -1),
	// 	"-Dsonar.projectName=" + p.Config.Name,
	// 	"-Dsonar.host.url=" + p.Config.Host,
	// 	"-Dsonar.login=" + p.Config.Token,

	// 	"-Dsonar.projectVersion=" + p.Config.Version,
	// 	"-Dsonar.sources=" + p.Config.Sources,
	// 	"-Dsonar.ws.timeout=" + p.Config.Timeout,
	// 	"-Dsonar.inclusions=" + p.Config.Inclusions,
	// 	"-Dsonar.exclusions=" + p.Config.Exclusions,
	// 	"-Dsonar.log.level=" + p.Config.Level,
	// 	"-Dsonar.showProfiling=" + p.Config.showProfiling,
	// 	"-Dsonar.scm.provider=git",
		
	// }
	// cmd := exec.Command("sonar-scanner", args...)
	// output, err := cmd.CombinedOutput()
	// if len(output) > 0 {
	// 	fmt.Printf("==> Code Analysis Result: %s\n", string(output))
	// }
	// if err != nil {
	// 	return err
	// }
	return nil
}
