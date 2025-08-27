// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Finance.GeneralLedger.Setup;

xmlport 147603 "SL BC Gen. Bus. Posting Group"
{
    Caption = 'General Business Posting Group data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("Gen. Business Posting Group"; "Gen. Business Posting Group")
            {
                AutoSave = false;
                XmlName = 'GenBusinessPostingGroup';

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
                var
                    GenBusinessPostingGroup: Record "Gen. Business Posting Group";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    GenBusinessPostingGroup.Code := Code;
                    GenBusinessPostingGroup.Description := Description;
                    GenBusinessPostingGroup.Insert(true);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        GenBusinessPostingGroup.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
}
