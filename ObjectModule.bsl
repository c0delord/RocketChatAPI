﻿Функция ПроверитьСессию(Углубленно = Ложь)
	Возврат ЗначениеЗаполнено(user_id) И ЗначениеЗаполнено(auth_token);
	//Углубленно <> Ложь
	//curl -H "X-Auth-Token: *" \
	//     -H "X-User-Id: *" \
	//     http://localhost:3000/api/v1/me
КонецФункции

Функция ПолучитьАвторизационныеДанные() Экспорт
	констUserId		= Константы.rocketchat_user_id.СоздатьМенеджерЗначения();
	констUserId.Прочитать();
	
	констAuthToken	= Константы.rocketchat_auth_token.СоздатьМенеджерЗначения();
	констAuthToken.Прочитать();
	
	
	user_id		= констUserId.Значение;
	auth_token	= констAuthToken.Значение;
КонецФункции

Функция Аутентификация(Логин, Пароль) Экспорт
	//curl -H "Content-type:application/json" \
	//      http://localhost:3000/api/v1/login \
	//      -d '{ "user": "my@email.com", "password": "mypassword" }'
	user_id			= Неопределено;
	auth_token		= Неопределено;
	
	ПакетЗапроса 	= Новый Структура();
	ПакетЗапроса.Вставить("user", 	Логин);
	ПакетЗапроса.Вставить("password", 	Пароль);

	ЗаписьJSON 		= Новый ЗаписьJSON();
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, ПакетЗапроса);
	НагрузкаJSON 	= ЗаписьJSON.Закрыть();
	
	РезультатМетода = ВыполнитьМетодAPI("login",, НагрузкаJSON, Ложь);
	Если РезультатМетода = Неопределено Тогда
		Сообщить("Не удалось авторизоваться");
		Возврат 0;
	КонецЕсли;
	////------------------------------- TEST
	//Чтение = Новый ЧтениеJSON;
	//Чтение.УстановитьСтроку( "{""status"":""success"",""data"":{""authToken"":""*"",""userId"":""*"",""me"":{""_id"":""aYjNnig8BEAWeQzMh"",""name"":""RocketCat"",""emails"":[{""address"":""rocket.cat@rocket.chat"",""verified"":false}],""status"":""offline"",""statusConnection"":""offline"",""username"":""rocket.cat"",""utcOffset"":-3,""active"":true,""roles"":[""admin""],""settings"":{""preferences"":{}},""avatarUrl"":""http://localhost:3000/avatar/test""}}}" );
	//РезультатМетода = ПрочитатьJSON(Чтение);
	////-------------------------------
	
	Если РезультатМетода["status"] = "success" Тогда
		user_id		= РезультатМетода["data"]["userId"];
		auth_token 	= РезультатМетода["data"]["authToken"];
		Возврат 1;
	ИначеЕсли РезультатМетода["status"] = "error"  Тогда
		Сообщить("Ошибка: " + РезультатМетода["message"]);
		Возврат 0;
	Иначе
		Возврат 0;
	КонецЕсли;
КонецФункции

