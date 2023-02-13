package main

import (
	"time"

	"github.com/gofiber/fiber/v2"
)

func setupRoutes(app *fiber.App) {

	app.Get("/id", checkCache, getCache)

	app.Post("/post", PostInCache)

}

func main() {
	app := fiber.New() // Create a new instance of Fiber

	memoryCache.SetTTL(time.Duration(30 * time.Minute))

	memRoutes(app)

	app.Listen(":7000")
}
