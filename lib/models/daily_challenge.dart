enum DailyChallengeType {
  correctAnswers,
  correctlyIdentifyScams,
  perfectRounds,
  correctStreak,
  completedRounds,
}

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final DailyChallengeType type;
  final int target;
  final int rewardXp;

  int progress;
  bool completed;
  bool claimed;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.rewardXp,
    this.progress = 0,
    this.completed = false,
    this.claimed = false,
  }) {
    progress = progress.clamp(0, target).toInt();
    completed = completed || progress >= target;
  }

  bool get canClaim => completed && !claimed;

  void addProgress(int amount) {
    if (amount <= 0 || completed) return;
    progress = (progress + amount).clamp(0, target).toInt();
    completed = progress >= target;
  }

  void resetProgress() {
    progress = 0;
    completed = false;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.name,
    'target': target,
    'rewardXp': rewardXp,
    'progress': progress,
    'completed': completed,
    'claimed': claimed,
  };

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String? ?? DailyChallengeType.completedRounds.name;
    final type = DailyChallengeType.values.firstWhere(
      (value) => value.name == typeName,
      orElse: () => DailyChallengeType.completedRounds,
    );
    return DailyChallenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: type,
      target: (json['target'] as num).toInt(),
      rewardXp: (json['rewardXp'] as num).toInt(),
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      completed: json['completed'] as bool? ?? false,
      claimed: json['claimed'] as bool? ?? false,
    );
  }
}
