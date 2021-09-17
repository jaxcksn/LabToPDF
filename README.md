# LabToPDF
Simple shell script to allow for the conversion of Jupyter Lab to a formatted PDF using chrome pdf.

#### Requirements:
- MacOS or Linux
- Google Chrome Installed (Edit chrome variable in script to point to Chrome install for Linux)

#### Installation:
```shell
git clone https://github.com/jaxcksn/LabToPDF.git
ln /LabToPDF/LabToPDF.sh /usr/local/bin/LabToPDF
```

#### Usage:
```shell
LabToPDF {-c} {notebook-file} 
```
The optional -c flag applies a CSS fix for cells that wrap strangely.

