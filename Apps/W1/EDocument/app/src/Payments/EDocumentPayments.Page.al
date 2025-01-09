// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Payments;

page 6101 "E-Document Payments"
{
    ApplicationArea = All;
    Caption = 'E-Document Payments';
    PageType = List;
    SourceTable = "E-Document Payment";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Date"; Rec."Date")
                {
                    ApplicationArea = All;
                    Editable = this.PaymentEditable;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Editable = this.PaymentEditable;
                }
                field("VAT Base"; Rec."VAT Base")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field(Direction; Rec.Direction)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        PaymentEditable: Boolean;

    trigger OnAfterGetRecord()
    begin
        this.PaymentEditable := Rec.Status <> Rec.Status::Sent;
    end;
}
