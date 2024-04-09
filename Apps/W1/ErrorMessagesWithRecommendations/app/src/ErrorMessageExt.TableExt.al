// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Shared.Error;

using System.Utilities;
tableextension 7900 "Error Message Ext." extends "Error Message"
{
    fields
    {
        field(7900; Title; Text[2048])
        {
            Caption = 'Title';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(7901; "Recommended Action Caption"; Text[100])
        {
            Caption = 'Recommended action caption';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(7902; "Error Msg. Fix Implementation"; Enum "Error Msg. Fix Implementation")
        {
            Caption = 'Error fix implementation';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(7903; "Message Status"; Enum "Error Message Status")
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
        }
        field(7904; "Sub-Context Record ID"; RecordID)
        {
            Caption = 'Sub-Context Record ID';
            DataClassification = CustomerContent;
        }
        field(7905; "Sub-Context Field Number"; Integer)
        {
            Caption = 'Sub-Context Field Number';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if "Sub-Context Record ID".TableNo = 0 then
                    "Sub-Context Field Number" := 0;
            end;
        }
    }

    keys
    {
        key(MessageStatus; "Message Status")
        {
            IncludedFields = "Error Msg. Fix Implementation";
        }
    }
}