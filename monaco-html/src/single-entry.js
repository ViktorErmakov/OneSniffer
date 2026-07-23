/* Single-file Monaco entry for 1C HTML field (same window API as multi-file editor.js). */
import * as monaco from 'monaco-editor/esm/vs/editor/editor.api';
import 'monaco-editor/esm/vs/editor/editor.all.js';
import 'monaco-editor/esm/vs/language/json/monaco.contribution';
import 'monaco-editor/esm/vs/basic-languages/xml/xml.contribution';
import editorCss from 'monaco-editor/min/vs/editor/editor.main.css';

(function (root) {
  'use strict';

  var editor = null;
  var pendingValue = '';
  var pendingLanguage = 'plaintext';
  var pendingReadOnly = false;
  var pendingOptions = {};
  var container = null;
  var restLanguageId = 'rest';
  var bslLanguageId = 'bsl';

  function injectCss(cssText) {
    if (typeof document === 'undefined' || !cssText) {
      return;
    }
    var style = document.createElement('style');
    style.setAttribute('data-onesniffer-monaco', '1');
    style.textContent = cssText;
    document.head.appendChild(style);
  }

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
  }

  function registerBslLanguage(monacoApi) {
    monacoApi.languages.register({ id: bslLanguageId });
    monacoApi.languages.setMonarchTokensProvider(bslLanguageId, {
      ignoreCase: true,
      defaultToken: '',
      keywords: [
        'если', 'тогда', 'иначеесли', 'иначе', 'конецесли',
        'пока', 'цикл', 'для', 'каждого', 'из', 'по', 'конеццикла',
        'процедура', 'функция', 'конецпроцедуры', 'конецфункции',
        'возврат', 'продолжить', 'прервать', 'перейти',
        'попытка', 'исключение', 'конецпопытки', 'вызватьисключение',
        'новый', 'неопределено', 'истина', 'ложь', 'null',
        'и', 'или', 'не', 'экспорт', 'знач', 'перем',
        'выполнить', 'область', 'конецобласти',
      ],
      typeKeywords: [
        'число', 'строка', 'дата', 'булево', 'массив', 'структура',
        'соответствие', 'таблицазначений', 'деревозначений',
        'списокзначений', 'хранилищезначения',
      ],
      operators: ['=', '<>', '<', '>', '<=', '>=', '+', '-', '*', '/', '%'],
      symbols: /[=><!~?:&|+\-*\/\^%]+/,
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

  function defaultOptions() {
    return {
      theme: 'vs',
      fontSize: 15,
      wordWrap: 'on',
      minimap: { enabled: false },
      lineNumbers: 'on',
      folding: true,
      automaticLayout: true,
      scrollBeyondLastLine: false,
      readOnly: false,
      tabSize: 4,
      formatOnPaste: true,
    };
  }

  function refreshLayout() {
    if (!editor) {
      return;
    }
    monaco.editor.remeasureFonts();
    editor.layout();
    editor.render(true);
  }

  function createEditor() {
    if (editor) {
      return editor;
    }
    container = document.getElementById('container');
    var options = Object.assign({}, defaultOptions(), pendingOptions, {
      value: pendingValue,
      language: pendingLanguage,
      readOnly: pendingReadOnly,
    });
    var theme = options.theme || 'vs';
    delete options.theme;
    editor = monaco.editor.create(container, options);
    monaco.editor.setTheme(theme);
    refreshLayout();
    return editor;
  }

  function setLanguageId(language) {
    pendingLanguage = language || 'plaintext';
    if (editor) {
      monaco.editor.setModelLanguage(editor.getModel(), pendingLanguage);
    }
  }

  function applyOptionsObject(options) {
    options = options || {};
    pendingOptions = Object.assign({}, pendingOptions, options);
    if (!editor) {
      return;
    }
    var forUpdate = Object.assign({}, pendingOptions);
    var theme = forUpdate.theme;
    delete forUpdate.theme;
    editor.updateOptions(forUpdate);
    if (theme) {
      monaco.editor.setTheme(theme);
    }
  }

  function init(options) {
    options = options || {};
    if (typeof options === 'string') {
      options = {};
    }
    pendingOptions = Object.assign({}, pendingOptions, options);
    createEditor();
    if (options.theme) {
      monaco.editor.setTheme(options.theme);
    } else if (pendingOptions.theme) {
      monaco.editor.setTheme(pendingOptions.theme);
    }
    return true;
  }

  function updateText(text) {
    pendingValue = text == null ? '' : String(text);
    if (!editor) {
      createEditor();
    }
    editor.setValue(pendingValue);
    refreshLayout();
  }

  function setContent(text) {
    updateText(text);
  }

  function getText() {
    return editor ? editor.getValue() : pendingValue;
  }

  function eraseText() {
    updateText('');
  }

  function setReadOnly(value) {
    pendingReadOnly = !!value;
    if (editor) {
      editor.updateOptions({ readOnly: pendingReadOnly });
    }
  }

  function getReadOnly() {
    return pendingReadOnly;
  }

  function setLanguageMode(language) {
    setLanguageId(language);
  }

  function setTheme(theme) {
    pendingOptions.theme = theme || 'vs';
    if (editor) {
      monaco.editor.setTheme(pendingOptions.theme);
    }
  }

  function setFontSize(size) {
    applyOptionsObject({ fontSize: Number(size) || 15 });
  }

  function minimap(enabled) {
    applyOptionsObject({ minimap: { enabled: !!enabled } });
  }

  function wordWrap(enabled) {
    applyOptionsObject({ wordWrap: enabled ? 'on' : 'off' });
  }

  function showLineNumbers() {
    applyOptionsObject({ lineNumbers: 'on' });
  }

  function hideLineNumbers() {
    applyOptionsObject({ lineNumbers: 'off' });
  }

  function setOption(name, value) {
    var patch = {};
    patch[name] = value;
    applyOptionsObject(patch);
  }

  function getOption(name) {
    if (pendingOptions[name] !== undefined) {
      return pendingOptions[name];
    }
    if (editor) {
      return editor.getOption(name);
    }
    return undefined;
  }

  function formatDocument() {
    if (!editor) {
      return;
    }
    var model = editor.getModel();
    var languageId = model.getModeId ? model.getModeId() : model.getLanguageId();
    if (languageId === 'json') {
      var action = editor.getAction('editor.action.formatDocument');
      if (action) {
        action.run();
      }
    }
  }

  function applyState(data) {
    if (!data || typeof data !== 'object') {
      return;
    }
    if (data.options) {
      applyOptionsObject(data.options);
    }
    if (data.language !== undefined) {
      setLanguageMode(data.language);
    }
    if (data.readOnly !== undefined) {
      setReadOnly(data.readOnly);
    }
    if (data.text !== undefined) {
      updateText(data.text);
    }
  }

  injectCss(typeof editorCss === 'string' ? editorCss : '');
  registerRestLanguage(monaco);
  registerBslLanguage(monaco);
  self.MonacoEnvironment = {
    getWorker: function () {
      return {
        postMessage: function () {},
        addEventListener: function () {},
        removeEventListener: function () {},
        terminate: function () {},
      };
    },
  };

  root.OneSnifferMonacoBootstrap = function () {
    createEditor();
    root.init = init;
    root.updateText = updateText;
    root.setContent = setContent;
    root.getText = getText;
    root.eraseText = eraseText;
    root.setReadOnly = setReadOnly;
    root.getReadOnly = getReadOnly;
    root.setLanguageMode = setLanguageMode;
    root.setTheme = setTheme;
    root.setFontSize = setFontSize;
    root.minimap = minimap;
    root.wordWrap = wordWrap;
    root.showLineNumbers = showLineNumbers;
    root.hideLineNumbers = hideLineNumbers;
    root.setOption = setOption;
    root.getOption = getOption;
    root.formatDocument = formatDocument;
    root.applyState = applyState;
    if (container) {
      container.setAttribute('data-monaco-ready', '1');
    }
  };

  if (typeof document !== 'undefined') {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', function () {
        root.OneSnifferMonacoBootstrap();
      });
    } else {
      root.OneSnifferMonacoBootstrap();
    }
  }

  root.addEventListener('resize', function () {
    refreshLayout();
  });

  var lastW = 0;
  var lastH = 0;
  setInterval(function () {
    if (!editor || !container) {
      return;
    }
    var w = container.clientWidth;
    var h = container.clientHeight;
    if (w !== lastW || h !== lastH) {
      lastW = w;
      lastH = h;
      refreshLayout();
    }
  }, 300);
})(typeof self !== 'undefined' ? self : this);
