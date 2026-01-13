// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147618 "SL INSetup Data"
{
    Caption = 'SL INSetup data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL INSetup"; "SL INSetup")
            {
                AutoSave = false;
                XmlName = 'SLINSetup';

                textelement(SetupID)
                {
                }
                textelement(DfltInvtAcct)
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
                    SLINSetup: Record "SL INSetup";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLINSetup.SetupId := SetupID;
                    SLINSetup.DfltInvtAcct := DfltInvtAcct;
                    SLINSetup.Insert(true);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLINSetup.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLINSetup: Record "SL INSetup";
}
