// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.EServices.EDocument.Processing.Import;

/// <summary>
/// States that the E-Document goes through during the import process. To go between each state, they go through the steps defined in "Import E-Document Steps".
/// </summary>
enum 6100 "Import E-Doc. Proc. Status"
{
    Extensible = false;

    value(0; "Unprocessed")
    {
        Caption = 'Unprocessed';
    }
    // Structure received data
    value(1; "Readable")
    {
        Caption = 'Readable';
    }
    // Read into IR
    value(2; "Ready for draft")
    {
        Caption = 'Ready for draft';
    }
    // Prepare draft
    value(3; "Draft Ready")
    {
        Caption = 'Draft ready';
    }
    // Finish draft
    value(4; "Processed")
    {
        Caption = 'Processed';
    }
}