Функция ОбновитьСписокПользователей(ФизЛицо = Неопределено) 
	//curl -H "X-Auth-Token: *" \
	//     -H "X-User-Id: *" \
	//     http://localhost:3000/api/v1/users.list
	Всего			= 1;
	КолНаЗапрос 	= 100;
	Отступ			= 0;
	Извлечено		= 0;
	ФильтрОтбора	= Неопределено;
	
	Если ЗначениеЗаполнено(ФизЛицо) Тогда
		ПакетЗапроса 	= Новый Структура();
		ПакетЗапроса.Вставить("name", 	ФизЛицо.Наименование);
		ЗаписьJSON 		= Новый ЗаписьJSON();                      
	    ПараметрыЗаписиJSON = Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Нет);
	    ЗаписьJSON.УстановитьСтроку(ПараметрыЗаписиJSON);		
		ЗаписатьJSON(ЗаписьJSON, ПакетЗапроса);
		ФильтрОтбора 	= "query=" + ЗаписьJSON.Закрыть();	
	КонецЕсли;
		
	Пока Истина Цикл 
		ПараметрыЗапроса 	= "offset=" + Формат(Отступ, "ЧГ=0") + "&count=" + Формат(КолНаЗапрос, "ЧГ=0");
		ПараметрыЗапроса 	= ?(Неопределено <> ФильтрОтбора, ПараметрыЗапроса + "&" + ФильтрОтбора, ПараметрыЗапроса); 
		
		РезультатМетода		= ВыполнитьМетодAPI("users.list", ПараметрыЗапроса, Неопределено);	
		////------------------------------- TEST
		//Чтение = Новый ЧтениеJSON;
		//Чтение.УстановитьСтроку( "{""users"":[{""_id"":""nSYqWzZ4GsKTX4dyK"",""type"":""user"",""status"":""offline"",""active"":true,""name"":""ExampleUser"",""utcOffset"":0,""username"":""example""},{""_id"":""2"",""type"":""user"",""status"":""offline"",""active"":true,""name"":""test2"",""utcOffset"":0,""username"":""example2""},{""_id"":""3"",""type"":""user"",""status"":""offline"",""active"":true,""name"":""test3"",""utcOffset"":0,""username"":""example3""},],""count"":3,""offset"":0,""total"":3,""success"":true}");
		//РезультатМетода = ПрочитатьJSON(Чтение);
		////-------------------------------
	
		Если Не РезультатМетода["success"] Тогда
			Сообщить("Метод получения списка пользователей выполнен неуспешно.");
			Возврат 0;
		КонецЕсли;
		Если РезультатМетода["users"].Количество() = 0 Тогда  //РезультатМетода["users"]
			Прервать;
		КонецЕсли;
		
		Всего	= РезультатМетода["total"];
		Для Каждого НовыйПользователь Из РезультатМетода["users"] Цикл
			
			НайденноеСоответствие	= НайтиФизЛицо(НовыйПользователь["name"]);
			Если НайденноеСоответствие <> Неопределено Тогда
				
				МенеджерЗаписи 				= РегистрыСведений.ПользователиRocketChat.СоздатьМенеджерЗаписи();
				МенеджерЗаписи.Пользователь = НайденноеСоответствие.Ссылка;
				
				МенеджерЗаписи.Прочитать();
				Если Не МенеджерЗаписи.Выбран() Тогда
					МенеджерЗаписи.Пользователь 			= НайденноеСоответствие.Ссылка;
					МенеджерЗаписи.РазрешитьУведомления 	= Ложь;
				КонецЕсли;
				
				МенеджерЗаписи.Id	= НовыйПользователь["_id"];
				МенеджерЗаписи.Записать();
			КонецЕсли;
		
		КонецЦикла;
		Извлечено   = Извлечено + РезультатМетода["users"].Количество();	
		Отступ 		= Отступ + КолНаЗапрос;
		КолНаЗапрос = Мин(КолНаЗапрос, Всего - Извлечено);
		
		Если Отступ >= Всего ИЛИ КолНаЗапрос = 0 Тогда
			Прервать;
		КонецЕсли;

		//HTTP 429 Too Many Requests 
		ПаузаПустымЦиклом(1);
	КонецЦикла;	
	Возврат 1;
КонецФункции

