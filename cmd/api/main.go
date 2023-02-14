package main

import (
	"time"

	"github.com/Sijibomi-stack/memoryRoutes"
	"github.com/gofiber/fiber/v2"
	"github.com/jellydator/ttlcache/v2"
)

var memoryCache ttlcache.SimpleCache = ttlcache.NewCache()

func setupRoutes(app *fiber.App) {

	app.Get("/:id", memoryRoutes.CheckCache, memoryRoutes.GetCache)

	app.Post("/post", memoryRoutes.PostInCache)

}

func main() {
	app := fiber.New() // Create a new instance of Fiber

	memoryCache.SetTTL(time.Duration(30 * time.Minute))

	setupRoutes(app)

	app.Listen(":7000")
}
