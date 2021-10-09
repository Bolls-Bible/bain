var __create = Object.create;
var __defProp = Object.defineProperty;
var __getProtoOf = Object.getPrototypeOf;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __markAsModule = (target) => __defProp(target, "__esModule", {value: true});
var __exportStar = (target, module2, desc) => {
  if (module2 && typeof module2 === "object" || typeof module2 === "function") {
    for (let key of __getOwnPropNames(module2))
      if (!__hasOwnProp.call(target, key) && key !== "default")
        __defProp(target, key, {get: () => module2[key], enumerable: !(desc = __getOwnPropDesc(module2, key)) || desc.enumerable});
  }
  return target;
};
var __toModule = (module2) => {
  return __exportStar(__markAsModule(__defProp(module2 != null ? __create(__getProtoOf(module2)) : {}, "default", module2 && module2.__esModule && "default" in module2 ? {get: () => module2.default, enumerable: true} : {value: module2, enumerable: true})), module2);
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
function iter$__(a) {
  let v;
  return a ? (v = a.toIterable) ? v.call(a) : a : [];
}
var φ1 = Symbol.for("#type");
var φ20 = Symbol.for("#__listeners__");
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
  var φ7, φ6, φ11, φ18;
  let origs = {};
  let diff = {
    added: [],
    changed: [],
    removed: [],
    all: [],
    urls: {}
  };
  if (prev.assets) {
    for (let φ42 = 0, φ52 = iter$__(prev.assets), φ8 = φ52.length; φ42 < φ8; φ42++) {
      let item = φ52[φ42];
      let ref = item.originalPath || item.path;
      origs[ref] = item;
      if (item.url) {
        (φ7 = curr.urls)[φ6 = item.url] || (φ7[φ6] = item);
      }
      ;
    }
    ;
  }
  ;
  for (let φ9 = 0, φ10 = iter$__(curr.assets || []), φ122 = φ10.length; φ9 < φ122; φ9++) {
    let item = φ10[φ9];
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
      φ11 = origs[ref], delete origs[ref], φ11;
    } else {
      diff.added.push(item);
      diff.all.push(item);
    }
    ;
  }
  ;
  for (let φ132 = 0, φ14 = Object.keys(origs), φ15 = φ14.length, path, item; φ132 < φ15; φ132++) {
    path = φ14[φ132];
    item = origs[path];
    item.removed = Date.now();
    diff.all.push(item);
  }
  ;
  for (let φ16 = 0, φ17 = iter$__(diff.all), φ19 = φ17.length; φ16 < φ19; φ16++) {
    let item = φ17[φ16];
    let typ = diff[φ18 = item.type] || (diff[φ18] = []);
    typ.push(item);
  }
  ;
  diff.removed = Object.values(origs);
  curr.changes = diff;
  return curr;
}

// src/imba/manifest.imba
var φ12 = Symbol.for("#refresh");
var φ2 = Symbol.for("#manifest");
var φ3 = Symbol.for("#absPath");
var φ4 = Symbol.for("#raw");
var φ5 = Symbol.for("#watch");
var Asset = class {
  constructor(manifest3) {
    this[φ2] = manifest3;
  }
  get absPath() {
    return this[φ3] || (this[φ3] = this[φ2].resolve(this));
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
    return this.url || this.absPath;
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
    return import_path.default.resolve(import_path.default.dirname(this.path), this.data.srcdir);
  }
  get outdir() {
    return import_path.default.resolve(import_path.default.dirname(this.path), this.data.outdir);
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
    return this.data[φ4];
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
  resolveAssetPath(path) {
    return import_path.default.resolve(this.outdir, path);
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
      raw[φ4] = str;
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
    return this.data[φ4];
  }
  [φ12](data) {
    return true;
  }
  watch() {
    var self = this;
    if (this[φ5] != true ? (this[φ5] = true, true) : false) {
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
  return globalThis[φ2];
});

// loader.imba
var φ13 = Symbol.for("#manifest");
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
      manifest2 = globalThis[φ13] = new Manifest({path: name + ".manifest"});
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
