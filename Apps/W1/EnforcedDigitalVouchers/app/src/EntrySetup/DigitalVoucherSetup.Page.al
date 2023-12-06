// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

page 5587 "Digital Voucher Setup"
{
    PageType = Card;
    SourceTable = "Digital Voucher Setup";
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    DeleteAllowed = false;
    InsertAllowed = false;
    DataCaptionExpression = '';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Specifies if the feature is enabled.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(EntrySetup)
            {
                Caption = 'Entry Setup';
                Image = SetupList;
                Scope = Repeater;
                ToolTip = 'Specifies the digital voucher feature for each entry type.';
                RunObject = Page "Digital Voucher Entry Setup";
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(EntrySetup_Promoted; EntrySetup)
                {

                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert();
    end;

}
