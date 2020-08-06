function syncDataFiles(dbname, baseurl)
{
    var retval = {};
    if (typeof (dbname) === "undefined") { dbname = "files"; }
    if (typeof (baseurl) === "undefined") { baseurl = ""; }

    // this is appended to files as an arg to defeat XMLHttpRequest cacheing.
    //  (Don't do this on most hosting services, from itch.io to
    //  playonjump.com, since we generally don't update the datafiles anyhow
    //  once we're shipping, and it defeats Cloudflare cacheing, causing it
    //  to abuse Amazon S3, etc.)
    var urlrandomizerarg = '';
    if (false) {
        urlrandomizerarg = "?nocache=" + (Date.now() / 1000 | 0);
    }

    var state = {
        db: null,
        reported_result: false,
        xhrs: {},
        remote_manifest: {},
        remote_manifest_loaded: false,
        local_manifest: {},
        local_manifest_loaded: false,
        total_to_download: 0,
        total_downloaded: 0,
        total_files: 0,
        pending_files: 0
    };

    var log = function(str) { console.log("CACHEAPPDATA: " + str); }
    var debug = function(str) {}
    //debug = function(str) { log(str); }

    var clear_state = function() {
        for (var i in state.xhrs) {
            state.xhrs[i].abort();
        }
        delete state.db;
        delete state.xhrs;
        delete state.remote_manifest;
        delete state.local_manifest;
    };

    var failed = function(why) {
        if (state.reported_result) { return; }
        state.reported_result = true;
        log("[FAILURE] " + why);
        clear_state();
        if (retval.onerror) {
            retval.onerror(why);
        }
    };

    retval.abort = function() {
        failed("Aborted.");
    }

    var succeeded = function() {
        if (state.reported_result) { return; }
        state.reported_result = true;
        var why = "File data synchronized (downloaded " + Math.ceil(state.total_downloaded / 1048576) + " megabytes in " + state.total_files + " files)";
        log("[SUCCESS] " + why);
        retval.db = state.db;
        retval.manifest = state.remote_manifest;
        clear_state();
        if (retval.onsuccess) {
            retval.onsuccess(why);
        }
    };

    var prevprogress = "";
    var progress = function(str) {
        if (state.reported_result) { return; }
        if (str == prevprogress) { return; }
        prevprogress = str;
        log("[PROGRESS] " + str);
        if (retval.onprogress) {
            retval.onprogress(str, state.total_downloaded, state.total_to_download);
        }
    }

    debug("Database name is '" + dbname + "'.");
    progress("Opening database...");
    var dbopen = window.indexedDB.open(dbname, 1);

    // this is called if we change the version or the database doesn't exist.
    // Use it to create the schema.
    dbopen.onupgradeneeded = function(event) {
        progress("Upgrading/creating local database...");
        var db = event.target.result;
        var metadataStore = db.createObjectStore("metadata", { keyPath: 'filename' });
        var dataStore = db.createObjectStore("data", { keyPath: 'chunkid', autoIncrement: true });
        dataStore.createIndex("data", "filename", { unique: false });
    };

    dbopen.onerror = function(event) {
        failed("Couldn't open local database: " + event.target.error.message);
    };

    var finished_file = function(fname) {
        debug("Finished writing '" + fname + "' to the database!");
        state.pending_files--;
        if (state.pending_files < 0) {
            state.pending_files = 0;
            debug("Uhoh, pending_files went negative?!");
        }
        if (state.pending_files == 0) {
            succeeded();
        }
    };

    var store_file = function(xhr) {
        // write to the database...
        var databuf = xhr.response;
        var transaction = state.db.transaction(["metadata", "data"], "readwrite");
        var objstoremetadata = transaction.objectStore("metadata");
        var objstoredata = transaction.objectStore("data");

        objstoremetadata.add({ filename: xhr.filename, filesize: xhr.filesize, filetime: xhr.filetime });
        // !!! FIXME: _of course_ this crashes Safari on large files
        /*
        var chunksize = 1048576;  // 1 megabyte each.
        var chunks = Math.ceil(xhr.response.byteLength / chunksize);
        for (var i = 0; i < chunks; i++) {
            var bufoffset = i * chunksize;
            objstoredata.add({
                filename: xhr.filename,
                offset: bufoffset,
                chunk: new Uint8Array(databuf, bufoffset, chunksize);
            });
        }
        */
        objstoredata.add({ filename: xhr.filename, offset: 0, chunk: databuf });

        transaction.oncomplete = function(event) {
            finished_file(xhr.filename);  // all done here!
        };
    };

    var download_new_files = function() {
        if (state.reported_result) { return; }
        progress("Downloading new files...");
        var downloadme = [];
        for (var i in state.remote_manifest) {
            var remoteitem = state.remote_manifest[i];
            var remotefname = i;
            if (typeof state.local_manifest[remotefname] !== "undefined") {
                debug("remote filename '" + remotefname + "' already downloaded.");
            } else {
                debug("remote filename '" + remotefname + "' needs downloading.");
                // the browser will let a handful of these go in parallel, and
                //  then will queue the rest, firing events as appropriate
                //  when it gets around to them, so just fire them all off
                //  here.

                // !!! FIXME: use the Fetch API, plus streaming, as an option.
                // !!! FIXME:  It can use less memory, since it doesn't need
                // !!! FIXME:  to keep the whole file in memory.
                state.total_to_download += remoteitem.filesize;
                state.total_files++;
                state.pending_files++;

                var xhr = new XMLHttpRequest();
                state.xhrs[remotefname] = xhr;
                xhr.previously_loaded = 0;
                xhr.filename = remotefname;
                xhr.filesize = state.remote_manifest[i].filesize;
                xhr.filetime = state.remote_manifest[i].filetime;
                xhr.expected_filesize = remoteitem.filesize;
                xhr.responseType = "arraybuffer";
                xhr.addEventListener("error", function(e) { failed("Download error on '" + e.target.filename + "'!"); });
                xhr.addEventListener("timeout", function(e) { failed("Download timeout on '" + e.target.filename + "'!"); });
                xhr.addEventListener("abort", function(e) { failed("Download abort on '" + e.target.filename + "'!"); });

                xhr.addEventListener('progress', function(e) {
                    if (state.reported_result) { return; }
                    var xhr = e.target;
                    var additional = e.loaded - xhr.previously_loaded;
                    state.total_downloaded += additional;
                    xhr.previously_loaded = e.loaded;
                    debug("Downloaded " + additional + " more bytes for file '" + xhr.filename + "'");
                    var percent = state.total_to_download ? Math.floor((state.total_downloaded / state.total_to_download) * 100.0) : 0;
                    progress("Downloaded " + percent + "% (" + Math.ceil(state.total_downloaded / 1048576) + "/" + Math.ceil(state.total_to_download / 1048576) + " megabytes)");
                });

                xhr.addEventListener("load", function(e) {
                    if (state.reported_result) { return; }
                    var xhr = e.target;
                    if (xhr.status != 200) {
                        failed("Server reported failure downloading '" + xhr.filename + "'!");
                    } else {
                        debug("Finished download of '" + xhr.filename + "'!");
                        state.total_downloaded -= xhr.previously_loaded;
                        state.total_downloaded += xhr.expected_filesize;
                        xhr.previously_loaded = xhr.expected_filesize;
                        delete state.xhrs[xhr.filename];
                        var percent = state.total_to_download ? Math.floor((state.total_downloaded / state.total_to_download) * 100.0) : 0;
                        progress("Downloaded " + percent + "% (" + Math.ceil(state.total_downloaded / 1048576) + "/" + Math.ceil(state.total_to_download / 1048576) + " megabytes)");
                        store_file(xhr);
                    }
                });

                xhr.open("get", baseurl + remotefname + urlrandomizerarg, true);
                xhr.send();
            }
        }

        if (state.pending_files == 0) {
            succeeded();  // we're already done.  :)
        }
    };

    var delete_old_files = function() {
        if (state.reported_result) { return; }
        var deleteme = []
        for (var i in state.local_manifest) {
            var localitem = state.local_manifest[i];
            var localfname = localitem.filename;
            var removeme = false;
            if (typeof state.remote_manifest[localfname] === "undefined") {
                removeme = true;
            } else {
                var remoteitem = state.remote_manifest[localfname];
                if ( (localitem.filesize != remoteitem.filesize) ||
                     (localitem.filetime != remoteitem.filetime) ) {
                    removeme = true;
                }
            }

            if (removeme) {
                debug("Marking old file '" + localfname + "' for removal.");
                deleteme.push(localfname);
                delete state.local_manifest[i];
            }
        }

        if (deleteme.length == 0) {
            debug("No old files to delete.");
            download_new_files();  // just move on to the next stage.
        } else {
            progress("Cleaning up old files...");
            var transaction = state.db.transaction(["data", "metadata"], "readwrite");
            transaction.oncomplete = function(event) {
                debug("All old files are deleted.");
                download_new_files();
            };

            var objstoremetadata = transaction.objectStore("metadata");
            var objstoredata = transaction.objectStore("data");
            var dataindex = objstoredata.index("data");
            for (var i of deleteme) {
                debug("Deleting metadata for '" + i + "'.");
                objstoremetadata.delete(i);
                dataindex.openCursor(IDBKeyRange.only(i)).onsuccess = function(event) {
                    var cursor = event.target.result;
                    if (cursor) {
                        debug("Deleting file chunk " + cursor.value.chunkid + " for '" + cursor.value.filename + "' (offset=" + cursor.value.offset + ", size=" + cursor.value.size + ").");
                        objstoredata.delete(cursor.value.chunkid);
                        cursor.continue();
                    }
                }
            }
        }
    };

    var manifest_loaded = function() {
        if (state.reported_result) { return; }
        if (state.local_manifest_loaded && state.remote_manifest_loaded) {
            debug("both manifests loaded, moving on to next step.");
            delete_old_files();  // on success, will start downloads.
        }
    };

    var load_local_manifest = function(db) {
        if (state.reported_result) { return; }
        debug("Loading local manifest...");
        var transaction = db.transaction("metadata", "readonly");
        var objstore = transaction.objectStore("metadata");
        var cursor = objstore.openCursor();

        // this gets called once for each item in the object store.
        cursor.onsuccess = function(event) {
            if (state.reported_result) { return; }
            var cursor = event.target.result;
            if (cursor) {
                debug("Another local manifest item: '" + cursor.value.filename + "'");
                state.local_manifest[cursor.value.filename] = cursor.value;
                cursor.continue();
            } else {
                debug("All local manifest items iterated.");
                state.local_manifest_loaded = true;
                manifest_loaded();  // maybe move on to next step.
            }
        };
    };

    dbopen.onsuccess = function(event) {
        debug("Database is open!");
        var db = event.target.result;
        state.db = db;

        // just catch all database errors here, where they will bubble up
        //  from objectstores and transactions.
        db.onerror = function(event) {
            failed("Database error: " + event.target.error.message);
        };

        progress("Loading file manifests...");

        // this is async, so it happens while remote manifest downloads.
        load_local_manifest(db);

        debug("Loading remote manifest...");
        var xhr = new XMLHttpRequest();
        xhr.responseType = "text";
        xhr.addEventListener("error", function(e) { failed("Manifest download error!"); });
        xhr.addEventListener("timeout", function(e) { failed("Manifest download timeout!"); });
        xhr.addEventListener("abort", function(e) { failed("Manifest download abort!"); });
        xhr.addEventListener("load", function(e) {
            if (e.target.status != 200) {
                failed("Server reported failure downloading manifest!");
            } else {
                debug("Remote manifest loaded!");
                debug("json: " + e.target.responseText);
                state.remote_manifest_loaded = true;
                try {
                    state.remote_manifest = JSON.parse(e.target.responseText);
                } catch (e) {
                    failed("Remote manifest is corrupted.");
                }
                delete state.remote_manifest[""]
                manifest_loaded();  // maybe move on to next step.
            }
        });
        xhr.open("get", "manifest.json" + urlrandomizerarg, true);
        xhr.send();
    };

    return retval;
}

