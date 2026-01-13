// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.SalesOrderAgent;

enum 4594 "SOA Email Attachment Status"
{
    Access = Internal;
    Extensible = false;

    value(0; "Reviewed")
    {
        Caption = 'Reviewed';
    }
    value(1; NoRelevantContent)
    {
        Caption = 'No relevant content';
    }
    value(2; UnsupportedFormat)
    {
        Caption = 'Unsupported format';
    }
    value(3; ExceedsPageCount)
    {
        Caption = 'Exceeds Page Count';
    }
    value(4; ExceedsNumberOfAttachments)
    {
        Caption = 'Exceeds maximum number of attachments';
    }
}