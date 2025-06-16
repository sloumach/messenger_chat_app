import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../models/message_model.dart';
import '../services/message_service.dart';
import '../services/reverb_socket_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MessagePage extends StatefulWidget {
  final ContactModel contact;

  const MessagePage({super.key, required this.contact});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final MessageService _messageService = MessageService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final TextEditingController _controller = TextEditingController();
  final List<MessageModel> _messages = [];
  final ScrollController _scrollController = ScrollController();
  String? _oldestIso; // timestamp du plus ancien msg chargé
  bool _isFetchingMore = false;
  bool _noMore = false; // true si on a tout chargé

  late ReverbSocketService _socketService;

  bool _isLoading = true;
  bool _isSending = false;
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _initChat();
  }

  void _onScroll() {
    // Distance depuis le haut
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + 50) {
      _loadMessages(loadMore: true); // charge bloc précédent
    }
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

  Future<void> _initChat() async {
    final userIdStr = await _secureStorage.read(key: 'user_id');

    if (userIdStr == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error : User not found')));
      return;
    }

    _userId = int.tryParse(userIdStr) ?? 0;

    await _initSocket();
    await _loadMessages();
  }

  Future<void> _loadMessages({bool loadMore = false}) async {
    if (loadMore && (_isFetchingMore || _noMore)) return;

    setState(() => _isFetchingMore = loadMore);

    try {
      final msgs = await _messageService.fetchMessages(
        context,
        widget.contact.id,
        beforeIso: loadMore ? _oldestIso : null,
      );

      setState(() {
        if (loadMore) {
          _messages.insertAll(0, msgs); // on prépend
        } else {
          _messages.addAll(msgs); // chargement initial
          _isLoading = false;
        }

        if (msgs.isNotEmpty) {
          _oldestIso = msgs.first.createdAt.toIso8601String();
        }
        if (msgs.length < 20) _noMore = true; // moins que 20 => plus rien
      });

      if (!loadMore) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } finally {
      if (loadMore) setState(() => _isFetchingMore = false);
    }
  }

  Future<void> _initSocket() async {
    _socketService = ReverbSocketService();

    await _socketService.connect(
      channel: 'private-chat.$_userId',
      onMessageReceived: (content, senderId) {
        setState(() {
          _messages.add(
            MessageModel(
              id: 0,
              senderId: senderId,
              receiverId: _userId,
              content: content,
              createdAt: DateTime.now(),
              status: 'received',
            ),
          );
        });
        _scrollToBottom();
      },
    );
  }

  Future<void> _sendMessage() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      await _messageService.sendMessage(context, widget.contact.id, content);
      setState(() {
        _messages.add(
          MessageModel(
            id: 0,
            senderId: _userId,
            receiverId: widget.contact.id,
            content: content,
            createdAt: DateTime.now(),
            status: 'sent',
          ),
        );
        _controller.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error : ${e.toString()}')));
    } finally {
      setState(() => _isSending = false);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return "Today";
    if (difference == 1) return "Yesterday";
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    _socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.contact.name}')),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount:
                        _messages.length +
                        (_isFetchingMore ? 1 : 0), // ajouter 1 si loader
                    itemBuilder: (context, index) {
                      if (_isFetchingMore && index == 0) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final msgIndex = _isFetchingMore ? index - 1 : index;
                      final msg = _messages[msgIndex];
                      final isOwn = msg.senderId == _userId;

                      // Vérifie si on doit afficher une date
                      bool showDate = true;
                      if (msgIndex > 0) {
                        final prevMsg = _messages[msgIndex - 1];
                        showDate =
                            msg.createdAt.day != prevMsg.createdAt.day ||
                            msg.createdAt.month != prevMsg.createdAt.month ||
                            msg.createdAt.year != prevMsg.createdAt.year;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showDate)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Text(
                                  _formatDate(msg.createdAt),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          Align(
                            alignment: isOwn
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: isOwn ? Colors.blue : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                msg.content,
                                style: TextStyle(
                                  color: isOwn ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Écrire un message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
