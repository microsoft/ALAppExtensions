// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147655 "SL Supported Tax Year Data"
{
    Caption = 'SL Supported Tax Year data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL Supported Tax Year"; "SL Supported Tax Year")
            {
                AutoSave = false;
                XmlName = 'SLSupportedTaxYear';
                UseTemporary = true;

                textelement("TaxYear")
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

                    Evaluate(TempSLSupportedTaxYear."Tax Year", TaxYear);
                    TempSLSupportedTaxYear.Insert(true);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        CaptionRow := true;
    end;

    procedure GetExpectedSLSupportedTaxYear(var NewTempSLSupportedTaxYear: Record "SL Supported Tax Year" temporary)
    begin
        if TempSLSupportedTaxYear.FindSet() then
            repeat
                NewTempSLSupportedTaxYear := TempSLSupportedTaxYear;
                NewTempSLSupportedTaxYear.Insert();
            until TempSLSupportedTaxYear.Next() = 0;
    end;

    var
        CaptionRow: Boolean;
        TempSLSupportedTaxYear: Record "SL Supported Tax Year" temporary;
}