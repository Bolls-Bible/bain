// copy here versions from languages.json
const languages = [
  {
    language: "Ukrainian Українська / Церковнослав'янська",
    translations: [
      {
        short_name: "UBIO",
        full_name: "Біблія, Іван Іванович Огієнко 1962",
        info: "http://uk.wikipedia.org/wiki/%D0%9F%D0%B5%D1%80%D0%B5%D0%BA%D0%BB%D0%B0%D0%B4_%D0%91%D1%96%D0%B1%D0%BB%D1%96%D1%97_%D0%86%D0%B2%D0%B0%D0%BD%D0%B0_%D0%9E%D0%B3%D1%96%D1%94%D0%BD%D0%BA%D0%B0",
        updated: 1591185595149,
      },
      {
        short_name: "UKRK",
        full_name:
          "Біблія. Пантелеймон Александрович Куліш, Іван Семенович Нечуй-Левицький, Іван Павлович Пулюй, 1903",
        info: "http://uk.wikipedia.org/wiki/%D0%9F%D0%B5%D1%80%D0%B5%D0%BA%D0%BB%D0%B0%D0%B4%D0%B8_%D0%91%D1%96%D0%B1%D0%BB%D1%96%D1%97_%D1%83%D0%BA%D1%80%D0%B0%D1%97%D0%BD%D1%81%D1%8C%D0%BA%D0%BE%D1%8E_%D0%BC%D0%BE%D0%B2%D0%BE%D1%8E#%D0%9F%D0%B5%D1%80%D0%B5%D0%BA%D0%BB%D0%B0%D0%B4_%D0%9F%D0%B0%D0%BD%D1%82%D0%B5%D0%BB%D0%B5%D0%B9%D0%BC%D0%BE%D0%BD%D0%B0_%D0%9A%D1%83%D0%BB%D1%96%D1%88%D0%B0,_%D0%86%D0%B2%D0%B0%D0%BD%D0%B0_%D0%9F%D1%83%D0%BB%D1%8E%D1%8F,_%D0%86%D0%B2%D0%B0%D0%BD%D0%B0_%D0%9D%D0%B5%D1%87%D1%83%D0%B9-%D0%9B%D0%B5%D0%B2%D0%B8%D1%86%D1%8C%D0%BA%D0%BE%D0%B3%D0%BE",
        updated: 1653205808333,
      },
      {
        short_name: "HOM",
        full_name: "Святе Письмо, Переклад Івана Хоменка, 1963",
        info: "http://uk.wikipedia.org/wiki/%D0%9F%D0%B5%D1%80%D0%B5%D0%BA%D0%BB%D0%B0%D0%B4%D0%B8_%D0%91%D1%96%D0%B1%D0%BB%D1%96%D1%97_%D1%83%D0%BA%D1%80%D0%B0%D1%97%D0%BD%D1%81%D1%8C%D0%BA%D0%BE%D1%8E_%D0%BC%D0%BE%D0%B2%D0%BE%D1%8E#%D0%9F%D0%B5%D1%80%D0%B5%D0%BA%D0%BB%D0%B0%D0%B4_%D0%86%D0%B2%D0%B0%D0%BD%D0%B0_%D0%A5%D0%BE%D0%BC%D0%B5%D0%BD%D0%BA%D0%B0",
        updated: 1591185595163,
      },
      {
        short_name: "UTT",
        full_name: "Українська Біблія LXX УБТ Рафаїла Турконяка (2011) 77 книг",
        info: "http://uk.wikipedia.org/wiki/%D0%9F%D0%B5%D1%80%D0%B5%D0%BA%D0%BB%D0%B0%D0%B4%D0%B8_%D0%91%D1%96%D0%B1%D0%BB%D1%96%D1%97_%D0%A0%D0%B0%D1%84%D0%B0%D1%97%D0%BB%D0%B0_%D0%A2%D1%83%D1%80%D0%BA%D0%BE%D0%BD%D1%8F%D0%BA%D0%B0",
        updated: 1635188106109,
      },
      {
        short_name: "UMT",
        full_name: "Свята Біблія: Сучасною мовою",
        updated: 1635188106109,
      },
      {
        short_name: "PHIL",
        full_name: "Бiблiя. Переклад Патріарха ФІЛАРЕТА (Денисенка), 2004",
        updated: 1635188106109,
      },
      {
        short_name: "CUV23",
        full_name: "БІБЛІЯ Сучасний переклад © УБТ (2020-2023)",
        updated: 1626349711821,
      },
      {
        short_name: "CSL",
        full_name: "Библия Церковнославянская, 1900",
        info: "http://ru.wikipedia.org/wiki/%D0%A6%D0%B5%D1%80%D0%BA%D0%BE%D0%B2%D0%BD%D0%BE%D1%81%D0%BB%D0%B0%D0%B2%D1%8F%D0%BD%D1%81%D0%BA%D0%B8%D0%B5_%D0%BF%D0%B5%D1%80%D0%B5%D0%B2%D0%BE%D0%B4%D1%8B_%D0%91%D0%B8%D0%B1%D0%BB%D0%B8%D0%B8",
        updated: 1626349711821,
      },
    ],
  },
  {
    language: "Arabic العربية",
    translations: [
      {
        full_name: "Smith and Van Dyke",
        short_name: "SVD",
        updated: 1671955360023,
        dir: "rtl",
      },
    ],
  },
  {
    language: "Chinese 中文",
    translations: [
      {
        short_name: "CUV",
        full_name: "Chinese Union (Traditional) 和合本",
        info: "http://en.wikipedia.org/wiki/Chinese_Union_Version",
        updated: 1591185595149,
      },
      {
        short_name: "CUNP",
        full_name:
          "新標點和合本串珠 - Chinese Union New Punctuation Cross References, 1988",
        info: "http://en.wikipedia.org/wiki/Chinese_Union_Version",
        updated: 1591185595149,
      },
      {
        short_name: "CUNPS",
        full_name:
          "新标点和合本 - Chinese Union New Punctuation (Simplified), 1988",
        info: "http://en.wikipedia.org/wiki/Chinese_Union_Version",
        updated: 1591185595149,
      },
    ],
  },
  {
    language: "Czech Ceský",
    translations: [
      {
        short_name: "CSP09",
        full_name: "Ceský studijní preklad",
        info: "http://cs.wikipedia.org/wiki/%C4%8Cesk%C3%BD_studijn%C3%AD_p%C5%99eklad",
        updated: 1713956432231,
      },
    ],
  },
  {
    language: "English",
    translations: [
      {
        short_name: "YLT",
        full_name: "Young's Literal Translation (1898)",
        info: "http://wikipedia.org/wiki/Young%27s_Literal_Translation",
        updated: 1626349711821,
      },
      {
        short_name: "KJV",
        full_name:
          "King James Version 1769 with Apocrypha and Strong's Numbers",
        info: "http://wikipedia.org/wiki/King_James_Version",
        updated: 1722769103732,
      },
      {
        short_name: "NKJV",
        full_name: "New King James Version, 1982",
        info: "http://wikipedia.org/wiki/New_King_James_Version",
        updated: 1635188106109,
      },
      {
        short_name: "WEB",
        full_name: "World English Bible",
        info: "http://wikipedia.org/wiki/World_English_Bible",
        updated: 1678028993719,
      },
      {
        short_name: "RSV",
        full_name: "Revised Standard Version (1952)",
        info: "http://wikipedia.org/wiki/Revised_Standard_Version",
        updated: 1635188106109,
      },
      {
        short_name: "CJB",
        full_name: "The Complete Jewish Bible (1998)",
        info: "http://wikipedia.org/wiki/Messianic_Bible_translations#Complete_Jewish_Bible_(CJB)",
        updated: 1635188106109,
      },
      {
        short_name: "TS2009",
        full_name: "The Scriptures 2009",
        info: "http://isr-messianic.org/publications/the-scriptures.html",
        updated: 1635188106109,
      },
      {
        short_name: "LXXE",
        full_name: "English version of the Septuagint Bible, 1851",
        info: "http://ebible.org/eng-Brenton/",
        updated: 1635188106109,
      },
      {
        short_name: "TLV",
        full_name: "Tree of Life Version",
        info: "http://www.tlvbiblesociety.org/tree-of-life-version",
        updated: 1635188106109,
      },
      {
        short_name: "LSB",
        full_name: "The Legacy Standard Bible",
        info: "http://lsbible.org/",
        updated: 1702218835084,
      },
      {
        short_name: "NASB",
        full_name: "New American Standard Bible (1995)",
        info: "http://wikipedia.org/wiki/New_American_Standard_Bible",
        updated: 1598253681687,
      },
      {
        short_name: "ESV",
        full_name: "English Standard Version 2001, 2016",
        info: "http://en.wikipedia.org/wiki/English_Standard_Version",
        updated: 1635188106109,
      },
      {
        short_name: "GNV",
        full_name: "Geneva Bible (1599)",
        info: "http://wikipedia.org/wiki/Geneva_Bible",
        updated: 1635188106109,
      },
      {
        short_name: "DRB",
        full_name: "Douay Rheims Bible",
        info: "http://en.wikipedia.org/wiki/Douay%E2%80%93Rheims_Bible",
        updated: 1591185595149,
      },
      {
        short_name: "NIV2011",
        full_name: "New International Version, 2011",
        info: "http://en.wikipedia.org/wiki/New_International_Version",
        updated: 1626349711821,
      },
      {
        short_name: "NIV",
        full_name: "New International Version, 1984",
        info: "http://en.wikipedia.org/wiki/New_International_Version",
        updated: 1626349711821,
      },
      {
        short_name: "NLT",
        full_name: "New Living Translation, 2015",
        info: "http://en.wikipedia.org/wiki/New_Living_Translation",
        updated: 1635188106109,
      },
      {
        short_name: "NRSVCE",
        full_name: "New Revised Standard Version Catholic Edition, 1993",
        info: "http://en.wikipedia.org/wiki/New_Revised_Standard_Version_Catholic_Edition",
        updated: 1635188106109,
      },
      {
        short_name: "NET",
        full_name: "New English Translation, 2007",
        info: "http://en.wikipedia.org/wiki/New_English_Translation",
        updated: 1635188106109,
      },
      {
        short_name: "NJB1985",
        full_name: "New Jerusalem Bible, 1985",
        info: "http://en.wikipedia.org/wiki/New_Jerusalem_Bible",
        updated: 1635188106109,
      },
      {
        short_name: "SPE",
        full_name: "Samaritan Pentateuch in English, 2013",
        info: "http://en.wikipedia.org/wiki/Samaritan_Pentateuch",
        updated: 1635188106109,
      },
      {
        short_name: "LBP",
        full_name: "Aramaic Of The Peshitta: Lamsa, 1933",
        info: "http://en.wikipedia.org/wiki/Lamsa_Bible",
        updated: 1635188106109,
      },
      {
        short_name: "AMP",
        full_name: "Amplified Bible, 2015",
        info: "http://en.wikipedia.org/wiki/Amplified_Bible",
        updated: 1673261959445,
      },
      {
        short_name: "MSG",
        full_name: "The Message, 2002",
        info: "http://messagebible.com",
        updated: 1635188106109,
      },
      {
        short_name: "LSV",
        full_name: "Literal Standard Version",
        info: "http://www.lsvbible.com/",
        updated: 1635188106109,
      },
      {
        short_name: "BSB",
        full_name: "The Holy Bible, Berean Standard Bible",
        info: "http://berean.bible",
        updated: 1635188106109,
      },
      {
        short_name: "MEV",
        full_name: "Modern English Version",
        info: "http://en.wikipedia.org/wiki/Modern_English_Version",
        updated: 1713944506081,
      },
      {
        short_name: "RSV2CE",
        full_name: "Revised Standard Version Catholic Edition",
        info: "http://en.wikipedia.org/wiki/Revised_Standard_Version_Catholic_Edition",
        updated: 1713944506081,
      },
      {
        short_name: "NABRE",
        full_name: "New American Bible (Revised Edition)",
        info: "http://en.wikipedia.org/wiki/New_American_Bible_Revised_Edition",
        updated: 1723748851755,
      },
    ],
  },
  {
    language: "Farsi فارسی",
    translations: [
      {
        short_name: "POV",
        full_name: "Persian Old Version",
        info: "http://en.wikipedia.org/wiki/Bible_translations_into_Persian#Persian_Old_Version_(POV)",
        updated: 1626349711821,
        dir: "rtl",
      },
      {
        short_name: "FACB",
        full_name: "کتاب مقدس، ترجمه تفسیری Farsi Contemporary Bible",
        info: "",
        updated: 1626349711821,
        dir: "rtl",
      },
    ],
  },
  {
    language: "French Français",
    translations: [
      {
        short_name: "NBS",
        full_name: "Nouvelle Bible Segond, 2002",
        info: "http://fr.wikipedia.org/wiki/Bible_Segond",
        updated: 1636583761597,
      },
    ],
  },
  {
    language: "German Deutsch",
    translations: [
      {
        full_name: "Menge-Bibel",
        short_name: "MB",
        info: "http://de.wikipedia.org/wiki/Hermann_Menge",
        updated: 1591185595149,
      },
      {
        full_name: "Elberfelder Bibel, 1871",
        short_name: "ELB",
        info: "http://de.wikipedia.org/wiki/Elberfelder_Bibel",
        updated: 1591185595149,
      },
      {
        short_name: "SCH",
        full_name: "Schlachter (1951)",
        info: "http://wikipedia.org/wiki/Schlachter_Bible",
        updated: 1591185595149,
      },
      {
        short_name: "LUT",
        full_name: "Luther (1912)",
        info: "http://wikipedia.org/wiki/Luther_Bible",
        updated: 1591185595149,
      },
    ],
  },
  {
    language: "Greek Ελληνικά",
    translations: [
      {
        short_name: "TISCH",
        full_name:
          "Tischendorf's Greek New Testament, 8th edition, 1869–72 (With Strong's numbers)",
        info: "http://en.wikipedia.org/wiki/Constantin_von_Tischendorf",
        updated: 1591185595149,
      },
      {
        short_name: "NTGT",
        full_name: "Greek NT: Tischendorf 8th Ed.",
        info: "http://en.wikipedia.org/wiki/Constantin_von_Tischendorf",
        updated: 1591185595149,
      },
      {
        short_name: "LXX",
        full_name: "Septuagint",
        info: "http://wikipedia.org/wiki/Septuagint",
        updated: 1626349711821,
      },
      {
        short_name: "TR",
        full_name: "Elzevir Textus Receptus (1624)",
        info: "http://wikipedia.org/wiki/Textus_Receptus",
        updated: 1695799046182,
      },
    ],
  },
  {
    language: "Hebrew עברית",
    translations: [
      {
        short_name: "WLCa",
        full_name:
          "Westminster Leningrad Codex (with vowels, accents and Strong's numbers)",
        info: "http://wikipedia.org/wiki/Leningrad_Codex",
        updated: 1716109547986,
        dir: "rtl",
      },
      {
        short_name: "WLC",
        full_name: "Westminster Leningrad Codex (with Vowels)",
        info: "http://wikipedia.org/wiki/Leningrad_Codex",
        updated: 1591185595149,
        dir: "rtl",
      },
      {
        short_name: "WLCC",
        full_name: "Westminster Leningrad Codex (Consonants)",
        info: "http://wikipedia.org/wiki/Leningrad_Codex",
        updated: 1591185595149,
        dir: "rtl",
      },
      {
        short_name: "HAC",
        full_name: "כֶּתֶר אֲרָם צוֹבָא - Tanah Aleppo Codex",
        info: "http://en.wikipedia.org/wiki/Aleppo_Codex",
        updated: 1591185595149,
        dir: "rtl",
      },
      {
        short_name: "DHNT",
        full_name: "Delitzsch's Hebrew New Testament 1877, 1998 (with vowels)",
        updated: 1672568934565,
        dir: "rtl",
      },
    ],
  },
  {
    language: "Hungarian Magyar",
    translations: [
      {
        short_name: "RUF",
        full_name:
          "Magyar Bibliatársulat újfordítású Bibliája, 2014 (protestáns)",
        updated: 1681972167751,
      },
      {
        short_name: "KB",
        full_name: "Karoli Bible 1908",
        updated: 1653206484214,
      },
    ],
  },
  {
    language: "Nepali नेपाली",
    translations: [
      {
        short_name: "NNRV",
        full_name: "Nepali New Revised Version, 2012",
        updated: 1722188869687,
      },
      {
        short_name: "NEPS",
        full_name: "सरल नेपाली पवित्र बाइबल",
        updated: 1722188869687,
      },
    ],
  },
  {
    language: "Indonesian",
    translations: [
      {
        short_name: "TB",
        full_name: "Terjemahan Baru",
        info: "http://id.wikipedia.org/wiki/Terjemahan_Baru",
        updated: 1626349711821,
      },
    ],
  },
  {
    language: "Japanese 日本語",
    translations: [
      {
        short_name: "NJB",
        full_name: "新改訳聖書 第三版, New Japanese Bible - Shinkai-yaku, 2003",
        info: "http://en.wikipedia.org/wiki/Bible_translations_into_Japanese#New_Japanese_Bible,_1965,_1970,_1978,_2003,_2017",
        updated: 1626349711821,
      },
    ],
  },
  {
    language: "Latin / Italian",
    translations: [
      {
        short_name: "VULG",
        full_name: "Biblia Sacra juxta Vulgatam Clementinam",
        info: "http://en.wikipedia.org/wiki/Vulgate",
        updated: 1591185595149,
      },
      {
        short_name: "NR06",
        full_name: "Nuova Riveduta, 2006",
        updated: 1591185595149,
      },
    ],
  },
  {
    language: "Netherlands Nederland",
    translations: [
      {
        short_name: "NLD",
        full_name: "De Heilige Schrift, Petrus Canisiusvertaling, 1939",
        info: "http://nl.wikipedia.org/wiki/Petrus_Canisiusvertaling",
        updated: 1591292348391,
      },
    ],
  },
  {
    language: "Norwegian Norsk",
    translations: [
      {
        short_name: "DNB",
        full_name: "Det Norsk Bibelselskap (1930)",
        info: "http://nn.wikipedia.org/wiki/Det_Norske_Bibelselskap",
        updated: 1591292348391,
      },
    ],
  },
  {
    language: "Portuguese",
    translations: [
      {
        short_name: "ARA",
        full_name: "Almeida Revista e Atualizada, 1993",
        info: "http://pt.wikipedia.org/wiki/Almeida_Revista_e_Atualizada",
        updated: 1591185595149,
      },
      {
        short_name: "NTJud",
        full_name: "Novo Testamento Judaico",
        updated: 1591781197652,
      },
      {
        short_name: "OL",
        full_name: "O Livro",
        updated: 1636583761597,
      },
      {
        short_name: "NVIPT",
        full_name: "Nova Versão Internacional",
        info: "http://pt.wikipedia.org/wiki/Nova_Vers%C3%A3o_Internacional",
        updated: 1626349711821,
      },
      {
        short_name: "NVT",
        full_name: "Bíblia Sagrada, Nova Versão Transformadora, 2016",
        info: "http://pt.wikipedia.org/wiki/Nova_Vers%C3%A3o_Transformadora",
        updated: 1636583761597,
      },
      {
        short_name: "NTLH",
        full_name: "Nova Tradução na Linguagem de Hoje, 2000",
        info: "http://pt.wikipedia.org/wiki/Nova_Tradu%C3%A7%C3%A3o_na_Linguagem_de_Hoje",
        updated: 1626349711821,
      },
      {
        short_name: "KJA",
        full_name: "Bíblia King James Atualizada, 2001",
        info: "http://pt.wikipedia.org/wiki/B%C3%ADblia_do_Rei_Jaime#Vers%C3%B5es_em_portugu%C3%AAs",
        updated: 1722972452187,
      },
      {
        short_name: "VFL",
        full_name: "Bíblia Sagrada: Versão Fácil de Ler",
        updated: 1688657206480,
      },
      {
        short_name: "NAA",
        full_name: "Nova Almeida Atualizada 2017",
        updated: 1722193929648,
      },
    ],
  },
  {
    language: "Polska Polish",
    translations: [
      {
        short_name: "BG",
        full_name: "Biblia gdańska, 1881",
        info: "http://pl.wikipedia.org/wiki/Biblia_gda%C5%84ska",
        updated: 1591185595149,
      },
      {
        short_name: "BW",
        full_name: "Biblia warszawska, 1975",
        info: "http://pl.wikipedia.org/wiki/Biblia_warszawska",
        updated: 1591185595149,
      },
    ],
  },
  {
    language: "Russian Русский",
    translations: [
      {
        short_name: "JNT",
        full_name:
          "Еврейский Новый Завет в переводе и комментариях Давида Стерна",
        updated: 1635446313426,
      },
      {
        short_name: "NRT",
        full_name: "Новый Русский Перевод (НРП)",
        info: "http://ru.wikipedia.org/w/index.php?title=%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B5_%D0%BF%D0%B5%D1%80%D0%B5%D0%B2%D0%BE%D0%B4%D1%8B_%D0%91%D0%B8%D0%B1%D0%BB%D0%B8%D0%B8&stable=0#%D0%9D%D0%BE%D0%B2%D1%8B%D0%B9_%D1%80%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9_%D0%BF%D0%B5%D1%80%D0%B5%D0%B2%D0%BE%D0%B4",
        updated: 1635446313426,
      },
      {
        short_name: "SYNOD",
        full_name: "Русский Синодальный Перевод",
        info: "http://ru.wikipedia.org/wiki/%D0%A1%D0%B8%D0%BD%D0%BE%D0%B4%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9_%D0%BF%D0%B5%D1%80%D0%B5%D0%B2%D0%BE%D0%B4",
        updated: 1591185595149,
      },
      {
        short_name: "TNHR",
        full_name: "ТаНаХ на русском языке в переводе Давида Йосифона, 1975",
        info: "http://esxatos.com/tanah-perevod-davida-yosifona-tora-proroki-ketuvim",
        updated: 1635446313426,
      },
      {
        short_name: "RBS2",
        full_name: "Современный русский перевод, 2015",
        info: "http://ru.wikipedia.org/wiki/%D0%9F%D0%B5%D1%80%D0%B5%D0%B2%D0%BE%D0%B4_%D0%91%D0%B8%D0%B1%D0%BB%D0%B8%D0%B8_(%D0%A0%D0%BE%D1%81%D1%81%D0%B8%D0%B9%D1%81%D0%BA%D0%BE%D0%B5_%D0%B1%D0%B8%D0%B1%D0%BB%D0%B5%D0%B9%D1%81%D0%BA%D0%BE%D0%B5_%D0%BE%D0%B1%D1%89%D0%B5%D1%81%D1%82%D0%B2%D0%BE)",
        updated: 1635446313426,
      },
      {
        short_name: "BTI",
        full_name: "Библия под ред. М.П. Кулакова и М.М. Кулакова, 2015",
        info: "http://ru.wikipedia.org/wiki/%D0%9A%D1%83%D0%BB%D0%B0%D0%BA%D0%BE%D0%B2,_%D0%9C%D0%B8%D1%85%D0%B0%D0%B8%D0%BB_%D0%9F%D0%B5%D1%82%D1%80%D0%BE%D0%B2%D0%B8%D1%87",
        updated: 1635446313426,
      },
    ],
  },
  {
    language: "Spanish Español",
    translations: [
      {
        short_name: "BTX3",
        full_name: "La Biblia Textual 3ra Edicion",
        info: "http://www.labiblia.org/paginas/btx",
        updated: 1635446313426,
      },
      {
        short_name: "RV1960",
        full_name: "Reina-Valera 1960",
        info: "http://wikipedia.org/wiki/Reina-Valera",
        updated: 1635446313426,
      },
      {
        short_name: "RV2004",
        full_name: "Reina Valera Gómez 2004",
        info: "http://wikipedia.org/wiki/Reina-Valera",
        updated: 1591185595149,
      },
      {
        short_name: "PDT",
        full_name: "Palabra de Dios para Todos",
        info: "http://medium.com/libros-para-cristianos-inquietos/la-palabra-de-dios-para-todos-26f0f951b328",
        updated: 1635446313426,
      },
      {
        short_name: "NVI",
        full_name: "Nueva Versión Internacional",
        info: "http://es.wikipedia.org/wiki/Nueva_Versi%C3%B3n_Internacional",
        updated: 1591185595149,
      },
      {
        short_name: "NTV",
        full_name: "Nueva Traducción Viviente, 2009",
        info: "http://es.wikipedia.org/wiki/Nueva_Traducci%C3%B3n_Viviente",
        updated: 1635446313426,
      },
      {
        short_name: "LBLA",
        full_name: "La Biblia de las Américas, 1997",
        info: "http://www.lockman.org/lbla/la-biblia-de-las-americas-biblia-de-estudio-lbla",
        updated: 1635446313426,
      },
    ],
  },
  {
    language: "Swahili Kiswahili",
    translations: [
      {
        short_name: "SUV",
        full_name: "Swahili Union Version, 1997",
        updated: 1700953875512,
      },
    ],
  },
  {
    language: "Tamil தமிழ்",
    translations: [
      {
        short_name: "TBSI",
        full_name: "Tamil Older Version Bible",
        info: "http://en.wikipedia.org/wiki/Bible_translations_into_Tamil",
        updated: 1626349711821,
      },
    ],
  },
  {
    language: "Vietnamese Tiếng Việt",
    translations: [
      {
        short_name: "VI1934",
        full_name: "Kinh Thánh (1934)",
        info: "http://en.wikipedia.org/wiki/Bible_translations_into_Vietnamese",
        updated: 1709478998974,
      },
    ],
  },
];

// I need it in format <li>{short_name}, {full_name}</li>
const translationsList = languages.map((language) => {
  return language.translations.map((translation) => {
    return `<li>${translation.short_name}, ${translation.full_name}</li>`;
  }).join('\n');
}).join('\n')

console.log(translationsList);