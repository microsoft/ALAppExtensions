// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Extends File Scenario enum with External Storage option.
/// Allows File Account framework to recognize external storage scenarios.
/// </summary>
enumextension 8750 "DA Ext. Storage-File Scenario" extends "File Scenario"
{
    value(8750; "Doc. Attach. - External Storage")
    {
        Caption = 'Document Attachments - External Storage';
    }
}