// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using Microsoft.Foundation.Company;
using Microsoft.Sales.Setup;
using Microsoft.Service.Document;

reportextension 11218 "SE Service Quote" extends "Service Quote"
{
    RDLCLayout = './src/ReportExtensions/ServiceQuote.rdlc';

    dataset
    {
        add("Service Header")
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

        add(CopyLoop)
        {
            column(CompanyInfoPlusGiroNumber; CompanyInformation."Plus Giro Number")
            {
            }
            column(CompanyInfoRegisteredOfficeInfo; CompanyInformation."Registered Office Info")
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
