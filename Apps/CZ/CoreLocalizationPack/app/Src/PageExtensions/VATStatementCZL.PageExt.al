// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;
#if not CLEAN24

using Microsoft.Finance.EU3PartyTrade;
#endif

pageextension 11701 "VAT Statement CZL" extends "VAT Statement"
{
    layout
    {
        modify("Box No.")
        {
            Visible = false;
        }
        modify("Account Totaling")
        {
            Visible = false;
        }
        addafter("Amount Type")
        {
            field("G/L Amount Type CZL"; Rec."G/L Amount Type CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies the general ledger amount type for the VAT statement line.';
            }
            field("Gen. Bus. Posting Group CZL"; Rec."Gen. Bus. Posting Group CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies the code for the Gen. Bus. Posting Group that applies to the entry.';
                Visible = false;
            }
            field("Gen. Prod. Posting Group CZL"; Rec."Gen. Prod. Posting Group CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies the code for the Gen. Prod. Posting Group that applies to the entry.';
                Visible = false;
            }
#if not CLEAN24
            field("EU-3 Party Trade CZL"; Rec."EU-3 Party Trade CZL")
            {
                ApplicationArea = VAT;
                Caption = 'EU 3-Party Trade (Obsolete)';
                ToolTip = 'Specifies whether the document is part of a three-party trade.';
                Visible = false;
                Enabled = not EU3PartyTradeFeatureEnabled;
                ObsoleteState = Pending;
                ObsoleteTag = '24.0';
                ObsoleteReason = 'Replaced by "EU 3 Party Trade" field in "EU 3-Party Trade Purchase" app.';
            }
#endif
            field("EU 3-Party Intermed. Role CZL"; Rec."EU 3-Party Intermed. Role CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies when the VAT entry will use European Union third-party intermediate trade rules. This option complies with VAT accounting standards for EU third-party trade.';
                Visible = false;
            }
        }
        movebefore("EU 3-Party Intermed. Role CZL"; "EU 3 Party Trade")
        addafter("Calculate with")
        {
            field("Show CZL"; Rec."Show CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies whether amount on the VAT statement line remains as calculated or is reset to zero according to the selected option and the sign of the calculated amount.';
            }
        }
        modify("Print with")
        {
            Visible = false;
        }
        modify("New Page")
        {
            Visible = false;
        }
        addlast(Control1)
        {
            field("Attribute Code CZL"; Rec."Attribute Code CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies xml code for export.';
            }
            field("VAT Ctrl. Report Section CZL"; Rec."VAT Ctrl. Report Section CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies the section code for the VAT Control Report.';
            }
            field("Ignore Simpl. Doc. Limit CZL"; Rec."Ignore Simpl. Doc. Limit CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies whether the system will or will not check the Simplified Tax document limit for VAT statement depending on whether the field is checked.';
            }
        }
    }
    actions
    {
#pragma warning disable AL0432        
        modify("P&review")
        {
            Visible = false;
        }
        modify("Calc. and Post VAT Settlement")
        {
            Visible = false;
        }
#pragma warning restore AL0432        
        addfirst("VAT &Statement")
        {
            action("P&review CZL")
            {
                ApplicationArea = VAT;
                Caption = 'P&review';
                Image = View;
                RunObject = page "VAT Statement Preview CZL";
                RunPageLink = "Statement Template Name" = field("Statement Template Name"), Name = field("Statement Name");
                ToolTip = 'Preview the VAT statement report.';
            }
        }
        addfirst("F&unctions")
        {
            action(ExportCZL)
            {
                ApplicationArea = VAT;
                Caption = 'Export';
                Ellipsis = true;
                Image = Export;
                ToolTip = 'Export VAT statement data to XML format. The structure of the output XML file is determined by the VAT statement template field XML format.';

                trigger OnAction()
                var
                    VATStatementName: Record "VAT Statement Name";
                begin
                    VATStatementName.Get(Rec."Statement Template Name", Rec."Statement Name");
                    VATStatementName.ExportToFileCZL();
                end;
            }
        }
        addlast(Reporting)
        {
            action(DocumentationForVATCZL)
            {
                ApplicationArea = VAT;
                Caption = 'Documentation for VAT';
                Ellipsis = true;
                Image = PrintInstallment;
                RunObject = report "Documentation for VAT CZL";
                ToolTip = 'Print documentation of VAT entries.';
            }
            action(VATDocumentListCZL)
            {
                ApplicationArea = VAT;
                Caption = 'VAT Documents List';
                Ellipsis = true;
                Image = PrintVAT;
                RunObject = report "VAT Documents List CZL";
                ToolTip = 'Print sales and purchase documents list.';
            }
            action(GLVATReconciliationCZL)
            {
                ApplicationArea = VAT;
                Caption = 'G/L VAT Reconciliation';
                Ellipsis = true;
                Image = PrintForm;
                RunObject = report "G/L VAT Reconciliation CZL";
                ToolTip = 'Print reconciliation G/L entries and VAT entries.';
            }
        }
        addlast(navigation)
        {
            action(VATReturnsCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'VAT Returns';
                RunObject = page "VAT Report List";
                Image = VATLedger;
                Tooltip = 'Open the VAT Returns page.';
            }
        }
        addfirst(Category_Process)
        {
            actionref(ExportCZL_Promoted; ExportCZL)
            {
            }
        }
        addlast(Category_Process)
        {
            actionref("P&review CZL_Promoted"; "P&review CZL")
            {
            }
        }
    }
#if not CLEAN24

    trigger OnOpenPage()
    begin
        EU3PartyTradeFeatureEnabled := EU3PartyTradeFeatMgt.IsEnabled();
    end;

    var
#pragma warning disable AL0432
        EU3PartyTradeFeatMgt: Codeunit "EU3 Party Trade Feat Mgt. CZL";
#pragma warning restore AL0432
        EU3PartyTradeFeatureEnabled: Boolean;
#endif
}
