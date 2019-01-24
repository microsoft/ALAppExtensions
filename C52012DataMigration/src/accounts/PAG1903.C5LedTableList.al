// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 1903 "C5 LedTable List"
{
    PageType = List;
    SourceTable = "C5 LedTable";
    CardPageId = "C5 LedTable";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    Caption = 'Accounts';

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
                field(Account; Account) { ApplicationArea = All; }
                field(AccountName; AccountName) { ApplicationArea = All; }
                field(AccountType; AccountType) { ApplicationArea = All; }
                field(Code; Code) { ApplicationArea = All; }
                field(DCproposal; DCproposal) { ApplicationArea = All; }
                field(Department; Department) { ApplicationArea = All; }
                field(MandDepartment; MandDepartment) { ApplicationArea = All; }
                field(OffsetAccount; OffsetAccount) { ApplicationArea = All; }
                field(Access; Access) { ApplicationArea = All; }
                field(TotalFromAccount; TotalFromAccount) { ApplicationArea = All; }
                field(Vat; Vat) { ApplicationArea = All; }
                field(BalanceCur; BalanceCur) { ApplicationArea = All; }
                field(Currency; Currency) { ApplicationArea = All; }
                field(CostType; CostType) { ApplicationArea = All; }
                field(Counterunit; Counterunit) { ApplicationArea = All; }
                field(BalanceMST; BalanceMST) { ApplicationArea = All; }
                field(CompanyGroupAcc; CompanyGroupAcc) { ApplicationArea = All; }
                field(ExchAdjust; ExchAdjust) { ApplicationArea = All; }
                field(Balance02; Balance02) { ApplicationArea = All; }
                field(EDIIndex; EDIIndex) { ApplicationArea = All; }
                field(Centre; Centre) { ApplicationArea = All; }
                field(MandCentre; MandCentre) { ApplicationArea = All; }
                field(Purpose; Purpose) { ApplicationArea = All; }
                field(MandPurpose; MandPurpose) { ApplicationArea = All; }
                field(VatBlocked; VatBlocked) { ApplicationArea = All; }
                field(OpeningAccount; OpeningAccount) { ApplicationArea = All; }
                field(DEL_UserLock; DEL_UserLock) { ApplicationArea = All; }
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
        DataMigrationError.GetErrorMessage(C5MigrDashboardMgt.GetC5MigrationTypeTxt(), RecordId(), MigrationErrorText);
    end;

}