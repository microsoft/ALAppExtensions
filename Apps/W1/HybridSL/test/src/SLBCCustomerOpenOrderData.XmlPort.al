// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Sales.Customer;

xmlport 147652 "SL BC Customer Open Order Data"
{
    Caption = 'SL BC Customer for Open Order data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("BCCustomer"; Customer)
            {
                AutoSave = false;
                XmlName = 'Customer';

                textelement("No.")
                {
                }
                textelement("Name")
                {
                }
                textelement("SearchName")
                {
                }
                textelement("Name2")
                {
                }
                textelement("Address")
                {
                }
                textelement("Address2")
                {
                }
                textelement("City")
                {
                }
                textelement("Contact")
                {
                }
                textelement("PhoneNo.")
                {
                }
                textelement("TerritoryCode")
                {
                }
                textelement("CreditLimit")
                {
                }
                textelement("CustomerPostingGroup")
                {
                }
                textelement("PaymentTermsCode")
                {
                }
                textelement("SalespersonCode")
                {
                }
                textelement("ShipmentMethodCode")
                {
                }
                textelement("CountryRegionCode")
                {
                }
                textelement("Blocked")
                {
                }
                textelement("FaxNo.")
                {
                }
                textelement("GenBusPostingGroup")
                {
                }
                textelement("ZIPCode")
                {
                }
                textelement("State")
                {
                }
                textelement("TaxAreaCode")
                {
                }
                textelement("TaxLiable")
                {
                }

                trigger OnPreXmlItem()
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;
                end;

                trigger OnBeforeInsertRecord()
                var
                    Customer: Record Customer;
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    Customer."No." := "No.";
                    Customer.Name := "Name";
                    Customer."Search Name" := "SearchName";
                    Customer."Name 2" := "Name2";
                    Customer.Address := "Address";
                    Customer."Address 2" := "Address2";
                    Customer.City := "City";
                    Customer.Contact := "Contact";
                    Customer."Phone No." := "PhoneNo.";
                    Customer."Territory Code" := "TerritoryCode";
                    if CreditLimit <> '' then
                        Evaluate(Customer."Credit Limit (LCY)", "CreditLimit", 9);
                    Customer."Customer Posting Group" := "CustomerPostingGroup";
                    // Customer."Payment Terms Code" := "PaymentTermsCode";
                    Customer."Salesperson Code" := "SalespersonCode";
                    Customer."Shipment Method Code" := "ShipmentMethodCode";
                    Customer."Country/Region Code" := "CountryRegionCode";
                    if Blocked <> '' then
                        Evaluate(Customer.Blocked, Blocked, 9);
                    Customer."Fax No." := "FaxNo.";
                    Customer."Gen. Bus. Posting Group" := "GenBusPostingGroup";
                    Customer."Post Code" := "ZIPCode";
                    Customer.County := State;
                    Customer."Tax Area Code" := "TaxAreaCode";
                    if TaxLiable <> '' then
                        Evaluate(Customer."Tax Liable", "TaxLiable", 9);
                    Customer.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        Customer.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        Customer: Record Customer;
}