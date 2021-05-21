// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 13622 PmtReconciliationJournals extends "Pmt. Reconciliation Journals"
{
    actions
    {
        addafter(ImportBankTransactionsToNew)
        {
            action(ImportFik)
            {
                Ellipsis = true;
                Caption = 'Import &FIK Statement';
                ToolTip = 'Import a file with FIK payments. The Fik payments are automatically applied as suggestions.';
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedIsBig = true;
                Image = Import;
                PromotedCategory = Process;
                trigger OnAction();
                begin
                    ImportAndProcessToNewFIK();
                end;
            }
        }
    }
}