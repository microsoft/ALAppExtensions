// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Storage;

/// <summary>
/// Defines the possible resource types for account SAS.
/// See: https://go.microsoft.com/fwlink/?linkid=2210398
/// </summary>
enum 9063 "SAS Resource Type"
{
    Access = Public;
    Extensible = false;

    value(0; Service)
    {
        Caption = 's', Locked = true;
    }
    value(1; Container)
    {
        Caption = 'c', Locked = true;
    }
    value(2; Object)
    {
        Caption = 'o', Locked = true;
    }
}