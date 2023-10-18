// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using Microsoft.Foundation.Company;
using Microsoft.Sales.Setup;
using Microsoft.Service.History;

reportextension 11215 "SE Service - Credit Memo" extends "Service - Credit Memo"
{
    RDLCLayout = './src/ReportExtensions/ServiceCreditMemo.rdlc';

    dataset
    {
        add("Service Cr.Memo Header")
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
