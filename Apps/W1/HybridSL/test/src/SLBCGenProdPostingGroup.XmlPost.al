// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Finance.GeneralLedger.Setup;
xmlport 147623 "SL BC Gen. Prod. Posting Group"
{
    Caption = 'General Product Posting Group data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("Gen. Product Posting Group"; "Gen. Product Posting Group")
            {
                AutoSave = false;
                XmlName = 'GeneralProductPostingGroup';
                UseTemporary = true;

                textelement("Code")
                {
                }
                textelement("Description")
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

                    TempGeneralProductPostingGroup.Code := Code;
                    TempGeneralProductPostingGroup.Description := Description;
                    TempGeneralProductPostingGroup.Insert(false);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        CaptionRow := true;
    end;

    procedure GetExpectedGeneralProductPostingGroups(var NewTempGeneralProductPostingGroup: Record "Gen. Product Posting Group" temporary)
    begin
        if TempGeneralProductPostingGroup.FindSet() then begin
            repeat
                NewTempGeneralProductPostingGroup.Copy(TempGeneralProductPostingGroup);
                NewTempGeneralProductPostingGroup.Insert();
            until TempGeneralProductPostingGroup.Next() = 0;
        end;
    end;

    var
        CaptionRow: Boolean;
        TempGeneralProductPostingGroup: Record "Gen. Product Posting Group" temporary;
}