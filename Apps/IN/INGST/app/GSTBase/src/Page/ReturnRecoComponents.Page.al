// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

page 18007 "Return & Reco Components"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Retrun & Reco. Components";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Component ID"; Rec."Component ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies Component ID defined in Tax Engine';
                }
                field("Component Name"; Rec."Component Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies Component name for GST reconcilaiotn and Return';
                }
            }
        }
    }
}
