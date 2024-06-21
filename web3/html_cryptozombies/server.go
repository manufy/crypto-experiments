package main

import (
	"log"
	"net/http"
	"runtime"
	"time"
)

func main() {
	// Utilizar todos los núcleos disponibles
	runtime.GOMAXPROCS(runtime.NumCPU())

	// Crear un servidor de archivos para servir archivos estáticos desde ./public
	fs := http.FileServer(http.Dir("./public"))

	// Manejar la URL raíz para servir index.html de forma predeterminada
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/" {
			http.ServeFile(w, r, "./public/index.html")
			return
		}

		// Eliminar el prefijo y servir archivos desde el directorio public
		http.StripPrefix("/", fs).ServeHTTP(w, r)
	})

	// Configuración del servidor HTTP
	server := &http.Server{
		Addr: ":3000",
		// Establecer tiempo máximo para leer la solicitud completa
		ReadTimeout: 5 * time.Second,
		// Establecer tiempo máximo para escribir la respuesta completa
		WriteTimeout: 10 * time.Second,
		// Establecer tiempo máximo para la inactividad entre solicitudes
		IdleTimeout: 15 * time.Second,
	}

	// Iniciar el servidor
	log.Print("Listening on :3000...")
	err := server.ListenAndServe()
	if err != nil {
		log.Fatal(err)
	}
}
