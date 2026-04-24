// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147639 "SL ItemSite Buffer Data"
{
    Caption = 'SL ItemSite Buffer data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL ItemSite Buffer"; "SL ItemSite Buffer")
            {
                AutoSave = false;
                XmlName = 'SLItemSiteBuffer';

                textelement(InvtID)
                {
                }
                textelement(SiteID)
                {
                }
                textelement(AvgCost)
                {
                }
                textelement(CpnyID)
                {
                }
                textelement(QtyOnHand)
                {
                }
                textelement(StdCost)
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
                    SLItemSite: Record "SL ItemSite Buffer";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLItemSite.InvtID := InvtID;
                    SLItemSite.SiteID := SiteID;
                    Evaluate(SLItemSite.AvgCost, AvgCost);
                    SLItemSite.CpnyID := CopyStr(CpnyID, 1, MaxStrLen(SLItemSite.CpnyID));
                    Evaluate(SLItemSite.QtyOnHand, QtyOnHand);
                    Evaluate(SLItemSite.StdCost, StdCost);
                    SLItemSite.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLItemSite.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLItemSite: Record "SL ItemSite Buffer";
}