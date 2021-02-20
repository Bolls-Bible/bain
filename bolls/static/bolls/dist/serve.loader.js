var __create = Object.create;
var __defProp = Object.defineProperty;
var __getProtoOf = Object.getPrototypeOf;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __markAsModule = (target) => __defProp(target, "__esModule", {value: true});
var __exportStar = (target, module2, desc) => {
  __markAsModule(target);
  if (module2 && typeof module2 === "object" || typeof module2 === "function") {
    for (let key of __getOwnPropNames(module2))
      if (!__hasOwnProp.call(target, key) && key !== "default")
        __defProp(target, key, {get: () => module2[key], enumerable: !(desc = __getOwnPropDesc(module2, key)) || desc.enumerable});
  }
  return target;
};
var __toModule = (module2) => {
  if (module2 && module2.__esModule)
    return module2;
  return __exportStar(__defProp(module2 != null ? __create(__getProtoOf(module2)) : {}, "default", {value: module2, enumerable: true}), module2);
};

// loader.imba
var import_path2 = __toModule(require("path"));
var import_fs2 = __toModule(require("fs"));
var import_module = __toModule(require("module"));

// src/imba/manifest.imba
var import_events = __toModule(require("events"));
var import_fs = __toModule(require("fs"));
var import_path = __toModule(require("path"));

// src/imba/utils.imba
function iter$(a) {
  let v;
  return a ? (v = a.toIterable) ? v.call(a) : a : [];
}
var sys$1 = Symbol.for("#type");
var sys$16 = Symbol.for("#__listeners__");
function deserializeData(data, reviver = null) {
  let objects = {};
  let reg = /\$\$\d+\$\$/;
  let lookup = function(value) {
    return objects[value] || (objects[value] = reviver ? reviver(value) : {});
  };
  let parser = function(key, value) {
    if (typeof value == "string") {
      if (value[0] == "$" && reg.test(value)) {
        return lookup(value);
      }
      ;
    } else if (typeof key == "string" && key[0] == "$" && reg.test(key)) {
      let obj = lookup(key);
      Object.assign(obj, value);
      return obj;
    }
    ;
    return value;
  };
  let parsed = JSON.parse(data, parser);
  return parsed;
}
function patchManifest(prev, curr) {
  var $0$2, $0$1, $0$3, $0$4;
  let origs = {};
  let diff = {
    added: [],
    changed: [],
    removed: [],
    all: [],
    urls: {}
  };
  if (prev.assets) {
    for (let sys$42 = 0, sys$52 = iter$(prev.assets), sys$6 = sys$52.length; sys$42 < sys$6; sys$42++) {
      let item = sys$52[sys$42];
      let ref = item.originalPath || item.path;
      origs[ref] = item;
      if (item.url) {
        ($0$2 = curr.urls)[$0$1 = item.url] || ($0$2[$0$1] = item);
      }
      ;
    }
    ;
  }
  ;
  for (let sys$7 = 0, sys$8 = iter$(curr.assets || []), sys$9 = sys$8.length; sys$7 < sys$9; sys$7++) {
    let item = sys$8[sys$7];
    let ref = item.originalPath || item.path;
    let orig = origs[ref];
    if (item.url && prev.urls) {
      prev.urls[item.url] = item;
    }
    ;
    if (orig) {
      if (orig.hash != item.hash) {
        orig.invalidated = Date.now();
        orig.replacedBy = item;
        item.replaces = orig;
        diff.changed.push(item);
        diff.all.push(item);
        if (orig == prev.main) {
          diff.main = item;
        }
        ;
      }
      ;
      $0$3 = origs[ref], delete origs[ref], $0$3;
    } else {
      diff.added.push(item);
      diff.all.push(item);
    }
    ;
  }
  ;
  for (let sys$10 = 0, sys$11 = Object.keys(origs), sys$122 = sys$11.length, path, item; sys$10 < sys$122; sys$10++) {
    path = sys$11[sys$10];
    item = origs[path];
    item.removed = Date.now();
    diff.all.push(item);
  }
  ;
  for (let sys$132 = 0, sys$14 = iter$(diff.all), sys$15 = sys$14.length; sys$132 < sys$15; sys$132++) {
    let item = sys$14[sys$132];
    let typ = diff[$0$4 = item.type] || (diff[$0$4] = []);
    typ.push(item);
  }
  ;
  diff.removed = Object.values(origs);
  curr.changes = diff;
  return curr;
}

