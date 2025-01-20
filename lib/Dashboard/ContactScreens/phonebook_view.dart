import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gosecure/Dashboard/Dashboard.dart';
import 'package:gosecure/animations/bottomAnimation.dart';

class PhoneBook extends StatefulWidget {
  @override
  _PhoneBookState createState() => _PhoneBookState();
}

class _PhoneBookState extends State<PhoneBook> {
  List<Contact> _contacts = [];
  List<Contact> filteredContacts = [];
  List<Contact> _userSelectedContacts = [];

  Permission _permission = Permission.contacts;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  Future<PermissionStatus> _getContactPermission() async {
    _permissionStatus = await _permission.status;

    if (_permissionStatus != PermissionStatus.granted) {
      _permissionStatus = await _permission.request();
      return _permissionStatus ?? PermissionStatus.denied;
    } else {
      return _permissionStatus;
    }
  }

  refreshContacts() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      var contacts = (await ContactsService.getContacts(withThumbnails: false)).toList();
      setState(() {
        _contacts = contacts;
        filteredContacts = _contacts;
      });
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    String message = '';
    if (permissionStatus == PermissionStatus.denied) {
      message = "Permission denied. Please enable contact access in settings.";
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      message = "Permission permanently denied. Please enable contact access in settings.";
    }
    Fluttertoast.showToast(msg: message);
  }

  @override
  void initState() {
    super.initState();
    refreshContacts();
  }

  goBack() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => Dashboard(pageIndex: 1),
      ),
          (route) => false,
    );
  }

  saveContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> numbers = prefs.getStringList("numbers") ?? [];
    if (_userSelectedContacts.isNotEmpty) {
      for (Contact c in _userSelectedContacts) {
        String entity = "";
        if (c.phones != null && c.phones!.isNotEmpty) {  // Fixed nullable check
          String refactoredNumber = refactorPhoneNumbers(c.phones!.first.value ?? "");
          entity = "${c.displayName ?? "User"}***$refactoredNumber";
        } else {
          entity = "${c.displayName ?? "User"}***";
        }
        if (!numbers.contains(entity)) numbers.add(entity);
      }

      prefs.setStringList("numbers", numbers);
      Fluttertoast.showToast(msg: "Contacts saved successfully!");
      goBack();
    } else {
      Fluttertoast.showToast(msg: "Please add at least one contact.");
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: saveContacts,
        backgroundColor: Color(0xFFFB8580),
        child: Text("Save"),
      ),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Color(0xFFFB8580),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: goBack,
        ),
        title: TextField(
          textInputAction: TextInputAction.search,
          style: TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent)),
            prefixIcon: Icon(Icons.search, color: Colors.white70, size: height * 0.03),
            hintText: 'Search Name',
            hintStyle: TextStyle(color: Colors.white70),
          ),
          onChanged: (string) {
            setState(() {
              filteredContacts = _contacts
                  .where((c) => (c.displayName?.toLowerCase()?.contains(string.toLowerCase()) ?? false))
                  .toList();
            });
          },
        ),
      ),
      body: _contacts.isNotEmpty
          ? Container(
        height: height,
        width: width,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(vertical: height * 0.01),
          separatorBuilder: (context, index) {
            Contact c = filteredContacts[index];
            if (c.phones == null || c.phones!.isEmpty) {  // Fixed nullable check
              return SizedBox();
            }
            return Divider(height: height * 0.01);
          },
          itemCount: filteredContacts.length,
          itemBuilder: (BuildContext context, int index) {
            Contact c = filteredContacts[index];
            return ItemsTile(addToContacts, c, c.phones);
          },
        ),
      )
          : Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xffbe3a5a)))),
    );
  }

  addToContacts(Contact con) {
    bool alreadyInList = false;
    for (Contact c in _userSelectedContacts) {
      if (c.displayName != null && c.displayName == con.displayName) {
        alreadyInList = true;
        break;
      } else if (c.phones != null && c.phones!.isNotEmpty && c.phones!.contains(con.phones!.first)) {  // Fixed nullable check
        alreadyInList = true;
        break;
      }
    }
    if (!alreadyInList) {
      _userSelectedContacts.add(con);
      Fluttertoast.showToast(msg: "${_userSelectedContacts.length} contacts selected");
    } else {
      Fluttertoast.showToast(msg: "Contact already selected");
    }
  }

  String refactorPhoneNumbers(String phone) {
    if (phone.isEmpty) return "";
    var newPhone = phone.replaceAll(RegExp(r"[^\d]"), '');
    if (newPhone.length == 12) {
      return "+" + newPhone.substring(0, 12); // For international numbers
    }
    if (newPhone.length == 11 && newPhone.startsWith('3')) {
      return "+92" + newPhone.substring(1); // For Pakistani numbers
    }
    return newPhone; // Default, returns the phone as is
  }
}

class ItemsTile extends StatefulWidget {
  ItemsTile(this.addToContacts, this.c, this._items);
  final Function addToContacts;
  final Contact c;
  final List<Item>? _items;

  @override
  _ItemsTileState createState() => _ItemsTileState();
}

class _ItemsTileState extends State<ItemsTile> {
  String currentContact = '';

  @override
  void initState() {
    super.initState();
    currentContact = '';
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return widget._items == null || widget._items!.isEmpty
        ? SizedBox()
        : WidgetAnimator(
      Card(
        child: ListTile(
          onTap: () {
            widget.addToContacts(widget.c);
            FocusScope.of(context).unfocus();
          },
          leading: CircleAvatar(
            backgroundColor: Color(0xffbe3a5a),
            child: Text(
              widget.c.displayName?.isNotEmpty ?? false
                  ? '${widget.c.displayName?[0].toUpperCase()}'
                  : '',
              style: TextStyle(color: Colors.white),
            ),
            radius: height * 0.025,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.c.displayName ?? "",
                style: TextStyle(color: Colors.black, fontSize: height * 0.022),
              ),
              SizedBox(height: height * 0.01),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget._items?.map((i) {
                  if (currentContact == i.value?.replaceAll(" ", "")) {
                    return SizedBox();
                  }
                  currentContact = i.value?.replaceAll(" ", "") ?? "";
                  return Text(
                    i.value ?? i.label ?? "",
                    style: TextStyle(color: Colors.grey[600]),
                  );
                }).toList() ?? [],
              )
            ],
          ),
          trailing: Text('Tap to Select', style: TextStyle(color: Colors.grey[400])),
        ),
      ),
    );
  }
}
