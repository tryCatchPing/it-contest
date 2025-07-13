enum ToolMode {
  pen('Pen'),
  eraser('Eraser'),
  highlighter('Highlighter'),
  linker('Linker');

  const ToolMode(this.displayName);

  final String displayName;
}
