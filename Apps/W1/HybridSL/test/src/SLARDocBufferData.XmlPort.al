// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147631 "SL ARDoc Buffer Data"
{
    Caption = 'SL ARDoc Buffer data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL ARDoc Buffer"; "SL ARDoc Buffer")
            {
                AutoSave = false;
                XmlName = 'SLARDocBuffer';

                textelement(CustId)
                {
                }
                textelement(DocType)
                {
                }
                textelement(RefNbr)
                {
                }
                textelement(BatNbr)
                {
                }
                textelement(BatSeq)
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
                textelement(OpenDoc)
                {
                }
                textelement(OrdNbr)
                {
                }
                textelement(Rlsed)
                {
                }
                textelement(SlsperId)
                {
                }
                textelement(Status)
                {
                }
                textelement(Terms)
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
                    SLARDocBuffer: Record "SL ARDoc Buffer";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLARDocBuffer.CustId := CustId;
                    SLARDocBuffer.DocType := DocType;
                    SLARDocBuffer.RefNbr := RefNbr;
                    SLARDocBuffer.BatNbr := BatNbr;
                    Evaluate(SLARDocBuffer.BatSeq, BatSeq);
                    SLARDocBuffer.CpnyID := CpnyID;
                    Evaluate(SLARDocBuffer.DocBal, DocBal);
                    Evaluate(SLARDocBuffer.DocDate, DocDate);
                    SLARDocBuffer.DocDesc := DocDesc;
                    Evaluate(SLARDocBuffer.DueDate, DueDate);
                    Evaluate(SLARDocBuffer.OpenDoc, OpenDoc);
                    SLARDocBuffer.OrdNbr := OrdNbr;
                    Evaluate(SLARDocBuffer.Rlsed, Rlsed);
                    SLARDocBuffer.SlsperId := SlsperId;
                    SLARDocBuffer.Status := Status;
                    SLARDocBuffer.Terms := Terms;
                    SLARDocBuffer.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLARDocBuffer.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLARDocBuffer: Record "SL ARDoc Buffer";
}
