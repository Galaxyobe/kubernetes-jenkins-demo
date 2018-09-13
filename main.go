package main

import "log"
import "flag"
import "github.com/gin-gonic/gin"

func main() {

	log.Println("version:", Version, "date:", Date, "build:", Build)

	addr := flag.String("addr", ":8080", "server address")

	route := gin.Default()

	route.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status_code": 200,
			"message":     "OK",
		})
	})

	if err := route.Run(*addr); err != nil {
		log.Fatalln(err)
	}
}
