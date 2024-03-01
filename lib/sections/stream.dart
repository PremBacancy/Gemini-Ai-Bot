import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gemini_ai_bot/app_theme.dart';
import 'package:gemini_ai_bot/text_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import '../widgets/chat_input_box.dart';
import '../widgets/item_image_view.dart';

class SectionTextStreamInput extends StatefulWidget {
  const SectionTextStreamInput({super.key});

  @override
  State<SectionTextStreamInput> createState() => _SectionTextInputStreamState();
}

class _SectionTextInputStreamState extends State<SectionTextStreamInput> {
  final ImagePicker picker = ImagePicker();
  final controller = TextEditingController();
  final gemini = Gemini.instance;
  String? searchedText,
      // result,
      _finishReason;
  List<Uint8List>? images;
  String? get finishReason => _finishReason;
  set finishReason(String? set) {
    if (set != _finishReason) {
      setState(() => _finishReason = set);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (searchedText != null)
          MaterialButton(
              color: AppTheme.secondaryGreen,
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  searchedText = null;
                  finishReason = null;
                  // result = null;
                });
              },
              child: Text('${searchedText?.capitalizeFirstLetter()}')),
        Expanded(child: GeminiResponseTypeView(
          builder: (context, child, response, loading) {
            if (loading) {
              return Lottie.asset('assets/lottie/ai.json');
            }
            if (response != null) {
              return Markdown(
                data: response,
                selectable: true,
              );
            } else {
              print("priting the response ${response}");
              return const Center(child: Text('Search something!'));
            }
          },
        )),

        /// if the returned finishReason isn't STOP
        if (finishReason != null) Text(finishReason!),

        if (images != null)
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.centerLeft,
            child: Card(
              child: ListView.builder(
                itemBuilder: (context, index) => ItemImageView(
                  bytes: images!.elementAt(index),
                ),
                itemCount: images!.length,
                scrollDirection: Axis.horizontal,
              ),
            ),
          ),

        /// imported from local widgets
        ChatInputBox(
          controller: controller,
          onClickCamera: () {
            picker.pickMultiImage().then((value) async {
              final imagesBytes = <Uint8List>[];
              for (final file in value) {
                imagesBytes.add(await file.readAsBytes());
              }

              if (imagesBytes.isNotEmpty) {
                setState(() {
                  images = imagesBytes;
                });
              }
            });
          },
          onSend: () {
            if (controller.text.isNotEmpty) {
              searchedText = controller.text;
              controller.clear();
              gemini
                  .streamGenerateContent(searchedText!, images: images)
                  .listen((value) {
                setState(() {
                  images = null;
                });
                // result = (result ?? '') + (value.output ?? '');

                if (value.finishReason != 'STOP') {
                  finishReason = 'Finish reason is `RECITATION`';
                }
              }).onError((e) {
                log('streamGenerateContent error', error: e);
                gemini.typeProvider!.loading = false;
                Fluttertoast.showToast(
                    msg: "An error occurred: $e",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM);
                // setState(() {});
                // throw e;
              });
            }
          },
        )
      ],
    );
  }
}
