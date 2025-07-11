// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

using System.Integration;

page 1902 "C5 LedTrans List"
{
    PageType = List;
    SourceTable = "C5 LedTrans";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    Caption = 'C5 Ledger Entries';

    layout
    {
        area(content)
        {
            repeater(General)
            {
#pragma warning disable AA0218
                field("Error Message"; MigrationErrorText)
                {
                    ApplicationArea = All;
                    Caption = 'Error Message';
                    Enabled = false;
                }
                field(Account; Rec.Account) { ApplicationArea = All; }
                field(BudgetCode; Rec.BudgetCode) { ApplicationArea = All; }
                field(Department; Rec.Department) { ApplicationArea = All; }
                field(Date_; Rec.Date_) { ApplicationArea = All; }
                field(Voucher; Rec.Voucher) { ApplicationArea = All; }
                field(Txt; Rec.Txt) { ApplicationArea = All; }
                field(AmountMST; Rec.AmountMST) { ApplicationArea = All; }
                field(AmountCur; Rec.AmountCur) { ApplicationArea = All; }
                field(Currency; Rec.Currency) { ApplicationArea = All; }
                field(Vat; Rec.Vat) { ApplicationArea = All; }
                field(VatAmount; Rec.VatAmount) { ApplicationArea = All; }
                field(Qty; Rec.Qty) { ApplicationArea = All; }
                field(TransType; Rec.TransType) { ApplicationArea = All; }
                field(DueDate; Rec.DueDate) { ApplicationArea = All; }
                field(Transaction; Rec.Transaction) { ApplicationArea = All; }
                field(CreatedBy; Rec.CreatedBy) { ApplicationArea = All; }
                field(JourNumber; Rec.JourNumber) { ApplicationArea = All; }
                field(Amount2; Rec.Amount2) { ApplicationArea = All; }
                field(LockAmount2; Rec.LockAmount2) { ApplicationArea = All; }
                field(Centre; Rec.Centre) { ApplicationArea = All; }
                field(Purpose; Rec.Purpose) { ApplicationArea = All; }
                field(ReconcileNo; Rec.ReconcileNo) { ApplicationArea = All; }
                field(VatRepCounter; Rec.VatRepCounter) { ApplicationArea = All; }
                field(VatPeriodRecId; Rec.VatPeriodRecId) { ApplicationArea = All; }
#pragma warning restore
            }
        }
    }

    var
        C5MigrDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
        MigrationErrorText: Text[250];

    trigger OnAfterGetRecord();
    var
        DataMigrationError: Record "Data Migration Error";
    begin
        DataMigrationError.GetErrorMessage(C5MigrDashboardMgt.GetC5MigrationTypeTxt(), Rec.RecordId(), MigrationErrorText);
    end;

}
