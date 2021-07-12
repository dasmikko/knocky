enum Usergroup {
  banned,
  regular,
  gold,
  moderator,
  admin,
  staff,
  moderatorInTraining,
}

class UsergroupHelper {
  static String userGroupToString(Usergroup group) {
    switch (group) {
      case Usergroup.banned:
        return 'Banned';
      case Usergroup.regular:
        return 'Member';
      case Usergroup.gold:
        return 'Gold Member';
      case Usergroup.moderator:
        return 'Moderator';
      case Usergroup.admin:
        return 'Admin';
      case Usergroup.staff:
        return 'Staff';
      case Usergroup.moderatorInTraining:
        return 'Moderator (training)';
    }
    return '';
  }
}
