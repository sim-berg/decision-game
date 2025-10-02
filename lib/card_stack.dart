import 'package:flutter/material.dart';
import 'card_model.dart';

typedef CardSwipeCallback = void Function(String direction, CardModel card);

class CardStack extends StatefulWidget {
  final List<CardModel> cards;
  final CardSwipeCallback onCardSwiped;
  final VoidCallback onCardFinished;

  const CardStack({
    super.key,
    required this.cards,
    required this.onCardSwiped,
    required this.onCardFinished,
  });

  @override
  State<CardStack> createState() => _CardStackState();
}

class _CardStackState extends State<CardStack> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.cards.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onCardFinished();
      });
      return const SizedBox();
    }

    return Stack(
      children: [
        if (_currentIndex + 1 < widget.cards.length)
          _buildCard(widget.cards[_currentIndex + 1], 1, null),
        if (_currentIndex < widget.cards.length)
          _buildCard(widget.cards[_currentIndex], 0, _onCardSwiped),
      ],
    );
  }

  Widget _buildCard(CardModel card, int index, Function(String)? onSwipe) {
    return Positioned(
      top: 20.0 * index,
      left: 10.0 * index,
      right: 10.0 * index,
      child: DraggableCard(
        key: ValueKey(_currentIndex + index),
        card: card,
        onSwipe: onSwipe,
        showAnswers: index == 0,
      ),
    );
  }

  void _onCardSwiped(String direction) {
    widget.onCardSwiped(direction, widget.cards[_currentIndex]);
    setState(() {
      _currentIndex++;
    });
  }
}

class DraggableCard extends StatefulWidget {
  final CardModel card;
  final Function(String)? onSwipe;
  final bool showAnswers;

  const DraggableCard({
    super.key,
    required this.card,
    this.onSwipe,
    required this.showAnswers,
  });

  @override
  State<DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard>
    with TickerProviderStateMixin {
  late AnimationController _answerController;
  late final  AnimationController _swipeController;
  late Animation<double> _answerAnimation;
  late Animation<Offset> _swipeAnimation;
  late Animation<double> _rotationAnimation;
  Offset _offset = Offset.zero;
  double _rotation = 0;
  bool _isSwiping = false;
  bool _isSwiped = false;

  @override
  void initState() {
    super.initState();
    _answerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOut,
    ));
    _answerAnimation = CurvedAnimation(
      parent: _answerController,
      curve: Curves.easeIn,
    );

    if (widget.showAnswers) {
      _answerController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant DraggableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAnswers && !oldWidget.showAnswers) {
      _answerController.forward();
    } else if (!widget.showAnswers && oldWidget.showAnswers) {
      _answerController.reverse();
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    _swipeController.dispose();
    super.dispose();
  }

  void _handleSwipe(String direction) {
    if (widget.onSwipe != null && !_isSwiped) {
      _isSwiped = true;
      widget.onSwipe!(direction);
    }
  }

  void _handleSwipeAnimation(String direction) {
    setState(() {
      Offset endPosition = Offset.zero;
      double endRotation = 0.0;
      
      const double distance = 1000.0;
      const double rotation = 0.3;
      
      switch (direction) {
        case 'left':
          endPosition = Offset(-distance, _offset.dy);
          endRotation = -rotation;
          break;
        case 'right':
          endPosition = Offset(distance, _offset.dy);
          endRotation = rotation;
          break;
        case 'up':
          endPosition = Offset(_offset.dx, -distance);
          endRotation = -rotation;
          break;
        case 'down':
          endPosition = Offset(_offset.dx, distance);
          endRotation = rotation;
          break;
      }

      _swipeController.reset();
      
      _swipeAnimation = Tween<Offset>(
        begin: _offset,
        end: endPosition,
      ).animate(CurvedAnimation(
        parent: _swipeController,
        curve: Curves.easeInOut,
      ));
      
      _rotationAnimation = Tween<double>(
        begin: _rotation,
        end: endRotation,
      ).animate(CurvedAnimation(
        parent: _swipeController,
        curve: Curves.easeInOut,
      ));
    });

    _swipeController.forward().then((_) {
      _handleSwipe(direction);
    });
  }


