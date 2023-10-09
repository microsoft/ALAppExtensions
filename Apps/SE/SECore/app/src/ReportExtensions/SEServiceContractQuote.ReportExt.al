// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using Microsoft.Foundation.Company;

reportextension 11226 "SE Service Contract Quote" extends "Service Contract Quote"
{
    RDLCLayout = './src/ReportExtensions/ServiceContractQuote.rdlc';

    dataset
    {
        add(PageLoop)
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
