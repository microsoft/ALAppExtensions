// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147658 "SL AP Balances Data"
{
    Caption = 'SL AP Balances data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL AP Balances"; "SL AP_Balances")
            {
                AutoSave = false;
                XmlName = 'SLAPBalances';

                textelement(VendID)
                {
                }
                textelement(CpnyID)
                {
                }
                textelement(CYBox00)
                {
                }
                textelement(CYBox01)
                {
                }
                textelement(CYBox02)
                {
                }
                textelement(CYBox03)
                {
                }
                textelement(CYBox04)
                {
                }
                textelement(CYBox05)
                {
                }
                textelement(CYBox06)
                {
                }
                textelement(CYBox07)
                {
                }
                textelement(CYBox08)
                {
                }
                textelement(CYBox09)
                {
                }
                textelement(CYBox10)
                {
                }
                textelement(CYBox11)
                {
                }
                textelement(CYBox12)
                {
                }
                textelement(CYBox13)
                {
                }
                textelement(CYBox14)
                {
                }
                textelement(CYBox15)
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
                    SLAPBalances: Record "SL AP_Balances";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLAPBalances.VendID := VendID;
                    SLAPBalances.CpnyID := CpnyID;
                    Evaluate(SLAPBalances.CYBox00, CYBox00);
                    Evaluate(SLAPBalances.CYBox01, CYBox01);
                    Evaluate(SLAPBalances.CYBox02, CYBox02);
                    Evaluate(SLAPBalances.CYBox03, CYBox03);
                    Evaluate(SLAPBalances.CYBox04, CYBox04);
                    Evaluate(SLAPBalances.CYBox05, CYBox05);
                    Evaluate(SLAPBalances.CYBox06, CYBox06);
                    Evaluate(SLAPBalances.CYBox07, CYBox07);
                    Evaluate(SLAPBalances.CYBox08, CYBox08);
                    Evaluate(SLAPBalances.CYBox09, CYBox09);
                    Evaluate(SLAPBalances.CYBox10, CYBox10);
                    Evaluate(SLAPBalances.CYBox11, CYBox11);
                    Evaluate(SLAPBalances.CYBox12, CYBox12);
                    Evaluate(SLAPBalances.CYBox13, CYBox13);
                    Evaluate(SLAPBalances.CYBox14, CYBox14);
                    Evaluate(SLAPBalances.CYBox15, CYBox15);
                    SLAPBalances.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLAPBalances.DeleteAll(true);
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLAPBalances: Record "SL AP_Balances";
}
