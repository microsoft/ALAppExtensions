// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

table 2029 "MS - Img. Analyzer Blacklist"
{
    ReplicateData = false;
    Caption = 'Image Analyzer Blocked Attributes';

    fields
    {
        field(1; TagName; Text[250])
        {
            Caption = 'Tag Name';
        }
    }

    keys
    {
        key(PK; TagName)
        {
            Clustered = true;
        }
    }
}