// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The Reten. Pol. Deleting interface is used to set filters on the table for which a retention policy is applied.
/// </summary>
interface "Reten. Pol. Deleting"
{
    /// <summary>
    /// This function deletes the expired records for the retention policy according to the settings in the parameter table.
    /// </summary>
    /// <param name="RecordRef">The record reference with expired records for the retention policy.</param>
    /// <param name="RetenPolDeletingParam">The parameter table for this run of apply retention policy.</param>
    procedure DeleteRecords(var RecordRef: RecordRef; var RetenPolDeletingParam: Record "Reten. Pol. Deleting Param" temporary);
}