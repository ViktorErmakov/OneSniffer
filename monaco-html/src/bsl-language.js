/* global monaco */
(function (root) {
  'use strict';

  var bslLanguageId = 'bsl';

  // Лёгкая подсветка BSL без метаданных конфигурации / bslGlobals.
  function registerBslLanguage(monacoApi) {
    monacoApi.languages.register({ id: bslLanguageId });

    monacoApi.languages.setMonarchTokensProvider(bslLanguageId, {
      ignoreCase: true,
      defaultToken: '',
      tokenPostfixRules: ['.bsl'],
      keywords: [
        'если', 'тогда', 'иначеесли', 'иначе', 'конецесли',
        'пока', 'цикл', 'для', 'каждого', 'из', 'по', 'конеццикла',
        'процедура', 'функция', 'конецпроцедуры', 'конецфункции',
        'возврат', 'продолжить', 'прервать', 'перейти',
        'попытка', 'исключение', 'конецпопытки', 'вызватьисключение',
        'новый', 'неопределено', 'истина', 'ложь', 'null',
        'и', 'или', 'не', 'экспорт', 'знач', 'перем', 'счётчик',
        'выполнить', 'добавитьобработчик', 'удалитьобработчик',
        'область', 'конецобласти',
      ],
      typeKeywords: [
        'число', 'строка', 'дата', 'булево', 'массив', 'структура',
        'соответствие', 'таблицазначений', 'деревозначений',
        'списокзначений', 'хранилищезначения',
      ],
      operators: ['=', '<>', '<', '>', '<=', '>=', '+', '-', '*', '/', '%'],
      symbols: /[=><!~?:&|+\-*\/\^%]+/,
      escapes: /\\(?:[abfnrtv\\"']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})/,
      tokenizer: {
        root: [
          [/\/\/.*$/, 'comment'],
          [/#.*$/, 'metatag'],
          [/\|.*$/, 'string'],
          [/"([^"\\]|\\.)*"/, 'string'],
          [/'([^'\\]|\\.)*'/, 'string'],
          [/\b\d+(\.\d+)?\b/, 'number'],
          [
            /[а-яёa-z_][\wа-яё]*/i,
            {
              cases: {
                '@keywords': 'keyword',
                '@typeKeywords': 'type',
                '@default': 'identifier',
              },
            },
          ],
          [/@symbols/, { cases: { '@operators': 'operator', '@default': '' } }],
          [/[{}()\[\]]/, '@brackets'],
          [/[,;.]/, 'delimiter'],
        ],
      },
    });
  }

  root.registerBslLanguage = registerBslLanguage;
  root.bslLanguageId = bslLanguageId;
})(typeof self !== 'undefined' ? self : this);
