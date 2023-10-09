// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Integration.Word;

table 130443 "Word Templates Test Table"
{
    DataClassification = SystemMetadata;
    TableType = Temporary;
    Caption = 'Word Templates Test / Table "<>:/\|?*'; // Used to verify that reserved characters are removed in template name
    ReplicateData = false;

    fields
    {
        field(1; "No."; Integer)
        {
            AutoIncrement = true;
        }
    }
}