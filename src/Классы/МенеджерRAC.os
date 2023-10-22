#Использовать logos
#Использовать v8runner

#Область ОписаниеПеременных

Перем Лог;
Перем ЭтоWindows;
Перем ОписаниеКластераКеш;
Перем ИдентификаторБазыКеш;
Перем Настройки;
Перем ПараметрыКоманды; // параметры из командной строки

#КонецОбласти

#Область ПрограммныйИнтерфейс

Процедура ПриСозданииОбъекта(Знач ПарамНастройки, Знач ПарамПараметрыКоманды, Знач ПарамЛог) // BSLLS:NonExportMethodsInApiRegion-off

	Лог = ПарамЛог;
	Настройки = ПарамНастройки;
	ПараметрыКоманды = ПарамПараметрыКоманды;

	СистемнаяИнформация = Новый СистемнаяИнформация;
	ЭтоWindows = Найти(НРег(СистемнаяИнформация.ВерсияОС), "windows") > 0;

КонецПроцедуры

// Находит данные подходящего кластера по настройкам из конструктора.
// Если в настройках не заданы ни, ни, выбирается первый кластер.
// Данные вычисляются один раз и далее кешируются.
//
//  Возвращаемое значение:
//   Структура - данные кластера
//		* Идентификатор - Строка - Идентификатор
//		* Хост - Строка - Хост
//		* Порт - Строка - Порт
//		* Имя - Строка - Имя
//
Функция ОписаниеКластера() Экспорт

	Если ОписаниеКластераКеш <> Неопределено Тогда
		Возврат ОписаниеКластераКеш;
	КонецЕсли;

	Лог.Информация("Получаю список кластеров");
	ОписаниеКластераКеш = Новый Структура("Идентификатор,Хост,Порт,Имя");

	КомандаВыполнения = СтрокаЗапускаКлиента() + "cluster list " + Настройки.АдресСервераАдминистрирования;

	Кластеры = РазобратьПоток(ЗапуститьПроцесс(КомандаВыполнения));

	МассивКластеров = Новый Массив;
	Для каждого Кластер Из Кластеры Цикл

		ОписаниеКластера = Новый Структура("Идентификатор,Хост,Порт,Имя");
		ОписаниеКластера.Вставить("Идентификатор", Кластер.Получить("cluster"));
		ОписаниеКластера.Вставить("Хост", Кластер.Получить("host"));
		ОписаниеКластера.Вставить("Порт", Кластер.Получить("port"));
		ОписаниеКластера.Вставить("Имя", Кластер.Получить("name"));

		МассивКластеров.Добавить(ОписаниеКластера);
	КонецЦикла;

	Если НЕ ПустаяСтрока(Настройки.ИдентификаторКластера) Тогда
		Для Каждого ОписаниеКластера Из МассивКластеров Цикл
			Если ОписаниеКластера.Идентификатор = Настройки.ИдентификаторКластера Тогда
				ЗаполнитьЗначенияСвойств(ОписаниеКластераКеш, ОписаниеКластера);
				Прервать;
			КонецЕсли;
		КонецЦикла;
	ИначеЕсли НЕ ПустаяСтрока(Настройки.ИмяКластера) Тогда
		Для Каждого ОписаниеКластера Из МассивКластеров Цикл
			Если ОписаниеКластера.Имя = """" + Настройки.ИмяКластера + """" Тогда
				ЗаполнитьЗначенияСвойств(ОписаниеКластераКеш, ОписаниеКластера);
				Прервать;
			КонецЕсли;
		КонецЦикла;
	ИначеЕсли ЗначениеЗаполнено(Настройки.ПортКластера) Тогда
		Для Каждого ОписаниеКластера Из МассивКластеров Цикл
			Если ОписаниеКластера.Порт = Настройки.ПортКластера Тогда
				ЗаполнитьЗначенияСвойств(ОписаниеКластераКеш, ОписаниеКластера);
				Прервать;
			КонецЕсли;
		КонецЦикла;
	Иначе
		Если ЗначениеЗаполнено(МассивКластеров) Тогда
			ОписаниеКластера = МассивКластеров[0];
			ЗаполнитьЗначенияСвойств(ОписаниеКластераКеш, ОписаниеКластера);
		КонецЕсли;
	КонецЕсли;

	ИдентификаторКластера = ОписаниеКластераКеш.Идентификатор;
	ИдентификаторКластера = СокрЛП(СтрЗаменить(ИдентификаторКластера, Символы.ПС, ""));

	ОписаниеКластераКеш.Вставить("Идентификатор", ИдентификаторКластера);

	Лог.Отладка("Использую найденный кластер. Хост %1:%2, Идентификатор %3, Имя %4",
		ОписаниеКластераКеш.Хост, ОписаниеКластераКеш.Порт, ОписаниеКластераКеш.Идентификатор, ОписаниеКластераКеш.Имя);

	Если ПустаяСтрока(ОписаниеКластераКеш.Идентификатор) Тогда
		ВызватьИсключение "Кластер серверов не найден";
	КонецЕсли;

	Возврат ОписаниеКластераКеш;

