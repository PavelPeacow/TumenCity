//
//  Strings.swift
//  TumenCity
//
//  Created by Павел Кай on 14.05.2023.
//

import Foundation

enum Strings {
    
    enum ButtonTitle {
        static let submitFilterBtnStrings = "Применить"
        static let clearFilterBtn = "Очистить"
    }
    
    enum CommunalServicesModule {
        
        enum CommunalServiceCallout {
            static let adress = "Адрес:"
            static let organization = "Устраняющая организация:"
            static let dateStart = "Дата начала работ:"
            static let dateFinish = "Дата окончания работ:"
        }
    }
    
    enum CloseRoadModule {
        
        enum CloseRoadCallout {
            static let description = "Описание:"
            static let datePeriod = "Период:"
        }
    }
    
    enum UrbanImprovementsModule {
        
        enum UrbanImprovementsCallout {
            static let photoTitle = "Фото:"
            static let videoTitle = "Видео:"
            static let stageWork = "Стадия работ:"
            static let dateStart = "Период проведения работ:"
            static let workType = "Вид работ:"
        }
    }
    
    enum CityCleaningModule {
        
        enum CityCleaningCallout {
            static let lastTimeUpdated = "Последнее обновление данных произошло в"
            static let council = "Управляющая организация:"
            static let contractor = "Подрядчик:"
            static let carType = "Тип ТС:"
            static let iAmSpeed = "Скорость:"
        }
    }
    
    enum SportModule {
        
        enum SportCallout {
            static let email = "Электронная почта:"
            static let contacts = "Контакты:"
            static let addresses = "Адреса:"
        }
    }
    
    enum DigWorkFilterBottomSheet {
        
        static let zones = ["Все", "ВАО", "ЦАО", "ЛАО", "КАО"]
        
        static let typeOfWork = ["Все", "Реконструкция, перенос, переустройство, ремонт ИК", "Аварии, инцидента на ИК",
                                 "Технологическое присоединение к сетям ИТ", "Установка/эксплуатация рекламных конструкций"]
        
        static let status = ["Все", "Подано уведомление", "Зарегистрировано", "Отказано", "Ожидание работы",
                             "В работе", "Восстановление", "Гарантийный период", "Завершенная работа", "Экспертиза",
                             "Ожидание восстановления в летнем варианте", "Ошибка"]
        
        static let personFilterString = "Заинтересованное лицо"
        static let zoneFilterString = "Район"
        static let typeOfWorkFilterString = "Цель работ"
        static let statusFilterString = "Статус"
        static let dateAfterFilterString = "Период осуществляемых работ после:"
        static let dateBeforeFilterString = "Период осуществляемых работ до:"
    }
    
#warning("Continue add strings, for separation")
    enum RegistryCardTableViewCell {
        
    }
    
    enum ModulesTitles {
        
    }
    
    enum MainMenuViewController {
        
    }
    
    enum TradeObjectsModule {
        static let filterActiveTitle = "НТО с действующими договорами: "
        static let filterFreeTitle = "Свободные места: "
        
        static let urName = "Наименование юридического лица: "
        static let numDoc = "Номер договора: "
        static let dateDoc = "Срок действия договора: "
        static let area = "Округ: "
        static let typeObject = "Тип объекта: "
        static let purpose = "Целевое назначение: "
        static let period = "Период функционирования: "
        
        static let parametersTitle = "Параметры и характеристики нестационарного торгового объекта"
        
        static let areaSquare = "Площадь, кв.м: "
        static let floors = "Количество этажей: "
        static let height = "Высота, м: "
        
        enum BottomSheet {
            static let address = "Адрес местоположения"
            static let purpose = "Целевое назначение"
            static let objectType = "Тип объекта"
            static let period = "Период функционирования"
            
            static let checkBoxTypes = ["Павильон", "Киоск", "Ролл-бар", "Холодильное оборудование",
                                        "Лотки", "Пресс-стенд", "Палатка, лотки, холодильное оборудование, передвижное сооружение",
                                        "Вендинговый автомат", "Елочный базар"]
            
            static let checkBoxPeriod = ["Круглогодичный", "Весенне-летний период (с 01 мая до 01 октября)",
                                         "Период проведения массового мероприятия",
                                         "Осенне-зимний период (с 10 октября до 20 апреля)",
                                         "Зимний период (с 10 декабря по 10 января)"]
        }
    }
}
