// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147653 "SL SOHeader Buffer Data"
{
    Caption = 'SL SOHeader Buffer data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL SOHeader Buffer"; "SL SOHeader Buffer")
            {
                AutoSave = false;
                XmlName = 'SLSOHeaderBuffer';

                textelement(CpnyID)
                {
                }
                textelement(OrdNbr)
                {
                }
                textelement(CustID)
                {
                }
                textelement(OrdDate)
                {
                }
                textelement(ShipAddr1)
                {
                }
                textelement(ShipAddr2)
                {
                }
                textelement(ShipAttn)
                {
                }
                textelement(ShipCity)
                {
                }
                textelement(ShipCmplt)
                {
                }
                textelement(ShipCountry)
                {
                }
                textelement(ShipName)
                {
                }
                textelement(ShipState)
                {
                }
                textelement(ShipViaID)
                {
                }
                textelement(ShipZip)
                {
                }
                textelement(SOTypeID)
                {
                }
                textelement(Status)
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
                    SLSOHeaderBuffer: Record "SL SOHeader Buffer";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLSOHeaderBuffer.CpnyID := CopyStr(CpnyID, 1, MaxStrLen(SLSOHeaderBuffer.CpnyID));
                    SLSOHeaderBuffer.OrdNbr := OrdNbr;
                    SLSOHeaderBuffer.CustID := CustID;
                    Evaluate(SLSOHeaderBuffer.OrdDate, OrdDate);
                    SLSOHeaderBuffer.ShipAddr1 := ShipAddr1;
                    SLSOHeaderBuffer.ShipAddr2 := ShipAddr2;
                    SLSOHeaderBuffer.ShipAttn := ShipAttn;
                    SLSOHeaderBuffer.ShipCity := ShipCity;
                    Evaluate(SLSOHeaderBuffer.ShipCmplt, ShipCmplt);
                    SLSOHeaderBuffer.ShipCountry := ShipCountry;
                    SLSOHeaderBuffer.ShipName := ShipName;
                    SLSOHeaderBuffer.ShipState := ShipState;
                    SLSOHeaderBuffer.ShipViaID := ShipViaID;
                    SLSOHeaderBuffer.ShipZip := ShipZip;
                    SLSOHeaderBuffer.SOTypeID := SOTypeID;
                    SLSOHeaderBuffer.Status := Status;
                    SLSOHeaderBuffer.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLSOHeaderBuffer.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLSOHeaderBuffer: Record "SL SOHeader Buffer";
}