КонецФункции

// Получить идентификатор кластера из настроек конструктора или из данных найденного кластера
// Данные вычисляются один раз и далее кешируются.
//
// Параметры:
//   ОписаниеКластера - Структура - см. ОписаниеКластер
//
//  Возвращаемое значение:
//   Строка - найденный идентификатор
//
Функция ИдентификаторКластера(Знач ОписаниеКластера) Экспорт
	Лог.Отладка("Найден идентификатор кластера %1", ОписаниеКластера.Идентификатор);
	Если ЗначениеЗаполнено(Настройки.ИдентификаторКластера) Тогда
		Результат = Настройки.ИдентификаторКластера;
		Лог.Отладка("Использую идентификатор кластера из переданных настроек %1 ", Результат);
	Иначе
		Результат = ОписаниеКластера.Идентификатор;
	КонецЕсли;
	Возврат Результат;
КонецФункции

// Найти идентификатор базы по настройкам
// Данные вычисляются один раз и далее кешируются.
//
//  Возвращаемое значение:
//   Строка - идентификатор базы
//
Функция ИдентификаторБазы() Экспорт
	Если ИдентификаторБазыКеш = Неопределено Тогда
		ИдентификаторБазыКеш = НайтиБазуВКластере();
	КонецЕсли;

	Возврат ИдентификаторБазыКеш;
КонецФункции

// Ключи авторизации в кластере в виде строки для rac
// --cluster-user="Настройки.АдминистраторКластера" --cluster-pwd="Настройки.ПарольАдминистратораКластера"
//
//  Возвращаемое значение:
//   Строка - результат
//
Функция КлючиАвторизацииВКластере() Экспорт
	КомандаВыполнения = "";
	Если ЗначениеЗаполнено(Настройки.АдминистраторКластера) Тогда
		КомандаВыполнения = КомандаВыполнения + СтрШаблон(" --cluster-user=""%1"" ", Настройки.АдминистраторКластера);
	КонецЕсли;

	Если ЗначениеЗаполнено(Настройки.ПарольАдминистратораКластера) Тогда
		КомандаВыполнения = КомандаВыполнения + СтрШаблон(" --cluster-pwd=""%1"" ", Настройки.ПарольАдминистратораКластера);
	КонецЕсли;
	Возврат КомандаВыполнения;
КонецФункции

// Ключи авторизации в ИБ в виде строки для rac
// --infobase-user="Настройки.АдминистраторКластера" --infobase-pwd="Настройки.ПарольАдминистратораИБ"
//
//  Возвращаемое значение:
//   Строка - результат
//
Функция КлючиАвторизацииВБазе() Экспорт
	КлючиАвторизацииВБазе = "";
	Если ЗначениеЗаполнено(Настройки.АдминистраторИБ) Тогда
		КлючиАвторизацииВБазе = КлючиАвторизацииВБазе + СтрШаблон(" --infobase-user=""%1""", Настройки.АдминистраторИБ);
	КонецЕсли;

	Если ЗначениеЗаполнено(Настройки.ПарольАдминистратораИБ) Тогда
		КлючиАвторизацииВБазе = КлючиАвторизацииВБазе + СтрШаблон(" --infobase-pwd=""%1""", Настройки.ПарольАдминистратораИБ);
	КонецЕсли;

	Возврат КлючиАвторизацииВБазе;

КонецФункции

// Получить полный путь RAC
//
//  Возвращаемое значение:
//   Строка - Путь к файлу rac.exe\rac
//
Функция ПолучитьПутьRAC() Экспорт

	ТекущийПуть = ПараметрыКоманды["--rac"];
	ВерсияПлатформы = ПараметрыКоманды["--v8version"];
	Разрядность = ОбщиеМетоды.РазрядностьПлатформы(ПараметрыКоманды["--bitness"]);

	Если НЕ ПустаяСтрока(ТекущийПуть) Тогда
		ФайлУтилиты = Новый Файл(ТекущийПуть);
		Если ФайлУтилиты.Существует() Тогда
			Лог.Отладка("Текущая версия rac " + ФайлУтилиты.ПолноеИмя);
			Возврат ФайлУтилиты.ПолноеИмя;
		КонецЕсли;
	КонецЕсли;

	Если ПустаяСтрока(ВерсияПлатформы) Тогда
		ВерсияПлатформы = "8.3";
	КонецЕсли;

	Конфигуратор = Новый УправлениеКонфигуратором;
	ПутьКПлатформе = Конфигуратор.ПолучитьПутьКВерсииПлатформы(ВерсияПлатформы, Разрядность);
	Лог.Отладка("Используемый путь для поиска rac " + ПутьКПлатформе);
	КаталогУстановки = Новый Файл(ПутьКПлатформе);
	Лог.Отладка(КаталогУстановки.Путь);

	ИмяФайла = ?(ЭтоWindows, "rac.exe", "rac");

	ФайлУтилиты = Новый Файл(ОбъединитьПути(Строка(КаталогУстановки.Путь), ИмяФайла));
	Если ФайлУтилиты.Существует() Тогда
		Лог.Отладка("Текущая версия rac " + ФайлУтилиты.ПолноеИмя);
		Возврат ФайлУтилиты.ПолноеИмя;
	КонецЕсли;

	Лог.Отладка("Не нашли rac. Использую переданный путь " + ТекущийПуть);
	Возврат ТекущийПуть;

