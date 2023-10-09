// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

table 1810 "Assisted Setup Icons"
{
    Access = Internal;
    Caption = 'Assisted Setup Icons';
    DataPerCompany = false;
    ReplicateData = false;
    ObsoleteState = Removed;
    ObsoleteReason = 'Icons are added directly from the extensions that add assisted setup, so no need to aggregate the icons here.';
    ObsoleteTag = '19.0';

    fields
    {
        field(1; "No."; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
        }
        field(2; Image; Media)
        {
            DataClassification = CustomerContent;
            Caption = 'Image';
        }
        field(3; "Media Resources Ref"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Media Resources Ref';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
}

