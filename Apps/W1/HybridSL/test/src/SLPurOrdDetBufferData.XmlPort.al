// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147642 "SL PurOrdDet Buffer Data"
{
    Caption = 'SL PurOrdDet Buffer data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL PurOrdDet Buffer"; "SL PurOrdDet Buffer")
            {
                AutoSave = false;
                XmlName = 'SLPurOrdDetBuffer';

                textelement(PONbr)
                {
                }
                textelement(LineRef)
                {
                }
                textelement(CnvFact)
                {
                }
                textelement(CostReceived)
                {
                }
                textelement(CpnyID)
                {
                }
                textelement(ExtCost)
                {
                }
                textelement(InvtID)
                {
                }
                textelement(LineID)
                {
                }
                textelement(OpenLine)
                {
                }
                textelement(PromDate)
                {
                }
                textelement(PurAcct)
                {
                }
                textelement(PurchaseType)
                {
                }
                textelement(PurchUnit)
                {
                }
                textelement(PurSub)
                {
                }
                textelement(QtyOrd)
                {
                }
                textelement(QtyRcvd)
                {
                }
                textelement(TranDesc)
                {
                }
                textelement(UnitCost)
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
                    SLPurOrdDetBuffer: Record "SL PurOrdDet Buffer";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLPurOrdDetBuffer.PONbr := PONbr;
                    SLPurOrdDetBuffer.LineRef := LineRef;
                    Evaluate(SLPurOrdDetBuffer.CnvFact, CnvFact);
                    Evaluate(SLPurOrdDetBuffer.CostReceived, CostReceived);
                    SLPurOrdDetBuffer.CpnyID := CopyStr(CpnyID, 1, MaxStrLen(SLPurOrdDetBuffer.CpnyID));
                    Evaluate(SLPurOrdDetBuffer.ExtCost, ExtCost);
                    SLPurOrdDetBuffer.InvtID := InvtID;
                    Evaluate(SLPurOrdDetBuffer.LineID, LineID);
                    Evaluate(SLPurOrdDetBuffer.OpenLine, OpenLine);
                    if PromDate <> '' then
                        Evaluate(SLPurOrdDetBuffer.PromDate, PromDate);
                    SLPurOrdDetBuffer.PurAcct := PurAcct;
                    SLPurOrdDetBuffer.PurchaseType := PurchaseType;
                    SLPurOrdDetBuffer.PurchUnit := PurchUnit;
                    SLPurOrdDetBuffer.PurSub := PurSub;
                    Evaluate(SLPurOrdDetBuffer.QtyOrd, QtyOrd);
                    Evaluate(SLPurOrdDetBuffer.QtyRcvd, QtyRcvd);
                    SLPurOrdDetBuffer.TranDesc := TranDesc;
                    Evaluate(SLPurOrdDetBuffer.UnitCost, UnitCost);
                    SLPurOrdDetBuffer.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLPurOrdDetBuffer.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLPurOrdDetBuffer: Record "SL PurOrdDet Buffer";
}