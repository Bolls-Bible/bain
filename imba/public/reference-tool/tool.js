const book_string =
  "Genesis|Gen?|Gn|Exodus|Exod?|Ex|Leviticus|Le?v|Numbers|Nu?m|Nu|Deuteronomy|Deut?|Dt|Josh?ua|Josh?|Jsh|Judges|Ju?dg|Jg|Ru(?:th)?|Ru?t|(?:1|i|2|ii) ?Samuel|(?:1|i|2|ii) ?S(?:a|m)|(?:1|i|2|ii) ?Sam|(?:1|i|2|ii) ?Kin(?:gs?)?|(?:1|i|2|ii) ?Kgs|(?:1|i|2|ii) ?Chronicles|(?:1|i|2|ii) ?Chr(?:o?n)?|(?:1|i|2|ii) ?Cr|Ezra?|Nehemiah|Neh?|Esther|Esth?|Jo?b|Psalms?|Psa?|Proverbs|Pro?v?|Ecclesiastes|Ec(?:cl?)?|Song (?:O|o)f Solomon|Song (?:O|o)f Songs?|Son(?:gs?)?|SS|Isaiah?|Isa?|Jeremiah|Je?r|Lamentations|La(?:me?)?|Ezekiel|Eze?k?|Daniel|Da?n|Da|Hosea|Hos?|Hs|Jo(?:el?)?|Am(?:os?)?|Obadiah|Ob(?:ad?)?|Jon(?:ah?)?|Jnh|Mic(?:ah?)?|Mi|Nah?um|Nah?|Habakkuk|Hab|Zephaniah|Ze?ph?|Haggai|Hagg?|Hg|Zechariah|Ze?ch?|Malachi|Ma?l|Matthew|Matt?|Mt|Mark|Ma(?:r|k)|M(?:r|k)|Luke?|Lk|Lu?c|John|Jn|Ac(?:ts?)?|Romans|Ro?m|(?:1|i|2|ii) ?Corinthians|(?:1|i|2|ii) ?C(?:or?)?|Galatians|Gal?|Gl|Ephesians|Eph?|Philippians|Phil|Colossians|Co?l|(?:1|i|2|ii) ?Thessalonians|(?:1|i|2|ii) ?Th(?:e(?:ss?)?)?|(?:1|i|2|ii) ?Timothy|(?:1|i|2|ii) ?Tim|(?:1|i|2|ii) ?T(?:i|m)|Ti(?:tus)?|Ti?t|Philemon|Phl?m|Hebrews|Heb?|Jam(?:es)?|Jms|Jas|(?:1|i|2|ii) ?Peter|(?:1|i|2|ii) ?Pe?t?|(?:1|i|2|ii|3|iii) ?J(?:oh)?n?|Jude?|Revelations?|Rev|R(?:e|v)";

const apoc_books =
  "|Tobit?|To?b|Judi(?:th?)?|Jdt|(?:1|2) ?Mac(?:cabees)?|(?:1|2) ?Ma?|Wi(?:sdom)?|Wi?s|Sir(?:ach)?|Ba(?:ruc?h)?|Ba?r";

class ReferenceTagging {
  // Public config options
  static translation = "YLT";
  static clickTooltip = false; // Defines whether the tooltip should be open on click or on hover
  static apocrypha = false; // Whether parse apocryphal books
  static showTooltips = true; // Whether tooltips should be shown, Otherwise it simply links to the passages
  static theme = "light"; // Theme, can be "light" or "dark"
  static delay = 300; // Delay in milliseconds before showing/hiding the tooltip

  // private fields
  static container = null;
  static host = "https://bolls.life";
  static showTimer = 0;
  static hideTimer = 0;

  version = "1.0.0";

  static init() {
    if (ReferenceTagging.showTooltips) {
      document.addEventListener("onclick", ReferenceTagging.hideAllTooltips);
    }
  }

  static hideAllTooltips() {
    const divs = document.getElementsByClassName("bg_popup-outer");
    for (let i = 0; i < divs.length; i++) {
      divs[i].style.display = "none";
    }
  }

  static tooltipMouseover(e) {
    let relNode = e.relatedTarget || e.fromElement;
    while (
      relNode &&
      relNode != null &&
      (!relNode.className ||
        relNode.className.indexOf("bg_popup-outer") === -1) &&
      relNode.nodeName.toLowerCase() !== "body"
    ) {
      relNode = relNode.parentNode;
    }
    if (
      relNode?.className &&
      relNode.className.indexOf("bg_popup-outer") !== -1
    )
      return;
  }

