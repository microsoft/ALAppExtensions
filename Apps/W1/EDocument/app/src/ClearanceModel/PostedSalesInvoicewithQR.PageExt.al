// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Sales.History;

pageextension 6164 "Posted Sales Invoice with QR" extends "Posted Sales Invoice"
{
    actions
    {
        addafter("F&unctions")
        {
            action(ViewQRCode)
            {
                ApplicationArea = All;
                Caption = 'View QR Code';
                Image = Picture;
                ToolTip = 'View the QR code assigned by the authority';
                Visible = ShowQRCodeAction;

                trigger OnAction()
                var
                    QRCodeViewerPage: Page "E-Document QR Code Viewer";
                begin
                    QRCodeViewerPage.SetRecord(Rec);
                    QRCodeViewerPage.RunModal();
                end;
            }
        }
    }

    var
        ShowQRCodeAction: Boolean;

    trigger OnAfterGetRecord()
    begin
        ShowQRCodeAction := Rec."QR Code Image".Count > 0;
    end;
}
