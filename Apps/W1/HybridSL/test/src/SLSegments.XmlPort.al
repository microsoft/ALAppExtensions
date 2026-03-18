// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147625 "SL Segments"
{
    Caption = 'SL Segments data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL Segments"; "SL Segments")
            {
                AutoSave = false;
                XmlName = 'SLSegment';

                textelement(Id)
                {
                }
                textelement(Name)
                {
                }
                textelement("CodeCaption")
                {
                }
                textelement("FilterCaption")
                {
                }
                textelement("SegmentNumber")
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
                    SLSegments: Record "SL Segments";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLSegments.Id := Id;
                    SLSegments.Name := Name;
                    SLSegments.CodeCaption := CodeCaption;
                    SLSegments.FilterCaption := FilterCaption;
                    Evaluate(SLSegments.SegmentNumber, SegmentNumber);
                    SLSegments.Insert(false);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLSegments.DeleteAll();
        CaptionRow := true;
    end;

    // procedure GetExpectedSLSegments(var NewTempSLSegment: Record "SL Segment" temporary)
    // begin
    //     if TempSLSegment.FindSet() then begin
    //         repeat
    //             NewTempSLSegment.Copy(TempSLSegment);
    //             NewTempSLSegment.Insert();
    //         until TempSLSegment.Next() = 0;
    //     end;
    // end;

    var
        CaptionRow: Boolean;
        SLSegments: Record "SL Segments";
}