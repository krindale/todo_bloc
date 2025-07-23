import '../model/todo_item.dart';

class TaskCategorizationService {
  static const Map<String, List<String>> _categoryKeywords = {
    'Work': [
      'meeting',
      'presentation',
      'report',
      'project',
      'deadline',
      'client',
      'email',
      'call',
      'conference',
      'business',
      'office',
      'team',
      'manager',
      'review',
      'document',
      'proposal',
      'budget',
      'schedule',
      'plan',
      '회의',
      '발표',
      '보고서',
      '프로젝트',
      '마감',
      '고객',
      '이메일',
      '전화',
      '회의실',
      '업무',
      '사무실',
      '팀',
      '매니저',
      '과제',
      '검토',
      '문서',
      '제안서',
      '예산',
      '일정',
      '계획',
      '출근',
      '퇴근',
      '야근'
    ],
    'Personal': [
      'myself',
      'personal',
      'hobby',
      'read',
      'book',
      'movie',
      'music',
      'game',
      'relax',
      'rest',
      'sleep',
      'meditation',
      'journal',
      'diary',
      'self',
      '개인',
      '취미',
      '독서',
      '책',
      '영화',
      '음악',
      '게임',
      '휴식',
      '잠',
      '명상',
      '일기',
      '자기계발',
      '공부',
      '학습',
      '운동',
      '산책',
    ],
    'Shopping': [
      'buy',
      'purchase',
      'shop',
      'store',
      'mall',
      'grocery',
      'food',
      'clothes',
      'shoes',
      'electronics',
      'gift',
      'online',
      'delivery',
      '구매',
      '쇼핑',
      '마트',
      '시장',
      '백화점',
      '음식',
      '옷',
      '신발',
      '전자제품',
      '선물',
      '온라인',
      '배송',
      '주문',
      '구입',
      '할인',
      '세일'
    ],
    'Health': [
      'doctor',
      'hospital',
      'medicine',
      'exercise',
      'gym',
      'workout',
      'diet',
      'healthy',
      'vitamins',
      'checkup',
      'appointment',
      'dental',
      'run',
      'walk',
      '의사',
      '병원',
      '약',
      '운동',
      '헬스장',
      '다이어트',
      '건강',
      '비타민',
      '검진',
      '치과',
      '달리기',
      '산책',
      '요가',
      '필라테스',
      '수영',
      '등산',
      '헬스'
    ],
    'Finance': [
      'bank',
      'money',
      'pay',
      'bill',
      'budget',
      'savings',
      'investment',
      'tax',
      'insurance',
      'loan',
      'credit',
      'financial',
      'account',
      '은행',
      '돈',
      '결제',
      '청구서',
      '예산',
      '저축',
      '투자',
      '세금',
      '보험',
      '대출',
      '신용카드',
      '금융',
      '계좌',
      '적금',
      '펀드'
    ],
    'Travel': [
      'trip',
      'travel',
      'vacation',
      'flight',
      'hotel',
      'booking',
      'passport',
      'visa',
      'luggage',
      'tourist',
      'destination',
      'itinerary',
      'tickets',
      '여행',
      '휴가',
      '항공편',
      '호텔',
      '예약',
      '여권',
      '비자',
      '짐',
      '관광',
      '목적지',
      '일정',
      '티켓',
      '출국',
      '입국'
    ],
    'Family': [
      'family',
      'parents',
      'children',
      'kids',
      'mom',
      'dad',
      'sister',
      'brother',
      'grandparents',
      'birthday',
      'anniversary',
      'wedding',
      'celebration',
      '가족',
      '부모님',
      '아이들',
      '엄마',
      '아빠',
      '형',
      '누나',
      '동생',
      '할머니',
      '할아버지',
      '생일',
      '기념일',
      '결혼식',
      '축하'
    ],
    'Social': [
      'friends',
      'party',
      'dinner',
      'lunch',
      'coffee',
      'hangout',
      'social',
      'event',
      'gathering',
      'celebration',
      'date',
      'concert',
      'festival',
      '친구',
      '파티',
      '저녁',
      '점심',
      '커피',
      '만남',
      '소셜',
      '이벤트',
      '모임',
      '축하',
      '데이트',
      '콘서트',
      '축제',
      '술자리'
    ]
  };

  String categorizeTask(String title) {
    final titleLower = title.toLowerCase();

    // 각 카테고리별로 키워드 매칭 점수 계산
    final categoryScores = <String, int>{};

    for (final category in _categoryKeywords.keys) {
      int score = 0;
      final keywords = _categoryKeywords[category]!;

      for (final keyword in keywords) {
        if (titleLower.contains(keyword.toLowerCase())) {
          // 정확한 단어 매치에 더 높은 점수
          if (titleLower.split(' ').contains(keyword.toLowerCase())) {
            score += 3;
          } else {
            score += 1;
          }
        }
      }

      if (score > 0) {
        categoryScores[category] = score;
      }
    }

    // 가장 높은 점수의 카테고리 반환
    if (categoryScores.isEmpty) {
      return 'Personal'; // 기본 카테고리
    }

    return categoryScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  TodoItem categorizeAndUpdateTask(TodoItem task) {
    final category = categorizeTask(task.title);
    return TodoItem(
      title: task.title,
      priority: task.priority,
      dueDate: task.dueDate,
      isCompleted: task.isCompleted,
      category: category,
    );
  }

  Map<String, List<TodoItem>> groupTasksByCategory(List<TodoItem> tasks) {
    final groupedTasks = <String, List<TodoItem>>{};

    for (final task in tasks) {
      final category = task.category ?? categorizeTask(task.title);
      if (!groupedTasks.containsKey(category)) {
        groupedTasks[category] = [];
      }
      groupedTasks[category]!.add(task);
    }

    return groupedTasks;
  }

  Map<String, int> getCategoryTaskCounts(List<TodoItem> tasks) {
    final counts = <String, int>{};

    for (final task in tasks) {
      final category = task.category ?? categorizeTask(task.title);
      counts[category] = (counts[category] ?? 0) + 1;
    }

    return counts;
  }

  Map<String, int> getCategoryCompletionCounts(List<TodoItem> tasks) {
    final counts = <String, int>{};

    for (final task in tasks) {
      if (task.isCompleted) {
        final category = task.category ?? categorizeTask(task.title);
        counts[category] = (counts[category] ?? 0) + 1;
      }
    }

    return counts;
  }
}
