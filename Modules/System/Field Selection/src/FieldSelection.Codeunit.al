// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to look up fields.
/// </summary>
codeunit 9806 "Field Selection"
{
    Access = Public;

    /// <summary>
    /// Opens the fields lookup page and assigns the selected fields on the <paramref name="SelectedField"/> parameter.
    /// </summary>
    /// <param name="SelectedField">The field record variable to set the selected fields. Any filters on this record will influence the page view.</param>
    /// <returns>Returns true if a field was selected.</returns>
    procedure Open(var SelectedField: Record "Field"): Boolean
    var
        FieldSelectionImpl: Codeunit "Field Selection Impl.";
    begin
        exit(FieldSelectionImpl.Open(SelectedField));
    end;
}

