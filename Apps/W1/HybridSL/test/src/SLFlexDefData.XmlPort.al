// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147627 "SL FlexDef Data"
{
    Caption = 'SL FlexDef data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL FlexDef"; "SL FlexDef")
            {
                AutoSave = false;
                XmlName = 'SLFlexDef';

                textelement(FieldClassName)
                {
                }
                textelement(Caption)
                {
                }
                textelement(Descr00)
                {
                }
                textelement(Descr01)
                {
                }
                textelement(Descr02)
                {
                }
                textelement(Descr03)
                {
                }
                textelement(Descr04)
                {
                }
                textelement(Descr05)
                {
                }
                textelement(Descr06)
                {
                }
                textelement(Descr07)
                {
                }
                textelement(NumberSegments)
                {
                }
                textelement(SegLength00)
                {
                }
                textelement(SegLength01)
                {
                }
                textelement(SegLength02)
                {
                }
                textelement(SegLength03)
                {
                }
                textelement(SegLength04)
                {
                }
                textelement(SegLength05)
                {
                }
                textelement(SegLength06)
                {
                }
                textelement(SegLength07)
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
                    SLFlexDef: Record "SL FlexDef";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLFlexDef.FieldClassName := FieldClassName;
                    SLFlexDef.Caption := Caption;
                    SLFlexDef.Descr00 := Descr00;
                    SLFlexDef.Descr01 := Descr01;
                    SLFlexDef.Descr02 := Descr02;
                    SLFlexDef.Descr03 := Descr03;
                    SLFlexDef.Descr04 := Descr04;
                    SLFlexDef.Descr05 := Descr05;
                    SLFlexDef.Descr06 := Descr06;
                    SLFlexDef.Descr07 := Descr07;
                    Evaluate(SLFlexDef.NumberSegments, NumberSegments);
                    Evaluate(SLFlexDef.SegLength00, SegLength00);
                    Evaluate(SLFlexDef.SegLength01, SegLength01);
                    Evaluate(SLFlexDef.SegLength02, SegLength02);
                    Evaluate(SLFlexDef.SegLength03, SegLength03);
                    Evaluate(SLFlexDef.SegLength04, SegLength04);
                    Evaluate(SLFlexDef.SegLength05, SegLength05);
                    Evaluate(SLFlexDef.SegLength06, SegLength06);
                    Evaluate(SLFlexDef.SegLength07, SegLength07);
                    SLFlexDef.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLFlexDef.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLFlexDef: Record "SL FlexDef";
}