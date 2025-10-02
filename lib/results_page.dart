import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'card_model.dart';
import 'main.dart';

class ResultsPage extends StatelessWidget {
  final List<Answer> answers;

  const ResultsPage({
    super.key,
    required this.answers,
  });

  Map<String, Map<String, int>> _analyzeAnswers() {
    final analysis = {
      'Ethics': {'up': 0, 'down': 0, 'left': 0, 'right': 0},
      'Social': {'up': 0, 'down': 0, 'left': 0, 'right': 0},
      'Personal': {'up': 0, 'down': 0, 'left': 0, 'right': 0},
      'Professional': {'up': 0, 'down': 0, 'left': 0, 'right': 0},
    };

    for (var answer in answers) {
      final category = answer.card.category;
      final direction = answer.direction;
      if (analysis.containsKey(category)) {
        analysis[category]![direction] = (analysis[category]![direction] ?? 0) + 1;
      }
    }

    return analysis;
  }

  double _calculateCategoryScore(Map<String, int> directions) {
    final total = directions.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return 0;

    int proactiveScore = (directions['up'] ?? 0) * 3 + (directions['right'] ?? 0) * 2;
    int reactiveScore = (directions['down'] ?? 0) * 2 + (directions['left'] ?? 0) * 1;
    
    return ((proactiveScore + reactiveScore) / (total * 3) * 10);
  }

