class OnboardingModel {
  final String title;
  final String description;

  OnboardingModel({required this.title, required this.description});
}

final List<OnboardingModel> onboardingData = [
  OnboardingModel(
    title: 'Welcome to TaskMaster',
    description:
        'Your personal task management companion to help you stay organized and productive',
  ),
  OnboardingModel(
    title: 'Create & Organize',
    description:
        'Easily create tasks, set priorities, and organize them into categories',
  ),
  OnboardingModel(
    title: 'Track Progress',
    description: 'Monitor your daily progress and celebrate your achievements',
  ),
];
