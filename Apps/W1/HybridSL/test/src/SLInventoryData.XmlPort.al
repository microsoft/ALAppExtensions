// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147619 "SL Inventory Data"
{
    Caption = 'SL Inventory data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL Inventory"; "SL Inventory")
            {
                AutoSave = false;
                XmlName = 'SLInventory';

                textelement(InvtID)
                {
                }
                textelement(ClassID)
                {
                }
                textelement(Descr)
                {
                }
                textelement(DfltPOUnit)
                {
                }
                textelement(LastCost)
                {
                }
                textelement(LotSerIssMthd)
                {
                }
                textelement(LotSerTrack)
                {
                }
                textelement(SerAssign)
                {
                }
                textelement(StdCost)
                {
                }
                textelement(StkBasePrc)
                {
                }
                textelement(StkItem)
                {
                }
                textelement(StkUnit)
                {
                }
                textelement(TranStatusCode)
                {
                }
                textelement(ValMthd)
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
                    SLInventory: Record "SL Inventory";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLInventory.InvtID := InvtID;
                    SLInventory.ClassID := ClassID;
                    SLInventory.Descr := Descr;
                    SLInventory.DfltPOUnit := DfltPOUnit;
                    Evaluate(SLInventory.LastCost, LastCost, 9);
                    SLInventory.LotSerIssMthd := LotSerIssMthd;
                    SLInventory.LotSerTrack := LotSerTrack;
                    SLInventory.SerAssign := SerAssign;
                    Evaluate(SLInventory.StdCost, StdCost, 9);
                    Evaluate(SLInventory.StkBasePrc, StkBasePrc, 9);
                    Evaluate(SLInventory.StkItem, StkItem, 9);
                    SLInventory.StkUnit := StkUnit;
                    SLInventory.TranStatusCode := TranStatusCode;
                    SLInventory.ValMthd := ValMthd;
                    SLInventory.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        SLInventory.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLInventory: Record "SL Inventory";
}