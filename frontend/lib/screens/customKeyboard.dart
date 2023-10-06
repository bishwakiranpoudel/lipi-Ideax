import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';

class TextKey extends StatelessWidget {
  const TextKey({
    Key? key,
    required this.customFont,
    required this.text,
    required this.onTextInput,
    this.flex = 1,
    this.isCapital = false,
  }) : super(key: key);

  final TextStyle? customFont;
  final String text;
  final ValueSetter<String> onTextInput;
  final int flex;
  final bool isCapital;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Material(
          color: AppColors.primaryColor,
          child: InkWell(
            onTap: () {
              onTextInput(isCapital ? text.toUpperCase() : text);
            },
            child: Container(
              height: 30,
              child: Center(
                child: Text(
                  isCapital ? text.toUpperCase() : text,
                  style: customFont,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomKeyboard extends StatefulWidget {
  final ValueSetter<dynamic> onTextInput;
  final VoidCallback onBackspace;

  CustomKeyboard({
    Key? key,
    required this.customFont,
    required this.onTextInput,
    required this.onBackspace,
  }) : super(key: key);

  final TextStyle? customFont;

  @override
  _CustomKeyboardState createState() => _CustomKeyboardState();
}

class _CustomKeyboardState extends State<CustomKeyboard> {
  bool isCapital = false;
  bool isSymbolsMode = false;

  final List<List<String>> keyboardLayout = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
    ['z', 'y', 'c', 'v', 'b', 'n', 'm'],
    ['🔼', '␣', '⌫'],
  ];

  void toggleCapitalMode() {
    setState(() {
      isCapital = !isCapital;
    });
  }

  void toggleSymbolsMode() {
    setState(() {
      isSymbolsMode = !isSymbolsMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      color: AppColors.accentColor,
      child: Column(
        children: keyboardLayout.map((row) {
          return buildRow(row);
        }).toList(),
      ),
    );
  }

  Row buildRow(List<String> rowKeys) {
    return Row(
      children: rowKeys.map((key) {
        if (key == '⌫') {
          return BackspaceKey(
            onBackspace: widget.onBackspace,
          );
        } else if (key == '🔼') {
          return TextKey(
            customFont: widget.customFont,
            text: '🔼',
            onTextInput: (text) {
              toggleCapitalMode();
            },
          );
        } else if (key == '␣') {
          return TextKey(
            customFont: widget.customFont,
            text: ' ',
            onTextInput: widget.onTextInput,
            flex: 4,
          );
        } else if (key == '#') {
          return TextKey(
            customFont: widget.customFont,
            text: '#',
            onTextInput: (text) {
              toggleSymbolsMode();
            },
          );
        } else if (key == 'ABC') {
          return TextKey(
            customFont: widget.customFont,
            text: 'ABC',
            onTextInput: (text) {
              toggleSymbolsMode();
            },
          );
        } else if (isSymbolsMode) {
          return TextKey(
            customFont: widget.customFont,
            text: key,
            onTextInput: widget.onTextInput,
          );
        } else {
          return TextKey(
            customFont: widget.customFont,
            text: key,
            onTextInput: widget.onTextInput,
            isCapital: isCapital,
          );
        }
      }).toList(),
    );
  }
}

class BackspaceKey extends StatelessWidget {
  const BackspaceKey({
    Key? key,
    required this.onBackspace,
    this.flex = 1,
  }) : super(key: key);

  final VoidCallback onBackspace;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Material(
          color: AppColors.primaryColor,
          child: InkWell(
            onTap: () {
              onBackspace.call();
            },
            child: Container(
              height: 30,
              child: Center(child: Icon(Icons.backspace)),
            ),
          ),
        ),
      ),
    );
  }
}
