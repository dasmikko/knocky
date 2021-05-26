class PostsPerPage {
  static const POSTS_PER_PAGE = 20;

  static int unreadPostsPage(int unreadPostCount, int postCount) {
    return ((postCount - (unreadPostCount - 1)) / POSTS_PER_PAGE).ceil();
  }

  static int totalPagesFromPosts(int postCount) {
    return (postCount / POSTS_PER_PAGE).ceil();
  }
}
