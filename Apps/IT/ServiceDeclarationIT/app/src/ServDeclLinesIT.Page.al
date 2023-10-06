// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

page 12214 "Serv. Decl. Lines IT"
{
    Caption = 'Service Declaration Lines';
    Editable = false;
    PageType = List;
    SourceTable = "Service Declaration Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Document Date"; Rec."Document Date")
                {
                    Caption = 'Date';
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies the document date.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies the document number of the source entry.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies the external document number.';
                }
                field("VAT Reg. No."; Rec."VAT Reg. No.")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies the VAT registration No. of the customer or vendor associated with a source entry.';
                }
                field("Service Tariff No."; Rec."Service Tariff No.")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies the ID of the service tariff that is associated with the Service Declaration.';
                }
                field("Transport Method"; Rec."Transport Method")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies the transport method for the item entry.';
                }
                field("Payment Method"; Rec."Payment Method")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies the payment method that is associated with the Service Declaration.';
                }
                field("Country/Region of Payment Code"; Rec."Country/Region of Payment Code")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies the country/region of the payment method that is associated with the Service Declaration.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies the currency code of the source entry.';
                }
                field("Source Currency Amount"; Rec."Source Currency Amount")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies the amount in the currency of the source of the transaction.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies the total amount of the entry, excluding VAT.';
                }
                field("Source Entry No."; Rec."Source Entry No.")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies the source VAT Entry number.';
                }
            }
        }
    }
}
