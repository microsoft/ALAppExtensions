#pragma warning disable AA0247
permissionset 11742 "CZ Advance Pack - Objects CZA"
{
    Access = Public;
    Assignable = false;
    Caption = 'CZ Advance Pack - Objects';

    Permissions =
#if not CLEAN26
#pragma warning disable AL0432
    codeunit "Assembly Handler CZA" = X,
#pragma warning restore AL0432
#endif
                  codeunit "Calculate Invent. Handler CZA" = X,
                  codeunit "Cancel FA Ldg.Ent. Handler CZA" = X,
                  codeunit "Data Class. Eval. Handler CZA" = X,
                  codeunit "Copy Fixed Asset Handler CZA" = X,
                  codeunit "Default Dimension Handler CZA" = X,
                  codeunit "Dimension Auto.Create Mgt. CZA" = X,
                  codeunit "Dimension Auto.Update Mgt. CZA" = X,
                  codeunit "Gen. Jnl.-Apply Handler CZA" = X,
                  codeunit "Gen. Jnl.Post Line Handler CZA" = X,
                  codeunit "Gen. Journal Line Handler CZA" = X,
#if not CLEAN26
#pragma warning disable AL0432
                  codeunit "G/L Entry - Edit CZA" = X,
#pragma warning restore AL0432
#endif
                  codeunit "G/L Entry Edit Handler CZA" = X,
                  codeunit "G/L Entry Post Application CZA" = X,
                  codeunit "Install Application CZA" = X,
                  codeunit "ItemJnl-Check Line Handler CZA" = X,
                  codeunit "Item Jnl-Post Line Handler CZA" = X,
                  codeunit "Item Journal Line Handler CZA" = X,
                  codeunit "Item Tracking Line Handler CZA" = X,
                  codeunit "Job Journal Line Handler CZA" = X,
                  codeunit "Process Data Exch. Handler CZA" = X,
#if not CLEAN26
#pragma warning disable AL0432
                  codeunit "Production Order Handler CZA" = X,
#pragma warning restore AL0432
#endif
                  codeunit "Purchase Line Handler CZA" = X,
                  codeunit "Reversal Entry Handler CZA" = X,
                  codeunit "Req.Wksh.Make Ord. Handler CZA" = X,
                  codeunit "Sales Line Handler CZA" = X,
                  codeunit "Service Line Handler CZA" = X,
                  codeunit "Std. Item Journal Handler CZA" = X,
                  codeunit "Substitute Report Handler CZA" = X,
                  codeunit "Transfer Header Handler CZA" = X,
                  codeunit "Transfer Line Handler CZA" = X,
                  codeunit "TransferOrder-Post Handler CZA" = X,
                  codeunit "Undo Shipment Line Handler CZA" = X,
                  codeunit "Upgrade Application CZA" = X,
                  codeunit "Upgrade Tag Definitions CZA" = X,
                  page "Applied G/L Entries CZA" = X,
#if not CLEAN26
#pragma warning disable AL0432
                  page "Apply G/L Entries CZA" = X,
#pragma warning restore AL0432
#endif
                  page "Apply Gen. Ledger Entries CZA" = X,
                  page "Detailed G/L Entries CZA" = X,
                  page "Unapply G/L Entries CZA" = X,
                  report "G/L Entry Applying CZA" = X,
                  report "Inventory Account To Date CZA" = X,
                  report "Inventory Valuation - WIP CZA" = X,
                  report "Open G/L Entries To Date CZA" = X,
                  table "Detailed G/L Entry CZA" = X;
}
