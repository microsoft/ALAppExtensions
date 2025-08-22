// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147613 "SL APSetup Data"
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
