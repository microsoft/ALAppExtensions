// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary>
/// Permission set for External Storage functionality.
/// Grants necessary permissions to use external storage features.
/// </summary>
permissionset 8750 "DA Ext. Stor. View"
{
    Assignable = true;
    Caption = 'Document Attachments - External Storage View';
    Permissions = tabledata "DA External Storage Setup" = R,
        table "DA External Storage Setup" = X,
        page "DA External Storage Setup" = X,
        page "Document Attachment - External" = X,
        codeunit "DA External Storage Processor" = X,
        codeunit "DA External Storage Subs." = X;
}