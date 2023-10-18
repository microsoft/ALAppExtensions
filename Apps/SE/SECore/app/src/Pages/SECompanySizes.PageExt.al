// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Analysis;

pageextension 11295 "SE Company Sizes" extends "Company Sizes"
{
    actions
    {
        addlast(Creation)
        {
            action(Import)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Import Company Sizes file.';
                Image = Import;
                ToolTip = 'Import Company Size Codes from the standard CSV file.';

                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"Import Company Size Codes");
                end;
            }
        }
        addlast(Promoted)
        {
            actionref(Import_promoted; Import) { }
        }
    }
}
