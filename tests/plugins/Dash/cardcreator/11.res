AbstractButton { 
                id: root; 
                property var cardData; 
                property string backgroundShapeStyle: "flat"; 
                property real fontScale: 1.0; 
                property var scopeStyle: null; 
                readonly property string title: cardData && cardData["title"] || "";
                property bool showHeader: true;
                implicitWidth: childrenRect.width;
                enabled: true;
                property int fixedHeaderHeight: -1; 
                property size fixedArtShapeSize: Qt.size(-1, -1); 
signal action(var actionId);
Loader {
                                id: backgroundLoader; 
                                objectName: "backgroundLoader"; 
                                anchors.fill: parent; 
                                asynchronous: true;
                                visible: status === Loader.Ready;
                                sourceComponent: UbuntuShape { 
                                    objectName: "background"; 
                                    radius: "small"; 
                                    aspect: { 
                                        switch (root.backgroundShapeStyle) { 
                                            case "inset": return UbuntuShape.Inset; 
                                            case "shadow": return UbuntuShape.DropShadow; 
                                            default: 
                                            case "flat": return UbuntuShape.Flat; 
                                        } 
                                    } 
                                    backgroundColor: getColor(0) || "white"; 
                                    secondaryBackgroundColor: getColor(1) || backgroundColor; 
                                    backgroundMode: UbuntuShape.VerticalGradient; 
                                    anchors.fill: parent; 
                                    source: backgroundImage.source ? backgroundImage : null; 
                                    property real luminance: Style.luminance(backgroundColor); 
                                    property Image backgroundImage: Image { 
                                        objectName: "backgroundImage"; 
                                        source: { 
                                            if (cardData && typeof cardData["background"] === "string") return cardData["background"]; 
                                            else return ""; 
                                        } 
                                    } 
                                    function getColor(index) { 
                                        if (cardData && typeof cardData["background"] === "object" 
                                            && (cardData["background"]["type"] === "color" || cardData["background"]["type"] === "gradient")) { 
                                            return cardData["background"]["elements"][index]; 
                                        } else return index === 0 ? "#E9E9E9" : undefined; 
                                    } 
                                } 
                            }
Loader {
                                id: artShapeLoader; 
                                height: root.fixedArtShapeSize.height; 
                                width: root.fixedArtShapeSize.width; 
                                anchors { horizontalCenter: parent.horizontalCenter; }
                                objectName: "artShapeLoader"; 
                                readonly property string cardArt: cardData && cardData["art"] || decodeURI("%5C");
                                onCardArtChanged: { if (item) { item.image.source = cardArt; } }
                                active: cardArt != "";
                                asynchronous: true;
                                visible: status === Loader.Ready;
                                sourceComponent: Item { 
                                    id: artShape; 
                                    objectName: "artShape"; 
                                    visible: image.status === Image.Ready;
                                    readonly property alias image: artImage; 
                                    UbuntuShape {
                                        anchors.fill: parent;
                                        source: artImage;
                                        sourceFillMode: UbuntuShape.PreserveAspectCrop;
                                        radius: "small";
                                        aspect: UbuntuShape.Flat;
                                    }
                                    width: root.fixedArtShapeSize.width;
                                    height: root.fixedArtShapeSize.height;
                                    CroppedImageMinimumSourceSize {
                                        id: artImage; 
                                        objectName: "artImage"; 
                                        source: artShapeLoader.cardArt;
                                        asynchronous: true;
                                        visible: false;
                                        width: root.width; 
                                        height: width / (root.fixedArtShapeSize.width / root.fixedArtShapeSize.height);
                                        onStatusChanged: if (status === Image.Error) source = decodeURI("%5C");
                                    } 
                                }
                        }
readonly property int headerHeight: row.height;
Row { 
                        id: row; 
                        objectName: "outerRow"; 
                        property real margins: units.gu(1); 
                        spacing: margins; 
                        height: root.fixedHeaderHeight;
                        anchors { top: artShapeLoader.bottom;
                                         topMargin: units.gu(1);
left: parent.left;
 } 
                        anchors.right: parent.right; 
                        anchors.margins: margins; 
                        anchors.rightMargin: 0; 
                        data: [ 
                                CroppedImageMinimumSourceSize { 
                            id: mascotImage; 
                            objectName: "mascotImage"; 
                            anchors { verticalCenter: parent.verticalCenter; } 
                            source: cardData && cardData["mascot"] || decodeURI("%22");
                            width: units.gu(6); 
                            height: units.gu(5.625); 
                            horizontalAlignment: Image.AlignHCenter; 
                            verticalAlignment: Image.AlignVCenter; 
                            visible: showHeader; 
                             onStatusChanged: if (status === Image.Error) source = decodeURI("%22");
                        }
,Item { 
                            id: headerTitleContainer; 
                            anchors { verticalCenter: parent.verticalCenter;  } 
                            width: parent.width - x; 
                            implicitHeight: titleLabel.height + subtitleLabel.height; 
                            data: [ 
                                Label { 
                        id: titleLabel; 
                        objectName: "titleLabel"; 
                        anchors { right: parent.right; 
rightMargin: units.gu(1); 
left: parent.left; 
                             top: parent.top; } 
                        elide: Text.ElideRight; 
                        fontSize: "small"; 
                        wrapMode: Text.Wrap; 
                        maximumLineCount: 2; 
                        font.pixelSize: Math.round(FontUtils.sizeToPixels(fontSize) * fontScale); 
                        color: backgroundLoader.active && backgroundLoader.item && root.scopeStyle ? root.scopeStyle.getTextColor(backgroundLoader.item.luminance) : (backgroundLoader.item && backgroundLoader.item.luminance > 0.7 ? theme.palette.normal.baseText : "white"); 
                        visible: showHeader ; 
                        width: undefined; 
                        text: root.title; 
                        font.weight: Font.Normal; 
                        horizontalAlignment: Text.AlignLeft;
                    }
,Label { 
                            id: subtitleLabel; 
                            objectName: "subtitleLabel"; 
                            anchors { right: parent.right; 
                               left: parent.left; 
rightMargin: units.gu(1); 
top: titleLabel.bottom;
 } 
                            anchors.topMargin: units.dp(2); 
                            elide: Text.ElideRight; 
                            maximumLineCount: 1; 
                            fontSize: "x-small"; 
                            font.pixelSize: Math.round(FontUtils.sizeToPixels(fontSize) * fontScale); 
                            color: backgroundLoader.active && backgroundLoader.item && root.scopeStyle ? root.scopeStyle.getTextColor(backgroundLoader.item.luminance) : (backgroundLoader.item && backgroundLoader.item.luminance > 0.7 ? theme.palette.normal.baseText : "white"); 
                            visible: titleLabel.visible && titleLabel.text; 
                            text: cardData && cardData["subtitle"] || ""; 
                            font.weight: Font.Light; 
                        }
 
                            ]
                        }
 
                                ] 
                    }
Loader {
    active: root.pressed;
    anchors { fill: backgroundLoader }
    sourceComponent: UbuntuShape {
        objectName: "touchdown";
        anchors.fill: parent;
        radius: "small";
        borderSource: "radius_pressed.sci"
    }
}
implicitHeight: row.y + row.height + units.gu(1);
}
