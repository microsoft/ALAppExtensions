// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147633 "SL APDoc Buffer Data"
{
    Caption = 'SL APDoc Buffer data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL APDoc Buffer"; "SL APDoc Buffer")
            {
                AutoSave = false;
                XmlName = 'SLAPDocBuffer';

                textelement(AccountNumber)
                {
                }
                textelement(Sub)
                {
                }
                textelement(DocType)
                {
                }
                textelement(RefNbr)
                {
                }
                textelement(RecordID)
                {
                }
                textelement(BatchNbr)
                {
                }
                textelement(CpnyID)
                {
                }
                textelement(DocBal)
                {
                }
                textelement(DocDate)
                {
                }
                textelement(DocDesc)
                {
                }
                textelement(DueDate)
                {
                }
                textelement(InvcDate)
                {
                }
                textelement(InvcNbr)
                {
                }
                textelement(OpenDoc)
                {
                }
                textelement(PONbr)
                {
                }
                textelement(Rlsed)
                {
                }
                textelement(Status)
                {
                }
                textelement(Terms)
                {
                }
                textelement(VendId)
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
                    SLAPDocBuffer: Record "SL APDoc Buffer";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLAPDocBuffer.Acct := AccountNumber;
                    SLAPDocBuffer.Sub := Sub;
                    SLAPDocBuffer.DocType := DocType;
                    SLAPDocBuffer.RefNbr := RefNbr;
                    Evaluate(SLAPDocBuffer.RecordID, RecordID);
                    SLAPDocBuffer.BatNbr := BatchNbr;
                    SLAPDocBuffer.CpnyID := CopyStr(CpnyID, 1, MaxStrLen(SLAPDocBuffer.CpnyID));
                    Evaluate(SLAPDocBuffer.DocBal, DocBal);
                    Evaluate(SLAPDocBuffer.DocDate, DocDate);
                    SLAPDocBuffer.DocDesc := DocDesc;
                    Evaluate(SLAPDocBuffer.DueDate, DueDate);
                    Evaluate(SLAPDocBuffer.InvcDate, InvcDate);
                    SLAPDocBuffer.InvcNbr := InvcNbr;
                    Evaluate(SLAPDocBuffer.OpenDoc, OpenDoc);
                    SLAPDocBuffer.PONbr := PONbr;
                    Evaluate(SLAPDocBuffer.Rlsed, Rlsed);
                    SLAPDocBuffer.Status := Status;
                    SLAPDocBuffer.Terms := Terms;
                    SLAPDocBuffer.VendId := VendId;
                    SLAPDocBuffer.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLAPDocBuffer.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLAPDocBuffer: Record "SL APDoc Buffer";
}