import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  _CurrencyConverterState createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final TextEditingController _amountController = TextEditingController();
  String _baseCurrency = 'USD';
  String _targetCurrency = 'EUR';
  double? _conversionResult;
  Map<String, dynamic>? _exchangeRates;

  Future<void> fetchExchangeRates() async {
    final url =
        "https://v6.exchangerate-api.com/v6/fcdf87381720a471b4127745/latest/$_baseCurrency";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        _exchangeRates = json.decode(response.body)['conversion_rates'];
      });
    } else {
      throw Exception("Failed to load exchange rates");
    }
  }

  void _convertCurrency() {
    if (_exchangeRates == null) return;

    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    final double rate = _exchangeRates![_targetCurrency];

    setState(() {
      _conversionResult = amount * rate;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchExchangeRates();
  }

  String _getFlagUrl(String currencyCode) {
    return "https://flagcdn.com/w40/${currencyCode.substring(0, 2).toLowerCase()}.png";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _baseCurrency,
                    onChanged: (value) {
                      setState(() {
                        _baseCurrency = value!;
                        fetchExchangeRates();
                      });
                    },
                    items: _exchangeRates?.keys.map((String currency) {
                          return DropdownMenuItem(
                            value: currency,
                            child: Row(
                              children: [
                                Image.network(
                                  _getFlagUrl(currency),
                                  width: 30,
                                  height: 20,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.flag),
                                ),
                                const SizedBox(width: 10),
                                Text(currency),
                              ],
                            ),
                          );
                        }).toList() ??
                        [],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _targetCurrency,
                    onChanged: (value) {
                      setState(() {
                        _targetCurrency = value!;
                      });
                    },
                    items: _exchangeRates?.keys.map((String currency) {
                          return DropdownMenuItem(
                            value: currency,
                            child: Row(
                              children: [
                                Image.network(
                                  _getFlagUrl(currency),
                                  width: 30,
                                  height: 20,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.flag),
                                ),
                                const SizedBox(width: 10),
                                Text(currency),
                              ],
                            ),
                          );
                        }).toList() ??
                        [],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _convertCurrency,
              child: const Text('Convert'),
            ),
            const SizedBox(height: 16),
            if (_conversionResult != null)
              Text(
                'Converted Amount: $_conversionResult $_targetCurrency',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
