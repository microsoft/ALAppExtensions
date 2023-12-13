// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

page 11510 "Swiss QR-Bill Scan"
{
    Caption = 'QR-Bill Scan';
    PageType = Card;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(QRCodeTextField; QRCodeText)
                {
                    Caption = 'QR-Code Input';
                    ToolTip = 'Specifies the QR-Code text or scan.';
                    ApplicationArea = All;
                    MultiLine = true;
                }
            }
        }
    }

    var
        QRCodeText: Text;

    internal procedure GetQRBillText(): Text
    begin
        exit(QRCodeText);
    end;
}
