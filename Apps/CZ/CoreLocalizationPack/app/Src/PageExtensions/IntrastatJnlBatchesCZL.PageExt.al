// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Inventory.Intrastat;

#pragma warning disable AL0432
pageextension 31138 "Intrastat Jnl. Batches CZL" extends "Intrastat Jnl. Batches"
#pragma warning restore AL0432
{
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

    layout
    {
        addafter(Reported)
        {
            field("Declaration No. CZL"; Rec."Declaration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Intrastat declaration number for the Intrastat journal batch.';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

                trigger OnAssistEdit()
                begin
#pragma warning disable AL0432
                    if Rec.AssistEditCZL() then
#pragma warning restore AL0432
                        CurrPage.Update();
                end;
            }
            field("Statement Type CZL"; Rec."Statement Type CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a Intrastat Declaration type for the Intrastat journal batch.';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
            }
        }
    }
}
#endif
