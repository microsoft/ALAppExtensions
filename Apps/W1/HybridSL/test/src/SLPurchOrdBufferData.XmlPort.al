// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147641 "SL PurchOrd Buffer Data"
{
    Caption = 'SL PurchOrd Buffer data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL PurchOrd Buffer"; "SL PurchOrd Buffer")
            {
                AutoSave = false;
                XmlName = 'SLPurchOrdBuffer';

                textelement(PONbr)
                {
                }
                textelement(CpnyID)
                {
                }
                textelement(POAmt)
                {
                }
                textelement(PODate)
                {
                }
                textelement(POType)
                {
                }
                textelement(RcptTotAmt)
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
                textelement(ShipCountry)
                {
                }
                textelement(ShipName)
                {
                }
                textelement(ShipState)
                {
                }
                textelement(ShipVia)
                {
                }
                textelement(ShipZip)
                {
                }
                textelement(Status)
                {
                }
                textelement(VendID)
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
                    SLPurchOrdBuffer: Record "SL PurchOrd Buffer";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLPurchOrdBuffer.PONbr := PONbr;
                    SLPurchOrdBuffer.CpnyID := CopyStr(CpnyID, 1, MaxStrLen(SLPurchOrdBuffer.CpnyID));
                    Evaluate(SLPurchOrdBuffer.POAmt, POAmt);
                    Evaluate(SLPurchOrdBuffer.PODate, PODate);
                    SLPurchOrdBuffer.POType := POType;
                    Evaluate(SLPurchOrdBuffer.RcptTotAmt, RcptTotAmt);
                    SLPurchOrdBuffer.ShipAddr1 := ShipAddr1;
                    SLPurchOrdBuffer.ShipAddr2 := ShipAddr2;
                    SLPurchOrdBuffer.ShipAttn := ShipAttn;
                    SLPurchOrdBuffer.ShipCity := ShipCity;
                    SLPurchOrdBuffer.ShipCountry := ShipCountry;
                    SLPurchOrdBuffer.ShipName := ShipName;
                    SLPurchOrdBuffer.ShipState := ShipState;
                    SLPurchOrdBuffer.ShipVia := ShipVia;
                    SLPurchOrdBuffer.ShipZip := ShipZip;
                    SLPurchOrdBuffer.Status := Status;
                    SLPurchOrdBuffer.VendID := VendID;
                    SLPurchOrdBuffer.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLPurchOrdBuffer.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLPurchOrdBuffer: Record "SL PurchOrd Buffer";
}