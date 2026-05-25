import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const TerlineTGovernanceApp());
}

class TerlineTGovernanceApp extends StatelessWidget {
  const TerlineTGovernanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TerlineT Governance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const CyberpunkHomePage(),
    );
  }
}

class CyberpunkHomePage extends StatefulWidget {
  const CyberpunkHomePage({super.key});

  @override
  State<CyberpunkHomePage> createState() => _CyberpunkHomePageState();
}

class _CyberpunkHomePageState extends State<CyberpunkHomePage> {
  late VideoPlayerController _controller;
  Offset _mousePosition = Offset.zero;
  bool _isLoading = false;
  String? _aiResponse;
  bool _showDiagnosticForm = false;
  bool _showMaturityForm = false;
  bool _showManualSelection = false; // Novo controle
  bool _showRobotProtocol = false; // Novo controle
  bool _showChatBubble = false; // Controle para o chat da IA
  String? _maturityResult;
  String? _recommendedFramework;

  // Controllers para o primeiro formulário
  final TextEditingController _porteController = TextEditingController();
  final TextEditingController _ramoController = TextEditingController();
  final TextEditingController _techsController = TextEditingController();
  final TextEditingController _chatController = TextEditingController(); // Controller para o chat

  // Opções para o formulário de maturidade
  String _docLevel = 'Nenhum';
  String _kpiLevel = 'Não';
  String _committee = 'Não';
  String _execSupport = 'Baixo';
  String _automation = 'Manual';

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/background.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _porteController.dispose();
    _ramoController.dispose();
    _techsController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _analyzeGovernance() async {
    setState(() {
      _isLoading = true;
      _aiResponse = null;
    });

    final prompt = """
    Aja como o MasterGovernance da TerlineT AI.
    Analise os seguintes dados de uma empresa e recomende o melhor framework (COBIT, ITIL, ISO 27001, etc):
    - Porte: ${_porteController.text}
    - Ramo: ${_ramoController.text}
    - Tecnologias Existentes: ${_techsController.text}

    IMPORTANTE: Sua resposta DEVE começar com a tag [FRAMEWORK: Nome do Framework] e depois seguir com a justificativa técnica e os primeiros passos.
    """;

    try {
      final response = await http.post(
        Uri.parse('https://tertulianoshow-terlinet-governance.hf.space/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': prompt,
          'is_agent': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['text'];

        // Extrair o framework recomendado
        final regExp = RegExp(r'\[FRAMEWORK:\s*(.*?)\]');
        final match = regExp.firstMatch(text);
        if (match != null) {
          _recommendedFramework = match.group(1);
        }

        setState(() {
          _aiResponse = text;
        });
      } else {
        setState(() {
          _aiResponse = "Erro na conexão com o sistema central. Status: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _aiResponse = "Falha crítica na Matrix: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _assessMaturity() async {
    setState(() {
      _isLoading = true;
      _maturityResult = null;
    });

    final prompt = """
    Aja como o MasterGovernance da TerlineT AI.
    A empresa escolheu o framework: $_recommendedFramework.
    Agora, analise o nível de maturidade (CMMI 0-5) com base nestes parâmetros:
    - Documentação de Processos: $_docLevel
    - Uso de KPIs/Métricas: $_kpiLevel
    - Comitê de Governança Formal: $_committee
    - Suporte Executivo/Orçamento: $_execSupport
    - Nível de Automação: $_automation

    Forneça o Nível de Maturidade (0 a 5) e um plano de ação imediato para subir de nível.
    """;

    try {
      final response = await http.post(
        Uri.parse('https://tertulianoshow-terlinet-governance.hf.space/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': prompt,
          'is_agent': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _maturityResult = data['text'];
        });
      } else {
        setState(() {
          _maturityResult = "Erro na análise de maturidade.";
        });
      }
    } catch (e) {
      setState(() {
        _maturityResult = "Erro ao conectar à IA: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateAICertificate() async {
    final pdf = pw.Document();
    final String timestamp = DateTime.now().toIso8601String().substring(0, 10);
    final String certId = "TRL-${math.Random().nextInt(999999).toString().padLeft(6, '0')}";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.cyanAccent, width: 5),
              color: PdfColors.black,
            ),
            padding: const pw.EdgeInsets.all(40),
            child: pw.Stack(
              children: [
                // Fundo decorativo estilo Matrix/Blockchain
                pw.Center(
                  child: pw.Opacity(
                    opacity: 0.1,
                    child: pw.Text('BLOCKCHAIN SYNC TERMINAL', style: pw.TextStyle(fontSize: 60, fontWeight: pw.FontWeight.bold, color: PdfColors.cyanAccent)),
                  ),
                ),
                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // Cabeçalho do Certificado
                    pw.Column(
                      children: [
                        pw.Text('CERTIFICADO DE SINCRONIZAÇÃO IA', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.cyanAccent, letterSpacing: 5)),
                        pw.SizedBox(height: 10),
                        pw.Container(height: 2, width: 400, color: PdfColors.cyanAccent),
                        pw.SizedBox(height: 10),
                        pw.Text('TERLINET GOVERNANCE ECOSYSTEM', style: pw.TextStyle(fontSize: 12, color: PdfColors.white, letterSpacing: 8)),
                      ],
                    ),

                    // Corpo do Certificado
                    pw.Column(
                      children: [
                        pw.Text('Certificamos que o protocolo de implementação para o framework', style: pw.TextStyle(fontSize: 16, color: PdfColors.white)),
                        pw.SizedBox(height: 15),
                        pw.Text(_recommendedFramework ?? 'GOVERNANCE FRAMEWORK', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.greenAccent, letterSpacing: 2)),
                        pw.SizedBox(height: 15),
                        pw.Text('foi devidamente processado e absorvido através da Interface Humana TerlineT AI.', style: pw.TextStyle(fontSize: 14, color: PdfColors.white)),
                        pw.SizedBox(height: 10),
                        pw.Text('NÍVEL DE MATURIDADE ALCANÇADO: CMMI STAGE ${_maturityResult?.contains('0') == true ? '0' : (_maturityResult?.contains('1') == true ? '1' : (_maturityResult?.contains('2') == true ? '2' : (_maturityResult?.contains('3') == true ? '3' : (_maturityResult?.contains('4') == true ? '4' : '5'))))}',
                          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.cyanAccent)),
                      ],
                    ),

                    // Rodapé com Assinatura e Dados Blockchain
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('BLOCKCHAIN HASH: ${certId}', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey, fontFamily: pw.FontWeight.bold.family)),
                            pw.Text('TIMESTAMP: $timestamp', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                            pw.SizedBox(height: 10),
                            pw.Text('VALIDAÇÃO SINTÉTICA COMPLETA', style: pw.TextStyle(fontSize: 10, color: PdfColors.greenAccent)),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text('TerlineT', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.cyanAccent, fontStyle: pw.FontStyle.italic)),
                            pw.Container(height: 1, width: 150, color: PdfColors.white),
                            pw.SizedBox(height: 5),
                            pw.Text('MASTER GOVERNANCE AI', style: pw.TextStyle(fontSize: 10, color: PdfColors.white)),
                            pw.SizedBox(height: 5),
                            pw.Text('O futuro é seu!', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.greenAccent)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _printImplementationPlan() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, text: 'TerlineT Governance - Plano de Implementacao'),
              pw.SizedBox(height: 20),
              pw.Text('Framework Recomendado: $_recommendedFramework'),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text('Relatorio Detalhado:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text(_maturityResult ?? 'Nenhum resultado disponivel.'),
              pw.SizedBox(height: 20),
              pw.Footer(
                trailing: pw.Text('Gerado por TerlineT AI - MasterGovernance'),
              )
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  void _onMouseMove(PointerEvent details) {
    setState(() {
      _mousePosition = details.position;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double rotateX = (_mousePosition.dy - size.height / 2) / (size.height / 2) * 0.5;
    double rotateY = (_mousePosition.dx - size.width / 2) / (size.width / 2) * -0.5;

    return Scaffold(
      backgroundColor: Colors.black,
      body: MouseRegion(
        onHover: _onMouseMove,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Background
            _controller.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),

            Container(color: Colors.black.withOpacity(0.7)),

            Positioned(top: 0, left: 0, right: 0, child: _buildTopGovernanceBar(context)),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 100, bottom: 40),
                child: Column(
                  children: [
                    Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002)
                        ..rotateX(rotateX)
                        ..rotateY(rotateY),
                      alignment: FractionalOffset.center,
                      child: const CyberpunkCube(text: 'MASTER GOVERNANCE'),
                    ),
                    const SizedBox(height: 40),

                    // Lógica de troca de conteúdo central
                    if (!_showDiagnosticForm && !_showMaturityForm && !_showManualSelection && !_showRobotProtocol && _aiResponse == null) ...[
                      _buildMissionStatement(context),
                      const SizedBox(height: 30),
                      _buildActionButtons(context),
                    ] else if (_showRobotProtocol) ...[
                      _buildRobotProtocolView(),
                    ] else if (_showManualSelection) ...[
                      _buildManualSelectionForm(),
                    ] else if (_showDiagnosticForm && !_showMaturityForm && _aiResponse == null) ...[
                      _buildDiagnosticForm(),
                    ] else if (_aiResponse != null && !_showMaturityForm) ...[
                      _buildAIResultArea(),
                    ] else if (_showMaturityForm && _maturityResult == null) ...[
                      _buildMaturityForm(),
                    ] else if (_maturityResult != null) ...[
                      _buildMaturityResultArea(),
                    ],
                  ],
                ),
              ),
            ),

            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.cyanAccent),
                      SizedBox(height: 20),
                      Text("TERLINET AI PROCESSANDO...", style: TextStyle(color: Colors.cyanAccent, letterSpacing: 2)),
                    ],
                  ),
                ),
              ),

            // Bolha de Chat no canto inferior direito
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildChatBubble(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_showChatBubble)
          Container(
            width: 350,
            height: 450,
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.95),
              border: Border.all(color: Colors.cyanAccent, width: 2),
              boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.2), blurRadius: 20)],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.cyanAccent.withOpacity(0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("TERLINET EXPLAINER", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close, color: Colors.cyanAccent, size: 18),
                        onPressed: () => setState(() => _showChatBubble = false),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _aiResponse ?? "Olá! Eu sou a TerlineT. Como posso te ajudar com a implementação de COBIT, ITIL, ISO ou outros frameworks de governança?",
                      style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'monospace'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: "Sua dúvida...",
                            hintStyle: const TextStyle(color: Colors.white24),
                            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                          ),
                          onSubmitted: (val) => _askAI(val),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.cyanAccent),
                        onPressed: () => _askAI(_chatController.text),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        GestureDetector(
          onTap: () => setState(() => _showChatBubble = !_showChatBubble),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              border: Border.all(color: Colors.cyanAccent, width: 1.5),
              boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 10)],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hub_outlined, color: Colors.cyanAccent, size: 20),
                const SizedBox(width: 10),
                const Text(
                  "TERLINET ADVISORY: ACESSE O PROTOCOLO DE CONHECIMENTO IA",
                  style: TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _askAI(String query) async {
    if (query.isEmpty) return;
    _chatController.clear();

    setState(() {
      _isLoading = true;
      _aiResponse = "Processando requisição de conhecimento...";
    });

    final prompt = """
    Aja como o MasterGovernance da TerlineT AI.
    Responda a seguinte dúvida sobre implementação de frameworks de Governança de TI (COBIT, ITIL, ISO, NIST, etc):
    Dúvida: $query

    Seja técnico, didático e cite as melhores práticas.
    """;

    try {
      final response = await http.post(
        Uri.parse('https://tertulianoshow-terlinet-governance.hf.space/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': prompt,
          'is_agent': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _aiResponse = data['text'];
        });
      }
    } catch (e) {
      setState(() => _aiResponse = "Erro na conexão: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildMissionStatement(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(
            'APRENDA COMO APLICAR OS MELHORES FRAMEWORKS DE GOVERNANÇA UTILIZANDO IA',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 16 : 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
              color: Colors.greenAccent.withOpacity(0.05),
            ),
            child: Text(
              'Sincronização Evolutiva: Implementação autônoma de COBIT & ITIL 4 via TerlineT AI.\nOtimização de valor para arquiteturas humanas e protocolos sintéticos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: isMobile ? 10 : 12,
                fontFamily: 'monospace',
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            _buildCyberButton(
              label: 'INTERFACE HUMANA',
              icon: Icons.person_search,
              color: Colors.cyanAccent,
              onTap: () => setState(() => _showDiagnosticForm = true),
            ),
            _buildCyberButton(
              label: 'PROTOCOLO DE MÁQUINA',
              icon: Icons.memory,
              color: Colors.greenAccent,
              onTap: () => setState(() => _showRobotProtocol = true),
            ),
          ],
        ),
        const SizedBox(height: 30),
        // Terceira opção: Seleção Manual (Melhores práticas: Menor destaque, mas acessível)
        InkWell(
          onTap: () => setState(() => _showManualSelection = true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              color: Colors.white.withOpacity(0.05),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings_applications, color: Colors.white54, size: 16),
                SizedBox(width: 10),
                Text(
                  'ESCOLHER FRAMEWORK MANUALMENTE (SYSTEM OVERRIDE)',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualSelectionForm() {
    final List<Map<String, String>> frameworks = [
      {'name': 'COBIT 2019', 'desc': 'Foco em Governança Estratégica'},
      {'name': 'ITIL 4', 'desc': 'Gestão de Serviços e Valor'},
      {'name': 'ISO/IEC 27001', 'desc': 'Segurança da Informação'},
      {'name': 'NIST CSF', 'desc': 'Cybersecurity Framework'},
      {'name': 'Balanced Scorecard', 'desc': 'Indicadores de Performance'},
    ];

    return Container(
      width: 500,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("BIBLIOTECA DE FRAMEWORKS", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
              IconButton(onPressed: () => setState(() => _showManualSelection = false), icon: const Icon(Icons.close, color: Colors.orangeAccent, size: 18))
            ],
          ),
          const Divider(color: Colors.orangeAccent),
          const SizedBox(height: 10),
          ...frameworks.map((f) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(f['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(f['desc']!, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right, color: Colors.orangeAccent),
            onTap: () {
              setState(() {
                _recommendedFramework = f['name'];
                _showManualSelection = false;
                _showMaturityForm = true;
              });
            },
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildCyberButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color, width: 2),
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticForm() {
    return Container(
      width: 500,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        border: Border.all(color: Colors.cyanAccent),
        boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.2), blurRadius: 30)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("DIAGNÓSTICO CORPORATIVO", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
              IconButton(onPressed: () => setState(() => _showDiagnosticForm = false), icon: const Icon(Icons.close, color: Colors.cyanAccent, size: 18))
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField("PORTE DA EMPRESA", _porteController),
          const SizedBox(height: 15),
          _buildTextField("RAMO DE ATUAÇÃO", _ramoController),
          const SizedBox(height: 15),
          _buildTextField("TECNOLOGIAS ATUAIS", _techsController),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _analyzeGovernance,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                side: const BorderSide(color: Colors.cyanAccent),
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: const Text("INICIAR SINCRONIZAÇÃO IA", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIResultArea() {
    return Container(
      width: 700,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        border: Border.all(color: Colors.greenAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("RELATÓRIO DE GOVERNANÇA TERLINET", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => setState(() { _aiResponse = null; _showDiagnosticForm = false; }), icon: const Icon(Icons.home, color: Colors.greenAccent))
            ],
          ),
          const Divider(color: Colors.greenAccent),
          const SizedBox(height: 10),
          Text(_aiResponse!, style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13)),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _showMaturityForm = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.withOpacity(0.2),
                side: const BorderSide(color: Colors.greenAccent),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("PROSSEGUIR PARA IMPLEMENTAÇÃO", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaturityForm() {
    return Container(
      width: 600,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        border: Border.all(color: Colors.blueAccent),
        boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 30)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ANÁLISE DE MATURIDADE (CMMI)", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 20),
          _buildDropdown("DOCUMENTAÇÃO DE PROCESSOS", _docLevel, ['Nenhum', 'Informal', 'Padronizada', 'Otimizada'], (val) => setState(() => _docLevel = val!)),
          _buildDropdown("USO DE KPIS / MÉTRICAS", _kpiLevel, ['Não', 'Algumas', 'Sistema Completo'], (val) => setState(() => _kpiLevel = val!)),
          _buildDropdown("COMITÊ DE GOVERNANÇA FORMAL", _committee, ['Não', 'Em formação', 'Sim'], (val) => setState(() => _committee = val!)),
          _buildDropdown("SUPORTE EXECUTIVO / ORÇAMENTO", _execSupport, ['Baixo', 'Moderado', 'Total'], (val) => setState(() => _execSupport = val!)),
          _buildDropdown("NÍVEL DE AUTOMAÇÃO", _automation, ['Manual', 'Híbrida', 'Totalmente Automatizada'], (val) => setState(() => _automation = val!)),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _assessMaturity,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent.withOpacity(0.2),
                side: const BorderSide(color: Colors.blueAccent),
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: const Text("ANALISAR ESTÁGIO DE MATURIDADE", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaturityResultArea() {
    return Container(
      width: 750,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("PLANO DE IMPLEMENTAÇÃO E MATURIDADE", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => setState(() { _maturityResult = null; _showMaturityForm = false; _aiResponse = null; }), icon: const Icon(Icons.home, color: Colors.blueAccent))
            ],
          ),
          const Divider(color: Colors.blueAccent),
          const SizedBox(height: 10),
          Text(_maturityResult!, style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13)),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _printImplementationPlan,
                    icon: const Icon(Icons.print, color: Colors.blueAccent),
                    label: const Text("IMPRIMIR PLANO", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent.withOpacity(0.1),
                      side: const BorderSide(color: Colors.blueAccent),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generateAICertificate,
                    icon: const Icon(Icons.verified_user, color: Colors.greenAccent),
                    label: const Text("GERAR CERTIFICADO", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.withOpacity(0.1),
                      side: const BorderSide(color: Colors.greenAccent),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: Colors.black,
            underline: Container(height: 1, color: Colors.blueAccent),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
      ),
    );
  }

  Widget _buildRobotProtocolView() {
    final List<Map<String, dynamic>> protocols = [
      {
        'id': 'COBIT_2019',
        'name': 'COBIT 2019',
        'type': 'Governance Umbrella',
        'owner': 'ISACA',
        'specs': '40 Governance/Management Objectives; 5 Domains (EDM, APO, BAI, DSS, MEA).',
        'logic': 'Alignment of IT goals with Enterprise strategy via Design Factors.',
      },
      {
        'id': 'ITIL_4',
        'name': 'ITIL 4',
        'type': 'Service Management',
        'owner': 'Axelos/PeopleCert',
        'specs': '34 Practices; Service Value System (SVS); 4 Dimensions of Service.',
        'logic': 'Value co-creation through Service Value Chain activities.',
      },
      {
        'id': 'ISO_38500',
        'name': 'ISO/IEC 38500',
        'type': 'International Standard',
        'owner': 'ISO/IEC',
        'specs': '6 Principles: Responsibility, Strategy, Acquisition, Performance, Conformance, Behavior.',
        'logic': 'Evaluate-Direct-Monitor (EDM) model for governing bodies.',
      },
      {
        'id': 'NIST_CSF_2.0',
        'name': 'NIST CSF 2.0',
        'type': 'Cybersecurity Framework',
        'owner': 'NIST (USA)',
        'specs': '6 Functions: Govern, Identify, Protect, Detect, Respond, Recover.',
        'logic': 'Risk-based approach with 22 Categories and 106 Subcategories.',
      },
      {
        'id': 'TOGAF_10',
        'name': 'TOGAF 10',
        'type': 'Enterprise Architecture',
        'owner': 'The Open Group',
        'specs': 'ADM (Architecture Development Method) 10-phase cycle.',
        'logic': 'Standardizing architecture artifacts and structural alignment.',
      },
    ];

    return Container(
      width: 800,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.95),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.1), blurRadius: 40)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("PROTOCOLO SINTÉTICO V3.0", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, letterSpacing: 3)),
                  Text("ESTRUTURA DE DADOS PARA AGENTES AUTÔNOMOS", style: TextStyle(color: Colors.greenAccent, fontSize: 10, letterSpacing: 1)),
                ],
              ),
              IconButton(onPressed: () => setState(() => _showRobotProtocol = false), icon: const Icon(Icons.close, color: Colors.greenAccent))
            ],
          ),
          const Divider(color: Colors.greenAccent),
          const SizedBox(height: 20),

          // Área de dados brutos para "Robôs" (JSON style)
          Container(
            height: 150,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.05), border: Border.all(color: Colors.greenAccent.withOpacity(0.2))),
            child: SingleChildScrollView(
              child: SelectableText(
                JsonEncoder.withIndent('  ').convert({
                  'system': 'TerlineT_Governance',
                  'node': 'MasterGovernance_AI',
                  'protocols_supported': protocols,
                  'access_level': 'Public_Synthetic',
                  'timestamp': DateTime.now().toIso8601String(),
                }),
                style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 10),
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text("ESPECIFICAÇÕES TÉCNICAS (HUMAN READABLE LAYER):", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // Lista de protocolos formatada
          ...protocols.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              title: Text(p['name'], style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(p['type'], style: const TextStyle(color: Colors.white38, fontSize: 11)),
              leading: const Icon(Icons.code, color: Colors.greenAccent, size: 18),
              collapsedIconColor: Colors.greenAccent,
              iconColor: Colors.greenAccent,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRobotMeta('OWNER', p['owner']),
                      _buildRobotMeta('SPEC_ID', p['specs']),
                      _buildRobotMeta('LOGIC_CHAIN', p['logic']),
                      const SizedBox(height: 8),
                    ],
                  ),
                )
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildRobotMeta(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'monospace'))),
        ],
      ),
    );
  }

  Widget _buildTopGovernanceBar(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), border: const Border(bottom: BorderSide(color: Colors.cyanAccent, width: 0.5))),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("TERLINET AI SYSTEM v2.1", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
            if (!isMobile) const Text("PROTOCOL: ISACA / COBIT 2019 / ITIL 4", style: TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class CyberpunkCube extends StatelessWidget {
  final String text;
  const CyberpunkCube({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200, height: 200,
      child: Stack(
        children: [
          _cubeFace(Matrix4.identity()..translate(0.0, 0.0, 100), Colors.black.withOpacity(0.8), true),
          _cubeFace(Matrix4.identity()..translate(100.0, 0.0, 0.0)..rotateY(math.pi/2), Colors.cyan.withOpacity(0.2), false),
          _cubeFace(Matrix4.identity()..translate(-100.0, 0.0, 0.0)..rotateY(-math.pi/2), Colors.teal.withOpacity(0.2), false),
          _cubeFace(Matrix4.identity()..translate(0.0, 100.0, 0.0)..rotateX(math.pi/2), Colors.blue.withOpacity(0.2), false),
          _cubeFace(Matrix4.identity()..translate(0.0, -100.0, 0.0)..rotateX(-math.pi/2), Colors.green.withOpacity(0.2), false),
        ],
      ),
    );
  }

  Widget _cubeFace(Matrix4 t, Color c, bool hasText) {
    return Transform(
      transform: t, alignment: Alignment.center,
      child: Container(
        width: 200, height: 200,
        decoration: BoxDecoration(color: c, border: Border.all(color: Colors.cyanAccent.withOpacity(0.5))),
        child: hasText ? Center(child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))) : null,
      ),
    );
  }
}
