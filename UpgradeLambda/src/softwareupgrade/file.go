package softwareupgrade

import "io/ioutil"

// ReadDataFromFile reads the contents of the given filename into a byte array and returns it.
func ReadDataFromFile(filename string) ([]byte, error) {
	if expandedFilename, err := Expand(filename); err == nil {
		filename = expandedFilename
	}
	result, err := ioutil.ReadFile(filename)
	return result, err
}

// SaveDataToFile is a simple way of writing to a given filename.
// Returns true if successful
// If the filename given points to an existing file, its contents are overwritten.
func SaveDataToFile(filename string, data []byte) (bool, error) {
	if expandedFilename, err := Expand(filename); err == nil {
		filename = expandedFilename
	}
	err := ioutil.WriteFile(filename, data, 0644)
	return err == nil, err
}
