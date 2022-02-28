// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AL0659
enum 1993 "Checklist Completion Requirements"
#pragma warning restore
{
    Access = Internal;

    /// <summary>
    /// Anyone who can view the checklist item can perform the action and the item will be registered 
    /// as completed.
    /// </summary>
    value(0; Anyone)
    {
        Caption = 'Anyone with roles';
    }

    /// <summary>
    /// Everyone who can view the checklist item needs to perform the action in order for the item
    /// to be registered as completed.
    /// </summary>
    value(1; Everyone)
    {
        Caption = 'Everyone with roles';
    }

    /// <summary>
    /// One or more specific users need to perform the checklist action in order for it to 
    /// be registered as completed.
    /// </summary>
    value(2; "Specific users")
    {
        Caption = 'Specific users';
    }
}