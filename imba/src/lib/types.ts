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
  | "white";

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
