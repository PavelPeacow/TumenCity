//
//  Strings.swift
//  TumenCity
//
//  Created by Павел Кай on 14.05.2023.
//

import Foundation

struct Strings {
    
    private init() { }
    
    struct DigWorkFilterBottomSheet {
        
        private init() { }
        
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
        
        static let submitFilterBtnStrings = "Применить"
        static let clearFilterBtn = "Очистить"
    }
    
    #warning("Continue add strings, for separation")
    struct RegistryCardTableViewCell {
        
    }
    
    struct ModulesTitles {
        
    }
    
    struct MainMenuViewController {
        
    }
}
