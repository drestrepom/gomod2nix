package main

import (
	"testing"

	"example.com/stringutil"
	"github.com/google/go-cmp/cmp"
)

func TestReverse(t *testing.T) {
	if diff := cmp.Diff("olleH", stringutil.Reverse("Hello")); diff != "" {
		t.Errorf("Reverse mismatch (-want +got):\n%s", diff)
	}
}
