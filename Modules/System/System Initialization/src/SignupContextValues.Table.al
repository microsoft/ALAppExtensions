// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

/// <summary>
/// This table stores the signup context and additional values passed at signup.
/// </summary>
table 150 "Signup Context Values"
{
    DataClassification = SystemMetadata;
    DataPerCompany = false;
    ReplicateData = false;
#pragma warning disable AS0034
    InherentEntitlements = RIX;
    InherentPermissions = RIX;
#pragma warning restore AS0034

    fields
    {
        /// <summary>
        /// The primary key for the signup context values.
        /// </summary>
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = SystemMetadata;
        }
        /// <summary>
        /// The Signup Context is used to track from where a tenant originated.
        /// </summary>
        field(2; "Signup Context"; Enum "Signup Context")
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}