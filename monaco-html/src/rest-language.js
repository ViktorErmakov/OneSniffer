/* global monaco */
(function (root) {
  'use strict';

  var restLanguageId = 'rest';

  function registerRestLanguage(monacoApi) {
    monacoApi.languages.register({ id: restLanguageId });

    monacoApi.languages.setMonarchTokensProvider(restLanguageId, {
      ignoreCase: true,
      tokenizer: {
        root: [
          [/^\s*###.*$/, 'comment'],
          [/^\s*#.*$/, 'comment'],
          [/^\s*\/\/.*$/, 'comment'],
          [/^(GET|POST|PUT|PATCH|DELETE|HEAD|OPTIONS)\b/, 'keyword'],
          [/https?:\/\/[^\s]+/, 'string'],
          [/^\s*[A-Za-z0-9\-]+:/, 'type'],
          [/\{\{[^}]+\}\}/, 'variable'],
          [/"([^"\\]|\\.)*"/, 'string'],
          [/'([^'\\]|\\.)*'/, 'string'],
        ],
      },
    });

    monacoApi.languages.registerCompletionItemProvider(restLanguageId, {
      triggerCharacters: [' ', ':'],
      provideCompletionItems: function () {
        var suggestions = [
          { label: 'GET', kind: monacoApi.languages.CompletionItemKind.Keyword, insertText: 'GET ' },
          { label: 'POST', kind: monacoApi.languages.CompletionItemKind.Keyword, insertText: 'POST ' },
          { label: 'PUT', kind: monacoApi.languages.CompletionItemKind.Keyword, insertText: 'PUT ' },
          { label: 'PATCH', kind: monacoApi.languages.CompletionItemKind.Keyword, insertText: 'PATCH ' },
          { label: 'DELETE', kind: monacoApi.languages.CompletionItemKind.Keyword, insertText: 'DELETE ' },
          {
            label: 'Content-Type',
            kind: monacoApi.languages.CompletionItemKind.Property,
            insertText: 'Content-Type: application/json',
          },
          {
            label: 'Authorization',
            kind: monacoApi.languages.CompletionItemKind.Property,
            insertText: 'Authorization: Bearer ',
          },
          {
            label: '{{$guid}}',
            kind: monacoApi.languages.CompletionItemKind.Snippet,
            insertText: '{{$guid}}',
          },
          {
            label: '{{$time}}',
            kind: monacoApi.languages.CompletionItemKind.Snippet,
            insertText: '{{$time}}',
          },
        ];
        return { suggestions: suggestions };
      },
    });
  }

  root.registerRestLanguage = registerRestLanguage;
  root.restLanguageId = restLanguageId;
})(typeof self !== 'undefined' ? self : this);
