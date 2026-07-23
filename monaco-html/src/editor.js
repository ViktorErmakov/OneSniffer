/* global monaco, registerRestLanguage, registerBslLanguage */
(function (root) {
  'use strict';

  var editor = null;
  var pendingValue = '';
  var pendingLanguage = 'plaintext';
  var pendingReadOnly = false;
  var pendingOptions = {};
  var container = null;

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

  // --- Public API (стиль bsl_console) ---

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

  root.OneSnifferMonacoBootstrap = function (monacoApi) {
    if (typeof registerRestLanguage === 'function') {
      registerRestLanguage(monacoApi);
    }
    if (typeof registerBslLanguage === 'function') {
      registerBslLanguage(monacoApi);
    }
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
