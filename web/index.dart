library player_list;

import 'dart:async';
import 'dart:html';

import 'package:clean_ajax/client_browser.dart';
import 'package:clean_data/clean_data.dart';
import 'package:clean_sync/client.dart';
import 'package:intl/intl.dart';
import 'package:react/react_client.dart' as react;
import "package:react/react.dart";

import 'package:chatboard/validators.dart';
import 'package:chatboard/standart_components.dart';

Connection connection;
Subscriber subscriber;
Map<String, Subscription> subscriptions = {};

main() {
  react.setClientConfiguration();
  connection = createHttpConnection("/resources/", new Duration(milliseconds: 200));
  subscriber = new Subscriber(connection);
  subscriber.init().then((_) {
      var cPage = Page.register();
      renderComponent(cPage(), querySelector('#page'));
  }).catchError((e) {
    print(e);
  });
}

class Page extends Component {
  static register() {
    var _registeredComponent = registerComponent(() => new Page());
    return () => _registeredComponent({});
  }

  sellectSubs(subscription){
    if (subscriptions[subscription] == null)
      subscriptions[subscription] = subscriber.subscribe(subscription);
    selectedCollection = subscriptions[subscription].collection;
    if (selectedCollectionSS != null) selectedCollectionSS.cancel();
    selectedCollectionSS = selectedCollection.onChange.listen((_) { print('onChange');redraw();});
    redraw();
  }
  DataSet selectedCollection;
  StreamSubscription selectedCollectionSS;

  DataReference name;
  DataReference text;
  get enableSend => isTextValid(text.value) && isNameValid(name.value);

  componentWillMount(){
    sellectSubs('board1');

    name =  new DataReference('name');
    name.onChange.listen((_)=> redraw());

    text = new DataReference('text');
    text.onChange.listen((_)=> redraw());
  }


  addEntry(name, text) {
    selectedCollection.add({'name': name.value, 'text':text.value, 'added': new DateTime.now().millisecondsSinceEpoch});
  }

  render() {
    var sorted = selectedCollection.toList()
        ..sort((e1,e2)=>(e1['added'] > e2['added'])?1:-1);
   return div({},[
     cChoser(sellectSubs),
     cNewEntry(name, text, enableSend, addEntry),
     div({},
         sorted.map(cItem)
     )
   ]);
  }
}

cChoser(selectSubs) =>
  div({},[
    mButton(onClick: () => selectSubs('board1'), content: 'board1'),
    '  ',
    mButton(onClick: () => selectSubs('board2'), content: 'board2'),
  ]);

cNewEntry(name, text, enableSend, addEntry) =>
  div({},[
    span({},'Name:'),
    mI(value: name),
    span({},'Text:'),
    mI(value: text),
    mButton(onClick: () =>addEntry(name, text),
        content: (enableSend)?'send':'send not allowed',
        isDisabled:!enableSend),
  ]);


var cItem = Item.register();
class Item extends Component {
  static register() {
    var _registeredComponent = registerComponent(() => new Item());
    return (item) => _registeredComponent({'data':item});
  }
  Map get data => props['data'];

  var formater = new DateFormat('dd.MM.yyyy HH:mm:ss');
  render() {
    return div({},[
      span({}, formater.format(new DateTime.fromMillisecondsSinceEpoch(data['added']))),
      '  ',
      b({},data['name']),
      ': ',
      data['text'],
    ]);
  }
}
