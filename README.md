Автоматизация повседневных операций 1С разработчика
==
 
[![Gitter](https://badges.gitter.im/silverbulleters/vanessa-runner.svg)](https://gitter.im/silverbulleters/vanessa-runner?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge) [![Build Status](http://ci.silverbulleters.org/buildStatus/icon?job=Vanessa-runner/master)](http://ci.silverbulleters.org/job/Vanessa-runner/job/master/) 
[![SonarQube Tech Debt](https://img.shields.io/sonar/https/sonar.silverbulleters.org/vanessa-runner/tech_debt.svg)](https://sonar.silverbulleters.org/dashboard?id=vanessa-runner)

Описание 
===

Библиотека проекта `oscript.io` для автоматизации различных операции для работы с `cf/cfe/epf` файлами и простой запуск `vanessa-behavior` и `xUnitFor1C` тестов.

Предназначена для организации разработки 1С в режиме, когда работа в git идет напрямую с исходниками или работаем через хранилище 1С.

Позволяет обеспечить единообразный запуск команд "локально" и на серверах сборки `CI-CD`


Установка
===

используйте пакетный менеджер `opm` из стандартной поставки дистрибутива `oscript.io`

```cmd
opm install vanessa-runner
```

при установке будет создан исполняемый файл `runner` в каталоге `bin` интерпретатора `oscript`.

После чего доступно выполнение команд через командную строку `runner <имя команды>`


Использование
===

Ключ `help` покажет справку по параметрам.

```cmd
runner help
```

или внутри батника (**ВАЖНО**) через `call`
```cmd
call runner help
```

В папке tools так же расположены примеры bat файлов для легкого запуска определенных действий.
Основной принцип - запустили bat файл с настроенными командами и получили результат.

В папке epf есть несколько обработок, позволяющих упростить развертывание/тестирование для конфигураций, основанных на БСП.

+ Основной пример (см. ниже пример вызова) - это передача через параметры /C команды "ЗапуститьОбновлениеИнформационнойБазы;ЗавершитьРаботуСистемы" и одновременная передача через /Execute"ЗакрытьПредприятие.epf".

  + При запуске с такими ключами подключается обработчик ожидания, который проверяет наличие формы с заголовком обновления и при окончании обновления завершает 1С:Предприятие. Данное действие необходимо для полного обновления информационной базы 1С:Предприятия, пока действует блокировка на фоновые задачи и запуск пользователей.

+ **ЗагрузитьРасширение** позволяет подключать разрешение в режиме предприятия и получать результат ошибки. Предназначено для подключения в конфигурациях, основанных на БСП. В параметрах /C передается путь к расширению и путь к файлу лога подключения.
+ **ЗагрузитьВнешниеОбработки** позволяет загрузить все внешние обработки и подключить в справочник "Дополнительные отчеты и обработки", т.к. их очень много то первым параметром идет каталог, вторым параметром путь к файлу лога. Все обработки обновляются согласно версиям.

Сборка обработок и конфигураций
===

Для сборки обработок необходимо иметь установленный oscript в переменной PATH и платформу выше 8.3.8

В командной строке нужно перейти в каталог с проектом и выполнить ```tools\compile_epf.bat```, по окончанию в каталоге build\epf должны появиться обработки.
Вся разработка в конфигураторе делается в каталоге build, по окончанию доработок запускаем ```tools\decompile_epf.bat```

Обязательно наличие установленного v8unpack версии не ниже 3.0.38 в переменной PATH. Установку можно взять https://github.com/dmpas/v8unpack#build

Примеры настройки и вызова
===

### 1. Создание ИБ из последней конфигурации хранилища 1С, обновление в режиме Предприятия и первоначальное заполнение ИБ


`1с-init.cmd` :
```cmd
@rem Полная инициализация из репозитария, обновление в режиме Предприятия и начальное заполнение ИБ ./build/ibservice

@rem Пример запуска 1с-init.cmd storage-user storage-password

@chcp 65001

@set RUNNER_IBNAME=/F./build/ibservice

@call runner init-dev --storage --storage-name http:/repo-1c --storage-user %1 --storage-pwd %2

@call runner run --command "ЗапуститьОбновлениеИнформационнойБазы;ЗавершитьРаботуСистемы;" --execute $runnerRoot\build\out\ЗакрытьПредприятие.epf

@call runner vanessa --settings tools/vrunner.first.json

@rem Если убрать комментарий из последней строки, тогда можно выполнять полный прогон bdd-фич
@rem @call runner vanessa --settings tools/vrunner.json
```

### 2. Вызов проверки поведения через vanessa-behavior

+ запуск `runner vanessa --settings tools/vrunner.json`
  + или внутри батника 
    + `call runner vanessa --settings tools/vrunner.json`

+ в данном примере фреймворк `vanessa-behavior` развернут как сабмодуль в каталоге ./tools/vanessa-behavior 

  + или вручную скопирован

+ vrunner.json:

```json
{
    "default": {
        "--ibconnection": "/F./build/ib",
        "--db-user": "Администратор",
        "--db-pwd": "",
        "--ordinaryapp": "0"
    },
    "vanessa": {
        "--vanessasettings": "./tools/VBParams.json",
        "--workspace": ".",
        "--pathvanessa": "./tools/vanessa-behavior/vanessa-behavior.epf",
        "--additional": "/DisplayAllFunctions /L ru"
    }
}
```

+ VBParams.json

```json
{
    "ВыполнитьСценарии": true,
    "ЗавершитьРаботуСистемы": true,
    "ЗакрытьTestClientПослеЗапускаСценариев": true,
    "КаталогФич": "$workspaceRoot/features/01-СистемаУправления",
    "СписокТеговИсключение": [
        "IgnoreOnCIMainBuild",
        "FirstStart",
        "Draft"
    ],
    "КаталогиБиблиотек": [
        "./features/Libraries"
    ],
    "ДелатьОтчетВФорматеАллюр": true,
    "КаталогOutputAllureБазовый": "$workspaceRoot/build/out/allure",
    "ДелатьОтчетВФорматеCucumberJson": true,
    "КаталогOutputCucumberJson": "$workspaceRoot/build/out/cucumber",
    "ВыгружатьСтатусВыполненияСценариевВФайл": true,
    "ПутьКФайлуДляВыгрузкиСтатусаВыполненияСценариев": "$workspaceRoot/build/out/vbStatus.log",
    "ДелатьЛогВыполненияСценариевВТекстовыйФайл": true,
    "ИмяФайлаЛогВыполненияСценариев": "$workspaceRoot/build/out/vbOnline.log"
}
```

### 3. Переопределение аргументов запуска

В случае необходимости переопределения параметров запуска используется схема приоритетов. 

Приоритет в порядке возрастания (от минимального до максимального приоритета)
+ `env.json(в корне проекта)` 
+ `--settings ../env.json(указание файла настроек вручную)`
+ `RUNNER_* (из переменных окружения)`
+ `--* (ключи командной строки)`

Описание:
+ На первоначальном этапе читаются настройки из файла настроек, указанного в ключе команды ```--settings tools/vrunner.json```
+ Потом, если настройка есть в переменной окружения, тогда берем из еe.
+ Если же настройка есть, как в файле json, так и в переменной окружения и непосредственно в командной строке, то берем настройку из командной строки.

Например:
  ### Переопределение переменной окружения:

  #### Установка значения.
    
  1. Допустим, в файле vrunner.json указана настройка
        ```json
        "--db-user":"Администратор"
        ```
        а нам для определенного случая надо переопределить имя пользователя, 
        тогда можно установить переменную: ```set RUNNER_DBUSER=Иванов``` и в данный параметр будет передано значение `Иванов`

  2. Очистка значения после установки 
        ```cmd
        set RUNNER_DBUSER=Иванов
        set RUNNER_DBUSER=
        ```
        в данном случаи установлено полностью пустое значение и имя пользователя будет взято из tools/vrunner.json, если оно там есть. 

  3. Установка пустого значения:
        ```cmd
        set RUNNER_DBUSER=""
        set RUNNER_DBUSER=''
        ```

        Если необходимо установить в поле пустое значение, тогда указываем кавычки и в параметр `--db-user` будет установлена пустая строка. 
        
  4. Переопределение через параметры командной строки. 
    
        Любое указание параметра в командной строке имеет наивысший приоритет.


Вывод отладочной информации
===

Управление выводом логов выполняется с помощью типовой для oscript-library настройки логирования через пакет logos.

Основной лог vanessa-runner имеет название ``oscript.app.vanessa-runner``.

## Примеры

Включение всех отладочных логов:

```bat
rem только для logos версии >=0.6
set LOGOS_CONFIG=logger.rootLogger=DEBUG

call vrunner <параметры запуска>
```

Если пишет, что неправильные параметры командной строки:

```bat
set LOGOS_CONFIG=logger.oscript.lib.cmdline=DEBUG
call vrunner <параметры запуска>
```

Включит отладочный лог только для библиотеки cmdline, которая анализирует параметры командной строки.
