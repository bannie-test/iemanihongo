import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons_600.dart';

/// One place for the app's icon set: Lucide's rounded outline icons, with
/// the heavier 600 weight for selected/emphasised states. Lucide has no
/// filled glyphs, so "on" states that need a fill (starred, flagged) use
/// Material's rounded filled icons.
class AppIcons {
  // Navigation
  static const IconData home = LucideIcons.house;
  static const IconData homeOn = LucideIcons600.house;
  static const IconData words = LucideIcons.galleryVerticalEnd;
  static const IconData wordsOn = LucideIcons600.galleryVerticalEnd;
  static const IconData practice = LucideIcons.target;
  static const IconData practiceOn = LucideIcons600.target;
  static const IconData exam = LucideIcons.notebookPen;
  static const IconData examOn = LucideIcons600.notebookPen;
  static const IconData progress = LucideIcons.chartNoAxesCombined;
  static const IconData progressOn = LucideIcons600.chartNoAxesCombined;

  // Actions
  static const IconData settings = LucideIcons.settings;
  static const IconData speaker = LucideIcons600.volume2;
  static const IconData star = LucideIcons.star;
  static const IconData starOn = Icons.star_rounded;
  static const IconData close = LucideIcons.x;
  static const IconData back = LucideIcons.chevronLeft;
  static const IconData next = LucideIcons.chevronRight;
  static const IconData play = LucideIcons600.play;
  static const IconData playCircle = LucideIcons.circlePlay;
  static const IconData search = LucideIcons.search;
  static const IconData add = LucideIcons.plus;
  static const IconData addToList = LucideIcons.listPlus;
  static const IconData folder = LucideIcons.folder;
  static const IconData folderOpen = LucideIcons.folderOpen;
  static const IconData more = LucideIcons.ellipsisVertical;
  static const IconData sync = LucideIcons.refreshCw;
  static const IconData signOut = LucideIcons.logOut;
  static const IconData account = LucideIcons.circleUser;
  static const IconData guest = LucideIcons.user;
  static const IconData cloudUpload = LucideIcons.cloudUpload;
  static const IconData mail = LucideIcons.mail;
  static const IconData lock = LucideIcons.lock;
  static const IconData eye = LucideIcons.eye;
  static const IconData eyeOff = LucideIcons.eyeOff;
  static const IconData clock = LucideIcons.clock;
  static const IconData timer = LucideIcons.timer;
  static const IconData flag = LucideIcons.flag;
  static const IconData flagOn = Icons.flag_rounded;
  static const IconData grid = LucideIcons.layoutGrid;
  static const IconData check = LucideIcons600.check;
  static const IconData cross = LucideIcons600.x;
  static const IconData checkCircle = LucideIcons600.circleCheck;
  static const IconData circle = LucideIcons.circle;
  static const IconData undo = LucideIcons.undo2;
  static const IconData eraser = LucideIcons.eraser;
  static const IconData pen = LucideIcons.pencilLine;
  static const IconData trash = LucideIcons.trash2;
  static const IconData retry = LucideIcons.rotateCw;
  static const IconData shuffle = LucideIcons.shuffle;

  // Content
  static const IconData grammar = LucideIcons.bookOpenText;
  static const IconData quiz = LucideIcons.zap;
  static const IconData writing = LucideIcons.penLine;
  static const IconData trophy = LucideIcons.trophy;
  static const IconData fire = LucideIcons.flame;
  static const IconData freeze = LucideIcons.snowflake;
  static const IconData voice = LucideIcons.audioWaveform;
  static const IconData warning = LucideIcons.circleAlert;
  static const IconData bulb = LucideIcons.lightbulb;
  static const IconData target = LucideIcons.crosshair;
  static const IconData translate = LucideIcons.languages;
  static const IconData history = LucideIcons.history;
  static const IconData chart = LucideIcons.chartColumn;
  static const IconData notFound = LucideIcons.searchX;
  static const IconData schedule = LucideIcons.alarmClock;
  static const IconData light = LucideIcons.sun;
  static const IconData dark = LucideIcons.moon;
  static const IconData system = LucideIcons.sunMoon;
}
