import 'package:flutter/material.dart';

class CardModel {
  final int id;
  final String question;
  final String scenario;
  final String leftAnswer;
  final String rightAnswer;
  final String upAnswer;
  final String downAnswer;
  final String category;

  CardModel({
    required this.id,
    required this.question,
    required this.scenario,
    required this.leftAnswer,
    required this.rightAnswer,
    required this.upAnswer,
    required this.downAnswer,
    required this.category,
  });

  String get suit {
    switch (category) {
      case 'Ethics':
        return '♥';
      case 'Social':
        return '♦';
      case 'Personal':
        return '♣';
      case 'Professional':
        return '♠';
      default:
        return '♥';
    }
  }

  Color get suitColor {
    switch (category) {
      case 'Ethics':
        return const Color(0xFFDC143C);
      case 'Social':
        return const Color(0xFF1E90FF);
      case 'Personal':
        return const Color(0xFF228B22);
      case 'Professional':
        return const Color(0xFF000000);
      default:
        return const Color(0xFFDC143C);
    }
  }
}

class Answer {
  final CardModel card;
  final String direction;

  Answer({required this.card, required this.direction});
}