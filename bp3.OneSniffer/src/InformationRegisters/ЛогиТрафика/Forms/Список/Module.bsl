
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	НастройкиЛогирования = ЛогированиеТрафика.ЗагрузитьНастройкиЛогирования();
	Если НастройкиЛогирования.ВключеноЛогирование 
		И НастройкиЛогирования.ПолучениеИсключенийВключено Тогда
		
		Если НастройкиЛогирования.ПолучатьИсключенияФЗ Тогда
			
			
			
		Иначе
			
			ДатаНачала = Константы.OneSniffer_ДатаЧтенияЖР.Получить();
			
			ТаблицаЗаписей = Новый ТаблицаЗначений();
			Отбор = Новый Структура;
			Отбор.Вставить("Событие", ЛогированиеТрафика.СобытиеВызватьHTTPМетод());
			Отбор.Вставить("ДатаНачала", ДатаНачала);
			ВыгрузитьЖурналРегистрации(ТаблицаЗаписей, Отбор);
			Для Каждого СтрокаЗаписиЖР Из ТаблицаЗаписей Цикл
				
				СохраненныйЛогЗапроса = ЛогированиеТрафика.ЗначениеИзСтрокиJSON(СтрокаЗаписиЖР.Данные, Ложь, "Дата"); // см. РегистрыСведений.ЛогиТрафика.НовыйЛогЗапроса
				Если СохраненныйЛогЗапроса = Неопределено Тогда
					Возврат;
				КонецЕсли;
				
				СохраненныйЛогЗапроса.Метод = Перечисления.МетодHTTP[СохраненныйЛогЗапроса.Метод];
				ЛогЗапроса = РегистрыСведений.ЛогиТрафика.СтруктураМенеджераЗаписи();
				ЗаполнитьЗначенияСвойств(ЛогЗапроса, СохраненныйЛогЗапроса);
				
				РегистрыСведений.ЛогиТрафика.ЗаписатьЛог(ЛогЗапроса);
				
			КонецЦикла;
			
			ДатаОкончания = ТекущаяДатаСеанса();
			Константы.OneSniffer_ДатаЧтенияЖР.Установить(ДатаОкончания);
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ИзменитьВидимостьДоступность();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПериодПриИзменении(Элемент)
	
	ГруппаОтбораСписка = Неопределено;
	Для каждого ЭлементКоллекции Из Список.Отбор.Элементы Цикл
		Если ЭлементКоллекции.ИдентификаторПользовательскойНастройки = "Дата" Тогда
			ГруппаОтбораСписка = ЭлементКоллекции;
			ГруппаОтбораСписка.Использование = Истина;
		КонецЕсли;
	КонецЦикла;
	
	Если ГруппаОтбораСписка = Неопределено Тогда
		ГруппаОтбораСписка = Список.Отбор.Элементы.Добавить(Тип("ГруппаЭлементовОтбораКомпоновкиДанных"));
		ГруппаОтбораСписка.ТипГруппы = ТипГруппыЭлементовОтбораКомпоновкиДанных.ГруппаИ;
		ГруппаОтбораСписка.ИдентификаторПользовательскойНастройки = "Дата";
		ГруппаОтбораСписка.Использование = Истина;
	ИначеЕсли Период.ДатаНачала = '00010101' И Период.ДатаОкончания = '00010101' Тогда
		ГруппаОтбораСписка.Использование = Ложь;
		Возврат;
	КонецЕсли;
	
	// Очистка всех дат.
	Для каждого ЭлементОтбораДанных Из ГруппаОтбораСписка.Элементы Цикл
		Если ЭлементОтбораДанных.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Дата") Тогда
			ГруппаОтбораСписка.Элементы.Удалить(ЭлементОтбораДанных);
		КонецЕсли;
	КонецЦикла;
	
	ЭлементОтбораДанных = ГруппаОтбораСписка.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	
	ЭлементОтбораДанных.ЛевоеЗначение  = Новый ПолеКомпоновкиДанных("Дата");
	ЭлементОтбораДанных.ВидСравнения   = ВидСравненияКомпоновкиДанных.БольшеИлиРавно;
	ЭлементОтбораДанных.ПравоеЗначение = Период.ДатаНачала;
	ЭлементОтбораДанных.Использование  = Истина;
	
	ЭлементОтбораДанных = ГруппаОтбораСписка.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбораДанных.ЛевоеЗначение  = Новый ПолеКомпоновкиДанных("Дата");
	ЭлементОтбораДанных.ВидСравнения   = ВидСравненияКомпоновкиДанных.МеньшеИлиРавно;
	ЭлементОтбораДанных.ПравоеЗначение = КонецДня(Период.ДатаОкончания);
	ЭлементОтбораДанных.Использование  = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура ПроизвольныйЗапросПриИзменении(Элемент)
	
	Модифицированность = Истина;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыСписок

