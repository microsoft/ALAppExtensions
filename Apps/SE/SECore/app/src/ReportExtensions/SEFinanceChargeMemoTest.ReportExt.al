// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.FinanceCharge;

using Microsoft.Foundation.Company;

reportextension 11221 "SE Finance Charge Memo - Test" extends "Finance Charge Memo - Test"
{
    RDLCLayout = './src/ReportExtensions/FinanceChargeMemoTest.rdlc';

    dataset
    {
        add(PageCounter)
        {
            column(CompanyInfoPlusGiroNumber; CompanyInformation."Plus Giro Number")
            {
            }
            column(CompanyInfoRegisteredOfficeInfo; CompanyInformation."Registered Office Info")
            {
            }
        }
    }

    labels
    {
        PlusGiroNumberCaption = 'Plus Giro No.';
        BoardOfDirectorsLocationCaption = 'Board of Directors Location (registered office)';
        CompanyHasTaxAssessCaption = 'Company has Tax Assessment Note';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
    end;

    var
        CompanyInformation: Record "Company Information";

}
