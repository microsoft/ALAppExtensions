// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Finance.Dimension;

xmlport 147629 "SL BC Dimension Value Data"
{
    Caption = 'BC Dimension Value data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("Dimension Value"; "Dimension Value")
            {
                AutoSave = false;
                XmlName = 'DimensionValue';

                textelement(DimensionCode)
                {
                }
                textelement(Code)
                {
                }
                textelement(Name)
                {
                }
                textelement(Indentation)
                {
                }
                textelement(GlobalDimensionNo)
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
                    DimensionValue: Record "Dimension Value";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    DimensionValue."Dimension Code" := DimensionCode;
                    DimensionValue.Code := Code;
                    DimensionValue.Name := Name;
                    Evaluate(DimensionValue.Indentation, Indentation);
                    Evaluate(DimensionValue."Global Dimension No.", GlobalDimensionNo);
                    DimensionValue.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        DimensionValue.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        DimensionValue: Record "Dimension Value";
}