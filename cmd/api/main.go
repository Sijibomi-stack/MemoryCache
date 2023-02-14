package main

import (
	"time"

	"github.com/Sijibomi-stack/memoryRoutes"
	"github.com/gofiber/fiber/v2"
)

func setupRoutes(app *fiber.App) {

	app.Get("/id", memoryRoutes.checkCache, memoryRoutes.getCache)

	app.Post("/post", memoryRoutes.PostInCache)

}

func main() {
	app := fiber.New() // Create a new instance of Fiber

	memoryCache.SetTTL(time.Duration(30 * time.Minute))

	memoryRoutes(app)

	app.Listen(":7000")
}
