// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147609 "SL GLSetup Data"
{
    Caption = 'SL GLSetup data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL GLSetup"; "SL GLSetup")
            {
                AutoSave = false;
                XmlName = 'GLSetup';

                textelement(SetupId)
                {
                }
                textelement(BegFiscalYr)
                {
                }
                textelement(CpnyId)
                {
                }
                textelement(CpnyName)
                {
                }
                textelement(FiscalPerEnd00)
                {
                }
                textelement(FiscalPerEnd01)
                {
                }
                textelement(FiscalPerEnd02)
                {
                }
                textelement(FiscalPerEnd03)
                {
                }
                textelement(FiscalPerEnd04)
                {
                }
                textelement(FiscalPerEnd05)
                {
                }
                textelement(FiscalPerEnd06)
                {
                }
                textelement(FiscalPerEnd07)
                {
                }
                textelement(FiscalPerEnd08)
                {
                }
                textelement(FiscalPerEnd09)
                {
                }
                textelement(FiscalPerEnd10)
                {
                }
                textelement(FiscalPerEnd11)
                {
                }
                textelement(FiscalPerEnd12)
                {
                }
                textelement(NbrPer)
                {
                }
                textelement(PerNbr)
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
                    SLGLSetup: Record "SL GLSetup";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLGLSetup.SetupId := SetupId;
                    Evaluate(SLGLSetup.BegFiscalYr, BegFiscalYr);
                    SLGLSetup.CpnyId := CpnyId;
                    SLGLSetup.CpnyName := CpnyName;
                    SLGLSetup.FiscalPerEnd00 := FiscalPerEnd00;
                    SLGLSetup.FiscalPerEnd01 := FiscalPerEnd01;
                    SLGLSetup.FiscalPerEnd02 := FiscalPerEnd02;
                    SLGLSetup.FiscalPerEnd03 := FiscalPerEnd03;
                    SLGLSetup.FiscalPerEnd04 := FiscalPerEnd04;
                    SLGLSetup.FiscalPerEnd05 := FiscalPerEnd05;
                    SLGLSetup.FiscalPerEnd06 := FiscalPerEnd06;
                    SLGLSetup.FiscalPerEnd07 := FiscalPerEnd07;
                    SLGLSetup.FiscalPerEnd08 := FiscalPerEnd08;
                    SLGLSetup.FiscalPerEnd09 := FiscalPerEnd09;
                    SLGLSetup.FiscalPerEnd10 := FiscalPerEnd10;
                    SLGLSetup.FiscalPerEnd11 := FiscalPerEnd11;
                    SLGLSetup.FiscalPerEnd12 := FiscalPerEnd12;
                    Evaluate(SLGLSetup.NbrPer, NbrPer);
                    Evaluate(SLGLSetup.PerNbr, PerNbr);
                    SLGLSetup.Insert(true);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLGLSetup.DeleteAll();
        CaptionRow := true;
    end;

    var
        SLGLSetup: Record "SL GLSetup";
        CaptionRow: Boolean;
}