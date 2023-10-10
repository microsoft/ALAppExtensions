// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Integration.Microsoft.Graph;

/// <summary>
/// The conflict resolution behavior for actions that create a new item.
/// You can use the values fail, replace, or rename. 
/// The default for PUT is replace. 
/// An item will never be returned with this annotation. Write-only.
/// See: https://learn.microsoft.com/en-us/graph/api/resources/driveitem?view=graph-rest-1.0#instance-attributes
/// </summary>
enum 9351 "Mg ConflictBehavior"
{
    Access = Public;
    Extensible = false;

    value(0; Replace)
    {
        Caption = 'replace', Locked = true;
    }

    value(1; Fail)
    {
        Caption = 'fail', Locked = true;
    }

    value(2; Rename)
    {
        Caption = 'rename', Locked = true;
    }
}