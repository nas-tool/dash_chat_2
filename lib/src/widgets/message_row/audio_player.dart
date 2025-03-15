part of '../../../dash_chat_2.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({
    required this.url,
    this.canPlay = true,
    this.audioControlColor,
    this.containerColor = const Color(0xFFF5F5F5),
    Key? key,
  }) : super(key: key);

  /// URL of the audio file
  final String url;

  /// If the audio can be played
  final bool canPlay;

  /// Optional color of the play button
  final Color? audioControlColor;

  /// Background color of the audio message container
  final Color containerColor;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  bool hasError = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  final List<int> _randomWave =
      List<int>.generate(30, (int index) => Random().nextInt(10) + 5);

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer()
      ..onDurationChanged.listen((Duration d) => setState(() => duration = d))
      ..onPositionChanged.listen((Duration p) => setState(() => position = p))
      ..onPlayerComplete.listen((_) => setState(() {
            isPlaying = false;
            position = Duration.zero;
          }));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error playing audio. Please check the file format.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      if (isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(widget.url));
      }
      setState(() => isPlaying = !isPlaying);
    } catch (e) {
      setState(() {
        hasError = true;
        isPlaying = false;
      });
      debugPrint('Exception while playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.containerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: widget.canPlay ? _togglePlayPause : null,
              child: CircleAvatar(
                backgroundColor: hasError
                    ? Colors.red
                    : widget.audioControlColor ?? Colors.blue,
                radius: 20,
                child: Icon(
                  hasError
                      ? Icons.error
                      : (isPlaying ? Icons.pause : Icons.play_arrow),
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: hasError
                  ? const Text(
                      'Error: Invalid audio format',
                      style: TextStyle(color: Colors.red),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _randomWave
                          .map((int h) => Container(
                                height: h.toDouble(),
                                width: 3,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color:
                                      widget.audioControlColor ?? Colors.blue,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
