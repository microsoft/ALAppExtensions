// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Purchases.Vendor;

xmlport 147654 "SL BC Vendor No 1099 Data"
{
    Caption = 'Vendor data without 1099 information for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("Vendor"; Vendor)
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
                textelement("VendorPostingGroup")
                {
                }
                textelement("PaymentTermsCode")
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
                    BCVendor: Record Vendor;
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    BCVendor."No." := "No.";
                    BCVendor.Name := "Name";
                    BCVendor."Search Name" := "SearchName";
                    BCVendor."Name 2" := "Name2";
                    BCVendor.Address := "Address";
                    BCVendor."Address 2" := "Address2";
                    BCVendor.City := "City";
                    BCVendor."Contact" := "Contact";
                    BCVendor."Phone No." := "PhoneNo.";
                    BCVendor."Vendor Posting Group" := "VendorPostingGroup";
                    BCVendor."Payment Terms Code" := "PaymentTermsCode";
                    BCVendor."Country/Region Code" := "CountryRegionCode";
                    Evaluate(BCVendor."Blocked", "Blocked");
                    BCVendor."Fax No." := "FaxNo.";
                    BCVendor."Gen. Bus. Posting Group" := "GenBusPostingGroup";
                    BCVendor."Post Code" := "ZipCode";
                    BCVendor.County := "State";
                    BCVendor."E-Mail" := "EMail";
                    BCVendor."Tax Area Code" := "TaxAreaCode";
                    Evaluate(BCVendor."Tax Liable", "TaxLiable", 9);
                    BCVendor.Insert(true);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        BCVendor.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        BCVendor: Record Vendor;
}
