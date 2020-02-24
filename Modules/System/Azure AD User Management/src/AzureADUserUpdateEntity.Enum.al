// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The entities that are updated in Business Central from Office 365.
/// </summary>
/// <remarks>
/// The order in which the update is processed must be in the following order.
/// Authentication email must be updated before Plan, and Plan must be updated before Language ID.
/// </remarks>
enum 9515 "Azure AD User Update Entity"
{
    Extensible = false;

    /// <summary>
    /// Represents an update to the authentication email property of a user.
    /// </summary>
    value(0; "Authentication Email")
    {
        Caption = 'Authentication Email';
    }

    /// <summary>
    /// Represents an update to the contact email property of a user.
    /// </summary>
    value(1; "Contact Email")
    {
        Caption = 'Contact Email';
    }

    /// <summary>
    /// Represents an update to the full name property of a user.
    /// </summary>
    value(2; "Full Name")
    {
        Caption = 'Full Name';
    }

    /// <summary>
    /// Represents an update to the assigned plans for a user.
    /// </summary>
    value(3; Plan)
    {
        Caption = 'Plan';
    }

    /// <summary>
    /// Represents an update to the language setting of a user.
    /// </summary>
    value(4; "Language ID")
    {
        Caption = 'Language ID';
    }
}