// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Used for 'recording' delete operations.
/// </summary>
page 633 "Data Archive - New Archive"
{
    Caption = 'New Data Archive';
    PageType = Card;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(ArchiveName; ArchiveName)
                {
                    Caption = 'Name of new archive';
                    ToolTip = 'Enter a name or description in this field.';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Start)
            {
                ApplicationArea = All;
                Enabled = not IsStarted;
                Caption = 'Start Logging';
                Image = Start;
                Promoted = true;
                ToolTip = 'Start logging deletions. All deletions will be added to the new archive.';
                trigger OnAction()
                begin
                    if ArchiveName = '' then
                        ArchiveName := 'Test';
                    DataArchive.Create(ArchiveName);
                    DataArchive.StartSubscriptionToDelete(false);
                    IsStarted := true;
                end;
            }
            action(Stop)
            {
                ApplicationArea = All;
                Enabled = IsStarted;
                Caption = 'Stop Logging';
                Image = Stop;
                Promoted = true;
                ToolTip = 'Stop logging deletions and add the data to the new archive.';
                trigger OnAction()
                begin
                    IsStarted := false;
                    DataArchive.StopSubscriptionToDelete();
                    DataArchive.Save();
                end;
            }

        }
    }

    trigger OnClosePage()
    begin
        if not IsStarted then
            exit;
        IsStarted := false;
        DataArchive.StopSubscriptionToDelete();
        DataArchive.Save();
    end;

    var
        DataArchive: Codeunit "Data Archive";
        ArchiveName: Text[80];
        IsStarted: Boolean;
}