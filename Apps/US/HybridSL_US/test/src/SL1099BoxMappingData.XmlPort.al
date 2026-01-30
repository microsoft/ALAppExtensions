// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147656 "SL 1099 Box Mapping Data"
{
    Caption = 'SL 1099 Box Mapping data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL 1099 Box Mapping"; "SL 1099 Box Mapping")
            {
                AutoSave = false;
                XmlName = 'SL1099BoxMapping';
                UseTemporary = true;

                textelement(TaxYear)
                {
                }
                textelement(SLDataValue)
                {
                }
                textelement(SL1099BoxNo)
                {
                }
                textelement(FormType)
                {
                }
                textelement(BCIRS1099Code)
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

                    Evaluate(TempSL1099BoxMapping."Tax Year", TaxYear);
                    Evaluate(TempSL1099BoxMapping."SL Data Value", SLDataValue);
                    TempSL1099BoxMapping."SL 1099 Box No." := SL1099BoxNo;
                    TempSL1099BoxMapping."Form Type" := FormType;
                    TempSL1099BoxMapping."BC IRS 1099 Code" := BCIRS1099Code;
                    TempSL1099BoxMapping.Insert(true);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        CaptionRow := true;
    end;

    procedure GetExpectedSL1099BoxMapping(var NewTempSL1099BoxMapping: Record "SL 1099 Box Mapping" temporary)
    begin
        if TempSL1099BoxMapping.FindSet() then
            repeat
                NewTempSL1099BoxMapping := TempSL1099BoxMapping;
                NewTempSL1099BoxMapping.Insert();
            until TempSL1099BoxMapping.Next() = 0;
    end;

    var
        CaptionRow: Boolean;
        TempSL1099BoxMapping: Record "SL 1099 Box Mapping" temporary;
}
