class Chapter {
  Chapter(
    this.id,
    this.chapterNum,
    this.bookId,
    {
      this.isDownloaded = false,
      this.isFinished = false,
      this.isPurchased = false,
    }
  );
  int id;
  int chapterNum;
  String bookId;
  bool isDownloaded;
  bool isFinished;
  bool isPurchased;
}