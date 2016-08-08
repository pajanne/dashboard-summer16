# Dashboard project Summer 2016

## Getting started with GitHub
- download GitHub desktop from https://desktop.github.com/
- clone this repository onto your computer https://github.com/pajanne/dashboard-summer16.git
- install atom editor https://atom.io/
- open it up using atom
- unable markdown-preview in atom in the settings view https://atom.io/packages/settings-view under install packages
- display README.md using ctrl-shift-m https://atom.io/packages/markdown-preview
- create a new file and commit into the repo 'dashboard-summer16'

## Project description

### Dashboard project with Anne
The dashboard project is about having a web page summarizing metrics of the sequencing service at the current time that evolves over time.

The sequencing service runs different Illumina platforms: HiSeq4000, HiSeq2500, MiSeq and NextSeq. For each run on a sequencer, metrics are recorded into a database which is part of the LiMS system and could be extracted and then plotted.

The first metrics to look at are yield and Q30. They should be displayed using box plots on a monthly basis.

**Here are the metrics CRUKCI Genomics Core would like to see on the report:**
1. Yield on Hiseq 4000, 2500 and Miseq (box plot with Millions of reads. It could also show the average yield which would be useful to know month by month). It could be one box plot generated every month, one for each platform.
2. Quality - %Bases Q30 across the 3 platforms (box plot per platform)
3. Turnaround time – median wait time across the platforms

#### Interesting read and useful links
- [GitHub Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)
- [Python's Web Framework Benchmarks](http://klen.github.io/py-frameworks-bench/)
- [EuroPython 2016](https://ep2016.europython.eu/en/)
- [Bokeh, a Python interactive visualization library](http://bokeh.pydata.org/)

#### Related projects
- https://github.com/crukci-bioinformatics/claritypy-ngsreports

### Map project with Stefanie

Please see [Mapping technology resources in Cambridge](https://github.com/pajanne/dashboard-summer16/blob/master/Mapping-locations.md) page and associated [resource file](https://github.com/pajanne/dashboard-summer16/blob/master/CUEquipmentDataGEO.csv)

## Objectives
