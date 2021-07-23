// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

Codeunit 138049 "User Login Test Library"
{
    Permissions = tabledata "User Login" = rim;

    /// <summary>
    /// Creates login information for a user.
    /// </summary>
    /// <param name="UserSID">The security ID of the user for whom to create the login information</param>
    /// <param name="FirstLoginDate">Date to be entered as first login</param>
    /// <param name="LastLoginDateTime">Date time to be entered as last login</param>
    /// <param name="PenultimateLoginDateTime">Date time to be entered as penultimate login</param>
    procedure InsertUserLogin(UserSID: Guid; FirstLoginDate: Date; LastLoginDateTime: DateTime; PenultimateLoginDateTime: DateTime)
    var
        UserLogin: Record "User Login";
    begin
        UserLogin."User SID" := UserSID;
        UserLogin."First Login Date" := FirstLoginDate;
        UserLogin."Last Login Date" := LastLoginDateTime;
        UserLogin."Penultimate Login Date" := PenultimateLoginDateTime;

        UserLogin.Insert();
    end;

    /// <summary>
    /// Updates login information for a user.
    /// </summary>
    /// <param name="UserSID">The security ID of the user for whom to update the login information</param>
    /// <param name="FirstLoginDate">Date to be entered as first login</param>
    /// <param name="LastLoginDateTime">Date time to be entered as last login</param>
    /// <param name="PenultimateLoginDateTime">Date time to be entered as penultimate login</param>
    procedure UpdateUserLogin(UserSID: Guid; FirstLoginDate: Date; LastLoginDateTime: DateTime; PenultimateLoginDateTime: DateTime)
    var
        UserLogin: Record "User Login";
    begin
        UserLogin.Get(UserSID);

        UserLogin."First Login Date" := FirstLoginDate;
        UserLogin."Last Login Date" := LastLoginDateTime;
        UserLogin."Penultimate Login Date" := PenultimateLoginDateTime;

        UserLogin.Modify();
    end;

    /// <summary>
    /// Deletes all login information for a user.
    /// </summary>
    /// <param name="UserSID">The security ID of the user for whom to delete the login information</param>
    procedure DeleteAllLoginInformation(UserSID: Guid)
    var
        UserLogin: Record "User Login";
    begin
        UserLogin.SetRange("User SID", UserSID);

        UserLogin.DeleteAll();
    end;
}