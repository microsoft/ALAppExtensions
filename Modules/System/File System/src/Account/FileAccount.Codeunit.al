// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

/// <summary>
/// Provides functionality to work with file accounts.
/// </summary>

codeunit 70000 "File Account"
{
    Access = Public;

    /// <summary>
    /// Gets all of the file accounts registered in Business Central.
    /// </summary>
    /// <param name="LoadLogos">Flag, used to determine whether to load the logos for the accounts.</param>
    /// <param name="TempFileAccount">Out parameter holding the file accounts.</param>
    procedure GetAllAccounts(LoadLogos: Boolean; var TempFileAccount: Record "File Account" temporary)
    begin
        FileAccountImpl.GetAllAccounts(LoadLogos, TempFileAccount);
    end;

    /// <summary>
    /// Gets all of the file accounts registered in Business Central.
    /// </summary>
    /// <param name="TempFileAccount">Out parameter holding the file accounts.</param>
    procedure GetAllAccounts(var TempFileAccount: Record "File Account" temporary)
    begin
        FileAccountImpl.GetAllAccounts(false, TempFileAccount);
    end;

    /// <summary>
    /// Checks if there is at least one file account registered in Business Central.
    /// </summary>
    /// <returns>True if there is any account registered in the system, otherwise - false.</returns>
    procedure IsAnyAccountRegistered(): Boolean
    begin
        exit(FileAccountImpl.IsAnyAccountRegistered());
    end;

    var
        FileAccountImpl: Codeunit "File Account Impl.";
}