import 'dart:io';

import 'package:contacts_list/domain/contact.dart';
import 'package:contacts_list/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'contact_page.dart';

//enum para opções de ordenação.
enum OrderOptions { orderAz, orderZa }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contatos = List();

  //carregando a lista de contatos do banco ao iniciar o app
  @override
  void initState() {
    super.initState();
    //then retorna um futuro e coloca em list
    updateList();
  }

  void updateList() {
    helper.getAllContact().then((list) {
      //atualizando a lista de contatos na tela
      setState(() {
        contatos = list;
      });
    });
  }

  void sortList(OrderOptions option) {
    List<Contact> contatosSort = contatos;

    switch (option) {
      case OrderOptions.orderAz:
        {
          contatos.sort((a, b) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
        }
        break;

      case OrderOptions.orderZa:
        {
          contatos.sort((b, a) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
        }
        break;
    }

    setState(() {
      contatos = contatosSort;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Contatos",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
              icon: Icon(Icons.sort_by_alpha),
              onSelected: sortList,
              color: Colors.grey[800],
              itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
                    PopupMenuItem<OrderOptions>(
                        value: OrderOptions.orderAz,
                        child: Text(
                          "A \u{2192} Z",
                          style: TextStyle(color: Colors.grey[50]),
                        )),
                    PopupMenuItem<OrderOptions>(
                        value: OrderOptions.orderZa,
                        child: Text(
                          "Z \u{2192} A",
                          style: TextStyle(color: Colors.grey[50]),
                        ))
                  ]),
        ],
      ),
      backgroundColor: Colors.black87,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.indigo[900],
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: contatos.length,
          itemBuilder: (context, index) {
            return _contatoCard(context, index);
          }),
    );
  }

  /// Função para criação de um card de contato para lista.
  Widget _contatoCard(BuildContext context, int index) {
    return GestureDetector(
        child: Card(
          color: Colors.grey[850],
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 70.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: contatos[index].img != null
                              ? FileImage(File(contatos[index].img))
                              : AssetImage("images/person.png"))),
                ),
                Flexible(
                    child: Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      //se não existe nome, joga vazio
                      Text(
                        contatos[index].name ?? "",
                        style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(
                        contatos[index].email ?? "",
                        style:
                            TextStyle(fontSize: 16.0, color: Colors.grey[50]),
                      ),
                      Text(
                        contatos[index].phone ?? "",
                        style:
                            TextStyle(fontSize: 16.0, color: Colors.grey[50]),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
        onTap: () {
          _showOptions(context, index);
        });
  }

  //mostra as opções
  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            //onclose obrigatório. Não fará nada
            onClosing: () {},
            backgroundColor: Colors.grey[800],
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  //ocupa o mínimo de espaço.
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.all(10.0),
                        child: FlatButton(
                            child: Text("ligar",
                                style: TextStyle(
                                    color: Colors.indigo[900], fontSize: 20.0)),
                            onPressed: () {
                              launch("tel:${contatos[index].phone}");
                              Navigator.pop(context);
                            })),
                    Padding(
                        padding: EdgeInsets.all(10.0),
                        child: FlatButton(
                            child: Text("editar",
                                style: TextStyle(
                                    color: Colors.indigo[900], fontSize: 20.0)),
                            onPressed: () {
                              Navigator.pop(context);
                              _showContactPage(contact: contatos[index]);
                            })),
                    Padding(
                        padding: EdgeInsets.all(10.0),
                        child: FlatButton(
                            child: Text("excluir",
                                style: TextStyle(
                                    color: Colors.indigo[900], fontSize: 20.0)),
                            onPressed: () {
                              helper.deleteContact(contatos[index].id);
                              updateList();
                              Navigator.pop(context);
                            }))
                  ],
                ),
              );
            },
          );
        });
  }

  //mostra o contato. Parâmetro opcional
  void _showContactPage({Contact contact}) async {
    Contact contatoRet = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));

    if (contatoRet != null) {
      print(contatoRet.id);
      if (contatoRet.id == null)
        await helper.saveContact(contatoRet);
      else
        await helper.updateContact(contatoRet);

      updateList();
    }
  }
}
