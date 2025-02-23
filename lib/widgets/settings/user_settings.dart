part of 'package:maid/main.dart';

class UserSettings extends StatelessWidget {
  final AppSettings settings;

  const UserSettings({
    super.key, 
    required this.settings
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        'User Settings',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      ListenableBuilder(
        listenable: settings,
        builder: userImageBuilder,
      ),
      const SizedBox(height: 8),
      ElevatedButton(
        onPressed: settings.loadUserImage, 
        child: const Text('Load User Image')
      ),
      const SizedBox(height: 8),
      ListenableTextField<AppSettings>(
        listenable: settings,
        selector: () => settings.userName,
        onChanged: settings.setUserName,
        labelText: 'User Name',
      ),
    ],
  );

  Widget userImageBuilder(BuildContext context, Widget? child) {
    if (settings.userImage == null) {
      return Icon(
        Icons.person, 
        size: 50,
        color: Theme.of(context).colorScheme.onSurface
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundImage: FileImage(settings.userImage!),
    );
  }
}