  @override
  Widget build(BuildContext context) {
    final analysis = _analyzeAnswers();
    
    final ethicsScore = _calculateCategoryScore(analysis['Ethics']!);
    final socialScore = _calculateCategoryScore(analysis['Social']!);
    final personalScore = _calculateCategoryScore(analysis['Personal']!);
    final professionalScore = _calculateCategoryScore(analysis['Professional']!);

    final scores = {
      'Ethics': ethicsScore,
      'Social': socialScore,
      'Personal': personalScore,
      'Professional': professionalScore,
    };

    final strongestCategory = scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final weakestCategory = scores.entries.reduce((a, b) => a.value < b.value ? a : b).key;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Decision Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Decision Profile',
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Completed ${answers.length} decisions',
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                height: 300,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: RadarChart(
                  RadarChartData(
                    radarShape: RadarShape.polygon,
                    tickCount: 5,
                    ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 10),
                    radarBorderData: const BorderSide(color: Colors.grey, width: 2),
                    gridBorderData: const BorderSide(color: Colors.grey, width: 1),
                    tickBorderData: const BorderSide(color: Colors.transparent),
                    getTitle: (index, angle) {
                      String text = '';
                      switch (index) {
                        case 0:
                          text = 'Ethics ♥\n${ethicsScore.toStringAsFixed(1)}';
                          break;
                        case 1:
                          text = 'Social ♦\n${socialScore.toStringAsFixed(1)}';
                          break;
                        case 2:
                          text = 'Personal ♣\n${personalScore.toStringAsFixed(1)}';
                          break;
                        case 3:
                          text = 'Professional ♠\n${professionalScore.toStringAsFixed(1)}';
                          break;
                      }
                      return RadarChartTitle(
                        text: text,
                        angle: angle,
                        positionPercentageOffset: 0.15,
                      );
                    },
                    titleTextStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    dataSets: [
                      RadarDataSet(
                        fillColor: Colors.blueAccent.withOpacity(0.3),
                        borderColor: Colors.blueAccent,
                        borderWidth: 3,
                        entryRadius: 4,
                        dataEntries: [
                          RadarEntry(value: ethicsScore),
                          RadarEntry(value: socialScore),
                          RadarEntry(value: personalScore),
                          RadarEntry(value: professionalScore),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(color: Colors.green.shade300, width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      '🎯 Your Decision Style',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _getProfileText(strongestCategory, weakestCategory, scores, analysis),
                      style: const TextStyle(
                        fontSize: 15.0,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildDecisionBreakdown(analysis),
              const SizedBox(height: 30),
              const Text(
                'Your Decisions',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: answers.length,
                itemBuilder: (context, index) {
                  final answer = answers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 2,
                    child: ListTile(
                      leading: Text(
                        answer.card.suit,
                        style: TextStyle(
                          fontSize: 30,
                          color: answer.card.suitColor,
                        ),
                      ),
                      title: Text(
                        answer.card.question,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            'Category: ${answer.card.category}',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Your choice: ${_getAnswerText(answer)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const CardGameScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Play Again'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecisionBreakdown(Map<String, Map<String, int>> analysis) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.blue.shade300, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            '📊 Decision Breakdown',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Your approach by category:',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black87,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 15),
          ...analysis.entries.map((entry) {
            final category = entry.key;
            final directions = entry.value;
            final total = directions.values.fold(0, (sum, count) => sum + count);
            
            if (total == 0) return const SizedBox.shrink();
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _buildDirectionBadge('♥ Up', directions['up'] ?? 0, Colors.red),
                      const SizedBox(width: 5),
                      _buildDirectionBadge('♦ Right', directions['right'] ?? 0, Colors.blue),
                      const SizedBox(width: 5),
                      _buildDirectionBadge('♠ Down', directions['down'] ?? 0, Colors.black),
                      const SizedBox(width: 5),
                      _buildDirectionBadge('♣ Left', directions['left'] ?? 0, Colors.green),
                    ],
                  ),
                  const Divider(height: 20),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDirectionBadge(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(
          '$label: $count',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _getAnswerText(Answer answer) {
    switch (answer.direction) {
      case 'left':
        return '♣ ${answer.card.leftAnswer}';
      case 'right':
        return '♦ ${answer.card.rightAnswer}';
      case 'up':
        return '♥ ${answer.card.upAnswer}';
      case 'down':
        return '♠ ${answer.card.downAnswer}';
      default:
        return 'Unknown';
    }
  }

  String _getProfileText(String strongest, String weakest, Map<String, double> scores, Map<String, Map<String, int>> analysis) {
    final strongScore = scores[strongest] ?? 0;
    final weakScore = scores[weakest] ?? 0;
    
    String profile = '';
    
    final strongAnalysis = analysis[strongest]!;
    final upCount = strongAnalysis['up'] ?? 0;
    final rightCount = strongAnalysis['right'] ?? 0;
    final downCount = strongAnalysis['down'] ?? 0;
    final leftCount = strongAnalysis['left'] ?? 0;
    
    String tendency = '';
    if (upCount >= rightCount && upCount >= downCount && upCount >= leftCount) {
      tendency = 'You tend to take proactive, positive actions';
    } else if (rightCount > upCount && rightCount >= downCount && rightCount >= leftCount) {
      tendency = 'You prefer direct and assertive approaches';
    } else if (downCount > upCount && downCount > rightCount) {
      tendency = 'You tend to follow established procedures';
    } else {
      tendency = 'You often choose avoidance or passive options';
    }
    
    switch (strongest) {
      case 'Ethics':
        profile = 'Your strongest area is Ethics (${strongScore.toStringAsFixed(1)}/10). $tendency when facing moral dilemmas. ';
        break;
      case 'Social':
        profile = 'Your strongest area is Social (${strongScore.toStringAsFixed(1)}/10). $tendency in interpersonal situations. ';
        break;
      case 'Personal':
        profile = 'Your strongest area is Personal (${strongScore.toStringAsFixed(1)}/10). $tendency in personal responsibility matters. ';
        break;
      case 'Professional':
        profile = 'Your strongest area is Professional (${strongScore.toStringAsFixed(1)}/10). $tendency in workplace scenarios. ';
        break;
    }
    
    if (strongScore - weakScore >= 2) {
      switch (weakest) {
        case 'Ethics':
          profile += 'Consider developing stronger ethical reasoning skills to enhance moral decision-making.';
          break;
        case 'Social':
          profile += 'Building social awareness could help you navigate interpersonal situations more effectively.';
          break;
        case 'Personal':
          profile += 'Developing personal accountability skills could enhance your decision-making confidence.';
          break;
        case 'Professional':
          profile += 'Growing your professional judgment could benefit your career development.';
          break;
      }
    } else {
      profile += 'You demonstrate a well-balanced approach across all decision-making categories!';
    }
    
    return profile;
  }
}
