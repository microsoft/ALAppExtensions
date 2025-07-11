// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.VoucherInterface;

using Microsoft.Bank.Check;

page 18936 "Confirm Financial Stale"
{
    Caption = 'Confirm Financial Stale';
    PageType = ConfirmationDialog;

    layout
    {
        area(content)
        {
            label("")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
            }
            field(VoidDate; VoidDate)
            {
                Caption = 'Stale Date';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Displays the date of marking the cheque as stale.';
                trigger OnValidate()
                begin
                    if VoidDate < CheckLedgerEntry."Check Date" then
                        Error(VoidDateErr, CheckLedgerEntry.FieldCaption("Check Date"));
                end;
            }
            field(VoidType; VoidType)
            {
                Caption = 'Type of Stale';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Select whether check is to be marked as stale or it should be unapplied and marked as stale.';
                OptionCaption = 'Unapply and Stale check,Stale check only';
            }
            group(Details)
            {
                Caption = 'Details';

                field("Bank Account No."; CheckLedgerEntry."Bank Account No.")
                {
                    Caption = 'Bank Account No.';
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Displays Bank Account No. of the transaction posted.';
                }
                field("Check No."; CheckLedgerEntry."Check No.")
                {
                    Caption = 'Check No.';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Displays Check No. of the transaction posted.';
                }
                field("Bal. Account No."; CheckLedgerEntry."Bal. Account No.")
                {
                    CaptionClass = Format((StrSubstNo(BalAccountTypeLbl, CheckLedgerEntry."Bal. Account Type")));
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Displays the G/L Account, Customer, Vendor or Bank Account of the transaction posted.';
                }
                field(Amount; CheckLedgerEntry.Amount)
                {
                    Caption = 'Amount';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Displays the Amount of the transaction posted.';
                }
            }
        }
    }

    trigger OnInit()
    begin
        CurrPage.LookupMode := true;
    end;

    trigger OnOpenPage()
    begin
        VoidDate := CheckLedgerEntry."Check Date";
        if CheckLedgerEntry."Bal. Account Type" in [CheckLedgerEntry."Bal. Account Type"::Vendor, CheckLedgerEntry."Bal. Account Type"::Customer] then
            VoidType := VoidType::"Unapply and Stale check"
        else
            VoidType := VoidType::"Stale check only";
    end;

    var
        CheckLedgerEntry: Record "Check Ledger Entry";
        VoidDate: Date;
        VoidType: Option "Unapply and Stale check","Stale check only";
        VoidDateErr: Label 'Void Date must not be before the original %1.', Comment = '%1 = Check Date';
        BalAccountTypeLbl: Label '%1 No.', Comment = '%1 = Bal Account Type';

    procedure SetCheckLedgerEntry(var NewCheckLedgerEntry: Record "Check Ledger Entry")
    begin
        CheckLedgerEntry := NewCheckLedgerEntry;
    end;

    procedure GetVoidDate(): Date
    begin
        exit(VoidDate);
    end;

    procedure GetVoidType(): Integer
    begin
        exit(VoidType);
    end;

    procedure InitializeRequest(VoidCheckdate: Date; VoiceCheckType: Option)
    begin
        VoidDate := VoidCheckdate;
        VoidType := VoiceCheckType;
    end;
}
