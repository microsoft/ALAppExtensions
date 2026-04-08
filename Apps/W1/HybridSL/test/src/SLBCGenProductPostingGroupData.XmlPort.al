// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Finance.GeneralLedger.Setup;

xmlport 147660 "SL Gen Prod Posting Group Data"
{
    Caption = 'SL BC General Product Posting Group data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("BCGenProductPostingGroup"; "Gen. Product Posting Group")
            {
                AutoSave = false;
                XmlName = 'GenProductPostingGroup';

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
                    GenProductPostingGroup: Record "Gen. Product Posting Group";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    GenProductPostingGroup.Code := Code;
                    GenProductPostingGroup.Description := Description;
                    GenProductPostingGroup.Insert(true);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        GenProductPostingGroup.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        GenProductPostingGroup: Record "Gen. Product Posting Group";
}