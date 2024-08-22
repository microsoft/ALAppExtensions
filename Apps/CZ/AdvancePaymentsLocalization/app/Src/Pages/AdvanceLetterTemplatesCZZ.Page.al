// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

page 31179 "Advance Letter Templates CZZ"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Advance Letter Templates';
    PageType = List;
    SourceTable = "Advance Letter Template CZZ";
    UsageCategory = Administration;
    PopulateAllFields = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies code.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies description.';
                }
                field("Sales/Purchase"; Rec."Sales/Purchase")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies sales/purchase.';
                }
                field("Advance Letter Document Nos."; Rec."Advance Letter Document Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies advance letter document nos.';
                }
                field("Advance Letter Invoice Nos."; Rec."Advance Letter Invoice Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies advance letter invoice nos.';
                }
                field("Advance Letter Cr. Memo Nos."; Rec."Advance Letter Cr. Memo Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies advance letter credit memo nos.';
                }
                field("Advance Letter G/L Account"; Rec."Advance Letter G/L Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies advance letter general ledger account.';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies default VAT bus. posting group.';
                }
                field("Automatic Post VAT Document"; Rec."Automatic Post VAT Document")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies automatic post VAT document.';
                }
                field("Automatic Post Non-Ded.VAT CZZ"; Rec."Automatic Post Non-Ded. VAT")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Post VAT Doc. for Rev. Charge"; Rec."Post VAT Doc. for Rev. Charge")
                {
                    ApplicationArea = Basic, Suite;
                }
#if not CLEAN23
#pragma warning disable AL0432,AS0074
                field("Document Report ID"; '')
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies document report ID.';
                    Visible = false;
                    Enabled = false;
                    ObsoleteReason = 'Replaced by standard report selection.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '23.0';
                }
                field("Document Report Caption"; '')
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies document report caption.';
                    Visible = false;
                    Enabled = false;
                    ObsoleteReason = 'Replaced by standard report selection.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '23.0';
                }
                field("Invoice/Cr. Memo Report ID"; '')
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies invoice/credit memo report ID';
                    Visible = false;
                    Enabled = false;
                    ObsoleteReason = 'Replaced by standard report selection.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '23.0';
                }
                field("Invoice/Cr. Memo Rep. Caption"; '')
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies invoice/credit memo report caption.';
                    Visible = false;
                    Enabled = false;
                    ObsoleteReason = 'Replaced by standard report selection.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '23.0';
                }
#pragma warning restore AL0432,AS0074
#endif
            }
        }
    }
}
