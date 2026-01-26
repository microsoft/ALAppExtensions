// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147615 "SL Vendor Data"
{
    Caption = 'SL Vendor data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL Vendor"; "SL Vendor")
            {
                AutoSave = false;
                XmlName = 'SLVendor';

                textelement(VendId)
                {
                }
                textelement(Addr1)
                {
                }
                textelement(Addr2)
                {
                }
                textelement(APAcct)
                {
                }
                textelement(APSub)
                {
                }
                textelement(Attn)
                {
                }
                textelement(City)
                {
                }
                textelement(ClassID)
                {
                }
                textelement(Country)
                {
                }
                textelement(EMailAddr)
                {
                }
                textelement(Fax)
                {
                }
                textelement(Name)
                {
                }
                textelement(Phone)
                {
                }
                textelement(RemitName)
                {
                }
                textelement(State)
                {
                }
                textelement(Status)
                {
                }
                textelement(TaxId00)
                {
                }
                textelement(TaxRegNbr)
                {
                }
                textelement(Terms)
                {
                }
                textelement(Zip)
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
                    SLVendor: Record "SL Vendor";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLVendor.VendId := VendId;
                    SLVendor.Addr1 := Addr1;
                    SLVendor.Addr2 := Addr2;
                    SLVendor.APAcct := APAcct;
                    SLVendor.APSub := APSub;
                    SLVendor.Attn := Attn;
                    SLVendor.City := City;
                    SLVendor.ClassID := ClassID;
                    SLVendor.Country := Country;
                    SLVendor.EMailAddr := EMailAddr;
                    SLVendor.Fax := Fax;
                    SLVendor.Name := Name;
                    SLVendor.Phone := Phone;
                    SLVendor.RemitName := RemitName;
                    SLVendor.State := State;
                    SLVendor.Status := Status;
                    SLVendor.TaxId00 := TaxId00;
                    SLVendor.TaxRegNbr := TaxRegNbr;
                    SLVendor.Terms := Terms;
                    SLVendor.Zip := Zip;
                    SLVendor.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLVendor.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLVendor: Record "SL Vendor";
}
