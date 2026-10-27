/// Romaji for kana, shown in writing practice.
library;

const _hira = 'あいうえおかきくけこがぎぐげごさしすせそざじずぜぞたちつてとだぢづでどなにぬねのはひふへほばびぶべぼぱぴぷぺぽまみむめもやゆよらりるれろわをんぁぃぅぇぉっゃゅょゎゐゑゔ';
const _roma = [
  'a', 'i', 'u', 'e', 'o', 'ka', 'ki', 'ku', 'ke', 'ko', 'ga', 'gi', 'gu', 'ge', 'go', //
  'sa', 'shi', 'su', 'se', 'so', 'za', 'ji', 'zu', 'ze', 'zo', 'ta', 'chi', 'tsu', 'te', 'to',
  'da', 'ji (ぢ)', 'zu (づ)', 'de', 'do', 'na', 'ni', 'nu', 'ne', 'no', 'ha', 'hi', 'fu', 'he', 'ho',
  'ba', 'bi', 'bu', 'be', 'bo', 'pa', 'pi', 'pu', 'pe', 'po', 'ma', 'mi', 'mu', 'me', 'mo',
  'ya', 'yu', 'yo', 'ra', 'ri', 'ru', 're', 'ro', 'wa', 'wo', 'n',
  'small a', 'small i', 'small u', 'small e', 'small o', 'small tsu', 'small ya', 'small yu', 'small yo', 'small wa',
  'wi (old)', 'we (old)', 'vu',
];

/// Basic kana first, then voiced, then small and rare ones.
const hiraganaOrder = 'あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽぁぃぅぇぉっゃゅょゎゐゑゔ';

String toKatakana(String hira) =>
    String.fromCharCodes(hira.runes.map((r) => r >= 0x3041 && r <= 0x3096 ? r + 0x60 : r));

String toHiragana(String kata) =>
    String.fromCharCodes(kata.runes.map((r) => r >= 0x30A1 && r <= 0x30F6 ? r - 0x60 : r));

String? romajiOf(String kana) {
  final i = _hira.indexOf(toHiragana(kana));
  return i < 0 || i >= _roma.length ? null : _roma[i];
}

bool isKana(String ch) {
  final c = ch.runes.first;
  return (c >= 0x3041 && c <= 0x3096) || (c >= 0x30A1 && c <= 0x30FA);
}
