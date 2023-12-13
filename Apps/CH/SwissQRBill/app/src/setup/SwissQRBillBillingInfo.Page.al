// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

page 11513 "Swiss QR-Bill Billing Info"
{
    Caption = 'QR-Bill Billing Information';
    PageType = List;
    SourceTable = "Swiss QR-Bill Billing Info";
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Code)
                {
                    ToolTip = 'Identifies the current record with billing information.';
                    ApplicationArea = All;
                }
                field(DocumentNo; "Document No.")
                {
                    ToolTip = 'Specifies whether a document number is printed in the Additional Information section. If selected, it will be printed like /10/<document no>';
                    ApplicationArea = All;
                }
                field(DocumentDate; "Document Date")
                {
                    ToolTip = 'Specifies whether a document date is printed in the Additional Information section. If selected, it will be printed like /11/<document date>';
                    ApplicationArea = All;
                }
                field(VATNumber; "VAT Number")
                {
                    ToolTip = 'Specifies whether a VAT number is printed in the Additional Information section. If selected, it will be printed like /30/<vat number>';
                    ApplicationArea = All;
                }
                field(VATDate; "VAT Date")
                {
                    ToolTip = 'Specifies whether a VAT date is printed in the Additional Information section. If selected, it will be printed like /31/<vat date>';
                    ApplicationArea = All;
                }
                field(VATDetails; "VAT Details")
                {
                    ToolTip = 'Specifies whether VAT details are printed in the Additional Information section. If selected, it will be printed like /32/<vat details>';
                    ApplicationArea = All;
                }
                field(PaymentTerms; "Payment Terms")
                {
                    ToolTip = 'Specifies whether Payment Terms are printed in the Additional Information section. If selected, it will be printed like /40/<payment terms>';
                    ApplicationArea = All;
                }
            }
        }
    }
}
