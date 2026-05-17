String stripHtmlTags(String? input) {
  if (input == null) return '';
  return input.replaceAll(RegExp(r'<[^>]*>'), '').trim();
}
