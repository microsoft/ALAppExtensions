// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 1863 "C5 LedTable"
{
    PageType = Card;
    SourceTable = "C5 LedTable";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 G/L Table';

    layout
    {
        area(content)
        {
            group(General)
            {
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
                field(ImageFile; ImageFile) { ApplicationArea = All; }
                field(BalanceMST; BalanceMST) { ApplicationArea = All; }
                field(TmpNumerals05; TmpNumerals05) { ApplicationArea = All; }
                field(TmpNumerals06; TmpNumerals06) { ApplicationArea = All; }
                field(TmpNumerals07; TmpNumerals07) { ApplicationArea = All; }
                field(TmpNumerals08; TmpNumerals08) { ApplicationArea = All; }
                field(TmpNumerals09; TmpNumerals09) { ApplicationArea = All; }
                field(TmpNumerals10; TmpNumerals10) { ApplicationArea = All; }
                field(TmpNumerals11; TmpNumerals11) { ApplicationArea = All; }
                field(TmpNumerals12; TmpNumerals12) { ApplicationArea = All; }
                field(TmpNumerals13; TmpNumerals13) { ApplicationArea = All; }
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
            }
        }
    }
}