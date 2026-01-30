// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147650 "SL APSetup Data"
{
    Caption = 'SL APSetup data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL APSetup"; "SL APSetup")
            {
                AutoSave = false;
                XmlName = 'SLAPSetup';

                textelement(SetupID)
                {
                }
                textelement(APAcct)
                {
                }
                textelement(Curr1099Yr)
                {
                }
                textelement(CY1099Stat)
                {
                }
                textelement(Next1099Yr)
                {
                }
                textelement(NY1099Stat)
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
                    SLAPSetup: Record "SL APSetup";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLAPSetup.SetupId := SetupID;
                    SLAPSetup.APAcct := APAcct;
                    SLAPSetup.Curr1099Yr := Curr1099Yr;
                    SLAPSetup.CY1099Stat := CY1099Stat;
                    SLAPSetup.Next1099Yr := Next1099Yr;
                    SLAPSetup.NY1099Stat := NY1099Stat;
                    SLAPSetup.Insert(true);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLAPSetup.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLAPSetup: Record "SL APSetup";
}
