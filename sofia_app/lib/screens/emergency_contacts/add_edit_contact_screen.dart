import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sofia_app/custom/emergency_contact.dart';

import 'package:sofia_app/storage/storage_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddEditContactScreen extends StatefulWidget {
  final EmergencyContact? contact;

  AddEditContactScreen({this.contact});

  @override
  _AddEditContactScreenState createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final StorageService storageService = StorageService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController prefixController =
      TextEditingController(text: "+39");
  final TextEditingController phoneNumberController = TextEditingController();

  List<String> countryCodes = ["+39", "+34"]; // List of country codes
  String selectedCountryCode = "+39"; // Default selected country code

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      nameController.text = widget.contact!.name;
      prefixController.text = "+39";
      phoneNumberController.text = widget.contact!.phoneNumber
          .substring(3); // Remove the "+39" prefix when editing
      isEditing = true;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    prefixController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  bool validateName(String value) {
    if (value.isEmpty) {
      return false;
    }
    // Add additional validation rules if needed
    return true;
  }

  bool validatePhoneNumber(String value) {
    if (value.isEmpty || value.length != 13) {
      return false;
    }
    // Add additional validation rules if needed
    return true;
  }

  void saveContact() {
    String name = nameController.text;
    String phoneNumber = prefixController.text + phoneNumberController.text;

    if (validateName(name) && validatePhoneNumber(phoneNumber)) {
      EmergencyContact contact =
          EmergencyContact(name: name, phoneNumber: phoneNumber);

      if (isEditing) {
        contact.id = widget.contact!.id;
        storageService.updateEmergencyContact(contact);
      } else {
        storageService.addEmergencyContact(contact);
      }

      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Validation Error'),
          content: const Text(
              'Please enter a valid name and a 10-digit phone number.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          isEditing ? 'Edit Contact' : 'Add Contact',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.white)),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Container(
                  width: 100.0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: DropdownButton<String>(
                        value: selectedCountryCode,
                        onChanged: (newValue) {
                          setState(() {
                            selectedCountryCode = newValue!;
                            prefixController.text = selectedCountryCode;
                          });
                        },
                        dropdownColor: Colors.teal,
                        items: countryCodes
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: phoneNumberController,
                    decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(color: Colors.white)),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(
                          13), // Limit the input to 10 digits
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.black, // Set the desired background color
              ),
              onPressed: saveContact,
              child: Text(
                isEditing ? 'Save Changes' : 'Add Contact',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
