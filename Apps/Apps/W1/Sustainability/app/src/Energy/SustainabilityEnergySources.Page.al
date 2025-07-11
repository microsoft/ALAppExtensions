// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Energy;

page 6259 "Sustainability Energy Sources"
{
    PageType = List;
    Caption = 'Sustainability Energy Sources';
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Sustainability Energy Source";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Description field.';
                }
            }
        }
    }
}