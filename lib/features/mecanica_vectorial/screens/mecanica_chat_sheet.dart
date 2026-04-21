import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_markdown_latex/flutter_markdown_latex.dart';
import 'package:markdown/markdown.dart' as md;
import '../logic/chat_provider.dart';

// Método global para abrir el asistente desde cualquier pantalla de mecánica
void showAssistantMecanica(BuildContext context, Color color, String contextoJson) {
  context.read<ChatProvider>().setSection('Mecánica Vectorial Estática');

  showModalBottomSheet(
    context: context, 
    isScrollControlled: true, 
    backgroundColor: Colors.transparent, 
    builder: (context) => MiniChatAssistantMecanica(contextoDatos: contextoJson, colorTema: color)
  );
}

class MiniChatAssistantMecanica extends StatefulWidget {
  final String contextoDatos; 
  final Color colorTema;
  
  const MiniChatAssistantMecanica({super.key, required this.contextoDatos, required this.colorTema});
  
  @override
  State<MiniChatAssistantMecanica> createState() => _MiniChatAssistantMecanicaState();
}

class _MiniChatAssistantMecanicaState extends State<MiniChatAssistantMecanica> {
  final _controller = TextEditingController();
  late ScrollController _scrollController;
  int? _copiedMessageIndex;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }
  
  @override
  void dispose() { 
    _controller.dispose();
    _scrollController.dispose();
    super.dispose(); 
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  void _showCopiedNotification(int messageIndex) {
    setState(() {
      _copiedMessageIndex = messageIndex;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copiedMessageIndex = null;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatProvider = context.watch<ChatProvider>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom; 

    return Container(
      height: MediaQuery.of(context).size.height * 0.70 + bottomInset, 
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C3350) : Colors.white, 
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), 
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12))), 
            child: Row(
              children: [
                Icon(Icons.architecture_rounded, color: widget.colorTema), // Ícono adaptado
                const SizedBox(width: 8), 
                Text(
                  "Tutor IA - Estática", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A2D4A))
                ), 
                const Spacer(), 
                IconButton(
                  icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54), 
                  onPressed: () => Navigator.pop(context)
                )
              ]
            )
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16), 
              itemCount: chatProvider.messages.length, 
              itemBuilder: (context, index) {
                final msg = chatProvider.messages[index];
                final isLastMessage = index == chatProvider.messages.length - 1;
                final isLastTutorMessage = isLastMessage && !msg.isUser;
                
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft, 
                  child: Column(
                    crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 8), 
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), 
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8), 
                        decoration: BoxDecoration(
                          color: msg.isUser ? widget.colorTema : (isDark ? const Color(0xFF234060) : const Color(0xFFE8EAF6)), 
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight: msg.isUser ? const Radius.circular(0) : null, 
                            bottomLeft: !msg.isUser ? const Radius.circular(0) : null
                          )
                        ), 
                        child: MarkdownBody(
                          data: msg.text,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              fontSize: 16,
                              color: msg.isUser ? Colors.white : (isDark ? Colors.white : const Color(0xFF1A2D4A)),
                            ),
                          ),
                          builders: {
                            'latex': LatexElementBuilder(
                              textStyle: TextStyle(
                                color: msg.isUser ? Colors.white70 : Colors.blue,
                                fontSize: 16,
                              ),
                            ),
                          },
                          extensionSet: md.ExtensionSet(
                            [
                              ...md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                              LatexBlockSyntax(),
                            ],
                            [
                              ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
                              LatexInlineSyntax(),
                            ],
                          ),
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  height: 32,
                                  width: 32,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(text: msg.text));
                                        _showCopiedNotification(index);
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Icon(
                                        Icons.copy_rounded,
                                        size: 18,
                                        color: isDark ? Colors.white54 : Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_copiedMessageIndex == index)
                                  Positioned(
                                    bottom: 36,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check, size: 12, color: Colors.white),
                                          SizedBox(width: 4),
                                          Text(
                                            '¡Copiado!',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (isLastTutorMessage) ...[
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 32,
                                width: 32,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      if (chatProvider.messages.length >= 2) {
                                        final lastUserMessage = chatProvider.messages[chatProvider.messages.length - 2];
                                        if (lastUserMessage.isUser) {
                                          chatProvider.sendMessage(lastUserMessage.text, currentEquation: widget.contextoDatos);
                                        }
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Icon(
                                      Icons.refresh_rounded,
                                      size: 18,
                                      color: isDark ? Colors.white54 : Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  )
                );
              }
            )
          ),
          if (chatProvider.isLoading) 
            Padding(
              padding: const EdgeInsets.all(8.0), 
              child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: widget.colorTema))
            ),
          Padding(
            padding: const EdgeInsets.all(12.0), 
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller, 
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87), 
                    decoration: InputDecoration(
                      hintText: "¿Tienes alguna duda con tu diagrama?", 
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13), 
                      filled: true, 
                      fillColor: isDark ? const Color(0xFF0F1E2E) : const Color(0xFFF5F5F5), 
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), 
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                    )
                  )
                ),
                const SizedBox(width: 8), 
                CircleAvatar(
                  backgroundColor: widget.colorTema, 
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20), 
                    onPressed: () { 
                      if (_controller.text.isNotEmpty) { 
                        chatProvider.sendMessage(_controller.text, currentEquation: widget.contextoDatos); 
                        _controller.clear(); 
                      } 
                    }
                  )
                ),
              ]
            )
          ),
        ],
      ),
    );
  }
}