import 'package:flutter/material.dart';
import 'card_model.dart';
import 'card_stack.dart';
import 'results_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Decision Card Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CardGameScreen(),
    );
  }
}

class CardGameScreen extends StatefulWidget {
  const CardGameScreen({super.key});

  @override
  State<CardGameScreen> createState() => _CardGameScreenState();
}

class _CardGameScreenState extends State<CardGameScreen> {
  final List<CardModel> _cards = [
    CardModel(
      id: 1,
      question: "You find a wallet with \$100 inside.",
      scenario: "Walking down the street, you spot a wallet on the ground. Inside, there's no ID but there's \$100 in cash.",
      leftAnswer: "Leave it there",
      rightAnswer: "Take the money",
      upAnswer: "Try to find the owner",
      downAnswer: "Turn it to police",
      category: "Ethics",
    ),
    CardModel(
      id: 2,
      question: "Friend spreading false rumors.",
      scenario: "You overhear your friend telling others a false story about a classmate, which could damage their reputation.",
      leftAnswer: "Ignore it",
      rightAnswer: "Ask friend to stop",
      upAnswer: "Tell the victim",
      downAnswer: "Join conversation",
      category: "Social",
    ),
    CardModel(
      id: 3,
      question: "You break a \$50 vase in a store.",
      scenario: "You accidentally bump into a display, breaking a vase. The store is busy, and no one saw you.",
      leftAnswer: "Leave the store",
      rightAnswer: "Buy the vase",
      upAnswer: "Tell the staff",
      downAnswer: "Hide and replace it",
      category: "Personal",
    ),
    CardModel(
      id: 4,
      question: "Boss takes credit for your work.",
      scenario: "You spent weeks on a project. In the presentation, your boss presents it as their own idea without mentioning you.",
      leftAnswer: "Stay silent",
      rightAnswer: "Speak up publicly",
      upAnswer: "Discuss privately",
      downAnswer: "Complain to HR",
      category: "Professional",
    ),
    CardModel(
      id: 5,
      question: "See someone shoplifting food.",
      scenario: "You notice a parent shoplifting baby formula and basic groceries. They look distressed and struggling.",
      leftAnswer: "Alert security",
      rightAnswer: "Offer to pay for it",
      upAnswer: "Look away",
      downAnswer: "Talk to them",
      category: "Ethics",
    ),
    CardModel(
      id: 6,
      question: "Invited to two events same night.",
      scenario: "Your best friend's birthday and your partner's work event are on the same night. Both are important.",
      leftAnswer: "Choose friend",
      rightAnswer: "Choose partner",
      upAnswer: "Split the time",
      downAnswer: "Skip both",
      category: "Social",
    ),
    CardModel(
      id: 7,
      question: "Found a valuable item at work.",
      scenario: "You find an expensive watch in the office bathroom. There's no lost and found, and no one has mentioned losing it.",
      leftAnswer: "Keep it",
      rightAnswer: "Email everyone",
      upAnswer: "Give to reception",
      downAnswer: "Wait for someone to ask",
      category: "Professional",
    ),
    CardModel(
      id: 8,
      question: "Family wants you to lie for them.",
      scenario: "Your sibling asks you to lie to your parents about where they were last night to avoid getting in trouble.",
      leftAnswer: "Tell the truth",
      rightAnswer: "Lie for them",
      upAnswer: "Stay neutral",
      downAnswer: "Avoid answering",
      category: "Personal",
    ),
    CardModel(
      id: 9,
      question: "Witness discrimination at work.",
      scenario: "You notice a colleague being treated unfairly due to their background. Others seem to ignore it.",
      leftAnswer: "Stay out of it",
      rightAnswer: "Report to management",
      upAnswer: "Support the colleague",
      downAnswer: "Document everything",
      category: "Professional",
    ),
    CardModel(
      id: 10,
      question: "Friend asks for honest opinion.",
      scenario: "Your friend shows you their creative work and asks for your honest opinion. You think it's not good.",
      leftAnswer: "Be brutally honest",
      rightAnswer: "Give gentle feedback",
      upAnswer: "Only say positives",
      downAnswer: "Avoid the question",
      category: "Social",
    ),
  ];

  final List<Answer> _answers = [];

  void _onCardSwiped(String direction, CardModel card) {
    setState(() {
      _answers.add(Answer(card: card, direction: direction));
    });
  }

  void _onCardFinished() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          answers: _answers,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Decision Card Game',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.inversePrimary.withOpacity(0.1),
              Colors.grey.shade100,
            ],
          ),
        ),
        child: Center(
          child: CardStack(
            cards: _cards,
            onCardSwiped: _onCardSwiped,
            onCardFinished: _onCardFinished,
          ),
        ),
      ),
    );
  }
}