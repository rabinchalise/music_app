import 'dart:io';

import 'package:client/core/theme/app_color.dart';
import 'package:client/core/utils/extension.dart';
import 'package:client/core/utils/utils.dart';
import 'package:client/core/widgets/custom_textfields.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/view/widgets/audio_wave.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadSongPage extends ConsumerStatefulWidget {
  const UploadSongPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UploadSongPageState();
}

class _UploadSongPageState extends ConsumerState<UploadSongPage> {
  final _formKey = GlobalKey<FormState>();
  final _songNameController = TextEditingController();
  final _artistController = TextEditingController();
  File? selectedImage;
  File? selectedAudio;

  Color selectedColor = AppColor.cardColor;

  void selectAudio() async {
    final pickedAudio = await pickAudio();

    if (pickedAudio != null) {
      setState(() {
        selectedAudio = pickedAudio;
      });
    }
  }

  void selectImage() async {
    final pickedImage = await pickImage();

    if (pickedImage != null) {
      setState(() {
        selectedImage = pickedImage;
      });
    }
  }

  @override
  void dispose() {
    _songNameController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      homeViewModelProvider.select((val) => val?.isLoading == true),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Song'),
        actions: [
          IconButton(
            onPressed: () async {
              if (_formKey.currentState!.validate() &&
                  selectedImage != null &&
                  selectedAudio != null) {
                await ref.read(homeViewModelProvider.notifier).uploadSong(
                      selectedAudio: selectedAudio!,
                      selectedThumbnail: selectedImage!,
                      songName: _songNameController.text,
                      artist: _artistController.text,
                      selectedColor: selectedColor,
                    );
              } else {
                context.showSnackBar(
                  message: 'Missing Fields',
                );
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: isLoading
          ? const Loader()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: selectImage,
                      child: selectedImage != null
                          ? SizedBox(
                              height: 150,
                              width: double.maxFinite,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ))
                          : DottedBorder(
                              color: AppColor.borderColor,
                              radius: const Radius.circular(10),
                              borderType: BorderType.RRect,
                              dashPattern: const [10, 4],
                              strokeCap: StrokeCap.round,
                              child: SizedBox(
                                height: 150,
                                width: double.maxFinite,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.folder_open,
                                      size: 40,
                                    ),
                                    15.verticalSpacer,
                                    const Text(
                                      'Select the thumbnail for your song',
                                      style: TextStyle(fontSize: 20),
                                    )
                                  ],
                                ),
                              ),
                            ),
                    ),
                    40.verticalSpacer,
                    selectedAudio != null
                        ? AudioWave(path: selectedAudio!.path)
                        : CustomTextfields(
                            hintText: 'Pick Song',
                            readOnly: true,
                            onTap: selectAudio,
                          ),
                    20.verticalSpacer,
                    CustomTextfields(
                      hintText: 'Artist',
                      controller: _artistController,
                    ),
                    20.verticalSpacer,
                    CustomTextfields(
                      hintText: 'Song Name',
                      controller: _songNameController,
                    ),
                    20.verticalSpacer,
                    ColorPicker(
                      pickersEnabled: const {ColorPickerType.wheel: true},
                      color: selectedColor,
                      onColorChanged: (Color color) {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
