package main

import "time"
import "testing"
import "math/rand"

func TestMain(t *testing.T) {
	// simulation a failed
	r := rand.New(rand.NewSource(time.Now().Unix()))
	n := r.Int31n(10)
	t.Log(n)
}
