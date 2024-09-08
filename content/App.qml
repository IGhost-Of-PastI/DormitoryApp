// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

import QtQuick 6.2
import Dormitory
import content

Window {

    width: Constants.width
    height: Constants.height

    visible: true
    title: "Dormitory"

    BackupsPage {
        id: mainScreen
    }

}

