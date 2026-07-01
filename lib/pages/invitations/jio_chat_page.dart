import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/models/jio_chat_message.dart';
import 'package:jio_leh/models/open_jio_event.dart';
import 'package:jio_leh/pages/auth/widgets/brand_loading_animation.dart';
import 'package:jio_leh/services/jio_chat_service.dart';

/// Group chat for a single Open Jio invite. Only the creator and accepted
/// invitees can reach this screen (enforced by RLS on the server).
class JioChatPage extends StatefulWidget {
  const JioChatPage({super.key, required this.event});

  final OpenJioEvent event;

  @override
  State<JioChatPage> createState() => _JioChatPageState();
}

class _JioChatPageState extends State<JioChatPage> {
  late final JioChatService _chat;
  late final String _eventId;
  late final String _currentUserId;

  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();

  final List<JioChatMessage> _messages = [];
  bool _loading = true;
  bool _hasError = false;
  bool _sending = false;

  void Function()? _unsubscribe;
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    final services = ServiceProvider.of(context)!;
    _chat = services.jioChat;
    _currentUserId = services.auth.getCurrentUserId();
    _eventId = widget.event.id!;

    _loadAndSubscribe();
  }

  Future<void> _loadAndSubscribe() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      final history = await _chat.loadMessages(_eventId);
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(history);
        _loading = false;
      });
      _scrollToBottom();

      // Start listening AFTER history loads so we don't miss or duplicate rows.
      _unsubscribe = _chat.subscribeToMessages(_eventId, _onNewMessage);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = true;
      });
    }
  }

  void _onNewMessage(JioChatMessage message) {
    if (!mounted) return;
    // Realtime can echo back our own insert; skip anything we already have.
    if (_messages.any((m) => m.id == message.id)) return;
    setState(() => _messages.add(message));
    _scrollToBottom();
  }

  Future<void> _sendText() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _sending) return;

    _textController.clear();
    setState(() => _sending = true);
    try {
      await _chat.sendText(_eventId, text);
    } catch (_) {
      _showError('Failed to send message.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _sendPhoto() async {
    if (_sending) return;
    final photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo == null) return;

    setState(() => _sending = true);
    try {
      await _chat.sendPhoto(_eventId, photo);
    } catch (_) {
      _showError('Failed to send photo.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _scrollToBottom() {
    // Wait one frame so the new item is laid out before we scroll.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _unsubscribe?.call();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.event.caption)),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: BrandLoadingAnimation.compact());
    }
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Failed to load chat.'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadAndSubscribe,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_messages.isEmpty) {
      return const Center(child: Text('No messages yet. Say hi! 👋'));
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: _messages.length,
      itemBuilder: (context, index) => _buildBubble(_messages[index]),
    );
  }

  Widget _buildBubble(JioChatMessage message) {
    final isMine = message.senderId == _currentUserId;
    final theme = Theme.of(context);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMine
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Text(
                message.senderName,
                style: theme.textTheme.labelSmall,
              ),
            if (message.hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  message.imageUrl!,
                  loadingBuilder: (context, child, progress) =>
                      progress == null
                          ? child
                          : const Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            ),
                  errorBuilder: (test1, test2, test3) => const Text('⚠️ image failed'),
                ),
              ),
            if (message.hasText)
              Text(
                message.content!,
                style: TextStyle(
                  color: isMine
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.photo_outlined),
              onPressed: _sending ? null : _sendPhoto,
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendText(),
                decoration: const InputDecoration(
                  hintText: 'Message…',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sending ? null : _sendText,
            ),
          ],
        ),
      ),
    );
  }
}
