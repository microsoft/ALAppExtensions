// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ChargeGroup.ChargeGroupBase;

page 18508 "Charge Group List"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Charge Group Header";
    Caption = 'Charge Groups';
    CardPageId = "Charge Group Card";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Code of the involved entry or record, according to the specified.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the charge Name that you are setting up.';
                }
                field("Invoice Combination"; Rec."Invoice Combination")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a combination of the charge that you are used to create for third party Invoice.';
                }
            }
        }
    }
}
