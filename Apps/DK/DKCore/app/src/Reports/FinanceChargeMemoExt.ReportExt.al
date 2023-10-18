// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.Core;

using Microsoft.Foundation.Company;
using Microsoft.Sales.FinanceCharge;

reportextension 13604 FinanceChargeMemoExt extends "Finance Charge Memo"
{
    RDLCLayout = './src/Reports/FinanceChargeMemo.rdlc';
    dataset
    {
        add("Integer")
        {
            column(CompanyInfoBankBranchNo; CompanyInformationDK."Bank Branch No.") { }

            column(BankBranchNoCaption; BankBranchNoCaptionLbl) { }
        }
    }

    trigger OnPreReport()
    begin
        CompanyInformationDK.Get();
    end;

    var
        CompanyInformationDK: Record "Company Information";
        BankBranchNoCaptionLbl: Label 'Bank Branch No.';
}
