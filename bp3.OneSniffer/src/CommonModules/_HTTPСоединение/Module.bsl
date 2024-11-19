// @strict-types


#Область ПрограммныйИнтерфейс

// Вызвать HTTPМетод.
// 
// Параметры:
//  Соединение - HTTPСоединение
//  Метод - Строка
//  Запрос - HTTPЗапрос
//  ИмяВыходногоФайла - Строка
//  ИмяСобытия - Строка
// 
// Возвращаемое значение:
//  HTTPОтвет
//
Функция _ВызватьHTTPМетод(Знач Соединение, Знач Метод, Знач Запрос, Знач ИмяВыходногоФайла = "", ИмяСобытия = "") Экспорт
	
	// Если логирование не используется, то делаем ровно то, что было бы сделано без расширения, без перехвата исключений.
	НастройкиЛогирования = ЛогированиеТрафика.ЗагрузитьНастройкиЛогирования();
	Если Не НастройкиЛогирования.ВключеноЛогирование Тогда
		
		Если ПустаяСтрока(ИмяВыходногоФайла) Тогда
			HTTPОтвет = Соединение.ВызватьHTTPМетод(Метод, Запрос); // HTTPОтвет
		Иначе
			HTTPОтвет = Соединение.ВызватьHTTPМетод(Метод, Запрос, ИмяВыходногоФайла); // HTTPОтвет
		КонецЕсли;
		
		Возврат HTTPОтвет;
		
	КонецЕсли;
	
	ЗаписыватьТело = Истина;
	Если НастройкиЛогирования.ЗаписыватьВЖР Тогда
		ЗаписыватьТело = НастройкиЛогирования.ЗаписыватьВЖРТело;
	КонецЕсли;
	
	ЛогЗапроса = РегистрыСведений.ЛогиТрафика.ЛогЗапроса(Соединение, Запрос, Метод, ЗаписыватьТело, ИмяСобытия);
	
	Попытка
		
		Если ПустаяСтрока(ИмяВыходногоФайла) Тогда
			HTTPОтвет = Соединение.ВызватьHTTPМетод(Метод, Запрос); // HTTPОтвет
		Иначе
			HTTPОтвет = Соединение.ВызватьHTTPМетод(Метод, Запрос, ИмяВыходногоФайла); // HTTPОтвет
		КонецЕсли;
		
		ЛогЗапроса.Вставить("HTTPОтвет", HTTPОтвет);
		
	Исключение
		
		// Запишем в лог текст самого исключения.
		Комментарий = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ЛогЗапроса.Содержание.ТелоОтвета = Комментарий;
		
		// Подготовим данные для записи в журнал регистрации.
		ДанныеДляЗаписиИсключения = ЛогированиеТрафика.ДанныеДляЗаписиИсключения(ЛогЗапроса, ЗаписыватьТело);
		
		ЗаписьЖурналаРегистрации(
			ЛогированиеТрафика.СобытиеВызватьHTTPМетод(), 
			УровеньЖурналаРегистрации.Ошибка,, 
			ДанныеДляЗаписиИсключения, 
			Комментарий);
		
		Если Не ТранзакцияАктивна() 
			И НастройкиЛогирования.ЗаписыватьВРС Тогда
			
			// Запись лога вне транзакции
			РегистрыСведений.ЛогиТрафика.ЗаписатьЛог(ЛогЗапроса, ИмяВыходногоФайла);
			
		КонецЕсли;
		
		ВызватьИсключение;
		
	КонецПопытки;
	
	Если НастройкиЛогирования.ЗаписыватьВЖР Тогда
		
		// Подготовим данные для записи в журнал регистрации.
		ДанныеДляЗаписиИсключения = ЛогированиеТрафика.ДанныеДляЗаписиИсключения(
			ЛогЗапроса, НастройкиЛогирования.ЗаписыватьВЖРТело);
		
		ЗаписьЖурналаРегистрации(
			ЛогированиеТрафика.СобытиеВызватьHTTPМетод(), 
			УровеньЖурналаРегистрации.Информация,, 
			ДанныеДляЗаписиИсключения, 
			Комментарий);
		
	КонецЕсли;
	
	Если НастройкиЛогирования.ЗаписыватьВРС Тогда
		РегистрыСведений.ЛогиТрафика.ЗаписатьЛог(ЛогЗапроса, ИмяВыходногоФайла);
	КонецЕсли;
	
	Возврат ЛогЗапроса.HTTPОтвет;
	
КонецФункции

#КонецОбласти