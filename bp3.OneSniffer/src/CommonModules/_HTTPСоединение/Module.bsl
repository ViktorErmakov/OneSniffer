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
Функция _ВызватьHTTPМетод(Знач Соединение, Знач Метод, Знач Запрос, Знач ИмяВыходногоФайла, ИмяСобытия = "") Экспорт
	
	// Проверка использования.
	НастройкиЛогирования = ЛогированиеТрафика.ЗагрузитьНастройкиЛогирования();
	Если Не НастройкиЛогирования.ВключеноЛогирование Тогда
		HTTPОтвет = Соединение.ВызватьHTTPМетод(Метод, Запрос, ИмяВыходногоФайла); // HTTPОтвет
		Возврат HTTPОтвет;
	КонецЕсли;
	
	ЛогЗапроса = РегистрыСведений.ЛогиТрафика.ЛогЗапроса(Соединение, Запрос, Метод, ИмяСобытия);
	
	// Подготовим данные для записи возможного исключения.
	ДанныеДляЗаписиИсключения = ЛогированиеТрафика.ДанныеДляЗаписиИсключения(ЛогЗапроса);
	
	Попытка
		
		HTTPОтвет = Соединение.ВызватьHTTPМетод(Метод, Запрос, ИмяВыходногоФайла); // HTTPОтвет
		ЛогЗапроса.Вставить("HTTPОтвет", HTTPОтвет);
		
	Исключение
		
		Если ТранзакцияАктивна() Тогда
			
			// В случае если произошло исключение и транзакция была активирована кодом извне, 
			// делаем запись в ЖР, т.к. запись в РС откатиться.
			ЗаписьЖурналаРегистрации(
				ЛогированиеТрафика.СобытиеВызватьHTTPМетод(), 
				УровеньЖурналаРегистрации.Ошибка,, 
				ДанныеДляЗаписиИсключения, 
				ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			
		КонецЕсли;
		
		РегистрыСведений.ЛогиТрафика.ЗаписатьЛог(ЛогЗапроса, ИмяВыходногоФайла);
		
		ВызватьИсключение;
		
	КонецПопытки;
	
	РегистрыСведений.ЛогиТрафика.ЗаписатьЛог(ЛогЗапроса, ИмяВыходногоФайла);
	
	Возврат ЛогЗапроса.HTTPОтвет;
	
КонецФункции

#КонецОбласти