// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Access information about the subscribed SKUs and the corresponding service plans.
/// You can retrieve information such as the SKU Object ID, SKU ID, number of licenses assigned, the license state (enabled, suspended, or warning), and the SKU part number.
/// For the corresponding service plans, you can retrieve the ID, the capability status, or the name.
/// </summary>
codeunit 458 "Azure AD Licensing"
{
    Access = Public;

    var
        [NonDebuggable]
        AzureADLicensingImpl: Codeunit "Azure AD Licensing Impl.";

    /// <summary>
    /// Sets the enumerator for the subscribed SKUs to its initial position, which is before the first subscribed SKU in the collection.
    /// </summary>
    /// <returns> True if the enumerator was successfully reset and otherwise false.</returns>
    [NonDebuggable]
    procedure ResetSubscribedSKU(): Boolean
    begin
        exit(AzureADLicensingImpl.ResetSubscribedSKU());
    end;

    /// <summary>
    /// Advances the enumerator to the next subscribed SKU in the collection. If only known service plans should be included, it advances to the next SKU known in Business Central.
    /// </summary>
    /// <returns> True if the enumerator was successfully advanced to the next SKU; false if the enumerator has passed the end of the collection.</returns>
    [NonDebuggable]
    procedure NextSubscribedSKU(): Boolean
    begin
        exit(AzureADLicensingImpl.NextSubscribedSKU());
    end;

    /// <summary>
    /// Gets the capability status of the subscribed SKU that the enumerator is currently pointing to in the collection.
    /// </summary>
    /// <returns> The capability status of the subscribed SKU, or an empty string if the subscribed SKUs enumerator was not initialized.</returns>
    [NonDebuggable]
    procedure SubscribedSKUCapabilityStatus(): Text
    begin
        exit(AzureADLicensingImpl.SubscribedSKUCapabilityStatus());
    end;

    /// <summary>
    /// Gets the number of licenses assigned to the subscribed SKU that the enumerator is currently pointing to in the collection.
    /// </summary>
    /// <returns> The number of licenses that are assigned to the subscribed SKU, or 0 if the subscribed SKUs enumerator was not initialized.</returns>
    [NonDebuggable]
    procedure SubscribedSKUConsumedUnits(): Integer
    begin
        exit(AzureADLicensingImpl.SubscribedSKUConsumedUnits());
    end;

    /// <summary>
    /// Gets the object ID of the subscribed SKU that the enumerator is currently pointing to in the collection.
    /// </summary>
    /// <returns> The object ID of the current SKU. If the subscribed SKUs enumerator was not initialized, it will return an empty string.</returns>
    [NonDebuggable]
    procedure SubscribedSKUObjectId(): Text
    begin
        exit(AzureADLicensingImpl.SubscribedSKUObjectId());
    end;

    /// <summary>
    /// Gets the number of prepaid licenses that are enabled for the subscribed SKU that the enumerator is currently pointing to in the collection.
    /// </summary>
    /// <returns> The number of prepaid licenses that are enabled for the subscribed SKU. If the subscribed SKUs enumerator was not initialized it will return 0.</returns>
    [NonDebuggable]
    procedure SubscribedSKUPrepaidUnitsInEnabledState(): Integer
    begin
        exit(AzureADLicensingImpl.SubscribedSKUPrepaidUnitsInEnabledState());
    end;

    /// <summary>
    /// Gets the number of prepaid licenses that are suspended for the subscribed SKU that the enumerator is currently pointing to in the collection.
    /// </summary>
    /// <returns>The number of prepaid licenses that are suspended for the subscribed SKU. If the subscribed SKUs enumerator was not initialized it will return 0.</returns>
    [NonDebuggable]
    procedure SubscribedSKUPrepaidUnitsInSuspendedState(): Integer
    begin
        exit(AzureADLicensingImpl.SubscribedSKUPrepaidUnitsInSuspendedState());
    end;

    /// <summary>
    /// Gets the number of prepaid licenses that are in warning status for the subscribed SKU that the enumerator is currently pointing to in the collection.
    /// </summary>
    /// <returns> The number of prepaid licenses that are in warning status for the subscribed SKU. If the subscribed SKUs enumerator was not initialized it will return 0.</returns>
    [NonDebuggable]
    procedure SubscribedSKUPrepaidUnitsInWarningState(): Integer
    begin
        exit(AzureADLicensingImpl.PrepaidUnitsInWarningState());
    end;

    /// <summary>
    /// Gets the unique identifier (GUID) for the subscribed SKU that the enumerator is currently pointing to in the collection.
    /// </summary>
    /// <returns> The unique identifier (GUID) of the subscribed SKU; empty string if the subscribed SKUs enumerator was not initialized.</returns>
    [NonDebuggable]
    procedure SubscribedSKUId(): Text
    begin
        exit(AzureADLicensingImpl.SubscribedSKUId());
    end;

    /// <summary>
    /// Gets the part number of the subscribed SKU that the enumerator is currently pointing to in the collection. For example, "AAD_PREMIUM" OR "RMSBASIC."
    /// </summary>
    /// <returns> The part number of the subscribed SKU or an empty string if the subscribed SKUs enumerator was not initialized.</returns>
    [NonDebuggable]
    procedure SubscribedSKUPartNumber(): Text
    begin
        exit(AzureADLicensingImpl.SubscribedSKUPartNumber());
    end;

    /// <summary>
    /// Sets the enumerator for service plans to its initial position, which is before the first service plan in the collection.
    /// </summary>
    [NonDebuggable]
    procedure ResetServicePlans()
    begin
        AzureADLicensingImpl.ResetServicePlans();
    end;

    /// <summary>
    /// Advances the enumerator to the next service plan in the collection.
    /// </summary>
    /// <returns> True if the enumerator was successfully advanced to the next service plan; false if the enumerator has passed the end of the collection or it was not initialized.</returns>
    [NonDebuggable]
    procedure NextServicePlan(): Boolean
    begin
        exit(AzureADLicensingImpl.NextServicePlan());
    end;

    /// <summary>
    /// Gets the service plan capability status.
    /// </summary>
    /// <returns> The capability status of the service plan, or an empty string if the service plan enumerator was not initialized.</returns>
    [NonDebuggable]
    procedure ServicePlanCapabilityStatus(): Text
    begin
        exit(AzureADLicensingImpl.ServicePlanCapabilityStatus());
    end;

    /// <summary>
    /// Gets the service plan ID.
    /// </summary>
    /// <returns> The ID of the service plan, or an empty string if the service plan enumerator was not initialized.</returns>
    [NonDebuggable]
    procedure ServicePlanId(): Text
    begin
        exit(AzureADLicensingImpl.ServicePlanId());
    end;

    /// <summary>
    /// Gets the service plan name.
    /// </summary>
    /// <returns> The name of the service plan, or an empty string if the service plan enumerator was not initialized.</returns>
    [NonDebuggable]
    procedure ServicePlanName(): Text
    begin
        exit(AzureADLicensingImpl.ServicePlanName());
    end;

    /// <summary>
    /// Checks whether to include unknown plans when moving to the next subscribed SKU in the subscribed SKUs collection.
    /// </summary>
    /// <returns> True if the unknown service plans should be included. Otherwise, false.</returns>
    [NonDebuggable]
    procedure IncludeUnknownPlans(): Boolean
    begin
        exit(AzureADLicensingImpl.IncludeUnknownPlans());
    end;

    /// <summary>
    /// Sets whether to include unknown plans when moving to the next subscribed SKU in subscribed SKUs collection.
    /// </summary>
    /// <param name="IncludeUnknownPlans">The value to be set to the flag.</param>
    [NonDebuggable]
    procedure SetIncludeUnknownPlans(IncludeUnknownPlans: Boolean)
    begin
        AzureADLicensingImpl.SetIncludeUnknownPlans(IncludeUnknownPlans);
    end;

    /// <summary>
    /// Sets a flag that is used to determine whether a test is in progress or not.
    /// </summary>
    /// <param name="TestInProgress">The value to be set to the flag.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure SetTestInProgress(TestInProgress: Boolean)
    begin
        AzureADLicensingImpl.SetTestInProgress(TestInProgress);
    end;
}

