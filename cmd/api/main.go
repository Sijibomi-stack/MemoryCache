package main

import (
	"time"
	"workspace/routes"

	"github.com/gofiber/fiber/v2"
)

func setupRoutes(app *fiber.App) {

	app.Get("/id", routes.checkCache, routes.getCache)

	app.Post("/post", routes.PostInCache)

}

func main() {
	app := fiber.New() // Create a new instance of Fiber

	memoryCache.SetTTL(time.Duration(30 * time.Minute))

	routes(app)

	app.Listen(":7000")
}
