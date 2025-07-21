#if not CLEANSCHEMA29
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;
#pragma warning disable AS0002 // this is a "false positive" - PK change was backported to 26.2, but it's being reverted, therefore the analyzer thinks that this is another PK change, this will be also backported to 26.3 
#pragma warning disable AS0009
table 6109 "EDoc. Purch. Line Field Setup"
{
    Access = Internal;
#pragma warning disable AS0072 // this change will be backported - the tag 26.0 is expected
    ObsoleteReason = 'Replaced by "ED Purchase Line Field Setup"';
#if not CLEAN26
    ObsoleteState = Pending;
    ObsoleteTag = '26.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '29.0';
#endif
#pragma warning restore AS0072
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    ReplicateData = false;

    fields
    {
        field(1; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Field No.")
        {
            Clustered = true;
        }
    }
}
#pragma warning restore AS0002
#pragma warning restore AS0009
#endif