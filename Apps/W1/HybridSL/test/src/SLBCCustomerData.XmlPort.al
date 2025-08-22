// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Sales.Customer;

xmlport 147604 "SL BC Customer Data"
{
    Caption = 'Customer data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("Customer"; Customer)
            {
                AutoSave = false;
                XmlName = 'Customer';
                UseTemporary = true;

                textelement("No.")
                {
                }
                textelement(Name)
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
                textelement(City)
                {
                }
                textelement(Contact)
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
                textelement(Blocked)
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
                textelement(State)
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
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    TempCustomer."No." := "No.";
                    TempCustomer.Name := Name;
                    TempCustomer."Search Name" := "SearchName";
                    TempCustomer."Name 2" := "Name2";
                    TempCustomer.Address := "Address";
                    TempCustomer."Address 2" := "Address2";
                    TempCustomer.City := City;
                    TempCustomer."Contact" := Contact;
                    TempCustomer."Phone No." := "PhoneNo.";
                    TempCustomer."Territory Code" := "TerritoryCode";
                    Evaluate(TempCustomer."Credit Limit (LCY)", "CreditLimit", 9);
                    TempCustomer."Customer Posting Group" := "CustomerPostingGroup";
                    TempCustomer."Payment Terms Code" := "PaymentTermsCode";
                    TempCustomer."Salesperson Code" := "SalespersonCode";
                    TempCustomer."Shipment Method Code" := "ShipmentMethodCode";
                    TempCustomer."Country/Region Code" := "CountryRegionCode";
                    Evaluate(TempCustomer.Blocked, Blocked, 9);
                    TempCustomer."Fax No." := "FaxNo.";
                    TempCustomer."Gen. Bus. Posting Group" := "GenBusPostingGroup";
                    TempCustomer."Post Code" := "ZIPCode";
                    TempCustomer."Tax Area Code" := "TaxAreaCode";
                    Evaluate(TempCustomer."Tax Liable", "TaxLiable", 9);
                    TempCustomer.Insert(false);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        CaptionRow := true;
    end;

    procedure GetExpectedCustomers(var NewTempCustomer: Record Customer temporary)
    begin
        if TempCustomer.FindSet() then begin
            repeat
                NewTempCustomer.Copy(TempCustomer);
                NewTempCustomer.Insert();
            until TempCustomer.Next() = 0;
        end;
    end;

    var
        CaptionRow: Boolean;
        TempCustomer: Record Customer temporary;
}