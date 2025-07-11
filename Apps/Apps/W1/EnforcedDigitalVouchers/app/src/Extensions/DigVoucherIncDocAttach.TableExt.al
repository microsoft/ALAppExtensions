// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

tableextension 5582 "Dig. Voucher Inc. Doc. Attach." extends "Incoming Document Attachment"
{
    fields
    {
        field(5582; "Is Digital Voucher"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
    }
}