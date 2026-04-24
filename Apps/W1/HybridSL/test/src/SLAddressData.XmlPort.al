// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147634 "SL Address Data"
{
    Caption = 'SL Address data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL Address"; "SL Address")
            {
                AutoSave = false;
                XmlName = 'SLAddress';

                textelement(AddrId)
                {
                }
                textelement(Addr1)
                {
                }
                textelement(Addr2)
                {
                }
                textelement(Attn)
                {
                }
                textelement(City)
                {
                }
                textelement(Country)
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
                textelement(State)
                {
                }
                textelement(TaxRegNbr)
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
                    SLAddress: Record "SL Address";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLAddress.AddrId := AddrId;
                    SLAddress.Addr1 := Addr1;
                    SLAddress.Addr2 := Addr2;
                    SLAddress.Attn := Attn;
                    SLAddress.City := City;
                    SLAddress.Country := Country;
                    SLAddress.Fax := Fax;
                    SLAddress.Name := Name;
                    SLAddress.Phone := Phone;
                    SLAddress.State := State;
                    SLAddress.TaxRegNbr := TaxRegNbr;
                    SLAddress.Zip := Zip;
                    SLAddress.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLAddress.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLAddress: Record "SL Address";
}