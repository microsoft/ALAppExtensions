// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to manage the Table Information Cache table and the Company Size Cache table.
/// </summary> 
codeunit 8701 "Table Information Cache"
{
    Access = Public;

    /// <summary>
    /// Refreshes the data in the Table Information Cache and Company Size Cache tables for all companies.
    /// </summary>
    trigger OnRun()
    begin
        RefreshTableInformationCache();
    end;

    /// <summary>
    /// Refreshes the data in the Table Information Cache and Company Size Cache tables for all companies.
    /// </summary>
    procedure RefreshTableInformationCache()
    var
        TableInformationCacheImpl: Codeunit "Table Information Cache Impl.";
    begin
        TableInformationCacheImpl.RefreshTableInformationCache();
    end;
}