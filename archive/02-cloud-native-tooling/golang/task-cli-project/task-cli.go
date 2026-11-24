package main

// Marshall serializes json which means transforms my struct data to Json mode
// Unmarshall is the reverse (deserialization)
import (
	"encoding/json"
	"fmt"
	"os"
	"time"

	"github.com/google/uuid"
)
type Task struct {
    Id        string `json:"id"`
    Body      string `json:"body"`
    Status    string `json:"status"`
    CreatedAt string `json:"createdAt"`
    UpdatedAt string `json:"updatedAt"`
}

const (
    StatusTodo       = "todo"
    StatusInProgress = "in-progress"
    StatusDone       = "done"
)

func deleteRecord(id string,tasks []Task,filename string ) []Task {
	idToRemove := id	
	for i, t := range tasks{
		if t.Id == idToRemove{
			tasks = append(tasks[:i],tasks[i+1:]...)
			break
		}
	}	
	if err := writeTasksToFile(tasks, filename); err != nil {
        		fmt.Println("Error adding task:", err)
    	}
	return tasks
}

func updateRecord(id string, body string, tasks []Task, filename string) []Task {
	for _ , t := range tasks {
			if id == t.Id {
				
				updatedTask := Task{
					Id:        t.Id, // Auto ID based on length
					Body: 	 body,
					Status:    t.Status,
					CreatedAt: t.CreatedAt,
					UpdatedAt: t.UpdatedAt,
				}
				tasks = deleteRecord(t.Id,tasks,filename)
				tasks = append(tasks,updatedTask)
			}
		}
		
		if err := writeTasksToFile(tasks, filename); err != nil {
        		fmt.Println("Error adding task:", err)
    		}
		return tasks
}

func writeTasksToFile(tasks []Task, filename string) error {
    updatedData, err := json.MarshalIndent(tasks, "", "  ")
    if err != nil {
        return fmt.Errorf("error encoding JSON: %w", err)
    }
    return os.WriteFile(filename, updatedData, 0644)
}

func changeProgress(id string, status string, tasks []Task, filename string) []Task {
	for _ , t := range tasks {
			if id == t.Id {
				
				updatedTask := Task{
					Id:        t.Id, // Auto ID based on length
					Body: 	 t.Body,
					Status:    status,
					CreatedAt: t.CreatedAt,
					UpdatedAt: t.UpdatedAt,
				}
				tasks = deleteRecord(t.Id,tasks,filename)
				tasks = append(tasks,updatedTask)
			}
		}
		
		if err := writeTasksToFile(tasks, filename); err != nil {
        		fmt.Println("Error adding task:", err)
    		}
		return tasks
}

func addRecord(body string, tasks []Task, filename string )  []Task {
	
	newTask := Task{
		Id:        fmt.Sprintf("%v", uuid.New()), // Auto ID 
		Body: 	 string(body),
		Status:    "todo",
		CreatedAt: time.Now().Format(time.RFC3339),
		UpdatedAt: time.Now().Format(time.RFC3339),
	}
	tasks = append(tasks, newTask) // Append new task
	if err := writeTasksToFile(tasks, filename); err != nil {
        		fmt.Println("Error adding task:", err)
    	}

	fmt.Println("Task added successfully!")
	return tasks
}

func listRecords(args []string , tasks []Task, filename string)  {

	statusFilter := ""

	if len(args) == 3 {
		statusFilter = args[2]
	}

	for _ , t  := range tasks {
		if  statusFilter == "" || t.Status == statusFilter {
			fmt.Println("======================================================")
			fmt.Println("Id:",t.Id)
			fmt.Println("Body:",t.Body)
			fmt.Println("CreatedAt:",t.CreatedAt)
			fmt.Println("UpdatedAt:",t.UpdatedAt)
			fmt.Println("Status:",t.Status)
		}	
	}
}

func main() {
    filename := "tasks.json"
    args := os.Args
    if len(args) < 2 {
    		fmt.Println("Usage: <command> [args]")
		return
	}
    // Step 1: Read existing data if file exists
    var tasks []Task
    data, err := os.ReadFile(filename)
    if err == nil && len(data) > 0 {
        // Step 2: Unmarshal JSON array to slice
        if err := json.Unmarshal(data, &tasks); err != nil {
            fmt.Println("Error decoding JSON:", err)
            return
        }
    } else if err != nil && !os.IsNotExist(err) {
        // Real error (not file not exist)
        fmt.Println("Error reading file:", err)
        return
    }

    switch args[1] {
	case "add":
		body := args[2]
		addRecord(body, tasks, filename)

	case "delete":
		deleteRecord(args[2],tasks,filename)
	
	case "list":
		listRecords(args,tasks,filename)

	case "update":
		updateRecord(args[2],args[3],tasks,filename)

	case "mark-in-progress":
		changeProgress(args[2],StatusInProgress,tasks,filename)
	
	case "mark-done":
		changeProgress(args[2],StatusDone,tasks,filename)
	}
		
}