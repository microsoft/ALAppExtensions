// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Inventory.Item;
xmlport 147620 "SL BC Item Data"
{
    Caption = 'BC Item data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("Item"; Item)
            {
                AutoSave = false;
                XmlName = 'Item';
                UseTemporary = true;

                textelement("No.")
                {
                }
                textelement("Description")
                {
                }
                textelement("SearchDescription")
                {
                }
                textelement("BaseUnitofMeasure")
                {
                }
                textelement("Type")
                {
                }
                textelement("InventoryPostingGroup")
                {
                }
                textelement("UnitPrice")
                {
                }
                textelement("CostingMethod")
                {
                }
                textelement("UnitCost")
                {
                }
                textelement("StandardCost")
                {
                }
                textelement("NetWeight")
                {
                }
                textelement("Blocked")
                {
                }
                textelement("BlockReason")
                {
                }
                textelement("GenProdPostingGroup")
                {
                }
                textelement("SalesUnitofMeasure")
                {
                }
                textelement("PurchUnitofMeasure")
                {
                }
                textelement("ItemTrackingCode")
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
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    TempItem."No." := "No.";
                    TempItem.Description := "Description";
                    TempItem."Search Description" := "SearchDescription";
                    TempItem."Base Unit of Measure" := "BaseUnitofMeasure";
                    Evaluate(TempItem.Type, "Type");
                    TempItem."Inventory Posting Group" := "InventoryPostingGroup";
                    Evaluate(TempItem."Unit Price", "UnitPrice");
                    Evaluate(TempItem."Costing Method", "CostingMethod");
                    Evaluate(TempItem."Unit Cost", "UnitCost");
                    Evaluate(TempItem."Standard Cost", "StandardCost");
                    Evaluate(TempItem."Net Weight", "NetWeight");
                    Evaluate(TempItem.Blocked, "Blocked");
                    TempItem."Block Reason" := "BlockReason";
                    TempItem."Gen. Prod. Posting Group" := "GenProdPostingGroup";
                    Evaluate(TempItem."Sales Unit of Measure", "SalesUnitofMeasure");
                    TempItem."Purch. Unit of Measure" := "PurchUnitofMeasure";
                    TempItem."Item Tracking Code" := "ItemTrackingCode";
                    TempItem.Insert(false);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        CaptionRow := true;
    end;

    procedure GetExpectedItems(var NewTempItem: Record Item temporary)
    begin
        if TempItem.FindSet() then begin
            repeat
                NewTempItem.Copy(TempItem);
                NewTempItem.Insert();
            until TempItem.Next() = 0;
        end;
    end;

    var
        CaptionRow: Boolean;
        TempItem: Record Item temporary;
}