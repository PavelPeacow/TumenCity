# TumenCity

## Требования
Компьютер на базе MacOS 14.0 и новее

IDE Xcode 15.0

## Замена API ключа YandexMapKit
Открыть файл по следующему пути App/AppDelegate.swift и вставить ключи в **YOUR_API_KEY**
```swift
YMKMapKit.setApiKey("YOUR_API_KEY")
```

## Установка библиотеки YabdexMapkit (нужно для запуска проекта в IDE)
Нвходясь в корне проекта (где находится Podfile) написать следующее
```ruby
pod install
```
Это создаст файл проекта xcworkspace

## Запуск
Открывать проект через созданный файл TumenCity.xcworkspace