  static tooltipMouseout(e) {
    let relNode = e.relatedTarget || e.toElement;
    while (
      relNode &&
      relNode != null &&
      (!relNode.className ||
        relNode.className.indexOf("bg_popup-outer") === -1) &&
      relNode.nodeName.toLowerCase() !== "body"
    ) {
      relNode = relNode.parentNode;
    }
    if (
      relNode?.className &&
      relNode.className.indexOf("bg_popup-outer") !== -1
    )
      return;
    window.clearTimeout(ReferenceTagging.hideTimer);
    ReferenceTagging.hideTimer = window.setTimeout(() => {
      ReferenceTagging.hideAllTooltips(e);
    }, ReferenceTagging.delay);
  }

  static setTooltipStyle(tooltip, anchor) {
    const boundingRect = anchor.getBoundingClientRect();
    if (boundingRect.top > window.innerHeight / 2) {
      tooltip.style.bottom = "100%";
      tooltip.style.top = "unset";
    } else {
      tooltip.style.top = "100%";
      tooltip.style.bottom = "unset";
    }
    if (
      boundingRect.left > window.innerWidth / 2 ||
      boundingRect.right > window.innerWidth / 2
    ) {
      tooltip.style.right = "0px";
      tooltip.style.left = "unset";
    } else {
      tooltip.style.left = "0px";
      tooltip.style.right = "unset";
    }
  }

  static getTooltip(reference, link) {
    let tooltip = document.createElement("div");
    tooltip.style.display = "none";
    tooltip.addEventListener("click", (e) => e.stopPropagation());
    tooltip.className = `bg_popup bg_popup-outer ${
      ReferenceTagging.theme === "dark" && "bg_popup-dark"
    }`;
    ReferenceTagging.setTooltipStyle(tooltip, link);

    let id = `bg_popup-${reference.replace(/(?:%20)|\+|[^\x00-\x80]/g, "")}`;

    id = id.replace(/:/g, "_");
    id = id.replace(/ /g, "");
    tooltip.id = id;
    tooltip.innerHTML = `<div class="bg_popup-content"><div class="bg_popup-spinner">Loading...</div>`;
    tooltip.style.display = "block";
    ReferenceTagging.addCloseButton(tooltip);

    tooltip = link.appendChild(tooltip);
    if (ReferenceTagging.clickTooltip !== true) {
      ReferenceTagging.addListener(
        tooltip,
        "mouseover",
        ReferenceTagging.tooltipMouseover.bind(ReferenceTagging)
      );
      ReferenceTagging.addListener(
        tooltip,
        "mouseout",
        ReferenceTagging.tooltipMouseout.bind(ReferenceTagging)
      );
    }

    const remote_passage = document.createElement("script");
    remote_passage.type = "text/javascript";
    remote_passage.src = `${ReferenceTagging.host}/api/tag-tool-reference${reference}/?callback=ReferenceTagging.updateTooltip`;
    remote_passage.id = `bg_remote_passage_script-${reference.replace(
      /(?:%20)|\+|[^\x00-\x80]/g,
      ""
    )}`;
    remote_passage.id = remote_passage.id.replace(/:/g, "_");
    remote_passage.id = remote_passage.id.replace(/ /g, "");
    const hook = document.getElementsByTagName("script")[0];
    hook.parentNode.insertBefore(remote_passage, hook);

    return tooltip;
  }

  static showTooltip(e, link) {
    if (link == null) {
      link = e.currentTarget || e.target || e.srcElement;
    }
    let reference;
    const bibleref = link.getAttribute("data-bibleref");

    if (bibleref) {
      reference = bibleref;
    } else {
      reference = new URL(link.href).pathname;
    }

    let id = reference.replace(/%20| |\+|[^\x00-\x80]/g, "");
    id = id.replace(/:/g, "_");
    id = id.replace(/ /g, "");
    let tooltip = document.getElementById(`bg_popup-${id}`);
    ReferenceTagging.hideAllTooltips(e);
    if (tooltip === null) {
      tooltip = ReferenceTagging.getTooltip(reference, link);
    } else {
      ReferenceTagging.setTooltipStyle(tooltip, link);
      tooltip.style.display = "block";
    }
  }

