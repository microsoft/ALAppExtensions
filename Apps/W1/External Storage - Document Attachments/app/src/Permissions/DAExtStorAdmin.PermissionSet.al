// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary>
/// Permission set for External Storage functionality.
/// Grants necessary permissions to use external storage features.
/// </summary>
permissionset 8751 "DA Ext. Stor. Admin"
{
    Assignable = true;
    Caption = 'Document Attachments - External Storage Admin';
    Permissions = tabledata "DA External Storage Setup" = RIMD,
        table "DA External Storage Setup" = X,
        page "DA External Storage Setup" = X,
        page "Document Attachment - External" = X,
        report "DA External Storage Sync" = X,
        codeunit "DA External Storage Processor" = X,
        codeunit "DA External Storage Subs." = X;
}