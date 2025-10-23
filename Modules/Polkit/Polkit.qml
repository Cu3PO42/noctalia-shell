import Quickshell
import Quickshell.Services.Polkit
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

NPanel {
    id: root

    preferredWidth: 640 * Style.uiScaleRatio
    preferredHeight: 300 * Style.uiScaleRatio

    panelAnchorHorizontalCenter: true
    panelAnchorVerticalCenter: true
    panelKeyboardFocus: true
    draggable: false
    backgroundClickEnabled: false

    panelContent: Rectangle {
        color: Color.transparent
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.marginL
            spacing: Style.marginL

            NText {
                text: polkitAgent.flow?.message || ""
                wrapMode: Text.WordWrap
                font.weight: Style.fontWeightBold
                pointSize: Style.fontSizeL
                color: Color.mOnSurface
                Layout.fillWidth: true
                visible: text.length > 0
            }

            NDivider {
                Layout.fillWidth: true
            }

            NText {
                text: polkitAgent.flow?.supplementaryMessage || ""
                wrapMode: Text.WordWrap
                pointSize: Style.fontSizeM
                color: polkitAgent.flow?.supplementaryIsError ? Color.mError : Color.mOnSurface
                Layout.fillWidth: true
                visible: text.length > 0
            }

            NTextInput {
                id: passwordField
                label: polkitAgent.flow?.inputPrompt || ""
                Layout.fillWidth: true
                inputItem.echoMode: polkitAgent.flow?.responseVisible ? TextInput.Normal : TextInput.Password
                visible: polkitAgent.flow?.isResponseRequired ?? false
                inputItem.onAccepted: {
                    polkitAgent.flow?.submit(passwordField.text)
                }
            }

            Item { Layout.fillHeight: true } // spacer

            RowLayout {
                spacing: Style.marginS
                Layout.alignment: Qt.AlignRight
                Layout.fillWidth: true

                NComboBox {
                    id: identityComboBox
                    model: polkitAgent.flow?.identities.map(i => ({ key: i.id, name: i.displayName })) || []
                    currentKey: polkitAgent.flow?.selectedIdentity?.id
                    visible: (polkitAgent.flow?.identities.length || 0) > 1
                    onSelected: key => {
                        polkitAgent.flow?.setSelectedIdentity(polkitAgent.flow.identities.find(i => i.id === key))
                    }
                }

                NButton {
                    id: cancelButton
                    text: "Cancel"
                    backgroundColor: Color.mTertiary
                    textColor: Color.mOnTertiary
                    onClicked: {
                        polkitAgent.flow?.cancelAuthenticationRequest()
                    }
                }

                NButton {
                    id: okButton
                    text: "Authenticate"
                    icon: "lock"
                    backgroundColor: Color.mPrimary
                    hoverColor: Color.mSecondary
                    textColor: Color.mOnPrimary
                    enabled: !!polkitAgent.flow?.isResponseRequired
                    onClicked: {
                        polkitAgent.flow?.submit(passwordField.text)
                    }
                }
            }

            Connections {
                target: polkitAgent.flow
                function onIsResponseRequiredChanged() {
                    passwordField.text = ""
                    if (polkitAgent.flow.isResponseRequired)
                        passwordField.inputItem.forceActiveFocus()
                }
            }
        }
    }

    PolkitAgent {
        id: polkitAgent
        onIsActiveChanged: {
            if (polkitAgent.isActive) {
                root.open()
            } else {
                root.close()
            }
        }
    }
}