  static linkMouseover(e) {
    const target = e.currentTarget || e.target;
    if (target.nodeName.toLowerCase() === "a") {
      window.clearTimeout(ReferenceTagging.showTimer);
      window.clearTimeout(ReferenceTagging.hideTimer);
      ReferenceTagging.showTimer = window.setTimeout(() => {
        ReferenceTagging.showTooltip(e, target);
      }, ReferenceTagging.delay);
    }
  }

  static linkMouseout(e) {
    if (e.target.nodeName.toLowerCase() === "a" && ReferenceTagging.showTimer) {
      window.clearTimeout(ReferenceTagging.showTimer);
      window.clearTimeout(ReferenceTagging.hideTimer);
      ReferenceTagging.hideTimer = window.setTimeout(() => {
        ReferenceTagging.hideTooltip(e);
      }, ReferenceTagging.delay);
    }
  }

  static toggleTooltip(e) {
    const link = e.target || e.srcElement;
    let reference;
    const bibleref = link.getAttribute("data-bibleref");
    if (bibleref) {
      reference = bibleref;
    } else {
      reference = new URL(link.href).pathname;
    }

    let id = reference.replace(/%20| /g, "");
    id = reference.replace(/:/g, "_");
    const tooltip = document.getElementById(`bg_popup-${id}`);
    if (tooltip === null || tooltip.style.display === "none") {
      ReferenceTagging.showTooltip(e);
    } else {
      ReferenceTagging.hideTooltip(e);
    }
  }

  static hideTooltip(e) {
    const link = e.target || e.srcElement;
    let reference;
    const bibleref = link.getAttribute("data-bibleref");
    if (bibleref) {
      reference = bibleref;
    } else {
      reference = new URL(link.href).pathname;
    }

    reference = reference.replace(/%20| /g, "");
    reference = reference.replace(/:/g, "_");

    const tooltip = document.getElementById(`bg_popup-${reference}`);
    if (tooltip) {
      tooltip.style.display = "none";
    }
  }

  static linkVerses() {
    ReferenceTagging.insertBiblerefs(document.body);
    if (ReferenceTagging.showTooltips === true) {
      const links = document.getElementsByTagName("a");
      for (let i = 0; i < links.length; i++) {
        const link = links[i];

        if (link.className && link.className.indexOf("bibleref") !== -1) {
          if (ReferenceTagging.clickTooltip !== true) {
            ReferenceTagging.addListener(
              link,
              "mouseover",
              ReferenceTagging.linkMouseover
            );
            ReferenceTagging.addListener(
              link,
              "mouseout",
              ReferenceTagging.linkMouseout
            );
          } else {
            ReferenceTagging.addListener(
              link,
              "click",
              ReferenceTagging.toggleTooltip
            );
          }
        }
      }
    }
  }

  static addListener(listen_object, action, callback) {
    if (listen_object.addEventListener) {
      if (action === "mouseover") {
        listen_object.addEventListener("mouseover", callback, false);
      } else if (action === "mouseout") {
        listen_object.addEventListener("mouseout", callback, false);
      } else if (action === "click") {
        listen_object.addEventListener("click", callback, false);
      }
    } else if (listen_object.attachEvent) {
      if (action === "mouseover") {
        listen_object.attachEvent("onmouseover", callback);
      } else if (action === "mouseout") {
        listen_object.attachEvent("onmouseout", callback);
      } else if (action === "click") {
        listen_object.attachEvent("onclick", callback);
      }
    } else {
      if (action === "mouseover") {
        listen_object.onmouseover = callback;
      } else if (action === "mouseout") {
        listen_object.onmouseout = callback;
      } else if (action === "click") {
        listen_object.onclick = callback;
      }
    }
  }

  static insertBiblerefs(node) {
    let new_nodes;
    if (node.nodeType === 3) {
      new_nodes = ReferenceTagging.searchNode(node, 0);
      return new_nodes;
    }
    if (node.tagName?.match(/^(?:a|h\d|img|pre|input|option)$/i)) {
      return null;
    }
    const children = node.childNodes;
    let i = 0;
    while (i < children.length) {
      new_nodes = ReferenceTagging.insertBiblerefs(children[i]);
      i += new_nodes + 1;
    }
    return null;
  }

