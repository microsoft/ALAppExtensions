// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11762 "CZ Fixed Asset - Objects CZF"
{
    Access = Public;
    Assignable = false;
    Caption = 'CZ Fixed Asset - Objects';

    Permissions = Codeunit "Calc. Normal Depr. Handler CZF" = X,
                  Codeunit "Data Class. Eval. Handler CZF" = X,
                  Codeunit "FA Acquisition Handler CZF" = X,
                  Codeunit "FA Deprec. Book Handler CZF" = X,
                  Codeunit "FA Disposal Handler CZF" = X,
                  Codeunit "FA General Report CZF" = X,
                  Codeunit "FA Insert G/L Acc. Handler CZF" = X,
                  Codeunit "FA History Handler CZF" = X,
                  Codeunit "FA History Management CZF" = X,
                  Codeunit "FA Ledger Entry Handler CZF" = X,
                  Codeunit "Guided Experience Handler CZF" = X,
                  Codeunit "Install Application CZF" = X,
                  Codeunit "Substitute Report Handler CZF" = X,
                  Codeunit "Upgrade Application CZF" = X,
                  Codeunit "Upgrade Tag Definitions CZF" = X,
                  Page "Classification Codes CZF" = X,
                  Page "Create FA History CZF" = X,
                  Page "FA Extended Posting Groups CZF" = X,
                  Page "FA History Entries CZF" = X,
                  Page "Tax Depreciation Groups CZF" = X,
                  Report "Calculate Depreciation CZF" = X,
                  Report "FA - Analysis G/L Account CZF" = X,
                  Report "FA Assignment/Discard CZF" = X,
                  Report "FA Physical Inventory List CZF" = X,
                  Report "Fixed Asset Acquisition CZF" = X,
                  Report "Fixed Asset - Analysis CZF" = X,
                  Report "Fixed Asset - An. Dep.Book CZF" = X,
                  Report "Fixed Asset - Book Value 1 CZF" = X,
                  Report "Fixed Asset - Book Value 2 CZF" = X,
                  Report "Fixed Asset Card CZF" = X,
                  Report "Fixed Asset Disposal CZF" = X,
                  Report "Fixed Asset - G/L Analysis CZF" = X,
                  Report "Fixed Asset History CZF" = X,
                  Report "Fixed Asset - Proj. Value CZF" = X,
                  Report "Initialize FA History CZF" = X,
                  Report "Maintenance - Analysis CZF" = X,
                  Table "Classification Code CZF" = X,
                  Table "FA Extended Posting Group CZF" = X,
                  Table "FA History Entry CZF" = X,
                  Table "Tax Depreciation Group CZF" = X;
}
