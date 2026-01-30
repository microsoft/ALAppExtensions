// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Finance.Dimension;

xmlport 147628 "SL BC Dimension Data"
{
    Caption = 'BC Dimension data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("Dimension"; Dimension)
            {
                AutoSave = false;
                XmlName = 'Dimension';

                textelement(Code)
                {
                }
                textelement(Name)
                {
                }
                textelement(CodeCaption)
                {
                }
                textelement(FilterCaption)
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
                    Dimension: Record Dimension;
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    Dimension.Code := Code;
                    Dimension.Name := Name;
                    Dimension."Code Caption" := CodeCaption;
                    Dimension."Filter Caption" := FilterCaption;
                    Dimension.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        DimensionRec.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        DimensionRec: Record Dimension;
}