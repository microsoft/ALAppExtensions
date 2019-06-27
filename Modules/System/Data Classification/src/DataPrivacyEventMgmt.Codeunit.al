// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
///
/// </summary>
codeunit 1183 "Data Privacy Event Mgmt."
{
    Access = Public;

    /// <summary>
    /// Publishes an event that allows subscription during the drill down of the EntityNo field on the Data Privacy Wizard page.
    /// </summary>
    /// <param name="EntityTypeTableNo">The table ID of the entity.</param>
    /// <param name="EntityNo">The ID of the entity.</param>
    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    internal procedure OnDrillDownForEntityNumber(EntityTypeTableNo: Integer; var EntityNo: Code[50])
    begin
    end;

    /// <summary>
    /// Publishes an event that allows subscription when validating the EntityNo field on the Data Privacy Wizard page.
    /// </summary>
    /// <param name="EntityTypeTableNo">The table ID of the entity.</param>
    /// <param name="EntityNo">The ID of the entity.</param>
    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    internal procedure OnEntityNoValidate(EntityTypeTableNo: Integer; var EntityNo: Code[50])
    begin
    end;
}

