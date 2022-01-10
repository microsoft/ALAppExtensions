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
                  Codeunit "Data Class. Eval. Handler CZA" = X,
                  Codeunit "Default Dimension Handler CZA" = X,
                  Codeunit "Dimension Auto.Create Mgt. CZA" = X,
                  Codeunit "Dimension Auto.Update Mgt. CZA" = X,
                  Codeunit "Gen. Jnl.-Apply Handler CZA" = X,
                  Codeunit "Gen. Jnl.Post Line Handler CZA" = X,
                  Codeunit "Gen. Journal Line Handler CZA" = X,
                  Codeunit "G/L Entry - Edit CZA" = X,
                  Codeunit "G/L Entry Post Application CZA" = X,
                  Codeunit "Install Application CZA" = X,
                  Codeunit "ItemJnl-Check Line Handler CZA" = X,
                  Codeunit "Item Jnl-Post Line Handler CZA" = X,
                  Codeunit "Item Journal Line Handler CZA" = X,
                  Codeunit "Job Journal Line Handler CZA" = X,
                  Codeunit "Nonstock Item Handler CZA" = X,
                  Codeunit "Process Data Exch. Handler CZA" = X,
                  Codeunit "Production Order Handler CZA" = X,
                  Codeunit "Purchase Line Handler CZA" = X,
                  Codeunit "Reversal Entry Handler CZA" = X,
                  Codeunit "Sales Line Handler CZA" = X,
                  Codeunit "Service Line Handler CZA" = X,
#if not CLEAN18
                  Codeunit "Sync.Dep.Fld-AssemblyHdr. CZA" = X,
                  Codeunit "Sync.Dep.Fld-AssemblyLine CZA" = X,
                  Codeunit "Sync.Dep.Fld-AssemblySetup CZA" = X,
                  Codeunit "Sync.Dep.Fld-InvtSetup CZA" = X,
                  Codeunit "Sync.Dep.Fld-ItemJnlLine CZA" = X,
                  Codeunit "Sync.Dep.Fld-ManufactSetup CZA" = X,
                  Codeunit "Sync.Dep.Fld-NonsItemSetup CZA" = X,
                  Codeunit "Sync.Dep.Fld-TransferHdr CZA" = X,
                  Codeunit "Sync.Dep.Fld-TransferLine CZA" = X,
                  Codeunit "Sync.Dep.Fld-TransferRoute CZA" = X,
                  Codeunit "Sync.Dep.Fld-TransRcptHdr CZA" = X,
                  Codeunit "Sync.Dep.Fld-TransRcptLine CZA" = X,
                  Codeunit "Sync.Dep.Fld-TransShptHdr CZA" = X,
                  Codeunit "Sync.Dep.Fld-TransShptLine CZA" = X,
#endif
#if not CLEAN19
                  Codeunit "Sync.Dep.Fld-DetGLEntry CZA" = X,
                  Codeunit "Sync.Dep.Fld-GLEntry CZA" = X,
#endif
                  Codeunit "Transfer Header Handler CZA" = X,
                  Codeunit "Transfer Line Handler CZA" = X,
                  Codeunit "TransferOrder-Post Handler CZA" = X,
                  Codeunit "Upgrade Application CZA" = X,
                  Codeunit "Upgrade Tag Definitions CZA" = X,
                  Page "Applied G/L Entries CZA" = X,
                  Page "Apply G/L Entries CZA" = X,
                  Page "Detailed G/L Entries CZA" = X,
                  Page "Unapply G/L Entries CZA" = X,
                  Report "G/L Entry Applying CZA" = X,
                  Report "Inventory Account To Date CZA" = X,
                  Report "Open G/L Entries To Date CZA" = X,
                  Table "Detailed G/L Entry CZA" = X;
}