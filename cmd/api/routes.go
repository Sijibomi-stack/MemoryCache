package routes

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"

	"github.com/gofiber/fiber/v2"
	"github.com/jellydator/ttlcache/v2"
)

type products struct {
	ID          int     `json:"id"`
	Title       string  `json:"title"`
	Price       float32 `json:"price"`
	Description string  `json:"description"`
	Category    string  `json:"category"`
}

type data struct {
	Name    string `json:"name"`
	Company string `json:"tech"`
}

func checkCache(c *fiber.Ctx) error {
	id := c.Params("id")
	val, err := memoryCache.Get(id)
	if err != ttlcache.ErrNotFound {
		return c.JSON(fiber.Map{"cached": val})
	}
	return c.Next()
}

var memoryCache ttlcache.SimpleCache = ttlcache.NewCache()

func getCache(c *fiber.Ctx) error {
	id := c.Params("id")
	res, err := http.Get("https://fakestoreapi.com/products/" + id)
	if err != nil {
		return err
	}

	defer res.Body.Close()
	body, err := io.ReadAll(res.Body)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("HTTP STATUS CODE: %d\nbody: %s\n", res.StatusCode, body)

	fakeProducts := products{}
	parseErr := json.Unmarshal(body, &fakeProducts)
	if parseErr != nil {
		return parseErr
	}

	memoryCache.Set(id, fakeProducts)
	return c.JSON(fiber.Map{"Data": fakeProducts})

}

func PostInCache(c *fiber.Ctx) error {
	info := new(data)
	if err := c.BodyParser(info); err != nil {
		return err
	}

	fmt.Println("info = ", info)
	fmt.Println("info = ", info.Name)

	return c.SendString(info.Name)

}
