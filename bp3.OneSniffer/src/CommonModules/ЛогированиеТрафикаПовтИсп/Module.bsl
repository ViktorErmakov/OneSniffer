
#Область СлужебныйПрограммныйИнтерфейс

//Функция ПолучитьЗначениеПеременнойСреды(ИмяПеременнойСреды) Экспорт
//	
//	Попытка
//		ИмяВременногоФайла = ПолучитьИмяВременногоФайла();
//		
//		ЭтоLinux = Ложь;
//		Информация = Новый СистемнаяИнформация;
//		Если Информация.ТипПлатформы = ТипПлатформы.Linux_x86
//			Или Информация.ТипПлатформы = ТипПлатформы.Linux_x86_64
//			ИЛИ Информация.ТипПлатформы = ТипПлатформы.MacOS_x86
//			ИЛИ Информация.ТипПлатформы = ТипПлатформы.MacOS_x86_64 Тогда
//			ЭтоLinux = Истина;
//		КонецЕсли;
//		
//		Если ЭтоLinux Тогда
//			СтрокаКоманды = "sh -c 'env | grep ^" + ИмяПеременнойСреды + "= > " + ИмяВременногоФайла + "'";
//			ЗапуститьПриложение(СтрокаКоманды);
//		Иначе
//			ВыполнитьКомандуОСБезПоказаЧерногоОкна("set " + ИмяПеременнойСреды + " > """ + ИмяВременногоФайла + """");
//		КонецЕсли;
//		
//		Файл = Новый Файл(ИмяВременногоФайла);
//		Если Не Файл.Существует() Тогда
//			Возврат Неопределено;
//		КонецЕсли;
//
//		Чтение = Новый ЧтениеТекста(ИмяВременногоФайла);
//		Стр = Чтение.ПрочитатьСтроку();
//		Пока Стр <> Неопределено Цикл
//			//Найдем ключ и значение
//			Индекс = Найти(Стр, "=");
//			Если Индекс > 0 Тогда
//				Ключ = Нрег(Лев(Стр, Индекс - 1));
//				Если ВРег(Ключ) = ВРег(ИмяПеременнойСреды) Тогда
//					ЗначениеВыражения = Сред(Стр, Индекс + 1);
//					Возврат ЗначениеВыражения
//				КонецЕсли;
//			КонецЕсли;
//			Стр = Чтение.ПрочитатьСтроку();
//		КонецЦикла;
//	Исключение
//	КонецПопытки;
//
//	Возврат Неопределено;
//	
//КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

//Функция ВыполнитьКомандуОСБезПоказаЧерногоОкна(ТекстКоманды, ЖдатьОкончания = -1)
//	
//	//если ЖдатьОкончания = -1, тогда будет ожидания окончания работы приложения
//	ИмяВременногоФайлаКоманды = ПолучитьИмяВременногоФайла("cmd");
//	ЗаписьТекста = Новый ЗаписьТекста(ИмяВременногоФайлаКоманды, КодировкаТекста.ANSI,, Ложь);
//	ЗаписьТекста.Закрыть();
//	ЗаписьТекста = Новый ЗаписьТекста(ИмяВременногоФайлаКоманды, КодировкаТекста.UTF8,, Истина);
//	ЗаписьТекста.ЗаписатьСтроку("chcp 65001");
//	ЗаписьТекста.ЗаписатьСтроку(ТекстКоманды);
//	ЗаписьТекста.Закрыть();
//	
//	WshShell = Новый COMОбъект("WScript.Shell");
//	Рез = WshShell.Run("""" + ИмяВременногоФайлаКоманды + """", 0, ЖдатьОкончания);
//	WshShell = Неопределено;
//	
//	Возврат Рез;
//	
//КонецФункции

#КонецОбласти
