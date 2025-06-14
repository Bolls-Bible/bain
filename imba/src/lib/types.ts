export type Verse = {
  pk: number;
  verse: number;
  text: string;
  translation?: string;
  chapter?: number;
  book?: number;
  comment?: string;
};

export type colorTheme =
  | "dark"
  | "light"
  | "black"
  | "gray"
  | "sepia"
  | "white"
  | "custom";

export type Accents = "blue" | "green" | "purple" | "gold" | "red";
export type Accent = {
  name: Accents;
  light: string;
  dark: string;
};

export type Notification = {
  id: string;
  message: string;
  className?: string;
};

export type CopyObject = {
  title: string;
  text: string;
  translation: string;
  book: number;
  chapter: number;
  verses: number[];
};

export type Translation = {
  full_name: string;
  short_name: string;
  updated: number;
  dir?: string; // "rtl" | "ltr";
};

export type HighlightRectangular = {
  top: number;
  left: number;
  height: number;
  width: number;
  class: string;
  matchID: string;
};

export type HistoryEntry = {
  book: number;
  chapter: number;
  verse: number | string;
  translation: string;
  date: number;
};

export type Bookmark = {
  verse: number; // actually pk of the verse
  date: number; // milliseconds since 1970
  color: string;
  collection: string;
  note: string;
};

export type ProfileBookmark = {
  date: number;
  color: string;
  collection: string;
  note: string;
  verse: Verse;
};

export interface BeforeInstallPromptEvent extends Event {
  readonly platforms: string[];
  readonly userChoice: Promise<{
    outcome: "accepted" | "dismissed";
    platform: string;
  }>;
  prompt(): Promise<void>;
}

export type Definition = {
  topic: string;
  definition: string;
  lexeme: string;
  transliteration: string;
  pronunciation: string;
  weight: number;
  short_definition: string
};
