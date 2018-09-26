package softwareupgrade

import (
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
)

type (
	// TDebugLog specifies where to send debugs to, and whether to also print the debug log to the console
	TDebugLog struct {
		printDebug   bool
		printConsole bool
		file         *os.File
	}
)

var (
	// DebugLog enables access to logging facilities
	DebugLog TDebugLog
)

func init() {
	log.SetOutput(ioutil.Discard) // prevent double output when PrintConsole is true
}

// Debug decides whether to send the log to the debug log file
func (d *TDebugLog) Debug(format string, args ...interface{}) {
	if d != nil && d.printDebug {
		d.Print(format, args...)
	}
}

// Debugf decides whether to send the log to the debug log file
func (d *TDebugLog) Debugf(format string, args ...interface{}) {
	if d != nil && d.printDebug {
		d.Printf(format, args...)
	}
}

// Debugln adds a newline to the debug string
func (d *TDebugLog) Debugln(format string, args ...interface{}) {
	if d != nil && d.printDebug {
		d.Print(format+"\n", args...)
	}
}

// EnablePrintConsole sets the PrintConsole flag
func (d *TDebugLog) EnablePrintConsole() {
	if d != nil {
		d.printConsole = true
	}
}

// EnableDebug sets the printDebug flag
func (d *TDebugLog) EnableDebug() {
	if d != nil {
		d.printDebug = true
	}
}

// GetFilename returns the filename that is currently in use by d, if it is assigned.
func (d *TDebugLog) GetFilename() (result string) {
	if d != nil && d.file != nil {
		result = d.file.Name()
	}
	return
}

// Print decides whether the debug log is sent to the console, or not, and also logs it to the debug log
func (d *TDebugLog) Print(format string, args ...interface{}) {
	if d != nil && d.printConsole {
		fmt.Printf(format, args...)
	}
	log.Printf(format, args...)
}

// Printf prints the specified debug log
func (d *TDebugLog) Printf(format string, args ...interface{}) {
	log := fmt.Sprintf(format, args...)
	d.Print(log)
}

// Println adds a newline to the specified debug log
func (d *TDebugLog) Println(msg string, args ...interface{}) {
	d.Printf(msg+"\n", args...)
}

// SetOutput changes the output writer for the log
func (d *TDebugLog) SetOutput(w io.Writer) {
	log.SetOutput(w)
}

// EnableDebugLog changes the log output to a new file specified by the given filename
func (d *TDebugLog) EnableDebugLog(LogFilename string) (err error) {
	if d == nil {
		return errors.New("receiver d has not been inialized")
	}
	if LogFilename == "" {
		return errors.New("Log filename is empty")
	}
	expandedLogPath, err := Expand(LogFilename)
	if err != nil {
		return
	}
	if !FileExists(expandedLogPath) {
		d.file, err = os.Create(expandedLogPath)
	} else {
		d.file, err = os.OpenFile(expandedLogPath, os.O_APPEND|os.O_WRONLY, 0)
	}
	if err == nil {
		log.SetOutput(d.file)
	}
	return
}

// CloseDebugLog flushes the debug log and closes it.
func (d *TDebugLog) CloseDebugLog() {
	if d == nil || d.file == nil {
		return
	}
	d.file.Sync()
	d.file.Close()
	d.file = nil
}
