package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"text/tabwriter"

	"github.com/tidwall/gjson"
)


func fetchFromTMDB(endpoint string) string {
	url := fmt.Sprintf("https://api.themoviedb.org/3%s", endpoint)
	apiKey := os.Getenv("MOVIE_API_KEY")
	if apiKey == "" {
		log.Fatal("Error: MOVIE_API_KEY environment variable not set.")
	}
	req, _ := http.NewRequest("GET", url, nil)
	req.Header.Add("accept", "application/json")
	req.Header.Add("Authorization", "Bearer "+apiKey)
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		log.Fatalf("Error making request to TMDB: %v", err)
	}
	defer res.Body.Close()
	body, err := io.ReadAll(res.Body)
	if err != nil {
        log.Fatalf("Error reading response body: %v", err)
     }

    return string(body)


}

func printTitles(jsonData string) {
    results := gjson.Get(jsonData, "results")
    if !results.Exists() {
        fmt.Println("No results found in the API response.")
        return
    }

    // Initialize a new tabwriter
    w := new(tabwriter.Writer)
    // Configure it to write to standard output, with padding
    w.Init(os.Stdout, 0, 8, 2, '\t', 0)

    // Print the table header
    fmt.Fprintln(w, "TITLE\tRELEASE DATE\tVOTE AVG\tOVERVIEW")
    fmt.Fprintln(w, "-----\t------------\t--------\t--------")

    results.ForEach(func(key, value gjson.Result) bool {
        title := value.Get("title").String()
        releaseDate := value.Get("release_date").String()
        voteAvg := value.Get("vote_average").Float()
        overview := value.Get("overview").String()

        // Truncate the overview if it's too long
        if len(overview) > 70 {
            overview = overview[:67] + "..."
        }

        // Print a row to the tabwriter buffer
        fmt.Fprintf(w, "%s\t%s\t%.1f\t%s\n", title, releaseDate, voteAvg, overview)

        return true // Continue iterating
    })

    // Flush the buffer to print the formatted table
    w.Flush()
}

func main(){
	args := os.Args
	
	if len(args) < 3 {
        fmt.Println("Usage: tmdb-app <command>")
        fmt.Println("\nAvailable commands:")
        fmt.Println("  playing    - Show movies now playing in theaters.")
        fmt.Println("  popular    - Show the most popular movies.")
        fmt.Println("  top-rated  - Show the top-rated movies.")
        fmt.Println("  upcoming   - Show upcoming movies.")
        os.Exit(1)
     }
	command := args[2]
	var endpoint string
	switch command {
		case "playing":
			endpoint = "/movie/now_playing?language=en-US&page=1"
		case "popular":
			endpoint = "/movie/popular?language=en-US&page=1"
		case "top":
			endpoint = "/movie/top_rated?language=en-US&page=1"
		case "upcoming":
			endpoint = "/movie/upcoming?language=en-US&page=1"
		case "trending":
			endpoint = "/trending/all/day?language=en-US"
		default:
			log.Fatalf("Error Unknown command: '%s'",command)
	}
	movieData := fetchFromTMDB(endpoint)
	printTitles(movieData)
	
}
