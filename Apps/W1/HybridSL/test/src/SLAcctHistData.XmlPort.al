// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147608 "SL AcctHist Data"
{
    Caption = 'SL AcctHist data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL AcctHist"; "SL AcctHist")
            {
                AutoSave = false;
                XmlName = 'SLAcctHist';

                textelement(CpnyID)
                {
                }
                textelement(Acct)
                {
                }
                textelement(Sub)
                {
                }
                textelement(LedgerID)
                {
                }
                textelement(FiscYr)
                {
                }
                textelement(PtdBal00)
                {
                }
                textelement(PtdBal01)
                {
                }
                textelement(PtdBal02)
                {
                }
                textelement(PtdBal03)
                {
                }
                textelement(PtdBal04)
                {
                }
                textelement(PtdBal05)
                {
                }
                textelement(PtdBal06)
                {
                }
                textelement(PtdBal07)
                {
                }
                textelement(PtdBal08)
                {
                }
                textelement(PtdBal09)
                {
                }
                textelement(PtdBal10)
                {
                }
                textelement(PtdBal11)
                {
                }
                textelement(PtdBal12)
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
                    SLAcctHist: Record "SL AcctHist";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLAcctHist.CpnyID := CpnyID;
                    SLAcctHist.Acct := Acct;
                    SLAcctHist.Sub := Sub;
                    SLAcctHist.LedgerID := LedgerID;
                    SLAcctHist.FiscYr := FiscYr;
                    Evaluate(SLAcctHist.PtdBal00, PtdBal00);
                    Evaluate(SLAcctHist.PtdBal01, PtdBal01);
                    Evaluate(SLAcctHist.PtdBal02, PtdBal02);
                    Evaluate(SLAcctHist.PtdBal03, PtdBal03);
                    Evaluate(SLAcctHist.PtdBal04, PtdBal04);
                    Evaluate(SLAcctHist.PtdBal05, PtdBal05);
                    Evaluate(SLAcctHist.PtdBal06, PtdBal06);
                    Evaluate(SLAcctHist.PtdBal07, PtdBal07);
                    Evaluate(SLAcctHist.PtdBal08, PtdBal08);
                    Evaluate(SLAcctHist.PtdBal09, PtdBal09);
                    Evaluate(SLAcctHist.PtdBal10, PtdBal10);
                    Evaluate(SLAcctHist.PtdBal11, PtdBal11);
                    Evaluate(SLAcctHist.PtdBal12, PtdBal12);
                    SLAcctHist.Insert(true);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLAcctHist.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLAcctHist: Record "SL AcctHist";
}