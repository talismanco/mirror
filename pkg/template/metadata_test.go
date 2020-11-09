package template_test

import (
	"encoding/json"
	"testing"

	"github.com/toyboxco/mirror/pkg/template"
)

func TestMarshalsTime(test *testing.T) {
	jsonT := template.NewTime()

	b, err := jsonT.MarshalJSON()
	if err != nil {
		test.Error(err)
	}

	var unmarshaledT template.JSONTime
	if err := json.Unmarshal(b, &unmarshaledT); err != nil {
		test.Error(err)
	}

	expected, got := jsonT.String(), unmarshaledT.String()
	if expected != got {
		test.Errorf("marshaled and unmarshaled time should've been equal expected %q, got %q", expected, got)
	}
}
