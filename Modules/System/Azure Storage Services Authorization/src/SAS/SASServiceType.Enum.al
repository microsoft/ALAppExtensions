// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Storage;

/// <summary>
/// Defines the possible service types for account SAS
/// More Information: https://go.microsoft.com/fwlink/?linkid=2210398
/// </summary>
enum 9062 "SAS Service Type"
{
    Access = Public;
    Extensible = false;

    value(0; Blob)
    {
        Caption = 'b', Locked = true;
    }
    value(1; Queue)
    {
        Caption = 'q', Locked = true;
    }
    value(2; Table)
    {
        Caption = 't', Locked = true;
    }
    value(3; File)
    {
        Caption = 'f', Locked = true;
    }
}