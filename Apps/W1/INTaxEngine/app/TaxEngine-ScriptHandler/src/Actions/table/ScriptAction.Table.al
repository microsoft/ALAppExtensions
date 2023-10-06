// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.ScriptHandler;

table 20186 "Script Action"
{
    Caption = 'Script Action';
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; ID; Enum "Action Type")
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'ID';
        }
        field(2; Text; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Text';
        }
        field(3; "Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Table ID';
        }
        field(4; "Rule ID Field No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Rule ID Field No.';
        }
    }

    keys
    {
        key(K0; ID)
        {
            Clustered = True;
        }
    }
}
