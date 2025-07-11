// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

page 11518 "Swiss QR-Bill Billing Details"
{
    Caption = 'Billing Information Details';
    PageType = List;
    SourceTable = "Swiss QR-Bill Billing Detail";
    SourceTableTemporary = true;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(FormatCodeField; "Format Code")
                {
                    ToolTip = 'Specifies the format code.';
                    ApplicationArea = All;
                }
                field(TagField; "Tag Code")
                {
                    ToolTip = 'Specifies the tag code.';
                    ApplicationArea = All;
                }
                field(ValueField; "Tag Value")
                {
                    ToolTip = 'Specifies the tag value.';
                    ApplicationArea = All;
                }
                field(TypeField; "Tag Type")
                {
                    ToolTip = 'Specifies the tag type.';
                    ApplicationArea = All;
                }
                field(DescriptionField; "Tag Description")
                {
                    ToolTip = 'Specifies the description for the current tag.';
                    ApplicationArea = All;
                }
            }
        }
    }

    internal procedure SetBuffer(var SourceSwissQRBillBillingDetail: Record "Swiss QR-Bill Billing Detail")
    begin
        DeleteAll();
        if SourceSwissQRBillBillingDetail.FindSet() then
            repeat
                Rec := SourceSwissQRBillBillingDetail;
                Insert();
            until SourceSwissQRBillBillingDetail.Next() = 0;
        if FindFirst() then;
    end;
}
