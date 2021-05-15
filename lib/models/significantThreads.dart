enum SignificantThreads { Popular, Latest }

extension SignificantThreadsExtension on SignificantThreads {
  // possible to 'toString()' on enum without including enum type?
  String get name => this.toString().split('.').last;
}
