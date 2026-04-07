// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147657 "SL SOType Buffer Data"
{
    Caption = 'SL SOType Buffer data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL SOType Buffer"; "SL SOType Buffer")
            {
                AutoSave = false;
                XmlName = 'SLSOTypeBuffer';

                textelement(CpnyID)
                {
                }
                textelement(SOTypeID)
                {
                }
                textelement(Behavior)
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
                    SLSOTypeBuffer: Record "SL SOType Buffer";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLSOTypeBuffer.CpnyID := CopyStr(CpnyID, 1, MaxStrLen(SLSOTypeBuffer.CpnyID));
                    SLSOTypeBuffer.SOTypeID := SOTypeID;
                    SLSOTypeBuffer.Behavior := Behavior;
                    SLSOTypeBuffer.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLSOTypeBuffer.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLSOTypeBuffer: Record "SL SOType Buffer";
}