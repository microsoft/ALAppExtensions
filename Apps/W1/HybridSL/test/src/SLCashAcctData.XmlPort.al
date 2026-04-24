// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147635 "SL CashAcct Data"
{
    Caption = 'SL CashAcct data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL CashAcct"; "SL CashAcct")
            {
                AutoSave = false;
                XmlName = 'SLCashAcct';

                textelement(CpnyID)
                {
                }
                textelement(BankAcct)
                {
                }
                textelement(BankSub)
                {
                }
                textelement(AcceptGLUpdates)
                {
                }
                textelement(AcctNbr)
                {
                }
                textelement(Active)
                {
                }
                textelement(AddrID)
                {
                }
                textelement(CashAcctName)
                {
                }
                textelement(transitnbr)
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
                    SLCashAcct: Record "SL CashAcct";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLCashAcct.CpnyID := CpnyID;
                    SLCashAcct.BankAcct := BankAcct;
                    SLCashAcct.BankSub := BankSub;
                    Evaluate(SLCashAcct.AcceptGLUpdates, AcceptGLUpdates);
                    SLCashAcct.AcctNbr := AcctNbr;
                    Evaluate(SLCashAcct.Active, Active);
                    SLCashAcct.AddrID := AddrID;
                    SLCashAcct.CashAcctName := CashAcctName;
                    SLCashAcct.transitnbr := transitnbr;
                    SLCashAcct.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLCashAcct.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLCashAcct: Record "SL CashAcct";
}