  @override
  Widget build(BuildContext context) {
    // Don't show the card if it's being swiped away
    if (_isSwiped && _swipeController.isCompleted) {
      return const SizedBox();
    }

    // Create the animation for the current position
    final currentPosition = _swipeController.isAnimating ? _swipeAnimation : AlwaysStoppedAnimation(_offset);
    final currentRotation = _swipeController.isAnimating ? _rotationAnimation : AlwaysStoppedAnimation(_rotation);

    return Center(
      child: Container(
        width: 400,
        height: 550,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Top answer (Hearts)
            Positioned(
              top: 0,
              left: 80,
              right: 80,
              child: FadeTransition(
                opacity: _answerAnimation,
                child: _buildAnswerCard(
                  text: "♥ ${widget.card.upAnswer}",
                  color: const Color(0xFFDC143C),
                  onTap: () => _handleSwipeAnimation('up'),
                ),
              ),
            ),
            // Left answer (Clubs)
            Positioned(
              left: 0,
              top: 170,
              bottom: 170,
              width: 60,
              child: FadeTransition(
                opacity: _answerAnimation,
                child: _buildVerticalAnswerCard(
                  text: "♣ ${widget.card.leftAnswer}",
                  color: const Color(0xFF228B22),
                  onTap: () => _handleSwipeAnimation('left'),
                ),
              ),
            ),
            // Right answer (Diamonds) - moved before card
            Positioned(
              right: 0,
              top: 170,
              bottom: 170,
              width: 60,
              child: FadeTransition(
                opacity: _answerAnimation,
                child: _buildVerticalAnswerCard(
                  text: "♦ ${widget.card.rightAnswer}",
                  color: const Color(0xFF1E90FF),
                  onTap: () => _handleSwipeAnimation('right'),
                ),
              ),
            ),
            // Bottom answer (Spades) - moved before card
            Positioned(
              bottom: 0,
              left: 80,
              right: 80,
              child: FadeTransition(
                opacity: _answerAnimation,
                child: _buildAnswerCard(
                  text: "♠ ${widget.card.downAnswer}",
                  color: const Color(0xFF000000),
                  onTap: () => _handleSwipeAnimation('down'),
                ),
              ),
            ),
            // Main card - LAST so it's on top
            Positioned(
              top: 80,
              left: 70,
              right: 70,
              bottom: 80,
              child: GestureDetector(
                onPanStart: (details) {
                  _isSwiping = true;
                },
                onPanUpdate: (details) {
                  setState(() {
                    _offset += details.delta;
                    // Limit rotation to 15 degrees
                    _rotation = (_offset.dx / 100).clamp(-0.25, 0.25);
                  });
                },
                onPanEnd: (details) {
                  _isSwiping = false;
                  if (_offset.distance > 50) {
                    String direction = "right";
                    if (_offset.dx > 50 && _offset.dx > _offset.dy.abs()) {
                      direction = "right";
                    } else if (_offset.dx < -50 && _offset.dx.abs() > _offset.dy.abs()) {
                      direction = "left";
                    } else if (_offset.dy > 50 && _offset.dy > _offset.dx.abs()) {
                      direction = "down";
                    } else if (_offset.dy < -50 && _offset.dy.abs() > _offset.dx.abs()) {
                      direction = "up";
                    }
                    _handleSwipeAnimation(direction);
                  } else {
                    setState(() {
                      _offset = Offset.zero;
                      _rotation = 0;
                    });
                  }
                },
                child: AnimatedBuilder(
                  animation: _swipeController,
                  builder: (context, child) {
                    final offset = _swipeController.isAnimating 
                        ? _swipeAnimation.value 
                        : _offset;
                    final rotation = _swipeController.isAnimating 
                        ? _rotationAnimation.value 
                        : _rotation;
                    
                    return Transform.translate(
                      offset: offset,
                      child: Transform.rotate(
                        angle: rotation,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.grey.shade50,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: Colors.black,
                        width: 3.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 60.0, 20.0, 60.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.card.question,
                                style: const TextStyle(
                                  fontSize: 19.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  letterSpacing: 0.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 18),
                              Text(
                                widget.card.scenario,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey.shade700,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.card.suitColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: widget.card.suitColor.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  widget.card.suit,
                                  style: TextStyle(
                                    color: widget.card.suitColor,
                                    fontSize: 28,
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  widget.card.category,
                                  style: TextStyle(
                                    color: widget.card.suitColor,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Transform.rotate(
                            angle: 3.14159,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: widget.card.suitColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: widget.card.suitColor.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    widget.card.suit,
                                    style: TextStyle(
                                      color: widget.card.suitColor,
                                      fontSize: 28,
                                      height: 1,
                                    ),
                                  ),
                                  Text(
                                    widget.card.category,
                                    style: TextStyle(
                                      color: widget.card.suitColor,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (widget.showAnswers)
              const Positioned(
                bottom: 5,
                left: 0,
                right: 0,
                child: Text(
                  "Swipe card or tap an answer",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerCard({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.0),
          splashColor: Colors.white.withOpacity(0.3),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalAnswerCard({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.0),
          splashColor: Colors.white.withOpacity(0.3),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 10.0,
            ),
            child: RotatedBox(
              quarterTurns: -1,
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}