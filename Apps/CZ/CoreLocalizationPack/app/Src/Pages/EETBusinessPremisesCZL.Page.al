// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

page 31143 "EET Business Premises CZL"
{
    Caption = 'EET Business Premises';
    PageType = List;
    SourceTable = "EET Business Premises CZL";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the premises.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the premises.';
                }
                field(Identification; Rec.Identification)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the identification number of the promises.';
                }
                field("Certificate Code"; Rec."Certificate Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the certificate needed to register sales.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Cash Registers")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cash Registers';
                Image = ElectronicPayment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "EET Cash Registers CZL";
                RunPageLink = "Business Premises Code" = field(Code);
                ToolTip = 'Displays a list of POS devices assigned to the promises.';
            }
        }
    }
}
