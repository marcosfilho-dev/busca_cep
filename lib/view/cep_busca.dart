import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CepSearchScreen extends StatefulWidget {
  const CepSearchScreen({super.key});

  @override
  State<CepSearchScreen> createState() => _CepSearchScreenState();
}

class _CepSearchScreenState extends State<CepSearchScreen> {
  final TextEditingController _cepController = TextEditingController();
  
  String _result = 'Nenhum CEP buscado ainda.';
  bool _isLoading = false;

  // Função para buscar CEP por número
  Future<void> _searchCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'\D'), ''); // Remove non-digits
    if (cep.isEmpty || cep.length != 8) {
      _showMessage('Por favor, insira um CEP válido de 8 dígitos.');
      return;
    }

    setState(() {
      _isLoading = true;
      _result = 'Buscando CEP...';
    });

    try {
      final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('erro')) {
          _result = 'CEP não encontrado.';
        } else {
          _result = _formatCepResult(data);
        }
      } else {
        _result = 'Erro ao buscar CEP: ${response.statusCode}';
      }
    } catch (e) {
      _result = 'Erro de conexão: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  
  // Formata o resultado do CEP para exibição
  String _formatCepResult(Map<String, dynamic> data) {
    return 'CEP: ${data['cep'] ?? 'N/A'}\n'
        'Logradouro: ${data['logradouro'] ?? 'N/A'}\n'
        'Complemento: ${data['complemento'] ?? 'N/A'}\n'
        'Bairro: ${data['bairro'] ?? 'N/A'}\n'
        'Localidade: ${data['localidade'] ?? 'N/A'}\n'
        'UF: ${data['uf'] ?? 'N/A'}';
  }

  // Exibe uma mensagem em um AlertDialog
  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Atenção'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Busca de CEP', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrangeAccent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Busca por CEP
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Buscar por CEP',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _cepController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Digite o CEP (somente números)',
                        hintText: 'Ex: 01001000',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _searchCep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent, // Cor de fundo
                        foregroundColor: Colors.white, // Cor do texto
                        minimumSize: const Size(200, 40), 
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5, // Sombra
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Buscar CEP'),
                    ),
                  ],
                ),
              ),
            ),

            // Busca por Cidade/Estado
            

            // Área de Resultados
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resultados:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      width: double.infinity,
                      child: SelectableText(
                        _result,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
