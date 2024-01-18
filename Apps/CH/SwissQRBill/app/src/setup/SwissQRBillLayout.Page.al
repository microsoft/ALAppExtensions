// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

page 11515 "Swiss QR-Bill Layout"
{
    Caption = 'QR-Bill Layouts';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Swiss QR-Bill Layout";
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the QR-Bill Layout code as an identifier for the layout.';
                }
                field(IBANType; "IBAN Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the IBAN type. Use QR-IBAN if you have been issued a QR-IBAN number from your bank and use this in your Company Information.';
                }
                field("Payment Reference Type"; "Payment Reference Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the QR-bIll reference type. Must be set according to the IBAN Type. Use a QR reference if you are using QR-IBAN type.';
                }
                field(UnstrMessage; "Unstr. Message")
                {
                    ToolTip = 'Specifies the unstructured message.';
                    ApplicationArea = All;
                }
                field(BillingFormat; "Billing Information")
                {
                    ApplicationArea = All;
                    LookupPageId = "Swiss QR-Bill Billing Info";
                    ToolTip = 'Specifies the QR-bill billing information section. This allows you to configure which additional information is printed on the QR-bill. Information is added in the form described by Swico.';
                }
                field(AltProcedureName1; "Alt. Procedure Name 1")
                {
                    ToolTip = 'Specifies the first alternate procedure name.';
                    ApplicationArea = All;
                }
                field(AltProcedureValue1; "Alt. Procedure Value 1")
                {
                    ToolTip = 'Specifies the first alternate procedure value.';
                    ApplicationArea = All;
                    Editable = "Alt. Procedure Name 1" <> '';
                }
                field(AltProcedureName2; "Alt. Procedure Name 2")
                {
                    ToolTip = 'Specifies the second alternate procedure name.';
                    ApplicationArea = All;
                }
                field(AltProcedureValue2; "Alt. Procedure Value 2")
                {
                    ToolTip = 'Specifies the second alternate procedure value.';
                    ApplicationArea = All;
                    Editable = "Alt. Procedure Name 2" <> '';
                }
            }
        }
    }
}
