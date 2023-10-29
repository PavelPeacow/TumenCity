//
//  ViewActionHandable.swift
//  TumenCity
//
//  Created by Павел Кай on 21.10.2023.
//

import YandexMapsMobile

protocol ViewActionAddAnnotationsHandable {
    func handleAddAnnotations(_ annotations: [YMKAnnotation])
}

protocol ViewActionCalloutHandable {
    func handleShowCallout(annotation: YMKAnnotation)
}

protocol ViewActionTapClusterHandable {
    func handleTapCluster(annotations: [YMKAnnotation])
}

protocol ViewActionSetLoadingHandable {
    func handleSetLoading(_ isLoading: Bool)
}

protocol ViewActionShowSnackbarHandable {
    func handleShowSnackbar(type: SnackBarView.SnackBarType)
}

protocol ViewActionMoveCameraToAnnotationHandable {
    func handleMoveToAnnotation(annotation: YMKAnnotation?)
}

extension ViewActionMoveCameraToAnnotationHandable {
    func handleMoveToAnnotation(annotation: YMKAnnotation?) {
        
    }
}

protocol LoadViewActionsHandable: ViewActionSetLoadingHandable,
                                  ViewActionShowSnackbarHandable { }

protocol ViewActionBaseMapHandable: ViewActionCalloutHandable,
                                     ViewActionTapClusterHandable,
                                     ViewActionAddAnnotationsHandable,
                                     LoadViewActionsHandable { }
