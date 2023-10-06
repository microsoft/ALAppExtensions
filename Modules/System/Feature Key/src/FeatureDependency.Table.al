// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

/// <summary>
/// Temporary table stores pairs of the dependent features.
/// </summary>
table 2611 "Feature Dependency"
{
    TableType = Temporary;
    InherentEntitlements = X;
    InherentPermissions = X;

    fields
    {
        field(1; "Feature Key"; Text[50])
        {
            Caption = 'Feature Key';
        }
        field(2; "Parent Feature Key"; Text[50])
        {
            Caption = 'Parent Feature Key';
        }
    }

    keys
    {
        key(PK; "Feature Key", "Parent Feature Key")
        { }
    }

    trigger OnInsert()
    begin
        // FeatureDependencyFacade.ValidateDependency(Rec);
    end;
}