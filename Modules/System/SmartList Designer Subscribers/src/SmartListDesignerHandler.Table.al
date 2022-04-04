// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A single-record table that can be used to handle contention between multiple subscribers of the events for the SmartList Designer.
/// Consumers of the events should check this record to see if another extension is registered as the handler and then decide if they
/// should execute code within their own subscriptions to these events. Likewise, consumers could set this record to register themselves
/// as the handler of events.
/// </summary>
table 2888 "SmartList Designer Handler"
{
    DataPerCompany = false;
    DataClassification = SystemMetadata;
    Extensible = false;
    ReplicateData = false;
#if not CLEAN19
    ObsoleteState = Pending;
    ObsoleteTag = '19.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '22.0';
#endif
    ObsoleteReason = 'The SmartList Designer is not supported in Business Central.';

    fields
    {
        /// <summary>
        /// The primary key of the table. As a single-record table this value
        /// should only ever be set to the empty string ''.
        /// </summary>
        field(1; PrimaryKey; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }

        /// <summary>
        /// The AppId of the extension that has registered itself as the handler
        /// of SmartList Designer events.
        /// </summary>
        field(2; HandlerExtensionId; Guid)
        {
            Caption = 'Handler Extension Id';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; PrimaryKey)
        {
            Clustered = true;
        }
    }

#if not CLEAN19
    trigger OnInsert()
    begin
        if PrimaryKey <> '' then
            Error(SingleValueOnlyErr);
    end;

    var
        SingleValueOnlyErr: Label 'The table only supports a single record whose primary key is the empty string';
#endif
}