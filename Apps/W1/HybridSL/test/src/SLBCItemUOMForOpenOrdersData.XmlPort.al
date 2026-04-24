// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Inventory.Item;

xmlport 147649 "SL BC Item UOM Open Orders"
{
    Caption = 'SL BC Item UOM for Open Orders data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("BCItemUnitofMeasure"; "Item Unit of Measure")
            {
                AutoSave = false;
                XmlName = 'ItemUnitOfMeasure';

                textelement(ItemNo)
                {
                }
                textelement(Code)
                {
                }
                textelement(QtyPerUnitOfMeasure)
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
                    ItemUnitOfMeasure: Record "Item Unit of Measure";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    ItemUnitOfMeasure."Item No." := ItemNo;
                    ItemUnitOfMeasure.Code := Code;
                    Evaluate(ItemUnitOfMeasure."Qty. per Unit of Measure", QtyPerUnitOfMeasure);
                    ItemUnitOfMeasure.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        ItemUnitOfMeasure.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
}