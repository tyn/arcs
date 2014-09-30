
Arcs - the retrieval tool for preprints

====
Arcs is a downloader of preprints that facilitates researchers
to preserve scholarly papers.  It currently supports donwloading
of preprints distributed by arXiv.org via the Amazon S3 Requester
Pays Buckets.

Arcs is designed to automate the process of downloading and
uncompression of preprint data.

### Usage
To install and setup arcs:

```
  git clone https://github.com/tyn/arcs.git
  cd arcs
  arcs init
```

Follow the displayed instruction to setup
[s3cmd](http://s3tools.org/s3cmd) (on which arcs depends).

#### Downloading example
To download the preprints of the year 2014
(NOTE: you have to pay for the data transfer)

```
  arcs syncsrc 2014
```


To grep the downloaded files:

```
  arcs walk-tex | arcs grep -H creativecommons
```
