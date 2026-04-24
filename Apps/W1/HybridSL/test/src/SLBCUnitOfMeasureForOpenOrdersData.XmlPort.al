// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Foundation.UOM;

xmlport 147648 "SL BC UOM Open Orders"
{
    Caption = 'SL BC Unit of Measure for Open Orders data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("BCUnitofMeasure"; "Unit of Measure")
            {
                AutoSave = false;
                XmlName = 'UnitOfMeasure';

                textelement(Code)
                {
                }
                textelement(Description)
                {
                }
                textelement(InternationalStandardCode)
                {
                }
                textelement(Symbol)
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
                    UnitOfMeasure: Record "Unit of Measure";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    UnitOfMeasure.Code := Code;
                    UnitOfMeasure.Description := Description;
                    UnitOfMeasure."International Standard Code" := InternationalStandardCode;
                    UnitOfMeasure.Symbol := Symbol;
                    UnitOfMeasure.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        UnitOfMeasure.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        UnitOfMeasure: Record "Unit of Measure";
}