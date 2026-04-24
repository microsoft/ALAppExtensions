// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Inventory.Item;

xmlport 147670 "SL BC Item for Open Order Data"
{
    Caption = 'SL BC Item for Open Order data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("BCItem"; Item)
            {
                AutoSave = false;
                XmlName = 'Item';

                textelement("No.")
                {
                }
                textelement("Description")
                {
                }
                textelement("SearchDescription")
                {
                }
                textelement("BaseUnitOfMeasure")
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
                textelement("SalesUnitOfMeasure")
                {
                }
                textelement("PurchUnitOfMeasure")
                {
                }
                textelement("ItemTrackingCode")
                {
                }
                textelement("ExpirationCalculation")
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
                    Item: Record Item;
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    Item."No." := "No.";
                    Item.Description := "Description";
                    Item."Search Description" := "SearchDescription";
                    Item."Base Unit of Measure" := "BaseUnitOfMeasure";
                    if Type <> '' then
                        Evaluate(Item.Type, "Type");
                    Item."Inventory Posting Group" := "InventoryPostingGroup";
                    if UnitPrice <> '' then
                        Evaluate(Item."Unit Price", "UnitPrice");
                    if CostingMethod <> '' then
                        Evaluate(Item."Costing Method", "CostingMethod");
                    if UnitCost <> '' then
                        Evaluate(Item."Unit Cost", "UnitCost");
                    if StandardCost <> '' then
                        Evaluate(Item."Standard Cost", "StandardCost");
                    if NetWeight <> '' then
                        Evaluate(Item."Net Weight", "NetWeight");
                    if Blocked <> '' then
                        Evaluate(Item.Blocked, "Blocked");
                    Item."Block Reason" := "BlockReason";
                    Item."Gen. Prod. Posting Group" := "GenProdPostingGroup";
                    Item."Sales Unit of Measure" := "SalesUnitOfMeasure";
                    Item."Purch. Unit of Measure" := "PurchUnitOfMeasure";
                    Item."Item Tracking Code" := "ItemTrackingCode";
                    if ItemTrackingCode <> '' then
                        Evaluate(Item."Expiration Calculation", "ExpirationCalculation");
                    Item.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        Item.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        Item: Record Item;
}
