// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147640 "SL Site Data"
{
    Caption = 'SL Site data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL Site"; "SL Site")
            {
                AutoSave = false;
                XmlName = 'SLSite';

                textelement(SiteId)
                {
                }
                textelement(Addr1)
                {
                }
                textelement(Addr2)
                {
                }
                textelement(City)
                {
                }
                textelement(CpnyID)
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
                    SLSite: Record "SL Site";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLSite.SiteId := SiteId;
                    SLSite.Addr1 := Addr1;
                    SLSite.Addr2 := Addr2;
                    SLSite.City := City;
                    SLSite.CpnyID := CpnyID;
                    SLSite.Fax := Fax;
                    SLSite.Name := Name;
                    SLSite.Phone := Phone;
                    SLSite.Zip := Zip;
                    SLSite.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLSite.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLSite: Record "SL Site";
}