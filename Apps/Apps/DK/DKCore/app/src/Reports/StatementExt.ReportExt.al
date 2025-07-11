// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.Core;

using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;

reportextension 13607 StatementExt extends Statement
{
    RDLCLayout = './src/Reports/Statement.rdlc';
    dataset
    {
        add("Integer")
        {
            column(BankBranchNo_CompanyInfo; CompanyInformationDK."Bank Branch No.") { }

            column(BankBranchNo_CompanyInfoCaption; BankBranchNo_CompanyInfoCaptionLbl) { }
        }
    }

    trigger OnPreReport()
    begin
        CompanyInformationDK.Get();
    end;

    var
        CompanyInformationDK: Record "Company Information";
        BankBranchNo_CompanyInfoCaptionLbl: Label 'Bank Branch No.';
}