// src/imba/manifest.imba
var sys$12 = Symbol.for("#refresh");
var sys$2 = Symbol.for("#manifest");
var sys$3 = Symbol.for("#absPath");
var sys$4 = Symbol.for("#raw");
var sys$5 = Symbol.for("#watch");
var Asset = class {
  constructor(manifest3) {
    this[sys$2] = manifest3;
  }
  get absPath() {
    return this[sys$3] || (this[sys$3] = this[sys$2].resolve(this));
  }
  get name() {
    return import_path.default.basename(this.path);
  }
  get body() {
    return this.readSync();
  }
  readSync() {
    return import_fs.default.readFileSync(this.absPath, "utf-8");
  }
  pipe(res) {
    let stream = import_fs.default.createReadStream(this.absPath);
    return stream.pipe(res);
  }
  toString() {
    return this.url;
  }
};
var Manifest = class extends import_events.EventEmitter {
  constructor(options = {}) {
    var self;
    super();
    self = this;
    this.options = options;
    this.data = {};
    this.path = options.path;
    this.refs = {};
    this.reviver = function(key) {
      return new Asset(self);
    };
    this.init(options.data);
  }
  get srcdir() {
    return import_path.default.resolve(this.path, this.data.srcdir);
  }
  get outdir() {
    return import_path.default.resolve(this.path, this.data.outdir);
  }
  get changes() {
    return this.data.changes || {};
  }
  get inputs() {
    return this.data.inputs;
  }
  get outputs() {
    return this.data.outputs;
  }
  get assets() {
    return this.data.assets;
  }
  get urls() {
    return this.data.urls || {};
  }
  get main() {
    return this.data.main;
  }
  get cwd() {
    return process.cwd();
  }
  get raw() {
    return this.data[sys$4];
  }
  resolve(path) {
    if (path._ == "input") {
      return import_path.default.resolve(this.srcdir || this.cwd, path.path);
    } else if (path._ == "output") {
      return import_path.default.resolve(this.outdir, path.path);
    } else {
      return import_path.default.resolve(this.cwd, path.path || path);
    }
    ;
  }
  read(path) {
    return import_fs.default.readFileSync(this.resolve(path), "utf-8");
  }
  loadFromFile(path) {
    return import_fs.default.existsSync(path) ? import_fs.default.readFileSync(path, "utf-8") : "{}";
  }
  init(data = null) {
    if (data || this.path) {
      this.update(data);
    }
    ;
    return this;
  }
  update(raw) {
    if (raw == null) {
      if (this.path) {
        raw = this.loadFromFile(this.path);
      } else {
        console.warn("cannot update manifest without path");
      }
      ;
    }
    ;
    if (typeof raw == "string") {
      let str = raw;
      raw = deserializeData(raw, this.reviver);
      raw[sys$4] = str;
    }
    ;
    this.data = patchManifest(this.data || {}, raw);
    if (this.data.changes.all.length) {
      this.emit("change", this.diff, this);
    }
    ;
    if (this.data.changes.main) {
      this.emit("change:main", this.data.main, this);
    }
    ;
    return this.data.changes;
  }
  serializeForBrowser() {
    return this.data[sys$4];
  }
  [sys$12](data) {
    return true;
  }
  watch() {
    var self = this;
    if (this[sys$5] != true ? (this[sys$5] = true, true) : false) {
      return this.path && !process.env.IMBA_HMR && import_fs.default.watch(this.path, function(ev, name) {
        let exists = import_fs.default.existsSync(self.path);
        let stat = exists && import_fs.default.statSync(self.path);
        if (exists) {
          self.update();
        }
        ;
        return;
      });
    }
    ;
  }
  on(event, cb) {
    this.watch();
    return super.on(...arguments);
  }
};
var LazyProxy = class {
  static for(getter) {
    return new Proxy({}, new this(getter));
  }
  constructor(getter) {
    this.getter = getter;
  }
  get target() {
    return this.getter();
  }
  get(_, key) {
    return this.target[key];
  }
  set(_, key, value) {
    this.target[key] = value;
    return true;
  }
};
var manifest = LazyProxy.for(function() {
  return globalThis[sys$2];
});

// loader.imba
var sys$13 = Symbol.for("#manifest");
var {_resolveFilename} = import_module.Module;
var manifest2 = null;
function resolveVirtual(path, output, realpath) {
  let ext = import_path2.default.extname(path);
  let name = import_path2.default.basename(path);
  let sup = import_module.Module._extensions[ext];
  import_module.Module._extensions[ext] = function(mod, filename) {
    import_module.Module._extensions[ext] = sup;
    let body = output.readSync();
    let find = "//# sourceMappingURL=" + output.name + ".map";
    let replace = "//# sourceMappingURL=" + realpath + ".map";
    body = body.replace(find, replace);
    return mod._compile(body, filename);
  };
  return path;
}
import_module.Module._resolveFilename = function(name, from) {
  if (!manifest2) {
    if (import_fs2.default.existsSync(name + ".manifest")) {
      manifest2 = globalThis[sys$13] = new Manifest({path: name + ".manifest"});
      let output = manifest2.main;
      if (output) {
        let path = output.source.absPath;
        resolveVirtual(path, output, name);
        return path;
      }
      ;
    }
    ;
  }
  ;
  let res = _resolveFilename.apply(import_module.Module, arguments);
  return res;
};
if (require.main == module) {
  let main = __filename.replace(".loader.js", ".js");
  if (main != __filename) {
    require(main);
  }
  ;
}
