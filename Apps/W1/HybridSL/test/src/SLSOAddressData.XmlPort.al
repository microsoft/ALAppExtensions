// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147607 "SL SOAddress Data"
{
    Caption = 'SL SOAddress data import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL SOAddress"; "SL SOAddress")
            {
                AutoSave = false;
                XmlName = 'SLSOSetup';

                textelement(CustId)
                {
                }
                textelement(ShipToId)
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
                textelement(EMailAddr)
                {
                }
                textelement(Fax)
                {
                }
                textelement(Phone)
                {
                }
                textelement(ShipViaID)
                {
                }
                textelement(State)
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
                    SLSOAddress: Record "SL SOAddress";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLSOAddress.CustId := CustId;
                    SLSOAddress.ShipToId := ShipToId;
                    SLSOAddress.Addr1 := Addr1;
                    SLSOAddress.Addr2 := Addr2;
                    SLSOAddress.Attn := Attn;
                    SLSOAddress.City := City;
                    SLSOAddress.Country := Country;
                    SLSOAddress.EMailAddr := EMailAddr;
                    SLSOAddress.Fax := Fax;
                    SLSOAddress.Phone := Phone;
                    SLSOAddress.State := State;
                    SLSOAddress.Zip := Zip;
                    SLSOAddress.Insert(true);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLSOAddress.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLSOAddress: Record "SL SOAddress";
}