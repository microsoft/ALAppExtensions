// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147653 "SL Vendor Data"
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
                textelement(Curr1099Yr)
                {
                }
                textelement(DfltBox)
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
                textelement(Next1099Yr)
                {
                }
                textelement(Phone)
                {
                }
                textelement(RemitName)
                {
                }
                textelement(S4Future09)
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
                textelement(TIN)
                {
                }
                textelement(Vend1099)
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
                    SLVendor.Curr1099Yr := Curr1099Yr;
                    SLVendor.DfltBox := DfltBox;
                    SLVendor.EMailAddr := EMailAddr;
                    SLVendor.Fax := Fax;
                    SLVendor.Name := Name;
                    SLVendor.Next1099Yr := Next1099Yr;
                    SLVendor.Phone := Phone;
                    SLVendor.RemitName := RemitName;
                    Evaluate(SLVendor.S4Future09, S4Future09, 9);
                    SLVendor.State := State;
                    SLVendor.Status := Status;
                    SLVendor.TaxId00 := TaxId00;
                    SLVendor.TaxRegNbr := TaxRegNbr;
                    SLVendor.Terms := Terms;
                    SLVendor.TIN := TIN;
                    Evaluate(SLVendor.Vend1099, Vend1099, 9);
                    SLVendor.Zip := Zip;
                    SLVendor.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLVendor.DeleteAll(true);
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLVendor: Record "SL Vendor";
}
