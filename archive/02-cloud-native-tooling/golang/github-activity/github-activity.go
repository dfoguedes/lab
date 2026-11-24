package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"

	"github.com/tidwall/gjson"
)


func fetchData(url string) string {
	response, err := http.Get(url)

	if err != nil {
		log.Fatalf("Error fetching data %v", err)
	}
	defer response.Body.Close()

	if response.StatusCode != http.StatusOK {
        log.Fatalf("Error: GitHub API returned status code: %v", response.StatusCode)
	}
	body, err := io.ReadAll(response.Body)

	if err != nil {
		log.Fatalf("Error reading response body: %v", err)	
	}
	return string(body)
}

func outputGithubInfo(jsonData string){
 gjson.Parse(jsonData).ForEach(func(_, value gjson.Result) bool {
		eventType := value.Get("type").String()
		repo := value.Get("repo.name").String()

        switch eventType {
		case "PushEvent":
			commitCount := value.Get("payload.commits.#").Int()
			if commitCount > 0 {
				plural := "s"
				if commitCount == 1 {
					plural = ""
				}
				fmt.Printf("- Pushed %d commit%s to %s\n", commitCount, plural, repo)
			}
		case "IssuesEvent":
			action := value.Get("payload.action").String()
			fmt.Printf("- %s an issue in %s\n", action, repo)
		case "WatchEvent":
			// Example for another event type from the requirements
			action := value.Get("payload.action").String()
			if action == "started" {
				fmt.Printf("- Starred %s\n", repo)
			}
        }
        return true
    })
}

func main() {
	// Handle number of args
	if len(os.Args) < 2 {
		log.Fatalf("Usage: github-activity <github_username>")
	}
	username := os.Args[1]
    url := fmt.Sprintf("https://api.github.com/users/%v/events", username)
    jsonData := fetchData(url)
    fmt.Printf("Recent activity for %s:\n", username)
    outputGithubInfo(jsonData)
}