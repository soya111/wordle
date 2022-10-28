package main

import (
	"fmt"
	"testing"
)

func TestIsWord(t *testing.T) {
	fmt.Println(isWord("dafd"))
	fmt.Println(isWord("dafdあ"))
}

func TestCollateTextWithWord(t *testing.T) {
	fmt.Println(collateTextWithWord("menay", "money"))
}