  static searchNode(node, inserted_nodes) {
    let newTxtNode;
    const apoc_string = ReferenceTagging.apocrypha === true ? apoc_books : "";
    const unicode_space =
      "[\\u0020\\u00a0\\u1680\\u2000-\\u200a\\u2028-\\u202f\\u205f\\u3000]";
    //finds book and chapter for each verse that been separated by &,and,etc...
    const book_chap = `((?:(${book_string}${apoc_string})(?:.)?${unicode_space}*?)?(?:(\\d*):)?(\\d+(?:(?:ff|f|\\w)|(?:\\s?(?:-|–|—)\\s?\\d+)?)))([^a-z0-9]*)`;
    const regex_string = `(?:${book_string}${apoc_string})(?:.)?${unicode_space}*?\\d+:\\d+(?:ff|f|\\w)?(?:\\s?(?:(?:(?:-|–|—)\\s?(?:(?:${book_string}${apoc_string})(?:.)?\\s)?)|(?:(?:,|;|&amp;|&|and|cf\\.|cf)))\\s?(?:(?:(?:vv.|vs.|vss.|v.) ?)?\\d+\\w?)(?::\\d+\\w?)?)*`;
    const regex = new RegExp(regex_string, "i");
    const verse_match = node.nodeValue.match(regex);
    if (verse_match == null) {
      return inserted_nodes;
    }
    const text = node.nodeValue;
    const before_text = text.substr(0, text.indexOf(verse_match[0]));
    const after_text = text.substr(
      text.indexOf(verse_match[0]) + verse_match[0].length
    );
    if (before_text.length > 0) {
      newTxtNode = document.createTextNode(before_text);
      node.parentNode.insertBefore(newTxtNode, node);
      inserted_nodes++;
    }

    const book_chap_regex = new RegExp(book_chap, "gi");
    let book;
    let chapter;
    let verse;
    let matched;

    // biome-ignore lint/suspicious/noAssignInExpressions: <explanation>
    while ((matched = book_chap_regex.exec(verse_match[0]))) {
      // break up what may be multiple references into links.
      if (matched[2] !== "" && matched[2] != null) {
        book = matched[2];
      }
      if (matched[3] !== "" && matched[3] != null) {
        chapter = matched[3];
      }
      verse = matched[4];
      const newLinkNode = document.createElement("a");
      newLinkNode.className = "bibleref";
      newLinkNode.target = "_BLANK";
      newLinkNode.href = `${ReferenceTagging.host}/${ReferenceTagging.translation}/${book}/${chapter}/${verse}`;
      newLinkNode.innerHTML = matched[1];
      if (ReferenceTagging.clickTooltip === true) {
        newLinkNode.onclick = () => false;
      }
      node.parentNode.insertBefore(newLinkNode, node);
      inserted_nodes++;
      if (matched[6] !== "") {
        newTxtNode = document.createTextNode(matched[5]);
        node.parentNode.insertBefore(newTxtNode, node);
        // do we need to update inserted_nodes with this?
      }
    }

    if (after_text.length > 0) {
      newTxtNode = document.createTextNode(after_text);
      node.parentNode.insertBefore(newTxtNode, node);
      node.parentNode.removeChild(node);
      inserted_nodes = ReferenceTagging.searchNode(
        newTxtNode,
        inserted_nodes + 1
      );
    } else {
      node.parentNode.removeChild(node);
    }
    return inserted_nodes;
  }

  static updateTooltip(tooltip_content) {
    let id = `bg_popup-${tooltip_content.reference.replace(/:/g, "_")}`;
    id = id.replace(/ |\+|[^\x00-\x80]/g, "");

    const tooltip = document.getElementById(id);

    let reference_display = tooltip_content.reference_display.replace(
      /%20/g,
      " "
    );
    if (tooltip_content.text === undefined) {
      if (tooltip.text === undefined) {
        tooltip_content.text = "Retrieving Passage...";
      } else {
        tooltip_content.text = tooltip.text;
        reference_display = tooltip.reference_display;
      }
    }

    tooltip.innerHTML = `<div class="bg_popup-content"><p>${tooltip_content.text} <b>(${ReferenceTagging.translation})</b></p></div>`;
    ReferenceTagging.addCloseButton(tooltip);
  }

  static addCloseButton(tooltip) {
    const divs = tooltip.getElementsByTagName("div");
    for (let i = 0; i < divs.length; i++) {
      if (divs[i].className === "bg_popup-header_right") {
        ReferenceTagging.addListener(
          divs[i],
          "click",
          ReferenceTagging.hideAllTooltips
        );
      }
    }
  }
}
