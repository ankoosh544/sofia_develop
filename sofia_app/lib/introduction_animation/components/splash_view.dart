import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sofia_app/main.dart';
import 'package:sofia_app/models/language.dart';

class SplashView extends StatefulWidget {
  final AnimationController animationController;

  const SplashView({Key? key, required this.animationController})
      : super(key: key);

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  Language? _selectedLanguage; // Track the selected language

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 0),
        end: Offset(0.0, -1.0),
      ).animate(
        CurvedAnimation(
          parent: widget.animationController,
          curve: Interval(
            0.0,
            0.2,
            curve: Curves.fastOutSlowIn,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            _buildLanguageDropdown(),
            SizedBox(height: 10),
            _buildElevatorsImage(),
            SizedBox(height: 8),
            _buildTitleText(),
            SizedBox(
              height: 8,
            ),
            _buildBodyText(),
            SizedBox(height: 48),
            _buildSplashButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Container(
      padding: EdgeInsets.only(top: 10, left: 80),
      child: DropdownButton<Language>(
        underline: SizedBox(),
        icon: Row(
          children: [
            Icon(
              Icons.language,
              color: Colors.white,
            ),
            SizedBox(width: 5),
            Text(
              _selectedLanguage != null
                  ? _selectedLanguage!.languageCode
                  : 'EN',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
        onChanged: _onLanguageChanged,
        value: _selectedLanguage,
        items: Language.languageList()
            .map<DropdownMenuItem<Language>>(
              (e) => DropdownMenuItem<Language>(
                value: e,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      e.flag,
                      style: TextStyle(fontSize: 30),
                    ),
                    Text(
                      e.name,
                      style: TextStyle(color: Colors.teal),
                    ),
                    Text(
                      e.languageCode,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void _onLanguageChanged(Language? language) {
    if (language != null) {
      setState(() {
        _selectedLanguage = language;
      });
      SofiaApp.setLocale(context, Locale(language.languageCode, ''));
    }
  }

  Widget _buildElevatorsImage() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Image.asset(
          'assets/introduction_animation/elevators.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTitleText() {
    return Padding(
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        AppLocalizations.of(context)!.splash_view_title,
        style: TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBodyText() {
    return Padding(
      padding: EdgeInsets.only(left: 64, right: 64),
      child: Text(AppLocalizations.of(context)!.splash_view_body,
          textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildSplashButton() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: InkWell(
        onTap: () {
          widget.animationController.animateTo(0.2);
        },
        child: Container(
          height: 58,
          padding: EdgeInsets.only(
            left: 56.0,
            right: 56.0,
            top: 16,
            bottom: 16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(38.0),
            color: Color(0xff132137),
          ),
          child: Text(
            AppLocalizations.of(context)!.splash_button,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
