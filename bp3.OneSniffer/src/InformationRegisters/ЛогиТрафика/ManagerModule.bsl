// @strict-types


#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

// Структура менеджера записи.
// 
// Возвращаемое значение:
//  Структура:
// * НомерСеанса - Число
// * ВремяНачала - Число
// * Дата - Дата
// * Сервер - Строка
// * Метод - ПеречислениеСсылка.МетодHTTP
// * Адрес - Строка
// * Входящий - Булево
// * Длительность - Число
// * Клиент - Строка
// * КодОтвета - Число
// * Пользователь - Строка
// * Порт - Число
// * РазмерОтвета - Число
// * Событие - Строка
// * Содержание - см. НовоеСодержаниеЗапроса
// * ЭтоЗащищенноеСоединение - Булево
// * Разделитель - Булево
//
Функция СтруктураМенеджераЗаписи() Экспорт
	
	// Подготовим данные для записи возможного исключения.
	СтруктураЗаписи = ОбщегоНазначения.СтруктураПоМенеджеруЗаписи(
		СоздатьМенеджерЗаписи(), 
		Метаданные.РегистрыСведений.ЛогиТрафика);
	
	//@skip-warning
	Возврат СтруктураЗаписи;
	
КонецФункции

// Новый лог запроса.
// 
// Параметры:
//  Соединение - HTTPСоединение
//  Запрос - HTTPЗапрос
//  ИмяМетода - Строка
//  ИмяСобытия - Строка
// 
// Возвращаемое значение:
//  см. НовыйЛогЗапроса
//
Функция ЛогЗапроса(Соединение, Запрос, ИмяМетода, ИмяСобытия = "") Экспорт
	
//	// Добавление идентификатора для отслеживания запросов.
//	Если НастройкиЛогирования.ВключенаТрассировка Тогда
//		HTTPЗапрос.Заголовки.Вставить("x-b3-traceid", СгенерироватьИдентификатор());
//		HTTPЗапрос.Заголовки.Вставить("x-b3-spanid",  СгенерироватьИдентификатор());
//	КонецЕсли;
	
	Метод = Перечисления.МетодHTTP[ИмяМетода];
	ЛогЗапроса = НовыйЛогЗапроса(Метод, ИмяСобытия, Соединение, Запрос);
	ЛогЗапроса.Событие = ИмяСобытия;
	ЛогированиеТрафика.ИмяСобытия(ЛогЗапроса.Событие, Запрос.АдресРесурса);
	
	Возврат ЛогЗапроса;
	
КонецФункции

