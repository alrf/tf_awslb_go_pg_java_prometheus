package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	_ "github.com/lib/pq"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"	
)

const (
	port   = 5432
	user   = "postgres"
	dbname = "postgres"
)

var (
    opsProcessed = promauto.NewCounter(prometheus.CounterOpts{
        Name: "app_processed_pg_connections",
        Help: "The total number of connections",
    })
)

func metricsHandler(w http.ResponseWriter, r *http.Request, s string) {
	// TODO expose metrics here
	promhttp.Handler().ServeHTTP(w, r)
}

func makeHandler(fn func(http.ResponseWriter, *http.Request, string)) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "" {
			http.NotFound(w, r)
			return
		}
		fn(w, r, "")
	}
}

func main() {
	password := os.Getenv("PGPASSWORD")
	host := os.Getenv("APP_PGHOST")

	// setup DB connection
	psqlInfo := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable", host, port, user, password, dbname)
	db, err := sql.Open("postgres", psqlInfo)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	err = db.Ping()
	if err != nil {
		panic(err)
	}

	log.Println("Successfully connected to DB!")

	// continously send db queries
	go func(db *sql.DB) {
		for {
			log.Println("Sending sql query")
			opsProcessed.Inc()
			sqlStatement := "select pg_sleep(floor(random() * 10 + 1)::int);"
			_, err = db.Exec(sqlStatement)
			if err != nil {
				panic(err)
			}
		}
	}(db)

	// setup handler
	http.HandleFunc("/metrics/", makeHandler(metricsHandler))
	log.Println("Port :8080 is ready for metrics collection")

	log.Fatal(http.ListenAndServe(":8080", nil))
}
