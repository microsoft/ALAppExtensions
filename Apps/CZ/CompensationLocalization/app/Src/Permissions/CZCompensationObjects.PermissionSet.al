// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11772 "CZ Compensation - Objects CZC"
{
    Access = Public;
    Assignable = false;
    Caption = 'CZ Compensation - Objects';

    Permissions = Codeunit "Compensation Approv. Mgt. CZC" = X,
                  Codeunit "Compensation Management CZC" = X,
                  Codeunit "Compensation - Post CZC" = X,
                  Codeunit "Compensation - Post Print CZC" = X,
                  Codeunit "Compensation - Post Yes/No CZC" = X,
                  Codeunit "Customer Handler CZC" = X,
                  Codeunit "Data Class. Eval. Handler CZC" = X,
                  Codeunit "Doc. Attachment Handler CZC" = X,
                  Codeunit "Gen. Journal Line Handler CZC" = X,
                  Codeunit "G/L Acc.Where-Used Handler CZC" = X,
                  Codeunit "Guided Experience Handler CZC" = X,
                  Codeunit "Install Application CZC" = X,
                  Codeunit "Navigate Handler CZC" = X,
                  Codeunit "Posting Group Mgt. Handler CZC" = X,
                  Codeunit "Release Compens. Document CZC" = X,
                  Codeunit "Sync.Dep.Fld-CompensSetup CZC" = X,
                  Codeunit "Sync.Dep.Fld-CustLedgEntry CZC" = X,
                  Codeunit "Sync.Dep.Fld-GenJnlLine CZC" = X,
                  Codeunit "Sync.Dep.Fld-PostCompensHd CZC" = X,
                  Codeunit "Sync.Dep.Fld-PostCompensLn CZC" = X,
                  Codeunit "Sync.Dep.Fld-PostGenJnlLn CZC" = X,
                  Codeunit "Sync.Dep.Fld-SrcCodeSetup CZC" = X,
                  Codeunit "Sync.Dep.Fld-VendLedgEntry CZC" = X,
                  Codeunit "Upgrade Application CZC" = X,
                  Codeunit "Upgrade Tag Definitions CZC" = X,
                  Codeunit "Vendor Handler CZC" = X,
                  Codeunit "Workflow Handler CZC" = X,
                  Page "Compensation Card CZC" = X,
                  Page "Compensation Lines CZC" = X,
                  Page "Compensation List CZC" = X,
                  Page "Compensation Proposal CZC" = X,
                  Page "Compensations Setup CZC" = X,
                  Page "Compensation Subform CZC" = X,
                  Page "Compens. Cust. LE Subform CZC" = X,
                  Page "Compens. Report Selections CZC" = X,
                  Page "Compens. Vendor LE Subform CZC" = X,
                  Page "Posted Compensation Card CZC" = X,
                  Page "Posted Compensation List CZC" = X,
                  Page "Posted Compensation Subf. CZC" = X,
                  Report "Compensation CZC" = X,
                  Report "Posted Compensation CZC" = X,
                  Table "Compensation Header CZC" = X,
                  Table "Compensation Line CZC" = X,
                  Table "Compensations Setup CZC" = X,
                  Table "Compens. Report Selections CZC" = X,
                  Table "Posted Compensation Header CZC" = X,
                  Table "Posted Compensation Line CZC" = X;
}