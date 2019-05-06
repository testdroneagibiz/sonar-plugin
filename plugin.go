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
		"-Dsonar.projectKey=" + strings.Replace(p.Config.Key, "/", ":", -1),
		"-Dsonar.projectName=" + p.Config.Name,
		"-Dsonar.host.url=" + p.Config.Host,
		"-Dsonar.login=" + p.Config.Token,

		"-Dsonar.projectVersion=" + p.Config.Version,
		"-Dsonar.sources=" + p.Config.Sources,
		"-Dsonar.ws.timeout=" + p.Config.Timeout,
		"-Dsonar.inclusions=" + p.Config.Inclusions,
		"-Dsonar.exclusions=" + p.Config.Exclusions,
		"-Dsonar.log.level=" + p.Config.Level,
		"-Dsonar.showProfiling=" + p.Config.showProfiling,
		"-Dsonar.scm.provider=git",
		
	}
	args2 := []string{
		"/k:" + strings.Replace(p.Config.Key, "/", ":", -1),
		"/d:sonar.verbose=true",
		"/d:sonar.host.url=" + p.Config.Host,
		"/d:sonar.login=" + p.Config.Token,
	}
	cmd := exec.Command("sonar-scanner", args...)
	output, err := cmd.CombinedOutput()
	if len(output) > 0 {
		fmt.Printf("==> Code Analysis Result: %s\n", string(output))
	}
	if err != nil {
		return err
	}

	exec.Command("SonarScanner.MSBuild.exe begin", args2...)
	output, err = cmd.CombinedOutput()
	fmt.Printf(string(output))
	exec.Command("MSBuild.exe /t:Rebuild /v:diag")
	output, err = cmd.CombinedOutput()
	fmt.Printf(string(output))
	exec.Command("SonarScanner.MSBuild.exe end")
	output, err = cmd.CombinedOutput()
	fmt.Printf(string(output))

	return nil
}
