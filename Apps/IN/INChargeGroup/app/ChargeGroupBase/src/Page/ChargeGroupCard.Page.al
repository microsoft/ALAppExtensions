// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ChargeGroup.ChargeGroupBase;

page 18507 "Charge Group Card"
{
    PageType = Card;
    RefreshOnActivate = true;
    SourceTable = "Charge Group Header";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Code of the involved entry or record, according to the specified.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a name of the charge item that you are setting up.';
                }
                field("Invoice Combination"; Rec."Invoice Combination")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a combination of charge that you are used to create for third party Invoice.';
                }
                field("Post Third Party Inv."; Rec."Post Third Party Inv.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the third party invoice is posted or not along with creation.';
                }
            }
            part(ChargeGroupSubForm; "Charge Group SubPage")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Charge Group Code" = field(Code);
                UpdatePropagation = Both;
            }
        }
    }
}
