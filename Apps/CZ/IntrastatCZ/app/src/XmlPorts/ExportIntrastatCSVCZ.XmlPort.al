// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using System.IO;

xmlport 31300 "Export Intrastat CSV CZ"
{
    Caption = 'Export Intrastat CSV';
    Direction = Export;
    Format = VariableText;
    TextEncoding = WINDOWS;
    UseRequestPage = false;
    FieldSeparator = ';';
    FieldDelimiter = '"';

    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            tableelement("Data Exch. Field"; "Data Exch. Field")
            {
                XmlName = 'DataExchField';
                textelement(ColumnX)
                {
                    MinOccurs = Zero;
                    Unbound = true;

                    trigger OnBeforePassVariable()
                    begin
                        if QuitLoop then
                            currXMLport.BreakUnbound();

                        if "Data Exch. Field"."Line No." <> LastLineNo then begin
                            if "Data Exch. Field"."Line No." <> LastLineNo + 1 then
                                ErrorText += LinesNotSequentialErr
                            else begin
                                LastLineNo := "Data Exch. Field"."Line No.";
                                PrevColumnNo := 0;
                                "Data Exch. Field".Next(-1);
                                Window.Update(1, LastLineNo);
                            end;
                            currXMLport.BreakUnbound();
                        end;

                        CheckColumnSequence();
                        ColumnX := "Data Exch. Field".Value;

                        if "Data Exch. Field".Next() = 0 then
                            QuitLoop := true;
                    end;
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnInitXmlPort()
    begin
        Window.Open(ProgressMsg);
    end;

    trigger OnPostXmlPort()
    begin
        if ErrorText <> '' then
            Error(ErrorText);

        Window.Close();
    end;

    trigger OnPreXmlPort()
    begin
        InitializeGlobals();
    end;

    var
        DataExchDef: Record "Data Exch. Def";
        DataExch: Record "Data Exch.";
        Window: Dialog;
        ErrorText: Text;
        DataExchEntryNo: Integer;
        LastLineNo: Integer;
        PrevColumnNo: Integer;
        QuitLoop: Boolean;
        ColumnsNotSequentialErr: Label 'The data to be exported is not structured correctly. The columns in the dataset must be sequential.';
        LinesNotSequentialErr: Label 'The data to be exported is not structured correctly. The lines in the dataset must be sequential.';
        ProgressMsg: Label 'Exporting line no. #1######';

    local procedure InitializeGlobals()
    begin
        DataExchEntryNo := "Data Exch. Field".GetRangeMin("Data Exch. No.");
        LastLineNo := 1;
        PrevColumnNo := 0;
        QuitLoop := false;

        if DataExch.Get(DataExchEntryNo) and DataExchDef.Get(DataExch."Data Exch. Def Code") then begin
            currXMLport.Filename := DataExchDef.Name + '.csv';
            if currXMLport.FieldSeparator <> DataExchDef.ColumnSeparatorChar() then
                currXMLport.FieldSeparator(DataExchDef.ColumnSeparatorChar())
        end;
    end;

    procedure CheckColumnSequence()
    begin
        if "Data Exch. Field"."Column No." <> PrevColumnNo + 1 then begin
            ErrorText += ColumnsNotSequentialErr;
            currXMLport.BreakUnbound();
        end;

        PrevColumnNo := "Data Exch. Field"."Column No.";
    end;
}

