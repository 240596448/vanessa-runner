#language: ru

Функционал: Загрузка расширений в режиме Предприятие
    Как разработчик
    Я хочу иметь возможность загрузить расширения конфигурации из файла
    В т.ч с отключение безопасного режима и\или защиты от опасных действий
    Универсально для любой конфигурации
    Чтобы выполнять коллективную разработку проекта 1С

Сценарий: Загрузка расширения из файла с отключением безопасного режима и защиты от опасных действий

    Дано я подготовил репозиторий и рабочий каталог проекта
    И я подготовил рабочую базу проекта "./build/ib" по умолчанию
    Дано Я копирую файл "Extension1.cfe" из каталога "tests/fixtures" проекта в рабочий каталог
    И Я очищаю параметры команды "oscript" в контексте

    Когда Я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os compileepf $runnerRoot\epf\ЗагрузитьРасширениеВРежимеПредприятия ЗагрузитьРасширениеВРежимеПредприятия.epf --nocacheuse --language ru"
    И Я показываю вывод команды
    И Код возврата команды "oscript" равен 0
    И Я очищаю параметры команды "oscript" в контексте

    Когда Я добавляю параметр "<КаталогПроекта>/src/main.os run" для команды "oscript"
    И Я добавляю параметр "--command" для команды "oscript"
    И Я добавляю параметр "Путь=Extension1.cfe;Имя=Расширение1;Перезаписывать" для команды "oscript"
    # И Я добавляю параметр "ИмяРасширения=Расширение1;БезопасныйРежим;ЗащитаОтОпасныхДействий;ОтключитьЛогикуНачалаРаботыСистемы;ЗавершитьРаботуСистемы" для команды "oscript"
    И Я добавляю параметр "--execute ЗагрузитьРасширениеВРежимеПредприятия.epf" для команды "oscript"
    И Я добавляю параметр " --ibconnection /Fbuild/ib" для команды "oscript"
    И Я добавляю параметр "--language ru" для команды "oscript"
    Когда Я выполняю команду "oscript"

    И Я показываю вывод команды

    Тогда Вывод команды "oscript" содержит
        | ИНФОРМАЦИЯ - Выполняю команду/действие в режиме 1С:Предприятие |
        | Информация: Установлено расширение Расширение1, версия |
        | Информация: Безопасный режим снят! |
        | Информация: Защита от опасных действий снята! |
        | ИНФОРМАЦИЯ - Выполнение команды/действия в режиме 1С:Предприятие завершено |
    Тогда Вывод команды "oscript" не содержит
        | Ошибка: Неудача при обработке параметров запуска |
        | Ошибка: Неудача при выполнении основного кода |
    И Код возврата команды "oscript" равен 0

Сценарий: Повторная загрузка расширения из файла с отключением безопасного режима и защиты от опасных действий

    Дано я подготовил репозиторий и рабочий каталог проекта
    И я подготовил рабочую базу проекта "./build/ib" по умолчанию
    Дано Я копирую файл "Extension1.cfe" из каталога "tests/fixtures" проекта в рабочий каталог
    И Я очищаю параметры команды "oscript" в контексте

    Когда Я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os compileepf $runnerRoot\epf\ЗагрузитьРасширениеВРежимеПредприятия ЗагрузитьРасширениеВРежимеПредприятия.epf --nocacheuse --language ru"
    И Я показываю вывод команды
    И Код возврата команды "oscript" равен 0
    И Я очищаю параметры команды "oscript" в контексте

    Когда Я добавляю параметр "<КаталогПроекта>/src/main.os run" для команды "oscript"
    И Я добавляю параметр "--command" для команды "oscript"
    И Я добавляю параметр "Путь=Extension1.cfe;Имя=Расширение1;Перезаписывать" для команды "oscript"
    И Я добавляю параметр "--execute ЗагрузитьРасширениеВРежимеПредприятия.epf" для команды "oscript"
    И Я добавляю параметр " --ibconnection /Fbuild/ib" для команды "oscript"
    И Я добавляю параметр "--language ru" для команды "oscript"
    Когда Я выполняю команду "oscript"

    И Я показываю вывод команды

    Когда Я выполняю команду "oscript"
    И Я показываю вывод команды

    Тогда Вывод команды "oscript" содержит
        | ИНФОРМАЦИЯ - Выполняю команду/действие в режиме 1С:Предприятие |
        | Информация: Расширение не удалось установить. Пытаюсь удалить существующее расширение по имени и повторно установить |
        | Информация: Установлено расширение Расширение1, версия |
        | Информация: Безопасный режим снят! |
        | Информация: Защита от опасных действий снята! |
        | ИНФОРМАЦИЯ - Выполнение команды/действия в режиме 1С:Предприятие завершено |
    Тогда Вывод команды "oscript" не содержит
        | Ошибка: Неудача при обработке параметров запуска |
        | Ошибка: Неудача при выполнении основного кода |
    И Код возврата команды "oscript" равен 0

