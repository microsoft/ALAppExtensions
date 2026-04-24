// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Purchases.Vendor;

xmlport 147645 "SL BC Vendor for Open POs Data"
{
    Caption = 'SL BC Vendor for Open POs data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("BCVendor"; Vendor)
            {
                AutoSave = false;
                XmlName = 'Vendor';

                textelement("No.")
                {
                }
                textelement("Name")
                {
                }
                textelement("SearchName")
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
                textelement("VendorPostingGroup")
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
                textelement("TaxRegistrationNo")
                {
                }
                textelement("GenBusPostingGroup")
                {
                }
                textelement("ZipCode")
                {
                }
                textelement("State")
                {
                }
                textelement("EMail")
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
                    Vendor: Record Vendor;
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    Vendor."No." := "No.";
                    Vendor.Name := "Name";
                    Vendor."Search Name" := "SearchName";
                    Vendor.Address := "Address";
                    Vendor."Address 2" := "Address2";
                    Vendor.City := "City";
                    Vendor.Contact := "Contact";
                    Vendor."Phone No." := "PhoneNo.";
                    Vendor."Vendor Posting Group" := "VendorPostingGroup";
                    Vendor."Shipment Method Code" := "ShipmentMethodCode";
                    Vendor."Country/Region Code" := "CountryRegionCode";
                    if Blocked <> '' then
                        Evaluate(Vendor.Blocked, "Blocked");
                    Vendor."VAT Registration No." := "TaxRegistrationNo";
                    Vendor."Gen. Bus. Posting Group" := "GenBusPostingGroup";
                    Vendor."Post Code" := "ZipCode";
                    Vendor.County := "State";
                    Vendor."E-Mail" := "EMail";
                    Vendor."Tax Area Code" := "TaxAreaCode";
                    if TaxLiable <> '' then
                        Evaluate(Vendor."Tax Liable", "TaxLiable", 9);
                    Vendor.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        Vendor.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        Vendor: Record Vendor;
}