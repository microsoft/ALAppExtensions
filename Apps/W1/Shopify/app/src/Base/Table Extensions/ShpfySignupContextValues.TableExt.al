// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using System.Environment.Configuration;

/// <summary>
/// Table extension for the Signup Context values
/// </summary>
tableextension 30199 "Shpfy Signup Context Values" extends "Signup Context Values"
{
    fields
    {
        field(30100; "Shpfy Signup Shop Url"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Signup Shop Url';
            Access = Internal;
        }
    }
}