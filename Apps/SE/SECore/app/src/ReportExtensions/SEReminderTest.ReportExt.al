// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Reminder;

using Microsoft.Foundation.Company;

reportextension 11224 "SE Reminder - Test" extends "Reminder - Test"
{
    RDLCLayout = './src/ReportExtensions/ReminderTest.rdlc';

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
