// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

using Microsoft.Foundation.Company;
using Microsoft.Sales.Setup;

reportextension 11228 "SE Statement" extends Statement
{
    RDLCLayout = './src/ReportExtensions/Statement.rdlc';

    dataset
    {
        add(Customer)
        {
            column(PlusGiroNumberCaption; CompanyInformation.FieldCaption("Plus Giro Number"))
            {
            }
            column(BoardOfDirectorsLocationCaption; CompanyInformation.GetLegalOfficeLabel())
            {
            }
            column(CompanyHasTaxAssessCaption; SalesReceivablesSetup.GetLegalStatementLabel())
            {
            }
        }

        add("Integer")
        {
            column(CompanyInfoPlusGiroNumber; CompanyInformation."Plus Giro Number")
            {
            }
            column(CompanyInfoRegisteredOfficeInfo; CompanyInformation."Registered Office Info")
            {
            }
            column(TodayFormatted_0_4; Format(Today(), 0, 4))
            {
            }
        }
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
    end;

    var
        CompanyInformation: Record "Company Information";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";

}