&НаКлиенте
Процедура СписокПриАктивизацииСтроки(Элемент)
	
	Если ТекущаяСтрокаСписка = Элементы.Список.ТекущаяСтрока Тогда
		Возврат;
	КонецЕсли;
	
	ПодключитьОбработчикОжидания("СписокПриАктивизацииСтрокиПродолжение", 0.1, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура СписокВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ПоказыватьПроизвольныйЗапрос = Истина;
	ПрочитатьТекущийЗапрос(ВыбраннаяСтрока, ПоказыватьПроизвольныйЗапрос);
	ТекущийЭлемент = Элементы.ПроизвольныйЗапрос;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СохранитьЛогиВФайл(Команда)
	
	АдресХранилища = ПоместитьВоВременноеХранилище(Неопределено, УникальныйИдентификатор);
	СохранитьНаСервере(Элементы.Список.ВыделенныеСтроки, АдресХранилища);
	СохранитьЛогиВФайлПродолжение(АдресХранилища);
	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьПроизвольныйЗапрос(Команда)
	
	АдресХранилища = ПоместитьВоВременноеХранилище(ПроизвольныйЗапрос.ПолучитьТекст());
	СохранитьЛогиВФайлПродолжение(АдресХранилища);
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьПроизвольныйЗапрос(Команда)
	
	ОткрытьПроизвольныйЗапросПродолжение();
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФормуНастроек(Команда)
	
	ОткрытьФорму("РегистрСведений.ЛогиТрафика.Форма.Настройки",, ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьСодержание(Команда)
	
	ПоказыватьДанные = Не ПоказыватьДанные;
	
	Если ПоказыватьДанные Тогда
		СписокПриАктивизацииСтроки(Команда);
	КонецЕсли;
	
	ИзменитьВидимостьДоступность();
	
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьПроизвольныйЗапрос(Команда)
	
	ПоказыватьПроизвольныйЗапрос = Не ПоказыватьПроизвольныйЗапрос;
	
	ТекущаяСтрока = Элементы.Список.ТекущаяСтрока;
	ПрочитатьТекущийЗапрос(ТекущаяСтрока, ПоказыватьПроизвольныйЗапрос);
	
	Если ПоказыватьПроизвольныйЗапрос = Ложь Тогда
		Модифицированность = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьПроизвольныйЗапрос(Команда)
	
	НоваяСтрока = Неопределено;
	Отказ = Ложь;
	ТекстОшибки = "";
	
	ВыполнитьЗапросПоСтроке(ПроизвольныйЗапрос.ПолучитьТекст(), Отказ, ТекстОшибки, НоваяСтрока);
	
	Если Не Отказ Тогда
		Элементы.Список.Обновить();
		Элементы.Список.ТекущаяСтрока = НоваяСтрока;
	КонецЕсли;
	
	Если Не ПустаяСтрока(ТекстОшибки) Тогда
		ПоказатьПредупреждение(, ТекстОшибки);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПросмотрЛогов(Команда)
	
	АдресХранилища = ПоместитьВоВременноеХранилище(Неопределено, УникальныйИдентификатор);
	СохранитьНаСервере(Элементы.Список.ВыделенныеСтроки, АдресХранилища);
	ПараметрыОткрытия = Новый Структура;
	ПараметрыОткрытия.Вставить("АдресХранилища", АдресХранилища);
	ПараметрыОткрытия.Вставить("Заголовок", Элементы.Список.ТекущиеДанные.Событие + " ("
		+ Элементы.Список.ТекущиеДанные.Дата + ")");
	
	ОткрытьФорму("РегистрСведений.ЛогиТрафика.Форма.Просмотр", ПараметрыОткрытия, ЭтотОбъект,
		Новый УникальныйИдентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура ОчиститьПроизвольныйЗапрос(Команда)
	
	ПроизвольныйЗапрос.Очистить();
	Модифицированность = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьЦвет(Команда)
	
	Цвет = 0;
	ИмяЦвета = СтрЗаменить(Команда.Имя, "УстановитьЦвет", "");
	КодЦвета = КодЦветаПоИмени(ИмяЦвета);
	
	ПараметрыЗаписи = Новый Структура;
	ПараметрыЗаписи.Вставить("Цвет", КодЦвета);
	УстановитьЗначениеРеквизитовЛогаЗаписи(Элементы.Список.ВыделенныеСтроки, ПараметрыЗаписи);
	
	Элементы.Список.Обновить();
	
КонецПроцедуры

&НаКлиенте
Процедура УдалитьВсеЗаписи(Команда)
	
	ОбработкаОповещения = Новый ОписаниеОповещения("УдалитьВсеЗаписиПродолжение", ЭтотОбъект);
	
	ПоказатьВопрос(ОбработкаОповещения, НСтр("ru = 'Будут удалены все строки логов. Продолжить?'"),
		РежимДиалогаВопрос.ДаНет);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗакрытьГруппуПроизвольногоЗапроса(Команда)
	
	ПоказыватьПроизвольныйЗапрос = Не ПоказыватьПроизвольныйЗапрос;
	ИзменитьВидимостьДоступность();
	
КонецПроцедуры

&НаКлиенте
Процедура ВставитьУникальныйИдентификатор(Команда)
	
	ВставитьТекстВЗапрос(Элементы.ПроизвольныйЗапрос, "{{$guid}}");
	
КонецПроцедуры

&НаКлиенте
Процедура ВставитьУникальноеВремя(Команда)
	
	ВставитьТекстВЗапрос(Элементы.ПроизвольныйЗапрос, "{{$time}}");
	
КонецПроцедуры

&НаКлиенте
Процедура КодироватьBase64(Команда)
	
	ВыделенныйТекст = Элементы.ПроизвольныйЗапрос.ВыделенныйТекст;
	Если ПустаяСтрока(ВыделенныйТекст) Тогда
		Возврат;
	КонецЕсли;
	
	Попытка
		ДвоичныеДанныеТекста = ПолучитьДвоичныеДанныеИзСтроки(ВыделенныйТекст);
		НовыйВыделенныйТекст = Base64Строка(ДвоичныеДанныеТекста);
		Элементы.ПроизвольныйЗапрос.ВыделенныйТекст = НовыйВыделенныйТекст;
	Исключение
		ОбщегоНазначенияКлиент.СообщитьПользователю("Не удалось кодировать выделенный текст");
	КонецПопытки;
	
КонецПроцедуры

&НаКлиенте
Процедура ДекодироватьBase64(Команда)
	
	ВыделенныйТекст = Элементы.ПроизвольныйЗапрос.ВыделенныйТекст;
	Если ПустаяСтрока(ВыделенныйТекст) Тогда
		Возврат;
	КонецЕсли;

	Попытка
		ДвоичныеДанныеТекста = Base64Значение(ВыделенныйТекст);
		НовыйВыделенныйТекст = ПолучитьСтрокуИзДвоичныхДанных(ДвоичныеДанныеТекста);
		Элементы.ПроизвольныйЗапрос.ВыделенныйТекст = НовыйВыделенныйТекст;
	Исключение
		ОбщегоНазначенияКлиент.СообщитьПользователю("Не удалось декодировать выделенный текст");
	КонецПопытки;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьЛогиИзФайла(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ЗагрузитьЛогиИзФайлаПродложение", ЭтотОбъект);
	
 	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	Диалог.Фильтр = НСтр("ru = 'Запросы rest'") + "(*.rest)|*.rest";
	Диалог.МножественныйВыбор = Ложь;
	Диалог.Расширение = "rest";
	Диалог.Заголовок = НСтр("ru = 'Выберите файл запросов rest'");
	Диалог.Показать(ОписаниеОповещения);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область ОбщаяФункциональность

&НаКлиенте
Процедура СохранитьЛогиВФайлПродолжение(ДополнительныеПараметры) Экспорт
	
	МассивФайлов = Новый Массив;
	ОписаниеФайла = Новый ОписаниеПередаваемогоФайла("", ДополнительныеПараметры);
	МассивФайлов.Добавить(ОписаниеФайла);
	
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);
	Диалог.Заголовок = НСтр("ru = 'Файл для сохранения'");
	Диалог.Расширение = "rest";
	Диалог.МножественныйВыбор = Ложь;
	Диалог.Фильтр = "Запросы rest (*.rest)|*.rest";
	
	ОписаниеОповещения = Новый ОписаниеОповещения();
	НачатьПолучениеФайлов(ОписаниеОповещения, МассивФайлов, Диалог);
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура СохранитьНаСервере(Знач ВыделенныеСтроки, АдресХранилища)
	
	ТаблицаСтрок = Новый ТаблицаЗначений;
	ТаблицаСтрок.Колонки.Добавить("ВремяНачала", Новый ОписаниеТипов("Число"));
	ТаблицаСтрок.Колонки.Добавить("Сервер",      Новый ОписаниеТипов("Строка"));
	ТаблицаСтрок.Колонки.Добавить("Метод",    Новый ОписаниеТипов("Строка"));
	Для каждого СтрокаСписка Из ВыделенныеСтроки Цикл
		НоваяСтрока = ТаблицаСтрок.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаСписка);
	КонецЦикла;
	ТаблицаСтрок.Сортировать("ВремяНачала");
	
	Текст = "";
	Для каждого ЭлементКоллекции Из ТаблицаСтрок Цикл
		Текст = Текст + ?(ПустаяСтрока(Текст), "", Символы.ПС + Символы.ПС)
			+ ЛогированиеТрафика.ПолучитьТекстЛога(ЭлементКоллекции, Истина);
	КонецЦикла;
	
	ПоместитьВоВременноеХранилище(Текст, АдресХранилища);
	
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьВидимостьДоступность()
	
	Элементы.ПоказатьСодержание.Пометка         = ПоказыватьДанные;
	Элементы.Содержание.Видимость               = ПоказыватьДанные;
	Элементы.ГруппаПроизвольныйЗапрос.Видимость = ПоказыватьПроизвольныйЗапрос;
	Элементы.ИзменитьЗапрос.Пометка             = ПоказыватьПроизвольныйЗапрос;

КонецПроцедуры

&НаКлиенте
Процедура УдалитьВсеЗаписиПродолжение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Да Тогда
		УдалитьВсеЗаписиЗавершение();
	КонецЕсли;
	
	Элементы.Список.Обновить();
	
КонецПроцедуры

&НаСервере
Процедура УдалитьВсеЗаписиЗавершение()
	
	НаборЗаписей = РегистрыСведений.ЛогиТрафика.СоздатьНаборЗаписей();
	НаборЗаписей.Записать(Истина);
	
	// Очистка элементов формы.
	СписокПриАктивизацииСтрокиНаСервере(Неопределено);
	
КонецПроцедуры

&НаСервере
Процедура УстановитьЗначениеРеквизитовЛогаЗаписи(Знач ВыделенныеСтроки, ПараметрыЗаписи)
	
	Для каждого ЭлементКоллекции Из ВыделенныеСтроки Цикл
		МенеджерЗаписи = РегистрыСведений.ЛогиТрафика.СоздатьМенеджерЗаписи();
		ЗаполнитьЗначенияСвойств(МенеджерЗаписи, ЭлементКоллекции);
		МенеджерЗаписи.Прочитать();
		Для каждого ЭлементКоллекции Из ПараметрыЗаписи Цикл
			МенеджерЗаписи[ЭлементКоллекции.Ключ] = ЭлементКоллекции.Значение;
		КонецЦикла;
		МенеджерЗаписи.Записать(Истина);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьТекстЛога(КлючЗаписи)
	
	Возврат ЛогированиеТрафика.ПолучитьТекстЛога(Элементы.Список.ТекущаяСтрока)
	
КонецФункции

&НаКлиенте
Процедура ЗагрузитьЛогиИзФайлаПродложение(МассивФайлов, ОбработчикЗавершения) Экспорт
	
	Если МассивФайлов = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ОбработкаОкончанияПомещения = Новый ОписаниеОповещения("ОбработчикОкончанияПомещения", ЭтотОбъект);	
	
	ИмяФайла = МассивФайлов[0];
	АдресХранилища = "";
	НачатьПомещениеФайла(ОбработкаОкончанияПомещения, АдресХранилища, ИмяФайла, Ложь, УникальныйИдентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработчикОкончанияПомещения(Результат, Адрес, ВыбранноеИмяФайла, ДополнительныеПараметры) Экспорт
	
	Если Не Результат Тогда
		Возврат;
	КонецЕсли;
	
	Отказ = Ложь;
	ТекстОшибки = "";
	ЗагрузитьЛогиИзФайлаНаСервере(Адрес, Отказ, ТекстОшибки);
	Если Отказ Тогда
		Сообщить(ТекстОшибки);
	КонецЕсли;
	
	Элементы.Список.Обновить();
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьЛогиИзФайлаНаСервере(Адрес, Отказ, ТекстОшибки)
	
	ЛогированиеТрафика.ЗагрузитьЛогиHTTPИзФайла(Адрес, Отказ, ТекстОшибки);
	УдалитьИзВременногоХранилища(Адрес);
	
КонецПроцедуры

#КонецОбласти

#Область Интерактив

&НаКлиентеНаСервереБезКонтекста
Функция КодЦветаПоИмени(ИмяЦвета)
	
	Результат = 0;
	Если ИмяЦвета = "Желтый" Тогда
		Результат = 1;
	ИначеЕсли ИмяЦвета = "Салатовый" Тогда
		Результат = 2;
	ИначеЕсли ИмяЦвета = "Бирюзовый" Тогда
		Результат = 3;
	ИначеЕсли ИмяЦвета = "Розовый" Тогда
		Результат = 4;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

#Область ПроизвольныйЗапрос

&НаКлиенте
Процедура ОткрытьПроизвольныйЗапросПродолжение() Экспорт
	
	ПустойОбработчик = Новый ОписаниеОповещения("ОткрытьПроизвольныйЗапросЗавершение", ЭтотОбъект);
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	Диалог.Заголовок = НСтр("ru = 'Файл запроса'");
	Диалог.Расширение = "rest";
	Диалог.МножественныйВыбор = Ложь;
	Диалог.Фильтр = "Запросы rest (*.rest)|*.rest";
	НачатьПомещениеФайлов(ПустойОбработчик, Диалог, Истина, УникальныйИдентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьПроизвольныйЗапросЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = Неопределено Или Результат.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	АдресХранилища = Результат[0].Хранение;
	ПроизвольныйЗапрос.УстановитьТекст(ПолучитьСтрокуИзДвоичныхДанных(
		ПолучитьИзВременногоХранилища(АдресХранилища)));
	УдалитьИзВременногоХранилища(АдресХранилища);
	
КонецПроцедуры

&НаСервере
Процедура ПрочитатьТекущийЗапрос(Знач ТекущаяСтрока, ПоказыватьПроизвольныйЗапрос)
	
	Элементы.ИзменитьЗапрос.Пометка = ПоказыватьПроизвольныйЗапрос;
	Элементы.ГруппаПроизвольныйЗапрос.Видимость = ПоказыватьПроизвольныйЗапрос;
	
	Если ПоказыватьПроизвольныйЗапрос И ТекущаяСтрока <> Неопределено Тогда
		
		ПроизвольныйЗапрос.Очистить();
		ТекстЗапроса = ЛогированиеТрафика.ПолучитьТекстЛога(ТекущаяСтрока, Ложь);
		ПроизвольныйЗапрос.УстановитьТекст(ТекстЗапроса);
		
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура КодCurl(Команда)
	
	Если Элементы.Список.ТекущаяСтрока = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыОткрытия = Новый Структура;
	ПараметрыОткрытия.Вставить("АдресХранилища", ПолучитьКодCurl());
	ПараметрыОткрытия.Вставить("Заголовок", НСтр("ru = 'Код Curl'"));
	ОткрытьФорму("РегистрСведений.ЛогиТрафика.Форма.Просмотр", ПараметрыОткрытия,,,,,,
		РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

&НаКлиенте
Процедура Код1СПредприятие(Команда)
	
	Если Элементы.Список.ТекущаяСтрока = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыОткрытия = Новый Структура;
	ПараметрыОткрытия.Вставить("АдресХранилища", ПолучитьКодЗапроса1СПредприятие());
	ПараметрыОткрытия.Вставить("Заголовок", НСтр("ru = 'Код 1С:Предприятие 8'"));
	ОткрытьФорму("РегистрСведений.ЛогиТрафика.Форма.Просмотр", ПараметрыОткрытия,,,,,,
		РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

&НаКлиенте
Процедура ПовторитьЗапрос(Команда)
	
	Если Элементы.Список.ТекущаяСтрока = Неопределено Тогда
		Возврат;
	КонецЕсли;
	ТекстЗапроса = ПолучитьТекстЛога(Элементы.Список.ТекущаяСтрока);
	
	НоваяСтрока = Неопределено;
	Отказ = Ложь;
	ТекстОшибки = "";
	
	ВыполнитьЗапросПоСтроке(ТекстЗапроса, Отказ, ТекстОшибки, НоваяСтрока);
	
	Если Не Отказ Тогда
		Элементы.Список.Обновить();
		Элементы.Список.ТекущаяСтрока = НоваяСтрока;
	КонецЕсли;
	
	Если Не ПустаяСтрока(ТекстОшибки) Тогда
		ПоказатьПредупреждение(, ТекстОшибки);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВставитьТекстВЗапрос(Элемент, ТекстДляВставки, Сдвиг = 0)
	
	СтрокаНач = 0;
	СтрокаКон = 0;
	КолонкаНач = 0;
	КолонкаКон = 0;
	
	Элемент.ПолучитьГраницыВыделения(СтрокаНач, КолонкаНач, СтрокаКон, КолонкаКон);
	
	Если (КолонкаКон = КолонкаНач) И (КолонкаКон + СтрДлина(ТекстДляВставки)) > Элемент.Ширина / 8 Тогда
		Элемент.ВыделенныйТекст = "";
	КонецЕсли;
		
	Элемент.ВыделенныйТекст = ТекстДляВставки;
	
	Если Не Сдвиг = 0 Тогда
		Элемент.ПолучитьГраницыВыделения(СтрокаНач, КолонкаНач, СтрокаКон, КолонкаКон);
		Элемент.УстановитьГраницыВыделения(СтрокаНач, КолонкаНач - Сдвиг, СтрокаКон, КолонкаКон - Сдвиг);
	КонецЕсли;
		
	ТекущийЭлемент = Элемент;
	
КонецПроцедуры

&НаСервере
Процедура ВыполнитьЗапросПоСтроке(ТекстЗапроса, Отказ, ТекстОшибки, НоваяСтрока)
	
	ЛогированиеТрафика.ВыполнитьЗапросПоСтроке(ТекстЗапроса, Отказ, ТекстОшибки, НоваяСтрока)
	
КонецПроцедуры

&НаСервере
Функция ПолучитьКодCurl()
	
	ПротоколЗапроса = ЛогированиеТрафика.ПолучитьПротоколЗапросаЛога(Элементы.Список.ТекущаяСтрока);
	Если ПротоколЗапроса = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	СтрокаЗапроса = ЛогированиеТрафика.ПолучитьСтрокуURLЗапроса(ПротоколЗапроса.Метод, ПротоколЗапроса.Сервер, ПротоколЗапроса.ЭтоЗащищенноеСоединение, ПротоколЗапроса.Порт, ПротоколЗапроса.Адрес);
	Результат = СтрШаблон("curl --request --ssl-no-revoke %1", СтрокаЗапроса);
	Для каждого ЭлементКоллекции Из ПротоколЗапроса.ЗаголовкиЗапроса Цикл
		Результат = Результат + СтрШаблон(" --header ""%1: %2""", ЭлементКоллекции.Ключ, ЭлементКоллекции.Значение);
	КонецЦикла;
	Если ЗначениеЗаполнено(ПротоколЗапроса.ТелоЗапроса) Тогда
		ТелоЗапроса = СтрЗаменить(ПолучитьСтрокуИзДвоичныхДанных(ПротоколЗапроса.ТелоЗапроса), """", "\""");
		ТелоЗапроса = СтрЗаменить(ТелоЗапроса, Символы.ПС, " ");
		Результат = Результат + СтрШаблон(" --data-raw ""%1""", ТелоЗапроса);
	КонецЕсли;
	
	АдресХранилища = ПоместитьВоВременноеХранилище(Результат, УникальныйИдентификатор);
	
	Возврат АдресХранилища;
	
КонецФункции

&НаСервере
Функция ПолучитьКодЗапроса1СПредприятие()
	
	ПротоколЗапроса = ЛогированиеТрафика.ПолучитьПротоколЗапросаЛога(Элементы.Список.ТекущаяСтрока);
	Если ПротоколЗапроса = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	//СтрокаЗапроса = Логирование.ПолучитьСтрокуURLЗапроса(Запрос.Метод, Запрос.Сервер, Запрос.ЭтоЗащищенноеСоединение, Запрос.Порт, Запрос.Адрес);
	
	Текст = Новый ТекстовыйДокумент;
	Текст.ДобавитьСтроку("// " + ПротоколЗапроса.Событие);
	Текст.ДобавитьСтроку(СтрШаблон("СоединениеHTTP = Новый HTTPСоединение(""%1"", %2,,,,,%3);", 
		ПротоколЗапроса.Сервер,
		ПротоколЗапроса.Порт,
		?(ПротоколЗапроса.ЭтоЗащищенноеСоединение, " Новый ЗащищенноеСоединениеOpenSSL", "")));
		
	Текст.ДобавитьСтроку(СтрШаблон("ЗапросHTTP = Новый HTTPЗапрос(""%1"");", ПротоколЗапроса.Адрес));
	
	Для каждого ЭлементКоллекции Из ПротоколЗапроса.ЗаголовкиЗапроса Цикл
		Текст.ДобавитьСтроку(СтрШаблон("ЗапросHTTP.Заголовки.Вставить(""%1"", ""%2"");", ЭлементКоллекции.Ключ, ЭлементКоллекции.Значение));
	КонецЦикла;
	
	Если ЗначениеЗаполнено(ПротоколЗапроса.ТелоЗапроса) Тогда
		ТелоЗапроса = СтрЗаменить(ПолучитьСтрокуИзДвоичныхДанных(ПротоколЗапроса.ТелоЗапроса), """", """""");
		ТелоЗапроса = СтрЗаменить(ТелоЗапроса, Символы.ПС, " ");
		Текст.ДобавитьСтроку(СтрШаблон("ЗапросHTTP.УстановитьТелоИзСтроки(""%1"");", ТелоЗапроса));
	КонецЕсли;
	
	Текст.ДобавитьСтроку(СтрШаблон("ОтветHTTP = СоединениеHTTP.ВызватьHTTPМетод(""%1"", ЗапросHTTP);", ПротоколЗапроса.Метод));
	Текст.ДобавитьСтроку("Сообщить(ОтветHTTP.ПолучитьТелоКакСтроку());");
	
	АдресХранилища = ПоместитьВоВременноеХранилище(Текст.ПолучитьТекст(), УникальныйИдентификатор);
	
	Возврат АдресХранилища;
	
КонецФункции

#КонецОбласти

&НаКлиенте
Процедура СписокПриАктивизацииСтрокиПродолжение() Экспорт
	
	Если Не ПоказыватьДанные Тогда
		Возврат;
	КонецЕсли;
	
	ТекущаяСтрокаСписка = Элементы.Список.ТекущаяСтрока;
	ТекущиеДанные = Элементы.Список.ТекущиеДанные;
	СписокПриАктивизацииСтрокиНаСервере(ТекущиеДанные);
	
КонецПроцедуры

&НаСервере
Процедура СписокПриАктивизацииСтрокиНаСервере(ТекущиеДанные)
	
	ЗаголовкиЗапроса.Очистить();
	ЗаголовкиОтвета.Очистить();
	Если ТекущиеДанные = Неопределено Тогда
		ТекущееТелоЗапроса = "";
		ТекущееТелоОтвета  = "";
		ТекущийВызов       = "";
		ТекущееСобытие     = "";
		Элементы.СтраницаЗапросаJSON.Картинка = Новый Картинка;
		Элементы.СтраницаОтветJSON.Картинка   = Новый Картинка;
		Элементы.СтраницаОтвета.Заголовок     = НСтр("ru = 'Ответ'");
		Элементы.СтраницаЗаголовкиЗапроса.Заголовок = НСтр("ru = 'Заголовки'");
		Элементы.СтраницаЗаголовкиОтвета.Заголовок  = НСтр("ru = 'Заголовки'");
		Элементы.СтраницаТелоЗапроса.Картинка = Новый Картинка;
		ЗапросJSON.ПолучитьЭлементы().Очистить();
		ОтветJSON.ПолучитьЭлементы().Очистить();
		Возврат;
	КонецЕсли;
	ПараметрыСтроки = Новый Структура;
	ПараметрыСтроки.Вставить("Адрес",       ТекущиеДанные.Адрес);
	ПараметрыСтроки.Вставить("ВремяНачала", ТекущиеДанные.ВремяНачала);
	
	ПротоколЗапрос = ЛогированиеТрафика.ПолучитьДетализациюПротоколаЗапроса(ТекущиеДанные);
	Если ПротоколЗапрос = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ТаблицаЗаголовковЗапроса = ЛогированиеТрафика.СоответствиеВТаблицуЗначений(ПротоколЗапрос.ЗаголовкиЗапроса, "Ключ", "Значение");
	ЗначениеВРеквизитФормы(ТаблицаЗаголовковЗапроса, "ЗаголовкиЗапроса");
	
	ТаблицаЗаголовковОтвета = ЛогированиеТрафика.СоответствиеВТаблицуЗначений(ПротоколЗапрос.ЗаголовкиОтвета, "Ключ", "Значение");
	ЗначениеВРеквизитФормы(ТаблицаЗаголовковОтвета,  "ЗаголовкиОтвета");
	
//	Протокол = ?(ТекущиеДанные.Порт = 443, "https://", "http://");
	ТекущийВызов = ЛогированиеТрафика.ПолучитьСтрокуURLЗапроса(ТекущиеДанные.Метод, ТекущиеДанные.Сервер, 
		?(ТекущиеДанные.Порт = 443, Истина, Ложь), ТекущиеДанные.Порт, ТекущиеДанные.Адрес);
	
	ТекущееТелоЗапроса = ТекущийВызов + ?(ЗначениеЗаполнено(ПротоколЗапрос.ПредставлениеТелоЗапроса), Символы.ПС + Символы.ПС, "")
		+ПротоколЗапрос.ПредставлениеТелоЗапроса;
	ТекущееТелоОтвета  = ПротоколЗапрос.ПредставлениеТелоОтвета;
	//ТекущийКомментарий = Запрос.Комментарий;
	КодОтвета          = ПротоколЗапрос.КодОтвета;
	
	
	ТекущееСобытие = ТекущиеДанные.Событие;
	
	Элементы.СтраницаОтвета.Заголовок = НСтр("ru = 'Ответ'")
		+ ?(КодОтвета = 0, "", " - " + КодОтвета);
	
	Элементы.СтраницаТелоЗапроса.Картинка = ?(ЗначениеЗаполнено(ТекущееТелоЗапроса),
		БиблиотекаКартинок.Документ, Новый Картинка);
	
	Элементы.СтраницаЗаголовкиЗапроса.Заголовок = НСтр("ru = 'Заголовки'")
		+ ?(ЗаголовкиЗапроса.Количество() = 0, "", " (" + ЗаголовкиЗапроса.Количество() + ")");
	
	Элементы.СтраницаЗаголовкиОтвета.Заголовок = НСтр("ru = 'Заголовки'")
		+ ?(ЗаголовкиОтвета.Количество() = 0, "", " (" + ЗаголовкиОтвета.Количество() + ")");
		
	Если ПротоколЗапрос.ДеревоЗапроса <> Неопределено Тогда
		ЗначениеВРеквизитФормы(ПротоколЗапрос.ДеревоЗапроса, "ЗапросJSON");
		Элементы.СтраницаЗапросаJSON.Картинка = БиблиотекаКартинок.РежимПросмотраСпискаИерархическийСписок;
	Иначе
		ЗапросJSON.ПолучитьЭлементы().Очистить();
		Элементы.СтраницаЗапросаJSON.Картинка = Новый Картинка;
	КонецЕсли;
	
	Если ПротоколЗапрос.ДеревоОтвета <> Неопределено Тогда
		ЗначениеВРеквизитФормы(ПротоколЗапрос.ДеревоОтвета, "ОтветJSON");
		Элементы.СтраницаОтветJSON.Картинка = БиблиотекаКартинок.РежимПросмотраСпискаИерархическийСписок;
	Иначе
		ОтветJSON.ПолучитьЭлементы().Очистить();
		Элементы.СтраницаОтветJSON.Картинка = Новый Картинка;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти