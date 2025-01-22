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
                field(Date; Rec.Date)
                {
                    Editable = this.PaymentEditable;
                }
                field(Amount; Rec.Amount)
                {
                    Editable = this.PaymentEditable;
                }
                field("VAT Base"; Rec."VAT Base")
                {
                    Visible = false;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    Visible = false;
                }
                field(Status; Rec.Status)
                {
                }
                field(Direction; Rec.Direction)
                {
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
