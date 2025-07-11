// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Foundation.Company;
using Microsoft.Purchases.History;
using Microsoft.Sales.Setup;

reportextension 11222 "SE Purchase - Return Shipment" extends "Purchase - Return Shipment"
{
    RDLCLayout = './src/ReportExtensions/PurchaseReturnShipment.rdlc';

    dataset
    {
        add("Return Shipment Header")
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
            column(CompanyInfoFaxNumber; CompanyInformation."Fax No.")
            {
            }
            column(CompanyInfoFaxNumberCaption; CompanyInformation.FieldCaption("Fax No."))
            {
            }
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
