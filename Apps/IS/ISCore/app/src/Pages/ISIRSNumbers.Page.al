// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.IRS;
#if not CLEAN24
using Microsoft.Finance;
using Microsoft.Finance.VAT.Setup;
#endif

page 14601 "IS IRS Numbers"
{
    ApplicationArea = Basic, Suite;
    Caption = 'IRS Number';
    PageType = List;
    SourceTable = "IS IRS Numbers";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("IRS Number"; Rec."IRS Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an Internal Revenue Service (IRS) tax number as defined by the Icelandic tax authorities.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a name for the Internal Revenue Service (IRS) tax number.';
                }
                field("Reverse Prefix"; Rec."Reverse Prefix")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the balance of the general ledger accounts with this IRS tax number must reverse the negative operator in IRS reports.';
                }
            }
        }
    }

    actions
    {
    }

#if not CLEAN24
    trigger OnOpenPage()
    var
        ISCoreAppSetup: Record "IS Core App Setup";
    begin
        if not ISCoreAppSetup.IsEnabled() then begin
            Page.Run(Page::"IRS Number");
            Error('');
        end;
    end;
#endif
}

