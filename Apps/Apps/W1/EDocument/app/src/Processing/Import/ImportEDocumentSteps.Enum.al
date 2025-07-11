// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.EServices.EDocument.Processing.Import;

/// <summary>
/// The steps that an E-Document goes through during the import process.
/// </summary>
enum 6114 "Import E-Document Steps"
{
    Extensible = false;

    // Unprocessed
    value(0; "Structure received data")
    {
        Caption = 'Structure received data';
    }
    // Readable
    value(1; "Read into Draft")
    {
        Caption = 'Read into draft';
    }
    // Ready for draft
    value(2; "Prepare draft")
    {
        Caption = 'Prepare draft';
    }
    // Draft ready
    value(3; "Finish draft")
    {
        Caption = 'Finish draft';
    }
    // Processed
}