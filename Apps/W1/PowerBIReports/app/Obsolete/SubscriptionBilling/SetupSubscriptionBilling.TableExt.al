// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.SubscriptionBilling.PowerBIReports;

using Microsoft.PowerBIReports;

tableextension 36961 "Setup - Subscription Billing" extends "PowerBI Reports Setup"
{
    fields
    {
        field(37000; "Subs. Billing Report Name"; Text[200])
        {
            Caption = 'Subscription Billing Report Name';
            DataClassification = CustomerContent;
#if not CLEAN28
            ObsoleteState = PendingMove;
            ObsoleteTag = '28.0';
#else
            ObsoleteState = Moved;
            ObsoleteTag = '31.0';
#endif
            ObsoleteReason = 'Tableextension moved to the Subscription Billing app, please add it to your dependencies';
            MovedTo = '3099ffc7-4cf7-4df6-9b96-7e4bc2bb587c';
        }
        field(37001; "Subscription Billing Report Id"; Guid)
        {
            Caption = 'Subscription Billing Report Id';
            DataClassification = CustomerContent;
#if not CLEAN28
            ObsoleteState = PendingMove;
            ObsoleteTag = '28.0';
#else
            ObsoleteState = Moved;
            ObsoleteTag = '31.0';
#endif
            ObsoleteReason = 'Tableextension moved to the Subscription Billing app, please add it to your dependencies';
            MovedTo = '3099ffc7-4cf7-4df6-9b96-7e4bc2bb587c';
        }
    }
}