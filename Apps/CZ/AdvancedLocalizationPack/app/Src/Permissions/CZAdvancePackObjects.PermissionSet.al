// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11742 "CZ Advance Pack - Objects CZA"
{
    Access = Public;
    Assignable = false;
    Caption = 'CZ Advance Pack - Objects';

    Permissions = Codeunit "Assembly Handler CZA" = X,
                  codeunit "Data Class. Eval. Handler CZA" = X,
                  codeunit "Default Dimension Handler CZA" = X,
                  codeunit "Dimension Auto.Create Mgt. CZA" = X,
                  codeunit "Dimension Auto.Update Mgt. CZA" = X,
                  codeunit "Gen. Jnl.-Apply Handler CZA" = X,
                  codeunit "Gen. Jnl.Post Line Handler CZA" = X,
                  codeunit "Gen. Journal Line Handler CZA" = X,
                  codeunit "G/L Entry - Edit CZA" = X,
                  codeunit "G/L Entry Post Application CZA" = X,
                  codeunit "Install Application CZA" = X,
                  codeunit "ItemJnl-Check Line Handler CZA" = X,
                  codeunit "Item Jnl-Post Line Handler CZA" = X,
                  codeunit "Item Journal Line Handler CZA" = X,
                  codeunit "Item Tracking Line Handler CZA" = X,
                  codeunit "Job Journal Line Handler CZA" = X,
                  codeunit "Nonstock Item Handler CZA" = X,
                  codeunit "Process Data Exch. Handler CZA" = X,
                  codeunit "Production Order Handler CZA" = X,
                  codeunit "Purchase Line Handler CZA" = X,
                  codeunit "Reversal Entry Handler CZA" = X,
                  codeunit "Sales Line Handler CZA" = X,
                  codeunit "Service Line Handler CZA" = X,
#if not CLEAN18
                  codeunit "Sync.Dep.Fld-AssemblyHdr. CZA" = X,
                  codeunit "Sync.Dep.Fld-AssemblyLine CZA" = X,
                  codeunit "Sync.Dep.Fld-AssemblySetup CZA" = X,
                  codeunit "Sync.Dep.Fld-InvtSetup CZA" = X,
                  codeunit "Sync.Dep.Fld-ItemJnlLine CZA" = X,
                  codeunit "Sync.Dep.Fld-ManufactSetup CZA" = X,
                  codeunit "Sync.Dep.Fld-NonsItemSetup CZA" = X,
                  codeunit "Sync.Dep.Fld-TransferHdr CZA" = X,
                  codeunit "Sync.Dep.Fld-TransferLine CZA" = X,
                  codeunit "Sync.Dep.Fld-TransferRoute CZA" = X,
                  codeunit "Sync.Dep.Fld-TransRcptHdr CZA" = X,
                  codeunit "Sync.Dep.Fld-TransRcptLine CZA" = X,
                  codeunit "Sync.Dep.Fld-TransShptHdr CZA" = X,
                  codeunit "Sync.Dep.Fld-TransShptLine CZA" = X,
#endif
#if not CLEAN19
                  codeunit "Sync.Dep.Fld-DetGLEntry CZA" = X,
                  codeunit "Sync.Dep.Fld-GLEntry CZA" = X,
#endif
#if not CLEAN20
                  codeunit "Sync.Dep.Fld-ItemEntryRel. CZA" = X,
#endif
                  codeunit "Transfer Header Handler CZA" = X,
                  codeunit "Transfer Line Handler CZA" = X,
                  codeunit "TransferOrder-Post Handler CZA" = X,
                  codeunit "Undo Transfer Ship. Line CZA" = X,
                  codeunit "Upgrade Application CZA" = X,
                  codeunit "Upgrade Tag Definitions CZA" = X,
                  page "Applied G/L Entries CZA" = X,
                  page "Apply G/L Entries CZA" = X,
                  page "Detailed G/L Entries CZA" = X,
                  page "Unapply G/L Entries CZA" = X,
                  report "G/L Entry Applying CZA" = X,
                  report "Inventory Account To Date CZA" = X,
                  report "Open G/L Entries To Date CZA" = X,
                  table "Detailed G/L Entry CZA" = X;
}
