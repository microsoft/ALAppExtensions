// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies the version in which the extension is deployed.
/// </summary>
enum 2504 "Extension Deploy To"
{
    Extensible = false;
    AssignmentCompatibility = true;

    /// <summary>
    /// Current version.
    /// </summary>
    value(0; "Current version")
    {
        Caption = 'Current version';
    }

    /// <summary>
    /// Next minor version
    /// </summary>
    value(1; "Next minor version")
    {
        Caption = 'Next minor version';
    }
    /// <summary>
    /// Next major version
    /// </summary>
    value(2; "Next major version")
    {
        Caption = 'Next major version';
    }
}