// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

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
#pragma warning disable AA0218
                field(Account; Rec.Account) { ApplicationArea = All; }
                field(AccountName; Rec.AccountName) { ApplicationArea = All; }
                field(AccountType; Rec.AccountType) { ApplicationArea = All; }
                field(Code; Rec.Code) { ApplicationArea = All; }
                field(DCproposal; Rec.DCproposal) { ApplicationArea = All; }
                field(Department; Rec.Department) { ApplicationArea = All; }
                field(MandDepartment; Rec.MandDepartment) { ApplicationArea = All; }
                field(OffsetAccount; Rec.OffsetAccount) { ApplicationArea = All; }
                field(Access; Rec.Access) { ApplicationArea = All; }
                field(TotalFromAccount; Rec.TotalFromAccount) { ApplicationArea = All; }
                field(Vat; Rec.Vat) { ApplicationArea = All; }
                field(BalanceCur; Rec.BalanceCur) { ApplicationArea = All; }
                field(Currency; Rec.Currency) { ApplicationArea = All; }
                field(CostType; Rec.CostType) { ApplicationArea = All; }
                field(Counterunit; Rec.Counterunit) { ApplicationArea = All; }
                field(ImageFile; Rec.ImageFile) { ApplicationArea = All; }
                field(BalanceMST; Rec.BalanceMST) { ApplicationArea = All; }
                field(TmpNumerals05; Rec.TmpNumerals05) { ApplicationArea = All; }
                field(TmpNumerals06; Rec.TmpNumerals06) { ApplicationArea = All; }
                field(TmpNumerals07; Rec.TmpNumerals07) { ApplicationArea = All; }
                field(TmpNumerals08; Rec.TmpNumerals08) { ApplicationArea = All; }
                field(TmpNumerals09; Rec.TmpNumerals09) { ApplicationArea = All; }
                field(TmpNumerals10; Rec.TmpNumerals10) { ApplicationArea = All; }
                field(TmpNumerals11; Rec.TmpNumerals11) { ApplicationArea = All; }
                field(TmpNumerals12; Rec.TmpNumerals12) { ApplicationArea = All; }
                field(TmpNumerals13; Rec.TmpNumerals13) { ApplicationArea = All; }
                field(CompanyGroupAcc; Rec.CompanyGroupAcc) { ApplicationArea = All; }
                field(ExchAdjust; Rec.ExchAdjust) { ApplicationArea = All; }
                field(Balance02; Rec.Balance02) { ApplicationArea = All; }
                field(EDIIndex; Rec.EDIIndex) { ApplicationArea = All; }
                field(Centre; Rec.Centre) { ApplicationArea = All; }
                field(MandCentre; Rec.MandCentre) { ApplicationArea = All; }
                field(Purpose; Rec.Purpose) { ApplicationArea = All; }
                field(MandPurpose; Rec.MandPurpose) { ApplicationArea = All; }
                field(VatBlocked; Rec.VatBlocked) { ApplicationArea = All; }
                field(OpeningAccount; Rec.OpeningAccount) { ApplicationArea = All; }
#pragma warning restore
            }
        }
    }
}
