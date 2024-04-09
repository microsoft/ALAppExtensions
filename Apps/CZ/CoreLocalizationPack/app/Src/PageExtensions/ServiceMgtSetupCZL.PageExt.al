// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Service.Setup;

using Microsoft.Finance.VAT.Calculation;

pageextension 11720 "Service Mgt. Setup CZL" extends "Service Mgt. Setup"
{
    ObsoleteState = Pending;
#pragma warning disable AS0072
    ObsoleteTag = '22.0';
#pragma warning restore AS0072
    ObsoleteReason = 'All fields from this pageextension are obsolete.';

    layout
    {
        addlast(content)
        {
            group(VatCZL)
            {
                Caption = 'VAT';
                Visible = not ReplaceVATDateEnabled;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'All fields from this group are obsolete.';

                field("Default VAT Date CZL"; Rec."Default VAT Date CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default VAT date type for service document (posting date, document date, blank).';
                    Visible = not ReplaceVATDateEnabled;
                    ObsoleteState = Pending;
                    ObsoleteTag = '22.0';
                    ObsoleteReason = 'Replaced by VAT Reporting Date in General Ledger Setup.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        ReplaceVATDateEnabled := ReplaceVATDateMgtCZL.IsEnabled();
    end;

    var
#pragma warning disable AL0432
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
#pragma warning restore AL0432
        ReplaceVATDateEnabled: Boolean;
}

#endif
