// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

xmlport 1860 "C5 LedTable"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'LedTableDocument';
            tableelement(C5LedTable; "C5 LedTable")
            {
                fieldelement(DEL_UserLock; C5LedTable.DEL_UserLock) { }
                fieldelement(Account; C5LedTable.Account) { }
                fieldelement(AccountName; C5LedTable.AccountName) { }
                fieldelement(AccountType; C5LedTable.AccountType) { }
                fieldelement(Code; C5LedTable.Code) { }
                fieldelement(DCproposal; C5LedTable.DCproposal) { }
                fieldelement(Department; C5LedTable.Department) { }
                fieldelement(MandDepartment; C5LedTable.MandDepartment) { }
                fieldelement(OffsetAccount; C5LedTable.OffsetAccount) { }
                fieldelement(Access; C5LedTable.Access) { }
                fieldelement(TotalFromAccount; C5LedTable.TotalFromAccount) { }
                fieldelement(Vat; C5LedTable.Vat) { }
                fieldelement(BalanceCur; C5LedTable.BalanceCur) { }
                fieldelement(Currency; C5LedTable.Currency) { }
                fieldelement(CostType; C5LedTable.CostType) { }
                fieldelement(Counterunit; C5LedTable.Counterunit) { }
                fieldelement(ImageFile; C5LedTable.ImageFile) { }
                fieldelement(BalanceMST; C5LedTable.BalanceMST) { }
                fieldelement(TmpNumerals05; C5LedTable.TmpNumerals05) { }
                fieldelement(TmpNumerals06; C5LedTable.TmpNumerals06) { }
                fieldelement(TmpNumerals07; C5LedTable.TmpNumerals07) { }
                fieldelement(TmpNumerals08; C5LedTable.TmpNumerals08) { }
                fieldelement(TmpNumerals09; C5LedTable.TmpNumerals09) { }
                fieldelement(TmpNumerals10; C5LedTable.TmpNumerals10) { }
                fieldelement(TmpNumerals11; C5LedTable.TmpNumerals11) { }
                fieldelement(TmpNumerals12; C5LedTable.TmpNumerals12) { }
                fieldelement(TmpNumerals13; C5LedTable.TmpNumerals13) { }
                fieldelement(CompanyGroupAcc; C5LedTable.CompanyGroupAcc) { }
                fieldelement(ExchAdjust; C5LedTable.ExchAdjust) { }
                fieldelement(Balance02; C5LedTable.Balance02) { }
                fieldelement(EDIIndex; C5LedTable.EDIIndex) { }
                fieldelement(Centre; C5LedTable.Centre) { }
                fieldelement(MandCentre; C5LedTable.MandCentre) { }
                fieldelement(Purpose; C5LedTable.Purpose) { }
                fieldelement(MandPurpose; C5LedTable.MandPurpose) { }
                fieldelement(VatBlocked; C5LedTable.VatBlocked) { }
                fieldelement(OpeningAccount; C5LedTable.OpeningAccount) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5LedTable.RecId := Counter;
                    Counter += 1;
                end;
            }
        }
    }

    var
        Counter: Integer;
}