var statusElement = document.getElementById('status');
var progressElement = document.getElementById('progress');
var canvasElement = document.getElementById('canvas');

canvasElement.style.width =  '1280px';
canvasElement.style.height = '720px';
canvasElement.style.display = 'block';
canvasElement.style['margin-left'] = 'auto';
canvasElement.style['margin-right'] = 'auto';

statusElement.style.display = 'none';
progressElement.style.display = 'none';
document.getElementById('progressdiv').style.display = 'none';
document.getElementById('output').style.display = 'none';
document.getElementById('game-input').style.display = "none"

if (!window.parent.window.gtk) {
  window.parent.window.gtk = {};
}

window.parent.window.gtk.saveMain = function(text) {
  FS.writeFile('app/main.rb', text);
  window.gtk.play();
}


var loadDataFiles = function(dbname, baseurl, onsuccess) {
  var syncdata = syncDataFiles(dbname, baseurl);
  window.gtk.syncdata = syncdata;

  syncdata.onerror = function(why) {
    Module.setStatus(why);
  }

  syncdata.onprogress = function(why, total_downloaded, total_to_download) {
    Module.setStatus(why);
  }

  syncdata.onsuccess = function(why) {
    //Module.setStatus(why);
    console.log(why);

    GGameFilesDatabase = syncdata.db;
    window.gtk.filedb = syncdata.db;

    var db = syncdata.db;
    var manifest = syncdata.manifest;
    syncdata.failed = false;
    syncdata.num_requests = 0;
    syncdata.total_requests = 0;

    db.onerror = function(event) {
      Module.setStatus("Database error: " + event.target.error.message);
      syncdata.failed = true;
    };

    var transaction = db.transaction("data", "readonly");
    var objstore = transaction.objectStore("data");
    var dataindex = objstore.index("data");

    for (var i in manifest) {
      // !!! FIXME: this assumes the whole file is in one chunk, but
      // !!! FIXME:  that was not my original plan.
      syncdata.total_requests++;
      syncdata.num_requests++;
      //console.log("'" + i + "' is headed for MEMFS...");
      var req = dataindex.get(i);
      req.filesize = manifest[i].filesize;
      req.onsuccess = function(event) {
        var path = "/" + event.target.result.filename;
        //console.log("'" + path + "' is loaded in from IndexedDB...");
        var ui8arr = new Uint8Array(event.target.result.chunk);
        var len = event.target.filesize;
        var arr = new Array(len);
        for (var i = 0; i < len; ++i) {
          arr[i] = ui8arr[i];
        }

        var basedir = PATH.dirname(path);
        FS.mkdirTree(basedir);

        var okay = false;
        try {
          okay = FS.createDataFile(basedir, PATH.basename(path), arr, true, true, true);
        } catch (err) {  // throws if file exists, etc. Nuke and try one more time.
          FS.unlink(path);
          try {
            okay = FS.createDataFile(basedir, PATH.basename(path), arr, true, true, true);
          } catch (err) {
            okay = false;  // oh well.
          }
        }

        if (!okay) {
          Module.setStatus("ERROR: Failed to put '" + path + "' in MEMFS.");
        } else {
          var completed = syncdata.total_requests - syncdata.num_requests;
          var percent = Math.floor((completed / syncdata.total_requests) * 100.0);
          Module.setStatus("Preparing game data: " + percent + "%");
          //console.log("'" + path + "' has made it to MEMFS! (" + syncdata.num_requests + " to go)");
          syncdata.num_requests--;
          if (syncdata.num_requests <= 0) {
            if (!syncdata.failed) {
              onsuccess();
            }
          }
        }
      };
    }
  }
}

