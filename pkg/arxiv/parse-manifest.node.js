var fs = require('fs')
  , xml2js = require('xml2js')
  , args = require('optimist').argv
  , csv = require('csv')
  ;

var s = csv.stringify({delimiter: '|'});

var p = xml2js.Parser();
p.addListener('end', function (xml) {
  var meta = {
    manifest_type : 'unknown',
    body : null
  };
  if (xml.arXivSRC) {
    meta.manifest_type = "src";
    meta.body = xml.arXivSRC;
  } else if (xml.arXivPDF) {
    meta.manifest_type = "pdf";
    meta.body = xml.arXivPDF;
  } else {
    console.log('WTD/1.0 600 Unsupported manifest');
    process.exit(1);
  }

  console.log('WTD/1.0 200 OK');
  console.log('Content-Type: text/xml');
  console.log('Manifest-Type: %s', meta.manifest_type);
  console.log('Timestamp: ' + meta.body.timestamp);
  console.log('Total-File-Count: ' + meta.body.file.length);
  console.log('Header-Included: no');

  var files = meta.body.file;
  var header = null;

  // Canonicalize records
  for (var i in files) {
    var file = files[i];
    var dd = {};
    var hh = [];
    for (var k in file) {
      hh.push(k);
      dd[k] = file[k][0];
    }
    if (header == null) {
      header = hh;
      console.log('Columns: ' + hh.join("|"));
      console.log('');
    }
    s.write(dd);
  }
});

fs.readFile(args._[0], function (err, data) {
  p.parseString(data);
});

s.on('readable', function () {
  var d;
  while (d = s.read()) {
    process.stdout.write(d);
  }
});

// Ignore EPIPE
process.stdout.on('error', function(err) {
  if (err.code == "EPIPE") process.exit(0);
});
