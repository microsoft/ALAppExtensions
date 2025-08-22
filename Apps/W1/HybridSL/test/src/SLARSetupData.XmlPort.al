// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147601 "SL ARSetup Data"
{
    Caption = 'SL ARSetup data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL ARSetup"; "SL ARSetup")
            {
                AutoSave = false;
                XmlName = 'SLARSetup';

                textelement(SetupID)
                {
                }
                textelement(ARAcct)
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
                    SLARSetup: Record "SL ARSetup";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLARSetup.SetupId := SetupID;
                    SLARSetup.ArAcct := ARAcct;
                    SLARSetup.Insert(true);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLARSetup.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLARSetup: Record "SL ARSetup";
}
