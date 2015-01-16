/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtTest 1.0
import ".."
import "../../../qml/Greeter"
import AccountsService 0.1
import LightDM 0.1 as LightDM
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Rectangle {
    color: "darkblue"
    width: units.gu(60)
    height: units.gu(80)

    Button {
        anchors.centerIn: parent
        text: "Show Greeter"
        onClicked: {
            if (greeterLoader.item)
                greeterLoader.item.show();
        }
    }

    Loader {
        id: greeterLoader
        anchors.fill: parent

        property bool itemDestroyed: false

        sourceComponent: Component {
            Greeter {
                width: greeterLoader.width
                height: greeterLoader.height

                Component.onDestruction: {
                    greeterLoader.itemDestroyed = true;
                }
                SignalSpy {
                    objectName: "selectedSpy"
                    target: parent
                    signalName: "selected"
                }
            }
        }
    }

    SignalSpy {
        id: unlockSpy
        target: greeterLoader.item
        signalName: "unlocked"
    }

    SignalSpy {
        id: tappedSpy
        target: greeterLoader.item
        signalName: "tapped"
    }

    UT.UnityTestCase {
        name: "SingleGreeter"
        when: windowShown

        property Greeter greeter: greeterLoader.item

        function cleanup() {
            AccountsService.statsWelcomeScreen = true

            // force a reload so that we get a fresh Greeter for the next test
            greeterLoader.itemDestroyed = false;
            greeterLoader.active = false;
            tryCompare(greeterLoader, "itemDestroyed", true);

            unlockSpy.clear();
            tappedSpy.clear();

            greeterLoader.active = true;
            tryCompare(greeterLoader, "status", Loader.Ready);
            removeTimeConstraintsFromDirectionalDragAreas(greeterLoader.item);
        }

        function test_properties() {
            compare(greeter.multiUser, false)
            compare(greeter.narrowMode, true)
        }

        function test_statsWelcomeScreen() {
            // Test logic in greeter that turns statsWelcomeScreen setting into infographic changes
            compare(AccountsService.statsWelcomeScreen, true)
            tryCompare(LightDM.Infographic, "username", "single")
            AccountsService.statsWelcomeScreen = false
            tryCompare(LightDM.Infographic, "username", "")
            AccountsService.statsWelcomeScreen = true
            tryCompare(LightDM.Infographic, "username", "single")
        }

        function test_initial_selected_signal() {
            var selectedSpy = findChild(greeter, "selectedSpy");
            selectedSpy.wait();
            tryCompare(selectedSpy, "count", 1);
        }

        function test_dragToHide_data() {
            return [
                {tag: "left", startX: greeter.width * 0.95, endX: greeter.width * 0.1, hiddenX: -greeter.width},
                {tag: "right", startX: greeter.width * 0.1, endX: greeter.width * 0.95, hiddenX: greeter.width},
            ];
        }
        function test_dragToHide(data) {
            compare(greeter.x, 0);
            compare(greeter.visible, true);
            compare(greeter.shown, true);
            compare(greeter.showProgress, 1);

            touchFlick(greeter,
                    data.startX, greeter.height / 2, // start pos
                    data.endX, greeter.height / 2); // end pos

            tryCompare(greeter, "x", data.hiddenX);
            tryCompare(greeter, "visible", false);
            tryCompare(greeter, "shown", false);
            tryCompare(greeter, "showProgress", 0);
        }

        function test_hiddenGreeterRemainsHiddenAfterResize_data() {
            return [
                {tag: "left", startX: greeter.width * 0.95, endX: greeter.width * 0.1},
                {tag: "right", startX: greeter.width * 0.1, endX: greeter.width * 0.95},
            ];
        }
        function test_hiddenGreeterRemainsHiddenAfterResize(data) {
            touchFlick(greeter,
                    data.startX, greeter.height / 2, // start pos
                    data.endX, greeter.height / 2); // end pos

            tryCompare(greeter, "x", data.tag == "left" ? -greeter.width : greeter.width);
            tryCompare(greeter, "visible", false);
            tryCompare(greeter, "shown", false);
            tryCompare(greeter, "showProgress", 0);

            // flip dimensions to simulate an orientation change
            greeter.width = greeterLoader.height;
            greeter.height = greeterLoader.width;

            // All properties should remain consistent
            tryCompare(greeter, "x", data.tag == "left" ? -greeter.width : greeter.width);
            tryCompare(greeter, "visible", false);
            tryCompare(greeter, "shown", false);
            tryCompare(greeter, "showProgress", 0);
        }
    }
}
