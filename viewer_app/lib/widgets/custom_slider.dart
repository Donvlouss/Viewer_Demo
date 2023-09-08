import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class CustomSlider extends StatefulWidget {
  ScrollController scrollController;

  late VoidCallback toZero;
  CustomSlider(this.scrollController, {super.key});

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  double _maxScrollExtent = 0.0;
  double _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();

    widget.scrollController.addListener(_onScrollValueChanged);
    _maxScrollExtent = widget.scrollController.position.maxScrollExtent;

    widget.toZero = () {
      // v = 0;
      // widget.scrollController.jumpTo(0);
      _sliderValue = 0;
      setState(() {});
    };
  }

  @override
  void dispose() {
    super.dispose();
    widget.scrollController.removeListener(_onScrollValueChanged);
  }

  void _onScrollValueChanged() {
    setState(() {
      _maxScrollExtent = widget.scrollController.position.maxScrollExtent;
      if (_sliderValue > _maxScrollExtent) {
        _sliderValue = _maxScrollExtent;
      }
    });
  }

  Slider _buildSlider(double v) {
    developer.log("Max V:$v", name: "Slider.Set");

    return Slider(
      key: const Key('slider'),
      // value: widget.scrollController.offset,
      value: _sliderValue,
      min: 0,
      max: _maxScrollExtent,
      // divisions: 10,
      activeColor: Colors.pinkAccent,
      inactiveColor: Color.fromARGB(255, 238, 125, 165),
      onChanged: (value) {
        developer.log("Max V:$v", name: "Slider.Set.Cur");
        developer.log("To V:$value", name: "Slider.Set.Move");
        developer.log("Cur V:${widget.scrollController.offset}",
            name: "Slider.Set.Move");

        _sliderValue = value;
        widget.scrollController.jumpTo(value);
        // widget.scrollController.animateTo(value,
        // duration: const Duration(milliseconds: 10), curve: Curves.ease);

        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildSlider(widget.scrollController.position.maxScrollExtent);
  }
}