// Записать лог.
// 
// Параметры:
//  ЛогЗапроса - см. НовыйЛогЗапроса
//  ИмяВыходногоФайла - Строка -  Имя выходного файла
//  ТекстОшибки - Строка -  Текст ошибки
//
Процедура ЗаписатьЛог(ЛогЗапроса, ИмяВыходногоФайла = "", ТекстОшибки = "") Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	НачатьТранзакцию();
	
	Попытка
		
		Запись = СоздатьМенеджерЗаписи();
		ЗаполнитьЗначенияСвойств(Запись, ЛогЗапроса, , "Содержание");
		Запись.Длительность = (ТекущаяУниверсальнаяДатаВМиллисекундах() - ЛогЗапроса.ВремяНачала)/1000;
		
		Содержание = НовоеСодержаниеЗапроса();
		ЗаполнитьЗначенияСвойств(Содержание, ЛогЗапроса.Содержание);
		
		HTTPОтвет = ?(ЛогЗапроса.Свойство("HTTPОтвет"), ЛогЗапроса.HTTPОтвет, Неопределено);
		Если HTTPОтвет <> Неопределено Тогда
			//TODO кажется функционал с именем выходного файла не готов, надо проверить
			Если ИмяВыходногоФайла = Неопределено Тогда
				
				Если HTTPОтвет.Заголовки["content-encoding"] = "gzip" Тогда
					ДвоичныеДанныеОтвета = HTTPОтвет.ПолучитьТелоКакДвоичныеДанные();
					ТелоОтвета = ЛогированиеТрафика.РаспаковатьФайлGZip(ДвоичныеДанныеОтвета);
				Иначе
					ТелоОтвета = HTTPОтвет.ПолучитьТелоКакДвоичныеДанные();
				КонецЕсли;
				
			Иначе
				ТелоОтвета = Новый ДвоичныеДанные(ИмяВыходногоФайла);
			КонецЕсли;
			Если ТелоОтвета <> Неопределено Тогда
				Запись.РазмерОтвета        = ТелоОтвета.Размер()/1000;
				Содержание.ТелоОтвета      = ТелоОтвета;
			КонецЕсли;
			Запись.КодОтвета           = HTTPОтвет.КодСостояния;
			Содержание.ЗаголовкиОтвета = HTTPОтвет.Заголовки;
		ИначеЕсли Не ПустаяСтрока(ТекстОшибки) Тогда
			Содержание.ТелоОтвета    = ТекстОшибки;
		КонецЕсли;
		
		Запись.Содержание = Новый ХранилищеЗначения(Содержание, Новый СжатиеДанных(5));
		
		Если Метаданные.Подсистемы.Найти("СтандартныеПодсистемы") <> Неопределено Тогда
			МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
			Запись.Разделитель = МодульРаботаВМоделиСервиса.ЗначениеРазделителяСеанса();
		КонецЕсли;
		
		Запись.Записать(Истина);
		ЗафиксироватьТранзакцию();
		
	Исключение
		
		ОтменитьТранзакцию();
		
		ШаблонОшибки = НСтр("ru = 'Метод: %2.%1%3%1%4'");
		ТекстОшибки = СтрШаблон(
			ШаблонОшибки, 
			Символы.ПС, 
			ЛогЗапроса.Событие, 
			ПолучитьСтрокуURLЗапроса(ЛогЗапроса), 
			ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		
		ШаблонСобытия = НСтр("ru = '%1Запись лога.'");
		ИмяСобытия = СтрШаблон(ШаблонСобытия, ЛогированиеТрафика.НаименованиеБиблиотеки());
		ЗаписьЖурналаРегистрации(
			ИмяСобытия, 
			УровеньЖурналаРегистрации.Ошибка,
			Метаданные.РегистрыСведений.ЛогиТрафика, , ТекстОшибки);
		
	КонецПопытки;
	
//	ЗаписатьЛогЗапросаВФайл(ЛогЗапроса, ТекстОшибки);
	
КонецПроцедуры

// Очистить историю.
// 
// Параметры:
//  СрокХранения - Число - количество дней.
//
Процедура ОчиститьИсторию(СрокХранения) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ЛогиТрафика.НомерСеанса КАК НомерСеанса,
	|	ЛогиТрафика.Дата КАК Дата,
	|	ЛогиТрафика.Сервер КАК Сервер,
	|	ЛогиТрафика.Метод КАК Метод,
	|	ЛогиТрафика.ВремяНачала КАК ВремяНачала
	|ИЗ
	|	РегистрСведений.ЛогиТрафика КАК ЛогиТрафика
	|ГДЕ
	|	ЛогиТрафика.Дата < &СрокХранения
	|
	|УПОРЯДОЧИТЬ ПО
	|	Дата";
	
	Запрос.УстановитьПараметр("СрокХранения", ТекущаяДатаСеанса() - СрокХранения * 24*60*60);
	Выборка = Запрос.Выполнить().Выбрать();
	
	// TODO Блокировка нужна
	
	СчетчикТранзакции = 0;
	Пока Выборка.Следующий() Цикл
		
		Запись = СоздатьМенеджерЗаписи();
		ЗаполнитьЗначенияСвойств(Запись, Выборка);
		Запись.Удалить();
		СчетчикТранзакции = СчетчикТранзакции + 1;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Новый лог запроса.
// 
// Параметры:
//  Метод - ПеречислениеСсылка.МетодHTTP
//  Событие - Строка
//  Соединение - HTTPСоединение
//  HTTPЗапрос - HTTPЗапрос
// 
// Возвращаемое значение:
//  Структура:
// * НомерСеанса - Число
// * ВремяНачала - Число
// * Дата - Дата
// * Сервер - Строка
// * Метод - ПеречислениеСсылка.МетодHTTP
// * Адрес - Строка
// * Входящий - Булево
// * Длительность - Число
// * Клиент - Строка
// * КодОтвета - Число
// * Пользователь - Строка
// * Порт - Число
// * РазмерОтвета - Число
// * Событие - Строка
// * Содержание - см. НовоеСодержаниеЗапроса
// * ЭтоЗащищенноеСоединение - Булево
// * Разделитель - Булево
// * HTTPОтвет - Неопределено, HTTPОтвет - ответ сервиса.
//
Функция НовыйЛогЗапроса(Метод, Событие, Соединение, HTTPЗапрос) Экспорт
	
	НовыйЛогЗапроса = СтруктураМенеджераЗаписи();
	НовыйЛогЗапроса.Метод = Метод; // POST, GET...
	НовыйЛогЗапроса.Событие = Событие;
	НовыйЛогЗапроса.Дата = ТекущаяДатаСеанса();
	НовыйЛогЗапроса.ВремяНачала = ТекущаяУниверсальнаяДатаВМиллисекундах();
	НовыйЛогЗапроса.ЭтоЗащищенноеСоединение = (Соединение.ЗащищенноеСоединение <> Неопределено);
	НовыйЛогЗапроса.Сервер = ?(ТипЗнч(Соединение) = Тип("HTTPСоединение"), Соединение.Сервер, "");
	НовыйЛогЗапроса.Адрес  = HTTPЗапрос.АдресРесурса;
	НовыйЛогЗапроса.Пользователь = Пользователи.ТекущийПользователь().ПолноеНаименование();
	НовыйЛогЗапроса.Клиент = ИмяКомпьютера();
	НовыйЛогЗапроса.НомерСеанса = НомерСеансаИнформационнойБазы();
	НовыйЛогЗапроса.Вставить("HTTPОтвет", Неопределено);
	
	Содержание = НовоеСодержаниеЗапроса();
	Содержание.ЗаголовкиЗапроса = HTTPЗапрос.Заголовки;
	Содержание.ТелоЗапроса = HTTPЗапрос.ПолучитьТелоКакДвоичныеДанные();
	
	// Проверка авторизации
	Если ЗначениеЗаполнено(Соединение.Пользователь)
		И Содержание.ЗаголовкиЗапроса.Получить("Autorization") = Неопределено Тогда
		
		АвторизацияOAuth = СтрШаблон(
			"Basic %1", 
			Base64Значение(СтрШаблон("%1:%2", Соединение.Пользователь, Соединение.Пароль)));
		
		Содержание.ЗаголовкиЗапроса.Вставить("Autorization", АвторизацияOAuth);
		
	КонецЕсли;
	
	НовыйЛогЗапроса.Содержание = Содержание;
	
	Возврат НовыйЛогЗапроса;
	
КонецФункции

// Новое содержание запроса.
// 
// Возвращаемое значение:
//  Структура -  Новое содержание запроса:
// * ЗаголовкиЗапроса - Соответствие из КлючиЗначение - заголовки запроса.
// * ТелоЗапроса - Неопределено, Произвольный - тело запроса.
// * ЗаголовкиОтвета - Соответствие из КлючиЗначение - заголовки ответа.
// * ТелоОтвета - Неопределено, Произвольный - тело ответа.
//
Функция НовоеСодержаниеЗапроса()
	
	Содержание = Новый Структура;
	Содержание.Вставить("ЗаголовкиЗапроса", Новый Соответствие());
	Содержание.Вставить("ТелоЗапроса", Неопределено);
	Содержание.Вставить("ЗаголовкиОтвета", Новый Соответствие());
	Содержание.Вставить("ТелоОтвета", Неопределено);
	
	Возврат Содержание;

КонецФункции

// Получить строку URLЗапроса.
// 
// Параметры:
//  ЛогЗапроса - см. НовыйЛогЗапроса
//  ИсключитьПараметры - Булево
// 
// Возвращаемое значение:
//  Строка -  Получить строку URLЗапроса
//
Функция ПолучитьСтрокуURLЗапроса(ЛогЗапроса, ИсключитьПараметры = Ложь) Экспорт
	
	Метод = Строка(ЛогЗапроса.Метод);
	Сервер = ЛогЗапроса.Сервер;
	ЗащищенноеСоединение = ЛогЗапроса.ЭтоЗащищенноеСоединение;
	Порт = ЛогЗапроса.Порт;
	Адрес = ЛогЗапроса.Адрес;
	
	Шаблон = НСтр("ru ='%1%2%3%4%5%6'");
	Результат = СтрШаблон(Шаблон, 
		?(ПустаяСтрока(Метод), "", СтрШаблон("%1 ", ВРег(Метод))), 
		?(Не ЗащищенноеСоединение, "http://", "https://"), 
		Сервер, 
		?(Порт = 0 Или Порт = 80 Или Порт = 443, "", СтрШаблон(":%1", Формат(Порт, "ЧГ="))), 
		?(Лев(Адрес, 1) = "/", "", "/"), 
		Адрес);
		
	Если ИсключитьПараметры Тогда
		РазделительПараметры = СтрНайти(Результат, "?");
		Если РазделительПараметры <> 0 Тогда
			Результат = Лев(Результат, РазделительПараметры - 1);
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

#КонецЕсли