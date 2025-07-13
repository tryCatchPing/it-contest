enum ToolMode {
  pen('Pen', [1, 3, 5, 7]),
  eraser('Eraser', [3, 5, 7]),
  highlighter('Highlighter', [10, 20, 30]),
  linker('Linker', [10, 20, 30]);

  const ToolMode(this.displayName, this.widths);

  final String displayName;
  final List<double> widths;
}