// https://stackoverflow.com/a/7372816
var base64Encode = function(ui8array) {
    var CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    var out = "", i = 0, len = ui8array.length, c1, c2, c3;
    while (i < len) {
        c1 = ui8array[i++] & 0xff;
        if (i == len) {
            out += CHARS.charAt(c1 >> 2);
            out += CHARS.charAt((c1 & 0x3) << 4);
            out += "==";
            break;
        }
        c2 = ui8array[i++];
        if (i == len) {
            out += CHARS.charAt(c1 >> 2);
            out += CHARS.charAt(((c1 & 0x3)<< 4) | ((c2 & 0xF0) >> 4));
            out += CHARS.charAt((c2 & 0xF) << 2);
            out += "=";
            break;
        }
        c3 = ui8array[i++];
        out += CHARS.charAt(c1 >> 2);
        out += CHARS.charAt(((c1 & 0x3) << 4) | ((c2 & 0xF0) >> 4));
        out += CHARS.charAt(((c2 & 0xF) << 2) | ((c3 & 0xC0) >> 6));
        out += CHARS.charAt(c3 & 0x3F);
    }
    return out;
}

var Module = {
  noInitialRun: true,
  preInit: [],
  clickedToPlay: false,
  clickToPlayListener: function() {
    if (Module.clickedToPlay) return;
    Module.clickedToPlay = true;
    var div = document.getElementById('clicktoplaydiv');
    if (div) {
        div.removeEventListener('click', Module.clickToPlayListener);
        document.body.removeChild(div);
    }
    if (window.parent.window.gtk.starting) {
      window.parent.window.gtk.starting();
    }
    Module["callMain"]();  // go go go!
  },
  startClickToPlay: function() {
    var base64 = base64Encode(FS.readFile(GDragonRubyIcon, {}));
    var div = document.createElement('div');
    var leftPx = ((window.innerWidth - 640) / 2);
    var leftPerc = Math.floor((leftPx / window.innerWidth) * 100);
    div.id = 'clicktoplaydiv';
    div.style.backgroundColor = 'rgb(40, 44, 52)';
    div.style.left = leftPerc.toString() + "%";
    div.style.top = '10%';
    div.style.display = 'block';
    div.style.position = 'absolute';
    div.style.width = "640px"
    div.style.height = "360px"



    var img = new Image();
    img.onload = function() {  // once we know its size, scale it, keeping aspect ratio.
      var zoomRatio = 100.0 / this.width;
      img.style.width = (zoomRatio * this.width.toString()) + "px";
      img.style.height = (zoomRatio * this.height.toString()) + "px";
      img.style.display = "block";
      img.style['margin-left'] = 'auto';
      img.style['margin-right'] = 'auto';
    }

    img.style.display = 'none';
    img.src = 'data:image/png;base64,' + base64;
    div.appendChild(img);


    var p;

    p = document.createElement('h1');
    p.textContent = GDragonRubyGameTitle + " " + GDragonRubyGameVersion + " by " + GDragonRubyDevTitle;
    p.style.textAlign = 'center';
    p.style.color = '#FFFFFF';
    p.style.width = '100%';
    p.style['font-family'] = "monospace";
    div.appendChild(p);

    p = document.createElement('p');
    p.innerHTML = 'Click here to begin.';
    p.style['font-family'] = "monospace";
    p.style['font-size'] = "20px";
    p.style.textAlign = 'center';
    p.style.backgroundColor = 'rgb(40, 44, 52)';
    p.style.color = '#FFFFFF';
    p.style.width = '100%';
    div.appendChild(p);

    document.body.appendChild(div);
    div.addEventListener('click', Module.clickToPlayListener);
    window.gtk.play = Module.clickToPlayListener;
  },
  preRun: function() {
    // set up a persistent store for save games, etc.
    FS.mkdir('/persistent');
    FS.mount(IDBFS, {}, '/persistent');
    FS.syncfs(true, function(err) {
      if (err) {
        console.log("WARNING: Failed to populate persistent store. Save games likely lost?");
      } else {
        console.log("Read in from persistent store.");
      }

      loadDataFiles(GDragonRubyGameId, 'gamedata/', function() {
        console.log("Game data is sync'd to MEMFS. Starting click-to-play()...");
        //Module.setStatus("Ready!");
        //setTimeout(function() { Module.setStatus(""); statusElement.style.display='none'; }, 1000);
        Module.setStatus("");
        statusElement.style.display='none';
        Module.startClickToPlay();
      });
    });
  },
  postRun: [],
  print: (function() {
    var element = document.getElementById('output');
    if (element) element.value = ''; // clear browser cache
    return function(text) {
      if (arguments.length > 1) text = Array.prototype.slice.call(arguments).join(' ');
      // These replacements are necessary if you render to raw HTML
      //text = text.replace(/&/g, "&amp;");
      //text = text.replace(/</g, "&lt;");
      //text = text.replace(/>/g, "&gt;");
      //text = text.replace('\n', '<br>', 'g');
      console.log(text);
      if (element) {
        element.value += text + "\n";
        element.scrollTop = element.scrollHeight; // focus on bottom
      }
    };
  })(),
  printErr: function(text) {
    if (arguments.length > 1) text = Array.prototype.slice.call(arguments).join(' ');
    if (0) { // XXX disabled for safety typeof dump == 'function') {
      dump(text + '\n'); // fast, straight to the real console
    } else {
      console.error(text);
    }
  },
  canvas: (function() {
    var canvas = document.getElementById('canvas');

    // As a default initial behavior, pop up an alert when webgl context is lost. To make your
    // application robust, you may want to override this behavior before shipping!
    // See http://www.khronos.org/registry/webgl/specs/latest/1.0/#5.15.2
    canvas.addEventListener("webglcontextlost", function(e) { alert('WebGL context lost. You will need to reload the page.'); e.preventDefault(); }, false);
    canvas.addEventListener("click", function() {
      document.getElementById('toplevel').click();
      document.getElementById('toplevel').focus();
      document.getElementById('game-input').style.display = "inline"
      document.getElementById('game-input').focus();
      document.getElementById('game-input').blur();
      document.getElementById('game-input').style.display = "none"
      canvas.focus();
    });


    return canvas;
  })(),
  setStatus: function(text) {
    if (!Module.setStatus.last) Module.setStatus.last = { time: Date.now(), text: '' };
    if (text === Module.setStatus.text) return;
    var m = text.match(/([^(]+)\((\d+(\.\d+)?)\/(\d+)\)/);
    var now = Date.now();
    if (m && now - Date.now() < 30) return; // if this is a progress update, skip it if too soon
    if (m) {
      text = m[1];
      progressElement.value = parseInt(m[2])*100;
      progressElement.max = parseInt(m[4])*100;
      progressElement.hidden = false;
    } else {
      progressElement.value = null;
      progressElement.max = null;
      progressElement.hidden = true;
    }
    statusElement.innerHTML = text;
  },
  totalDependencies: 0,
  monitorRunDependencies: function(left) {
    this.totalDependencies = Math.max(this.totalDependencies, left);
    Module.setStatus(left ? 'Preparing... (' + (this.totalDependencies-left) + '/' + this.totalDependencies + ')' : 'All downloads complete.');
  }
};
Module.setStatus('Downloading...');
window.onerror = function(event) {
  // TODO: do not warn on ok events like simulating an infinite loop or exitStatus
  Module.setStatus('Exception thrown, see JavaScript console');
  Module.setStatus = function(text) {
    if (text) Module.printErr('[post-exception status] ' + text);
  };
};

var hasWebAssembly = false;
if (typeof WebAssembly==="object" && typeof WebAssembly.Memory==="function") {
  hasWebAssembly = true;
}
//console.log("Do we have WebAssembly? " + ((hasWebAssembly) ? "YES" : "NO"));

var buildtype = hasWebAssembly ? "wasm" : "asmjs";
var module = "dragonruby-" + buildtype + ".js";
window.gtk = {};
window.gtk.module = Module;

//console.log("Our main module is: " + module);

var script = document.createElement('script');
script.src = module;
if (hasWebAssembly) {
  script.async = true;
} else {
  script.async = false;  // !!! FIXME: can this be async?
  (function() {
    var memoryInitializer = module + '.mem';
    if (typeof Module['locateFile'] === 'function') {
      memoryInitializer = Module['locateFile'](memoryInitializer);
    } else if (Module['memoryInitializerPrefixURL']) {
      memoryInitializer = Module['memoryInitializerPrefixURL'] + memoryInitializer;
    }
    var meminitXHR = Module['memoryInitializerRequest'] = new XMLHttpRequest();
    meminitXHR.open('GET', memoryInitializer, true);
    meminitXHR.responseType = 'arraybuffer';
    meminitXHR.send(null);
  })();
}
document.body.appendChild(script);
