library validators;

isTextValid(String text) => text.length < 30;

isNameValid(String name) => name.toLowerCase() == name;