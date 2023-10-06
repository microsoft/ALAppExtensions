// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

/// <summary>
/// The Signup Context is used to track from where a tenant originated.
/// </summary>
enum 150 "Signup Context"
{
    Extensible = true;

    /// <summary>
    /// The blank value indicates the sinup context was not set or unknown.
    /// </summary>
    value(0; " ")
    {
        Caption = 'Not Set';
    }
    /// <summary>
    ///  The Viral Signup value indicates the tenant was created by viral signup.
    /// </summary>
    value(1; "Viral Signup")
    {
        Caption = 'Viral Signup';
    }
}