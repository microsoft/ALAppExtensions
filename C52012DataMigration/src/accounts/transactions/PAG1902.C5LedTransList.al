// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

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
                field("Error Message"; MigrationErrorText)
                {
                    ApplicationArea = All;
                    
                    Enabled = false;
                }
                field(Account;Account) { ApplicationArea=All; }
                field(BudgetCode;BudgetCode) { ApplicationArea=All; }
                field(Department;Department) { ApplicationArea=All; }
                field(Date_;Date_) { ApplicationArea=All; }
                field(Voucher;Voucher) { ApplicationArea=All; }
                field(Txt;Txt) { ApplicationArea=All; }
                field(AmountMST;AmountMST) { ApplicationArea=All; }
                field(AmountCur;AmountCur) { ApplicationArea=All; }
                field(Currency;Currency) { ApplicationArea=All; }
                field(Vat;Vat) { ApplicationArea=All; }
                field(VatAmount;VatAmount) { ApplicationArea=All; }
                field(Qty;Qty) { ApplicationArea=All; }
                field(TransType;TransType) { ApplicationArea=All; }
                field(DueDate;DueDate) { ApplicationArea=All; }
                field(Transaction;Transaction) { ApplicationArea=All; }
                field(CreatedBy;CreatedBy) { ApplicationArea=All; }
                field(JourNumber;JourNumber) { ApplicationArea=All; }
                field(Amount2;Amount2) { ApplicationArea=All; }
                field(LockAmount2;LockAmount2) { ApplicationArea=All; }
                field(Centre;Centre) { ApplicationArea=All; }
                field(Purpose;Purpose) { ApplicationArea=All; }
                field(ReconcileNo;ReconcileNo) { ApplicationArea=All; }
                field(VatRepCounter;VatRepCounter) { ApplicationArea=All; }
                field(VatPeriodRecId;VatPeriodRecId) { ApplicationArea=All; }                
            }
        }
    }

    var
        C5MigrDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
        MigrationErrorText : Text[250];

    trigger OnAfterGetRecord();
    var
        DataMigrationError: Record "Data Migration Error";
    begin
        DataMigrationError.GetErrorMessage(C5MigrDashboardMgt.GetC5MigrationTypeTxt(), RecordId(), MigrationErrorText);
    end;

}