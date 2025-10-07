#if not CLEANSCHEMA30
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 11769 "VAT Period CZL"
{
    Caption = 'VAT Period';
#if not CLEAN28
    LookupPageId = "VAT Periods CZL";
    ObsoleteState = Pending;
    ObsoleteTag = '28.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '31.0';
#endif
    ObsoleteReason = 'Replaced by standard VAT Return Period table.';

    fields
    {
        field(1; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            NotBlank = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Name := Format("Starting Date", 0, MonthTok);
            end;
        }
        field(2; Name; Text[10])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; "New VAT Year"; Boolean)
        {
            Caption = 'New VAT Year';
            DataClassification = CustomerContent;
        }
        field(4; Closed; Boolean)
        {
            Caption = 'Closed';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "Starting Date")
        {
            Clustered = true;
        }
        key(Key2; "New VAT Year")
        {
        }
        key(Key3; Closed)
        {
        }
    }
    var
        MonthTok: Label '<Month Text>', Locked = true;
}
#endif