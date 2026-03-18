// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Purchases.Vendor;

xmlport 147657 "SL BC Vendor With 1099 Data"
{
    Caption = 'BC Vendor With 1099 data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement(Vendor; Vendor)
            {
                AutoSave = false;
                XmlName = 'BCVendor';
                UseTemporary = true;

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
                textelement("ZIPCode")
                {
                }
                textelement("State")
                {
                }
                textelement("Email")
                {
                }
                textelement("TaxAreaCode")
                {
                }
                textelement("TaxLiable")
                {
                }
                textelement("FederalIDNo")
                {
                }
                textelement("FATCARequirement")
                {
                }
                textelement("TaxIdentificationType")
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

                    TempVendor."No." := "No.";
                    TempVendor.Name := "Name";
                    TempVendor."Search Name" := "SearchName";
                    TempVendor."Name 2" := "Name2";
                    TempVendor.Address := "Address";
                    TempVendor."Address 2" := "Address2";
                    TempVendor.City := "City";
                    TempVendor."Contact" := "Contact";
                    TempVendor."Phone No." := "PhoneNo.";
                    TempVendor."Vendor Posting Group" := "VendorPostingGroup";
                    TempVendor."Payment Terms Code" := "PaymentTermsCode";
                    TempVendor."Country/Region Code" := "CountryRegionCode";
                    Evaluate(TempVendor."Blocked", "Blocked");
                    TempVendor."Fax No." := "FaxNo.";
                    TempVendor."Gen. Bus. Posting Group" := "GenBusPostingGroup";
                    TempVendor."Post Code" := "ZipCode";
                    TempVendor.County := "State";
                    TempVendor."E-Mail" := "EMail";
                    TempVendor."Tax Area Code" := "TaxAreaCode";
                    Evaluate(TempVendor."Tax Liable", "TaxLiable", 9);
                    TempVendor."Federal ID No." := "FederalIDNo";
                    Evaluate(TempVendor."FATCA Requirement", "FATCARequirement", 9);
                    Evaluate(TempVendor."Tax Identification Type", "TaxIdentificationType");
                    TempVendor.Insert(false);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        CaptionRow := true;
    end;

    procedure GetExpectedVendors(var NewTempVendor: Record Vendor temporary)
    begin
        if TempVendor.FindSet() then begin
            repeat
                NewTempVendor.Copy(TempVendor);
                NewTempVendor.Insert();
            until TempVendor.Next() = 0;
        end;
    end;

    var
        CaptionRow: Boolean;
        TempVendor: Record Vendor temporary;
}
