enum UserRole {
  GUEST,
  BANNED_USER,
  LIMITED_USER,
  BASIC_USER,
  GOLD_USER,
  PAID_GOLD_USER,
  MODERATOR_IN_TRAINING,
  MODERATOR,
  SUPER_MODERATOR,
  ADMIN
}

const UserRoleCodes = {
  UserRole.GUEST: 'guest',
  UserRole.BANNED_USER: 'banned-user',
  UserRole.LIMITED_USER: 'guest',
  UserRole.BASIC_USER: 'guest',
  UserRole.GOLD_USER: 'guest',
  UserRole.PAID_GOLD_USER: 'guest',
  UserRole.MODERATOR_IN_TRAINING: 'guest',
  UserRole.MODERATOR: 'guest',
  UserRole.SUPER_MODERATOR: 'guest',
  UserRole.ADMIN: 'guest',
};

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.GUEST:
        return 'guest';
      case UserRole.BANNED_USER:
        return 'banned-user';
      case UserRole.LIMITED_USER:
        return 'limited-user';
      case UserRole.BASIC_USER:
        return 'basic-user';
      case UserRole.GOLD_USER:
        return 'gold-user';
      case UserRole.PAID_GOLD_USER:
        return 'paid-gold-user';
      case UserRole.MODERATOR_IN_TRAINING:
        return 'moderator-in-training';
      case UserRole.MODERATOR:
        return 'moderator';
      case UserRole.SUPER_MODERATOR:
        return 'super-moderator';
      case UserRole.ADMIN:
        return 'admin';
      default:
        return null;
    }
  }
}
