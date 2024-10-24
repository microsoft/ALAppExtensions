// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

page 42008 "SL Upgrade Settings"
{
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "SL Upgrade Settings";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(ErrorHandling)
            {
                Caption = 'Error Handling';
                field(CollectAllErrors; Rec."Collect All Errors")
                {
                    ApplicationArea = All;
                    Caption = 'Attempt to upgrade all companies';
                    ToolTip = 'Specifies whether to stop upgrade on first company failure or to attempt to upgrade all companies.';
                }
                field(LogAllRecordChanges; Rec."Log All Record Changes")
                {
                    ApplicationArea = All;
                    Caption = 'Log all record changes';
                    ToolTip = 'Specifies whether to log all record changes during upgrade. This method will make the data upgrade slower.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetonInsertSLUpgradeSettings(Rec);
    end;
}