Функция ОтправитьСообщение(Id, Сообщение) 
	//curl -H "X-Auth-Token: *" \
	//     -H "X-User-Id: *" \
	//     -H "Content-type:application/json" \
	//     http://localhost:3000/api/v1/chat.postMessage \
	//     -d '{ "channel": "#general", "text": "This is a test!" }'	
	ПакетЗапроса 	= Новый Структура();
	ПакетЗапроса.Вставить("channel", Id);
	ПакетЗапроса.Вставить("text", Сообщение);
	
	ЗаписьJSON 		= Новый ЗаписьJSON();
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, ПакетЗапроса);
	НагрузкаJSON 	= ЗаписьJSON.Закрыть();


	РезультатМетода = ВыполнитьМетодAPI("chat.postMessage",, НагрузкаJSON);
	////------------------------------- TEST
	//Чтение = Новый ЧтениеJSON;
	//Чтение.УстановитьСтроку( "{""ts"":1481748965123,""channel"":""general"",""message"":{""alias"":"""",""msg"":""Thisisatest!"",""parseUrls"":true,""groupable"":false,""ts"":""2016-12-14T20:56:05.117Z"",""u"":{""_id"":""y65tAmHs93aDChMWu"",""username"":""graywolf336""},""rid"":""GENERAL"",""_updatedAt"":""2016-12-14T20:56:05.119Z"",""_id"":""jC9chsFddTvsbFQG7""},""success"":true}" );
	//РезультатМетода = ПрочитатьJSON(Чтение);
	////-------------------------------
	
	Если РезультатМетода.Получить("success") <> Неопределено Тогда
		Возврат РезультатМетода["success"];
	ИначеЕсли РезультатМетода.Получить("error") <> Неопределено Тогда
		Сообщить("Ошибка: " + РезультатМетода["error"]);
		Возврат 0;
	Иначе
		Сообщить("Неизвестная ошибка.");
		Возврат 0;
	КонецЕсли;
КонецФункции

Функция ВыполнитьМетодAPI(Метод, ПараметрыURL = Неопределено, НагрузкаJSON = Неопределено, ТребуетсяАвторизация = Истина, НомерПопытки = 0)
	Если ТребуетсяАвторизация И Не ПроверитьСессию() И НомерПопытки = 0 Тогда
		ВызватьИсключение НСтр("ru = 'Пользователь не авторизован.'");
		Возврат Неопределено;
	КонецЕсли;
	Если НомерПопытки > 1 Тогда
		Сообщить("Авторизационная сессия устарела. Не удалось обновить сессию.");
		Возврат Новый Соответствие();
	КонецЕсли;
	НомерПопытки = НомерПопытки + 1;

	
	ЭндПт = "/api/v1/" + Метод;
	ЭндПт = ?(ПараметрыURL <> Неопределено, ЭндПт + "?" + ПараметрыURL, ЭндПт);
	
	ЗащищенноеСоединение = Новый ЗащищенноеСоединениеOpenSSL();
	БезопасноеСоединение = Новый HTTPСоединение(Адрес,Порт,,,,,ЗащищенноеСоединение);
	
	Запрос = Новый HTTPЗапрос(ЭндПт);
	Запрос.Заголовки.Вставить("Content-type", "application/json");
	
	Если ТребуетсяАвторизация Тогда
		Запрос.Заголовки.Вставить("X-Auth-Token", 	auth_token);
		Запрос.Заголовки.Вставить("X-User-Id", 		user_id);
	КонецЕсли;

	JSONОтвет = "";
	Если НагрузкаJSON <> Неопределено Тогда
		//POST METHOD
		Запрос.УстановитьТелоИзСтроки(НагрузкаJSON, "utf-8", ИспользованиеByteOrderMark.НеИспользовать);
		Попытка
			Ответ 		= БезопасноеСоединение.ОтправитьДляОбработки(Запрос);
			JSONОтвет 	= Ответ.ПолучитьТелоКакСтроку();
		Исключение
			Сообщить(ОписаниеОшибки());
			Возврат Неопределено;
		КонецПопытки;	
	Иначе
		//GET METHOD
		Попытка
			Ответ 		= БезопасноеСоединение.Получить(Запрос);
			JSONОтвет 	= Ответ.ПолучитьТелоКакСтроку();
		Исключение
			Сообщить(ОписаниеОшибки());
			Возврат Неопределено;
		КонецПопытки;
	КонецЕсли;
	
	Чтение = Новый ЧтениеJSON;
	Чтение.УстановитьСтроку( JSONОтвет );	
	Попытка	
		РезультатЗапроса = ПрочитатьJSON(Чтение, Истина);
	Исключение
		Сообщить(ОписаниеОшибки());
		Возврат Неопределено;
	КонецПопытки;

	Если Ответ.КодСостояния <> 200 Тогда
		Сообщить("Метод <" + Метод + "> Сервер вернул код: " + Строка(Ответ.КодСостояния));
	КонецЕсли;
	
	//На случай, если устареет auth_token
	Если РезультатЗапроса.Получить("message") <> Неопределено Тогда				
		Если РезультатЗапроса["message"] = "You must be logged in to do this." Тогда
			ОбновитьСессию();
			Возврат ВыполнитьМетодAPI(Метод, ПараметрыURL, НагрузкаJSON, ТребуетсяАвторизация, НомерПопытки)
			//ОтправитьСообщение(Id, Сообщение, НомерПопытки);
		КонецЕсли;
	КонецЕсли;
	//
	
	Возврат РезультатЗапроса;	
