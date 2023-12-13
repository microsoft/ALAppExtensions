// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.VAT.Setup;

pageextension 31026 "VAT Posting Setup Card CZZ" extends "VAT Posting Setup Card"
{
    layout
    {
        addbefore(VATCtrlReportCZL)
        {
            group(AdvancePaymentsCZZ)
            {
                Caption = 'Advance Payments';
                field("Sales Adv. Letter Account CZZ"; Rec."Sales Adv. Letter Account CZZ")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies sales advance letter account.';
                }
                field("Sales Adv. Letter VAT Acc. CZZ"; Rec."Sales Adv. Letter VAT Acc. CZZ")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies sales advance letter VAT account.';
                }
                field("Purch. Adv. Letter Account CZZ"; Rec."Purch. Adv. Letter Account CZZ")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies purchase advance letter account.';
                }
                field("Purch. Adv.Letter VAT Acc. CZZ"; Rec."Purch. Adv.Letter VAT Acc. CZZ")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies purchase advance letter VAT account.';
                }
            }
        }
    }
}
