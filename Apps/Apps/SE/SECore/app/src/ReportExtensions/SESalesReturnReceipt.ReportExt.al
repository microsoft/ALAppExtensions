// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Foundation.Company;
using Microsoft.Sales.History;
using Microsoft.Sales.Setup;

reportextension 11223 "SE Sales - Return Receipt" extends "Sales - Return Receipt"
{
    RDLCLayout = './src/ReportExtensions/SalesReturnReceipt.rdlc';

    dataset
    {
        add("Return Receipt Header")
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

        add(Total2)
        {
            column(BillToCustomerNo_ReturnReceiptHeader; "Return Receipt Header".FieldCaption("Bill-to Customer No."))
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
