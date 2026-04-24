// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147654 "SL SOLine Buffer Data"
{
    Caption = 'SL SOLine Buffer data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL SOLine Buffer"; "SL SOLine Buffer")
            {
                AutoSave = false;
                XmlName = 'SLSOLineBuffer';

                textelement(CpnyID)
                {
                }
                textelement(OrdNbr)
                {
                }
                textelement(LineRef)
                {
                }
                textelement(InvtID)
                {
                }
                textelement(QtyBO)
                {
                }
                textelement(SiteID)
                {
                }
                textelement(SlsPrice)
                {
                }
                textelement(UnitDesc)
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
                    SLSOLineBuffer: Record "SL SOLine Buffer";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLSOLineBuffer.CpnyID := CopyStr(CpnyID, 1, MaxStrLen(SLSOLineBuffer.CpnyID));
                    SLSOLineBuffer.OrdNbr := OrdNbr;
                    SLSOLineBuffer.LineRef := LineRef;
                    SLSOLineBuffer.InvtID := InvtID;
                    Evaluate(SLSOLineBuffer.QtyBO, QtyBO);
                    SLSOLineBuffer.SiteID := SiteID;
                    Evaluate(SLSOLineBuffer.SlsPrice, SlsPrice);
                    SLSOLineBuffer.UnitDesc := UnitDesc;
                    SLSOLineBuffer.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLSOLineBuffer.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLSOLineBuffer: Record "SL SOLine Buffer";
}