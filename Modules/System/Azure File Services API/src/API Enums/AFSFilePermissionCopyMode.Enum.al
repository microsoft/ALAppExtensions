// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Describes possible values for File Permission Copy Mode header.
/// </summary>
enum 8956 "AFS File Permission Copy Mode"
{
    Access = Public;
    Extensible = false;

    /// <summary>
    /// Copy file permissions from source to destination.
    /// </summary>
    value(0; Source)
    {
        Caption = 'source', Locked = true;
    }
    /// <summary>
    /// Override file permissions on destination with permissions from the request.
    /// </summary>
    value(1; Override)
    {
        Caption = 'override', Locked = true;
    }
}