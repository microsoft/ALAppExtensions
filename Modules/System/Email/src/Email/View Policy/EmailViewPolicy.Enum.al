// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Available policies that can be assigned to a user.  
/// </summary>
enum 8930 "Email View Policy" implements "Email View Policy"
{
    Access = Public;
    Extensible = true;

    /// <summary>
    /// Policy allowing users to view their own emails.
    /// </summary>
    value(0; OwnEmails)
    {
        Implementation = "Email View Policy" = "View Only Own Emails Policy";
        Caption = 'View own emails';
    }
    /// <summary>
    /// Policy allowing users to view all emails.
    /// </summary>
    value(1; AllEmails)
    {
        Implementation = "Email View Policy" = "View All Emails Policy";
        Caption = 'View all emails';
    }
    /// <summary>
    /// Policy allowing users to view emails if they have direct permissions to all its related records.
    /// Authors can always see their own emails.
    /// </summary>
    value(2; AllRelatedRecordsEmails)
    {
        Implementation = "Email View Policy" = "View If All Related Records";
        Caption = 'View if access to all related records';
    }
    /// <summary>
    /// Policy allowing users to view emails if they have direct permissions to one or more of its related records.
    /// Authors can always see their own emails.
    /// </summary>
    value(3; AnyRelatedRecordEmails)
    {
        Implementation = "Email View Policy" = "View If Any Related Records";
        Caption = 'View if access to any related records';
    }
}