КонецФункции

Функция НайтиПользователя(ФизЛицо) 
	Результат = Неопределено;
	ЗапросПоследних = Новый Запрос("ВЫБРАТЬ
	                               |	ПользователиRocketChat.Пользователь,
	                               |	ПользователиRocketChat.Id,
	                               |	ПользователиRocketChat.РазрешитьУведомления
	                               |ИЗ
	                               |	РегистрСведений.ПользователиRocketChat КАК ПользователиRocketChat
	                               |ГДЕ
	                               |	ПользователиRocketChat.Пользователь = &Пользователь");
	ЗапросПоследних.УстановитьПараметр("Пользователь", ФизЛицо);
	Выборка = ЗапросПоследних.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Результат = Выборка; 
	КонецЦикла;
	Возврат Результат;
КонецФункции

Функция НайтиФизЛицо(ФИО) 
	Результат = Неопределено;
	ЗапросПоследних = Новый Запрос("ВЫБРАТЬ
	                               |	ФизическиеЛица.Ссылка
	                               |ИЗ
	                               |	Справочник.ФизическиеЛица КАК ФизическиеЛица
	                               |ГДЕ
	                               |	ФизическиеЛица.Наименование = &ФИО");
	ЗапросПоследних.УстановитьПараметр("ФИО", ФИО);
	Выборка = ЗапросПоследних.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Результат = Выборка; 
	КонецЦикла;
	Возврат Результат;
КонецФункции


Процедура ПаузаПустымЦиклом(Секунды)	 
	ВремяОкончания = ТекущаяДата() + Секунды;
	Пока ТекущаяДата() <= ВремяОкончания Цикл	
	КонецЦикла;
КонецПроцедуры 

Процедура УстановитьАдресПоУмолчанию() Экспорт
	Адрес		= "chat.skl.ru";
	Порт		= 443;
КонецПроцедуры

Процедура УведомитьПользователя(Получатель, Сообщение) Экспорт
	ПользовательПолучатель 	= НайтиПользователя(Получатель);
	
	Если ПользовательПолучатель = Неопределено Тогда 
		ОбновитьСписокПользователей(Получатель);
		ПользовательПолучатель = НайтиПользователя(Получатель);
		Если ПользовательПолучатель = Неопределено Тогда
			Сообщить("Пользователь с именем <" + Получатель + "> не найден, отправка невозможна.");
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	Если ПользовательПолучатель.РазрешитьУведомления Тогда
		ПользовательId 	= ПользовательПолучатель.Id;
		ОтправитьСообщение(ПользовательId, Сообщение);
	Иначе
		Сообщить("У пользователя <" + Получатель + "> отключены уведомления в регистре ПользователиRocketChat");
	КонецЕсли;
КонецПроцедуры

Процедура ОбновитьСессию()
	констUsername	= Константы.rocketchat_username.СоздатьМенеджерЗначения();
	констUsername.Прочитать();
	констPassword	= Константы.rocketchat_password.СоздатьМенеджерЗначения();
	констPassword.Прочитать();
	
	Логин	= констUsername.Значение;
	Пароль	= констPassword.Значение;
	Аутентификация(Логин, Пароль);
	
	констUserId 			= Константы.rocketchat_user_id.СоздатьМенеджерЗначения();
    констAuthToken			= Константы.rocketchat_auth_token.СоздатьМенеджерЗначения();	
	констUserId.Значение	= user_id;
	констAuthToken.Значение	= auth_token;
	констUserId.Записать();
    констAuthToken.Записать();
КонецПроцедуры
















