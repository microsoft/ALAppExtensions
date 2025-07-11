// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 10039 "IRS 1099 Report Line"
{
    Access = Internal;
    DataClassification = CustomerContent;
    InherentEntitlements = X;
    InherentPermissions = X;
    TableType = Temporary;

    fields
    {
        field(1; "Line No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; Name; Text[250])
        {

        }
        field(3; Value; Text[250])
        {

        }
    }
    keys
    {
        key(PK; "Line No.")
        {
            Clustered = true;
        }
    }
}
