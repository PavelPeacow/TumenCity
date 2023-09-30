// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum BikePaths {
    /// Велодорожки
    internal static let title = L10n.tr("Localizable", "BikePaths.title", fallback: "Велодорожки")
  }
  internal enum ButtonTitle {
    /// Очистить
    internal static let clearFilterBtn = L10n.tr("Localizable", "ButtonTitle.clearFilterBtn", fallback: "Очистить")
    /// Применить
    internal static let submitFilterBtnStrings = L10n.tr("Localizable", "ButtonTitle.submitFilterBtnStrings", fallback: "Применить")
  }
  internal enum Callout {
    /// Закрыть
    internal static let close = L10n.tr("Localizable", "Callout.close", fallback: "Закрыть")
  }
  internal enum CityCleaning {
    /// Уборка города
    internal static let title = L10n.tr("Localizable", "CityCleaning.title", fallback: "Уборка города")
    internal enum Callout {
      /// Тип ТС:
      internal static let carType = L10n.tr("Localizable", "CityCleaning.callout.carType", fallback: "Тип ТС:")
      /// Подрядчик:
      internal static let contractor = L10n.tr("Localizable", "CityCleaning.callout.contractor", fallback: "Подрядчик:")
      /// Управляющая организация:
      internal static let council = L10n.tr("Localizable", "CityCleaning.callout.council", fallback: "Управляющая организация:")
      /// Скорость:
      internal static let iAmSpeed = L10n.tr("Localizable", "CityCleaning.callout.iAmSpeed", fallback: "Скорость:")
      /// Последнее обновление данных произошло в
      internal static let lastTimeUpdated = L10n.tr("Localizable", "CityCleaning.callout.lastTimeUpdated", fallback: "Последнее обновление данных произошло в")
    }
    internal enum Contractors {
      /// Управляющие организации:
      internal static let title = L10n.tr("Localizable", "CityCleaning.contractors.title", fallback: "Управляющие организации:")
    }
    internal enum Filter {
      /// Подрядчики
      internal static let contractors = L10n.tr("Localizable", "CityCleaning.filter.contractors", fallback: "Подрядчики")
      /// Показатели
      internal static let indicators = L10n.tr("Localizable", "CityCleaning.filter.indicators", fallback: "Показатели")
      /// Тип техники
      internal static let machineType = L10n.tr("Localizable", "CityCleaning.filter.machineType", fallback: "Тип техники")
      /// Выбранный индикатор
      internal static let selectedFilter = L10n.tr("Localizable", "CityCleaning.filter.selectedFilter", fallback: "Выбранный индикатор")
      /// Вид техники
      internal static let selectedMachine = L10n.tr("Localizable", "CityCleaning.filter.selectedMachine", fallback: "Вид техники")
    }
    internal enum Indicator {
      internal enum Callout {
        /// Передавали данные о местоположении техники за последние 3 суток: 
        internal static let activeDuringDay = L10n.tr("Localizable", "CityCleaning.indicator.callout.activeDuringDay", fallback: "Передавали данные о местоположении техники за последние 3 суток: ")
        /// Подрядчик: 
        internal static let contractor = L10n.tr("Localizable", "CityCleaning.indicator.callout.contractor", fallback: "Подрядчик: ")
        /// Заказчик: 
        internal static let council = L10n.tr("Localizable", "CityCleaning.indicator.callout.council", fallback: "Заказчик: ")
        /// Город
        internal static let councilPlaceholder = L10n.tr("Localizable", "CityCleaning.indicator.callout.councilPlaceholder", fallback: "Город")
        /// Всего техники: 
        internal static let countContractor = L10n.tr("Localizable", "CityCleaning.indicator.callout.countContractor", fallback: "Всего техники: ")
        /// Данные о местоположении техники
        /// день | ночь: 
        internal static let dayNight = L10n.tr("Localizable", "CityCleaning.indicator.callout.dayNight", fallback: "Данные о местоположении техники\nдень | ночь: ")
        /// Своевременность передачи данных: 
        internal static let timelinessData = L10n.tr("Localizable", "CityCleaning.indicator.callout.timelinessData", fallback: "Своевременность передачи данных: ")
      }
    }
    internal enum MachineType {
      /// Все
      internal static let switcthAllTitle = L10n.tr("Localizable", "CityCleaning.machineType.switcthAllTitle", fallback: "Все")
      /// Виды техники: 
      internal static let title = L10n.tr("Localizable", "CityCleaning.machineType.title", fallback: "Виды техники: ")
    }
  }
  internal enum CloseRoad {
    internal enum Callout {
      /// Период:
      internal static let datePeriod = L10n.tr("Localizable", "CloseRoad.Callout.datePeriod", fallback: "Период:")
      /// Описание:
      internal static let description = L10n.tr("Localizable", "CloseRoad.Callout.description", fallback: "Описание:")
    }
  }
  internal enum CommunalServices {
    internal enum Callout {
      /// Адрес:
      internal static let adress = L10n.tr("Localizable", "CommunalServices.callout.adress", fallback: "Адрес:")
      /// Дата окончания работ:
      internal static let dateFinish = L10n.tr("Localizable", "CommunalServices.callout.dateFinish", fallback: "Дата окончания работ:")
      /// Дата начала работ:
      internal static let dateStart = L10n.tr("Localizable", "CommunalServices.callout.dateStart", fallback: "Дата начала работ:")
      /// Устраняющая организация:
      internal static let organization = L10n.tr("Localizable", "CommunalServices.callout.organization", fallback: "Устраняющая организация:")
    }
  }
  internal enum DigWork {
    /// Земляные работы
    internal static let title = L10n.tr("Localizable", "DigWork.title", fallback: "Земляные работы")
    internal enum BottomSheet {
      /// Период осуществляемых работ после:
      internal static let dateAfterFilterString = L10n.tr("Localizable", "DigWork.bottomSheet.dateAfterFilterString", fallback: "Период осуществляемых работ после:")
      /// Период осуществляемых работ до:
      internal static let dateBeforeFilterString = L10n.tr("Localizable", "DigWork.bottomSheet.dateBeforeFilterString", fallback: "Период осуществляемых работ до:")
      /// Заинтересованное лицо
      internal static let personFilterString = L10n.tr("Localizable", "DigWork.bottomSheet.personFilterString", fallback: "Заинтересованное лицо")
      /// Статус
      internal static let statusFilterString = L10n.tr("Localizable", "DigWork.bottomSheet.statusFilterString", fallback: "Статус")
      /// Готово
      internal static let toolbarDone = L10n.tr("Localizable", "DigWork.bottomSheet.toolbarDone", fallback: "Готово")
      /// Цель работ
      internal static let typeOfWorkFilterString = L10n.tr("Localizable", "DigWork.bottomSheet.typeOfWorkFilterString", fallback: "Цель работ")
      /// Район
      internal static let zoneFilterString = L10n.tr("Localizable", "DigWork.bottomSheet.zoneFilterString", fallback: "Район")
      internal enum Status {
        /// Все
        internal static let all = L10n.tr("Localizable", "DigWork.bottomSheet.status.all", fallback: "Все")
        /// Завершенная работа
        internal static let completedWork = L10n.tr("Localizable", "DigWork.bottomSheet.status.completedWork", fallback: "Завершенная работа")
        /// Отказано
        internal static let denied = L10n.tr("Localizable", "DigWork.bottomSheet.status.denied", fallback: "Отказано")
        /// Ошибка
        internal static let error = L10n.tr("Localizable", "DigWork.bottomSheet.status.error", fallback: "Ошибка")
        /// Экспертиза
        internal static let expertise = L10n.tr("Localizable", "DigWork.bottomSheet.status.expertise", fallback: "Экспертиза")
        /// В работе
        internal static let inProgress = L10n.tr("Localizable", "DigWork.bottomSheet.status.inProgress", fallback: "В работе")
        /// Подано уведомление
        internal static let notificationSubmitted = L10n.tr("Localizable", "DigWork.bottomSheet.status.notificationSubmitted", fallback: "Подано уведомление")
        /// Зарегистрировано
        internal static let registered = L10n.tr("Localizable", "DigWork.bottomSheet.status.registered", fallback: "Зарегистрировано")
        /// Восстановление
        internal static let restoration = L10n.tr("Localizable", "DigWork.bottomSheet.status.restoration", fallback: "Восстановление")
        /// Ожидание восстановления в летнем варианте
        internal static let waitingForSummerRestoration = L10n.tr("Localizable", "DigWork.bottomSheet.status.waitingForSummerRestoration", fallback: "Ожидание восстановления в летнем варианте")
        /// Ожидание работы
        internal static let waitingForWork = L10n.tr("Localizable", "DigWork.bottomSheet.status.waitingForWork", fallback: "Ожидание работы")
        /// Гарантийный период
        internal static let warrantyPeriod = L10n.tr("Localizable", "DigWork.bottomSheet.status.warrantyPeriod", fallback: "Гарантийный период")
      }
      internal enum TypeOfWork {
        /// Аварии, инцидента на ИК
        internal static let accidentsIncidentsIK = L10n.tr("Localizable", "DigWork.bottomSheet.typeOfWork.accidentsIncidentsIK", fallback: "Аварии, инцидента на ИК")
        /// Все
        internal static let all = L10n.tr("Localizable", "DigWork.bottomSheet.typeOfWork.all", fallback: "Все")
        /// Установка/эксплуатация рекламных конструкций
        internal static let installationOperationAdvertisingStructures = L10n.tr("Localizable", "DigWork.bottomSheet.typeOfWork.installationOperationAdvertisingStructures", fallback: "Установка/эксплуатация рекламных конструкций")
        /// Реконструкция, перенос, переустройство, ремонт ИК
        internal static let reconstructionRelocationRepairIK = L10n.tr("Localizable", "DigWork.bottomSheet.typeOfWork.reconstructionRelocationRepairIK", fallback: "Реконструкция, перенос, переустройство, ремонт ИК")
        /// Технологическое присоединение к сетям ИТ
        internal static let technologicalConnectionITNetworks = L10n.tr("Localizable", "DigWork.bottomSheet.typeOfWork.technologicalConnectionITNetworks", fallback: "Технологическое присоединение к сетям ИТ")
      }
      internal enum Zones {
        /// Все
        internal static let all = L10n.tr("Localizable", "DigWork.bottomSheet.zones.all", fallback: "Все")
        /// ЦАО
        internal static let cao = L10n.tr("Localizable", "DigWork.bottomSheet.zones.CAO", fallback: "ЦАО")
        /// КАО
        internal static let kao = L10n.tr("Localizable", "DigWork.bottomSheet.zones.KAO", fallback: "КАО")
        /// ЛАО
        internal static let lao = L10n.tr("Localizable", "DigWork.bottomSheet.zones.LAO", fallback: "ЛАО")
        /// ВАО
        internal static let vao = L10n.tr("Localizable", "DigWork.bottomSheet.zones.VAO", fallback: "ВАО")
      }
    }
  }
  internal enum Empty {
    /// Нет доступных данных
    internal static let tableMessage = L10n.tr("Localizable", "Empty.tableMessage", fallback: "Нет доступных данных")
  }
  internal enum MapSegmentSwitcher {
    /// Карта
    internal static let map = L10n.tr("Localizable", "MapSegmentSwitcher.map", fallback: "Карта")
    /// Реестр
    internal static let registry = L10n.tr("Localizable", "MapSegmentSwitcher.registry", fallback: "Реестр")
  }
  internal enum SearchTextfield {
    /// Введите адрес...
    internal static let placeholder = L10n.tr("Localizable", "SearchTextfield.placeholder", fallback: "Введите адрес...")
  }
  internal enum SnackBar {
    /// Пропало соединение с интернетом!
    internal static let noConnection = L10n.tr("Localizable", "SnackBar.noConnection", fallback: "Пропало соединение с интернетом!")
    /// Нет доступной информации по заданному фильтру
    internal static let warning = L10n.tr("Localizable", "SnackBar.warning", fallback: "Нет доступной информации по заданному фильтру")
    /// Соединение с интернетом восстановлено!
    internal static let withConnection = L10n.tr("Localizable", "SnackBar.withConnection", fallback: "Соединение с интернетом восстановлено!")
  }
  internal enum Sport {
    /// Спорт
    internal static let title = L10n.tr("Localizable", "Sport.title", fallback: "Спорт")
    internal enum Callout {
      /// Адреса:
      internal static let addresses = L10n.tr("Localizable", "Sport.Callout.addresses", fallback: "Адреса:")
      /// Контакты:
      internal static let contacts = L10n.tr("Localizable", "Sport.Callout.contacts", fallback: "Контакты:")
      /// Электронная почта:
      internal static let email = L10n.tr("Localizable", "Sport.Callout.email", fallback: "Электронная почта:")
    }
  }
  internal enum TradeObjects {
    /// НТО
    internal static let title = L10n.tr("Localizable", "TradeObjects.title", fallback: "НТО")
    internal enum BottomSheet {
      /// Адрес местоположения
      internal static let address = L10n.tr("Localizable", "TradeObjects.bottomSheet.address", fallback: "Адрес местоположения")
      /// Тип объекта
      internal static let objectType = L10n.tr("Localizable", "TradeObjects.bottomSheet.objectType", fallback: "Тип объекта")
      /// Период функционирования
      internal static let period = L10n.tr("Localizable", "TradeObjects.bottomSheet.period", fallback: "Период функционирования")
      /// Целевое назначение
      internal static let purpose = L10n.tr("Localizable", "TradeObjects.bottomSheet.purpose", fallback: "Целевое назначение")
      internal enum Buttons {
        /// Убрать все
        internal static let deselectAll = L10n.tr("Localizable", "TradeObjects.bottomSheet.buttons.deselectAll", fallback: "Убрать все")
        /// Выбрать все
        internal static let selectAll = L10n.tr("Localizable", "TradeObjects.bottomSheet.buttons.selectAll", fallback: "Выбрать все")
      }
      internal enum CheckBoxPeriod {
        /// Круглогодичный
        internal static let allYear = L10n.tr("Localizable", "TradeObjects.bottomSheet.checkBoxPeriod.allYear", fallback: "Круглогодичный")
        /// Осенне-зимний период (с 10 октября до 20 апреля)
        internal static let autumnWinter = L10n.tr("Localizable", "TradeObjects.bottomSheet.checkBoxPeriod.autumnWinter", fallback: "Осенне-зимний период (с 10 октября до 20 апреля)")
        /// Период проведения массового мероприятия
        internal static let massEvent = L10n.tr("Localizable", "TradeObjects.bottomSheet.checkBoxPeriod.massEvent", fallback: "Период проведения массового мероприятия")
        /// Весенне-летний период (с 01 мая до 01 октября)
        internal static let springSummer = L10n.tr("Localizable", "TradeObjects.bottomSheet.checkBoxPeriod.springSummer", fallback: "Весенне-летний период (с 01 мая до 01 октября)")
        /// Зимний период (с 10 декабря по 10 января)
        internal static let winter = L10n.tr("Localizable", "TradeObjects.bottomSheet.checkBoxPeriod.winter", fallback: "Зимний период (с 10 декабря по 10 января)")
      }
      internal enum CheckBoxTypes {
        /// Елочный базар
        internal static let christmasMarket = L10n.tr("Localizable", "TradeObjects.bottomSheet.checkBoxTypes.christmasMarket", fallback: "Елочный базар")
        /// Киоск
        internal static let kiosk = L10n.tr("Localizable", "TradeObjects.bottomSheet.checkBoxTypes.kiosk", fallback: "Киоск")
        /// Павильон
        internal static let pavilion = L10n.tr("Localizable", "TradeObjects.bottomSheet.checkBoxTypes.pavilion", fallback: "Павильон")
        /// Пресс-стенд
        internal static let pressStand = L10n.tr("Localizable", "TradeObjects.bottomSheet.checkBoxTypes.pressStand", fallback: "Пресс-стенд")
        /// Холодильное оборудование
        internal static let refrigerationEquipment = L10n.tr("Localizable", "TradeObjects.bottomSheet.checkBoxTypes.refrigerationEquipment", fallback: "Холодильное оборудование")
        /// Ролл-бар
        internal static let rollBar = L10n.tr("Localizable", "TradeObjects.bottomSheet.checkBoxTypes.rollBar", fallback: "Ролл-бар")
        /// Лотки
        internal static let stalls = L10n.tr("Localizable", "TradeObjects.bottomSheet.checkBoxTypes.stalls", fallback: "Лотки")
        /// Палатка, лотки, холодильное оборудование, передвижное сооружение
        internal static let tentStallsRefrigeration = L10n.tr("Localizable", "TradeObjects.bottomSheet.checkBoxTypes.tentStallsRefrigeration", fallback: "Палатка, лотки, холодильное оборудование, передвижное сооружение")
        /// Вендинговый автомат
        internal static let vendingMachine = L10n.tr("Localizable", "TradeObjects.bottomSheet.checkBoxTypes.vendingMachine", fallback: "Вендинговый автомат")
      }
    }
    internal enum Callout {
      /// Округ: 
      internal static let area = L10n.tr("Localizable", "TradeObjects.callout.area", fallback: "Округ: ")
      /// Площадь, кв.м: 
      internal static let areaSquare = L10n.tr("Localizable", "TradeObjects.callout.areaSquare", fallback: "Площадь, кв.м: ")
      /// Срок действия договора: 
      internal static let dateDoc = L10n.tr("Localizable", "TradeObjects.callout.dateDoc", fallback: "Срок действия договора: ")
      /// НТО с действующими договорами: 
      internal static let filterActiveTitle = L10n.tr("Localizable", "TradeObjects.callout.filterActiveTitle", fallback: "НТО с действующими договорами: ")
      /// Свободные места: 
      internal static let filterFreeTitle = L10n.tr("Localizable", "TradeObjects.callout.filterFreeTitle", fallback: "Свободные места: ")
      /// Количество этажей: 
      internal static let floors = L10n.tr("Localizable", "TradeObjects.callout.floors", fallback: "Количество этажей: ")
      /// Высота, м: 
      internal static let height = L10n.tr("Localizable", "TradeObjects.callout.height", fallback: "Высота, м: ")
      /// Номер договора: 
      internal static let numDoc = L10n.tr("Localizable", "TradeObjects.callout.numDoc", fallback: "Номер договора: ")
      /// Параметры и характеристики нестационарного торгового объекта
      internal static let parametersTitle = L10n.tr("Localizable", "TradeObjects.callout.parametersTitle", fallback: "Параметры и характеристики нестационарного торгового объекта")
      /// Период функционирования: 
      internal static let period = L10n.tr("Localizable", "TradeObjects.callout.period", fallback: "Период функционирования: ")
      /// Целевое назначение: 
      internal static let purpose = L10n.tr("Localizable", "TradeObjects.callout.purpose", fallback: "Целевое назначение: ")
      /// Тип объекта: 
      internal static let typeObject = L10n.tr("Localizable", "TradeObjects.callout.typeObject", fallback: "Тип объекта: ")
      /// Наименование юридического лица: 
      internal static let urName = L10n.tr("Localizable", "TradeObjects.callout.urName", fallback: "Наименование юридического лица: ")
    }
  }
  internal enum UrbanImprovements {
    /// Благоустройство
    internal static let title = L10n.tr("Localizable", "UrbanImprovements.title", fallback: "Благоустройство")
    internal enum Callout {
      /// Период проведения работ:
      internal static let dateStart = L10n.tr("Localizable", "UrbanImprovements.callout.dateStart", fallback: "Период проведения работ:")
      /// Фото:
      internal static let photoTitle = L10n.tr("Localizable", "UrbanImprovements.callout.photoTitle", fallback: "Фото:")
      /// Стадия работ:
      internal static let stageWork = L10n.tr("Localizable", "UrbanImprovements.callout.stageWork", fallback: "Стадия работ:")
      /// Видео:
      internal static let videoTitle = L10n.tr("Localizable", "UrbanImprovements.callout.videoTitle", fallback: "Видео:")
      /// Вид работ:
      internal static let workType = L10n.tr("Localizable", "UrbanImprovements.callout.workType", fallback: "Вид работ:")
    }
    internal enum Filter {
      internal enum Buttons {
        /// Отменить фильтр
        internal static let cancelFilter = L10n.tr("Localizable", "UrbanImprovements.filter.buttons.cancelFilter", fallback: "Отменить фильтр")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
