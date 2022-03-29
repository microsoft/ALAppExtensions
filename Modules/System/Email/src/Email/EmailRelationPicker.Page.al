// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 8910 "Email Relation Picker"
{
    PageType = List;
    SourceTable = "Email Related Record";
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    ShowFilter = false;
    LinksAllowed = false;
    Caption = 'Related Records';
    Permissions = tabledata "Email Related Record" = r;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Source Name"; RecordName(Rec."Table Id", Rec."System Id"))
                {
                    ApplicationArea = All;
                    Caption = 'Source Record';
                    ToolTip = 'Specifies the type of source record and its identifier. Choose the record to view more information.';
                }
                field("Relation Type"; "Relation Type")
                {
                    ApplicationArea = All;
                    Caption = 'Type of relation';
                    ToolTip = 'Specifies the type of source relation.';
                }
            }
        }
    }

    local procedure RecordName(TableID: Integer; SystemID: Guid): Text
    var
        SourceRecordRef: RecordRef;
    begin
        SourceRecordRef.Open(TableID);
        SourceRecordRef.GetBySystemId(SystemID);
        exit(Format(SourceRecordRef.RecordId(), 0, 1));
    end;
}