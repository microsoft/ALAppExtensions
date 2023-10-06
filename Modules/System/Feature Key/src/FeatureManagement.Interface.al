// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

/// <summary>
/// Interface that defines methods for linking tables "Feature Key Buffer" and "Feature Key".
/// The default implementation uses the system table "Feature Key" as a source, 
/// but another implementation uses a temporary table "Feature Key" to delink Feature Management UX from the read-only virtual table.
/// </summary>
interface "Feature Management"
{
    /// <summary>
    /// Returns number of collected records. Feature interface read the system table "Feature Key" or 
    /// another source of data depends on the interface implementation. In tests it can be a temporary table "Feature Key".
    /// Parameters IncludeFeatureKeys or ExcludeFeatureKeys can be used to get a subset of all existing records.
    /// </summary>
    /// <param name="IncludeFeatureKeys">the list of feature ids that must be included into the result buffer</param>
    /// <param name="ExcludeFeatureKeys">the list of feature ids that must be excluded from the result buffer</param>
    /// <param name="FeatureKeyBuffer">the record set of the table "Feature Key Buffer"</param>
    /// <returns>number of records in the buffer</returns>
    procedure GetData(IncludeFeatureKeys: List of [Text[50]]; ExcludeFeatureKeys: List of [Text[50]]; var FeatureKeyBuffer: Record "Feature Key Buffer"): Integer

    /// <summary>
    /// Returns number of collected records. Feature interface read the system table "Feature Key" or 
    /// another source of data depends on the interface implementation. In tests it can be a temporary table "Feature Key".
    /// </summary>
    /// <param name="FeatureId">the feature id in the system table "Feature Key"</param>
    /// <param name="TempFeatureKey">the returned fresh copy of the record in the table "Feature Key"</param>
    /// <returns>if the feature key record was found</returns>
    procedure GetFeatureKey(FeatureId: Text[50]; var TempFeatureKey: Record "Feature Key" temporary): Boolean;

    /// <summary>
    /// Modifies the Enabled field in the source record in the "Feature Key" table.
    /// The new value for the Enabled field is taken from the TempFeatureKey.Enabled.
    /// </summary>
    /// <param name="TempFeatureKey">the copy of the record in the table "Feature Key"</param>
    /// <returns>if the feature key record was modified</returns>
    procedure SetEnabled(TempFeatureKey: Record "Feature Key" temporary): Boolean;

    /// <summary>
    /// Fills the temporary table "Feature Dependency" stored in the single instance codeunit "Feature Dependency Management".
    /// Add new feature dependencies by passing DependentFeatureId and ParentFeatureID, 
    /// FeatureKeyBuffer is passed to control data consistency:
    ///   FeatureDependency.New(FeatureKeyBuffer, DependentFeatureId, ParentFeatureID);
    /// </summary>
    /// <param name="FeatureKeyBuffer">the record set of the available feature keys</param>
    /// <param name="FeatureDependency">returned the record set of the dependencies to add</param>
    /// <returns>if any feature dependency was generated</returns>
    procedure GenerateDependencies(var FeatureKeyBuffer: Record "Feature Key Buffer"; var FeatureDependency: Record "Feature Dependency"): Boolean
}
