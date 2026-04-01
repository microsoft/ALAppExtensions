// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Inventory.Location;

xmlport 147650 "SL BC Locations Open Orders"
{
    Caption = 'SL BC Locations data for open orders import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("BCLocation"; Location)
            {
                AutoSave = false;
                XmlName = 'Location';

                textelement(Code)
                {
                }
                textelement(Name)
                {
                }
                textelement(Address)
                {
                }
                textelement(Address2)
                {
                }
                textelement(City)
                {
                }
                textelement(PhoneNo)
                {
                }
                textelement(FaxNo)
                {
                }
                textelement(ZipCode)
                {
                }
                textelement(State)
                {
                }
                textelement(CountryRegionCode)
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
                    Location: Record Location;
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    Location.Code := Code;
                    Location.Name := Name;
                    Location.Address := Address;
                    Location."Address 2" := Address2;
                    Location.City := City;
                    Location."Phone No." := PhoneNo;
                    Location."Fax No." := FaxNo;
                    Location."Post Code" := ZipCode;
                    Location.County := State;
                    Location."Country/Region Code" := CountryRegionCode;
                    Location.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        Location.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        Location: Record Location;
}