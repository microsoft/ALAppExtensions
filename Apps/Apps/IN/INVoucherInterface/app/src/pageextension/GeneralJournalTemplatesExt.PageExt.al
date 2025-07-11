// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

pageextension 18934 "General Journal Templates Ext." extends "General Journal Templates"
{
    layout
    {
        modify(Type)
        {
            Visible = false;
        }
        addafter(Description)
        {
            field("Voucher Type"; VoucherEnum)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of the journal template which are getting created.';
                Caption = 'Type';
                trigger OnValidate()
                begin
                    Validate(Type, VoucherEnum);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        VoucherEnum := Type;
    end;

    var
        VoucherEnum: Enum "Gen. Journal Template Type";
}
