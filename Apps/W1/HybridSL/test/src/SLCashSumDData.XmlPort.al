// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147638 "SL CashSumD Data"
{
    Caption = 'SL CashSumD data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL CashSumD"; "SL CashSumD")
            {
                AutoSave = false;
                XmlName = 'SLCashSumD';

                textelement(CpnyID)
                {
                }
                textelement(BankAcct)
                {
                }
                textelement(BankSub)
                {
                }
                textelement(PerNbr)
                {
                }
                textelement(TranDate)
                {
                }
                textelement(Disbursements)
                {
                }
                textelement(Receipts)
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
                    SLCashSumD: Record "SL CashSumD";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLCashSumD.CpnyID := CpnyID;
                    SLCashSumD.BankAcct := BankAcct;
                    SLCashSumD.BankSub := BankSub;
                    SLCashSumD.PerNbr := PerNbr;
                    Evaluate(SLCashSumD.TranDate, TranDate);
                    Evaluate(SLCashSumD.Disbursements, Disbursements);
                    Evaluate(SLCashSumD.Receipts, Receipts);
                    SLCashSumD.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLCashSumD.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLCashSumD: Record "SL CashSumD";
}