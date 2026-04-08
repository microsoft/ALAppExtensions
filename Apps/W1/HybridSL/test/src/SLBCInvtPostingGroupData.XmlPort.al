// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Inventory.Item;

xmlport 147658 "SL BC Invt Posting Group Data"
{
    Caption = 'SL BC Inventory Posting Group data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("BCInventoryPostingGroup"; "Inventory Posting Group")
            {
                AutoSave = false;
                XmlName = 'InventoryPostingGroup';

                textelement(Code)
                {
                }
                textelement(Description)
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
                    InventoryPostingGroup: Record "Inventory Posting Group";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    InventoryPostingGroup.Code := Code;
                    InventoryPostingGroup.Description := Description;
                    InventoryPostingGroup.Insert();
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        InventoryPostingGroup.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        InventoryPostingGroup: Record "Inventory Posting Group";
}