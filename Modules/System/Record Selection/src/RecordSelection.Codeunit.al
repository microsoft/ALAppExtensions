// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Reflection;

/// <summary>
/// Exposes functionality to look up records.
/// </summary>
codeunit 9555 "Record Selection"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Opens the record lookup page and assigns the selected records on the <paramref name="SelectedRecord"/> parameter.
    /// </summary>
    /// <param name="TableId">The ID of the table from which records should be selected.</param>
    /// <param name="MaximumCount">The maximum number of records allowed in the table that is being looked up. If there are more records, an error is thrown.</param>
    /// <param name="SelectedRecord">The variable to set the selected records.</param>
    /// <error>There is more than <paramref name="MaximumCount"/> records in the table.</error>
    /// <returns>Returns true if a record was selected.</returns>
    procedure Open(TableId: Integer; MaximumCount: Integer; var SelectedRecord: Record "Record Selection Buffer"): Boolean
    var
        RecordSelectionImpl: Codeunit "Record Selection Impl.";
    begin
        exit(RecordSelectionImpl.Open(TableId, MaximumCount, SelectedRecord));
    end;

    /// <summary>
    /// Returns a string representation of the record from the given <paramref name="TableId"/> with the given <paramref name="SystemId"/>.
    /// The string representation is a comma separated string of fields that describes the record.
    /// </summary>
    /// <example>
    /// For the Company Information table, an example return value is "CRONUS International Ltd.".
    /// For the Bank Account Ledger Entry table, an example return value is "37,Order 106015,GIRO,01/01/24,Payment,108017"
    /// </example>
    /// <param name="TableId">The ID of the table from which the record is located.</param>
    /// <param name="SystemId">The system id of the record.</param>
    /// <returns>A string representation of the record.</returns>
    procedure ToText(TableId: Integer; SystemId: Guid): Text
    var
        RecordSelectionImpl: Codeunit "Record Selection Impl.";
    begin
        exit(RecordSelectionImpl.ToText(TableId, SystemId));
    end;


}

