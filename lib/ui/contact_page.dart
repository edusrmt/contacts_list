import 'dart:io';

import 'package:contacts_list/domain/contact.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  Contact contact;

  //construtor que inicia o contato.
  //Entre chaves porque é opcional.
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact _editedContact;
  bool _userEdited;

  //para garantir o foco no nome
  final _nomeFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();

  //controladores
  TextEditingController nomeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    //acessando o contato definido no widget(ContactPage)
    //mostrar se ela for privada
    if (widget.contact == null)
      _editedContact = Contact();
    else {
      _editedContact = Contact.fromMap(widget.contact.toMap());
      nomeController.text = _editedContact.name;
      emailController.text = _editedContact.email;
      phoneController.text = _editedContact.phone;
    }
  }

  Future<bool> _requestPop() {
    if (_userEdited != null && _userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "Abandonar alteração?",
                style: TextStyle(color: Colors.white),
              ),
              content: Text("Os dados serão perdidos.",
                  style: TextStyle(color: Colors.grey[50])),
              backgroundColor: Colors.grey[800],
              actions: <Widget>[
                FlatButton(
                    child: Text("NÃO",
                        style: TextStyle(color: Colors.indigo[900])),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                FlatButton(
                  child:
                      Text("SIM", style: TextStyle(color: Colors.indigo[900])),
                  onPressed: () {
                    //desempilha 2x
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    } else {
      return Future.value(true);
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    //com popup de confirmação
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          title: Text(_editedContact.name ?? "Novo contato"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact.name == null || _editedContact.name.isEmpty) {
              FocusScope.of(context).requestFocus(_nomeFocus);
            } else if (_editedContact.email == null ||
                _editedContact.email.isEmpty ||
                !_editedContact.email.contains('@')) {
              FocusScope.of(context).requestFocus(_emailFocus);
            } else if (_editedContact.phone == null ||
                _editedContact.phone.isEmpty) {
              FocusScope.of(context).requestFocus(_phoneFocus);
            } else {
              Navigator.pop(context, _editedContact);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.indigo[900],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                    width: 140.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: _editedContact.img != null
                                ? FileImage(File(_editedContact.img))
                                : AssetImage("images/person.png")))),
                onTap: () {
                  ImagePicker()
                      .getImage(source: ImageSource.camera, imageQuality: 50)
                      .then((file) {
                    if (file == null)
                      return;
                    else {
                      setState(() {
                        _editedContact.img = file.path;
                      });
                    }
                  });
                },
              ),
              TextField(
                controller: nomeController,
                focusNode: _nomeFocus,
                decoration: InputDecoration(
                    labelText: "Nome",
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.indigo[800])),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.indigo[700], width: 2.5))),
                style: TextStyle(color: Colors.grey[50]),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
              ),
              TextField(
                controller: emailController,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: "E-mail",
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.indigo[800])),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.indigo[700], width: 2.5))),
                style: TextStyle(color: Colors.grey[50]),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.email = text;
                },
              ),
              TextField(
                controller: phoneController,
                focusNode: _phoneFocus,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    labelText: "Telefone",
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.indigo[800])),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.indigo[700], width: 2.5))),
                style: TextStyle(color: Colors.grey[50]),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.phone = text;
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
