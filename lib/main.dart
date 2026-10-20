import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'الآلة الحاسبة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF58A6FF),
          surface: Color(0xFF161B22),
        ),
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String _expression = '';
  double? _firstOperand;
  String? _operator;
  bool _startNewNumber = true;
  bool _hasError = false;

  static const Color _numberColor = Color(0xFF21262D);
  static const Color _functionColor = Color(0xFF30363D);
  static const Color _operatorColor = Color(0xFF1F6FEB);
  static const Color _equalsColor = Color(0xFF238636);

  void _press(String value) {
    setState(() {
      if (_hasError) {
        _display = '0';
        _expression = '';
        _firstOperand = null;
        _operator = null;
        _startNewNumber = true;
        _hasError = false;
      }

      if (value == 'AC') {
        _clear();
      } else if (value == '⌫') {
        _backspace();
      } else if (value == '±') {
        _toggleSign();
      } else if (value == '%') {
        _percent();
      } else if (value == '.') {
        _decimal();
      } else if (_isOperator(value)) {
        _setOperator(value);
      } else if (value == '=') {
        _calculate();
      } else {
        _inputDigit(value);
      }
    });
  }

  bool _isOperator(String value) =>
      value == '+' || value == '−' || value == '×' || value == '÷';

  void _clear() {
    _display = '0';
    _expression = '';
    _firstOperand = null;
    _operator = null;
    _startNewNumber = true;
    _hasError = false;
  }

  void _inputDigit(String digit) {
    if (_startNewNumber || _display == '0') {
      _display = digit;
      _startNewNumber = false;
    } else if (_display.length < 15) {
      _display += digit;
    }
  }

  void _decimal() {
    if (_startNewNumber) {
      _display = '0.';
      _startNewNumber = false;
    } else if (!_display.contains('.')) {
      _display += '.';
    }
  }

  void _setOperator(String op) {
    final current = double.tryParse(_display);
    if (current == null) return;

    if (_firstOperand != null && _operator != null && !_startNewNumber) {
      _calculate();
      if (_hasError) return;
    }

    _firstOperand = double.tryParse(_display);
    _operator = op;
    _expression = '${_formatNumber(_firstOperand!)} $op';
    _startNewNumber = true;
  }

  void _calculate() {
    if (_firstOperand == null || _operator == null || _startNewNumber) {
      return;
    }

    final secondOperand = double.tryParse(_display);
    if (secondOperand == null) return;

    double result;
    switch (_operator) {
      case '+':
        result = _firstOperand! + secondOperand;
        break;
      case '−':
        result = _firstOperand! - secondOperand;
        break;
      case '×':
        result = _firstOperand! * secondOperand;
        break;
      case '÷':
        if (secondOperand == 0) {
          _display = 'خطأ';
          _expression = 'لا يمكن القسمة على صفر';
          _firstOperand = null;
          _operator = null;
          _startNewNumber = true;
          _hasError = true;
          return;
        }
        result = _firstOperand! / secondOperand;
        break;
      default:
        return;
    }

    if (!result.isFinite) {
      _display = 'خطأ';
      _expression = 'النتيجة غير صالحة';
      _firstOperand = null;
      _operator = null;
      _startNewNumber = true;
      _hasError = true;
      return;
    }

    _expression =
        '${_formatNumber(_firstOperand!)} $_operator ${_formatNumber(secondOperand)} =';
    _display = _formatNumber(result);
    _firstOperand = null;
    _operator = null;
    _startNewNumber = true;
  }

  void _backspace() {
    if (_startNewNumber || _hasError) {
      _display = '0';
      _startNewNumber = true;
      _hasError = false;
      return;
    }
    if (_display.length <= 1 ||
        (_display.length == 2 && _display.startsWith('-'))) {
      _display = '0';
      _startNewNumber = true;
    } else {
      _display = _display.substring(0, _display.length - 1);
    }
  }

  void _toggleSign() {
    if (_display == '0' || _display == 'خطأ') return;
    _display = _display.startsWith('-')
        ? _display.substring(1)
        : '-$_display';
    _startNewNumber = false;
  }

  void _percent() {
    final value = double.tryParse(_display);
    if (value == null) return;
    _display = _formatNumber(value / 100);
    _startNewNumber = true;
  }

  String _formatNumber(double value) {
    if (value == 0) return '0';
    if (value.abs() >= 1e15 || value.abs() < 1e-9) {
      return value.toStringAsExponential(6);
    }
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsPrecision(12).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  Widget _buildButton(
    String label, {
    Color? color,
    Color? textColor,
    int flex = 1,
    double fontSize = 23,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Material(
          color: color ?? _numberColor,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _press(label),
            child: SizedBox(
              height: 68,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<Widget> buttons) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: buttons,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الآلة الحاسبة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D1117),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _expression,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          _display,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            color: _hasError
                                ? const Color(0xFFFF7B72)
                                : Colors.white,
                            fontSize: 58,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Expanded(
                      child: _buildRow([
                        _buildButton('AC',
                            color: const Color(0xFF8B3038), fontSize: 20),
                        _buildButton('±', color: _functionColor),
                        _buildButton('%', color: _functionColor),
                        _buildButton('÷', color: _operatorColor, fontSize: 28),
                      ]),
                    ),
                    Expanded(
                      child: _buildRow([
                        _buildButton('7'),
                        _buildButton('8'),
                        _buildButton('9'),
                        _buildButton('×',
                            color: _operatorColor, fontSize: 28),
                      ]),
                    ),
                    Expanded(
                      child: _buildRow([
                        _buildButton('4'),
                        _buildButton('5'),
                        _buildButton('6'),
                        _buildButton('−',
                            color: _operatorColor, fontSize: 28),
                      ]),
                    ),
                    Expanded(
                      child: _buildRow([
                        _buildButton('1'),
                        _buildButton('2'),
                        _buildButton('3'),
                        _buildButton('+',
                            color: _operatorColor, fontSize: 28),
                      ]),
                    ),
                    Expanded(
                      child: _buildRow([
                        _buildButton('⌫', color: _functionColor),
                        _buildButton('0', flex: 2),
                        _buildButton('.'),
                        _buildButton('=', color: _equalsColor, fontSize: 28),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}