Сценарий: Неудачная загрузка несуществующего расширения из файла с отключением безопасного режима и защиты от опасных действий

    Дано я подготовил репозиторий и рабочий каталог проекта
    И я подготовил рабочую базу проекта "./build/ib" по умолчанию
    Дано Я копирую файл "Extension1.cfe" из каталога "tests/fixtures" проекта в рабочий каталог
    И Я очищаю параметры команды "oscript" в контексте

    Когда Я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os compileepf $runnerRoot\epf\ЗагрузитьРасширениеВРежимеПредприятия ЗагрузитьРасширениеВРежимеПредприятия.epf --nocacheuse --language ru"
    И Я показываю вывод команды
    И Код возврата команды "oscript" равен 0
    И Я очищаю параметры команды "oscript" в контексте

    Когда Я добавляю параметр "<КаталогПроекта>/src/main.os run" для команды "oscript"
    И Я добавляю параметр "--command" для команды "oscript"
    И Я добавляю параметр "Путь=Несуществующее.cfe;Имя=НесуществующееРасширение1;Перезаписывать" для команды "oscript"
    И Я добавляю параметр "--execute ЗагрузитьРасширениеВРежимеПредприятия.epf" для команды "oscript"
    И Я добавляю параметр " --ibconnection /Fbuild/ib" для команды "oscript"
    И Я добавляю параметр "--language ru" для команды "oscript"
    Когда Я выполняю команду "oscript"

    И Я показываю вывод команды

    Тогда Вывод команды "oscript" содержит
        | ИНФОРМАЦИЯ - Выполняю команду/действие в режиме 1С:Предприятие |
        | Ошибка: Неудача при выполнении основного кода |
        | Файл не обнаружен 'Несуществующее.cfe' |
        | ИНФОРМАЦИЯ - Выполнение команды/действия в режиме 1С:Предприятие завершено |
    Тогда Вывод команды "oscript" не содержит
        | Информация: Установлено расширение |
        | Информация: Безопасный режим снят! |
        | Информация: Защита от опасных действий снята! |
    И Код возврата команды "oscript" равен 0

Сценарий: Загрузка расширений из каталога

    Дано я подготовил репозиторий и рабочий каталог проекта
    И я подготовил рабочую базу проекта "./build/ib" по умолчанию
    Дано Я копирую файл "Extension1.cfe" из каталога "tests/fixtures" проекта в рабочий каталог
    И Я очищаю параметры команды "oscript" в контексте

    Когда Я выполняю команду "oscript" с параметрами "<КаталогПроекта>/src/main.os compileepf $runnerRoot\epf\ЗагрузитьРасширениеВРежимеПредприятия ЗагрузитьРасширениеВРежимеПредприятия.epf --nocacheuse --language ru"
    И Я показываю вывод команды
    И Код возврата команды "oscript" равен 0
    И Я очищаю параметры команды "oscript" в контексте

    Когда Я добавляю параметр "<КаталогПроекта>/src/main.os run" для команды "oscript"
    И Я добавляю параметр "--command" для команды "oscript"
    И Я добавляю параметр "Путь=.;Перезаписывать" для команды "oscript"
    # И Я добавляю параметр "--execute $runnerRoot\epf\ЗагрузитьРасширениеВРежимеПредприятия.epf" для команды "oscript"
    И Я добавляю параметр "--execute ЗагрузитьРасширениеВРежимеПредприятия.epf" для команды "oscript"
    И Я добавляю параметр " --ibconnection /Fbuild/ib" для команды "oscript"
    И Я добавляю параметр "--language ru" для команды "oscript"
    Когда Я выполняю команду "oscript"

    И Я показываю вывод команды

    Тогда Вывод команды "oscript" содержит
        | ИНФОРМАЦИЯ - Выполняю команду/действие в режиме 1С:Предприятие |
        | Информация: Установлено расширение Расширение1, версия |
        | Информация: Безопасный режим снят! |
        | Информация: Защита от опасных действий снята! |
        | ИНФОРМАЦИЯ - Выполнение команды/действия в режиме 1С:Предприятие завершено |
    Тогда Вывод команды "oscript" не содержит
        | Ошибка: Неудача при обработке параметров запуска |
        | Ошибка: Неудача при выполнении основного кода |
    И Код возврата команды "oscript" равен 0
