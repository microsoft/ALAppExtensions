// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147632 "SL Batch Data"
{
    Caption = 'SL Batch data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL Batch"; "SL Batch")
            {
                AutoSave = false;
                XmlName = 'SLBatch';

                textelement(Module)
                {
                }
                textelement(BatNbr)
                {
                }
                textelement(Acct)
                {
                }
                textelement(CpnyID)
                {
                }
                textelement(JrnlType)
                {
                }
                textelement(LedgerID)
                {
                }
                textelement(Rlsed)
                {
                }
                textelement(Status)
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
                    SLBatch: Record "SL Batch";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLBatch.Module := Module;
                    SLBatch.BatNbr := BatNbr;
                    SLBatch.Acct := Acct;
                    SLBatch.CpnyID := CopyStr(CpnyID, 1, MaxStrLen(SLBatch.CpnyID));
                    SLBatch.JrnlType := JrnlType;
                    SLBatch.LedgerID := LedgerID;
                    Evaluate(SLBatch.Rlsed, Rlsed);
                    SLBatch.Status := Status;
                    SLBatch.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLBatch.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLBatch: Record "SL Batch";
}