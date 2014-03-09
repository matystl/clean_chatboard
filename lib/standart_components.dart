library standartComponents;

import "package:react/react.dart";
import 'package:clean_data/clean_data.dart';

InputType mI = Input.register(/*constructor param*/);

typedef InputType({String id, String type, String className, value, String placeholder, bool readOnly, Function onChange, Function onBlur, String name});

class Input extends Component {
  static InputType register(/*constructor param*/) {
    var _registeredComponent = registerComponent(() => new Input(/*constructor param*/));
    return ({String id:null, String type:'text', String className:'', value:null,
      String placeholder:'', bool readOnly:false, onChange: null, onBlur: null, String name:''}) {

      //TODO maybe create it
      assert(value is DataReference);

      return _registeredComponent({
        'id': id,
        'type' : type,
        'name': name,
        'className': className,
        'placeholder': placeholder,
        'value': value,
        'readOnly' : readOnly,
        'onChange': onChange,
        'onBlur': onBlur
      },null);
    };
  }

  onChange(e) {
    var value = e.target.value;
    if (props['type'] == 'checkbox') value = e.target.checked;
    if (props['readOnly']) return;
    props['value'].value = value;
    redraw();
    if (props['onChange'] != null) props['onChange'](value);
  }

  onBlur(e) {
    if (props['onBlur'] != null)  props['onBlur'](e.target.value);
  }

  render() {
    return input({
      'id': props['id'],
      'type': props['type'],
      'name': props['name'],
      'placeholder': props['placeholder'],
      'className': props['inputClass'],
      'checked': (props['type'] == 'checkbox')?props['value'].value:null,
      'value': props['value'].value,
      'onChange': onChange,
      'onBlur': onBlur
    });
  }
}

mButton({String className:'',Function onClick:null, String content:'', bool isDisabled: false}) =>
    span({'className': 'myButton',  'onClick': (e) => (onClick==null || isDisabled)?null:onClick()}, content);