КонецФункции

// Получить строку запуска rac, используя ключ "ПутьКлиентаАдминистрирования" из настроек
//
//  Возвращаемое значение:
//   Строка - строка для запуска (для Windows или Linux)
//
Функция СтрокаЗапускаКлиента() Экспорт
	Перем ПутьКлиентаАдминистрирования;
	Если ЭтоWindows Тогда
		ПутьКлиентаАдминистрирования = ОбщиеМетоды.ОбернутьПутьВКавычки(Настройки.ПутьКлиентаАдминистрирования);
	Иначе
		ПутьКлиентаАдминистрирования = Настройки.ПутьКлиентаАдминистрирования;
	КонецЕсли;

	Возврат ПутьКлиентаАдминистрирования + " ";

КонецФункции

// Разобрать поток от rac по ключам\значениям
// Например, из вывода ниже будет получено массив с одним соответствием с ключами слева от ":"" и значениями справа от ":"
// 		infobase : a6497ea3-0f8f-4943-a9d5-986a63e6437c
// 		name     : test123-vanessa-runner
// 		descr    : "vanessa runner test 123"
//
// Параметры:
//   Поток - Строка - лог команды rac
//
//  Возвращаемое значение:
//   Массив - массив результатов
//
Функция РазобратьПоток(Знач Поток) Экспорт

	ТД = Новый ТекстовыйДокумент;
	ТД.УстановитьТекст(Поток);

	СписокОбъектов = Новый Массив;
	ТекущийОбъект = Неопределено;

	Для Сч = 1 По ТД.КоличествоСтрок() Цикл

		Текст = ТД.ПолучитьСтроку(Сч);
		Если ПустаяСтрока(Текст) ИЛИ ТекущийОбъект = Неопределено Тогда
			Если ТекущийОбъект <> Неопределено И ТекущийОбъект.Количество() = 0 Тогда
				Продолжить; // очередная пустая строка подряд
			КонецЕсли;

			ТекущийОбъект = Новый Соответствие;
			СписокОбъектов.Добавить(ТекущийОбъект);
		КонецЕсли;

		СтрокаРазбораИмя      = "";
		СтрокаРазбораЗначение = "";

		Если РазобратьНаКлючИЗначение(Текст, СтрокаРазбораИмя, СтрокаРазбораЗначение) Тогда
			ТекущийОбъект[СтрокаРазбораИмя] = СтрокаРазбораЗначение;
		КонецЕсли;

	КонецЦикла;

	Если ТекущийОбъект <> Неопределено И ТекущийОбъект.Количество() = 0 Тогда
		СписокОбъектов.Удалить(СписокОбъектов.ВГраница());
	КонецЕсли;

	Возврат СписокОбъектов;

КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ЗапуститьПроцесс(Знач СтрокаВыполнения)

	Возврат ОбщиеМетоды.ЗапуститьПроцесс(СтрокаВыполнения);

КонецФункции

Функция НайтиБазуВКластере()

	ОписаниеКластера = ОписаниеКластера();
	Лог.Отладка("Найден идентификатор кластера %1", ОписаниеКластера.Идентификатор);

	КомандаВыполнения = СтрокаЗапускаКлиента() + СтрШаблон("infobase summary list --cluster=""%1""%2",
			ОписаниеКластера.Идентификатор,
			КлючиАвторизацииВКластере()) + " " + Настройки.АдресСервераАдминистрирования;

	Лог.Информация("Получаю список баз кластера");

	Базы = РазобратьПоток(ЗапуститьПроцесс(КомандаВыполнения));

	Для каждого База Из Базы Цикл
		Если Нрег(База.Получить("name")) = НРег(Настройки.ИмяИБ) Тогда
			ИдентификаторБазы = База.Получить("infobase");
			Лог.Отладка("Найден идентификатор базы %1", ИдентификаторБазы);

			Возврат ИдентификаторБазы;
		КонецЕсли;
	КонецЦикла;

	ВызватьИсключение "База " + Настройки.ИмяИБ + " не найдена в кластере";

КонецФункции

Функция РазобратьНаКлючИЗначение(Знач СтрокаРазбора, Ключ, Значение)

	ПозицияРазделителя = Найти(СтрокаРазбора, ":");
	Если ПозицияРазделителя = 0 Тогда
		Возврат Ложь;
	КонецЕсли;

	Ключ     = СокрЛП(Лев(СтрокаРазбора, ПозицияРазделителя - 1));
	Значение = СокрЛП(Сред(СтрокаРазбора, ПозицияРазделителя + 1));

	Возврат Истина;

КонецФункции

#КонецОбласти
